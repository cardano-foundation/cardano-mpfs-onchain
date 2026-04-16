{- |
Module      : Cardano.MPFS.Cage.Config
Description : Configuration for cage transaction builders
License     : Apache-2.0

Configuration record for the cage transaction
builders. Holds the applied PlutusV3 script bytes,
computed script hash, default token parameters, and
network.
-}
module Cardano.MPFS.Cage.Config (
    -- * Configuration
    CageConfig (..),
) where

import Data.ByteString.Short (ShortByteString)

import Cardano.Ledger.BaseTypes (Network)
import Cardano.Ledger.Hashes (ScriptHash)

import Cardano.MPFS.Cage.Ledger (Coin)

{- | Configuration for the cage script transaction
builders.

The 'cageScriptBytes' field holds the raw
flat-encoded UPLC script (after parameter
application). The 'cfgScriptHash' is the
hash of the deserialized script.
-}
data CageConfig = CageConfig
    { cageScriptBytes :: !ShortByteString
    -- ^ PlutusV3 script bytes (applied parameters)
    , cfgScriptHash :: !ScriptHash
    -- ^ Hash of the PlutusV3 script
    , defaultProcessTime :: !Integer
    -- ^ Phase 1 window (ms) for oracle processing
    , defaultRetractTime :: !Integer
    -- ^ Phase 2 window (ms) for requester retract
    , defaultTip :: !Coin
    -- ^ Default max fee for newly booted tokens
    , network :: !Network
    -- ^ Target network (Mainnet or Testnet)
    }
