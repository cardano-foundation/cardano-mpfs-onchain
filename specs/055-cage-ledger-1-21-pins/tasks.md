# Tasks: Support Moog GHC 9.12.3 / cardano-node 10.7.0 pins

**Branch**: `fix/55-cage-ledger-1-21-pins` | **Plan**: [plan.md](./plan.md)

## Slice 1 — Bump pins, drop `KeyHash '<Role>` ticks, absorb cascade

One bisect-safe commit covering the flake+cabal bump, the unticked spelling, and any cascade fix the bump surfaces. Commit subject: `fix(haskell): drop KeyRole ticks and bump to cardano-node 10.7.0 (#55)`. Body trailer: `Tasks: T055-S1`.

- [X] T055-S1 — Bump `flake.nix` `cardano-node` input to `github:IntersectMBO/cardano-node/10.7.0`. Refresh only that input in `flake.lock` (`nix flake lock --update-input cardano-node`).
- [X] T055-S1 — Bump `haskell/cabal.project` Hackage `index-state` to `2026-02-17T10:15:41Z`. Bump CHaP to the `repo` branch + `index-state: 2026-05-22T05:43:37Z`. Remove the `constraints: ouroboros-consensus <0.28` line.
- [X] T055-S1 — `haskell/lib/Cardano/MPFS/Cage/Ledger.hs`: drop the tick at L103, L118 (`KeyHash 'Payment` → `KeyHash Payment`).
- [X] T055-S1 — `haskell/lib/Cardano/MPFS/Cage/TxBuilder/Internal.hs`: drop the tick at L480, L485 (`KeyHash 'Witness`, `KeyHash 'Payment` → unticked).
- [X] T055-S1 — `haskell/lib/Cardano/MPFS/Cage/TxBuilder/Reject.hs`: drop the tick at L211, L309 (`KeyHash 'Witness` → unticked).
- [X] T055-S1 — `haskell/lib/Cardano/MPFS/Cage/TxBuilder/Update.hs`: drop the tick at L223, L329 (`KeyHash 'Witness` → unticked).
- [X] T055-S1 — Run `./gate.sh`. Absorb any cascade build error from the ledger/consensus bump in the same commit (Conway/Babbage type renames, network protocol renames, etc.). Update plan.md in-flight if the touched-file set widens.
- [X] T055-S1 — `vectors-freshness` check stays green (no Aiken/vectors edits).
- [X] T055-S1 — Single commit with `Tasks: T055-S1` trailer; do not push (orchestrator amends `tasks.md` and pushes).

## Finalization

- [ ] T055-FIN — Orchestrator: amend slice commit with `tasks.md` checks, `git push --force-with-lease`.
- [ ] T055-FIN — Orchestrator: PR body audit against delivered diff; update if cascade widened the scope.
- [ ] T055-FIN — Orchestrator: `chore: drop gate.sh (ready for review)`, push, `gh pr ready 56`.
- [ ] T055-FIN — Orchestrator: post-merge cleanup (worktree + branch removal).
