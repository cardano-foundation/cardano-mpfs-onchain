{-# LANGUAGE OverloadedStrings #-}

module Cardano.MPFS.OnChain.AssetName
    ( computeAssetName
    ) where

import Cardano.Ledger.TxIn (TxId (..), TxIn (..))
import Cardano.Ledger.BaseTypes (TxIx (..))
import Cardano.Ledger.Core (extractHash)
import Cardano.Crypto.Hash (hashToBytes)
import Crypto.Hash (Digest, SHA256, hash)
import Data.Bits (shiftR)
import Data.ByteArray (convert)
import Data.ByteString (ByteString)
import Data.ByteString qualified as BS
import Data.Word (Word16)

computeAssetName :: TxIn -> ByteString
computeAssetName (TxIn (TxId h) (TxIx ix)) =
    convert digest
  where
    digest :: Digest SHA256
    digest = hash (txIdBytes <> indexBytes)

    txIdBytes :: ByteString
    txIdBytes = hashToBytes (extractHash h)

    indexBytes :: ByteString
    indexBytes =
        let w16 = fromIntegral ix :: Word16
        in  BS.pack
                [ fromIntegral (w16 `shiftR` 8)
                , fromIntegral w16
                ]
