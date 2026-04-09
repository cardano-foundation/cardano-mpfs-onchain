{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}

module CageE2ESpec (spec) where

import Control.Concurrent (threadDelay)
import Data.ByteString qualified as BS
import Data.Maybe (listToMaybe)
import Data.Time.Clock.POSIX (getPOSIXTime)
import System.Environment (lookupEnv)
import Test.Hspec

import Data.Set qualified as Set
import Lens.Micro ((&), (.~))

import Cardano.Ledger.Address (Addr)
import Cardano.Ledger.Api.Tx (mkBasicTx)
import Cardano.Ledger.Api.Tx.Body (collateralInputsTxBodyL, mkBasicTxBody)

import Cardano.Node.Client.Balance (balanceTx)
import Cardano.Node.Client.E2E.Setup
    ( addKeyWitness
    , genesisAddr
    , genesisSignKey
    , keyHashFromSignKey
    , withDevnet
    )
import Cardano.Node.Client.Provider (Provider (..))
import Cardano.Node.Client.Submitter (Submitter (..), SubmitResult (..))

import Cardano.MPFS.OnChain.AssetName (computeAssetName)
import Cardano.MPFS.OnChain.Types
    ( OnChainTokenId (..)
    )
import PlutusTx.Builtins.Internal (BuiltinByteString (..))

import CageTxBuilder

requireJust :: String -> Maybe a -> IO a
requireJust msg Nothing = fail msg
requireJust _ (Just x) = pure x

spec :: Spec
spec = do
    around setupDevnet $ do
        describe "MPF Cage E2E" $ do
            it "self-transfer with collateral" selfTransferWithCollateral
            it "mint and end" mintAndEnd
            it "modify with tip" modifyWithTip
            it "reject after retract window" rejectAfterRetract
            it "reject multiple requests" rejectMultipleRequests

type DevnetEnv = (CageEnv, Addr)

setupDevnet :: (DevnetEnv -> IO ()) -> IO ()
setupDevnet action = do
    bpPath <- lookupEnv "MPFS_BLUEPRINT"
    let bp = maybe "plutus.json" id bpPath
    withDevnet $ \lsq ltxs -> do
        now <- getPOSIXTime
        let startMs = round (now * 1000)
        env <- mkCageEnv bp startMs lsq ltxs
        action (env, genesisAddr)

selfTransferWithCollateral :: DevnetEnv -> IO ()
selfTransferWithCollateral (env, addr) = do
    let sk = genesisSignKey
    pp <- queryProtocolParams (envProvider env)
    utxos <- queryUTxOs (envProvider env) addr
    utxos `shouldSatisfy` (not . null)
    seedUtxo <- requireJust "seed UTxO" $ listToMaybe utxos
    let body = mkBasicTxBody
            & collateralInputsTxBodyL .~ Set.singleton (fst seedUtxo)
        tx = mkBasicTx body
    case balanceTx pp utxos addr tx of
        Left err -> fail $ "Balance error: " <> show err
        Right balanced -> do
            let signed = addKeyWitness sk balanced
            result <- submitTx (envSubmitter env) signed
            case result of
                Submitted _ -> pure ()
                Rejected reason -> fail $ "Rejected: " <> show reason

mintAndEnd :: DevnetEnv -> IO ()
mintAndEnd (env, addr) = do
    let sk = genesisSignKey
        kh = keyHashFromSignKey sk
    utxos <- queryUTxOs (envProvider env) addr
    utxos `shouldSatisfy` (not . null)
    seedUtxo <- requireJust "seed UTxO" $ listToMaybe utxos
    -- Mint
    mintTx <- buildMintTx env kh addr seedUtxo 0 60_000 60_000
    signAndSubmit env sk mintTx
    waitForTx
    -- Verify state UTxO exists
    scriptUtxos <- queryScriptUtxos env
    stateUtxo <- requireJust "state UTxO" $ findStateUtxo env scriptUtxos
    -- End
    endTx <- buildEndTx env kh addr stateUtxo
    signAndSubmit env sk endTx
    waitForTx
    -- Verify token is gone
    scriptUtxos' <- queryScriptUtxos env
    let mState' = findStateUtxo env scriptUtxos'
    mState' `shouldBe` Nothing

modifyWithTip :: DevnetEnv -> IO ()
modifyWithTip (env, addr) = do
    let sk = genesisSignKey
        kh = keyHashFromSignKey sk
        tip = 500_000
    utxos <- queryUTxOs (envProvider env) addr
    seedUtxo <- requireJust "seed UTxO" $ listToMaybe utxos
    let assetName = computeAssetName (fst seedUtxo)
        tokenId = OnChainTokenId (BuiltinByteString assetName)
    mintTx <- buildMintTx env kh addr seedUtxo tip 600_000 600_000
    signAndSubmit env sk mintTx
    waitForTx
    -- Request
    let submittedAt = envStartMs env + 5_000
    reqTx <-
        buildRequestTx
            env
            kh
            addr
            assetName
            tokenId
            "42"
            "42"
            tip
            submittedAt
    signAndSubmit env sk reqTx
    waitForTx
    -- Find state and request UTxOs
    scriptUtxos <- queryScriptUtxos env
    stateUtxo <- requireJust "state UTxO" $ findStateUtxo env scriptUtxos
    let reqUtxos =
            filter
                (\(tin, _) -> tin /= fst stateUtxo)
                scriptUtxos
    reqUtxos `shouldSatisfy` (not . null)
    -- Modify
    modTx <-
        buildModifyTx
            env
            kh
            addr
            stateUtxo
            reqUtxos
            BS.empty
            tip
            600_000
            600_000
    signAndSubmit env sk modTx
    waitForTx
    -- End
    scriptUtxos' <- queryScriptUtxos env
    stateUtxo' <- requireJust "state UTxO" $ findStateUtxo env scriptUtxos'
    endTx <- buildEndTx env kh addr stateUtxo'
    signAndSubmit env sk endTx
    waitForTx

-- | Reject 3 requests in a single tx.
-- Proves the fee loop converges with multiple
-- requests (more outputs, different fee).
rejectMultipleRequests :: DevnetEnv -> IO ()
rejectMultipleRequests (env, addr) = do
    let sk = genesisSignKey
        kh = keyHashFromSignKey sk
        processTime = 10_000
        retractTime = 10_000
        tip = 100_000
    utxos <- queryUTxOs (envProvider env) addr
    seedUtxo <- requireJust "seed UTxO" $ listToMaybe utxos
    let assetName = computeAssetName (fst seedUtxo)
        tokenId = OnChainTokenId (BuiltinByteString assetName)
    mintTx <- buildMintTx env kh addr seedUtxo tip processTime retractTime
    signAndSubmit env sk mintTx
    waitForTx
    -- Submit 3 requests
    let submittedAt = envStartMs env + 5_000
        submitReq key value = do
            reqTx <-
                buildRequestTx
                    env
                    kh
                    addr
                    assetName
                    tokenId
                    key
                    value
                    tip
                    submittedAt
            signAndSubmit env sk reqTx
            waitForTx
    submitReq "k1" "v1"
    submitReq "k2" "v2"
    submitReq "k3" "v3"
    -- Wait for phase 3
    let waitMs = processTime + retractTime + 2_000
    threadDelay (fromIntegral waitMs * 1000)
    -- Find state and request UTxOs
    scriptUtxos <- queryScriptUtxos env
    stateUtxo <- requireJust "state UTxO" $ findStateUtxo env scriptUtxos
    let reqUtxos =
            filter
                (\(tin, _) -> tin /= fst stateUtxo)
                scriptUtxos
    length reqUtxos `shouldBe` 3
    -- Reject all 3
    rejTx <-
        buildRejectTx
            env
            kh
            addr
            stateUtxo
            reqUtxos
            tip
            processTime
            retractTime
    signAndSubmit env sk rejTx
    waitForTx
    -- End
    scriptUtxos' <- queryScriptUtxos env
    stateUtxo' <- requireJust "state UTxO" $ findStateUtxo env scriptUtxos'
    endTx <- buildEndTx env kh addr stateUtxo'
    signAndSubmit env sk endTx
    waitForTx

rejectAfterRetract :: DevnetEnv -> IO ()
rejectAfterRetract (env, addr) = do
    let sk = genesisSignKey
        kh = keyHashFromSignKey sk
        processTime = 10_000
        retractTime = 10_000
    utxos <- queryUTxOs (envProvider env) addr
    seedUtxo <- requireJust "seed UTxO" $ listToMaybe utxos
    let assetName = computeAssetName (fst seedUtxo)
        tokenId = OnChainTokenId (BuiltinByteString assetName)
    mintTx <- buildMintTx env kh addr seedUtxo 0 processTime retractTime
    signAndSubmit env sk mintTx
    waitForTx
    -- Request
    let submittedAt = envStartMs env + 5_000
    reqTx <-
        buildRequestTx
            env
            kh
            addr
            assetName
            tokenId
            "42"
            "42"
            0
            submittedAt
    signAndSubmit env sk reqTx
    waitForTx
    -- Wait for phase 3
    let waitMs = processTime + retractTime + 2_000
    threadDelay (fromIntegral waitMs * 1000)
    -- Find state and request UTxOs
    scriptUtxos <- queryScriptUtxos env
    stateUtxo <- requireJust "state UTxO" $ findStateUtxo env scriptUtxos
    let reqUtxos =
            filter
                (\(tin, _) -> tin /= fst stateUtxo)
                scriptUtxos
    reqUtxos `shouldSatisfy` (not . null)
    -- Reject
    rejTx <-
        buildRejectTx
            env
            kh
            addr
            stateUtxo
            reqUtxos
            0
            processTime
            retractTime
    signAndSubmit env sk rejTx
    waitForTx
    -- End
    scriptUtxos' <- queryScriptUtxos env
    stateUtxo' <- requireJust "state UTxO" $ findStateUtxo env scriptUtxos'
    endTx <- buildEndTx env kh addr stateUtxo'
    signAndSubmit env sk endTx
    waitForTx
