# Implementation Plan: Fair Fee Model

**Branch**: `001-fair-fee-model` | **Date**: 2026-04-08 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-fair-fee-model/spec.md`

## Summary

Replace the fixed `max_fee` per-request charge with a fair model where requesters pay their proportional share of the actual Cardano transaction fee plus a declared oracle tip. Requires changes to both datum types (State and Request), the Modify and Reject validators, the formal Lean specification, and all related tests.

## Technical Context

**Language/Version**: Aiken (Plutus V3), Lean 4
**Primary Dependencies**: aiken-lang/merkle-patricia-forestry v2.0.0, aiken-lang/stdlib v2.2.0
**Storage**: N/A (on-chain validator)
**Testing**: `aiken check` (87 inline tests), `lake build` (Lean proofs)
**Target Platform**: Cardano mainnet/preprod
**Project Type**: On-chain smart contract (validator)
**Performance Goals**: Minimal script execution units (every byte costs ADA)
**Constraints**: Plutus V3 execution budget, datum size limits
**Scale/Scope**: 3 Aiken source files, 1 Lean spec file, ~60 affected tests

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Formal-First | PASS | Lean spec updated before Aiken code |
| II. Minimal On-Chain Logic | PASS | Uses existing `Transaction.fee` field — no new datum fields beyond renaming |
| III. Security by Construction | PASS | Conservation equation is a formal property to be proved in Lean |
| IV. Backward Compatibility | PASS | Datum change acknowledged; migration uses existing `Migrating` redeemer |

## Project Structure

### Documentation (this feature)

```text
specs/001-fair-fee-model/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
└── tasks.md             # Phase 2 output (from /speckit.tasks)
```

### Source Code (repository root)

```text
validators/
├── types.ak             # State.max_fee → State.tip, Request.fee → Request.tip
├── cage.ak              # mkUpdate, mkReject, validRootUpdate, validReject
├── cage.tests.ak        # All fee-related tests updated + new tx fee tests
├── cage.props.ak        # Unchanged (phase property tests)
└── lib.ak               # Unchanged

spec/
└── CageDatum.lean       # Formal spec: Transaction.fee, FeeEnforced, ValidReject

lean/MpfsCage/
├── Lib.lean             # Unchanged
└── Phases.lean          # Unchanged
```

**Structure Decision**: No new files needed. All changes are modifications to existing files in `validators/` and `spec/`.

## Complexity Tracking

No constitution violations — table not needed.
