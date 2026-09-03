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
- [Permissionless Registries](https://cardano-foundation.github.io/cardano-mpfs-onchain/roadmap/permissionless-registries/) — roadmap: what is planned and not yet shipped

## Where this is going

Every way a request leaves the cage, other than the requester's own Phase 2
retraction, needs the state owner's signature. That makes the oracle a
liveness dependency and stops a cage from serving as a public registry.
Permissionless Phase 3 sweep (#98), plugin cages (#99) and the keri registry
plugin (#104) are the planned answer; the
[roadmap page](https://cardano-foundation.github.io/cardano-mpfs-onchain/roadmap/permissionless-registries/)
has the detail. Its first consumer is the
[cardano-keri](https://github.com/lambdasistemi/cardano-keri) AID registry
(milestone M1, epic
[K6](https://github.com/lambdasistemi/cardano-keri/issues/324)), which runs
on a permissioned cage today and consumes one interface from it: the leaf map
`absent` / `live` / `closed(epoch, sn)` / `convicted`.

## Quick start

```sh
# Build plutus.json (Aiken validators)
nix build

# Run Aiken validator tests
just test          # or: nix build .#checks.x86_64-linux.aiken-check

# Run Haskell QuickCheck tests
nix run .#cage-tests

# Run fourmolu + hlint
nix run .#lint

# Enter dev shell (Haskell + Aiken + Lean)
nix develop
```

## License

Apache-2.0. The Haskell package carries the licence text at
[haskell/LICENSE](haskell/LICENSE); a repository-root copy is still missing
([#85](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/85)).
