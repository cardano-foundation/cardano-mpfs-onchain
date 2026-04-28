# Implementation Plan: Split state and request validators

**Branch**: `feat/feat-split-into-shared-state-and-per-token-request` | **Date**: 2026-04-28 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/004-split-state-and-request-validators/spec.md`

## Status

**Completed**: Speckit artifacts, split Aiken state/request validators, regression tests, Lean split-validator model, architecture docs, Haskell redeemer encodings, vector regeneration, and off-chain state/request script routing.
**Current**: PR handoff.
**Blockers**: Local devnet E2E was not run in this pass; CI still covers it with `nix run .#cage-tests-e2e`.

## Summary

Split the current combined per-token cage validator into a globally discoverable state validator and a per-token request validator. The state policy id becomes the global discovery anchor. Request addresses remain per cage by applying the request blueprint to `(statePolicyId, cageToken)`. The implementation also closes three reviewed gaps: reject extra state-policy assets, authenticate state references by policy and asset, and allow cleanup of malformed request-address spam.

## Technical Context

**Language/Version**: Aiken v1.1.16, Plutus V3; Haskell for vector and helper types; Lean 4 for formal phase specs.
**Primary Dependencies**: `aiken-lang/stdlib`, `aiken-lang/merkle-patricia-forestry`, existing Haskell Cardano ledger libraries.
**Storage**: On-chain UTxO datums and values.
**Testing**: `aiken check`, `aiken build`, `just vectors-check`, `lake build`.
**Target Platform**: Cardano Plutus V3.
**Project Type**: On-chain validator package with supporting Haskell and Lean artifacts.
**Performance Goals**: Request `Sweep` uses redeemer-pointed state lookup; state `Modify` keeps existing linear scan over transaction inputs.
**Constraints**: Aiken/Haskell encodings must match byte-for-byte; script count should be exactly two for this feature.
**Scale/Scope**: One global state policy and one request validator blueprint per version; one applied request script per cage.

## Constitution Check

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Cross-Language Encoding Fidelity | Guarded | Mint redeemer encoding changes; Haskell vector types must update. |
| II. Formal Properties First | Guarded | Existing phase proofs should still compile; split-specific Lean can be minimal if behavior is covered in Aiken tests. |
| III. Three-Phase Time Invariant | Pass | Phase predicates are reused unchanged. |
| IV. Test Coverage | Pass | New tests cover the split and review gaps. |
| V. Minimal Script Size | Guarded | Split duplicates some helper logic but removes per-token state parameterization. |

## Project Structure

### Documentation

```text
specs/004-split-state-and-request-validators/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md
```

### Source Code

```text
validators/
├── state.ak
├── request.ak
├── types.ak
├── lib.ak
├── cage.tests.ak
├── cage.props.ak
└── cage_vectors.ak

haskell/lib/Cardano/MPFS/Cage/
├── Types.hs
├── Blueprint.hs
└── TxBuilder/
```

**Structure Decision**: Keep shared datums and helper types in `validators/types.ak` and `validators/lib.ak`; replace the old combined validator entry with `state` and `request` validator entries.

## Phase 0: Research

See [research.md](./research.md).

## Phase 1: Design

- `validator state` is unparameterized. Its mint policy handles `Minting(seed)`, `Migrating(Migration)`, and `Burning(TokenId)`.
- `validator state.spend` accepts only `StateDatum` with `Modify(actions)` and `End`; state address has no `Sweep`.
- `validator request(statePolicyId: PolicyId, cageTokenName: AssetName)` handles `Contribute`, `Retract`, and `Sweep`.
- `Contribute` requires the referenced state UTxO in `tx.inputs` and spent with state `Modify`.
- `Retract` and `Sweep` may use `tx.reference_inputs`.
- State `Modify` continues folding any input with a matching-token `RequestDatum`, regardless of address.
- Request `Sweep` treats a request as protected only when it is processable for the current state tip.

## Validation

- Run `aiken fmt`.
- Run `aiken check` (112 passing tests).
- Run `aiken build`.
- Run `nix develop .#aiken --quiet --command just vectors-check`.
- Run `lake build` in `lean/`.
- Run `nix develop github:paolino/dev-assets?dir=mkdocs --quiet --command mkdocs build --strict`.
- Run `nix run --quiet .#lint`.
- Run `nix build --quiet .#checks.x86_64-linux.library .#checks.x86_64-linux.cage-tests .#checks.x86_64-linux.cage-test-vectors .#checks.x86_64-linux.lint .#checks.x86_64-linux.vectors-freshness`.
- Run `nix build --quiet`.
