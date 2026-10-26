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
- [Permissionless multi-oracle registries](https://cardano-foundation.github.io/cardano-mpfs-onchain/design/registries/) — design: decided, modelled in Lean and audited, not yet implemented

## Where this is going

Every way a request leaves the cage, other than the requester's own Phase 2
retraction, needs the state owner's signature. That makes the oracle a
liveness dependency and stops a cage from serving as a public registry.
The [permissionless multi-oracle registries](https://cardano-foundation.github.io/cardano-mpfs-onchain/design/registries/)
design is the planned answer: anyone creates a registry by naming its oracles
and protocol, one request script per release serves every registry, and anyone
can fold what the oracles approved. It is decided, modelled in Lean and
independently audited; its implementation is the milestone
[Permissionless multi-oracle registries](https://github.com/cardano-foundation/cardano-mpfs-onchain/milestone/3).
The [cardano-keri](https://github.com/lambdasistemi/cardano-keri) AID registry
(milestone M1, epic
[K6](https://github.com/lambdasistemi/cardano-keri/issues/324)) runs on a
permissioned cage today.

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
