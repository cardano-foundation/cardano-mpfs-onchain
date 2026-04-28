# Cardano MPFS Onchain

Aiken validators and Haskell off-chain library for [Merkle Patricia Forestry](https://github.com/aiken-lang/merkle-patricia-forestry) on Cardano (Plutus V3).

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

The `haskell/` package (`cardano-mpfs-cage`) is the single source of truth for all Haskell cage code — PlutusData type encodings, transaction builders, MPF proof serialization, and cross-language test vectors.

## Documentation

Full documentation is available at **[cardano-foundation.github.io/cardano-mpfs-onchain](https://cardano-foundation.github.io/cardano-mpfs-onchain/)**.

- [Development](https://cardano-foundation.github.io/cardano-mpfs-onchain/development/) — building, dev shell, justfile recipes
- [Architecture Overview](https://cardano-foundation.github.io/cardano-mpfs-onchain/architecture/overview/) — system diagram, transaction lifecycle, protocol flow
- [Validators](https://cardano-foundation.github.io/cardano-mpfs-onchain/architecture/validators/) — minting policy and spending validator logic
- [Types & Encodings](https://cardano-foundation.github.io/cardano-mpfs-onchain/architecture/types/) — datum, redeemer, and operation structures
- [Proof System](https://cardano-foundation.github.io/cardano-mpfs-onchain/architecture/proofs/) — MPF proof format, verification, and performance
- [Security Properties](https://cardano-foundation.github.io/cardano-mpfs-onchain/architecture/properties/) — on-chain invariants and proof links
- [Haskell Cage Library](https://cardano-foundation.github.io/cardano-mpfs-onchain/haskell-cage/) — off-chain types, tx builders, test vectors

## Quick start

```sh
# Build plutus.json (Aiken validators)
nix build

# Run Aiken tests
nix run .#cage-tests

# Run Haskell QuickCheck tests
nix run .#cage-tests

# Enter dev shell (Haskell + Aiken + Lean)
nix develop
```

## License

See [LICENSE](LICENSE).
