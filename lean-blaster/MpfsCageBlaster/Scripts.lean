import PlutusCore.UPLC
import CardanoLedgerApi.V3
import Blaster

namespace MpfsCageBlaster.Scripts

open CardanoLedgerApi.IsData.Class (toTerm)
open CardanoLedgerApi.V3 (ScriptContext mintingInputs spendingInputs)
open PlutusCore.Integer (Integer)
open PlutusCore.Data (Data)
open PlutusCore.UPLC.Term (Term)

#import_uplc mpfStateMint PlutusV3 single_cbor_hex "generated/mpf_state_mint.flat"
#import_uplc mpfStateSpend PlutusV3 single_cbor_hex "generated/mpf_state_spend.flat"
#import_uplc mpfRequestSpend PlutusV3 single_cbor_hex "generated/mpf_request_spend.flat"

def mpfStateMintInputs (version : Integer) (ctx : ScriptContext) : List Term :=
  toTerm version :: mintingInputs ctx

def mpfStateSpendInputs (version : Integer) (ctx : ScriptContext) : List Term :=
  toTerm version :: spendingInputs ctx

def mpfRequestSpendInputs
    (statePolicyId cageTokenName : Data)
    (version : Integer)
    (ctx : ScriptContext) : List Term :=
  toTerm statePolicyId :: toTerm cageTokenName :: toTerm version :: spendingInputs ctx

#prep_uplc appliedMpfStateMint mpfStateMint mpfStateMintInputs 500
#prep_uplc appliedMpfStateSpend mpfStateSpend mpfStateSpendInputs 500
#prep_uplc appliedMpfRequestSpend mpfRequestSpend mpfRequestSpendInputs 500

end MpfsCageBlaster.Scripts
