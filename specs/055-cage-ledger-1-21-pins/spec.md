# Feature Specification: Support Moog GHC 9.12.3 / cardano-node 10.7.0 pins

**Feature Branch**: `fix/55-cage-ledger-1-21-pins`
**Created**: 2026-05-25
**Status**: Draft
**Input**: Issue [#55](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/55)

## User Scenarios & Testing

### User Story 1 - Moog can pin cardano-mpfs-onchain at the new pins (Priority: P1)

As a Moog maintainer, I pin `cardano-mpfs-onchain` as a `source-repository-package` while aligning Moog with GHC 9.12.3 and `cardano-node` 10.7.0, and `cardano-mpfs-cage` builds under the same ledger/network dependency set as the rest of the Moog build.

**Why this priority**: Moog's GHC 9.12.3 / `cardano-node` 10.7.0 bump is blocked on `cardano-mpfs-cage` failing to build. Without this fix Moog cannot move forward at all.

**Independent Test**: Add `cardano-mpfs-onchain` as a `source-repository-package` in a downstream cabal project that already pins the constraints listed in issue #55, and `cabal build cardano-mpfs-cage` succeeds.

**Acceptance Scenarios**:

1. **Given** Moog's `cabal.project` constraints from issue #55 (`cardano-ledger-conway ==1.21.0.0`, `cardano-ledger-core ==1.19.0.0`, `ouroboros-consensus ==1.0.0.0`, etc.) and GHC 9.12.3, **When** the downstream build reaches `cardano-mpfs-cage` pinned to the merged HEAD of this PR, **Then** the library compiles cleanly.
2. **Given** the merged HEAD, **When** Moog updates only the `tag` and `--sha256` of its `source-repository-package cardano-mpfs-onchain` entry, **Then** no other Moog-side change is required.
3. **Given** the merged HEAD, **When** this repository's own CI builds the haskell library check under its bumped `flake.nix`, **Then** the build is green.

### User Story 2 - This repository's CI proves the build under the target pins (Priority: P1)

This repository's own `flake.nix` / `cabal.project` advance to the same GHC + ledger pins, so CI is the live proof that the source code compiles under the target set.

**Why this priority**: Source-repository-package consumers cannot tell whether this repo's source is compatible with their pins unless this repo's own CI exercises those pins. A green CI here is the receipt.

**Acceptance Scenarios**:

1. **Given** the bumped `flake.nix`, **When** `nix build .#checks.x86_64-linux.library` runs in CI, **Then** the build is green.
2. **Given** the bumped `flake.nix`, **When** `nix build .#checks.x86_64-linux.cage-tests` runs, **Then** all cage unit/property tests pass.
3. **Given** the bumped flake inputs, **When** `nix build .#checks.x86_64-linux.aiken-check` and `.aiken-build` run, **Then** the on-chain Aiken build is unaffected (vectors freshness still holds).

---

## Requirements

### Functional Requirements

- **FR-001**: `haskell/lib/Cardano/MPFS/Cage/Ledger.hs` MUST compile under `cardano-ledger-core 1.19.0.0`, in which `KeyRole` is declared with `type data` and tick-promoted constructors are not in scope.
- **FR-002**: Every site in `haskell/` that writes `KeyHash '<Role>` MUST be updated to the post-`type data` spelling. Inventory at branch base:
  - `haskell/lib/Cardano/MPFS/Cage/Ledger.hs:103,118` (`'Payment`)
  - `haskell/lib/Cardano/MPFS/Cage/TxBuilder/Internal.hs:480,485` (`'Witness`, `'Payment`)
  - `haskell/lib/Cardano/MPFS/Cage/TxBuilder/Reject.hs:211,309` (`'Witness`)
  - `haskell/lib/Cardano/MPFS/Cage/TxBuilder/Update.hs:223,329` (`'Witness`)
- **FR-003**: `flake.nix` MUST consume `cardano-node` at the version that ships GHC 9.12.3 + the target ledger set (currently `github:IntersectMBO/cardano-node/10.7.0`).
- **FR-004**: `haskell/cabal.project` MUST consume CHaP with the same repo branch and index-state Moog uses (`repo` branch, index-state `2026-05-22T05:43:37Z`); Hackage index-state MUST move to `2026-02-17T10:15:41Z`; the `ouroboros-consensus <0.28` cap MUST be dropped.
- **FR-005**: Any further cascade build error introduced by the ledger/consensus bump (Conway era API drift, network type renames, etc.) MUST also be fixed in the same change — partial fixes leave the build red at HEAD and break bisect-safety.
- **FR-006**: PR body MUST document the downstream update Moog performs: bump only `tag` + `--sha256` of the `cardano-mpfs-onchain` `source-repository-package` entry.

### Non-Functional Requirements

- **NFR-001**: The change MUST land in a single bisect-safe commit (or a small sequence of bisect-safe commits) — every commit on the branch builds and tests at HEAD.
- **NFR-002**: Aiken validators MUST remain bit-identical (no `validators/*.ak` edits). `vectors-freshness` MUST stay green.

### Out of Scope

- Refactoring the `KeyHash` usage shape (e.g. introducing local `type KeyHashPayment = KeyHash Payment` aliases) — only the minimal change to compile.
- Bumping any other flake input not required to get GHC 9.12.3 / cardano-node 10.7.0.
- E2E test coverage changes; the existing `cage-tests-e2e` job continues to run.
- Updating Moog itself — that is the downstream-side change documented but not implemented here.

## Success Criteria

- `./gate.sh` is green at HEAD.
- This repository's CI is green on the PR.
- Moog's local build of `cardano-mpfs-cage`, pointed at this PR's merge commit via `source-repository-package`, compiles under the issue-#55 constraints with no further Moog-side patching.
- PR body links the merge SHA and downstream `--sha256` for Moog's bump.
