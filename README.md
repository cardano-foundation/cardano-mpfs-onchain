# Cardano MPFS Onchain

Aiken validators for [Merkle Patricia Forestry](https://github.com/aiken-lang/merkle-patricia-forestry) on Cardano (Plutus V3).

The on-chain component defines a **cage** pattern: an NFT locked at a script address carries the current MPF root hash as its datum. Modifications are verified on-chain via cryptographic proofs.

This repository contains the on-chain validators extracted from [cardano-foundation/mpfs](https://github.com/cardano-foundation/mpfs) (`on_chain/` directory). See the upstream [documentation](https://cardano-foundation.github.io/mpfs/) for the full MPFS system including the off-chain TypeScript service.

## Documentation

Full documentation is available at **[cardano-foundation.github.io/cardano-mpfs-onchain](https://cardano-foundation.github.io/cardano-mpfs-onchain/)**.

- [Development](https://cardano-foundation.github.io/cardano-mpfs-onchain/development/) — building, dev shell, justfile recipes
- [Architecture Overview](https://cardano-foundation.github.io/cardano-mpfs-onchain/architecture/overview/) — system diagram, transaction lifecycle, protocol flow
- [Validators](https://cardano-foundation.github.io/cardano-mpfs-onchain/architecture/validators/) — minting policy and spending validator logic
- [Types & Encodings](https://cardano-foundation.github.io/cardano-mpfs-onchain/architecture/types/) — datum, redeemer, and operation structures
- [Proof System](https://cardano-foundation.github.io/cardano-mpfs-onchain/architecture/proofs/) — MPF proof format, verification, and performance
- [Security Properties](https://cardano-foundation.github.io/cardano-mpfs-onchain/architecture/properties/) — 17 invariants verified by 44 tests

## Quick Start

```sh
# Build plutus.json
nix build

# Enter dev shell
nix develop

# Run tests (44 tests, 242 checks)
nix develop --command aiken check
```

## License

See [LICENSE](LICENSE).
