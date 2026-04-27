{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}

{- |
Module      : Cardano.MPFS.Cage.E2E.CageSpec
Description : E2E tests for the full cage protocol
License     : Apache-2.0
-}
module Cardano.MPFS.Cage.E2E.CageSpec (spec) where

import Control.Concurrent (threadDelay)
import Control.Concurrent.Async (async, cancel, poll)
import Data.ByteString.Short qualified as SBS
import Data.Map.Strict qualified as Map
import Lens.Micro ((^.))
import System.Environment (lookupEnv)
import Test.Hspec (
    Spec,
    describe,
    expectationFailure,
    it,
    runIO,
    shouldSatisfy,
 )

import Cardano.Ledger.Api.Tx (
    Tx,
    bodyTxL,
    txIdTx,
 )
import Cardano.Ledger.Api.Tx.Body (
    mintTxBodyL,
 )
import Cardano.Ledger.BaseTypes (
    Network (..),
    TxIx (..),
 )
import Cardano.Ledger.Mary.Value (
    MultiAsset (..),
 )
import Cardano.Ledger.TxIn (TxIn (..))

import Cardano.MPFS.Cage.Blueprint (
    applyVersion,
    extractCompiledCode,
    loadBlueprint,
 )
import Cardano.MPFS.Cage.Config (
    CageConfig (..),
 )
import Cardano.MPFS.Cage.Ledger (
    Coin (..),
    ConwayEra,
    TokenId (..),
 )
import Cardano.MPFS.Cage.Provider qualified as Cage
import Cardano.MPFS.Cage.Trie (TrieManager (..))
import Cardano.MPFS.Cage.Trie.PureManager (
    mkPureTrieManager,
 )
import Cardano.MPFS.Cage.TxBuilder.Boot (
    bootTokenImpl,
 )
import Cardano.MPFS.Cage.TxBuilder.Internal (
    cageAddrFromCfg,
    cagePolicyIdFromCfg,
    computeScriptHash,
 )
import Cardano.MPFS.Cage.TxBuilder.Request (
    requestInsertImpl,
 )
import Cardano.MPFS.Cage.TxBuilder.Retract (
    retractRequestImpl,
 )
import Cardano.MPFS.Cage.TxBuilder.Update (
    updateTokenImpl,
 )
import Cardano.Node.Client.E2E.Devnet (
    withCardanoNode,
 )
import Cardano.Node.Client.E2E.Setup (
    addKeyWitness,
    genesisAddr,
    genesisDir,
    genesisSignKey,
 )
import Cardano.Node.Client.N2C.Connection (
    newLSQChannel,
    newLTxSChannel,
    runNodeClient,
 )
import Cardano.Node.Client.N2C.Provider (
    mkN2CProvider,
 )
import Cardano.Node.Client.N2C.Submitter (
    mkN2CSubmitter,
 )
import Cardano.Node.Client.Provider qualified as N2C
import Cardano.Node.Client.Submitter (
    SubmitResult (..),
    Submitter (..),
 )
import Ouroboros.Network.Magic (NetworkMagic (..))

{- | Full cage protocol E2E test spec.
Skips when @MPFS_BLUEPRINT@ is not set.
-}
spec :: Spec
spec = describe "Cage E2E" $ do
    mPath <-
        runIO $ lookupEnv "MPFS_BLUEPRINT"
    case mPath of
        Nothing ->
            it
                "skipped (MPFS_BLUEPRINT \
                \not set)"
                (pure () :: IO ())
        Just path -> do
            ebp <-
                runIO $ loadBlueprint path
            case ebp of
                Left err ->
                    it
                        ( "blueprint error: "
                            <> err
                        )
                        (expectationFailure err)
                Right bp ->
                    case extractCompiledCode
                        "cage."
                        bp of
                        Nothing ->
                            it "no compiled code" $
                                expectationFailure
                                    "cage script not \
                                    \found in blueprint"
                        Just scriptBytes ->
                            let applied =
                                    applyVersion
                                        1
                                        scriptBytes
                             in cageFlowSpec applied

-- ---------------------------------------------------------
-- Test implementation
-- ---------------------------------------------------------

{- | Full cage flow: boot, request, update,
and retract.
-}
cageFlowSpec ::
    SBS.ShortByteString -> Spec
cageFlowSpec scriptBytes =
    it "boot, request, update, retract" $
        withE2E scriptBytes $
            \cfg prov submit tm -> do
                let scriptAddr =
                        cageAddrFromCfg cfg Testnet

                -- Step 1: Boot token
                unsignedBoot <-
                    bootTokenImpl
                        cfg
                        prov
                        genesisAddr
                let signedBoot =
                        addKeyWitness
                            genesisSignKey
                            unsignedBoot

                bootResult <-
                    submitTx submit signedBoot
                assertSubmitted bootResult
                awaitTx

                -- Extract TokenId from mint field
                let tokenId =
                        extractTokenId cfg signedBoot

                -- Register trie for this token
                createTrie tm tokenId

                -- Assert: cage address has UTxO
                cageUtxos <-
                    Cage.queryUTxOs prov scriptAddr
                cageUtxos
                    `shouldSatisfy` (not . null)

                -- Step 2: Request insert
                unsignedReq <-
                    requestInsertImpl
                        cfg
                        prov
                        (Coin 1_000_000)
                        tokenId
                        "hello"
                        "world"
                        genesisAddr
                let signedReq =
                        addKeyWitness
                            genesisSignKey
                            unsignedReq
                reqResult <-
                    submitTx submit signedReq
                assertSubmitted reqResult
                awaitTx

                -- Assert: cage has more UTxOs now
                cageUtxos2 <-
                    Cage.queryUTxOs prov scriptAddr
                length cageUtxos2
                    `shouldSatisfy` (> length cageUtxos)

                -- Step 3: Update token
                unsignedUpdate <-
                    updateTokenImpl
                        cfg
                        prov
                        tm
                        tokenId
                        genesisAddr
                let signedUpdate =
                        addKeyWitness
                            genesisSignKey
                            unsignedUpdate
                updateResult <-
                    submitTx submit signedUpdate
                assertSubmitted updateResult
                awaitTx

                -- Assert: request was consumed
                cageUtxos3 <-
                    Cage.queryUTxOs prov scriptAddr
                cageUtxos3
                    `shouldSatisfy` (not . null)
                length cageUtxos3
                    `shouldSatisfy` (< length cageUtxos2)

                -- Step 4: Request + retract
                unsignedReq2 <-
                    requestInsertImpl
                        cfg
                        prov
                        (Coin 1_000_000)
                        tokenId
                        "bye"
                        "moon"
                        genesisAddr
                let signedReq2 =
                        addKeyWitness
                            genesisSignKey
                            unsignedReq2
                req2Result <-
                    submitTx submit signedReq2
                assertSubmitted req2Result
                awaitTx

                let req2TxIn =
                        TxIn
                            (txIdTx signedReq2)
                            (TxIx 0)

                cageUtxos4 <-
                    Cage.queryUTxOs prov scriptAddr
                length cageUtxos4
                    `shouldSatisfy` (> length cageUtxos3)

                -- Wait for Phase 2 (process_time =
                -- 30s after request submitted_at)
                threadDelay 32_000_000

                -- Retract the second request
                unsignedRetract <-
                    retractRequestImpl
                        cfg
                        prov
                        tokenId
                        req2TxIn
                        genesisAddr
                let signedRetract =
                        addKeyWitness
                            genesisSignKey
                            unsignedRetract
                retractResult <-
                    submitTx submit signedRetract
                assertSubmitted retractResult
                awaitTx

                -- Assert: request UTxO gone
                cageUtxos5 <-
                    Cage.queryUTxOs prov scriptAddr
                length cageUtxos5
                    `shouldSatisfy` (< length cageUtxos4)

-- ---------------------------------------------------------
-- Bracket
-- ---------------------------------------------------------

{- | Start a devnet node, connect via N2C,
build Provider and Submitter, then run.
-}
withE2E ::
    SBS.ShortByteString ->
    ( CageConfig ->
      Cage.Provider IO ->
      Submitter IO ->
      TrieManager IO ->
      IO a
    ) ->
    IO a
withE2E scriptBytes action = do
    gDir <- genesisDir
    withCardanoNode gDir $ \sock _startMs -> do
        lsqCh <- newLSQChannel 16
        ltxsCh <- newLTxSChannel 16
        nodeThread <-
            async $
                runNodeClient
                    (NetworkMagic 42)
                    sock
                    lsqCh
                    ltxsCh
        threadDelay 3_000_000
        -- Verify connection
        status <- poll nodeThread
        case status of
            Just (Left err) ->
                error $
                    "Node connection failed: "
                        <> show err
            Just (Right (Left err)) ->
                error $
                    "Node connection error: "
                        <> show err
            Just (Right (Right ())) ->
                error
                    "Node connection closed \
                    \unexpectedly"
            Nothing -> pure ()
        -- Build Provider (adapt from
        -- cardano-node-clients Provider)
        let n2cProv = mkN2CProvider lsqCh
            prov = adaptProvider n2cProv
        -- Build Submitter
        let submit = mkN2CSubmitter ltxsCh
        -- Build TrieManager
        tm <- mkPureTrieManager
        let cfg = cageCfg scriptBytes
        -- Verify connection works
        _ <- Cage.queryProtocolParams prov
        result <- action cfg prov submit tm
        cancel nodeThread
        pure result

{- | Adapt a @cardano-node-clients@ 'Provider' to a
@Cage@ 'Provider'. The record fields are
identical.
-}
adaptProvider :: N2C.Provider IO -> Cage.Provider IO
adaptProvider p =
    Cage.Provider
        { Cage.queryUTxOs =
            N2C.queryUTxOs p
        , Cage.queryProtocolParams =
            N2C.queryProtocolParams p
        , Cage.evaluateTx =
            N2C.evaluateTx p
        , Cage.posixMsToSlot =
            N2C.posixMsToSlot p
        , Cage.posixMsCeilSlot =
            N2C.posixMsCeilSlot p
        }

-- ---------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------

-- | Assert that a submit result is 'Submitted'.
assertSubmitted :: SubmitResult -> IO ()
assertSubmitted (Submitted _) = pure ()
assertSubmitted (Rejected reason) =
    expectationFailure $
        "Tx rejected: " <> show reason

{- | Extract the 'TokenId' from a boot
transaction's mint field.
-}
extractTokenId ::
    CageConfig -> Tx ConwayEra -> TokenId
extractTokenId cfg tx =
    let MultiAsset ma =
            tx ^. bodyTxL . mintTxBodyL
        assets =
            Map.toList
                ( ma
                    Map.! cagePolicyIdFromCfg cfg
                )
     in case assets of
            [(an, _)] -> TokenId an
            _ ->
                error
                    "extractTokenId: \
                    \unexpected assets"

-- | Wait for a transaction to be confirmed.
awaitTx :: IO ()
awaitTx = threadDelay 5_000_000

-- ---------------------------------------------------------
-- Config
-- ---------------------------------------------------------

-- | Build a 'CageConfig' from applied script bytes.
cageCfg ::
    SBS.ShortByteString -> CageConfig
cageCfg sb =
    CageConfig
        { cageScriptBytes = sb
        , cfgScriptHash =
            computeScriptHash sb
        , defaultProcessTime = 30_000
        , defaultRetractTime = 30_000
        , defaultTip = Coin 1_000_000
        , network = Testnet
        }
