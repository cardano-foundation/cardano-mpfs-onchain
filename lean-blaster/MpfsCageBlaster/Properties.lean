import CardanoLedgerApi.V3
import MpfsCageBlaster.Scripts
import Blaster

namespace MpfsCageBlaster.Properties

open CardanoLedgerApi.V3
open MpfsCageBlaster.Scripts
open PlutusCore.Data (Data)
open PlutusCore.Integer (Integer)
open PlutusCore.UPLC.Utils

def ownSpendingDatum : ScriptContext → Option Data
  | ⟨_, _, .SpendingScript _ datum⟩ => datum
  | _ => none

def hasNoSpendingDatum (ctx : ScriptContext) : Prop :=
  ownSpendingDatum ctx = none

def hasRequestDatum (ctx : ScriptContext) : Prop :=
  match ownSpendingDatum ctx with
  | some (.Constr 0 [_]) => True
  | _ => False

def hasStateDatum (ctx : ScriptContext) : Prop :=
  match ownSpendingDatum ctx with
  | some (.Constr 1 [_]) => True
  | _ => False

def isEndRedeemer (ctx : ScriptContext) : Prop :=
  match ctx.scriptContextRedeemer with
  | .Constr 0 [] => True
  | _ => False

def isContributeRedeemer (ctx : ScriptContext) : Prop :=
  match ctx.scriptContextRedeemer with
  | .Constr 1 [_] => True
  | _ => False

def isModifyRedeemer (ctx : ScriptContext) : Prop :=
  match ctx.scriptContextRedeemer with
  | .Constr 2 [_] => True
  | _ => False

def isRetractRedeemer (ctx : ScriptContext) : Prop :=
  match ctx.scriptContextRedeemer with
  | .Constr 3 [_] => True
  | _ => False

def isSweepRedeemer (ctx : ScriptContext) : Prop :=
  match ctx.scriptContextRedeemer with
  | .Constr 4 [_] => True
  | _ => False

def isStateSpendRedeemer (ctx : ScriptContext) : Prop :=
  isEndRedeemer ctx ∨ isModifyRedeemer ctx

def isRequestSpendRedeemer (ctx : ScriptContext) : Prop :=
  isContributeRedeemer ctx ∨ isRetractRedeemer ctx ∨ isSweepRedeemer ctx

def isKnownUpdateRedeemer (ctx : ScriptContext) : Prop :=
  isStateSpendRedeemer ctx ∨ isRequestSpendRedeemer ctx

def isUnknownUpdateRedeemer (ctx : ScriptContext) : Prop :=
  match ctx.scriptContextRedeemer with
  | .Constr 0 [] => False
  | .Constr 1 [_] => False
  | .Constr 2 [_] => False
  | .Constr 3 [_] => False
  | .Constr 4 [_] => False
  | _ => True

def isMintingRedeemer (ctx : ScriptContext) : Prop :=
  match ctx.scriptContextRedeemer with
  | .Constr 0 [_] => True
  | _ => False

def isMigratingRedeemer (ctx : ScriptContext) : Prop :=
  match ctx.scriptContextRedeemer with
  | .Constr 1 [_] => True
  | _ => False

def isBurningRedeemer (ctx : ScriptContext) : Prop :=
  match ctx.scriptContextRedeemer with
  | .Constr 2 [_] => True
  | _ => False

def isKnownMintRedeemer (ctx : ScriptContext) : Prop :=
  isMintingRedeemer ctx ∨ isMigratingRedeemer ctx ∨ isBurningRedeemer ctx

def isUnknownMintRedeemer (ctx : ScriptContext) : Prop :=
  match ctx.scriptContextRedeemer with
  | .Constr 0 [_] => False
  | .Constr 1 [_] => False
  | .Constr 2 [_] => False
  | _ => True

def stateOwnerSigned (ctx : ScriptContext) : Prop :=
  match ownSpendingDatum ctx with
  | some (.Constr 1 [.Constr 0 [.B owner, _, _, _, _]]) =>
      txSignedBy owner ctx.scriptContextTxInfo
  | _ => False

def stateOwnerNotSigned (ctx : ScriptContext) : Prop :=
  match ownSpendingDatum ctx with
  | some (.Constr 1 [.Constr 0 [.B owner, _, _, _, _]]) =>
      ¬ txSignedBy owner ctx.scriptContextTxInfo
  | _ => False

def requestOwnerSigned (ctx : ScriptContext) : Prop :=
  match ownSpendingDatum ctx with
  | some (.Constr 0 [.Constr 0 [_, .B owner, _, _, _, _]]) =>
      txSignedBy owner ctx.scriptContextTxInfo
  | _ => False

def requestOwnerNotSigned (ctx : ScriptContext) : Prop :=
  match ownSpendingDatum ctx with
  | some (.Constr 0 [.Constr 0 [_, .B owner, _, _, _, _]]) =>
      ¬ txSignedBy owner ctx.scriptContextTxInfo
  | _ => False

/-! State minting policy properties. -/

/-- Successful state-policy minting uses one of the declared mint redeemers. -/
theorem state_mint_successful_imp_known_redeemer :
    ∀ (version : Integer) (ctx : ScriptContext),
      isMintingScriptInfo ctx →
      isSuccessful (appliedMpfStateMint.prop version ctx) →
      isKnownMintRedeemer ctx := by
  blaster

/-- Unknown mint redeemer constructors are rejected by the state policy. -/
theorem state_mint_unknown_redeemer_errors :
    ∀ (version : Integer) (ctx : ScriptContext),
      isMintingScriptInfo ctx →
      isUnknownMintRedeemer ctx →
      isUnsuccessful (appliedMpfStateMint.prop version ctx) := by
  blaster

/-- The minting entrypoint cannot succeed when evaluated as a non-minting script. -/
theorem state_mint_successful_imp_minting_script_info :
    ∀ (version : Integer) (ctx : ScriptContext),
      isSuccessful (appliedMpfStateMint.prop version ctx) →
      isMintingScriptInfo ctx := by
  blaster

/-! State validator spending properties. -/

/-- Successful state spends use only `End` or `Modify`. -/
theorem state_spend_successful_imp_state_redeemer :
    ∀ (version : Integer) (ctx : ScriptContext),
      isSpendingScriptInfo ctx →
      isSuccessful (appliedMpfStateSpend.prop version ctx) →
      isStateSpendRedeemer ctx := by
  blaster

/-- State spends require an inline state datum on the spent UTxO. -/
theorem state_spend_no_datum_errors :
    ∀ (version : Integer) (ctx : ScriptContext),
      isSpendingScriptInfo ctx →
      hasNoSpendingDatum ctx →
      isUnsuccessful (appliedMpfStateSpend.prop version ctx) := by
  blaster

/-- Unknown update redeemer constructors are rejected by the state validator. -/
theorem state_spend_unknown_redeemer_errors :
    ∀ (version : Integer) (ctx : ScriptContext),
      isSpendingScriptInfo ctx →
      isUnknownUpdateRedeemer ctx →
      isUnsuccessful (appliedMpfStateSpend.prop version ctx) := by
  blaster

/-- `Contribute` is a request-validator operation, not a state spend. -/
theorem state_spend_contribute_redeemer_errors :
    ∀ (version : Integer) (ctx : ScriptContext),
      isContributeRedeemer ctx →
      isUnsuccessful (appliedMpfStateSpend.prop version ctx) := by
  blaster

/-- `Retract` is a request-validator operation, not a state spend. -/
theorem state_spend_retract_redeemer_errors :
    ∀ (version : Integer) (ctx : ScriptContext),
      isRetractRedeemer ctx →
      isUnsuccessful (appliedMpfStateSpend.prop version ctx) := by
  blaster

/-- `Sweep` is a request-validator operation, not a state spend. -/
theorem state_spend_sweep_redeemer_errors :
    ∀ (version : Integer) (ctx : ScriptContext),
      isSweepRedeemer ctx →
      isUnsuccessful (appliedMpfStateSpend.prop version ctx) := by
  blaster

/-- `End` is a State UTxO operation, not a Request UTxO operation. -/
theorem state_spend_end_request_datum_errors :
    ∀ (version : Integer) (ctx : ScriptContext),
      isEndRedeemer ctx →
      hasRequestDatum ctx →
      isUnsuccessful (appliedMpfStateSpend.prop version ctx) := by
  blaster

/-- `Modify` is a State UTxO operation, not a Request UTxO operation. -/
theorem state_spend_modify_request_datum_errors :
    ∀ (version : Integer) (ctx : ScriptContext),
      isModifyRedeemer ctx →
      hasRequestDatum ctx →
      isUnsuccessful (appliedMpfStateSpend.prop version ctx) := by
  blaster

/-- Successful `End` spends a State UTxO. -/
theorem state_spend_end_successful_imp_state_datum :
    ∀ (version : Integer) (ctx : ScriptContext),
      isSpendingScriptInfo ctx →
      isEndRedeemer ctx →
      isSuccessful (appliedMpfStateSpend.prop version ctx) →
      hasStateDatum ctx := by
  blaster

/-- Successful `Modify` spends a State UTxO. -/
theorem state_spend_modify_successful_imp_state_datum :
    ∀ (version : Integer) (ctx : ScriptContext),
      isSpendingScriptInfo ctx →
      isModifyRedeemer ctx →
      isSuccessful (appliedMpfStateSpend.prop version ctx) →
      hasStateDatum ctx := by
  blaster

/-- `End` can only succeed when the State owner signed the transaction. -/
theorem state_spend_end_successful_imp_owner_signed :
    ∀ (version : Integer) (ctx : ScriptContext),
      isEndRedeemer ctx →
      isSuccessful (appliedMpfStateSpend.prop version ctx) →
      stateOwnerSigned ctx := by
  blaster

/-- `Modify` can only succeed when the State owner signed the transaction. -/
theorem state_spend_modify_successful_imp_owner_signed :
    ∀ (version : Integer) (ctx : ScriptContext),
      isModifyRedeemer ctx →
      isSuccessful (appliedMpfStateSpend.prop version ctx) →
      stateOwnerSigned ctx := by
  blaster

/-- `End` rejects a well-formed State datum when the State owner did not sign. -/
theorem state_spend_end_owner_not_signed_errors :
    ∀ (version : Integer) (ctx : ScriptContext),
      isEndRedeemer ctx →
      stateOwnerNotSigned ctx →
      isUnsuccessful (appliedMpfStateSpend.prop version ctx) := by
  blaster

/-- `Modify` rejects a well-formed State datum when the State owner did not sign. -/
theorem state_spend_modify_owner_not_signed_errors :
    ∀ (version : Integer) (ctx : ScriptContext),
      isModifyRedeemer ctx →
      stateOwnerNotSigned ctx →
      isUnsuccessful (appliedMpfStateSpend.prop version ctx) := by
  blaster

/-! Parameterized request validator spending properties. -/

/-- Successful request spends use only `Contribute`, `Retract`, or `Sweep`. -/
theorem request_spend_successful_imp_request_redeemer :
    ∀ (statePolicyId cageTokenName : Data) (version : Integer) (ctx : ScriptContext),
      isSpendingScriptInfo ctx →
      isSuccessful (appliedMpfRequestSpend.prop statePolicyId cageTokenName version ctx) →
      isRequestSpendRedeemer ctx := by
  blaster

/-- Unknown update redeemer constructors are rejected by the request validator. -/
theorem request_spend_unknown_redeemer_errors :
    ∀ (statePolicyId cageTokenName : Data) (version : Integer) (ctx : ScriptContext),
      isSpendingScriptInfo ctx →
      isUnknownUpdateRedeemer ctx →
      isUnsuccessful (appliedMpfRequestSpend.prop statePolicyId cageTokenName version ctx) := by
  blaster

/-- `End` is a state-validator operation, not a request spend. -/
theorem request_spend_end_redeemer_errors :
    ∀ (statePolicyId cageTokenName : Data) (version : Integer) (ctx : ScriptContext),
      isEndRedeemer ctx →
      isUnsuccessful (appliedMpfRequestSpend.prop statePolicyId cageTokenName version ctx) := by
  blaster

/-- `Modify` is a state-validator operation, not a request spend. -/
theorem request_spend_modify_redeemer_errors :
    ∀ (statePolicyId cageTokenName : Data) (version : Integer) (ctx : ScriptContext),
      isModifyRedeemer ctx →
      isUnsuccessful (appliedMpfRequestSpend.prop statePolicyId cageTokenName version ctx) := by
  blaster

/-- `Contribute` requires a Request datum. -/
theorem request_spend_contribute_no_datum_errors :
    ∀ (statePolicyId cageTokenName : Data) (version : Integer) (ctx : ScriptContext),
      isContributeRedeemer ctx →
      hasNoSpendingDatum ctx →
      isUnsuccessful (appliedMpfRequestSpend.prop statePolicyId cageTokenName version ctx) := by
  blaster

/-- `Retract` requires a Request datum. -/
theorem request_spend_retract_no_datum_errors :
    ∀ (statePolicyId cageTokenName : Data) (version : Integer) (ctx : ScriptContext),
      isRetractRedeemer ctx →
      hasNoSpendingDatum ctx →
      isUnsuccessful (appliedMpfRequestSpend.prop statePolicyId cageTokenName version ctx) := by
  blaster

/-- `Contribute` is a Request UTxO operation, not a State UTxO operation. -/
theorem request_spend_contribute_state_datum_errors :
    ∀ (statePolicyId cageTokenName : Data) (version : Integer) (ctx : ScriptContext),
      isContributeRedeemer ctx →
      hasStateDatum ctx →
      isUnsuccessful (appliedMpfRequestSpend.prop statePolicyId cageTokenName version ctx) := by
  blaster

/-- `Retract` is a Request UTxO operation, not a State UTxO operation. -/
theorem request_spend_retract_state_datum_errors :
    ∀ (statePolicyId cageTokenName : Data) (version : Integer) (ctx : ScriptContext),
      isRetractRedeemer ctx →
      hasStateDatum ctx →
      isUnsuccessful (appliedMpfRequestSpend.prop statePolicyId cageTokenName version ctx) := by
  blaster

/-- Successful `Contribute` spends a Request UTxO. -/
theorem request_spend_contribute_successful_imp_request_datum :
    ∀ (statePolicyId cageTokenName : Data) (version : Integer) (ctx : ScriptContext),
      isSpendingScriptInfo ctx →
      isContributeRedeemer ctx →
      isSuccessful (appliedMpfRequestSpend.prop statePolicyId cageTokenName version ctx) →
      hasRequestDatum ctx := by
  blaster

/-- Successful `Retract` spends a Request UTxO. -/
theorem request_spend_retract_successful_imp_request_datum :
    ∀ (statePolicyId cageTokenName : Data) (version : Integer) (ctx : ScriptContext),
      isSpendingScriptInfo ctx →
      isRetractRedeemer ctx →
      isSuccessful (appliedMpfRequestSpend.prop statePolicyId cageTokenName version ctx) →
      hasRequestDatum ctx := by
  blaster

/-- `Retract` can only succeed when the Request owner signed the transaction. -/
theorem request_spend_retract_successful_imp_request_owner_signed :
    ∀ (statePolicyId cageTokenName : Data) (version : Integer) (ctx : ScriptContext),
      isRetractRedeemer ctx →
      isSuccessful (appliedMpfRequestSpend.prop statePolicyId cageTokenName version ctx) →
      requestOwnerSigned ctx := by
  blaster

/-- `Retract` rejects a well-formed Request datum when the Request owner did not sign. -/
theorem request_spend_retract_owner_not_signed_errors :
    ∀ (statePolicyId cageTokenName : Data) (version : Integer) (ctx : ScriptContext),
      isRetractRedeemer ctx →
      requestOwnerNotSigned ctx →
      isUnsuccessful (appliedMpfRequestSpend.prop statePolicyId cageTokenName version ctx) := by
  blaster

end MpfsCageBlaster.Properties
