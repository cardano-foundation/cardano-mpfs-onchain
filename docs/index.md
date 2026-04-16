# Cardano MPFS Onchain

Aiken validators and Haskell off-chain library for
[Merkle Patricia Forestry](https://github.com/aiken-lang/merkle-patricia-forestry)
on Cardano (Plutus V3).

The on-chain component defines a **cage** pattern: an NFT locked at
a script address carries the current MPF root hash as its datum.
Modifications are verified on-chain via cryptographic proofs.
Time-gated phases prevent race conditions between the oracle and
requesters, and a Reject mechanism enables DDoS protection.

## Repository structure

| Directory | Language | Contents |
|-----------|----------|----------|
| `validators/` | Aiken | Cage minting policy + spending validator |
| `lean/` | Lean 4 | Formal proofs of phase exclusivity and token handling |
| `haskell/` | Haskell | Off-chain types, tx builders, test vectors, E2E tests |

## Documentation

- [Development](development.md) — building, dev shell, nix checks, justfile recipes
- [Architecture Overview](architecture/overview.md) — system diagram, transaction lifecycle, protocol flow
- [Validators](architecture/validators.md) — minting policy and spending validator logic
- [Types & Encodings](architecture/types.md) — datum, redeemer, and operation structures
- [Proof System](architecture/proofs.md) — MPF proof format, verification, and performance
- [Security Properties](architecture/properties.md) — 16 categories verified by 80 tests
- [Haskell Cage Library](haskell-cage.md) — off-chain types, tx builders, test vectors
