# cardano-mpfs-onchain Constitution

## Core Principles

### I. Cross-Language Encoding Fidelity
Aiken types must match the Haskell cage types byte-for-byte. Constructor indices and field ordering are the contract. The cage test vectors are the executable specification — `just vectors-check` must pass.

### II. Formal Properties First
The Lean 4 specification captures safety invariants. Type changes that affect validator semantics must update the Lean spec before or alongside the Aiken implementation.

### III. Three-Phase Time Invariant
The request lifecycle (Phase 1: oracle processes, Phase 2: requester retracts, Phase 3: oracle rejects) is formally verified. Changes must preserve phase exclusivity and coverage.

### IV. Test Coverage
44 Aiken tests + fuzz property tests cover 242 checks. Type changes must update all affected tests. The E2E TypeScript codec must match on-chain encoding.

### V. Minimal Script Size
On-chain validators run in a constrained environment. Prefer fewer constructors and simpler branching. Every byte costs ADA.

## Quality Gates

- `just test` passes (all Aiken tests)
- `just vectors-check` passes (cage vectors up to date)
- `lake build` passes (Lean spec compiles)
- E2E codec matches on-chain types

## Governance

Constitution supersedes ad-hoc decisions. Amendments require documentation and approval.

**Version**: 1.0.0 | **Ratified**: 2026-04-13
