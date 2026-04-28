import MpfsCage.Lib

/-!
# MPFS Cage — Split State/Request Validator Logic

Formal model of the issue #49 validator split.

The state validator is a global policy/spend script. The request validator is
applied per cage with `(statePolicyId, cageToken)` parameters. Request spends
therefore authenticate the referenced state UTxO by both policy id and asset
name, not by asset name alone.
-/

abbrev Owner := String
abbrev OutputRef := String

/-- Transaction view needed by the split-validator authorization rules. -/
structure TxView where
  inputs : List OutputRef
  modifyInputs : List OutputRef
  referenceInputs : List OutputRef
  signers : List Owner

/-- The state UTxO identity and owner data needed by request validation. -/
structure StateUTxO where
  ref : OutputRef
  policy : PolicyId
  cageToken : AssetName
  owner : Owner
  tip : Int

/-- Request datum fields relevant to validator split and sweep protection. -/
structure RequestUTxO where
  cageToken : AssetName
  requestOwner : Owner
  tip : Int
  lovelace : Int

/-- State authentication by exact policy and asset. -/
def carriesStateToken
    (statePolicyId : PolicyId)
    (cageToken : AssetName)
    (state : StateUTxO) : Prop :=
  state.policy = statePolicyId ∧ state.cageToken = cageToken

/-- A state reference usable by `Contribute`: regular inputs only. -/
def stateConsumed (tx : TxView) (state : StateUTxO) : Prop :=
  state.ref ∈ tx.inputs

/-- A state reference spent specifically by state `Modify`. -/
def stateSpentWithModify (tx : TxView) (state : StateUTxO) : Prop :=
  state.ref ∈ tx.modifyInputs

/-- A state reference usable by `Retract` and `Sweep`: regular or reference
    inputs. -/
def stateVisible (tx : TxView) (state : StateUTxO) : Prop :=
  state.ref ∈ tx.inputs ∨ state.ref ∈ tx.referenceInputs

/-- Request-side state authentication for `Contribute`. Phase checks are
    intentionally factored out and proved in `Phases.lean`. -/
def contributeAuthenticates
    (statePolicyId : PolicyId)
    (cageToken : AssetName)
    (tx : TxView)
    (state : StateUTxO)
    (request : RequestUTxO) : Prop :=
  request.cageToken = cageToken ∧
  stateConsumed tx state ∧
  stateSpentWithModify tx state ∧
  carriesStateToken statePolicyId cageToken state

/-- Request-side state authentication for `Retract`. -/
def retractAuthenticates
    (statePolicyId : PolicyId)
    (cageToken : AssetName)
    (tx : TxView)
    (state : StateUTxO)
    (request : RequestUTxO) : Prop :=
  request.cageToken = cageToken ∧
  stateVisible tx state ∧
  carriesStateToken statePolicyId cageToken state

/-- A request is protected from owner sweep exactly when state `Modify` can
    process it for the currently referenced cage state. -/
def processableRequest
    (cageToken : AssetName)
    (state : StateUTxO)
    (request : RequestUTxO) : Prop :=
  request.cageToken = cageToken ∧
  request.tip = state.tip ∧
  state.tip ≤ request.lovelace

/-- Request-address sweep is allowed only for the state owner, against an
    authenticated visible state UTxO, and only when the spent request is not
    processable. -/
def sweepAllowed
    (statePolicyId : PolicyId)
    (cageToken : AssetName)
    (tx : TxView)
    (state : StateUTxO)
    (request : RequestUTxO) : Prop :=
  state.owner ∈ tx.signers ∧
  stateVisible tx state ∧
  carriesStateToken statePolicyId cageToken state ∧
  ¬ processableRequest cageToken state request

-- ============================================================
-- Theorems
-- ============================================================

/-- `Contribute` cannot use a reference-only state UTxO. This prevents a
    request from being consumed without state `Modify` also running the root
    and refund checks. -/
theorem contribute_rejects_reference_only_state
    (statePolicyId : PolicyId)
    (cageToken : AssetName)
    (tx : TxView)
    (state : StateUTxO)
    (request : RequestUTxO)
    (hNotInput : state.ref ∉ tx.inputs) :
    ¬ contributeAuthenticates statePolicyId cageToken tx state request := by
  intro h
  exact hNotInput h.2.1

/-- Authenticating only by asset name is insufficient: a same-asset state under
    a foreign policy is rejected. -/
theorem contribute_rejects_foreign_policy_state_same_asset
    (statePolicyId : PolicyId)
    (cageToken : AssetName)
    (tx : TxView)
    (state : StateUTxO)
    (request : RequestUTxO)
    (hForeign : state.policy ≠ statePolicyId) :
    ¬ contributeAuthenticates statePolicyId cageToken tx state request := by
  intro h
  exact hForeign h.2.2.2.1

/-- `Contribute` cannot be paired with arbitrary state spends such as `End`;
    the referenced state input must be spent with state `Modify`. -/
theorem contribute_rejects_state_spent_without_modify
    (statePolicyId : PolicyId)
    (cageToken : AssetName)
    (tx : TxView)
    (state : StateUTxO)
    (request : RequestUTxO)
    (hNotModify : state.ref ∉ tx.modifyInputs) :
    ¬ contributeAuthenticates statePolicyId cageToken tx state request := by
  intro h
  exact hNotModify h.2.2.1

/-- A request validator instance rejects requests for a different cage token. -/
theorem wrong_request_parameter_rejects_cage_token
    (statePolicyId : PolicyId)
    (cageToken : AssetName)
    (tx : TxView)
    (state : StateUTxO)
    (request : RequestUTxO)
    (hWrong : request.cageToken ≠ cageToken) :
    ¬ contributeAuthenticates statePolicyId cageToken tx state request := by
  intro h
  exact hWrong h.1

/-- `Retract` may authenticate state through reference inputs because it does
    not update state and does not need state `Modify` to run. -/
theorem retract_accepts_reference_state
    (statePolicyId : PolicyId)
    (cageToken : AssetName)
    (tx : TxView)
    (state : StateUTxO)
    (request : RequestUTxO)
    (hReq : request.cageToken = cageToken)
    (hRef : state.ref ∈ tx.referenceInputs)
    (hState : carriesStateToken statePolicyId cageToken state) :
    retractAuthenticates statePolicyId cageToken tx state request := by
  exact ⟨hReq, Or.inr hRef, hState⟩

/-- Matching-token requests with mismatched tips are sweepable, since state
    `Modify` would reject them before refund processing. -/
theorem sweep_mismatched_tip_request_allowed
    (statePolicyId : PolicyId)
    (cageToken : AssetName)
    (tx : TxView)
    (state : StateUTxO)
    (request : RequestUTxO)
    (hSigned : state.owner ∈ tx.signers)
    (hVisible : stateVisible tx state)
    (hState : carriesStateToken statePolicyId cageToken state)
    (hTip : request.tip ≠ state.tip) :
    sweepAllowed statePolicyId cageToken tx state request := by
  refine ⟨hSigned, hVisible, hState, ?_⟩
  intro hProcessable
  exact hTip hProcessable.2.1

/-- Matching-token requests that cannot cover the state tip are sweepable,
    because they cannot satisfy the state validator's refund equation. -/
theorem sweep_underfunded_matching_request_allowed
    (statePolicyId : PolicyId)
    (cageToken : AssetName)
    (tx : TxView)
    (state : StateUTxO)
    (request : RequestUTxO)
    (hSigned : state.owner ∈ tx.signers)
    (hVisible : stateVisible tx state)
    (hState : carriesStateToken statePolicyId cageToken state)
    (hUnderfunded : request.lovelace < state.tip) :
    sweepAllowed statePolicyId cageToken tx state request := by
  refine ⟨hSigned, hVisible, hState, ?_⟩
  intro hProcessable
  have hEnough := hProcessable.2.2
  omega

/-- Processable legitimate requests are protected from owner sweep. -/
theorem protected_request_not_sweepable
    (statePolicyId : PolicyId)
    (cageToken : AssetName)
    (tx : TxView)
    (state : StateUTxO)
    (request : RequestUTxO)
    (hProcessable : processableRequest cageToken state request) :
    ¬ sweepAllowed statePolicyId cageToken tx state request := by
  intro hSweep
  exact hSweep.2.2.2 hProcessable
