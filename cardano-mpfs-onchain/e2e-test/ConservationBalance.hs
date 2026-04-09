{- |
Module      : ConservationBalance
Description : Fee-output fixed point for conservation-aware transactions
License     : Apache-2.0

In standard transaction balancing ('balanceTx'), the fee is
computed from the transaction size and the outputs are fixed.
This works when outputs are independent of the fee.

In conservation-aware transactions (e.g., Cardano validators
with @sum(refunds) = sum(inputs) - fee - N * tip@), the output
values depend on the fee, and the fee depends on the output
values (via tx size). This module provides 'balanceFeeLoop',
which iterates both until they converge.

The iteration is fast (2–3 rounds) because a fee change of
@Δf@ only changes output encoding by a few bytes, which
changes the fee by @≈ 44 × (bytes changed)@ lovelace — well
under @Δf@.

Intended for upstreaming to @cardano-node-clients@ alongside
'Cardano.Node.Client.Balance.balanceTx'.
-}
module ConservationBalance
    ( balanceFeeLoop
    , FeeLoopError (..)
    ) where

import Lens.Micro ((&), (.~))

import Cardano.Ledger.Api.Tx
    ( Tx
    , bodyTxL
    , estimateMinFeeTx
    )
import Cardano.Ledger.Api.Tx.Body
    ( feeTxBodyL
    , outputsTxBodyL
    )
import Cardano.Ledger.Api.Tx.Out (TxOut)
import Cardano.Ledger.Coin (Coin (..))
import Cardano.Ledger.Conway (ConwayEra)
import Cardano.Ledger.Core (PParams)
import Data.Sequence.Strict (StrictSeq)

data FeeLoopError
    = -- | Fee did not converge within the iteration limit.
      FeeDidNotConverge
    | -- | The output function rejected the fee (e.g., negative refund).
      OutputError !String
    deriving (Eq, Show)

{- | Find the fee fixed point for a transaction where
output values depend on the fee.

@
  let mkOutputs fee =
        let refund = inputValue - fee - tip
        in  Right [stateOutput, mkRefundOutput refund]
  in  balanceFeeLoop pp mkOutputs 1 templateTx
@

The template transaction must have inputs, collateral,
scripts, and redeemers already set. The fee and outputs
will be overwritten by the loop.

Unlike 'balanceTx', this does NOT add inputs or a change
output. The fee is paid from the existing inputs; any
excess (converged fee minus actual minimum) goes to
the Cardano treasury.
-}
balanceFeeLoop
    :: PParams ConwayEra
    -> (Coin -> Either String (StrictSeq (TxOut ConwayEra)))
    -- ^ Compute outputs for a given fee. Return
    --   'Left' to abort (e.g., insufficient funds).
    -> Int
    -- ^ Number of key witnesses to assume for
    --   fee estimation.
    -> Tx ConwayEra
    -- ^ Template transaction.
    -> Either FeeLoopError (Tx ConwayEra)
balanceFeeLoop pp mkOutputs numWitnesses tx =
    go 0 (Coin 0)
  where
    go !n currentFee
        | n > (10 :: Int) = Left FeeDidNotConverge
        | otherwise =
            case mkOutputs currentFee of
                Left msg -> Left (OutputError msg)
                Right outs ->
                    let candidate =
                            tx
                                & bodyTxL . outputsTxBodyL
                                    .~ outs
                                & bodyTxL . feeTxBodyL
                                    .~ currentFee
                        newFee =
                            estimateMinFeeTx
                                pp
                                candidate
                                numWitnesses
                                0 -- boot witnesses
                                0 -- ref script bytes
                    in  if newFee <= currentFee
                            then Right candidate
                            else go (n + 1) newFee
