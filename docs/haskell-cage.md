# Haskell Cage Library

The `haskell/` directory contains `cardano-mpfs-cage`, a Haskell
package that provides everything needed to build and submit cage
transactions off-chain.

## What it provides

### On-chain type encodings

Hand-written `ToData`/`FromData` instances matching the Aiken
validator byte-for-byte. These are the canonical Haskell
representation — the
[offchain service](https://github.com/lambdasistemi/cardano-mpfs-offchain)
imports them as re-exports.

- `Cardano.MPFS.Cage.Types` — `CageDatum`, `UpdateRedeemer`,
  `MintRedeemer`, `RequestAction`, `ProofStep`, `Neighbor`,
  and all on-chain domain types
- `Cardano.MPFS.Cage.AssetName` — deterministic asset-name
  derivation matching Aiken's `lib.assetName`

### MPF proof serialization

- `Cardano.MPFS.Cage.Proof` — converts `MPFProof` from
  [haskell-mts](https://github.com/lambdasistemi/haskell-mts)
  to on-chain `ProofStep` lists and Aiken-compatible CBOR

### Blueprint loading

- `Cardano.MPFS.Cage.Blueprint` — CIP-57 `plutus.json` parser,
  compiled code extraction, and UPLC version parameter application

### Transaction builders

All cage protocol transactions, using the
[TxBuild DSL](https://github.com/lambdasistemi/cardano-node-clients)
for convergent fee balancing:

| Module | Transaction | Description |
|--------|------------|-------------|
| `TxBuilder.Boot` | Mint | Create a new cage token with empty trie |
| `TxBuilder.Request` | Pay-to-script | Submit an insert/delete/update request |
| `TxBuilder.Update` | Modify | Process requests, update root, refund requesters |
| `TxBuilder.Reject` | Modify with `Rejected` actions | Discard expired or dishonest requests |
| `TxBuilder.Retract` | Retract | Cancel a request in Phase 2 |
| `TxBuilder.End` | Burn | Destroy the cage token |

### In-memory MPF trie

- `Cardano.MPFS.Cage.Trie` — record-of-functions interface
- `Cardano.MPFS.Cage.Trie.Pure` — `IORef`-backed implementation
  using [haskell-mts](https://github.com/lambdasistemi/haskell-mts)
- `Cardano.MPFS.Cage.Trie.PureManager` — per-token trie management
  with speculative sessions for proof generation

## Test vectors

The `cage-test-vectors` executable generates deterministic test
data for cross-language validation:

```sh
# JSON format (for any backend)
nix run .#cage-test-vectors

# Aiken format (for validator unit tests)
nix run .#cage-test-vectors -- --aiken
```

Vectors include:
- MPF proof roundtrips (insert, fork, shared prefix, inclusion)
- Asset name derivation (various txId/index combinations)
- Datum/redeemer PlutusData encodings (all constructors)

## QuickCheck tests

Property-based tests verify:
- `ToData`/`FromData` roundtrip for every type
- Constructor indices match Aiken (0-indexed)
- Asset name determinism, uniqueness, and length

```sh
nix run .#cage-tests
```

## Dependencies

- [cardano-node-clients](https://github.com/lambdasistemi/cardano-node-clients) —
  TxBuild DSL, fee balancing, N2C provider
- [haskell-mts](https://github.com/lambdasistemi/haskell-mts) —
  in-memory MPF trie (`mts:mpf`)
- [CHaP](https://github.com/intersectmbo/cardano-haskell-packages) —
  Cardano ledger libraries
