-- |
-- Module      : Cardano.MPFS.Cage.TxBuilder.End
-- Description : End token (burn) transaction
-- License     : Apache-2.0
--
-- Builds the burn transaction that retires a cage
-- token. Consumes the State UTxO with an @End@
-- spending redeemer, mints -1 with @Burning@, and
-- returns remaining ADA to the owner.
module Cardano.MPFS.Cage.TxBuilder.End
    ( endTokenImpl
    ) where

import Data.List (sortOn)
import Data.Map.Strict qualified as Map
import Data.Ord (Down (..))
import Data.Set qualified as Set
import Lens.Micro ((&), (.~), (^.))

import Cardano.Ledger.Address (Addr)
import Cardano.Ledger.Alonzo.Scripts (AsIx (..))
import Cardano.Ledger.Alonzo.TxBody
    ( reqSignerHashesTxBodyL
    , scriptIntegrityHashTxBodyL
    )
import Cardano.Ledger.Api.Tx
    ( Tx
    , mkBasicTx
    , witsTxL
    )
import Cardano.Ledger.Api.Tx.Body
    ( collateralInputsTxBodyL
    , inputsTxBodyL
    , mintTxBodyL
    , mkBasicTxBody
    )
import Cardano.Ledger.Api.Tx.Out (coinTxOutL)
import Cardano.Ledger.Api.Tx.Wits
    ( Redeemers (..)
    , rdmrsTxWitsL
    , scriptTxWitsL
    )
import Cardano.Ledger.Conway.Scripts
    ( ConwayPlutusPurpose (..)
    )
import Cardano.Ledger.Core (hashScript)
import Cardano.Ledger.Mary.Value
    ( MultiAsset (..)
    )
import PlutusTx.Builtins.Internal
    ( BuiltinByteString (..)
    )

import Cardano.MPFS.Cage.Config
    ( CageConfig (..)
    )
import Cardano.MPFS.Cage.Types
    ( CageDatum (..)
    , MintRedeemer (..)
    , OnChainTokenState (..)
    , UpdateRedeemer (..)
    )
import Cardano.MPFS.Cage.Provider (Provider (..))
import Cardano.MPFS.Cage.TxBuilder.Internal
import Cardano.MPFS.Cage.Ledger
    ( ConwayEra
    , TokenId (..)
    )

-- | Build an end-token (burn) transaction.
endTokenImpl
    :: CageConfig
    -> Provider IO
    -> TokenId
    -> Addr
    -> IO (Tx ConwayEra)
endTokenImpl cfg prov tid addr = do
    let scriptAddr =
            cageAddrFromCfg cfg (network cfg)
    cageUtxos <- queryUTxOs prov scriptAddr
    let policyId = cagePolicyIdFromCfg cfg
    stateUtxo <-
        case findStateUtxo
            policyId
            tid
            cageUtxos of
            Nothing ->
                error
                    "endToken: state UTxO \
                    \not found"
            Just x -> pure x
    let (stateIn, stateOut) = stateUtxo
    let OnChainTokenState
            { stateOwner =
                BuiltinByteString ownerBs
            } = case extractCageDatum stateOut of
                Just (StateDatum s) -> s
                _ ->
                    error
                        "endToken: invalid \
                        \state datum"
        ownerKh = addrWitnessKeyHash ownerBs
    pp <- queryProtocolParams prov
    walletUtxos <- queryUTxOs prov addr
    feeUtxo <- case sortOn
        (Down . (^. coinTxOutL) . snd)
        walletUtxos of
        [] -> error "endToken: no UTxOs"
        (u : _) -> pure u
    let assetName = unTokenId tid
        burnMA =
            MultiAsset
                $ Map.singleton policyId
                $ Map.singleton assetName (-1)
    let script = mkCageScript cfg
        scriptHash = hashScript script
        allInputs =
            Set.fromList [stateIn, fst feeUtxo]
        stateIx =
            spendingIndex stateIn allInputs
        spendRedeemer = End
        mintRedeemer = Burning
        redeemers =
            Redeemers
                $ Map.fromList
                    [
                        ( ConwaySpending
                            (AsIx stateIx)
                        ,
                            ( toLedgerData
                                spendRedeemer
                            , placeholderExUnits
                            )
                        )
                    ,
                        ( ConwayMinting (AsIx 0)
                        ,
                            ( toLedgerData
                                mintRedeemer
                            , placeholderExUnits
                            )
                        )
                    ]
        integrity =
            computeScriptIntegrity pp redeemers
    let body =
            mkBasicTxBody
                & inputsTxBodyL
                    .~ Set.singleton stateIn
                & mintTxBodyL .~ burnMA
                & collateralInputsTxBodyL
                    .~ Set.singleton
                        (fst feeUtxo)
                & reqSignerHashesTxBodyL
                    .~ Set.singleton ownerKh
                & scriptIntegrityHashTxBodyL
                    .~ integrity
        tx =
            mkBasicTx body
                & witsTxL . scriptTxWitsL
                    .~ Map.singleton
                        scriptHash
                        script
                & witsTxL . rdmrsTxWitsL
                    .~ redeemers
    evaluateAndBalance
        prov
        pp
        [feeUtxo, stateUtxo]
        addr
        tx
