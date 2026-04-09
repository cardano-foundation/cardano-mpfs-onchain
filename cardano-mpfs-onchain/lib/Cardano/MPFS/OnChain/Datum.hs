module Cardano.MPFS.OnChain.Datum
    ( mkInlineDatum
    , extractCageDatum
    , toPlcData
    , toLedgerData
    ) where

import Cardano.Ledger.Api.Scripts.Data
    ( Data (..)
    , Datum (..)
    , binaryDataToData
    , dataToBinaryData
    )
import Cardano.Ledger.Api.Tx.Out
    ( TxOut
    , datumTxOutL
    )
import Cardano.Ledger.Conway (ConwayEra)
import Lens.Micro ((^.))
import PlutusCore.Data qualified as PLC
import PlutusTx.Builtins.Internal
    ( BuiltinData (..)
    )
import PlutusTx.IsData.Class
    ( FromData (..)
    , ToData (..)
    )

import Cardano.MPFS.OnChain.Types (CageDatum)

toPlcData :: (ToData a) => a -> PLC.Data
toPlcData x =
    let BuiltinData d = toBuiltinData x in d

toLedgerData
    :: (ToData a) => a -> Data ConwayEra
toLedgerData = Data . toPlcData

mkInlineDatum :: PLC.Data -> Datum ConwayEra
mkInlineDatum d =
    Datum
        $ dataToBinaryData
            (Data d :: Data ConwayEra)

extractCageDatum
    :: TxOut ConwayEra -> Maybe CageDatum
extractCageDatum txOut =
    case txOut ^. datumTxOutL of
        Datum bd ->
            let Data plcData =
                    binaryDataToData bd
            in  fromBuiltinData (BuiltinData plcData)
        _ -> Nothing
