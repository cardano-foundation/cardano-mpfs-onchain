{-# LANGUAGE NumericUnderscores #-}

-- |
-- Module      : Cardano.MPFS.Cage.TxBuilder.Request
-- Description : Request insert/delete/update transactions
-- License     : Apache-2.0
--
-- Builds request transactions for inserting, deleting,
-- or updating a key in a token's trie. No script
-- execution occurs — the transaction simply pays to
-- the cage address with an inline 'RequestDatum'.
-- The locked ADA includes the token's @tip@ plus a
-- fee buffer for the oracle's update transaction.
module Cardano.MPFS.Cage.TxBuilder.Request
    ( requestInsertImpl
    , requestDeleteImpl
    , requestUpdateImpl
    , requestLockedAda
    ) where

import Data.ByteString (ByteString)
import Data.List (sortOn)
import Data.Ord (Down (..))
import Data.Sequence.Strict qualified as StrictSeq
import Lens.Micro ((&), (.~), (^.))

import Cardano.Ledger.Address (Addr)
import Cardano.Ledger.Api.Tx
    ( Tx
    , mkBasicTx
    )
import Cardano.Ledger.Api.Tx.Body
    ( mkBasicTxBody
    , outputsTxBodyL
    )
import Cardano.Ledger.Api.Tx.Out
    ( TxOut
    , coinTxOutL
    , datumTxOutL
    , getMinCoinTxOut
    , mkBasicTxOut
    , valueTxOutL
    )
import Cardano.Ledger.BaseTypes (Inject (..))

import Cardano.MPFS.Cage.Config
    ( CageConfig (..)
    )
import Cardano.MPFS.Cage.OnChain
    ( OnChainOperation (..)
    )
import Cardano.MPFS.Cage.Provider (Provider (..))
import Cardano.MPFS.Cage.TxBuilder.Internal
import Cardano.MPFS.Cage.Types
    ( Coin (..)
    , ConwayEra
    , PParams
    , TokenId
    )
import Cardano.Node.Client.Balance
    ( BalanceResult (..)
    , balanceTx
    )

-- | Build a request-insert transaction.
requestInsertImpl
    :: CageConfig
    -> Provider IO
    -> Coin
    -- ^ Token tip (lovelace)
    -> TokenId
    -> ByteString
    -- ^ Key to insert
    -> ByteString
    -- ^ Value to insert
    -> Addr
    -> IO (Tx ConwayEra)
requestInsertImpl cfg prov tip tid key value =
    requestImpl
        cfg
        prov
        tip
        tid
        key
        (OpInsert value)

-- | Build a request-delete transaction.
requestDeleteImpl
    :: CageConfig
    -> Provider IO
    -> Coin
    -- ^ Token tip (lovelace)
    -> TokenId
    -> ByteString
    -- ^ Key to delete
    -> ByteString
    -- ^ Old value (for on-chain proof)
    -> Addr
    -> IO (Tx ConwayEra)
requestDeleteImpl cfg prov tip tid key val =
    requestImpl
        cfg
        prov
        tip
        tid
        key
        (OpDelete val)

-- | Build a request-update transaction.
requestUpdateImpl
    :: CageConfig
    -> Provider IO
    -> Coin
    -- ^ Token tip (lovelace)
    -> TokenId
    -> ByteString
    -- ^ Key to update
    -> ByteString
    -- ^ Old value (must match current)
    -> ByteString
    -- ^ New value
    -> Addr
    -> IO (Tx ConwayEra)
requestUpdateImpl
    cfg
    prov
    tip
    tid
    key
    oldVal
    newVal =
        requestImpl
            cfg
            prov
            tip
            tid
            key
            (OpUpdate oldVal newVal)

-- | Generic request transaction builder.
requestImpl
    :: CageConfig
    -> Provider IO
    -> Coin
    -- ^ Token tip
    -> TokenId
    -> ByteString
    -> OnChainOperation
    -> Addr
    -> IO (Tx ConwayEra)
requestImpl cfg prov (Coin mf) tid key op addr = do
    pp <- queryProtocolParams prov
    utxos <- queryUTxOs prov addr
    feeUtxo <- case sortOn
        (Down . (^. coinTxOutL) . snd)
        utxos of
        [] -> error "requestImpl: no UTxOs"
        (u : _) -> pure u
    now <- currentPosixMs
    let datum =
            mkRequestDatum tid addr key op mf now
        scriptAddr =
            cageAddrFromCfg cfg (network cfg)
        draftOut =
            mkBasicTxOut
                scriptAddr
                (inject (Coin 0))
                & datumTxOutL
                    .~ mkInlineDatum datum
        refundDraft =
            mkBasicTxOut addr (inject (Coin 0))
        minAda =
            requestLockedAda
                pp
                draftOut
                refundDraft
                mf
        txOut =
            mkBasicTxOut
                scriptAddr
                (inject minAda)
                & datumTxOutL
                    .~ mkInlineDatum datum
        body =
            mkBasicTxBody
                & outputsTxBodyL
                    .~ StrictSeq.singleton txOut
        tx = mkBasicTx body
    case balanceTx pp [feeUtxo] addr tx of
        Left err ->
            error
                $ "requestImpl: " <> show err
        Right br -> pure (balancedTx br)

-- | Compute the ADA to lock in a request output.
requestLockedAda
    :: PParams ConwayEra
    -> TxOut ConwayEra
    -> TxOut ConwayEra
    -> Integer
    -> Coin
requestLockedAda pp reqDraft refDraft tip =
    let Coin refMin =
            getMinCoinTxOut pp refDraft
        feeBuffer = 1_000_000
        locked = tip + feeBuffer + refMin
        adjusted =
            getMinCoinTxOut
                pp
                ( reqDraft
                    & valueTxOutL
                        .~ inject (Coin locked)
                )
    in  max adjusted (Coin locked)
