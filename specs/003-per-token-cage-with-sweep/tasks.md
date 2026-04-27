---
description: "Task list for feature 003-per-token-cage-with-sweep"
---

# Tasks: Per-token cage validator with owner sweep

**Input**: Design documents from `specs/003-per-token-cage-with-sweep/`
**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md)
**Issue**: [#47](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/47)

## Phase 1: Setup and Speckit

- [X] T001 Create branch `feat/47-per-token-cage-with-sweep` in a sibling worktree of `cardano-mpfs-onchain`.
- [X] T002 Author `specs/003-per-token-cage-with-sweep/spec.md`.
- [X] T003 Author `specs/003-per-token-cage-with-sweep/plan.md`.
- [X] T004 Author `specs/003-per-token-cage-with-sweep/tasks.md` (this file).
- [ ] T005 Commit and push speckit artifacts; open draft PR linked to #47.

## Phase 2: Types

- [ ] T006 Update `validators/types.ak`: collapse `MintRedeemer.Minting(Mint)` to `MintRedeemer.Minting` (unit). Delete the `Mint` redeemer-payload type and its uses.
- [ ] T007 Update `validators/types.ak`: add `UpdateRedeemer.Sweep(OutputReference)`.

## Phase 3: Validator

- [ ] T008 Change `validator mpfCage(_version: Int)` to `validator mpfCage(seed: OutputReference)` in `validators/cage.ak`.
- [ ] T009 Update `validateMint` in `validators/cage.ak` to derive `tokenId = TokenId { assetName: assetName(seed) }` from the parameter and require the seed UTxO be in `tx.inputs`.
- [ ] T010 Update `validateMigration` in `validators/cage.ak` to add `expect tokenId.assetName == assetName(seed)`.
- [ ] T011 Update the Modify/End branch in `spend` to add `expect extractedToken == cageToken` defense-in-depth check.
- [ ] T012 Add the zero-request short-circuit branch to `validModify` (`n == 0` returns `True` after preserving root, address, and time params).
- [ ] T013 Add `validateSweep` to `validators/cage.ak` per the design in `plan.md` (Phase 1 design section).
- [ ] T014 Wire `Sweep(stateRef) -> validateSweep(...)` into the spend dispatch.

## Phase 4: Tests and Properties

- [ ] T015 Update `validators/cage.tests.ak` for the new `Minting` (unit) shape on every existing mint test.
- [ ] T016 Update `validators/cage.tests.ak` for the migration asset-name pin: positive case + negative case (`tokenId.assetName != assetName(seed)`).
- [ ] T017 Add new `validators/cage.tests.ak` cases for zero-request Modify: positive (root unchanged, no refunds, accepts), negative (root mutated, rejects).
- [ ] T018 Add new `validators/cage.tests.ak` cases for Sweep happy paths: no-datum garbage, wrong-token RequestDatum, foreign-NFT StateDatum.
- [ ] T019 Add new `validators/cage.tests.ak` cases for Sweep negative paths: non-owner rejected, fake stateRef rejected, legitimate state not sweepable, legitimate request not sweepable.
- [ ] T020 Add new `validators/cage.tests.ak` case for two-instance per-token isolation: two distinct seeds → two distinct script hashes.
- [ ] T021 Update `validators/cage.props.ak` for the new redeemer shape; add fuzz property for Sweep authorization (cage owner is the only key that can sweep).
- [ ] T022 Run `just test` and confirm all Aiken tests pass.

## Phase 5: Vectors

- [ ] T023 Adapt the upstream Haskell cage test-vector generator for the new `MintRedeemer.Minting` (unit) and `UpdateRedeemer.Sweep` shapes. (Coordinate with the upstream cage repo if it lives separately.)
- [ ] T024 Run `just generate-vectors` (or equivalent) to refresh `validators/cage_vectors.ak`.
- [ ] T025 Run `just vectors-check` and confirm parity.

## Phase 6: Lean spec

- [ ] T026 Update the Lean specification under `lean/` to reflect the new `MintRedeemer` and `UpdateRedeemer` shapes.
- [ ] T027 Add a Lean predicate / theorem capturing per-instance token isolation (the cage's `cageToken` is determined by the seed parameter; legitimate state and legitimate request UTxOs are characterized by carrying / referencing it).
- [ ] T028 Add a Lean transition / theorem capturing Sweep semantics (owner-signed; state UTxO referenced; garbage predicate at the spent UTxO).
- [ ] T029 Run `lake build` and confirm the Lean spec compiles.

## Phase 7: Blueprint and Build

- [ ] T030 Run `aiken build` and inspect `plutus.json`. Confirm the validator parameter is `seed: OutputReference` and the spend redeemer enumerates `End | Contribute | Modify | Retract | Sweep` with the documented payloads.
- [ ] T031 Confirm validator script size is within budget (compare to baseline; flag if regressed).

## Phase 8: Quickstart

- [ ] T032 Author `specs/003-per-token-cage-with-sweep/quickstart.md` documenting a worked example tx flow: parameterize the blueprint with a seed, mint, submit a request, owner runs Modify+Sweep, requester retracts, owner ends the cage.

## Phase 9: Validation and Merge

- [ ] T033 Run `just test` (all Aiken tests pass).
- [ ] T034 Run `just vectors-check` (vectors up-to-date).
- [ ] T035 Run `lake build` (Lean compiles).
- [ ] T036 Run any local CI gate (e.g. `just ci` if it exists in this repo).
- [ ] T037 Push branch to `origin` and open the PR (or unmark draft); update PR body to reflect the merged design and validation status.
- [ ] T038 Wait for green CI; merge through merge-guard once an off-chain ripple plan is in place under a follow-up issue.

## Phase 10: Off-chain ripple (separate issues / PRs)

- [ ] T039 File a follow-up issue against `cardano-foundation/cardano-mpfs-offchain` (or `lambdasistemi/cardano-mpfs-offchain` per server-deployment ownership) covering: blueprint-applied parameterization in `/tx/boot`; per-policy-id read endpoints; transaction-builder updates; server-side discovery of new cages.
- [ ] T040 Update `lambdasistemi/cardano-mpfs-offchain#231` (paused) to depend on the on-chain change merging here. Refresh the verifier-side design accordingly (per-token addressing changes the URL shape and the proof bundle shape).
