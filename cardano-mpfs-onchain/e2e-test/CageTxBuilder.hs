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
import Data.ByteString.Short qualified as SBS
import Data.Map.Strict qualified as Map
import Data.Sequence.Strict qualified as StrictSeq
import Data.Set qualified as Set
import Data.Word (Word32)
import Lens.Micro ((&), (.~), (^.))

import Cardano.Crypto.Hash (hashToBytes)
import Cardano.Ledger.Address (Addr (..))
import Cardano.Ledger.Allegra.Scripts
    ( ValidityInterval (..)
    )
import Cardano.Ledger.Alonzo.PParams
    ( LangDepView
    , getLanguageView
    )
import Cardano.Ledger.Alonzo.Scripts (AsIx (..))
import Cardano.Ledger.Alonzo.Tx
    ( ScriptIntegrityHash
    , hashScriptIntegrity
    )
import Cardano.Ledger.Alonzo.TxBody
    ( reqSignerHashesTxBodyL
    , scriptIntegrityHashTxBodyL
    )
import Cardano.Ledger.Alonzo.TxWits
    ( Redeemers (..)
    , TxDats (..)
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
    , StrictMaybe (SJust)
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
import Cardano.Ledger.Plutus.ExUnits (ExUnits (..))
import Cardano.Ledger.Plutus.Language
    ( Language (PlutusV3)
    )
import Cardano.Ledger.TxIn (TxId (..), TxIn (..))
import Cardano.Ledger.Mary.Value qualified as Value
import PlutusTx.Builtins.Internal
    ( BuiltinByteString (..)
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

placeholderExUnits :: ExUnits
placeholderExUnits = ExUnits 0 0

emptyRoot :: BS.ByteString
emptyRoot = BS.replicate 32 0

computeScriptIntegrity
    :: PParams ConwayEra
    -> Redeemers ConwayEra
    -> StrictMaybe ScriptIntegrityHash
computeScriptIntegrity pp rdmrs =
    let langViews :: Set.Set LangDepView
        langViews =
            Set.singleton
                (getLanguageView pp PlutusV3)
        emptyDats = TxDats mempty
    in  hashScriptIntegrity langViews rdmrs emptyDats

spendingIndex :: TxIn -> Set.Set TxIn -> Word32
spendingIndex needle inputs =
    let sorted = Set.toAscList inputs
    in  go 0 sorted
  where
    go _ [] =
        error "spendingIndex: TxIn not in set"
    go n (x : xs)
        | x == needle = n
        | otherwise = go (n + 1) xs

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
                    pp
                    newRedeemers
            -- Rebuild the body with new integrity to avoid
            -- composed lens losing collateral from MemoBytes
            oldBody = tx ^. bodyTxL
            newBody = oldBody
                & scriptIntegrityHashTxBodyL .~ integrity
            patched' =
                tx
                    & witsTxL . rdmrsTxWitsL
                        .~ newRedeemers
                    & bodyTxL .~ newBody
        case balanceTx
            pp
            inputUtxos
            changeAddr
            patched' of
            Left err ->
                error
                    $ "evaluateAndBalance: "
                        <> show err
            Right balanced -> pure balanced

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
            computeScriptIntegrity pp mintRdmr
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
    let (stateIn, stateOut) = stateUtxo
        reqIns = map fst reqUtxos
        overestimate = Coin 500_000
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
        Coin overEst = overestimate
        totalRefund = totalIn - overEst - numReqs * tip
        perRequest =
            if numReqs > 0
                then totalRefund `div` numReqs
                else 0
        remainder =
            if numReqs > 0
                then totalRefund `mod` numReqs
                else 0
        ownerKhBytes = case ownerAddr of
            Addr _ (KeyHashObj kh) _ ->
                let KeyHash h = kh
                in  hashToBytes h
            _ -> error "buildModifyTx: not a key address"
        assetNameSbs = case stateOut ^. valueTxOutL of
            MaryValue _ (MultiAsset ma) ->
                case Map.lookup (envPolicyId env) ma of
                    Just assets ->
                        case Map.keys assets of
                            (Value.AssetName an : _) -> an
                            _ -> error "buildModifyTx: no asset"
                    Nothing -> error "buildModifyTx: no policy"
        assetNameLedger = Value.AssetName assetNameSbs
        newStateDatum =
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
        mint =
            MultiAsset
                $ Map.singleton
                    (envPolicyId env)
                    (Map.singleton assetNameLedger 1)
        newStateOut =
            mkBasicTxOut
                (envScriptAddr env)
                (MaryValue (Coin 2_000_000) mint)
                & datumTxOutL
                    .~ mkInlineDatum
                        (toPlcData newStateDatum)
        mkRefundOut i =
            mkBasicTxOut
                ownerAddr
                ( inject
                    ( Coin
                        ( perRequest
                            + if i == (0 :: Int)
                                then remainder
                                else 0
                        )
                    )
                )
        refundOuts =
            map mkRefundOut [0 .. length reqUtxos - 1]
        allOuts =
            StrictSeq.fromList
                (newStateOut : refundOuts)
        allScriptIns =
            Set.fromList (stateIn : reqIns)
        -- Compute proofs: empty for E2E (empty MPF)
        proofs = map (const []) reqUtxos
        stateRef = txInToRef stateIn
        modifyRedeemer = Modify proofs
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
                $ ( ConwaySpending
                        (AsIx stateIx)
                  ,
                      ( toLedgerData modifyRedeemer
                      , placeholderExUnits
                      )
                  )
                    : contributeEntries
        integrity =
            computeScriptIntegrity pp redeemers
        witnessKh =
            coerceKeyRole ownerKh
                :: KeyHash 'Witness
        -- Validity: current time window
        nowMs = envStartMs env + 10_000
        nowSlot = SlotNo (fromIntegral (nowMs `div` 1000))
        upperSlot = SlotNo (fromIntegral ((nowMs + 60_000) `div` 1000))
        vldt =
            ValidityInterval
                (SJust nowSlot)
                (SJust upperSlot)
        body =
            mkBasicTxBody
                & inputsTxBodyL .~ allScriptIns
                & outputsTxBodyL .~ allOuts
                & feeTxBodyL .~ overestimate
                & reqSignerHashesTxBodyL
                    .~ Set.singleton witnessKh
                & vldtTxBodyL .~ vldt
                & scriptIntegrityHashTxBodyL
                    .~ integrity
        tx =
            mkBasicTx body
                & witsTxL . scriptTxWitsL
                    .~ Map.singleton
                        (envSpendScriptHash env)
                        (envSpendScript env)
                & witsTxL . rdmrsTxWitsL
                    .~ redeemers
    -- Conservation-aware: evaluate but don't rebalance
    -- (fee is already set, change goes to oracle via refunds)
    walletUtxos <- queryUTxOs (envProvider env) ownerAddr
    let feeUtxo = case walletUtxos of
            [] -> error "buildModifyTx: no wallet UTxOs"
            (u : _) -> u
        _allInputUtxos = feeUtxo : stateUtxo : reqUtxos
    -- Add collateral
    let txWithCollateral =
            tx
                & bodyTxL . collateralInputsTxBodyL
                    .~ Set.singleton (fst feeUtxo)
                & bodyTxL . inputsTxBodyL
                    .~ Set.insert (fst feeUtxo) allScriptIns
    evalResult <- evaluateTx (envProvider env) txWithCollateral
    let Redeemers rdmrMap =
            txWithCollateral ^. witsTxL . rdmrsTxWitsL
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
            computeScriptIntegrity pp newRedeemers
    pure
        $ txWithCollateral
            & witsTxL . rdmrsTxWitsL
                .~ newRedeemers
            & bodyTxL
                . scriptIntegrityHashTxBodyL
                .~ newIntegrity

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
    let (stateIn, stateOut) = stateUtxo
        reqIns = map fst reqUtxos
        overestimate = Coin 500_000
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
        Coin overEst = overestimate
        totalRefund = totalIn - overEst - numReqs * tip
        perRequest =
            if numReqs > 0
                then totalRefund `div` numReqs
                else 0
        remainder =
            if numReqs > 0
                then totalRefund `mod` numReqs
                else 0
        ownerKhBytes = case ownerAddr of
            Addr _ (KeyHashObj kh) _ ->
                let KeyHash h = kh
                in  hashToBytes h
            _ -> error "buildRejectTx: not a key address"
        assetNameSbs = case stateOut ^. valueTxOutL of
            MaryValue _ (MultiAsset ma) ->
                case Map.lookup (envPolicyId env) ma of
                    Just assets ->
                        case Map.keys assets of
                            (Value.AssetName an : _) -> an
                            _ -> error "buildRejectTx: no asset"
                    Nothing -> error "buildRejectTx: no policy"
        assetNameLedger = Value.AssetName assetNameSbs
        -- Same datum (root unchanged for reject)
        sameDatum =
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
        mint =
            MultiAsset
                $ Map.singleton
                    (envPolicyId env)
                    (Map.singleton assetNameLedger 1)
        newStateOut =
            mkBasicTxOut
                (envScriptAddr env)
                (MaryValue (Coin 2_000_000) mint)
                & datumTxOutL
                    .~ mkInlineDatum (toPlcData sameDatum)
        mkRefundOut i =
            mkBasicTxOut
                ownerAddr
                ( inject
                    ( Coin
                        ( perRequest
                            + if i == (0 :: Int)
                                then remainder
                                else 0
                        )
                    )
                )
        refundOuts =
            map mkRefundOut [0 .. length reqUtxos - 1]
        allOuts =
            StrictSeq.fromList
                (newStateOut : refundOuts)
        allScriptIns =
            Set.fromList (stateIn : reqIns)
        stateRef = txInToRef stateIn
        rejectRedeemer = Reject
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
                $ ( ConwaySpending
                        (AsIx stateIx)
                  ,
                      ( toLedgerData rejectRedeemer
                      , placeholderExUnits
                      )
                  )
                    : contributeEntries
        integrity =
            computeScriptIntegrity pp redeemers
        witnessKh =
            coerceKeyRole ownerKh
                :: KeyHash 'Witness
        -- Validity: must be after process_time + retract_time
        -- Use slots well past phase 3
        nowMs = envStartMs env + processTime + retractTime + 5_000
        nowSlot = SlotNo (fromIntegral (nowMs `div` 1000))
        upperSlot = SlotNo (fromIntegral ((nowMs + 60_000) `div` 1000))
        vldt =
            ValidityInterval
                (SJust nowSlot)
                (SJust upperSlot)
        body =
            mkBasicTxBody
                & inputsTxBodyL .~ allScriptIns
                & outputsTxBodyL .~ allOuts
                & feeTxBodyL .~ overestimate
                & reqSignerHashesTxBodyL
                    .~ Set.singleton witnessKh
                & vldtTxBodyL .~ vldt
                & scriptIntegrityHashTxBodyL
                    .~ integrity
        tx =
            mkBasicTx body
                & witsTxL . scriptTxWitsL
                    .~ Map.singleton
                        (envSpendScriptHash env)
                        (envSpendScript env)
                & witsTxL . rdmrsTxWitsL
                    .~ redeemers
    walletUtxos <- queryUTxOs (envProvider env) ownerAddr
    let feeUtxo = case walletUtxos of
            [] -> error "buildRejectTx: no wallet UTxOs"
            (u : _) -> u
        _allInputUtxos = feeUtxo : stateUtxo : reqUtxos
    let txWithCollateral =
            tx
                & bodyTxL . collateralInputsTxBodyL
                    .~ Set.singleton (fst feeUtxo)
                & bodyTxL . inputsTxBodyL
                    .~ Set.insert (fst feeUtxo) allScriptIns
    evalResult <- evaluateTx (envProvider env) txWithCollateral
    let Redeemers rdmrMap =
            txWithCollateral ^. witsTxL . rdmrsTxWitsL
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
            computeScriptIntegrity pp newRedeemers
    pure
        $ txWithCollateral
            & witsTxL . rdmrsTxWitsL
                .~ newRedeemers
            & bodyTxL
                . scriptIntegrityHashTxBodyL
                .~ newIntegrity

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
        stateIx = spendingIndex stateIn allScriptIns
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
            computeScriptIntegrity pp redeemers
        witnessKh =
            coerceKeyRole ownerKh
                :: KeyHash 'Witness
        body =
            mkBasicTxBody
                & inputsTxBodyL .~ allScriptIns
                & mintTxBodyL .~ burn
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
    walletUtxos <- queryUTxOs (envProvider env) ownerAddr
    let feeUtxo = case walletUtxos of
            [] -> error "buildEndTx: no wallet UTxOs"
            (u : _) -> u
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
    let signed = addKeyWitness sk tx
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
