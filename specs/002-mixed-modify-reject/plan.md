# Implementation Plan: Mixed Update/Reject in Modify Redeemer (On-chain)

**Branch**: `002-mixed-modify-reject` | **Date**: 2026-04-13 | **Spec**: `specs/002-mixed-modify-reject/spec.md`

## Summary

Merge the separate `Modify(List<Proof>)` and `Reject` paths into a single `Modify(List<RequestAction>)` path. The per-input fold function dispatches on `RequestAction::Update` (proof verification) vs `RequestAction::Rejected` (rejectability check). This eliminates `validReject` and `mkReject` as standalone functions.

## Technical Context

**Language**: Aiken (Plutus V3 smart contracts)
**Primary Dependencies**: aiken/merkle_patricia_forestry, cardano-mpfs-cage (test vectors)
**Testing**: Aiken built-in tests + fuzz properties + Vitest E2E
**Target Platform**: Cardano L1 (Plutus V3)
**Project Type**: On-chain validator
**Constraints**: Script size budget, execution units budget

## Constitution Check

| Gate | Status | Notes |
|------|--------|-------|
| I. Cross-Language Encoding | PASS | Matches updated cage types (RequestAction Constr 0/1) |
| II. Formal Properties First | PASS | Lean spec updated |
| III. Three-Phase Invariant | PASS | Phase checks preserved per-action |
| IV. Test Coverage | PASS | All Reject tests migrated to Modify |
| V. Minimal Script Size | PASS | Merging reduces code (one fold instead of two) |

## Project Structure

### Source Code

```text
validators/
├── types.ak         # Add RequestAction, update UpdateRedeemer
├── cage.ak          # Merge mkUpdate+mkReject, remove validReject
├── cage.tests.ak    # Migrate Reject tests to Modify
├── cage.props.ak    # Unchanged (phase logic unaffected)
├── cage_vectors.ak  # Regenerated via just generate-vectors
├── lib.ak           # Unchanged
├── lib.tests.ak     # Unchanged
└── lib.props.ak     # Unchanged

e2e/src/
├── codec.ts         # Update RequestAction encoding
└── cage.ts          # Update builder if needed

lean/MpfsCage/
└── (no changes — spec lives in cardano-mpfs-cage)

spec/
└── CageDatum.lean   # Update SpendRedeemer, add RequestAction
```

## Key Design Decision

The current code has two separate fold functions:
- `mkUpdate`: consumes proofs, applies MPF operations, enforces Phase 1
- `mkReject`: no proofs, no MPF ops, enforces Phase 3 (rejectability)

The merged design uses a single fold function `mkAction` that takes `(MerklePatriciaForestry, List<RequestAction>, List<refunds>)` as accumulator. For each matching request:
- Pop the next `RequestAction` from the list
- If `Update(proof)`: apply MPF operation with proof, enforce Phase 1
- If `Rejected`: skip MPF, check rejectability, enforce Phase 3

`validRootUpdate` and `validReject` merge into a single `validModify` function. The root is computed by the fold — for `Rejected` entries the root passes through unchanged.
