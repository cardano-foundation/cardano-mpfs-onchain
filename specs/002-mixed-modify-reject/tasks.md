# Tasks: Mixed Update/Reject On-chain

**Input**: Design documents from `/specs/002-mixed-modify-reject/`

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Lean Specification

**Purpose**: Formal properties updated before code.

- [ ] T001 [US4] Add `RequestAction` inductive to `spec/CageDatum.lean`
- [ ] T002 [US4] Remove `Reject` from `SpendRedeemer`, update `Modify` to carry `List RequestAction` in `spec/CageDatum.lean`
- [ ] T003 [US4] Update any predicates referencing old `Reject` variant in `spec/CageDatum.lean`

**Checkpoint**: `lake build` passes

---

## Phase 2: Aiken Types

**Purpose**: Update type definitions — all validator changes depend on this.

- [ ] T004 [US1] Add `RequestAction` type with `Update(Proof)` and `Rejected` variants in `validators/types.ak`
- [ ] T005 [US2] Update `Modify` to carry `List<RequestAction>` instead of `List<Proof>` in `validators/types.ak`
- [ ] T006 [US2] Remove `Reject` variant from `UpdateRedeemer` in `validators/types.ak`
- [ ] T007 [US2] Update type documentation and test hints in `validators/types.ak`

---

## Phase 3: Validator Logic

**Purpose**: Merge fold functions and update dispatch.

- [ ] T008 [US1] Create `mkAction` fold function (dispatches on `RequestAction`, replaces `mkUpdate` + `mkReject`) in `validators/cage.ak`
- [ ] T009 [US1] Create `validModify` function (replaces `validRootUpdate` + `validReject`) in `validators/cage.ak`
- [ ] T010 [US2] Update redeemer dispatch: `Modify(actions) -> validModify(...)`, remove `Reject -> validReject(...)` in `validators/cage.ak`
- [ ] T011 [US2] Remove `mkReject` and `validReject` functions from `validators/cage.ak`
- [ ] T012 [US1] Update `mkUpdate` → delete (logic absorbed into `mkAction`) in `validators/cage.ak`

**Checkpoint**: `aiken build` succeeds

---

## Phase 4: Tests

**Purpose**: Migrate Reject tests, add mixed action tests.

- [ ] T013 [US1] Add test: Modify with mixed `[Update(proof), Rejected]` actions in `validators/cage.tests.ak`
- [ ] T014 [US1] Add test: Modify with all-`Rejected` actions (root unchanged) in `validators/cage.tests.ak`
- [ ] T015 [US2] Migrate all existing Reject tests to `Modify([Rejected, ...])` in `validators/cage.tests.ak`
- [ ] T016 [US1] Add test: `Rejected` action on non-rejectable request (Phase 1) fails in `validators/cage.tests.ak`
- [ ] T017 [US2] Add test: old Constr 4 redeemer fails in `validators/cage.tests.ak`
- [ ] T018 [US1] Update import list (remove `Reject`, add `RequestAction`) across test files

**Checkpoint**: `just test` passes

---

## Phase 5: Test Vectors

**Purpose**: Regenerate cage vectors from updated upstream.

- [ ] T019 [US1] Run `just generate-vectors` to regenerate `validators/cage_vectors.ak`
- [ ] T020 [US1] Verify `just vectors-check` passes

**Checkpoint**: Vectors up to date

---

## Phase 6: E2E Codec

**Purpose**: Update TypeScript encoding.

- [ ] T021 [P] [US3] Update `RequestAction` encoding in `e2e/src/codec.ts`
- [ ] T022 [US3] Remove Reject constructor encoding from `e2e/src/codec.ts`
- [ ] T023 [US3] Update cage builder if it references Reject in `e2e/src/cage.ts`

**Checkpoint**: E2E tests pass (if infrastructure available)

---

## Phase 7: Polish

- [ ] T024 Run `just test` + `just vectors-check` for final validation
- [ ] T025 Update validator documentation comments in `validators/cage.ak`

---

## Dependencies & Execution Order

- **Phase 1** (Lean): Independent — start here
- **Phase 2** (types): Independent of Phase 1
- **Phase 3** (validator): Depends on Phase 2
- **Phase 4** (tests): Depends on Phase 3
- **Phase 5** (vectors): Depends on Phase 2 (types must match cage)
- **Phase 6** (E2E): Depends on Phase 3
- **Phase 7** (polish): Depends on all

Phases 1 and 2 can run in parallel. Phases 5 and 6 can run in parallel after Phase 3.

---

## Notes

- `RequestAction::Update` wraps a single `Proof`, not `List<Proof>` — one action per request
- The fold accumulator changes from `(MPF, List<Proof>, refunds)` to `(MPF, List<RequestAction>, refunds)`
- `mkAction` pops one `RequestAction` per matching request (same pattern as `mkUpdate` popping one `Proof`)
