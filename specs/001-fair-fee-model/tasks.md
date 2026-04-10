# Tasks: Fair Fee Model

**Input**: Design documents from `/specs/001-fair-fee-model/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to

---

## Phase 1: Foundational (Lean Formal Spec)

**Purpose**: Update the formal specification before any Aiken changes (Formal-First principle)

- [x] T001 [P] Update State and Request types in spec/CageDatum.lean: rename `maxFee` → `tip`, `fee` → `tip`
- [x] T002 [P] Add `fee : Nat` field to Transaction type in spec/CageDatum.lean
- [x] T003 Rewrite `FeeEnforced` structure in spec/CageDatum.lean: conservation equation over list of requests and refund outputs
- [x] T004 Update `ValidReject.feeMatch` and `ValidReject.refunds` in spec/CageDatum.lean to use `tip` and conservation equation
- [x] T005 Run `lake build` to verify spec compiles

**Checkpoint**: Lean spec compiles with updated fee model

---

## Phase 2: User Story 1 - Fair cost sharing on batch updates (Priority: P1)

**Goal**: Modify validator uses conservation equation with `tx.fee` instead of fixed `max_fee`

**Independent Test**: Construct Modify transactions with known tx fee and verify refund amounts

### Implementation for User Story 1

- [x] T006 [P] [US1] Rename `max_fee` → `tip` in State type in validators/types.ak
- [x] T007 [P] [US1] Rename `fee` → `tip` in Request type in validators/types.ak
- [x] T008 [US1] Rewrite `mkUpdate` in validators/cage.ak: check `tip == state_tip`, accumulate `(owner, inputLovelace)` pairs and running total instead of computing per-request refund
- [x] T009 [US1] Replace `verifyRefunds` with `sumRefunds` in validators/cage.ak: return total refunded lovelace instead of checking per-request amounts
- [x] T010 [US1] Rewrite `validRootUpdate` in validators/cage.ak: destructure `tx.fee`, compute `N = list.length(owners)`, check conservation `totalRefunded == totalInputLovelace - tx_fee - n * tip`
- [x] T011 [US1] Update all Modify-related test constants in validators/cage.tests.ak: rename `max_fee` → `tip`, `fee` → `tip`, `testFee` → `testTip`
- [x] T012 [US1] Update refund test expectations in validators/cage.tests.ak to account for `tx.fee` in conservation equation
- [x] T013 [US1] Add new test in validators/cage.tests.ak: Modify with nonzero `tx.fee` verifying conservation equation
- [x] T014 [US1] Add new test in validators/cage.tests.ak: batch Modify with two requests verifying total refund splits correctly
- [x] T015 [US1] Run `aiken check` to verify all Modify tests pass

**Checkpoint**: Modify path works with fair fee model, all tests green

---

## Phase 3: User Story 2 - Requester agrees to oracle terms (Priority: P1)

**Goal**: Tip mismatch between request and state is rejected

**Independent Test**: Construct Modify with mismatched tip values and verify rejection

### Implementation for User Story 2

- [x] T016 [US2] Update tip mismatch test in validators/cage.tests.ak to use renamed fields
- [x] T017 [US2] Run `aiken check` to verify mismatch test still fails as expected

**Checkpoint**: Tip agreement enforcement verified

---

## Phase 4: User Story 3 - Fair cost sharing on reject (Priority: P2)

**Goal**: Reject validator uses same conservation equation as Modify

**Independent Test**: Construct Reject transaction in Phase 3 and verify refund amounts

### Implementation for User Story 3

- [x] T018 [US3] Rewrite `mkReject` in validators/cage.ak: same pattern as `mkUpdate` — accumulate `(owner, inputLovelace)` pairs, check `tip == state_tip`
- [x] T019 [US3] Rewrite `validReject` in validators/cage.ak: destructure `tx.fee`, check conservation equation
- [x] T020 [US3] Update all Reject-related test constants in validators/cage.tests.ak: rename fields, adjust refund expectations
- [x] T021 [US3] Add new test in validators/cage.tests.ak: Reject with nonzero `tx.fee`
- [x] T022 [US3] Run `aiken check` to verify all Reject tests pass

**Checkpoint**: Reject path works with fair fee model, all tests green

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Update remaining references and run full suite

- [x] T023 Update all remaining `max_fee`/`fee` references in Minting-related test constants in validators/cage.tests.ak
- [x] T024 Update doc comments in validators/cage.ak and validators/types.ak to reflect new fee model
- [x] T025 Run full `aiken check` — all 91 tests pass
- [x] T026 Run `lake build` — Lean spec compiles

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Lean spec)**: No dependencies — start here (Formal-First)
- **Phase 2 (US1 Modify)**: Depends on Phase 1 (spec defines the conservation equation)
- **Phase 3 (US2 Tip agreement)**: Depends on Phase 2 (needs renamed fields)
- **Phase 4 (US3 Reject)**: Depends on Phase 2 (shares `sumRefunds` helper)
- **Phase 5 (Polish)**: Depends on Phases 2–4

### Parallel Opportunities

- T001 and T002 can run in parallel (different sections of CageDatum.lean)
- T006 and T007 can run in parallel (different type definitions in types.ak)
- Phase 3 and Phase 4 can run in parallel after Phase 2 completes

---

## Implementation Strategy

### MVP First (Phase 1 + Phase 2)

1. Complete Phase 1: Lean spec
2. Complete Phase 2: Modify path with conservation equation
3. **STOP and VALIDATE**: `aiken check` passes for Modify
4. Continue to Phase 3 + 4 for Reject and tip agreement

### Incremental Delivery

1. Lean spec → validates the design formally
2. Modify path → core value (fair fees on updates)
3. Reject path → consistency (same model for rejects)
4. Polish → clean up docs and remaining references

---

## Notes

- The zero-lovelace edge case (test artifact): skip adding to owners list when `inputLovelace == 0`
- `transaction.placeholder` has `fee: 0`, so existing tests with `fee: 0` tip will pass conservation trivially
- New tests must set nonzero `fee` on the Transaction to exercise the conservation equation properly
