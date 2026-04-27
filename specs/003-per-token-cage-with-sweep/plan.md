# Implementation Plan: Per-token cage validator with owner sweep

**Branch**: `feat/47-per-token-cage-with-sweep` | **Date**: 2026-04-27 | **Spec**: [spec.md](./spec.md)
**Issue**: [#47](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/47)
**Supersedes**: [#24](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/24)

## Summary

Repurpose the unused `_version: Int` validator parameter as `seed: OutputReference`, derive the cage's `cageToken` from the parameter, drop the redundant `Mint.asset` redeemer field, add a `Sweep(OutputReference)` redeemer, special-case zero-request Modify, and add defense-in-depth token-equality checks on Modify and End. Update tests, properties, Lean spec, vectors, and the Plutus blueprint.

## Technical Context

**Language**: Aiken for validators, Lean 4 for formal spec, Haskell for cage test-vector generation, optionally TypeScript for E2E codec depending on what the recent test refactor PR (#43) did to the E2E layer.
**Primary dependencies**: `aiken-lang/stdlib` (already in use), `merkle_patricia_forestry` (already in use), no new external dependencies.
**Storage**: N/A — on-chain validator only.
**Testing**: Aiken unit tests in `validators/cage.tests.ak`, fuzz properties in `validators/cage.props.ak`, cage test vectors in `validators/cage_vectors.ak`, Lean theorems under `lean/`.
**Target platform**: Plutus V3 on Cardano.
**Project type**: On-chain Aiken validator with Lean spec and Haskell-driven test vector generation.
**Performance goals**: Per-input validation cost stays O(1) under direct redeemer-pointed lookups for Sweep; script size stays under existing budget.
**Constraints**: Aiken-compatible only (no host-language interop in the validator). Must preserve byte-for-byte encoding compatibility with the Haskell cage test-vector generator. Must keep the script size minimal (Constitution Principle V).
**Scope**: One Aiken file (`validators/cage.ak`), one type module (`validators/types.ak`), two test files, one Lean spec file, blueprint regen, vector regen.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Cross-Language Encoding Fidelity | GUARDED | The cage test vectors must be regenerated against the upstream Haskell cage source, which itself must adopt the new `Mint` shape (unit) and the new `UpdateRedeemer` (with `Sweep`). Vector regeneration is a step in the implementation. |
| II. Formal Properties First | PASS | Lean spec is updated before or alongside the Aiken implementation. Per-token isolation is captured as a Lean predicate; Sweep semantics are formalized as a transition rule. |
| III. Three-Phase Time Invariant | PASS | Sweep does not alter request-lifecycle phases. Zero-request Modify preserves all phase invariants by construction (no requests means no phase checks fire). |
| IV. Test Coverage | PASS | All existing tests will be updated for the new shapes; new tests cover Sweep happy paths, Sweep negative paths, zero-request Modify, defense-in-depth token check, migration asset-name pin, two-instance per-token isolation. |
| V. Minimal Script Size | GUARDED | The new `Sweep` branch and the defense-in-depth checks add bytes. The `Mint` redeemer simplification (drop `asset` field) and zero-request branch's short-circuit save bytes. Net delta TBD; budget check in CI. |

No justified violations. The two GUARDED items are operational, not architectural — they require attention in the implementation, not a constitutional amendment.

## Project Structure

### Documentation

```text
specs/003-per-token-cage-with-sweep/
├── spec.md       # this directory's spec
├── plan.md       # this file
├── tasks.md      # ordered task list
├── research.md   # references to prior thinking, rejected approaches summary
└── quickstart.md # worked example tx flow for off-chain implementors
```

### Source Code (Aiken)

```text
validators/
├── cage.ak             # main validator — parameter, mint, spend, helpers
├── types.ak            # MintRedeemer, UpdateRedeemer, CageDatum, etc.
├── lib.ak              # TokenId, assetName, helpers
├── cage.tests.ak       # unit tests
├── cage.props.ak       # fuzz properties
├── cage_vectors.ak     # Haskell-generated test vectors
└── lib.tests.ak        # helpers tests
```

### Lean spec

```text
lean/
├── lakefile.lean
├── lean-toolchain
└── Cage/
    ├── Datum.lean      # types and per-instance invariants
    └── ...             # transitions, theorems
```

(Exact Lean module layout TBD by what currently exists; this plan adapts to the existing structure.)

### Off-chain ripple (out of scope for this PR; tracked separately)

- `cardano-mpfs-offchain` server changes: per-policy-id read endpoints, blueprint-based parameterization in `/tx/boot`, transaction-builder updates.
- MOOG client-side ripple under issue [`lambdasistemi/cardano-mpfs-offchain#231`](https://github.com/lambdasistemi/cardano-mpfs-offchain/issues/231).

## Phase 0: Research

The session leading to this plan resolved several design forks; recording for the record:

- **Per-token vs. per-oracle parameterization.** Per-token chosen; see *Rejected approaches* in spec.md.
- **`Sweep` redeemer payload.** `Sweep(OutputReference)` chosen; the redeemer carries the state UTxO's reference for direct O(1) lookup. Per-input validation runs do not share computation, so payloading is the right ergonomic choice.
- **Sweep coupling to Modify.** Decoupled. Sweep stands alone with direct owner-signature check.
- **Zero-request Modify.** Accepted as a first-class case, with the conservation equation short-circuited when there are no request inputs.
- **Defense-in-depth token check.** Added to Modify and End. Closes a foreign-NFT-at-this-address concern that, while bounded by the cage NFT's uniqueness invariant, is now textually enforced per handler.
- **Sweep state UTxO lookup**. Redeemer-pointed; verified via `tokenFromValue(stateInput.value) == Some(cageToken)`.
- **Mint redeemer simplification.** `Mint.asset` field dropped; `Minting` is now a unit constructor since the seed comes from the parameter.

No further research deliverables needed for this on-chain change.

## Phase 1: Design

### Validator parameter and mint flow

```aiken
validator mpfCage(seed: OutputReference) {
  mint(redeemer: MintRedeemer, policyId: PolicyId, tx: Transaction) {
    when redeemer is {
      Minting -> validateMint(seed, policyId, tx)
      Migrating(migration) -> validateMigration(seed, migration, policyId, tx)
      Burning -> True
    }
  }
  spend(maybeDatum, redeemer, self, tx) { ... }
  else(_) { fail }
}

pub fn validateMint(seed: OutputReference, policyId: PolicyId, tx: Transaction) {
  let Transaction { outputs, mint, inputs, .. } = tx
  let tokenId = TokenId { assetName: assetName(seed) }
  expect is_some(find_input(inputs, seed))
  expect when quantity(policyId, mint, tokenId) is {
    Some(q) -> q == 1
    None -> False
  }
  expect Some(output) = head(outputs)
  expect address.Script(targetScriptHash) = output.address.payment_credential
  expect targetScriptHash == policyId
  expect InlineDatum(tokenState) = output.datum
  expect StateDatum(State { root: tokenRoot, .. }) = tokenState
  expect tokenRoot == root(empty)
  True
}
```

### Spend dispatch

```aiken
spend(maybeDatum, redeemer, self, tx) {
  expect Some(datum) = maybeDatum
  let cageToken = TokenId { assetName: assetName(seed) }
  when redeemer is {
    Retract(stateRef) -> { ... existing ... }
    Contribute(tokenRef) -> { ... existing ... }
    Sweep(stateRef) -> validateSweep(stateRef, datum, self, cageToken, policyId, tx)
    _ -> {
      // Modify / End
      expect StateDatum(state) = datum
      expect validateOwnership(state, tx)
      let (input, tokenId) = extractToken(self, tx)
      expect tokenId == cageToken                       -- defense-in-depth FR-009 / FR-010
      when redeemer is {
        Modify(actions) -> validModify(state, input, tokenId, tx, actions)
        End -> {
          expect address.Script(p) = input.output.address.payment_credential
          validateEnd(p, tokenId, tx)
        }
        _ -> fail
      }
    }
  }
}
```

Note: the `policyId` reference needs to be threaded into the `spend` closure; in Aiken this is conventionally derived from the script hash by querying the script context, or by parameterizing the validator's `spend` signature appropriately. Implementation detail in Phase 2.

### `validateSweep`

```aiken
fn validateSweep(stateRef, datum, self, cageToken, policyId, tx) {
  // 1. Direct lookup of the state UTxO.
  let Transaction { inputs, reference_inputs, extra_signatories, .. } = tx
  let stateInput = findInputOrRef(stateRef, inputs, reference_inputs)

  // 2. Verify the redeemer's claim: stateRef points at the legitimate cage state.
  expect Some(stateTokenId) = tokenFromValue(stateInput.output.value)
  expect stateTokenId == cageToken
  // (Optional: also assert the state input is at our script's address. Implicit
  //  if the cage NFT is unique under our policy id.)

  // 3. Owner signed.
  let State { owner, .. } = readState(stateInput)
  expect has(extra_signatories, owner)

  // 4. Garbage predicate at `self`.
  expect Some(spent) = find(inputs, fn(i) { i.output_reference == self })
  let spentValue = spent.output.value
  let isLegitState = when datum is {
    StateDatum(_) -> when tokenFromValue(spentValue) is {
      Some(t) -> t == cageToken
      None -> False
    }
    _ -> False
  }
  let isLegitRequest = when datum is {
    RequestDatum(req) -> req.requestToken == cageToken
    _ -> False
  }
  expect !(isLegitState || isLegitRequest)
  True
}
```

### `validModify` zero-request branch

```aiken
fn validModify(state, input, tokenId, tx, actions) {
  ... existing root-folding, address-preservation, time-params-immutability checks ...
  let n = list.length(owners)
  when n is {
    0 -> True   -- zero-request Modify; root-unchanged is enforced earlier
    _ -> {
      expect [_, ..refundOutputs] = outputs
      let orderedOwners = list.reverse(owners)
      let totalRefunded = sumRefunds(refundOutputs, orderedOwners)
      expect totalRefunded == totalInputLovelace - tx_fee - n * tip
      True
    }
  }
}
```

### `validateMigration` asset-name pin

```aiken
pub fn validateMigration(seed, migration, policyId, tx) {
  let Migration { oldPolicy, tokenId } = migration
  expect tokenId.assetName == assetName(seed)        -- FR-004
  let Transaction { outputs, mint, .. } = tx
  expect Some(q1) = quantity(oldPolicy, mint, tokenId)
  expect q1 == -1
  expect Some(q2) = quantity(policyId, mint, tokenId)
  expect q2 == 1
  ... existing output / datum checks ...
}
```

### Types

```aiken
pub type MintRedeemer {
  Minting                 -- now unit; drop the Mint payload
  Migrating(Migration)
  Burning
}

pub type UpdateRedeemer {
  End
  Contribute(OutputReference)
  Modify(List<RequestAction>)
  Retract(OutputReference)
  Sweep(OutputReference)  -- new; carries stateRef
}

-- Mint type can be deleted since its only use site is gone.
```

## Phase 2: Implementation

The work decomposes into ordered, testable steps. See [tasks.md](./tasks.md).

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Sweep redeemer carries `OutputReference` | O(1) lookup vs O(N) scan; per-input runs don't amortize | Scan-based — costs more bytes per Sweep validation, especially in busy ticks |
| Defense-in-depth `extractedToken == cageToken` checks | Auditing-friendly per-handler invariant; closes foreign-NFT path textually | Implicit reasoning across handlers — sound but harder to audit and to formalize in Lean |
| Zero-request Modify branch | Operationally required for empty-queue ticks; current validator unsatisfiable for `n == 0` | Forbid empty Modify — would force the Oracle to skip its cycle when the queue is empty, blocking sweep+state-touch idle ticks |

## Off-chain ripple (separate PRs)

This PR is on-chain only. The off-chain follow-ups, in order:

1. Adapt the upstream Haskell cage test-vector generator to emit vectors compatible with the new redeemer/parameter shapes. Confirm `just vectors-check` passes.
2. Update the `cardano-mpfs-offchain` server: `/tx/boot` applies seed-parameterization via the blueprint and returns `(scriptBody, policyId, address, tokenId, mintTx)`. Per-policy-id read endpoints. Tracked under a new off-chain issue once this PR is in review.
3. Update MOOG and the in-flight client work in `lambdasistemi/cardano-mpfs-offchain#231` to consume the new wire format and apply the per-cage parameterization client-side or server-side as appropriate.
