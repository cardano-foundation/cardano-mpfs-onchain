# Security Properties

This page documents the security properties enforced by the MPF Cage
validators. The properties are covered by the Aiken test suite, Haskell
encoding tests, and the Lean models in `lean/MpfsCage`.

Run `aiken check` (or `just test`) for validator tests. Run `lake build` in
`lean/` for the formal phase, token, and split-validator proofs.

## Roles

- **Oracle**: the state owner. Can modify state, reject expired or dishonest
  requests through `Modify(Rejected)`, sweep malformed request-address UTxOs,
  and end the cage.
- **Requester**: the request owner. Can submit requests and retract them during
  Phase 2.
- **Observer**: reconstructs MPF state from chain history.

## On-chain vs Off-chain Guarantees

| Guarantee | Enforced by |
|---|---|
| Token identity is unique | State mint policy consumes the seed UTxO |
| State policy moves exactly one state-policy asset | `exactQuantity` |
| State UTxO references are authentic | `(statePolicyId, cageToken)` check |
| Only the oracle updates or ends state | `State.owner` signature, plus a `stake_script` withdrawal when one is set |
| Only the requester retracts a request | `Request.requestOwner` signature |
| Request updates carry valid MPF proofs | On-chain MPF proof verification |
| Output root matches proof computation | State `Modify` fold |
| Requesters can reclaim Phase 2 requests | Request `Retract` |
| Expired or dishonest requests can be rejected | `Modify(Rejected)` |
| Malformed request-address UTxOs can be cleaned up | Request `Sweep` |
| Processable requests cannot be swept | `processableRequest` guard |
| Phase windows are exclusive | Validity-range checks and Lean proofs |
| Oracle honestly chooses which valid requests to process | Off-chain behavior |
| Requests can always exit after Phase 3 | Off-chain behavior — no permissionless path exists |
| Proofs are generated against the intended trie state | Off-chain behavior |
| History is reconstructable | Ledger property |

The two off-chain behavior rows about the oracle are the liveness hole: an
oracle that stops acting strands funds at the request address, and nothing
on-chain forces it to act. The
[permissionless registries roadmap](../roadmap/permissionless-registries.md)
is the plan to close the exit half of it.

## 1. Token Uniqueness

**Invariant:** a cage token asset name under the state policy is creatable
only via seed derivation (`Minting`) or via authenticated provenance from an
allowlisted predecessor (`Migrating`, see §13); no path accepts an arbitrary
asset name or an arbitrary predecessor policy.

The seed-derived asset name is `SHA2-256(tx_id ++ output_index)`. Since the
seed UTxO can be consumed only once, the ledger gives uniqueness for
`Minting`. `Migrating` carries the asset name forward from an already-unique,
audited predecessor rather than deriving a fresh one — see §13 for how its
provenance is authenticated.

Representative tests: `assetName_deterministic`,
`assetName_different_txid`, `assetName_different_index`,
`prop_assetName_deterministic`.

## 2. State-Policy Mint and Burn Integrity

**Invariant:** every mint, migration, and burn under the global state policy
moves exactly one asset under that policy.

`Minting(seed)` requires exactly `+1` of `assetName(seed)`.
`Migrating` requires exactly `-1` under the old policy and `+1` under the
state policy, *and* additionally requires the old policy to be an allowlisted
predecessor whose UTxO is actually spent (§13) — mint/burn quantities alone
are not sufficient proof of a legitimate migration. `Burning(tokenId)`
requires exactly `-1` of that token. Extra assets under the state policy are
rejected.

Representative tests: `canMint`, `mint_missing_input`,
`mint_quantity_two`, `mint_extra_state_policy_asset`, `canMigrate`,
`end_happy`, `end_with_extra_state_policy_asset`.

Lean theorem: `exactQuantity_rejects_extra_same_policy_asset`.

## 3. Split Validator Authentication

**Invariant:** request spends authenticate the referenced state UTxO by both
policy ID and asset name.

The request validator is parameterized by `(statePolicyId, cageTokenName)`.
It rejects fake state UTxOs that carry the same asset name under a foreign
policy.

Representative tests: `contribute_rejects_foreign_policy_state_same_asset`,
`wrong_request_parameter_rejects_this_cage_token`.

Lean theorems: `contribute_rejects_foreign_policy_state_same_asset`,
`wrong_request_parameter_rejects_cage_token`.

## 4. Contribute Cannot Bypass State Modify

**Invariant:** `Contribute(stateRef)` requires `stateRef` in regular
transaction inputs, not only reference inputs, and the state input must be
spent with `Modify`.

This prevents a request UTxO from being consumed without state `Modify`
running the root and refund checks.

Representative tests: `contribute_missing_ref`,
`contribute_reference_only_state_rejected`,
`contribute_with_state_end_rejected`.

Lean theorems: `contribute_rejects_reference_only_state`,
`contribute_rejects_state_spent_without_modify`.

## 5. Ownership and Authorization

**Invariant:** privileged operations require the relevant owner signature.

| Operation | Required signer |
|---|---|
| State `Modify` | `State.owner`, plus a `stake_script` withdrawal when set |
| State `End` | `State.owner`, plus a `stake_script` withdrawal when set |
| Mint `Migrating` | the predecessor `State.owner`, under the same rule |
| Request `Sweep` | current `State.owner`, key signature only |
| Request `Retract` | `Request.requestOwner` |
| Request `Contribute` | permissionless, but authenticated against state |

The `stake_script` hook is conjunctive (`shared.validateOwnership`): it adds a
withdrawal requirement, it never replaces the owner signature. The shipped
`staking.ak` stub returns `True` for every withdrawal, so a cage booted with
it gains no guarantee — both points are
[#79](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/79),
and the delegated authorization a permissionless registry needs is roadmap
work, not shipped behaviour
([roadmap](../roadmap/permissionless-registries.md)).

Representative tests: `modify_missing_signature`, `end_missing_signature`,
`sweep_wrong_signer`, `retract_wrong_signer`,
`prop_retract_requires_owner`, `prop_modify_requires_owner`,
`modify_with_stake_script_withdrawal`,
`modify_with_stake_script_no_withdrawal`, `end_with_stake_script`,
`end_with_stake_script_no_withdrawal`, `migrate_missing_owner_signature`.

## 6. State Confinement and Immutability

**Invariant:** after `Modify`, the state output remains at the state script,
carries the same cage token, and preserves `tip`, `process_time`, and
`retract_time`.

The state output must also hold at least as much lovelace as the state input.

`owner` and `stake_script` are intentionally mutable, allowing oracle rotation
through a normal `Modify`. That is safe only because `Modify` is owner-gated;
pinning both is a prerequisite of every permissionless path
([#98](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/98),
[#100](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/100)).

Representative tests: `modify_wrong_address`, `modify_owner_transfer`,
`modify_output_must_hold_token`, `migrate_changes_tip`, `migrate_changes_owner`.

Coverage gap: the `tip`, `process_time`, and `retract_time` equalities are
enforced at `validators/state.ak` on the `Modify` path, but no Aiken test
mutates them there — the negatives above cover the `Migrating` path only.

## 7. MPF Root Integrity

**Invariant:** the output root equals the result of folding matching request
actions over the input root.

`UpdateAction(proof)` applies an MPF insert, delete, or update proof.
`Rejected` leaves the root unchanged for that request.

Representative tests: `canCage`, `modify_wrong_root`,
`modify_no_requests`, `modify_skip_other_token`, `modify_too_few_proofs`,
`modify_extra_proofs`.

## 8. Refund and Tip Accounting

**Invariant:** the total paid back to processed request owners lies between
what they are owed and what the oracle may keep:

```text
owed        = total request input lovelace - tx_fee - n * state.tip
maxRefunded = total request input lovelace - n * state.tip

owed <= totalRefunded <= maxRefunded
```

It is a range, not an equality: a refund may exceed `owed` so an output can
reach the ledger min-UTxO floor. The state output's lovelace is pinned
non-decreasing, so that top-up comes from funding inputs rather than the cage.

The request tip must match `state.tip` for processable requests.

Two limits are open and both block any permissionless builder: `tx_fee` enters
`owed` unbounded
([#97](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/97)),
and the bounds are aggregate with no per-owner floor
([#77](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/77)).

Representative tests: `modify_with_refund`, `modify_missing_refund`,
`modify_insufficient_refund`, `modify_wrong_refund_address`,
`modify_zero_fee`, `modify_fee_mismatch`.

## 9. Datum-Redeemer Type Safety

**Invariant:** each validator path accepts only the datum and redeemer shapes
it owns.

| Validator | Accepted redeemers |
|---|---|
| state | `Modify`, `End` |
| request | `Contribute`, `Retract`, `Sweep` |

Representative tests: `retract_on_state_datum`, `contribute_on_state_datum`,
`modify_on_request_datum`, `end_on_request_datum`, `state_sweep_rejected`.

## 10. Time-Gated Phases

**Invariant:** each request is in exactly one lifecycle phase for point
validity ranges, and straddling ranges are rejected by the validators.

```text
submitted_at          + process_time       + process_time + retract_time
    |                        |                        |
    |   Phase 1: Modify      |   Phase 2: Retract     |   Phase 3: Rejected
```

Representative tests: `retract_in_phase1`, `retract_happy`,
`retract_in_phase3`, `contribute_in_phase2`, `contribute_in_phase3`,
`modify_in_phase2`, `reject_happy`, `reject_in_phase1`, `reject_in_phase2`,
`reject_future_submitted_at`, `prop_phase1_phase2_exclusive`,
`prop_phase_coverage_point`.

Lean theorems: `phase1_phase2_exclusive`, `phase1_phase3_exclusive`,
`phase2_phase3_exclusive`, `phase1_honest_not_rejectable`,
`phase2_honest_not_rejectable`, `phase_coverage_point`.

## 11. Request Sweep

**Invariant:** the state owner can sweep request-address garbage, but cannot
sweep a request that state `Modify` can process.

Protected requests must have matching token, matching tip, and enough lovelace
to cover `state.tip`. Wrong-token, no-datum, mismatched-tip, and underfunded
matching-token UTxOs are sweepable.

Representative tests: `sweep_no_datum`, `sweep_wrong_token_request`,
`sweep_mismatched_tip_request`, `sweep_underfunded_matching_request`,
`sweep_legitimate_request`, `sweep_fake_state_ref`, `sweep_alongside_modify`.

Lean theorems: `sweep_mismatched_tip_request_allowed`,
`sweep_underfunded_matching_request_allowed`,
`protected_request_not_sweepable`.

## 12. Token Extraction

**Invariant:** token extraction is unambiguous.

`tokenFromValue` returns a token only when the value has exactly one non-ADA
policy with exactly one asset name. `tokenFromPolicy` scopes extraction to a
specific policy and rejects zero or multiple assets under that policy.

Representative tests: `tokenFromValue_single_nft`, `tokenFromValue_ada_only`,
`tokenFromValue_multi_policy`, `tokenFromValue_multi_asset`,
`tokenFromValue_roundtrip`.

Lean theorems: `valueFromToken_roundtrip`, `tokenFromValue_ada_only`,
`tokenFromValue_multi_policy`, `tokenFromValue_multi_asset`.

## 13. Migration Provenance

**Invariant:** `Migrating` proves that the migrated state token descends from
an audited predecessor, not from an attacker-chosen policy.

The `state` validator is parameterized by an immutable
`previousPolicies: List<PolicyId>` allowlist. `validateMigration` enforces,
in order:

1. **Allowlist** — `oldPolicy` must be a member of `previousPolicies`. A
   genesis cage is deployed with `previousPolicies = []`, so migration into
   it is impossible; its tokens exist only via seed `Minting` (§1).
2. **Provenance by spend** — a transaction input must actually carry
   `(oldPolicy, tokenId)`; the migrated `State` is read from that input's
   datum (`predState`), not from the redeemer.
3. **Owner authorization** — `predState`'s owner must authorize the
   migration via the existing ownership rule (§5).
4. **Full field preservation** — the migrated output `State` must equal
   `predState` in every field. Migration is a pure re-policy operation; it
   cannot introduce an owner or parameter change (that remains `Modify`'s
   job, §6).

Without the allowlist, provenance-by-spend + owner-sig + field-preservation
are all trivially satisfiable by an attacker who authors the fake
predecessor datum himself, since he controls an always-true `oldPolicy`.
Requiring `oldPolicy ∈ previousPolicies` forces the burned token to be a
genuine audited predecessor whose asset name the attacker does not control.

Representative tests: `canMigrate`, `migrate_old_policy_not_allowlisted`,
`migrate_no_predecessor_input`, `migrate_missing_owner_signature`,
`migrate_changes_owner`, `migrate_changes_tip`,
`migrate_forged_token_cannot_sweep`.
