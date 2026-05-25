# Implementation Plan: Support Moog GHC 9.12.3 / cardano-node 10.7.0 pins

**Branch**: `fix/55-cage-ledger-1-21-pins` | **Date**: 2026-05-25 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/055-cage-ledger-1-21-pins/spec.md`

## Summary

`cardano-mpfs-cage` currently uses tick-promoted constructors `KeyHash '<Role>` from `Cardano.Ledger.Keys`. In `cardano-ledger-core 1.19.0.0` (the version Moog will pin), `KeyRole` is a `type data` declaration — its constructors live only at the type level, so the tick form fails with `Not in scope: data constructor 'Payment'`. Drop the tick at every site, advance this repo's `flake.nix` to `cardano-node 10.7.0`, align `haskell/cabal.project` with Moog's CHaP repo branch + index-states, and absorb whatever cascade build errors the bump surfaces.

## Technical Context

**Language/Version**: Haskell GHC 9.12.3 (target), GHC 9.10.x (current).
**Primary Dependencies (target)**:
- `cardano-node 10.7.0` (flake input)
- `cardano-ledger-conway 1.21.0.0`, `cardano-ledger-core 1.19.0.0`, `cardano-ledger-allegra 1.9.0.0`, `cardano-ledger-alonzo 1.15.0.0`, `cardano-ledger-api 1.13.0.0`, `cardano-ledger-babbage 1.13.0.0`, `cardano-ledger-byron 1.3.0.0`, `cardano-ledger-mary 1.10.0.0`, `cardano-ledger-shelley 1.18.0.0`
- `cardano-crypto-class 2.3.1.0`, `cardano-crypto-praos 2.2.2.0`, `cardano-protocol-tpraos 1.5.0.0`
- `ouroboros-consensus 1.0.0.0`, `ouroboros-network 1.1.0.0`, `typed-protocols 1.2.0.0`
- CHaP branch `repo` @ `8479db771a3186eb326e42d8480eddc20a208275`, index-state `2026-05-22T05:43:37Z`
- Hackage index-state `2026-02-17T10:15:41Z`
**Storage**: N/A.
**Testing**: `nix build .#checks.x86_64-linux.{library,cage-tests,cage-test-vectors,lint,vectors-freshness,aiken-check,aiken-build}`.
**Target Platform**: Linux x86_64 (CI + Moog).
**Project Type**: Haskell + Aiken on-chain package; this PR touches the Haskell side and `flake.nix` only.
**Constraints**: No Aiken validator edits; vectors must remain bit-identical.

## Constitution Check

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Cross-Language Encoding Fidelity | Pass | No on-chain encoding changes; `vectors-freshness` gate proves it. |
| II. Formal Properties First | Pass | No Lean model changes; semantics unchanged. |
| III. Three-Phase Time Invariant | Pass | No validator changes. |
| IV. Test Coverage | Pass | Existing cage-tests cover the touched modules; library check covers compile-time. |
| V. Minimal Script Size | Pass | No script changes. |

## Project Structure

### Documentation

```text
specs/055-cage-ledger-1-21-pins/
├── spec.md
├── plan.md
└── tasks.md
```

### Source Code (touched)

```text
flake.nix                                              # cardano-node input bump
haskell/cabal.project                                  # CHaP branch + index-state; drop consensus<0.28
haskell/lib/Cardano/MPFS/Cage/Ledger.hs                # drop 'Payment ticks
haskell/lib/Cardano/MPFS/Cage/TxBuilder/Internal.hs    # drop 'Witness / 'Payment ticks
haskell/lib/Cardano/MPFS/Cage/TxBuilder/Reject.hs      # drop 'Witness ticks
haskell/lib/Cardano/MPFS/Cage/TxBuilder/Update.hs      # drop 'Witness ticks
```

Any cascade fixes (Conway/Babbage/consensus API renames surfaced by the bump) MAY widen the touched set; the slice grows to include them — partial fixes are not bisect-safe.

## Phase 0: Research

Root cause confirmed by reading `cardano-ledger-core` at tag `cardano-ledger-core-1.19.0.0`:

```haskell
type data KeyRole
  = GenesisRole | GenesisDelegate | Payment | Staking | StakePool
  | BlockIssuer | Witness | DRepRole | HotCommitteeRole
  | ColdCommitteeRole | Guard
```

`type data` (GHC 9.6+) lifts the constructors to the type level only — no term-level data constructor exists, so `'Payment` (which is shorthand for "promote the data constructor `Payment`") cannot resolve. The unticked form `Payment` already lives at the type level under the same `Cardano.Ledger.Keys` re-export, so dropping the tick is the minimal fix.

## Phase 1: Design

### Slice 1 — Bump pins + drop ticks + cascade fixes (one bisect-safe commit)

1. **`flake.nix`** — change the `cardano-node` input URL to `github:IntersectMBO/cardano-node/10.7.0`. Run `nix flake update cardano-node` (or `nix flake lock --update-input cardano-node`) to refresh `flake.lock`. Do not refresh unrelated inputs in the same commit.
2. **`haskell/cabal.project`** — bump Hackage index-state to `2026-02-17T10:15:41Z`. Bump CHaP to the `repo` branch + index-state `2026-05-22T05:43:37Z` (replace the keyed CHaP repo with the branch-specific URL, mirroring what Moog uses). Remove the `constraints: ouroboros-consensus <0.28` line.
3. **`haskell/lib/Cardano/MPFS/Cage/Ledger.hs`** — change `KeyHash 'Payment` at L103, L118 to `KeyHash Payment`.
4. **`haskell/lib/Cardano/MPFS/Cage/TxBuilder/Internal.hs`** — change `KeyHash 'Witness` (L480) and `KeyHash 'Payment` (L485) to unticked forms.
5. **`haskell/lib/Cardano/MPFS/Cage/TxBuilder/Reject.hs`** — change `KeyHash 'Witness` at L211, L309 to unticked.
6. **`haskell/lib/Cardano/MPFS/Cage/TxBuilder/Update.hs`** — change `KeyHash 'Witness` at L223, L329 to unticked.
7. **Cascade fixes** — run `./gate.sh`. Any further build error introduced by the new ledger/consensus API is in scope and fixed in the same commit. Common surface areas to watch: Conway era era types, `cardano-ledger-api` deserialization helpers, `ouroboros-consensus` block + protocol type renames.

If no cascade fixes are needed, the slice is the seven steps above. If cascades widen the diff, plan.md is updated in-flight via an amendment commit before the slice is sealed.

### Why one slice and not two

The pin bump and the source fix are interdependent: the unticked spelling is the form the new ledger demands, and the bumped flake is required for this repo's CI to prove the fix. Splitting them creates a commit where the build is red at HEAD, which fails the bisect-safety invariant.

## Phase 2: Validation

Local (run by the driver before reporting):

- `./gate.sh` — all seven `nix build .#checks.*` invocations green.

CI (run by GitHub Actions):

- `build` job — same nix-built checks the gate uses.
- `tests` job — `nix run .#cage-tests`.
- `e2e` job — `nix run .#cage-tests-e2e`. Not in `gate.sh` (slow, needs runtime cardano-node); CI is the proof.

Downstream proof (operator follow-up, not part of the gate):

- In a scratch Moog branch with the issue-#55 constraints, point `cardano-mpfs-onchain` `source-repository-package` at the merged SHA + recomputed `--sha256` and confirm `cabal build cardano-mpfs-cage` succeeds.
