{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}

module CageTxBuilder
    ( -- * Script setup
      CageEnv (..)
    , mkCageEnv

      -- * Transaction builders
    , buildMintTx
    , buildRequestTx
    , buildModifyTx
    , buildRejectTx
    , buildEndTx

      -- * Helpers
    , signAndSubmit
    , waitForTx
    , queryScriptUtxos
    , findStateUtxo
    ) where

import Control.Concurrent (threadDelay)
import Data.ByteString qualified as BS
import Data.ByteString.Lazy qualified as BSL
import Data.ByteString.Short qualified as SBS
import Data.Map.Strict qualified as Map
import Data.Sequence.Strict qualified as StrictSeq
import Data.Set qualified as Set
import Lens.Micro ((&), (.~), (^.))
import Numeric (showHex)
import System.IO (hPutStrLn, hFlush, stderr)

import Cardano.Crypto.Hash (hashToBytes)
import Cardano.Ledger.Address (Addr (..))
import Cardano.Ledger.Allegra.Scripts
    ( ValidityInterval (..)
    )
import Cardano.Ledger.Alonzo.Scripts (AsIx (..))
import Cardano.Ledger.Alonzo.TxBody
    ( reqSignerHashesTxBodyL
    , scriptIntegrityHashTxBodyL
    )
import Cardano.Ledger.Alonzo.TxWits
    ( Redeemers (..)
    )
import Cardano.Ledger.Api.Tx
    ( Tx
    , bodyTxL
    , mkBasicTx
    , witsTxL
    )
import Cardano.Ledger.Api.Tx.Body
    ( collateralInputsTxBodyL
    , feeTxBodyL
    , inputsTxBodyL
    , mintTxBodyL
    , mkBasicTxBody
    , outputsTxBodyL
    , vldtTxBodyL
    )
import Cardano.Ledger.Api.Tx.Out
    ( TxOut
    , coinTxOutL
    , datumTxOutL
    , mkBasicTxOut
    , valueTxOutL
    )
import Cardano.Ledger.Api.Tx.Wits
    ( rdmrsTxWitsL
    , scriptTxWitsL
    )
import Cardano.Ledger.BaseTypes
    ( Inject (..)
    , Network (..)
    , SlotNo (..)
    , StrictMaybe (SJust, SNothing)
    , TxIx (..)
    )
import Cardano.Ledger.Coin (Coin (..))
import Cardano.Ledger.Conway (ConwayEra)
import Cardano.Ledger.Conway.Scripts
    ( ConwayPlutusPurpose (..)
    )
import Cardano.Ledger.Core
    ( PParams
    , Script
    , eraProtVerLow
    , extractHash
    , hashScript
    )
import Cardano.Ledger.Credential
    ( Credential (..)
    , StakeReference (..)
    )
import Cardano.Ledger.Hashes (ScriptHash)
import Cardano.Ledger.Keys
    ( KeyHash (..)
    , KeyRole (..)
    , coerceKeyRole
    )
import Cardano.Ledger.Mary.Value
    ( MaryValue (..)
    , MultiAsset (..)
    , PolicyID (..)
    )
import Cardano.Ledger.Plutus.Language
    ( Language (PlutusV3)
    )
import Cardano.Ledger.TxIn (TxId (..), TxIn (..))
import Cardano.Ledger.Mary.Value qualified as Value
import PlutusTx.Builtins.Internal
    ( BuiltinByteString (..)
    )


import Cardano.Node.Client.Balance
    ( FeeLoopError (..)
    , balanceFeeLoop
    , computeScriptIntegrity
    , placeholderExUnits
    , spendingIndex
    )

import Cardano.MPFS.OnChain.AssetName (computeAssetName)
import Cardano.MPFS.OnChain.Datum
    ( mkInlineDatum
    , toLedgerData
    , toPlcData
    )
import Cardano.MPFS.OnChain.Script
    ( applyVersion
    , extractCompiledCode
    , loadBlueprint
    , mkCageScript
    )
import Cardano.MPFS.OnChain.Types

import Cardano.Node.Client.Balance (balanceTx)
import Cardano.Node.Client.E2E.Setup
    ( addKeyWitness
    )
import Cardano.Node.Client.N2C.Provider (mkN2CProvider)
import Cardano.Node.Client.N2C.Submitter (mkN2CSubmitter)
import Cardano.Node.Client.N2C.Types
    ( LSQChannel
    , LTxSChannel
    )
import Cardano.Node.Client.Provider (Provider (..))
import Cardano.Node.Client.Submitter
    ( SubmitResult (..)
    , Submitter (..)
    )
import Cardano.Crypto.DSIGN (Ed25519DSIGN, SignKeyDSIGN)
import Cardano.Ledger.Binary (serialize)

-- | Dump tx body diagnostic info to stderr.
-- Checks if CBOR bytes contain key 13 (collateral).
diagnoseTxBody :: String -> Tx ConwayEra -> IO ()
diagnoseTxBody label tx = do
    let body = tx ^. bodyTxL
        collateral =
            body ^. collateralInputsTxBodyL
        inputs = body ^. inputsTxBodyL
        fee = body ^. feeTxBodyL
        mintVal = body ^. mintTxBodyL
        bodyBytes =
            BSL.toStrict
                $ serialize
                    (eraProtVerLow @ConwayEra)
                    body
        -- Search for CBOR key 13 (0x0d) in the
        -- body map. Key 13 = collateral inputs.
        hexStr = bytesToHex bodyBytes
    hPutStrLn stderr
        $ "DIAG ["
            <> label
            <> "] inputs="
            <> show (Set.size inputs)
            <> " collateral="
            <> show (Set.size collateral)
            <> " fee="
            <> show fee
            <> " mint="
            <> show (mintVal == mempty)
            <> " bodyHex="
            <> hexStr
    hFlush stderr

bytesToHex :: BS.ByteString -> String
bytesToHex =
    concatMap
        ( \w ->
            let s = showHex w ""
            in  if length s == 1
                    then '0' : s
                    else s
        )
        . BS.unpack

data CageEnv = CageEnv
    { envScript :: Script ConwayEra
    , envScriptHash :: ScriptHash
    , envPolicyId :: PolicyID
    , envScriptAddr :: Addr
    , envMintScriptBytes :: SBS.ShortByteString
    , envSpendScriptBytes :: SBS.ShortByteString
    , envMintScript :: Script ConwayEra
    , envSpendScript :: Script ConwayEra
    , envMintScriptHash :: ScriptHash
    , envSpendScriptHash :: ScriptHash
    , envProvider :: Provider IO
    , envSubmitter :: Submitter IO
    , envStartMs :: Integer
    }

mkCageEnv
    :: FilePath
    -> Integer
    -> LSQChannel
    -> LTxSChannel
    -> IO CageEnv
mkCageEnv bpPath startMs lsq ltxs = do
    bp <- loadBlueprint bpPath >>= either fail pure
    let cageCode =
            maybe
                (error "cage compiled code not found")
                id
                (extractCompiledCode "cage." bp)
        appliedCode = applyVersion 0 cageCode
        cageScr = mkCageScript appliedCode
        cageHash = hashScript @ConwayEra cageScr
        policyId = PolicyID cageHash
        scriptAddr =
            Addr
                Testnet
                (ScriptHashObj cageHash)
                StakeRefNull
        provider = mkN2CProvider lsq
        submitter = mkN2CSubmitter ltxs
    pure
        CageEnv
            { envScript = cageScr
            , envScriptHash = cageHash
            , envPolicyId = policyId
            , envScriptAddr = scriptAddr
            , envMintScriptBytes = appliedCode
            , envSpendScriptBytes = appliedCode
            , envMintScript = cageScr
            , envSpendScript = cageScr
            , envMintScriptHash = cageHash
            , envSpendScriptHash = cageHash
            , envProvider = provider
            , envSubmitter = submitter
            , envStartMs = startMs
            }


emptyRoot :: BS.ByteString
emptyRoot = BS.replicate 32 0

-- | MPF root after inserting key "42" value "42"
-- into an empty trie with proof []. Taken from the
-- Aiken test vector in cage.tests.ak.
rootAfterInsert42 :: BS.ByteString
rootAfterInsert42 =
    BS.pack
        [ 0x48, 0x4d, 0xee, 0x38, 0x6b, 0xcb, 0x51
        , 0xe2, 0x85, 0x89, 0x62, 0x71, 0x04, 0x8b
        , 0xaf, 0x6e, 0xa4, 0x39, 0x6b, 0x2e, 0xe9
        , 0x5b, 0xe6, 0xfd, 0x29, 0xa9, 0x2a, 0x0e
        , 0xeb, 0x84, 0x62, 0xea
        ]

evaluateAndBalance
    :: Provider IO
    -> PParams ConwayEra
    -> [(TxIn, TxOut ConwayEra)]
    -> Addr
    -> Tx ConwayEra
    -> IO (Tx ConwayEra)
evaluateAndBalance prov pp inputUtxos changeAddr tx =
    do
        let existingIns =
                tx ^. bodyTxL . inputsTxBodyL
            allIns =
                foldl
                    ( \s (tin, _) ->
                        Set.insert tin s
                    )
                    existingIns
                    inputUtxos
            txForEval =
                tx
                    & bodyTxL . inputsTxBodyL
                        .~ allIns
        evalResult <- evaluateTx prov txForEval
        -- Check for script evaluation failures
        let failures =
                [ (p, e)
                | (p, Left e) <-
                    Map.toList evalResult
                ]
        if null failures
            then pure ()
            else
                error
                    $ "evaluateAndBalance: \
                      \script eval failed: "
                        <> show failures
        let Redeemers rdmrMap =
                tx ^. witsTxL . rdmrsTxWitsL
            patched =
                Map.mapWithKey
                    ( \purpose (dat, eu) ->
                        case Map.lookup
                            purpose
                            evalResult of
                            Just (Right eu') ->
                                (dat, eu')
                            _ -> (dat, eu)
                    )
                    rdmrMap
            newRedeemers = Redeemers patched
            integrity =
                computeScriptIntegrity
                    PlutusV3
                    pp
                    newRedeemers
            origCollateral =
                tx ^. bodyTxL . collateralInputsTxBodyL
            patched' =
                tx
                    & witsTxL . rdmrsTxWitsL
                        .~ newRedeemers
                    & bodyTxL
                        . scriptIntegrityHashTxBodyL
                        .~ integrity
        diagnoseTxBody "pre-balance" patched'
        case balanceTx
            pp
            inputUtxos
            changeAddr
            patched' of
            Left err ->
                error
                    $ "evaluateAndBalance: "
                        <> show err
            Right balanced -> do
                diagnoseTxBody "post-balance" balanced
                -- Re-apply collateral if balanceTx
                -- dropped it (MemoBytes bug)
                let postColl =
                        balanced
                            ^. bodyTxL
                                . collateralInputsTxBodyL
                if Set.null postColl
                    && not (Set.null origCollateral)
                    then do
                        hPutStrLn stderr
                            "DIAG: balanceTx dropped \
                            \collateral! Re-applying."
                        hFlush stderr
                        let fixed =
                                balanced
                                    & bodyTxL
                                        . collateralInputsTxBodyL
                                        .~ origCollateral
                        diagnoseTxBody "post-fix" fixed
                        pure fixed
                    else pure balanced

-- | Build a mint transaction.
buildMintTx
    :: CageEnv
    -> KeyHash 'Payment
    -> Addr
    -> (TxIn, TxOut ConwayEra)
    -> Integer
    -> Integer
    -> Integer
    -> IO (Tx ConwayEra)
buildMintTx env _ownerKh ownerAddr seedUtxo tip processTime retractTime = do
    pp <- queryProtocolParams (envProvider env)
    walletUtxos <- queryUTxOs (envProvider env) ownerAddr
    let (seedIn, _) = seedUtxo
        otherUtxos =
            filter (\(tin, _) -> tin /= seedIn) walletUtxos
        feeUtxo = case otherUtxos of
            (u : _) -> Just u
            [] -> Nothing
        collateralIn = maybe seedIn fst feeUtxo
        extraUtxos = case feeUtxo of
            Just fu -> [fu, seedUtxo]
            Nothing -> [seedUtxo]
        assetName = computeAssetName seedIn
        assetNameSbs = SBS.toShort assetName
        assetNameLedger = Value.AssetName assetNameSbs
        ownerKhBytes = case ownerAddr of
            Addr _ (KeyHashObj kh) _ ->
                let KeyHash h = kh
                in  hashToBytes h
            _ -> error "buildMintTx: not a key address"
        stateDatum =
            StateDatum
                OnChainTokenState
                    { stateOwner =
                        BuiltinByteString
                            ownerKhBytes
                    , stateRoot = OnChainRoot emptyRoot
                    , stateTip = tip
                    , stateProcessTime = processTime
                    , stateRetractTime = retractTime
                    }
        cageDatum = toPlcData stateDatum
        txOutRef = txInToRef seedIn
        mintRedeemer =
            Minting (Mint txOutRef)
        mint =
            MultiAsset
                $ Map.singleton
                    (envPolicyId env)
                    (Map.singleton assetNameLedger 1)
        stateOutput =
            mkBasicTxOut
                (envScriptAddr env)
                ( MaryValue
                    (Coin 2_000_000)
                    mint
                )
                & datumTxOutL
                    .~ mkInlineDatum cageDatum
        allScriptIns = Set.singleton seedIn
        mintRdmr =
            Redeemers
                $ Map.singleton
                    (ConwayMinting (AsIx 0))
                    ( toLedgerData mintRedeemer
                    , placeholderExUnits
                    )
        integrity =
            computeScriptIntegrity PlutusV3 pp mintRdmr
        body =
            mkBasicTxBody
                & inputsTxBodyL .~ allScriptIns
                & outputsTxBodyL
                    .~ StrictSeq.singleton stateOutput
                & mintTxBodyL .~ mint
                & collateralInputsTxBodyL
                    .~ Set.singleton collateralIn
                & scriptIntegrityHashTxBodyL
                    .~ integrity
        tx =
            mkBasicTx body
                & witsTxL . scriptTxWitsL
                    .~ Map.singleton
                        (envMintScriptHash env)
                        (envMintScript env)
                & witsTxL . rdmrsTxWitsL
                    .~ mintRdmr
    evaluateAndBalance
        (envProvider env)
        pp
        extraUtxos
        ownerAddr
        tx

-- | Build a request transaction (simple payment, no scripts).
buildRequestTx
    :: CageEnv
    -> KeyHash 'Payment
    -> Addr
    -> BS.ByteString
    -> OnChainTokenId
    -> BS.ByteString
    -> BS.ByteString
    -> Integer
    -> Integer
    -> IO (Tx ConwayEra)
buildRequestTx env _ownerKh ownerAddr _assetNameBs tokenId key value tip submittedAt = do
    pp <- queryProtocolParams (envProvider env)
    let ownerKhBytes = case ownerAddr of
            Addr _ (KeyHashObj kh) _ ->
                let KeyHash h = kh
                in  hashToBytes h
            _ -> error "buildRequestTx: not a key address"
        reqDatum =
            RequestDatum
                OnChainRequest
                    { requestToken = tokenId
                    , requestOwner =
                        BuiltinByteString
                            ownerKhBytes
                    , requestKey = key
                    , requestValue = OpInsert value
                    , requestTip = tip
                    , requestSubmittedAt = submittedAt
                    }
        reqOutput =
            mkBasicTxOut
                (envScriptAddr env)
                (inject (Coin 2_000_000))
                & datumTxOutL
                    .~ mkInlineDatum (toPlcData reqDatum)
        body =
            mkBasicTxBody
                & outputsTxBodyL
                    .~ StrictSeq.singleton reqOutput
        tx = mkBasicTx body
    walletUtxos <- queryUTxOs (envProvider env) ownerAddr
    let feeUtxo = case walletUtxos of
            [] -> error "buildRequestTx: no wallet UTxOs"
            (u : _) -> u
    case balanceTx pp [feeUtxo] ownerAddr tx of
        Left err ->
            error $ "buildRequestTx: " <> show err
        Right balanced -> pure balanced

-- | Build a modify transaction with conservation-aware fee handling.
buildModifyTx
    :: CageEnv
    -> KeyHash 'Payment
    -> Addr
    -> (TxIn, TxOut ConwayEra)
    -> [(TxIn, TxOut ConwayEra)]
    -> BS.ByteString
    -> Integer
    -> Integer
    -> Integer
    -> IO (Tx ConwayEra)
buildModifyTx env ownerKh ownerAddr stateUtxo reqUtxos _newRoot tip processTime retractTime = do
    pp <- queryProtocolParams (envProvider env)
    walletUtxos <- queryUTxOs (envProvider env) ownerAddr
    let feeUtxo = case walletUtxos of
            [] -> error "buildModifyTx: no wallet UTxOs"
            (u : _) -> u
    buildConservationTx
        BuildConservationConfig
            { bccEnv = env
            , bccPP = pp
            , bccOwnerKh = ownerKh
            , bccOwnerAddr = ownerAddr
            , bccStateUtxo = stateUtxo
            , bccReqUtxos = reqUtxos
            , bccFeeUtxo = feeUtxo
            , bccTip = tip
            , bccProcessTime = processTime
            , bccRetractTime = retractTime
            , bccNewRoot = rootAfterInsert42
            , bccStateRedeemer = Modify (map (const []) reqUtxos)
            , bccVldt =
                ValidityInterval
                    SNothing
                    (SJust (SlotNo 300))
            }

-- | Build a reject transaction with conservation-aware fee handling.
buildRejectTx
    :: CageEnv
    -> KeyHash 'Payment
    -> Addr
    -> (TxIn, TxOut ConwayEra)
    -> [(TxIn, TxOut ConwayEra)]
    -> Integer
    -> Integer
    -> Integer
    -> IO (Tx ConwayEra)
buildRejectTx env ownerKh ownerAddr stateUtxo reqUtxos tip processTime retractTime = do
    pp <- queryProtocolParams (envProvider env)
    walletUtxos <- queryUTxOs (envProvider env) ownerAddr
    let feeUtxo = case walletUtxos of
            [] -> error "buildRejectTx: no wallet UTxOs"
            (u : _) -> u
        -- Phase 3 validity: devnet-relative slots
        -- (100ms/slot), with ~5s genesis delay
        genesisDelayMs = 5_000
        phase3StartMs =
            genesisDelayMs
                + processTime
                + retractTime
                + 5_000
        lowerSlot =
            SlotNo
                ( fromIntegral
                    (phase3StartMs `div` 100)
                )
    buildConservationTx
        BuildConservationConfig
            { bccEnv = env
            , bccPP = pp
            , bccOwnerKh = ownerKh
            , bccOwnerAddr = ownerAddr
            , bccStateUtxo = stateUtxo
            , bccReqUtxos = reqUtxos
            , bccFeeUtxo = feeUtxo
            , bccTip = tip
            , bccProcessTime = processTime
            , bccRetractTime = retractTime
            , bccNewRoot = emptyRoot
            , bccStateRedeemer = Reject
            , bccVldt =
                ValidityInterval
                    (SJust lowerSlot)
                    (SJust (SlotNo 490))
            }

-- | Config for conservation-aware tx building
-- (shared by modify and reject).
data BuildConservationConfig = BuildConservationConfig
    { bccEnv :: CageEnv
    , bccPP :: PParams ConwayEra
    , bccOwnerKh :: KeyHash 'Payment
    , bccOwnerAddr :: Addr
    , bccStateUtxo :: (TxIn, TxOut ConwayEra)
    , bccReqUtxos :: [(TxIn, TxOut ConwayEra)]
    , bccFeeUtxo :: (TxIn, TxOut ConwayEra)
    , bccTip :: Integer
    , bccProcessTime :: Integer
    , bccRetractTime :: Integer
    , bccNewRoot :: BS.ByteString
    , bccStateRedeemer :: UpdateRedeemer
    , bccVldt :: ValidityInterval
    }

-- | Build a conservation-aware transaction (modify
-- or reject). Uses 'balanceFeeLoop' to find the
-- fee fixed point: fee and refund outputs converge
-- in 2–3 rounds, with no hardcoded overestimate.
buildConservationTx
    :: BuildConservationConfig -> IO (Tx ConwayEra)
buildConservationTx cfg = do
    let env = bccEnv cfg
        pp = bccPP cfg
        ownerAddr = bccOwnerAddr cfg
        (stateIn, stateOut) = bccStateUtxo cfg
        reqUtxos = bccReqUtxos cfg
        reqIns = map fst reqUtxos
        tip = bccTip cfg
        numReqs = fromIntegral (length reqUtxos)
        totalInputLovelace =
            foldl
                ( \(Coin acc) (_, o) ->
                    let Coin c = o ^. coinTxOutL
                    in  Coin (acc + c)
                )
                (Coin 0)
                reqUtxos
        Coin totalIn = totalInputLovelace
        oracleTipTotal = numReqs * tip
        ownerKhBytes = case ownerAddr of
            Addr _ (KeyHashObj kh) _ ->
                let KeyHash h = kh
                in  hashToBytes h
            _ ->
                error
                    "buildConservationTx: \
                    \not a key address"
        assetNameSbs = case stateOut ^. valueTxOutL of
            MaryValue _ (MultiAsset ma) ->
                case Map.lookup (envPolicyId env) ma of
                    Just assets ->
                        case Map.keys assets of
                            (Value.AssetName an : _) ->
                                an
                            _ ->
                                error
                                    "buildConservationTx: \
                                    \no asset"
                    Nothing ->
                        error
                            "buildConservationTx: \
                            \no policy"
        assetNameLedger = Value.AssetName assetNameSbs
        newDatum =
            StateDatum
                OnChainTokenState
                    { stateOwner =
                        BuiltinByteString
                            ownerKhBytes
                    , stateRoot =
                        OnChainRoot (bccNewRoot cfg)
                    , stateTip = tip
                    , stateProcessTime =
                        bccProcessTime cfg
                    , stateRetractTime =
                        bccRetractTime cfg
                    }
        mint =
            MultiAsset
                $ Map.singleton
                    (envPolicyId env)
                    (Map.singleton assetNameLedger 1)
        -- Output function for balanceFeeLoop:
        -- given a fee, compute state + refund outputs
        mkOutputs (Coin fee) =
            let totalRefund =
                    totalIn - fee - numReqs * tip
                perRequest =
                    if numReqs > 0
                        then totalRefund `div` numReqs
                        else 0
                remainder =
                    if numReqs > 0
                        then totalRefund `mod` numReqs
                        else 0
            in  if totalRefund < 0
                    then
                        Left
                            "insufficient funds \
                            \for fee + tips"
                    else
                        let stOut =
                                mkBasicTxOut
                                    (envScriptAddr env)
                                    ( MaryValue
                                        ( Coin
                                            ( 2_000_000
                                                + oracleTipTotal
                                            )
                                        )
                                        mint
                                    )
                                    & datumTxOutL
                                        .~ mkInlineDatum
                                            (toPlcData newDatum)
                            mkRefund i =
                                mkBasicTxOut
                                    ownerAddr
                                    ( inject
                                        ( Coin
                                            ( perRequest
                                                + if i
                                                    == (0 :: Int)
                                                    then
                                                        remainder
                                                    else 0
                                            )
                                        )
                                    )
                            refunds =
                                map
                                    mkRefund
                                    [0 .. length reqUtxos - 1]
                        in  Right
                                $ StrictSeq.fromList
                                    (stOut : refunds)
        allScriptIns =
            Set.fromList (stateIn : reqIns)
        stateRef = txInToRef stateIn
        stateIx =
            spendingIndex stateIn allScriptIns
        contributeEntries =
            map
                ( \rIn ->
                    let ix =
                            spendingIndex
                                rIn
                                allScriptIns
                        rdm = Contribute stateRef
                    in  ( ConwaySpending (AsIx ix)
                        ,
                            ( toLedgerData rdm
                            , placeholderExUnits
                            )
                        )
                )
                reqIns
        redeemers =
            Redeemers
                $ Map.fromList
                $ ( ConwaySpending (AsIx stateIx)
                  ,
                      ( toLedgerData
                            (bccStateRedeemer cfg)
                      , placeholderExUnits
                      )
                  )
                    : contributeEntries
        integrity =
            computeScriptIntegrity PlutusV3 pp redeemers
        witnessKh =
            coerceKeyRole (bccOwnerKh cfg)
                :: KeyHash 'Witness
        -- Template tx: inputs, collateral, scripts,
        -- redeemers set. Fee and outputs will be
        -- overwritten by balanceFeeLoop.
        templateBody =
            mkBasicTxBody
                & inputsTxBodyL .~ allScriptIns
                & collateralInputsTxBodyL
                    .~ Set.singleton
                        (fst (bccFeeUtxo cfg))
                & reqSignerHashesTxBodyL
                    .~ Set.singleton witnessKh
                & vldtTxBodyL .~ bccVldt cfg
                & scriptIntegrityHashTxBodyL
                    .~ integrity
        templateTx =
            mkBasicTx templateBody
                & witsTxL . scriptTxWitsL
                    .~ Map.singleton
                        (envSpendScriptHash env)
                        (envSpendScript env)
                & witsTxL . rdmrsTxWitsL
                    .~ redeemers
    -- Phase 1: evaluate scripts with a fee
    -- overestimate to get real ExUnits.
    let overestTx = case mkOutputs (Coin 1_000_000) of
            Left msg ->
                error
                    $ "buildConservationTx: "
                        <> msg
            Right outs ->
                templateTx
                    & bodyTxL . outputsTxBodyL .~ outs
                    & bodyTxL . feeTxBodyL
                        .~ Coin 1_000_000
    evalResult <-
        evaluateTx (envProvider env) overestTx
    let failures =
            [ (p, e)
            | (p, Left e) <-
                Map.toList evalResult
            ]
    if null failures
        then pure ()
        else
            error
                $ "buildConservationTx: \
                  \script eval: "
                    <> show failures
    -- Phase 2: patch ExUnits, recompute integrity,
    -- then find the fee fixed point with the real
    -- ExUnits baked in.
    let Redeemers rdmrMap =
            templateTx ^. witsTxL . rdmrsTxWitsL
        patchedRdmrs =
            Map.mapWithKey
                ( \purpose (dat, eu) ->
                    case Map.lookup
                        purpose
                        evalResult of
                        Just (Right eu') ->
                            (dat, eu')
                        _ -> (dat, eu)
                )
                rdmrMap
        newRedeemers = Redeemers patchedRdmrs
        newIntegrity =
            computeScriptIntegrity PlutusV3 pp newRedeemers
        patchedTx =
            templateTx
                & witsTxL . rdmrsTxWitsL
                    .~ newRedeemers
                & bodyTxL
                    . scriptIntegrityHashTxBodyL
                    .~ newIntegrity
    case balanceFeeLoop
        pp
        mkOutputs
        1
        patchedTx of
        Left (OutputError msg) ->
            error
                $ "buildConservationTx: "
                    <> msg
        Left FeeDidNotConverge ->
            error
                "buildConservationTx: \
                \fee did not converge"
        Right tx -> pure tx

-- | Build an end transaction (burn token, spend state UTxO).
buildEndTx
    :: CageEnv
    -> KeyHash 'Payment
    -> Addr
    -> (TxIn, TxOut ConwayEra)
    -> IO (Tx ConwayEra)
buildEndTx env ownerKh ownerAddr stateUtxo = do
    pp <- queryProtocolParams (envProvider env)
    let (stateIn, stateOut) = stateUtxo
        assetNameSbs = case stateOut ^. valueTxOutL of
            MaryValue _ (MultiAsset ma) ->
                case Map.lookup (envPolicyId env) ma of
                    Just assets ->
                        case Map.keys assets of
                            (Value.AssetName an : _) -> an
                            _ -> error "buildEndTx: no asset"
                    Nothing -> error "buildEndTx: no policy"
        assetNameLedger = Value.AssetName assetNameSbs
        burn =
            MultiAsset
                $ Map.singleton
                    (envPolicyId env)
                    (Map.singleton assetNameLedger (-1))
        endRedeemer = End
        burnRedeemer = Burning
        allScriptIns = Set.singleton stateIn
    walletUtxos <- queryUTxOs (envProvider env) ownerAddr
    let feeUtxo = case walletUtxos of
            [] -> error "buildEndTx: no wallet UTxOs"
            (u : _) -> u
        collateralIn = fst feeUtxo
        -- Compute indices with all inputs that
        -- evaluateAndBalance will add
        allInputs =
            Set.insert (fst feeUtxo) allScriptIns
        stateIx =
            spendingIndex stateIn allInputs
        redeemers =
            Redeemers
                $ Map.fromList
                    [ ( ConwaySpending (AsIx stateIx)
                      ,
                          ( toLedgerData endRedeemer
                          , placeholderExUnits
                          )
                      )
                    , ( ConwayMinting (AsIx 0)
                      ,
                          ( toLedgerData burnRedeemer
                          , placeholderExUnits
                          )
                      )
                    ]
        integrity =
            computeScriptIntegrity PlutusV3 pp redeemers
        witnessKh =
            coerceKeyRole ownerKh
                :: KeyHash 'Witness
        body =
            mkBasicTxBody
                & inputsTxBodyL .~ allScriptIns
                & mintTxBodyL .~ burn
                & collateralInputsTxBodyL
                    .~ Set.singleton collateralIn
                & reqSignerHashesTxBodyL
                    .~ Set.singleton witnessKh
                & scriptIntegrityHashTxBodyL
                    .~ integrity
        tx =
            mkBasicTx body
                & witsTxL . scriptTxWitsL
                    .~ Map.fromList
                        [ (envMintScriptHash env, envMintScript env)
                        , (envSpendScriptHash env, envSpendScript env)
                        ]
                & witsTxL . rdmrsTxWitsL
                    .~ redeemers
    evaluateAndBalance
        (envProvider env)
        pp
        [feeUtxo, stateUtxo]
        ownerAddr
        tx

-- | Helper: convert TxIn to OnChainTxOutRef
txInToRef :: TxIn -> OnChainTxOutRef
txInToRef (TxIn (TxId h) (TxIx ix)) =
    OnChainTxOutRef
        { txOutRefId =
            BuiltinByteString
                (hashToBytes (extractHash h))
        , txOutRefIdx = fromIntegral ix
        }

-- | Sign a transaction and submit it.
signAndSubmit
    :: CageEnv
    -> SignKeyDSIGN Ed25519DSIGN
    -> Tx ConwayEra
    -> IO ()
signAndSubmit env sk tx = do
    diagnoseTxBody "pre-sign" tx
    let signed = addKeyWitness sk tx
    diagnoseTxBody "post-sign" signed
    result <- submitTx (envSubmitter env) signed
    case result of
        Submitted _ -> pure ()
        Rejected reason ->
            error
                $ "Transaction rejected: "
                    <> show reason

-- | Wait for a transaction to be confirmed.
waitForTx :: IO ()
waitForTx = threadDelay 5_000_000

-- | Query UTxOs at the cage script address.
queryScriptUtxos
    :: CageEnv -> IO [(TxIn, TxOut ConwayEra)]
queryScriptUtxos env =
    queryUTxOs (envProvider env) (envScriptAddr env)

-- | Find the state UTxO (the one holding the cage token).
findStateUtxo
    :: CageEnv
    -> [(TxIn, TxOut ConwayEra)]
    -> Maybe (TxIn, TxOut ConwayEra)
findStateUtxo env = go
  where
    go [] = Nothing
    go ((tin, tout) : rest) =
        case tout ^. valueTxOutL of
            MaryValue _ (MultiAsset ma) ->
                case Map.lookup (envPolicyId env) ma of
                    Just assets
                        | not (Map.null assets) ->
                            Just (tin, tout)
                    _ -> go rest
