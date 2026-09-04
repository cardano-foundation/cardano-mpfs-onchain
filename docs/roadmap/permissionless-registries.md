# Permissionless Registries

Everything on this page is **planned work, tracked as open issues**. None of it
is in the shipped validators. The behaviour that ships today is described in
[Validators](../architecture/validators.md) and
[Security Properties](../architecture/properties.md).

## The hole: the cage needs its oracle to be alive and willing

A cage has exactly one privileged party, the state owner. `Modify` and `End`
are both gated on `shared.validateOwnership`, and the request validator's
`Sweep` checks the same owner key. Everything a request can become — folded
into the trie, rejected, or cleaned up — passes through a transaction only
that party can author.

A requester's own escape is one window wide. During Phase 2 they may `Retract`.
Once Phase 2 closes, the request sits at the request address and the only
remaining path is `Modify(Rejected)`, which needs the owner's signature. An
oracle that goes offline, or simply declines to act, strands those funds
indefinitely — and it costs the oracle nothing, because nothing on-chain
obliges it to move.

That is why [Security Properties](../architecture/properties.md) lists *"oracle
honestly chooses which valid requests to process"* and *"requests can always
exit after Phase 3"* as off-chain behaviour rather than enforced guarantees.
They are assumptions about a party, not properties of the code.

The same single-owner assumption is what stops a cage from being a public
registry. A registry has no oracle: anyone should be able to fold the queue,
with the registry's own rules — not a key holder's discretion — deciding what
is allowed.

## The three changes

### 1. Sweep without an owner signature — [#98](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/98)

Give Phase 3 cleanup a permissionless path, so no request can be held past its
own expiry.

The safety argument is structural rather than added: a `Modify` in which every
action is `Rejected` returns the input root unchanged by construction, so the
permissionless branch cannot touch the MPF at all. It can only retire expired
requests and pay their owners back. The sweeper collects `n * tip`, exactly as
the oracle does, so cleanup becomes more attractive the longer an oracle is
absent.

Two things `validModify` leaves open must be closed first, because both are
currently safe only by virtue of the owner gate:

- `owner` and `stake_script` are mutable across `Modify` — deliberate, for
  oracle rotation, but on an open branch it means whoever sweeps first can
  seize the cage;
- the refund rule bounds only the aggregate and subtracts an unbounded
  `tx_fee`, so a stranger who builds the transaction chooses both its cost to
  the requesters and its distribution among them —
  [#97](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/97)
  and
  [#77](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/77).

This buys *exit*, not censorship resistance. An oracle that never issues an
`UpdateAction` still never folds anything into the trie; forced processing is a
separate design.

### 2. Plugin cages — [#99](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/99)

Turn the `stake_script` hook into a real delegated authorization path, so a
validator — not a key holder — decides what a fold may do.

Three gaps stand between the hook as shipped and that:

| Gap | Today | Planned |
|---|---|---|
| Authorization | `validateOwnership` requires the owner signature in **both** branches, and `staking.ak` returns `True` for every withdrawal ([#79](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/79)) | On the delegated path the withdrawal **replaces** the owner signature; an owner bypass would void every rule the plugin enforces |
| Hook integrity | `stake_script` and `owner` fall under `..` in the output-state pattern, so any authorized `Modify` can swap the plugin; `Modify([])` is accepted, re-creating the state UTxO and invalidating every fold built against it | [#100](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/100) pins both fields and forbids the empty fold on the delegated path |
| Value routing | `sumRefunds` returns each processed request's lovelace to a key-hash owner, positionally, and rejects a script credential | [#101](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/101) lets the plugin route `UpdateAction` value into outputs it creates; `Rejected` refunds stay the cage's job, so exit never depends on the plugin |

[#102](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/102)
writes the plugin contract down — what a `stake_script` validator may rely on
— and proves it with a mint-coupled reference registry exercised on a devnet,
replacing the always-true stub in the shipped blueprint.
[#103](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/103)
lifts the Lean model from lemmas to a plugin-parametric cage machine, so the
difference between the cage as shipped and the cage a registry needs is a set
of theorems rather than prose.

### 3. The keri registry plugin and its leaf map — [#104](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/104)

The first real plugin, and the interface a consumer actually reads. Per
identity the store remembers one of four things:

```text
absent  →  live  →  closed(epoch, sn)  →  live      (reopen, sn strictly greater)
              ↓
          convicted                                  (terminal)
```

- `Insert` of an absent key registers the identity and mints its checkpoint
  token in the same transaction;
- `Update` from `closed(epoch, sn)` back to `live` is the reopen, allowed only
  with a witnessed rotation whose sequence is strictly greater than the
  recorded `sn`;
- `Update` from `live` to `closed` or `convicted` comes only from the
  checkpoint's own close or convict transaction;
- `convicted` is terminal — the token is never burned, so the row can never be
  deleted and the name never re-minted.

## The consumer

[lambdasistemi/cardano-keri](https://github.com/lambdasistemi/cardano-keri)
milestone M1 uses a **permissioned** cage as its AID registry: one MPF root
holding every identity ever registered, with the guarantee that an identity is
incarnated once and once only.

| What | Where |
|---|---|
| Registry integration epic (K6) | [lambdasistemi/cardano-keri#324](https://github.com/lambdasistemi/cardano-keri/issues/324) |
| Registry model and simulator | [lambdasistemi/cardano-keri#316](https://github.com/lambdasistemi/cardano-keri/issues/316) |
| Upstream tracking: permissionless batching | [lambdasistemi/cardano-keri#329](https://github.com/lambdasistemi/cardano-keri/issues/329) |
| Upstream tracking: gating plugin | [lambdasistemi/cardano-keri#330](https://github.com/lambdasistemi/cardano-keri/issues/330) |

The interface it consumes is the leaf map above: `absent` / `live` /
`closed(epoch, sn)` / `convicted`. Nothing else about the cage crosses the
boundary.

The registry state machine can be replayed scenario by scenario in the
simulator:

<https://lambdasistemi.github.io/cardano-keri/simulator/registry/>

M1 ships against the permissioned cage — the registry's own operator holds the
key. The work on this page is what removes that operator from the trust
argument.

## Issue index

| Issue | Title |
|---|---|
| [#97](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/97) | `Modify` charges requesters an unbounded `tx_fee` |
| [#98](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/98) | epic: permissionless Phase 3 sweep |
| [#99](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/99) | epic: plugin cages — delegated authorization and value routing |
| [#100](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/100) | Delegated path: pin `stake_script` and `owner`, forbid empty `Modify` |
| [#101](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/101) | Delegated path: route processed-request value through the plugin |
| [#102](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/102) | Plugin contract docs and a mint-coupled reference plugin |
| [#103](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/103) | Lean: plugin-parametric cage machine |
| [#104](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/104) | keri registry plugin: the leaf map |
