# WIP: Issue #35 - Fair fee model + Haskell library + E2E tests

## Status

Haskell library compiles. E2E tests blocked by MemoBytes serialization bug.

## Completed

### Aiken/Lean (prior work)
- [x] Spec for new fee model
- [x] Aiken type renames: `State.max_fee` → `State.tip`, `Request.fee` → `Request.tip`
- [x] Aiken validator updates for conservation equation
- [x] TypeScript E2E tests (passing via Yaci DevKit)

### Haskell library: `cardano-mpfs-onchain`
- [x] `Cardano.MPFS.OnChain.Types` — canonical on-chain types with `stateTip`/`requestTip` field names
- [x] `Cardano.MPFS.OnChain.Script` — blueprint loading, `applyVersion`, `mkCageScript`, `computeScriptHash`
- [x] `Cardano.MPFS.OnChain.AssetName` — `computeAssetName :: TxIn -> ByteString`
- [x] `Cardano.MPFS.OnChain.Datum` — `mkInlineDatum`, `extractCageDatum`, `toPlcData`, `toLedgerData`
- [x] `Cardano.MPFS.OnChain` — re-export module
- [x] `cardano-mpfs-onchain.cabal` — library + e2e-tests test-suite
- [x] `cabal.project` — CHaP, source-repository-package pins
- [x] `nix build .#e2e-tests` compiles cleanly

### Build infrastructure
- [x] `flake.nix` — haskell.nix project with `nixpkgs.follows = "haskellNix/nixpkgs-unstable"`
- [x] `flake.nix` — `devnet-genesis` and `cardano-node` from `cardano-node-clients` input
- [x] `flake.nix` — `shellHook` sets `MPFS_BLUEPRINT` and `E2E_GENESIS_DIR`
- [x] `.github/workflows/ci.yml` — replaced TypeScript E2E with Haskell E2E job

### E2E test infrastructure (working)
- [x] Devnet starts via `withDevnet` (cardano-node subprocess)
- [x] N2C connection (LocalStateQuery + LocalTxSubmission)
- [x] UTxO queries work (`queryUTxOs`, `queryProtocolParams`)
- [x] Simple tx submission works (self-transfer, with and without collateral)
- [x] Script evaluation works (`evaluateTx` returns correct ExUnits)
- [x] `balanceTx` preserves collateral correctly

## Blocked: MemoBytes serialization bug

### Symptom
All transactions with Plutus scripts are rejected by the node with:
```
ConwayUtxowFailure (UtxoFailure (InsufficientCollateral (DeltaCoin 0) (Coin 833279)))
:| [ConwayUtxowFailure (UtxoFailure NoCollateralInputs)]
```

### Root cause (narrowed down)

The `collateralInputsTxBodyL` lens reads from `mbRawType` (the Haskell value inside `MemoBytes`), but `toCBOR MemoBytes` serializes from `mbBytes` (the cached CBOR bytes). These are **inconsistent** — `mbRawType` has collateral but `mbBytes` doesn't include it.

#### Evidence

1. **Haskell value is correct at every stage**: collateral=1 before `evaluateAndBalance`, after it, before `addKeyWitness`, after it, right up to `submitTx`.

2. **Simple txs work**: Self-transfer with collateral (no scripts) submits successfully. The same `balanceTx`, `addKeyWitness`, and `submitTx` code path works.

3. **Script txs fail**: Any tx with scripts/redeemers/integrity hash in the body gets `NoCollateralInputs`. Even with hardcoded ExUnits (no `evaluateAndBalance`).

4. **Bypassing `balanceTx` works for script txs**: When I submit a script tx with just `mkBasicTx body` (body has collateral set via `mkBasicTxBody & ... & collateralInputsTxBodyL .~ ...`), the node rejects for other reasons (wrong ExUnits, missing fee) but **NOT** `NoCollateralInputs`. Collateral is present.

5. **`balanceTx` on script txs drops collateral**: When the SAME body goes through `balanceTx` (which does `body & inputsTxBodyL .~ ... & outputsTxBodyL .~ ... & feeTxBodyL .~ f`), collateral disappears from the serialized CBOR despite being present in the Haskell value.

6. **`balanceTx` on plain txs preserves collateral**: A plain body (no scripts/mint/integrity) going through `balanceTx` keeps collateral.

#### Hypothesis

The `lensMemoRawType` for `inputsTxBodyL`, `outputsTxBodyL`, or `feeTxBodyL` in Conway era creates `MemoBytes` where `mbBytes` is serialized from a `ConwayTxBodyRaw` that has some fields reset. Specifically, when fields like `mintTxBodyL` or `scriptIntegrityHashTxBodyL` are present in the body, the `EncCBOR ConwayTxBodyRaw` serialization at `eraProtVerLow @ConwayEra` (Version 9) may produce CBOR that doesn't include collateral — even though `mbRawType.ctbrCollateralInputs` is set.

This could be a bug in:
- The `EncCBOR ConwayTxBodyRaw` instance (conditional field serialization)
- The `lensMemoRawType` implementation (stale raw type extraction)
- The interaction between multiple `lensMemoRawType` applications in a chain

The offchain (`cardano-mpfs-offchain`) uses identical code and the same library versions (`cardano-ledger-conway-1.19.0.0`, `cardano-ledger-core-1.17.0.0`) and works. The difference may be in how the body is constructed (order of lens applications, initial state of `mkBasicTxBody`).

### Next steps to investigate

1. **Dump `mbBytes` directly**: After `balanceTx`, extract `mbBytes` from the body's `MemoBytes` and decode with Python `cbor2` to check if CBOR map key 13 (collateral) is present. Compare with the same after `mkBasicTxBody & ...` before `balanceTx`.

2. **Compare `mbRawType` field-by-field**: After `balanceTx`, check every field of `ConwayTxBodyRaw` to see if any unexpected values appear.

3. **Binary comparison**: Serialize the body at each step of the lens chain (`mkBasicTxBody & inputsTxBodyL .~ ...`, then `& outputsTxBodyL .~ ...`, etc.) and decode each intermediate CBOR to find exactly which lens application drops collateral.

4. **Test with offchain's exact code path**: Import `bootTokenImpl` from the offchain and run it in our test context to see if it also fails, which would prove the issue is environmental, not code.

5. **Check `EncCBOR ConwayTxBodyRaw`**: The Conway body uses a CBOR map with optional fields. Check if the serialization conditionally omits collateral when other fields (like mint or integrity hash) are present.

## Design (agreed with user)

### New fee model
- State datum: `max_fee` → `tip` (oracle's margin per request)
- Request datum: `fee` → `tip` (requester agrees to oracle's tip)
- Conservation equation: `totalRefunded == totalInputLovelace - tx.fee - N * tip`
- Plutus V3 `tx.fee` field provides the actual transaction fee on-chain

### Haskell library purpose
Canonical source for on-chain types. The offchain (`cardano-mpfs-offchain`) will eventually import from here instead of maintaining its own copy in `Core.OnChain`.

### E2E test approach
- Uses `withDevnet` from `cardano-node-clients:devnet` (cardano-node subprocess)
- No Yaci DevKit, no docker-compose, no Node.js
- Three scenarios: mint-and-end, modify-with-tip, reject-after-retract

## Files

### New
```
cardano-mpfs-onchain/
├── cardano-mpfs-onchain.cabal
├── lib/Cardano/MPFS/OnChain.hs
├── lib/Cardano/MPFS/OnChain/Types.hs
├── lib/Cardano/MPFS/OnChain/Script.hs
├── lib/Cardano/MPFS/OnChain/AssetName.hs
├── lib/Cardano/MPFS/OnChain/Datum.hs
├── e2e-test/Main.hs
├── e2e-test/CageTxBuilder.hs
└── e2e-test/CageE2ESpec.hs
cabal.project
```

### Modified
- `flake.nix` — added haskell.nix, cardano-node-clients input, devnet-genesis
- `.github/workflows/ci.yml` — replaced TypeScript E2E with Haskell E2E

### Dependency pins
- `cardano-node-clients` at `1104f7cb` (same as offchain)
- `chain-follower` at `371b5930`
- `rocksdb-kv-transactions` at `e2e77579`
- `rocksdb-haskell` at `a3e86b39`
- CHaP at `a46182e9` (same as offchain)
- haskell.nix at `baa6a549` (same as offchain)
