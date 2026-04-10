# cardano-mpfs-onchain Constitution

## Core Principles

### I. Formal-First
Every validator change starts with Lean 4 formalization. The Lean spec is the source of truth — Aiken code implements what Lean proves. No validator change without updating the formal spec first.

### II. Minimal On-Chain Logic
Validators must be as simple as possible. Every byte costs ADA. Prefer checks that use data already available in the script context over adding new datum fields or redeemer parameters.

### III. Security by Construction
Safety properties (fee fairness, phase exclusivity, token confinement) must be formally stated as Lean propositions. The Aiken test suite mirrors these properties empirically.

### IV. Backward Compatibility
Datum changes require validator migration. The Migration redeemer exists for this purpose. Any change to State or Request datum structure is a breaking change that needs a new validator version.

## Technology Stack

- **On-chain**: Aiken (Plutus V3)
- **Formal spec**: Lean 4 with mathlib
- **MPF library**: aiken-lang/merkle-patricia-forestry
- **CI**: Nix + justfile

## Quality Gates

- Lean spec compiles with zero `sorry` in scope
- All Aiken tests pass (`aiken check`)
- Formal spec and Aiken code agree on all invariants
- No axioms beyond MPF library trust assumptions

## Governance

Constitution supersedes all other practices. Amendments require documentation and approval.

**Version**: 1.0.0 | **Ratified**: 2026-04-08
