{- |
Module      : Cardano.MPFS.Cage.Config
Description : Configuration for cage transaction builders
License     : Apache-2.0

Configuration record for the cage transaction
builders. Holds the applied PlutusV3 script bytes,
computed script hash, the seed @OutputReference@
the validator was parameterized with, default token
parameters, and network.

After the introduction of per-token addressing, a
'CageConfig' is /per-cage/: one instance per minted
token, each with its own seed-derived script hash
and address. Construct one via 'applyOutputRef'
applied to the unparameterized blueprint bytes.
-}
module Cardano.MPFS.Cage.Config (
    -- * Configuration
    CageConfig (..),
) where

import Data.ByteString.Short (ShortByteString)

import Cardano.Ledger.BaseTypes (Network)
import Cardano.Ledger.Hashes (ScriptHash)

import Cardano.MPFS.Cage.Ledger (Coin)
import Cardano.MPFS.Cage.Types (OnChainTxOutRef)

{- | Configuration for the cage script transaction
builders.

The 'cageScriptBytes' field holds the raw
flat-encoded UPLC script after parameter
application. The 'cfgScriptHash' is the hash of the
deserialized script. The 'cageSeed' records the
@OutputReference@ that was applied as the validator
parameter — used by 'bootTokenImpl' as the UTxO to
consume in the mint transaction (must be present in
the boot caller's wallet).
-}
data CageConfig = CageConfig
    { cageScriptBytes :: !ShortByteString
    -- ^ PlutusV3 script bytes (applied parameters)
    , cfgScriptHash :: !ScriptHash
    -- ^ Hash of the PlutusV3 script
    , cageSeed :: !OnChainTxOutRef
    {- ^ Seed @OutputReference@ the validator was
    parameterized with. Boot consumes this UTxO.
    -}
    , defaultProcessTime :: !Integer
    -- ^ Phase 1 window (ms) for oracle processing
    , defaultRetractTime :: !Integer
    -- ^ Phase 2 window (ms) for requester retract
    , defaultTip :: !Coin
    -- ^ Default max fee for newly booted tokens
    , network :: !Network
    -- ^ Target network (Mainnet or Testnet)
    }
