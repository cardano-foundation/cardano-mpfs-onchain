# WIP: Issue #35 - Fair fee model + Haskell library + E2E tests

## Status

All 4 E2E tests pass: self-transfer, mint-and-end, modify-with-tip, reject-after-retract.

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

## Resolved: NoCollateralInputs errors

### What happened

The WIP originally attributed all `NoCollateralInputs` errors to a MemoBytes
serialization bug in cardano-ledger. CBOR diagnostics proved this wrong:
`balanceTx` never dropped collateral. The actual bugs were in the E2E tx builders.

### Bugs found and fixed (commit e06eb5c)

1. **`buildEndTx` never set `collateralInputsTxBodyL`** — the body was constructed
   without collateral. This was the original `NoCollateralInputs` error.

2. **`buildModifyTx`/`buildRejectTx` added the fee UTxO to body `inputsTxBodyL`** —
   the wallet UTxO (billions of ADA) was included as a script input, causing
   `ValueNotConservedUTxO`, shifted spending indices (`MissingRedeemers`/`ExtraRedeemers`),
   and `FeeTooSmallUTxO`. The fee UTxO should only be collateral; the fee is paid
   from request UTxO values via the conservation equation.

3. **Slot calculation used absolute POSIX time / 1000** — produced slot ~1.7 billion
   on a devnet with max slot 500. Fixed to use devnet-relative slots (offset / 100ms)
   with genesis delay compensation.

4. **N\*tip not placed in any output** — the oracle's tip margin was deducted from
   refunds but not added anywhere, violating ledger conservation. Fixed by adding
   tips to the state output value.

5. **Fee overestimate too low** — 500K < actual ~552K. Increased to 600K.

6. **MPF root hardcoded to emptyRoot in modify** — the output datum used all-zero
   root instead of the correct root after inserting "42"→"42". Used Aiken test
   vector `484dee...`.

7. **Missing script evaluation error checking** in modify/reject — `evaluateTx`
   failures were silently ignored.

### MemoBytes verdict

The cardano-ledger `lensMemoRawType` mechanism is sound. Each lens application
extracts the full `ConwayTxBodyRaw`, applies a standard Haskell record update
(only touching the target field), re-serializes via `mkMemoizedEra`, and stores
consistent `mbRawType` + `mbBytes`. The `EncCBOR ConwayTxBodyRaw` instance
correctly includes collateral (key 13) whenever `null ctbrCollateralInputs` is
False. There is no MemoBytes bug.

## Refactoring proposals

### 1. Extract shared modify/reject logic (~200 lines duplication)

`buildModifyTx` and `buildRejectTx` are nearly identical. They differ only in:
redeemer (Modify vs Reject), new root, and validity interval. Extract a
`buildConservationTx` helper parameterized by these differences.

### 2. Slim down CageEnv

Four fields are never read (`envMintScriptBytes`, `envSpendScriptBytes`) and four
are redundant copies of `envScript`/`envScriptHash` (`envMintScript`,
`envSpendScript`, `envMintScriptHash`, `envSpendScriptHash`). These were copied
from the offchain where mint and spend could be separate scripts. Here they're
the same script — collapse to `envScript` + `envScriptHash`.

### 3. Remove unused function parameters

- `buildMintTx`: `_ownerKh` unused
- `buildRequestTx`: `_assetNameBs` unused
- `buildModifyTx`: `_newRoot` unused (hardcodes `rootAfterInsert42` instead)

### 4. Extract repeated helpers

- Asset name extraction from state output (3 copies)
- Owner keyhash bytes from Addr (4 copies)
- Wallet UTxO fetch with error (5 copies)
- Redeemer patching + integrity hash update (2 copies)

### 5. Remove diagnostic code and dead workaround

- `diagnoseTxBody` writes unconditionally to stderr — either gate behind
  `MPFS_E2E_DIAG=1` or remove
- The collateral re-application workaround in `evaluateAndBalance` is dead code
  (`balanceTx` doesn't drop collateral) — remove it

### 6. Document the two balancing strategies

`buildMintTx`/`buildEndTx` use `evaluateAndBalance` → `balanceTx` (automatic fee).
`buildModifyTx`/`buildRejectTx` hardcode the fee at 600K and build conservation-aware
outputs manually. The split exists because the new conservation equation
`refund = reqValues - tx.fee - N*tip` requires knowing the fee before computing
outputs, while `balanceTx` computes the fee from the outputs. The manual approach
breaks this circularity by fixing the fee upfront. The excess (overestimate minus
actual min fee) goes to treasury. This design choice should be documented.

### 7. Validate negative refunds

If `totalIn < overestimate + N*tip`, the refund goes negative. Add a guard.

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
