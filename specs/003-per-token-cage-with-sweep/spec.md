# Feature Specification: Per-token cage validator with owner sweep

**Feature Branch**: `feat/47-per-token-cage-with-sweep`
**Created**: 2026-04-27
**Status**: Draft
**Input**: Issue [#47](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/47) — "feat: per-token cage validator parameterized by seed, with owner sweep"
**Supersedes**: [#24](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/24) — per-oracle parameterization (rejected; see *Rejected approaches* below)

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Per-token cage address (Priority: P1)

Each cage instance lives at its own address, derived from a parameterized validator. Off-chain consumers querying "all pending requests for token T" get a CSMT address-completeness proof that covers exactly T's requests, with no cross-token leakage.

**Why this priority**: This is the structural change that closes the cross-token bandwidth coupling and lets the off-chain client ship a cryptographically meaningful per-token completeness proof. Every other change in this issue depends on it.

**Independent Test**: Compile `mpfCage(seed: OutputReference)` against two distinct seeds and verify the resulting script hashes (and therefore addresses) differ. Mint two tokens, one under each instance. Confirm CSMT subtree completeness at instance A's address never contains UTxOs related to instance B's token.

**Acceptance Scenarios**:

1. **Given** two distinct seeds `s1` and `s2`, **When** the validator is compiled with each seed, **Then** the resulting script hashes differ, and the resulting addresses differ.
2. **Given** a cage minted under `mpfCage(s1)` with token id `assetName(s1)`, **When** another party submits a `RequestDatum { requestToken = assetName(s2), ... }` UTxO at this cage's address, **Then** that UTxO is not legitimate for instance `s1` and is sweepable by `s1`'s owner.
3. **Given** the off-chain client queries `GET /tokens/{policyId}/requests`, **When** the server provides a CSMT subtree-completeness proof at the cage's address, **Then** the result contains exactly the legitimate requests for that one token (after the client's local datum-decode filter).

---

### User Story 2 — Mint authorization via seed consumption (Priority: P1)

Mint authorization comes from consuming the seed UTxO, not from a signature gate. The validator parameter is `seed: OutputReference`; `validateMint` requires that exact UTxO to be consumed in the mint transaction. The seed is also the asset-name source: `tokenId = TokenId { assetName: assetName(seed) }`.

**Why this priority**: This is the security property that makes the cage address commit-on-mint rather than publicly predictable. Without it, an adversary who knows the parameter scheme can pre-compute a victim's address before they ever mint. With seed-based mint authorization, the address is fully determined only at the moment the seed is consumed.

**Independent Test**: Build a mint transaction whose body does not include the seed UTxO as an input; the validator must reject. Build a mint transaction whose mint field carries a token whose asset name does not match `assetName(seed)`; the validator must reject. Build a correct mint transaction; it succeeds.

**Acceptance Scenarios**:

1. **Given** a transaction that does not consume `seed`, **When** the mint validator runs, **Then** it rejects with `find_input(inputs, seed) = None`.
2. **Given** a transaction that consumes `seed` but mints under an incorrect asset name, **When** the mint validator runs, **Then** it rejects.
3. **Given** a transaction that consumes `seed` and mints exactly `+1` of `(thisPolicyId, assetName(seed))` to the cage's own address, **Then** the mint succeeds.
4. **Given** a third-party adversary who knows the parameter scheme, **When** they attempt to derive the address of an oracle's future cage from public information alone, **Then** they cannot — they would need the oracle's chosen seed UTxO ref, which the oracle has not yet committed to.

---

### User Story 3 — Owner sweeps non-legitimate UTxOs (Priority: P1)

The cage owner can reclaim any UTxO at the cage's address that is not a legitimate request UTxO for this token and not the legitimate state UTxO. The redeemer carries the state UTxO's reference for direct lookup; the validator confirms the pointed-to UTxO carries `cageToken` under `policyId`, reads the state datum, requires `state.owner ∈ extra_signatories`, and runs the garbage predicate at the spent UTxO.

**Why this priority**: Without sweep, garbage at the cage address is permanently locked (no spend path covers it under the current validator). With per-token addressing the blast radius of any one cage's spam is bounded to that cage, but the owner still needs a way to reclaim the dust to keep response payloads small.

**Independent Test**: Deposit a UTxO with no inline datum at the cage address; the cage owner spends it with `Sweep(stateRef)` while the state UTxO is in `tx.reference_inputs`. Repeat with a `RequestDatum` whose `requestToken` does not match `cageToken`, and with a `StateDatum` UTxO whose value does not carry `cageToken`. All three are sweepable. The same redeemer fails when (a) the spender is not the cage owner, (b) the redeemer points at a UTxO that is not the legitimate state, (c) the spent UTxO is itself the legitimate state, (d) the spent UTxO is a legitimate request for this token.

**Acceptance Scenarios**:

1. **Given** the cage owner signs a transaction sweeping a no-datum UTxO at the cage address, with the state UTxO present as a reference input, **When** the spend validator runs, **Then** it accepts.
2. **Given** the cage owner signs a transaction sweeping a `RequestDatum` UTxO whose `requestToken ≠ cageToken`, **When** the spend validator runs, **Then** it accepts.
3. **Given** the cage owner signs a transaction sweeping a `StateDatum` UTxO whose value does NOT carry `cageToken`, **When** the spend validator runs, **Then** it accepts.
4. **Given** a non-owner attempts to sweep, **When** the spend validator runs, **Then** it rejects (`expect has(extra_signatories, owner)` fails).
5. **Given** the redeemer's `stateRef` points at a UTxO whose value does NOT carry `cageToken`, **When** the spend validator runs, **Then** it rejects (the redeemer's claim is checked).
6. **Given** the spent UTxO is the legitimate state UTxO (StateDatum + carries `cageToken`), **When** the spend validator runs `Sweep`, **Then** it rejects (legitimate state is excluded from the garbage predicate).
7. **Given** the spent UTxO is a legitimate request for this token (RequestDatum with `requestToken == cageToken`), **When** the spend validator runs `Sweep`, **Then** it rejects.

---

### User Story 4 — Zero-request Modify is accepted (Priority: P2)

The owner can submit a Modify transaction with an empty actions list. The validator preserves all the usual invariants (root unchanged, address preserved, time params immutable, owner signed) and skips the per-request refund-conservation equation.

**Why this priority**: This is the steady-state Oracle tick when the request queue is empty but the owner wants to sweep accumulated garbage in the same transaction. Without explicit support, the conservation equation reduces to `0 == -tx_fee`, which is unsatisfiable for any non-zero fee.

**Independent Test**: Build a `Modify([])` transaction with the state UTxO as the sole input from this script (no request inputs), one state output preserving root/address/time-params, and any Sweep inputs alongside. The validator accepts. Repeat with the root in the output differing from the input — must reject.

**Acceptance Scenarios**:

1. **Given** a Modify transaction with `actions = []`, no request inputs, and the state output preserving root/address/time-params, **When** the spend validator runs, **Then** it accepts.
2. **Given** a Modify transaction with `actions = []` and the state output mutating the MPF root, **When** the spend validator runs, **Then** it rejects.
3. **Given** a Modify transaction with `actions = []` and a Sweep input alongside (legitimate sweep target), **When** the spend validator runs, **Then** it accepts.

---

### User Story 5 — Defense-in-depth token check on Modify and End (Priority: P2)

The `Modify` and `End` paths in the spend validator explicitly check that the token extracted from the spent UTxO matches `cageToken` derived from the seed parameter. This closes any path where a third party could deposit a non-cage NFT with a fake `StateDatum` and have the spend handler operate on a foreign token.

**Why this priority**: The current implicit guarantee (only the cage's mint path produces a legitimate state UTxO) is sound but auditing-unfriendly. Adding the explicit check makes per-handler invariants standalone and removes a class of foreign-NFT-at-this-address concerns.

**Independent Test**: Construct a UTxO at the cage address carrying `StateDatum(StateOwnedBy { attacker_vkh })` and a foreign NFT (different policy id). The attacker (signing as `attacker_vkh`) attempts `Modify`. The validator rejects on `extractedToken ≠ cageToken`. The attacker's `End` attempt fails for the same reason.

**Acceptance Scenarios**:

1. **Given** a fake StateDatum UTxO with a foreign NFT at the cage address, **When** an actor attempts `Modify`, **Then** the validator rejects.
2. **Given** a fake StateDatum UTxO with a foreign NFT at the cage address, **When** an actor attempts `End`, **Then** the validator rejects.
3. **Given** the legitimate state UTxO with `cageToken`, **When** the owner runs `Modify` or `End` correctly, **Then** the validator accepts.

---

### User Story 6 — Migration enforces asset-name continuity (Priority: P2)

The `Migrating` redeemer pins `tokenId.assetName == assetName(seed)`. A migration into a new instance can only mint a token whose asset name matches the new instance's parameter. This rules out migrations that decouple the cage's identity from its on-chain commitment.

**Why this priority**: Migration is a less-common operation but the per-token model requires the new instance's policy id and asset name to match the seed. Without the pin, a migration tx could mint under the new policy id with an arbitrary asset name, breaking the per-token invariant.

**Acceptance Scenarios**:

1. **Given** a migration into `mpfCage(seed_new)` with `Migration { oldPolicy, tokenId }` where `tokenId.assetName == assetName(seed_new)`, **When** the mint validator runs, **Then** it accepts (alongside the existing burn-of-old-token check).
2. **Given** the same migration but with `tokenId.assetName ≠ assetName(seed_new)`, **When** the mint validator runs, **Then** it rejects.

---

### User Story 7 — Plutus blueprint reflects the new parameter and redeemer (Priority: P3)

Re-running `aiken build` produces a `plutus.json` blueprint with `seed: OutputReference` as the parameter and the extended `UpdateRedeemer` shape. Off-chain consumers depend on the blueprint to apply per-cage parameters via standard CIP-57 parameterization tooling.

**Independent Test**: After build, the blueprint's parameter schema for `mpfCage` lists exactly one parameter of type `OutputReference`, and the redeemer schema for the spend handler enumerates `End | Contribute | Modify | Retract | Sweep` constructors with the documented payloads.

**Acceptance Scenarios**:

1. **Given** `aiken build` runs cleanly, **When** the resulting `plutus.json` is inspected, **Then** the spend redeemer enumerates `Sweep(OutputReference)` and the validator parameter is `seed: OutputReference`.

---

### Edge Cases

- **Seed UTxO consumed before mint tx confirms.** Standard Cardano pattern: if the chosen seed UTxO is spent in another tx first, the mint tx fails at submission (UTxO already consumed). Off-chain tooling picks a fresh seed and retries.
- **Two cages racing on overlapping seeds.** Impossible by construction: a UTxO can only be spent once. Whichever transaction wins minted; the other fails.
- **Sweep with state in `tx.inputs` (bundled with Modify or End).** The redeemer's `OutputReference` lookup checks `tx.inputs ++ tx.reference_inputs`; either case works.
- **Sweep after `End`.** Once the cage is destroyed, the state UTxO no longer exists. Subsequent sweep attempts cannot find the state and fail. Operational discipline: the owner sweeps in the same tick as End or immediately before.
- **Sweep predicate on a UTxO whose datum is `Some(_)` but doesn't fit `CageDatum`.** Not possible at the type level: the validator's signature receives `Option<CageDatum>`, and the ledger's datum-typing enforces decode-or-`None`. Truly malformed datum bytes arrive as `None` and fall into the no-datum branch of the garbage predicate.
- **Empty modify with empty sweep.** A pure no-op tick: just refreshes the state UTxO. Allowed; the validator preserves all invariants. Operationally pointless but not unsafe.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The validator MUST be parameterized by `seed: OutputReference` (replacing `_version: Int`).
- **FR-002**: `validateMint` MUST derive `tokenId = TokenId { assetName: assetName(seed) }` from the parameter and MUST require the seed UTxO be present in `tx.inputs` (`is_some(find_input(inputs, seed))`).
- **FR-003**: The `MintRedeemer.Minting` constructor MUST be a unit constructor (no payload). The `Mint` redeemer-payload type MUST be removed.
- **FR-004**: `validateMigration` MUST add `expect tokenId.assetName == assetName(seed)`.
- **FR-005**: `UpdateRedeemer` MUST add a `Sweep(OutputReference)` constructor.
- **FR-006**: `validateSweep` MUST locate the state UTxO via the redeemer's `OutputReference` in `tx.inputs ++ tx.reference_inputs`, MUST confirm the pointed-to UTxO carries `cageToken` under `policyId`, MUST read the state datum and require `state.owner ∈ tx.extra_signatories`.
- **FR-007**: `validateSweep` MUST reject if the spent UTxO at `self` is the legitimate state UTxO (`Some(StateDatum(_))` AND value carries `cageToken`).
- **FR-008**: `validateSweep` MUST reject if the spent UTxO at `self` is a legitimate request for this cage (`Some(RequestDatum(req))` AND `req.requestToken == cageToken`).
- **FR-009**: `validateModify` MUST add `expect extractedToken == cageToken`.
- **FR-010**: `validateEnd` MUST add `expect extractedToken == cageToken`.
- **FR-011**: `validateModify` MUST accept `actions = []` provided the root, address, and time params are preserved; the per-request refund-conservation equation MUST be skipped when `n == 0`.
- **FR-012**: The Plutus blueprint emitted by `aiken build` MUST list `seed: OutputReference` as the validator parameter and the new `Sweep` constructor in the spend redeemer schema.

### Non-functional Requirements

- **NFR-001**: Validator script size MUST stay below the existing budget threshold (TBD; check post-build).
- **NFR-002**: Per-input validation cost for `Sweep` MUST be O(1) lookup (redeemer-pointed), not O(N) scan.
- **NFR-003**: All existing tests MUST still pass after migration. New behavior MUST be covered by new tests.
- **NFR-004**: The Lean specification MUST be updated alongside the Aiken implementation per the project constitution (Principle II).

### Key Entities

- **Cage instance**: a script artifact produced by applying `seed: OutputReference` to the unparameterized blueprint. Each instance has a unique `(scriptHash, policyId, address, cageToken)` quadruple.
- **`cageToken`**: `TokenId { assetName: assetName(seed) }`. Derived purely from the parameter; canonical for the instance.
- **State UTxO**: the unique UTxO per instance carrying `StateDatum` and `cageToken`. Created by mint or migration, updated by Modify, destroyed by End.
- **Legitimate request UTxO**: a UTxO at the cage address with `RequestDatum(req)` where `req.requestToken == cageToken`.
- **Garbage UTxO**: any UTxO at the cage address that is neither the legitimate state UTxO nor a legitimate request for this cage.

## Success Criteria *(mandatory)*

- **SC-001**: All existing Aiken tests pass after the rewrite (no regressions).
- **SC-002**: New tests cover Sweep happy paths, Sweep negative paths (non-owner, fake state, legitimate state, legitimate request), zero-request Modify, defense-in-depth token check on Modify and End, migration asset-name pin, and per-token isolation across two distinct seeds.
- **SC-003**: `lake build` (Lean) compiles after spec updates.
- **SC-004**: `aiken build` produces a blueprint reflecting the new parameter and redeemer shapes.
- **SC-005**: `just vectors-check` passes (or vectors are regenerated to match).
- **SC-006**: A worked example transaction (mint, request, modify+sweep, retract, end) is documented in `quickstart.md` for off-chain implementors.

## Rejected approaches

### Per-oracle parameterization (`oracle_vkh: VerificationKeyHash`)

Originally proposed in [#24](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/24) (closed in favor of [#47](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/47)). Rejected because the cage's address would be publicly derivable from the oracle's verification key alone, before the cage exists. Concrete attack surfaces:

1. **Pre-pollution.** Anyone who has seen the oracle's VKH on any prior signature can compute the cage address and pre-deposit garbage there before the oracle ever mints.
2. **Pre-positioned `RequestDatum`s.** Adversaries submit well-formed request datums at the predictable address targeting tokens not yet minted.
3. **Phishing leverage.** Address derivation being fully public widens the surface for malicious-UI attacks where the attacker computes the victim's prospective address.
4. **Lifecycle coupling.** Cage identity is welded to one verification key. Key rotation requires migration. There is no separation between "who controls the cage" (`state.owner`, mutable) and "where the cage lives" (script hash, immutable per key).
5. **Cross-token bandwidth coupling.** All tokens this oracle owns share an address. Address-completeness payloads scale with the oracle's *total* request load, not with the queried token's load.

`seed: OutputReference` parameterization avoids all of these because the seed UTxO must be consumed at mint time; the address commitment is contemporaneous with the mint and not derivable from public information beforehand.

### `Sweep` coupled to concurrent `Modify`

Considered earlier in the design. Rejected because savings in `validateSweep` are cosmetic (~3 lines) while the constraint forces operational rigidity (no standalone sweeps, no emergency cleanup outside the Oracle's update cadence). Sweep stands on its own with direct owner-signature check via the state UTxO referenced through the redeemer.

### Sweep without `cageToken` check on `stateRef`

Considered. Rejected because an attacker could craft a fake state UTxO (foreign NFT or no NFT, fake `StateDatum` signed by an attacker key) and point Sweep at it via redeemer. The garbage predicate would correctly reject sweeping the legitimate state, but the *fake* state would authorize sweep operations under attacker control. The redeemer-claimed `stateRef` MUST be verified to carry `cageToken` under `policyId`.

## Assumptions

- The on-chain repo's existing fair-fee model and time-params-in-datum branches are merged before this work begins; this spec assumes both as the baseline.
- The Plutus blueprint output of `aiken build` is the canonical artifact off-chain consumers depend on; the off-chain ripple is tracked separately.
- Existing deployed cages (e.g. the preprod token under the current shared validator) are migrated under a separate operational plan, not in scope for this issue.
- The CSMT subtree-completeness primitive in the upstream MTS library exists and operates on script-hash-prefixed keys; verification that the primitive is in place is a prerequisite of the off-chain follow-up, not this on-chain change.

## Out of scope

- Off-chain server changes to surface `policyId`-keyed read endpoints.
- Off-chain tooling changes to apply the seed parameter to the blueprint at mint time.
- Migration of existing deployed cages.
- Lean theorem statements about completeness over an oracle's address (not directly relevant after per-token addressing).
- New on-chain features beyond Sweep, defense-in-depth, and zero-request Modify.
