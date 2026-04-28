# Tasks: Split state and request validators

**Input**: Design documents from `specs/004-split-state-and-request-validators/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md
**Issue**: [#49](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/49)

## Phase 1: Speckit

- [X] T001 Create `specs/004-split-state-and-request-validators/spec.md`.
- [X] T002 Create `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, and `tasks.md`.

## Phase 2: Aiken Types and Helpers

- [X] T003 Update `validators/types.ak` so `MintRedeemer.Minting` carries `OutputReference` and `Burning` carries `TokenId`.
- [X] T004 Update `validators/lib.ak` with helper predicates for exact state-policy asset movement.

## Phase 3: Split Validators

- [X] T005 Add `validators/state.ak` with global mint and state spend handlers.
- [X] T006 Add `validators/request.ak` with `(statePolicyId, cageTokenName)` parameters and request spend handlers.
- [X] T007 Remove the old combined `mpfCage` validator entry from `validators/cage.ak`.

## Phase 4: Aiken Tests

- [X] T008 Update tests to call `state.state` and `request.request` validators.
- [X] T009 Add tests for extra state-policy mint, migration, and burn rejection.
- [X] T010 Add tests for fake state-policy references in request spends.
- [X] T011 Add tests for reference-only and state-End `Contribute` rejection.
- [X] T012 Add tests for sweeping malformed matching-token request spam and rejecting sweep of processable requests.

## Phase 5: Haskell and Vectors

- [X] T013 Update Haskell `MintRedeemer` encoding and generators.
- [X] T014 Update blueprint/script helpers to extract state and request validators.
- [X] T015 Regenerate or update `validators/cage_vectors.ak`.

## Phase 6: Formal Spec and Docs

- [X] T016 Run `lake build` and update Lean type references if split redeemers broke compilation.
- [X] T017 Update architecture docs that describe one combined cage validator.

## Phase 7: Validation and PR

- [X] T018 Run `aiken fmt`.
- [X] T019 Run `aiken check`.
- [X] T020 Run `aiken build` and confirm state/request validator handlers.
- [X] T021 Run `just vectors-check` where possible.
- [X] T022 Push branch and open/update PR.
