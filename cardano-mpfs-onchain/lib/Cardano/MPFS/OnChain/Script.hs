{-# LANGUAGE OverloadedStrings #-}

module Cardano.MPFS.OnChain.Script
    ( -- * Blueprint types
      Blueprint (..)
    , Validator (..)

      -- * Loading
    , loadBlueprint

      -- * Compiled code extraction
    , extractCompiledCode

      -- * Parameter application
    , applyVersion

      -- * Script construction
    , mkCageScript
    , computeScriptHash
    , cageScriptAddr
    , cagePolicyId
    ) where

import Cardano.Ledger.Address (Addr (..))
import Cardano.Ledger.Alonzo.Scripts
    ( fromPlutusScript
    , mkPlutusScript
    )
import Cardano.Ledger.BaseTypes (Network)
import Cardano.Ledger.Conway (ConwayEra)
import Cardano.Ledger.Core
    ( Script
    , hashScript
    )
import Cardano.Ledger.Credential
    ( Credential (..)
    , StakeReference (..)
    )
import Cardano.Ledger.Hashes (ScriptHash)
import Cardano.Ledger.Mary.Value (PolicyID (..))
import Cardano.Ledger.Plutus.Language
    ( Language (PlutusV3)
    , Plutus (..)
    , PlutusBinary (..)
    )
import Data.Aeson
    ( FromJSON (..)
    , withObject
    , (.:)
    , (.:?)
    )
import Data.Aeson qualified as Aeson
import Data.ByteString qualified as BS
import Data.ByteString.Short qualified as SBS
import Data.Char (isDigit)
import Data.Text (Text)
import Data.Text qualified as T
import Data.Word (Word8)
import PlutusCore qualified as PLC
import PlutusCore.Data (Data (..))
import PlutusLedgerApi.V3
    ( serialiseUPLC
    , uncheckedDeserialiseUPLC
    )
import UntypedPlutusCore
    ( Program (..)
    , applyProgram
    )
import UntypedPlutusCore qualified as UPLC

data Validator = Validator
    { vTitle :: Text
    , vHash :: Text
    , vCompiledCode :: Maybe Text
    }
    deriving stock (Show, Eq)

data Blueprint = Blueprint
    { validators :: [Validator]
    }
    deriving stock (Show, Eq)

instance FromJSON Validator where
    parseJSON = withObject "Validator" $ \o -> do
        title <- o .: "title"
        h <- o .: "hash"
        code <- o .:? "compiledCode"
        pure
            Validator
                { vTitle = title
                , vHash = h
                , vCompiledCode = code
                }

instance FromJSON Blueprint where
    parseJSON = withObject "Blueprint" $ \o -> do
        vs <- o .: "validators"
        pure Blueprint{validators = vs}

loadBlueprint
    :: FilePath -> IO (Either String Blueprint)
loadBlueprint path = do
    bs <- BS.readFile path
    pure $ Aeson.eitherDecodeStrict' bs

extractCompiledCode
    :: Text -> Blueprint -> Maybe SBS.ShortByteString
extractCompiledCode prefix bp = do
    v <-
        case filter
            (T.isPrefixOf prefix . vTitle)
            (validators bp) of
            (x : _) -> Just x
            [] -> Nothing
    hex <- vCompiledCode v
    SBS.toShort <$> decodeHex hex

decodeHex :: Text -> Maybe BS.ByteString
decodeHex t
    | odd (T.length t) = Nothing
    | otherwise =
        BS.pack <$> go (T.unpack t)
  where
    go [] = Just []
    go (a : b : rest) = do
        hi <- hexDigit a
        lo <- hexDigit b
        (hi * 16 + lo :) <$> go rest
    go _ = Nothing

    hexDigit :: Char -> Maybe Word8
    hexDigit c
        | isDigit c =
            Just
                $ fromIntegral
                    (fromEnum c - fromEnum '0')
        | c >= 'a' && c <= 'f' =
            Just
                $ fromIntegral
                    (fromEnum c - fromEnum 'a' + 10)
        | c >= 'A' && c <= 'F' =
            Just
                $ fromIntegral
                    (fromEnum c - fromEnum 'A' + 10)
        | otherwise = Nothing

applyVersion
    :: Integer -> SBS.ShortByteString -> SBS.ShortByteString
applyVersion ver sbs =
    let prog = uncheckedDeserialiseUPLC sbs
        argProg =
            Program
                ()
                (progVer prog)
                ( UPLC.Constant
                    ()
                    ( PLC.Some
                        ( PLC.ValueOf
                            PLC.DefaultUniData
                            (I ver)
                        )
                    )
                )
        applied = case applyProgram prog argProg of
            Right p -> p
            Left e ->
                error
                    $ "applyVersion: "
                        <> show e
    in  serialiseUPLC applied
  where
    progVer (Program _ v _) = v

mkCageScript
    :: SBS.ShortByteString -> Script ConwayEra
mkCageScript sbs =
    let plutus =
            Plutus @PlutusV3
                $ PlutusBinary sbs
    in  case mkPlutusScript plutus of
            Just ps -> fromPlutusScript ps
            Nothing ->
                error
                    "mkCageScript: invalid \
                    \PlutusV3 script"

computeScriptHash
    :: SBS.ShortByteString -> ScriptHash
computeScriptHash sbs =
    hashScript @ConwayEra (mkCageScript sbs)

cagePolicyId :: SBS.ShortByteString -> PolicyID
cagePolicyId = PolicyID . computeScriptHash

cageScriptAddr
    :: SBS.ShortByteString -> Network -> Addr
cageScriptAddr sbs net =
    Addr
        net
        (ScriptHashObj $ computeScriptHash sbs)
        StakeRefNull
