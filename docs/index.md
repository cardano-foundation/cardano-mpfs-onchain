# Cardano MPFS Onchain

Aiken validators and Haskell off-chain library for
[Merkle Patricia Forestry](https://github.com/aiken-lang/merkle-patricia-forestry)
on Cardano (Plutus V3).

> **New to MPFS?** Start with the [Introduction](introduction.md) — a plain-language
> explanation of what this system does, why it exists, and how it stays trustworthy
> without trusting the operator. No blockchain background assumed.

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
- [Permissionless multi-oracle registries](design/registries/index.md) — design: decided, modelled in Lean and audited, not yet implemented

## Where this is going

Every way a request leaves the cage, other than the requester's own Phase 2
retraction, needs the state owner's signature. That makes the oracle a
liveness dependency and stops a cage from serving as a public registry. The
[permissionless multi-oracle registries](design/registries/index.md) design
removes both limits: anyone creates a registry by naming its oracles and
protocol, one request script per release serves every registry, and anyone
can fold what the oracles approved. It is decided, modelled in Lean and
independently audited; its implementation is the milestone
[Permissionless multi-oracle registries](https://github.com/cardano-foundation/cardano-mpfs-onchain/milestone/3).
The [cardano-keri](https://github.com/lambdasistemi/cardano-keri) AID
registry uses a permissioned cage today.
