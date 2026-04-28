# Cardano MPFS Onchain

Aiken validators and Haskell off-chain library for
[Merkle Patricia Forestry](https://github.com/aiken-lang/merkle-patricia-forestry)
on Cardano (Plutus V3).

The on-chain component defines a **cage** pattern: a state NFT carries the
current MPF root hash as its datum. A global state validator anchors token
discovery, while per-cage request validators handle contributions,
retractions, and cleanup. Modifications are verified on-chain via
cryptographic proofs. Time-gated phases prevent race conditions between the
oracle and requesters.

## Repository structure

| Directory | Language | Contents |
|-----------|----------|----------|
| `validators/` | Aiken | State and request validators |
| `lean/` | Lean 4 | Formal proofs of phase, token, and split-validator invariants |
| `haskell/` | Haskell | Off-chain types, tx builders, test vectors, E2E tests |

## Documentation

- [Development](development.md) — building, dev shell, nix checks, justfile recipes
- [Architecture Overview](architecture/overview.md) — system diagram, transaction lifecycle, protocol flow
- [Validators](architecture/validators.md) — minting policy and spending validator logic
- [Types & Encodings](architecture/types.md) — datum, redeemer, and operation structures
- [Proof System](architecture/proofs.md) — MPF proof format, verification, and performance
- [Security Properties](architecture/properties.md) — on-chain invariants and proof links
- [Haskell Cage Library](haskell-cage.md) — off-chain types, tx builders, test vectors
