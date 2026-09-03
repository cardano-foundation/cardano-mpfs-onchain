# Validators

The on-chain logic is split across two validator modules:

- [`state.ak`](https://github.com/cardano-foundation/cardano-mpfs-onchain/blob/main/validators/state.ak)
  defines the global state minting policy and the state UTxO spending rules.
- [`request.ak`](https://github.com/cardano-foundation/cardano-mpfs-onchain/blob/main/validators/request.ak)
  defines the per-cage request spending rules.

Shared predicates live in
[`shared.ak`](https://github.com/cardano-foundation/cardano-mpfs-onchain/blob/main/validators/shared.ak),
and token helpers live in
[`lib.ak`](https://github.com/cardano-foundation/cardano-mpfs-onchain/blob/main/validators/lib.ak).
[`staking.ak`](https://github.com/cardano-foundation/cardano-mpfs-onchain/blob/main/validators/staking.ak)
is the withdrawal stub used by the optional staking-script ownership hook
(see [Ownership](#ownership)).

## Validator Parameters

The state validator carries one immutable parameter:

```aiken
validator state(previousPolicies: List<PolicyId>) {
```

| Parameter | Type | Description |
|---|---|---|
| `previousPolicies` | `List<PolicyId>` | Allowlist of audited predecessor policies a `Migrating` mint may descend from |

A genesis deployment sets `previousPolicies = []`, which makes migration into
it impossible; its tokens exist only through seed `Minting`. The parameter is
part of the script, so each allowlist value produces a distinct policy ID.

That policy ID is the global discovery anchor for all cages of this
validator version. A specific cage is identified by the pair
`(statePolicyId, cageToken)`, where `cageToken` is the asset name minted
under the state policy.

The request validator is parameterized per cage:

```aiken
validator request(statePolicyId: PolicyId, cageTokenName: AssetName) {
```

| Parameter | Type | Description |
|---|---|---|
| `statePolicyId` | `PolicyId` | Policy ID of the global state validator |
| `cageTokenName` | `AssetName` | Asset name of the cage token handled by this request instance |

Wallets can derive the canonical request address from the audited request
blueprint plus `(statePolicyId, cageTokenName)`. Request spends then
authenticate the referenced state UTxO by checking that it carries exactly
one `(statePolicyId, cageTokenName)` token.

## State Minting Policy

### Boot (`Minting(seed)`)

Creates a new cage token under the global state policy.

Validation rules:

1. The `seed` `OutputReference` is consumed by the transaction.
2. The asset name is `assetName(seed)`.
3. The mint field contains exactly one asset under the state policy:
   `(policyId, assetName(seed)) = 1`.
4. No other asset under the state policy is minted or burned.
5. The first output is locked at the state script address.
6. The output datum is `StateDatum` with `root(empty)`.
7. The output value contains exactly one cage token.

```mermaid
graph LR
    UTXO["Consumed seed UTxO"]
    TX["Boot transaction"]
    STATE["State UTxO<br/>global policy + cage asset<br/>empty MPF root"]

    UTXO --> TX
    TX -->|"Minting(seed)"| STATE
```

### Migration (`Migrating(migration)`)

Carries a cage token identity forward from an audited predecessor policy to
the new global state policy.

Validation rules:

1. `oldPolicy` is a member of the `previousPolicies` parameter.
2. Exactly one old token `(oldPolicy, tokenId)` is burned.
3. Exactly one new token `(statePolicyId, tokenId)` is minted.
4. No unrelated state-policy asset is moved.
5. A transaction input actually carries `(oldPolicy, tokenId)`; the migrated
   `State` is read from that input's inline datum, not from the redeemer.
6. The predecessor `State` authorizes the migration under the ownership rule
   below.
7. The first output is locked at the new state script address and carries
   exactly one `(statePolicyId, tokenId)` token.
8. The output `StateDatum` equals the predecessor `State` in every field.
   Migration is a pure re-policy operation; it cannot change the owner, the
   staking hook, the root, or the phase parameters.

Dropping any one of rules 1 and 5-8 makes the path forgeable: without the
allowlist an attacker supplies an `oldPolicy` he controls and authors the
predecessor datum himself. See
[Security Properties §13](properties.md#13-migration-provenance).

### Burn (`Burning(tokenId)`)

Burns a cage token when paired with state spending redeemer `End`.

Validation rules:

1. The mint field contains exactly `-1` of `(statePolicyId, tokenId)`.
2. No unrelated asset under the state policy is moved.

## Ownership

Every privileged state operation — `Modify`, `End`, and the predecessor side
of `Migrating` — goes through `shared.validateOwnership`:

| `State.stake_script` | Required authorization |
|---|---|
| `None` | `State.owner` is in `tx.extra_signatories` |
| `Some(script)` | `State.owner` is in `tx.extra_signatories` **and** the transaction carries a withdrawal under `Script(script)` |

The hook is conjunctive: a staking script can only add a condition, never
replace the owner signature. It covers the state-side operations only; the
request validator's `Sweep` reads `State.owner` and checks that signature
directly. `staking.ak`, the stub shipped in the blueprint,
returns `True` unconditionally for any `withdraw`, so a cage booted against it
gains no extra guarantee. Both facts are tracked as
[#79](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/79),
and replacing the conjunction with a real delegated path is the subject of the
[permissionless registries roadmap](../roadmap/permissionless-registries.md).

## State Spending Validator

`state.spend` accepts only `StateDatum` inputs. Authorization follows
[Ownership](#ownership),
the spent input must be locked at the state validator's script credential,
and the input value must carry exactly one cage token under the state policy.

Accepted redeemers:

| Redeemer | Purpose |
|---|---|
| `Modify(List<RequestAction>)` | Process matching request inputs |
| `End` | Burn and destroy the cage token |

All other redeemers fail at the state address.

### Modify

The owner applies pending requests to the MPF trie. The transaction spends
the state UTxO with `Modify(actions)` and spends each request UTxO with the
request validator's `Contribute(stateRef)` redeemer.

Validation rules:

1. The transaction is authorized under [Ownership](#ownership).
2. The first output remains at the state script credential.
3. The first output carries exactly one same cage token.
4. The first output holds at least as much lovelace as the state input.
5. `tip`, `process_time`, and `retract_time` are immutable. `owner` and
   `stake_script` are not: an owner may hand the cage over in a normal
   `Modify`.
6. Matching request inputs are those with `RequestDatum.requestToken` equal
   to the cage token. Each must record `tip` equal to `state.tip`.
7. Each matching request consumes one `RequestAction` in input order.
8. `UpdateAction(proof)` is allowed only in Phase 1 and folds the MPF proof
   into the root.
9. `Rejected` is allowed only for rejectable requests: Phase 3 or dishonest
   future `submitted_at`.
10. The output root equals the folded root.
11. Refund outputs follow the state input positionally, one per processed
    request owner, and their total lies within bounds (see below).

```mermaid
graph TD
    STATE_IN["State UTxO<br/>redeemer: Modify [actions]"]
    REQ1["Request UTxO<br/>redeemer: Contribute(stateRef)"]
    REQ2["Request UTxO<br/>redeemer: Contribute(stateRef)"]
    FOLD["Fold update actions<br/>skip rejected actions"]
    STATE_OUT["State UTxO<br/>new or unchanged root"]
    REFUNDS["Requester refunds"]

    STATE_IN --> FOLD
    REQ1 --> FOLD
    REQ2 --> FOLD
    FOLD --> STATE_OUT
    FOLD --> REFUNDS
```

#### Refund bounds

With `n` processed requests contributing `totalInputLovelace`, the validator
enforces a range rather than an equality:

```text
owed        = totalInputLovelace - tx_fee - n * state.tip
maxRefunded = totalInputLovelace - n * state.tip

owed <= totalRefunded <= maxRefunded
```

The upper bound is what the oracle may keep; the lower bound is what the
requesters are owed. Refunds are allowed to exceed `owed` so an output can
reach the ledger min-UTxO floor — the state output's own lovelace is pinned
non-decreasing, so the top-up comes from the funding inputs, not from the
cage.

Two limits of this rule are open issues, and both matter before anyone but
the oracle can build a `Modify`:

- `tx_fee` enters `owed` unbounded, so whoever builds the transaction can
  charge unrelated business to the requesters
  ([#97](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/97));
- the bounds are aggregate, with no per-owner floor, so the builder chooses
  the distribution across requesters
  ([#77](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/77)).

### End

Destroys the cage token instance.

Validation rules:

1. The transaction is authorized under [Ownership](#ownership).
2. The mint field burns exactly the cage token from the spent state input.
3. No unrelated asset under the state policy is moved.

## Request Spending Validator

`request(statePolicyId, cageTokenName).spend` accepts request-side operations
for one cage. It does not update the MPF state directly; it authenticates the
referenced state UTxO and enforces the request lifecycle rules.

Accepted redeemers:

| Redeemer | Purpose |
|---|---|
| `Contribute(OutputReference)` | Spend a request with state `Modify` |
| `Retract(OutputReference)` | Let the request owner reclaim a Phase 2 request |
| `Sweep(OutputReference)` | Let the state owner clean up request-address garbage |

All other redeemers fail at the request address.

### Contribute

Validation rules:

1. The spent UTxO must carry `RequestDatum`.
2. `requestToken` must equal the request validator's `cageTokenName`.
3. `stateRef` must be present in regular `tx.inputs`, not only in
   `tx.reference_inputs`.
4. The state input's redeemer must be `Modify`; `End` or any other state
   spend cannot be used to authorize request consumption.
5. The referenced state input must carry exactly one
   `(statePolicyId, cageTokenName)` token.
6. The request must be in Phase 1 or be rejectable.

The regular-input plus `Modify`-redeemer requirement prevents request
consumption without state `Modify` also running the root and refund checks.

### Retract

Validation rules:

1. The spent UTxO must carry `RequestDatum`.
2. `requestToken` must equal the request validator's `cageTokenName`.
3. The request owner signs the transaction.
4. `stateRef` may be in regular inputs or reference inputs.
5. The referenced state UTxO must carry exactly one
   `(statePolicyId, cageTokenName)` token.
6. The request must be in Phase 2.

### Sweep

`Sweep` exists because anyone can send arbitrary UTxOs to a request address.
Without a cleanup path, no-datum or malformed matching-token spam could be
locked forever.

Validation rules:

1. `stateRef` may be in regular inputs or reference inputs.
2. The referenced state UTxO must carry exactly one
   `(statePolicyId, cageTokenName)` token.
3. The `State.owner` read from the referenced state signs the transaction.
   `Sweep` checks that key directly and does **not** consult `stake_script`,
   unlike the state-side operations.
4. The spent UTxO is not a processable request for the referenced state.

A request is protected from sweep only when all of these hold:

1. It has `RequestDatum`.
2. `requestToken == cageTokenName`.
3. `request.tip == state.tip`.
4. The spent request value contains at least `state.tip` lovelace.

Therefore no-datum UTxOs, wrong-token requests, mismatched-tip requests, and
underfunded matching-token requests are sweepable. Processable legitimate
requests are not sweepable.

## Helper Predicates

| Function | Purpose |
|---|---|
| `exactQuantity` | Requires exactly one asset under a policy with the expected quantity |
| `tokenFromPolicy` | Extracts the sole asset name under a specific policy |
| `carriesStateToken` | Authenticates a state UTxO by `(statePolicyId, cageToken)` |
| `validateOwnership` | Owner signature, plus a `stake_script` withdrawal when one is set |
| `in_phase1` | Checks the oracle processing window |
| `in_phase2` | Checks the requester retract window |
| `is_rejectable` | Checks Phase 3 or dishonest future `submitted_at` |
| `processableRequest` | Defines which request UTxOs are protected from `Sweep` |
