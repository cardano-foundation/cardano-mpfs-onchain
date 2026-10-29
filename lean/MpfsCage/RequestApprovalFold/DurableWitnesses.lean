import MpfsCage.RequestApprovalFold.Witnesses

namespace RequestApprovalFold.DurableWitnesses

/-! These proof terms import no admitted statements. Each scenario constructs
an actual path from registry creation, including the authentic live inputs. -/

def cage := Witnesses.Zero.cage
def origin := initial cage
def origin_reachable : Reachable origin := Witnesses.Zero.reachable0

def extraction : Extraction :=
  ⟨cage.id, "extractor", "q", none, ⟨"refund-A", 3⟩, 4, 10, 5, "extract-A",
    [requestName cage.id], .release⟩
def createExtraction : ExtractionCreateTx := ⟨cage, extraction, extraction.tokens, []⟩
def pending := afterExtractionCreate origin createExtraction

def extraction_wf : extractionWellFormed cage extraction := by
  unfold extractionWellFormed
  exact ⟨rfl, by decide, rfl, rfl, by decide⟩
def create_extraction_step : Step origin (.extractionCreate createExtraction) pending :=
  .extractionCreate origin createExtraction rfl ⟨extraction_wf,rfl⟩ (by simp [origin,initial])
def pending_reachable : Reachable pending := .next origin_reachable create_extraction_step

def extraction_valid : extractionAllowed cage ⟨3,4⟩ extraction :=
  ⟨extraction_wf, by (try unfold Interval.valid); decide, by decide, rfl, rfl⟩

def extractTx := singletonFold pending ⟨3,4⟩ [] (.extract extraction) "folder"
def live := afterFold pending extractTx
def outputA := witnessOutput cage.id extraction.key extraction.data

def singleton_accepted (s : State) (iv : Interval) (sigs : List Signer)
 (i : FoldItem) (folder : Signer) (hv : iv.valid)
 (hi : itemAllowed s.cage iv s.judgments sigs i) :
 foldAccepted (singletonFold s iv sigs i folder) := by
  refine ⟨hv, ?_, by simp [singletonFold,withWitnessBoundary], by simp [singletonFold,withWitnessBoundary,foldPayments], .cons _ _ _ _ hi (.nil _), ?_⟩
  · cases i <;> simp [singletonFold, withWitnessBoundary, FoldTx.requests, FoldTx.claims,
      FoldTx.extractions, FoldItem.request, FoldItem.claimInput, FoldItem.extraction]
  · exact ⟨rfl,rfl,rfl,rfl,rfl⟩

def extract_accepted : foldAccepted extractTx :=
  singleton_accepted pending _ _ _ _ (by (try unfold Interval.valid); decide) extraction_valid

def extract_step : Step pending (.fold extractTx) live := by
  apply Step.fold pending extractTx rfl
  · intro o h; change o ∈ ([] : List RequestOutput) at h; contradiction
  · intro o h; change o ∈ ([] : List ClaimOutput) at h; contradiction
  · exact fun _ h => h
  · exact extract_accepted
  · intro o h; change o ∈ [extraction] at h
    have he := List.mem_singleton.mp h; subst o
    exact List.mem_cons_self
  · intro w h; change w ∈ ([] : List WitnessOutput) at h; contradiction

def live_reachable : Reachable live := .next pending_reachable extract_step

def live_fact : live.witnesses = [outputA] ∧ witnessAt live.cage.tree "q" = some extraction.data ∧
 live.cage.trie "q" = none ∧ outputA.value = 3 ∧ outputA.address = registryAddress := by
  exact ⟨rfl,rfl,rfl,rfl,rfl⟩

def no_rule_admission : ¬ ruleAdmits cage { Witnesses.request with owner := extraction.owner } [] := by
  simp [ruleAdmits, cage, Witnesses.Zero.cage, Witnesses.Zero.rule, extraction]

def writeOutput (ref key value : String) (witness : Option WitnessSpec) : RequestOutput :=
  { Witnesses.Zero.output with
    ref := ref
    request := { Witnesses.Zero.output.request with
      write := .set key value
      conditions := []
      witnessing := witness } }

def creation (s : State) (o : RequestOutput) : CreateTx :=
  ⟨[], s.cage, tokensOf o, [o], ["creator"], .rule "creator-rule"⟩

def unrelatedOutput := writeOutput "unrelated" "other" "other-value" none
def unrelatedCreate := creation live unrelatedOutput
def unrelatedPending := afterCreate live unrelatedCreate unrelatedOutput
def unrelatedTx := singletonFold unrelatedPending ⟨4,5⟩ [] (.write unrelatedOutput (Witnesses.selected true)) "folder"
def unrelated := afterFold unrelatedPending unrelatedTx

def replacementOutput := writeOutput "replacement" "q" "value-q" (some ⟨"refund-B",5⟩)
def replacementCreate := creation unrelated replacementOutput
def replacementPending := afterCreate unrelated replacementCreate replacementOutput
def replacementTx := singletonFold replacementPending ⟨5,6⟩ [] (.write replacementOutput (Witnesses.selected true)) "folder"
def replaced := afterFold replacementPending replacementTx

def outputB := witnessOutput cage.id "q" ⟨some "value-q","refund-B",5,"replacement"⟩

def unsetOutput : RequestOutput :=
  { Witnesses.Zero.output with
    ref := "unset"
    request := { Witnesses.Zero.output.request with write := .unset "q", conditions := [] } }
def unsetCreate := creation replaced unsetOutput
def unsetPending := afterCreate replaced unsetCreate unsetOutput
def unsetTx := singletonFold unsetPending ⟨6,7⟩ [] (.write unsetOutput (Witnesses.selected true)) "folder"
def cleared := afterFold unsetPending unsetTx

macro "expand_scenario" : tactic => `(tactic|
  simp only [cleared, unsetTx, unsetPending, unsetCreate, unsetOutput,
    replaced, replacementTx, replacementPending, replacementCreate, replacementOutput,
    unrelated, unrelatedTx, unrelatedPending, unrelatedCreate, unrelatedOutput,
    creation, writeOutput, live, extractTx, pending, createExtraction, extraction,
    origin, cage, Witnesses.Zero.cage, Witnesses.Zero.output, Witnesses.Zero.rule,
    Witnesses.cage, Witnesses.output, Witnesses.request,
    singletonFold, withWitnessBoundary, afterFold, afterCreate, afterExtractionCreate,
    initial, itemResult, credit, FoldTx.requests, FoldTx.claims, FoldTx.extractions,
    FoldItem.request, FoldItem.claimInput, FoldItem.extraction, removeRequests])

macro "finite_scenario" : tactic => `(tactic|
  (expand_scenario
   simp [wellFormed, Request.witnessValid, createAllowed, tokensOf, ruleAdmits,
     requestPolicy, totalFees, Request.fee, stepValid, hasApproval, Interval.valid,
     witnessBoundary, foldWitnessEvents, itemWitnessEvents, FoldItem.entryKey,
     witnessAt, putEntry, writeEntry, Write.key, Write.value, writeTree, witnessWriteAllowed, witnessOutput, Extraction.data,
     externalWitnessInputs, externalWitnessOutputs, emptyEntries, credits,
     CageState.trie, logicalTree, Entry.logical]))

def unrelated_create_ok : createAllowed unrelatedCreate unrelatedOutput := by finite_scenario

def unrelated_create_step : Step live (.create unrelatedCreate unrelatedOutput) unrelatedPending := by
  apply Step.create live unrelatedCreate unrelatedOutput rfl unrelated_create_ok
  · simp [unrelatedCreate,creation]
  · finite_scenario

def unrelated_pending_reachable : Reachable unrelatedPending := .next live_reachable unrelated_create_step

def unrelated_valid : stepValid unrelatedPending.cage ⟨4,5⟩ unrelatedPending.judgments []
 (Witnesses.selected true) unrelatedOutput := by finite_scenario

def unrelated_accepted : foldAccepted unrelatedTx :=
 singleton_accepted unrelatedPending _ _ _ _ (by (try unfold Interval.valid); decide) unrelated_valid

def unrelated_step : Step unrelatedPending (.fold unrelatedTx) unrelated := by
  apply Step.fold unrelatedPending unrelatedTx rfl
  · intro o h; change o ∈ [unrelatedOutput] at h
    have he := List.mem_singleton.mp h; subst o
    exact List.mem_cons_self
  · intro o h; change o ∈ ([] : List ClaimOutput) at h; contradiction
  · exact fun _ h => h
  · exact unrelated_accepted
  · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
  · intro w h; change w ∈ ([] : List WitnessOutput) at h; contradiction

def unrelated_reachable : Reachable unrelated := .next unrelated_pending_reachable unrelated_step

def unrelated_retains : unrelated.witnesses = [outputA] ∧ unrelated.cage.trie "q" = none ∧
 unrelated.cage.trie "other" = some "other-value" := ⟨rfl,rfl,rfl⟩

def replacement_create_ok : createAllowed replacementCreate replacementOutput := by finite_scenario

def replacement_create_step : Step unrelated (.create replacementCreate replacementOutput) replacementPending := by
  apply Step.create unrelated replacementCreate replacementOutput rfl replacement_create_ok
  · simp [replacementCreate,creation]
  · finite_scenario

def replacement_pending_reachable : Reachable replacementPending :=
 .next unrelated_reachable replacement_create_step

def replacement_valid : stepValid replacementPending.cage ⟨5,6⟩ replacementPending.judgments []
 (Witnesses.selected true) replacementOutput := by finite_scenario

def replacement_accepted : foldAccepted replacementTx :=
 singleton_accepted replacementPending _ _ _ _ (by (try unfold Interval.valid); decide) replacement_valid

def replacement_step : Step replacementPending (.fold replacementTx) replaced := by
  apply Step.fold replacementPending replacementTx rfl
  · intro o h; change o ∈ [replacementOutput] at h
    have he := List.mem_singleton.mp h; subst o
    exact List.mem_cons_self
  · intro o h; change o ∈ ([] : List ClaimOutput) at h; contradiction
  · exact fun _ h => h
  · exact replacement_accepted
  · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
  · intro w h
    change w ∈ [outputA] at h
    change w ∈ [outputA]
    exact h

def replaced_reachable : Reachable replaced := .next replacement_pending_reachable replacement_step

def replacement_effect : replaced.witnesses = [outputB] ∧
 replacementTx.payments = [⟨"folder","",10⟩,⟨"refund-A","",3⟩] ∧
 replacementTx.witnessBurned = [outputA.token] ∧ replacementTx.witnessMinted = [outputB.token] ∧
 replaced.cage.trie "q" = some "value-q" := ⟨rfl,rfl,rfl,rfl,rfl⟩

def unset_create_ok : createAllowed unsetCreate unsetOutput := by finite_scenario

def unset_create_step : Step replaced (.create unsetCreate unsetOutput) unsetPending := by
  apply Step.create replaced unsetCreate unsetOutput rfl unset_create_ok
  · simp [unsetCreate,creation]
  · finite_scenario

def unset_pending_reachable : Reachable unsetPending := .next replaced_reachable unset_create_step

def unset_valid : stepValid unsetPending.cage ⟨6,7⟩ unsetPending.judgments []
 (Witnesses.selected true) unsetOutput := by finite_scenario

def unset_accepted : foldAccepted unsetTx :=
 singleton_accepted unsetPending _ _ _ _ (by (try unfold Interval.valid); decide) unset_valid

def unset_step : Step unsetPending (.fold unsetTx) cleared := by
  apply Step.fold unsetPending unsetTx rfl
  · intro o h; change o ∈ [unsetOutput] at h
    have he := List.mem_singleton.mp h; subst o
    exact List.mem_cons_self
  · intro o h; change o ∈ ([] : List ClaimOutput) at h; contradiction
  · exact fun _ h => h
  · exact unset_accepted
  · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
  · intro w h; change w ∈ [outputB] at h; change w ∈ [outputB]; exact h

def cleared_reachable : Reachable cleared := .next unset_pending_reachable unset_step

def cleared_effect : cleared.witnesses = [] ∧ cleared.cage.trie "q" = none ∧
 unsetTx.payments = [⟨"folder","",10⟩,⟨"refund-B","",5⟩] := ⟨rfl,rfl,rfl⟩



def transientCreate := creation pending replacementOutput
def transientSource := afterCreate pending transientCreate replacementOutput
def transientItems : List FoldItem := [.extract extraction, .write replacementOutput (Witnesses.selected true)]
def transientTx : FoldTx := withWitnessBoundary
  ⟨cage, foldResult cage transientItems, transientItems, [], [], ⟨3,4⟩,
    "folder", "anyone", transientItems.flatMap FoldItem.burned,
    foldPayments cage "folder" transientItems, [], [], [], [], []⟩
def transientResult := afterFold transientSource transientTx

def transient_create_step : Step pending (.create transientCreate replacementOutput) transientSource := by
  apply Step.create pending transientCreate replacementOutput rfl
  · exact replacement_create_ok
  · simp [transientCreate,creation]
  · decide

def transient_source_reachable : Reachable transientSource := .next pending_reachable transient_create_step

def transient_accepted : foldAccepted transientTx := by
  refine ⟨by unfold Interval.valid; decide, by decide, rfl, rfl, ?_, ⟨rfl,rfl,rfl,rfl,rfl⟩⟩
  refine .cons _ _ _ _ extraction_valid (.cons _ _ _ _ ?_ (.nil _))
  refine ⟨Or.inr (Or.inr (by decide)), replacement_valid.2.1, by unfold Interval.valid; decide, by decide, ?_, ?_, ?_⟩
  · intro o h; change o ∈ ([] : List Oracle) at h; contradiction
  · intro condition h; change condition ∈ ([] : List Condition) at h; contradiction
  · intro o h; change o ∈ ([] : List Oracle) at h; contradiction

def transient_step : Step transientSource (.fold transientTx) transientResult := by
  apply Step.fold transientSource transientTx rfl
  · intro o h; change o ∈ [replacementOutput] at h
    have he := List.mem_singleton.mp h; subst o; exact List.mem_cons_self
  · intro o h; change o ∈ ([] : List ClaimOutput) at h; contradiction
  · intro name h; change name ∈ ([] : List TokenName) at h; contradiction
  · exact transient_accepted
  · intro o h; change o ∈ [extraction] at h; change o ∈ [extraction]; exact h
  · intro out h; change out ∈ ([] : List WitnessOutput) at h; contradiction

def transient_reachable : Reachable transientResult := .next transient_source_reachable transient_step

def transient_effect : transientTx.witnessInputs = [] ∧ transientTx.witnessOutputs = [outputB] ∧
 transientTx.witnessBurned = [] ∧ transientTx.witnessMinted = [outputB.token] ∧
 transientResult.witnesses = [outputB] ∧
 transientTx.payments = [⟨"folder","",4⟩,⟨"folder","",10⟩,⟨"refund-A","",3⟩] ∧
 outputA ∈ transientTx.witnessEvents.filterMap WitnessEvent.produced ∧
 outputA ∈ transientTx.witnessEvents.filterMap WitnessEvent.consumed := by
  exact ⟨rfl,rfl,rfl,rfl,rfl,rfl,by decide,by decide⟩

def accountTx := singletonFold pending ⟨10,15⟩ [] (.extractAccount extraction) "anyone"
def accountResult := afterFold pending accountTx

def account_valid : extractionAccountAllowed cage ⟨10,15⟩ extraction :=
  ⟨extraction_wf, by unfold Interval.valid; decide, by decide, by decide⟩

def account_accepted : foldAccepted accountTx :=
 singleton_accepted pending _ _ _ _ (by unfold Interval.valid; decide) account_valid

def account_step : Step pending (.fold accountTx) accountResult := by
  apply Step.fold pending accountTx rfl
  · intro o h; change o ∈ ([] : List RequestOutput) at h; contradiction
  · intro o h; change o ∈ ([] : List ClaimOutput) at h; contradiction
  · exact fun _ h => h
  · exact account_accepted
  · intro o h; change o ∈ [extraction] at h; change o ∈ [extraction]; exact h
  · intro out h; change out ∈ ([] : List WitnessOutput) at h; contradiction

def account_reachable : Reachable accountResult := .next pending_reachable account_step

def withdrawTx : ExtractionWithdrawTx :=
 ⟨extraction,⟨16,17⟩,["extractor"],extraction.tokens,"extractor",7⟩
def withdrawn := afterExtractionWithdraw pending withdrawTx
def withdraw_allowed : extractionWithdrawAllowed withdrawTx := by
  unfold extractionWithdrawAllowed Interval.valid
  decide

def withdraw_step : Step pending (.extractionWithdraw withdrawTx) withdrawn :=
  .extractionWithdraw pending withdrawTx List.mem_cons_self withdraw_allowed

def withdrawn_reachable : Reachable withdrawn := .next pending_reachable withdraw_step

def exit_effects : accountTx.payments = [⟨"extractor","",4⟩,⟨"extractor","",3⟩] ∧
 accountResult.extractions = [] ∧ accountResult.witnesses = [] ∧
 withdrawn.extractions = [] ∧ withdrawTx.paid = 7 := ⟨rfl,rfl,rfl,rfl,rfl⟩

def unusedTx := singletonFold replacementPending ⟨10,15⟩ []
 (.account replacementOutput (Witnesses.selected false)) "folder"
def unusedResult := afterFold replacementPending unusedTx

def unused_valid : accountAllowed replacementPending.cage ⟨10,15⟩ replacementPending.judgments
 replacementOutput (Witnesses.selected false) := by
  refine ⟨replacement_valid.2.1, by unfold Interval.valid; decide, by decide, by decide, ?_⟩
  intro o h; change o ∈ ([] : List Oracle) at h; contradiction

def unused_accepted : foldAccepted unusedTx :=
 singleton_accepted replacementPending _ _ _ _ (by unfold Interval.valid; decide) unused_valid

def unused_step : Step replacementPending (.fold unusedTx) unusedResult := by
  apply Step.fold replacementPending unusedTx rfl
  · intro o h; change o ∈ [replacementOutput] at h
    have he := List.mem_singleton.mp h; subst o; exact List.mem_cons_self
  · intro o h; change o ∈ ([] : List ClaimOutput) at h; contradiction
  · exact fun _ h => h
  · exact unused_accepted
  · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
  · intro out h; change out ∈ ([] : List WitnessOutput) at h; contradiction

def unused_reachable : Reachable unusedResult := .next replacement_pending_reachable unused_step

def unused_effect : unusedResult.witnesses = [outputA] ∧
 unusedTx.payments = [⟨"owner","",10⟩,⟨"owner","",5⟩] := ⟨rfl,rfl⟩

/-- Oracle-bearing registry with a rule that rejects every ordinary request. -/
def rejectingCage : CageState := { Witnesses.cage with rule := some ⟨"reject",fun _ _ => False⟩ }
def rejectingOrigin := initial rejectingCage
def rejectingCreate : ExtractionCreateTx := ⟨rejectingCage, extraction, extraction.tokens, []⟩
def rejectingPending := afterExtractionCreate rejectingOrigin rejectingCreate
def rejectingTx := singletonFold rejectingPending ⟨3,4⟩ [] (.extract extraction) "anyone"
def rejectingResult := afterFold rejectingPending rejectingTx

def rejecting_created : registryCreated rejectingCage [] := by
  simp [registryCreated,RegistryValid,rejectingCage,Witnesses.cage]
def rejecting_origin_reachable : Reachable rejectingOrigin := .registry rejectingCage [] rejecting_created

def rejecting_create_step : Step rejectingOrigin (.extractionCreate rejectingCreate) rejectingPending :=
  .extractionCreate rejectingOrigin rejectingCreate rfl ⟨extraction_wf,rfl⟩ (by simp [rejectingOrigin,initial])
def rejecting_pending_reachable : Reachable rejectingPending := .next rejecting_origin_reachable rejecting_create_step

def rejecting_valid : extractionAllowed rejectingCage ⟨3,4⟩ extraction := extraction_valid

def rejecting_accepted : foldAccepted rejectingTx :=
 singleton_accepted rejectingPending _ _ _ _ (by unfold Interval.valid; decide) rejecting_valid

def rejecting_step : Step rejectingPending (.fold rejectingTx) rejectingResult := by
  apply Step.fold rejectingPending rejectingTx rfl
  · intro o h; change o ∈ ([] : List RequestOutput) at h; contradiction
  · intro o h; change o ∈ ([] : List ClaimOutput) at h; contradiction
  · exact fun _ h => h
  · exact rejecting_accepted
  · intro o h; change o ∈ [extraction] at h; change o ∈ [extraction]; exact h
  · intro out h; change out ∈ ([] : List WitnessOutput) at h; contradiction

def rejecting_reachable : Reachable rejectingResult := .next rejecting_pending_reachable rejecting_step

def bypasses_rule_and_oracles : rejectingCage.oracles ≠ [] ∧
 (∀ r sigs, ¬ ruleAdmits rejectingCage r sigs) ∧ rejectingTx.refs = [] ∧ rejectingTx.signers = [] :=
 ⟨by decide,fun _ _ h => h,rfl,rfl⟩



/-- A different-value plain set discharges its old witness. -/
def plainOutput := writeOutput "plain-change" "q" "value-r" none
def plainCreate := creation replaced plainOutput
def plainPending := afterCreate replaced plainCreate plainOutput
def plainTx := singletonFold plainPending ⟨6,7⟩ [] (.write plainOutput (Witnesses.selected true)) "folder"
def plainResult := afterFold plainPending plainTx

def plain_create_ok : createAllowed plainCreate plainOutput := by
  simp only [plainCreate,plainOutput]
  finite_scenario

def plain_create_step : Step replaced (.create plainCreate plainOutput) plainPending := by
  apply Step.create replaced plainCreate plainOutput rfl plain_create_ok
  · simp [plainCreate,creation]
  · decide

def plain_pending_reachable : Reachable plainPending := .next replaced_reachable plain_create_step

def plain_valid : stepValid plainPending.cage ⟨6,7⟩ plainPending.judgments []
 (Witnesses.selected true) plainOutput := by
  simp only [plainPending,plainCreate,plainOutput]
  finite_scenario

def plain_accepted : foldAccepted plainTx :=
 singleton_accepted plainPending _ _ _ _ (by unfold Interval.valid; decide) plain_valid

def plain_step : Step plainPending (.fold plainTx) plainResult := by
  apply Step.fold plainPending plainTx rfl
  · intro o h; change o ∈ [plainOutput] at h
    have he := List.mem_singleton.mp h; subst o; exact List.mem_cons_self
  · intro o h; change o ∈ ([] : List ClaimOutput) at h; contradiction
  · exact fun _ h => h
  · exact plain_accepted
  · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
  · intro out h; change out ∈ [outputB] at h; change out ∈ [outputB]; exact h

def plain_reachable : Reachable plainResult := .next plain_pending_reachable plain_step

def plain_effect : plainResult.witnesses = [] ∧ plainResult.cage.trie "q" = some "value-r" ∧
 plainTx.payments = [⟨"folder","",10⟩,⟨"refund-B","",5⟩] ∧
 plainResult.cage.trie "q" ≠ replaced.cage.trie "q" := ⟨rfl,rfl,rfl,by decide⟩

def exactExtraction : Extraction :=
 { extraction with wanted := some "value-r", ref := "exact-extraction" }
def exactCreate : ExtractionCreateTx := ⟨plainResult.cage,exactExtraction,exactExtraction.tokens,[]⟩
def exactPending := afterExtractionCreate plainResult exactCreate

def exact_create_step : Step plainResult (.extractionCreate exactCreate) exactPending :=
 .extractionCreate plainResult exactCreate rfl ⟨extraction_wf,rfl⟩ (by decide)

def exact_pending_reachable : Reachable exactPending := .next plain_reachable exact_create_step

def exact_valid : extractionAllowed exactPending.cage ⟨7,8⟩ exactExtraction :=
 ⟨extraction_wf,by unfold Interval.valid; decide,by decide,rfl,rfl⟩

def exactTx := singletonFold exactPending ⟨7,8⟩ [] (.extract exactExtraction) "anyone"
def exactResult := afterFold exactPending exactTx
def exactOutput := witnessOutput cage.id "q" exactExtraction.data

def exact_accepted : foldAccepted exactTx :=
 singleton_accepted exactPending _ _ _ _ (by unfold Interval.valid; decide) exact_valid

def exact_step : Step exactPending (.fold exactTx) exactResult := by
  apply Step.fold exactPending exactTx rfl
  · intro o h; change o ∈ ([] : List RequestOutput) at h; contradiction
  · intro o h; change o ∈ ([] : List ClaimOutput) at h; contradiction
  · exact fun _ h => h
  · exact exact_accepted
  · intro o h; change o ∈ [exactExtraction] at h; change o ∈ [exactExtraction]; exact h
  · intro out h; change out ∈ ([] : List WitnessOutput) at h; contradiction

def exact_reachable : Reachable exactResult := .next exact_pending_reachable exact_step

def exact_effect : exactResult.witnesses = [exactOutput] ∧ exactOutput.token.data.fact = some "value-r" ∧
 exactResult.cage.trie "q" = some "value-r" := ⟨rfl,rfl,rfl⟩

def stale : extractionWellFormed plainResult.cage extraction ∧
 witnessAt plainResult.cage.tree extraction.key = none ∧
 plainResult.cage.trie extraction.key ≠ extraction.wanted := ⟨extraction_wf,rfl,by decide⟩

def replacementEvents : List (State × Action × State) :=
 [(origin,.extractionCreate createExtraction,pending),
  (pending,.fold extractTx,live),
  (live,.create unrelatedCreate unrelatedOutput,unrelatedPending),
  (unrelatedPending,.fold unrelatedTx,unrelated),
  (unrelated,.create replacementCreate replacementOutput,replacementPending),
  (replacementPending,.fold replacementTx,replaced)]

def replacement_trace : Trace origin replacementEvents replaced :=
 .cons create_extraction_step (.cons extract_step (.cons unrelated_create_step
  (.cons unrelated_step (.cons replacement_create_step (.cons replacement_step (.nil _))))))

/-- Each public row names a concrete, kernel-checked premise instance below. -/
def extractionPremise : Reachable pending ∧ Step pending (.fold extractTx) live ∧
 foldAccepted extractTx ∧ extractTx.items[0]? = some (.extract extraction) :=
 ⟨pending_reachable,extract_step,extract_accepted,rfl⟩

def replacementPremise : Reachable replacementPending ∧ Step replacementPending (.fold replacementTx) replaced ∧
 foldAccepted replacementTx ∧ replacementTx.items[0]? = some (.write replacementOutput (Witnesses.selected true)) ∧
 witnessAt replacementPending.cage.tree "q" = some extraction.data ∧
 itemChanges (atTurn replacementTx 0) (.write replacementOutput (Witnesses.selected true)) "q" :=
 ⟨replacement_pending_reachable,replacement_step,replacement_accepted,rfl,rfl,by unfold itemChanges; decide⟩

def DW01 := unrelated_reachable
def DW02 := unrelated_reachable
def DW03 := replaced_reachable
def DW04 : Reachable exactResult ∧ exactOutput ∈ exactResult.witnesses := ⟨exact_reachable,by decide⟩
def DW05 : Reachable exactResult ∧ exactOutput ∈ exactResult.witnesses ∧ exactOutput.token.data.fact = some "value-r" :=
 ⟨exact_reachable,by decide,rfl⟩
def DW06 : Reachable live ∧ outputA ∈ live.witnesses ∧ outputA.token.data.fact = none := ⟨live_reachable,by decide,rfl⟩
def DW07 : Reachable replaced ∧ outputB ∈ replaced.witnesses ∧ outputB.token.key = outputB.token.key :=
 ⟨replaced_reachable,by decide,rfl⟩
def DW08 := replacementPremise
def DW09 := replacementPremise
def DW10 : Reachable replacementPending ∧ Step replacementPending (.fold replacementTx) replaced ∧
 outputA ∈ replacementPending.witnesses ∧ outputA ∉ replaced.witnesses :=
 ⟨replacement_pending_reachable,replacement_step,by decide,by decide⟩
def DW11 : Reachable unrelatedPending ∧ Step unrelatedPending (.fold unrelatedTx) unrelated ∧
 outputA ∈ unrelatedPending.witnesses ∧
 (∀ o e, FoldItem.write o e ∈ unrelatedTx.items → o.request.write.key ≠ outputA.token.key) := by
 refine ⟨unrelated_pending_reachable,unrelated_step,by decide,?_⟩
 intro o e h
 change FoldItem.write o e ∈ [FoldItem.write unrelatedOutput (Witnesses.selected true)] at h
 have he := List.mem_singleton.mp h
 cases he
 decide

def DW12 := extractionPremise
def DW13 := extractionPremise
def DW14 := extractionPremise
def DW15 : Reachable rejectingOrigin ∧ Step rejectingOrigin (.extractionCreate rejectingCreate) rejectingPending :=
 ⟨rejecting_origin_reachable,rejecting_create_step⟩
def DW16 : Reachable rejectingPending ∧ Step rejectingPending (.fold rejectingTx) rejectingResult ∧
 extractionAllowed rejectingPending.cage ⟨3,4⟩ extraction :=
 ⟨rejecting_pending_reachable,rejecting_step,rejecting_valid⟩
def DW17 : Reachable live ∧ witnessAt live.cage.tree extraction.key = some extraction.data := ⟨live_reachable,rfl⟩
def DW18 : Reachable plainResult ∧ extractionWellFormed plainResult.cage extraction ∧
 witnessAt plainResult.cage.tree extraction.key = none ∧ plainResult.cage.trie extraction.key ≠ extraction.wanted :=
 ⟨plain_reachable,stale⟩
def DW19 := replacementPremise
def DW20 : Reachable plainPending ∧ plainOutput.request.witnessing = none ∧ Step plainPending (.fold plainTx) plainResult ∧
 itemChanges plainPending.cage (.write plainOutput (Witnesses.selected true)) "q" :=
 ⟨plain_pending_reachable,rfl,plain_step,by unfold itemChanges; decide⟩
def DW21 : Reachable transientSource ∧ Step transientSource (.fold transientTx) transientResult :=
 ⟨transient_source_reachable,transient_step⟩
def DW22 : Reachable live ∧ (["q"] : List Key).Nodup ∧
 (∀ k, k ∈ ["q"] ↔ ∃ w, witnessAt live.cage.tree k = some w) := by
 refine ⟨live_reachable,by decide,?_⟩
 intro k
 change k ∈ ["q"] ↔ ∃ w, witnessAt (putEntry emptyEntries "q" (some (.witnessed extraction.data))) k = some w
 by_cases h : k = "q"
 · subst k; simp [witnessAt,putEntry]
 · simp [witnessAt,putEntry,h,emptyEntries]

def DW23 := DW04
def DW24 : registryCreated cage [] ∧ Trace (initial cage) replacementEvents replaced ∧ outputB ∈ replaced.witnesses :=
 ⟨Witnesses.Zero.registry_ok,replacement_trace,by decide⟩
def DW25 := DW15
def DW26 : Reachable pending ∧ extractionAccountAllowed cage ⟨10,15⟩ extraction ∧ Step pending (.fold accountTx) accountResult :=
 ⟨pending_reachable,account_valid,account_step⟩
def DW27 : Reachable pending ∧ Step pending (.extractionWithdraw withdrawTx) withdrawn := ⟨pending_reachable,withdraw_step⟩
def DW28 := DW26
def DW29 : Reachable pending ∧ extractionSpendAllowed extraction (.folded accountTx) ∧
 ExtractionSpend.exitsAs (.folded accountTx) extraction .account :=
 ⟨pending_reachable,⟨account_accepted,by decide⟩,by unfold ExtractionSpend.exitsAs; exact List.mem_cons_self⟩
def DW30 := DW27
def DW31 : Reachable pending ∧ extraction ∈ pending.extractions := ⟨pending_reachable,by decide⟩
def DW32 : Reachable unrelated ∧ Step unrelated (.create replacementCreate replacementOutput) replacementPending ∧
 replacementOutput.request.witnessing = some ⟨"refund-B",5⟩ := ⟨unrelated_reachable,replacement_create_step,rfl⟩
def DW33 : Reachable replacementPending ∧ Step replacementPending (.fold unusedTx) unusedResult ∧ foldAccepted unusedTx :=
 ⟨replacement_pending_reachable,unused_step,unused_accepted⟩
def DW34 := replacementPremise
def DW35 : Reachable transientSource ∧ foldAccepted transientTx ∧
 outputA ∈ transientTx.witnessEvents.filterMap WitnessEvent.produced ∧
 outputA ∈ transientTx.witnessEvents.filterMap WitnessEvent.consumed :=
 ⟨transient_source_reachable,transient_accepted,by decide,by decide⟩
def DW36 := DW10
def DW37 := pending_reachable
def DW38 := DW26

def DW40 := replacementPremise
def DW41 := transient_source_reachable
def DW42 := replacementPremise
def DW43 := replacementPremise

def requestTraceEvents : List (State × Action × State) :=
 [(Witnesses.s0,.create Witnesses.create Witnesses.output,Witnesses.s1),
  (Witnesses.s1,.create Witnesses.Batch.createUnset Witnesses.Batch.unsetOutput,Witnesses.Batch.withUnset),
  (Witnesses.Batch.withUnset,.create Witnesses.Batch.createAgain Witnesses.Batch.againOutput,Witnesses.Batch.withAgain)]

def request_trace : Trace (initial Witnesses.cage) requestTraceEvents Witnesses.Batch.withAgain :=
 .cons Witnesses.step_create (.cons Witnesses.Batch.unsetStep (.cons Witnesses.Batch.againStep (.nil _)))

def DW44 : registryCreated Witnesses.cage [] ∧
 Trace (initial Witnesses.cage) requestTraceEvents Witnesses.Batch.withAgain ∧
 (Witnesses.s0,Action.create Witnesses.create Witnesses.output,Witnesses.s1) ∈ requestTraceEvents ∧
 (Witnesses.Batch.withUnset,Action.create Witnesses.Batch.createAgain Witnesses.Batch.againOutput,Witnesses.Batch.withAgain) ∈ requestTraceEvents ∧
 Witnesses.create.cageRef.oracles ≠ [] ∧ Witnesses.Batch.createAgain.cageRef.oracles ≠ [] ∧
 Witnesses.create ≠ Witnesses.Batch.createAgain := by
 refine ⟨Witnesses.registry_ok,request_trace,List.mem_cons_self,?_,by decide,by decide,?_⟩
 · exact List.mem_cons_of_mem _ (List.mem_cons_of_mem _ List.mem_cons_self)
 · intro h
   have he := congrArg CreateTx.spent h
   change ["seed"] = ["again-seed"] at he
   contradiction

def DW45 : Reachable exactResult ∧ referenceWitness exactResult exactOutput = some exactExtraction.data :=
 ⟨exact_reachable,rfl⟩

def staleExtraction : Extraction := { extraction with ref := "stale-extraction" }
def staleCreate : ExtractionCreateTx := ⟨plainResult.cage,staleExtraction,staleExtraction.tokens,[]⟩
def stalePending := afterExtractionCreate plainResult staleCreate

def stale_create_step : Step plainResult (.extractionCreate staleCreate) stalePending :=
 .extractionCreate plainResult staleCreate rfl ⟨extraction_wf,rfl⟩ (by decide)
def stale_pending_reachable : Reachable stalePending := .next plain_reachable stale_create_step

def staleAccountTx := singletonFold stalePending ⟨10,15⟩ [] (.extractAccount staleExtraction) "anyone"
def staleAccountResult := afterFold stalePending staleAccountTx

def stale_account_accepted : foldAccepted staleAccountTx :=
 singleton_accepted stalePending _ _ _ _ (by unfold Interval.valid; decide) account_valid

def stale_account_step : Step stalePending (.fold staleAccountTx) staleAccountResult := by
 apply Step.fold stalePending staleAccountTx rfl
 · intro o h; change o ∈ ([] : List RequestOutput) at h; contradiction
 · intro o h; change o ∈ ([] : List ClaimOutput) at h; contradiction
 · exact fun _ h => h
 · exact stale_account_accepted
 · intro o h; change o ∈ [staleExtraction] at h; change o ∈ [staleExtraction]; exact h
 · intro out h; change out ∈ ([] : List WitnessOutput) at h; contradiction

def stale_account_reachable : Reachable staleAccountResult := .next stale_pending_reachable stale_account_step

def DW39 : Reachable stalePending ∧ staleExtraction ∈ stalePending.extractions ∧
 extractionWellFormed stalePending.cage staleExtraction ∧
 stalePending.cage.trie staleExtraction.key ≠ staleExtraction.wanted ∧
 Step stalePending (.fold staleAccountTx) staleAccountResult :=
 ⟨stale_pending_reachable,by decide,extraction_wf,by decide,stale_account_step⟩

def paid_extraction : Reachable pending ∧ extraction.escrow = 7 ∧
 extractTx.payments = [⟨"folder","",4⟩] ∧ outputA.value = 3 ∧
 accountTx.payments = [⟨"extractor","",4⟩,⟨"extractor","",3⟩] ∧ withdrawTx.paid = 7 :=
 ⟨pending_reachable,rfl,rfl,rfl,rfl,rfl⟩

def underfunded_refused : Reachable origin ∧
 ¬ extractionWellFormed cage { extraction with value := 1 } ∧
 ¬ extractionWellFormed cage { extraction with witness := ⟨"refund-A",1⟩ } := by
 refine ⟨origin_reachable,?_,?_⟩ <;> unfold extractionWellFormed <;> decide

def sameOutput : RequestOutput := writeOutput "same-value" "q" "value-q" none
def sameCreate := creation replaced sameOutput
def samePending := afterCreate replaced sameCreate sameOutput

def same_create_ok : createAllowed sameCreate sameOutput := by
 simp only [sameCreate,sameOutput]
 finite_scenario

def same_create_step : Step replaced (.create sameCreate sameOutput) samePending := by
 apply Step.create replaced sameCreate sameOutput rfl same_create_ok
 · simp [sameCreate,creation]
 · decide

def same_pending_reachable : Reachable samePending := .next replaced_reachable same_create_step

def sameTx := singletonFold samePending ⟨6,7⟩ [] (.write sameOutput (Witnesses.selected true)) "folder"
def sameResult := afterFold samePending sameTx

def same_valid : stepValid samePending.cage ⟨6,7⟩ samePending.judgments []
 (Witnesses.selected true) sameOutput := by
 simp only [samePending,sameCreate,sameOutput]
 finite_scenario

def same_accepted : foldAccepted sameTx :=
 singleton_accepted samePending _ _ _ _ (by unfold Interval.valid; decide) same_valid

def same_step : Step samePending (.fold sameTx) sameResult := by
 apply Step.fold samePending sameTx rfl
 · intro o h; change o ∈ [sameOutput] at h
   have he := List.mem_singleton.mp h; subst o; exact List.mem_cons_self
 · intro o h; change o ∈ ([] : List ClaimOutput) at h; contradiction
 · exact fun _ h => h
 · exact same_accepted
 · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
 · intro out h; change out ∈ ([] : List WitnessOutput) at h; contradiction

def same_reachable : Reachable sameResult := .next same_pending_reachable same_step

def same_effect : sameResult.witnesses = replaced.witnesses ∧
 sameResult.cage.tree = replaced.cage.tree ∧ sameTx.witnessEvents = [] ∧
 sameTx.witnessInputs = [] ∧ sameTx.witnessBurned = [] ∧
 sameTx.payments = [⟨"folder","",10⟩] := ⟨rfl,rfl,rfl,rfl,rfl,rfl⟩

def absentNoopOutput : RequestOutput := { unsetOutput with ref := "absent-noop" }
def absentNoopCreate := creation live absentNoopOutput
def absentNoopPending := afterCreate live absentNoopCreate absentNoopOutput

def absentNoop_create_ok : createAllowed absentNoopCreate absentNoopOutput := by
 simp only [absentNoopCreate,absentNoopOutput]
 finite_scenario

def absentNoop_create_step : Step live (.create absentNoopCreate absentNoopOutput) absentNoopPending := by
 apply Step.create live absentNoopCreate absentNoopOutput rfl absentNoop_create_ok
 · simp [absentNoopCreate,creation]
 · decide

def absentNoop_pending_reachable : Reachable absentNoopPending := .next live_reachable absentNoop_create_step

def absentNoopTx := singletonFold absentNoopPending ⟨6,7⟩ [] (.write absentNoopOutput (Witnesses.selected true)) "folder"
def absentNoopResult := afterFold absentNoopPending absentNoopTx

def absentNoop_valid : stepValid absentNoopPending.cage ⟨6,7⟩ absentNoopPending.judgments []
 (Witnesses.selected true) absentNoopOutput := by
 simp only [absentNoopPending,absentNoopCreate,absentNoopOutput]
 finite_scenario

def absentNoop_accepted : foldAccepted absentNoopTx :=
 singleton_accepted absentNoopPending _ _ _ _ (by unfold Interval.valid; decide) absentNoop_valid

def absentNoop_step : Step absentNoopPending (.fold absentNoopTx) absentNoopResult := by
 apply Step.fold absentNoopPending absentNoopTx rfl
 · intro o h; change o ∈ [absentNoopOutput] at h
   have he := List.mem_singleton.mp h; subst o; exact List.mem_cons_self
 · intro o h; change o ∈ ([] : List ClaimOutput) at h; contradiction
 · exact fun _ h => h
 · exact absentNoop_accepted
 · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
 · intro out h; change out ∈ ([] : List WitnessOutput) at h; contradiction

def absentNoop_reachable : Reachable absentNoopResult := .next absentNoop_pending_reachable absentNoop_step

def absentNoop_effect : absentNoopResult.witnesses = live.witnesses ∧
 absentNoopResult.cage.tree = live.cage.tree ∧ absentNoopTx.witnessEvents = [] ∧
 absentNoopTx.witnessInputs = [] ∧ absentNoopTx.witnessBurned = [] ∧
 absentNoopTx.payments = [⟨"folder","",10⟩] := ⟨rfl,rfl,rfl,rfl,rfl,rfl⟩

def refusedOutput : RequestOutput := writeOutput "refused-same-value" "q" "value-q" (some ⟨"new-refund",7⟩)
def refusedCreate := creation replaced refusedOutput
def refusedPending := afterCreate replaced refusedCreate refusedOutput

def refused_create_ok : createAllowed refusedCreate refusedOutput := by
 simp only [refusedCreate,refusedOutput]
 finite_scenario

def refused_create_step : Step replaced (.create refusedCreate refusedOutput) refusedPending := by
 apply Step.create replaced refusedCreate refusedOutput rfl refused_create_ok
 · simp [refusedCreate,creation]
 · decide

def refused_pending_reachable : Reachable refusedPending := .next replaced_reachable refused_create_step

def refused_validity : ¬ stepValid refusedPending.cage ⟨6,7⟩ [] ["refund-B","new-refund"]
 (Witnesses.selected true) refusedOutput := by
 intro h
 have guard := h.1
 change (some (WitnessSpec.mk "new-refund" 7) = none ∨
  some (WitnessData.mk (some "value-q") "refund-B" 5 "replacement") = none ∨
  some "value-q" ≠ some "value-q") at guard
 simp at guard

def refusedAccountTx := singletonFold refusedPending ⟨10,15⟩ [] (.account refusedOutput (Witnesses.selected false)) "anyone"
def refusedAccountResult := afterFold refusedPending refusedAccountTx

def refused_account_valid : accountAllowed refusedPending.cage ⟨10,15⟩ [] refusedOutput
 (Witnesses.selected false) := by
 simp only [refusedPending,refusedCreate,refusedOutput]
 expand_scenario
 simp [accountAllowed,wellFormed,hasAccount,Request.witnessValid,totalFees,Request.fee,
  requestPolicy,Interval.valid]

def refused_account_accepted : foldAccepted refusedAccountTx :=
 singleton_accepted refusedPending _ _ _ _ (by unfold Interval.valid; decide) refused_account_valid

def refused_account_step : Step refusedPending (.fold refusedAccountTx) refusedAccountResult := by
 apply Step.fold refusedPending refusedAccountTx rfl
 · intro o h; change o ∈ [refusedOutput] at h
   have he := List.mem_singleton.mp h; subst o; exact List.mem_cons_self
 · intro o h; change o ∈ ([] : List ClaimOutput) at h; contradiction
 · exact fun _ h => h
 · exact refused_account_accepted
 · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
 · intro out h; change out ∈ ([] : List WitnessOutput) at h; contradiction

def refused_withdraw_tx : WithdrawTx := ⟨refusedOutput,⟨16,17⟩,["owner"],tokensOf refusedOutput,"owner",17⟩
def refused_withdraw_step : Step refusedPending (.withdraw refused_withdraw_tx)
 (afterExit refusedPending refusedOutput) := by
 apply Step.withdraw
 · exact List.mem_cons_self
 · unfold withdrawAllowed Interval.valid
   decide

def refused_exits_preserve : Reachable refusedPending ∧
 Step refusedPending (.fold refusedAccountTx) refusedAccountResult ∧
 Step refusedPending (.withdraw refused_withdraw_tx) (afterExit refusedPending refusedOutput) ∧
 refusedAccountTx.payments = [⟨"owner","",10⟩,⟨"owner","",7⟩] ∧
 refusedAccountResult.witnesses = [outputB] ∧ refusedAccountTx.witnessInputs = [] ∧
 (afterExit refusedPending refusedOutput).witnesses = [outputB] :=
 ⟨refused_pending_reachable,refused_account_step,refused_withdraw_step,rfl,rfl,rfl,rfl⟩

def DW46 : Reachable replacementPending ∧
 itemAllowed replacementPending.cage ⟨5,6⟩ [] [] (.write replacementOutput (Witnesses.selected true)) ∧
 witnessAt replacementPending.cage.tree "q" = some extraction.data :=
 ⟨replacement_pending_reachable,replacement_valid,rfl⟩

def same_preserves_key : actionPreservesKey (.fold sameTx) "q" := by
 intro n i h
 cases n with
 | zero =>
   have he : some (FoldItem.write sameOutput (Witnesses.selected true)) = some i := h
   cases Option.some.inj he
   change ¬ (some "value-q" ≠ some "value-q")
   simp
 | succ n => simp [sameTx,singletonFold,withWitnessBoundary] at h

def DW47 : Reachable samePending ∧ Step samePending (.fold sameTx) sameResult ∧
 outputB ∈ samePending.witnesses ∧ actionPreservesKey (.fold sameTx) outputB.token.key :=
 ⟨same_pending_reachable,same_step,by decide,same_preserves_key⟩

def DW48 : Reachable samePending ∧ sameOutput.request.witnessing = none ∧
 samePending.cage.trie sameOutput.request.write.key = sameOutput.request.write.value :=
 ⟨same_pending_reachable,rfl,rfl⟩

def DW49 : Reachable refusedPending ∧
 witnessAt refusedPending.cage.tree refusedOutput.request.write.key = some outputB.token.data ∧
 refusedOutput.request.witnessing = some ⟨"new-refund",7⟩ ∧
 refusedPending.cage.trie refusedOutput.request.write.key = refusedOutput.request.write.value :=
 ⟨refused_pending_reachable,rfl,rfl,rfl⟩

def DW50 := DW10

def DW51 : Reachable replacementPending ∧
 wellFormed replacementPending.cage replacementOutput ∧
 witnessWriteAllowed replacementPending.cage replacementOutput.request ∧
 replacementOutput.request.conditions = [] ∧
 (∀ oracle ∈ replacementPending.cage.oracles, (Witnesses.selected true oracle).conditions = []) :=
 ⟨replacement_pending_reachable,replacement_valid.2.1,replacement_valid.1,rfl,by simp [replacementPending,replacementCreate]; finite_scenario⟩

/-- A-003 / NOTE-006: equal batch endpoints do not undo the first value-change event. -/
def restoreOutput := writeOutput "restore-value" "q" "value-q" none
def restoreCreate := creation plainPending restoreOutput
def roundSource := afterCreate plainPending restoreCreate restoreOutput

def restore_create_ok : createAllowed restoreCreate restoreOutput := by
 simp only [restoreCreate,restoreOutput,plainPending,plainCreate,plainOutput]
 finite_scenario

def restore_create_step : Step plainPending (.create restoreCreate restoreOutput) roundSource := by
 apply Step.create plainPending restoreCreate restoreOutput rfl restore_create_ok
 · simp [restoreCreate,creation]
 · decide

def round_source_reachable : Reachable roundSource := .next plain_pending_reachable restore_create_step

def roundItems : List FoldItem := [.write plainOutput (Witnesses.selected true),.write restoreOutput (Witnesses.selected true)]
def roundTx : FoldTx := withWitnessBoundary
 ⟨roundSource.cage,foldResult roundSource.cage roundItems,roundItems,[],[],⟨6,7⟩,
 "folder","anyone",roundItems.flatMap FoldItem.burned,foldPayments roundSource.cage "folder" roundItems,[],[],[],[],[]⟩
def roundResult := afterFold roundSource roundTx

def restore_valid : stepValid (itemResult roundSource.cage (.write plainOutput (Witnesses.selected true)))
 ⟨6,7⟩ [] [] (Witnesses.selected true) restoreOutput := by
 simp only [roundSource,restoreCreate,restoreOutput,plainPending,plainCreate,plainOutput]
 finite_scenario

def round_accepted : foldAccepted roundTx := by
 refine ⟨by unfold Interval.valid; decide,by decide,rfl,rfl,?_,⟨rfl,rfl,rfl,rfl,rfl⟩⟩
 exact .cons _ _ _ _ plain_valid (.cons _ _ _ _ restore_valid (.nil _))

def round_step : Step roundSource (.fold roundTx) roundResult := by
 apply Step.fold roundSource roundTx rfl
 · intro o h
   change o ∈ [plainOutput,restoreOutput] at h
   change o ∈ [restoreOutput,plainOutput]
   rcases List.mem_cons.mp h with h | h
   · exact List.mem_cons_of_mem _ (List.mem_singleton.mpr h)
   · exact List.mem_cons.mpr (Or.inl (List.mem_singleton.mp h))
 · intro o h; change o ∈ ([] : List ClaimOutput) at h; contradiction
 · exact fun _ h => h
 · exact round_accepted
 · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
 · intro out h; change out ∈ [outputB] at h; change out ∈ [outputB]; exact h

def roundtrip_burn : Reachable roundSource ∧ Step roundSource (.fold roundTx) roundResult ∧
 roundSource.cage.trie "q" = some "value-q" ∧ roundResult.cage.trie "q" = some "value-q" ∧
 outputB ∈ roundSource.witnesses ∧ outputB ∉ roundResult.witnesses ∧
 roundTx.witnessInputs = [outputB] ∧ roundTx.witnessBurned = [outputB.token] ∧
 roundTx.payments = [⟨"folder","",10⟩,⟨"refund-B","",5⟩,⟨"folder","",10⟩] ∧
 itemChanges (atTurn roundTx 0) (.write plainOutput (Witnesses.selected true)) "q" :=
 ⟨round_source_reachable,round_step,rfl,rfl,by decide,by decide,rfl,rfl,rfl,by unfold itemChanges; decide⟩

def keepCreate := creation pending absentNoopOutput
def keepSource := afterCreate pending keepCreate absentNoopOutput

def keep_create_step : Step pending (.create keepCreate absentNoopOutput) keepSource := by
 apply Step.create pending keepCreate absentNoopOutput rfl
 · exact absentNoop_create_ok
 · simp [keepCreate,creation]
 · decide

def keep_source_reachable : Reachable keepSource := .next pending_reachable keep_create_step

def keepItems : List FoldItem := [.extract extraction,.write absentNoopOutput (Witnesses.selected true)]
def keepTx : FoldTx := withWitnessBoundary
 ⟨keepSource.cage,foldResult keepSource.cage keepItems,keepItems,[],[],⟨6,7⟩,
 "folder","anyone",keepItems.flatMap FoldItem.burned,foldPayments keepSource.cage "folder" keepItems,[],[],[],[],[]⟩
def keepResult := afterFold keepSource keepTx

def keep_accepted : foldAccepted keepTx := by
 refine ⟨by unfold Interval.valid; decide,by decide,rfl,rfl,?_,⟨rfl,rfl,rfl,rfl,rfl⟩⟩
 refine .cons _ _ _ _ ?_ (.cons _ _ _ _ absentNoop_valid (.nil _))
 exact ⟨extraction_wf,by unfold Interval.valid; decide,by decide,rfl,rfl⟩

def keep_step : Step keepSource (.fold keepTx) keepResult := by
 apply Step.fold keepSource keepTx rfl
 · intro o h; change o ∈ [absentNoopOutput] at h; change o ∈ [absentNoopOutput]; exact h
 · intro o h; change o ∈ ([] : List ClaimOutput) at h; contradiction
 · exact fun _ h => h
 · exact keep_accepted
 · intro o h; change o ∈ [extraction] at h; change o ∈ [extraction]; exact h
 · intro out h; change out ∈ ([] : List WitnessOutput) at h; contradiction

def intrafold_noop_keeps : Reachable keepSource ∧ Step keepSource (.fold keepTx) keepResult ∧
 keepResult.witnesses = [outputA] ∧ keepTx.witnessInputs = [] ∧
 keepTx.witnessBurned = [] ∧ keepTx.witnessMinted = [outputA.token] ∧
 keepTx.payments = [⟨"folder","",4⟩,⟨"folder","",10⟩] :=
 ⟨keep_source_reachable,keep_step,rfl,rfl,rfl,rfl,rfl⟩

def refund_without_issuer_signature : Reachable replacementPending ∧
 Step replacementPending (.fold replacementTx) replaced ∧ replacementTx.signers = [] ∧
 replacementTx.submitter = "folder" ∧ extraction.owner = "extractor" ∧
 ⟨"refund-A","",3⟩ ∈ replacementTx.payments :=
 ⟨replacement_pending_reachable,replacement_step,rfl,rfl,rfl,by decide⟩

/-- Repair F2: each terminality premise is instantiated on the reachable lifecycle. -/
def DW52 := DW27

def DW53 : Reachable pending ∧ Step pending (.fold extractTx) live ∧
 extraction ∈ extractTx.extractions ∧ Step pending (.fold accountTx) accountResult ∧
 extraction ∈ accountTx.extractions :=
 ⟨pending_reachable,extract_step,by decide,account_step,by decide⟩

def DW54 : Reachable live ∧ extraction.ref ∈ live.usedOutputs ∧ extraction ∉ live.extractions ∧
 History live unrelated :=
 ⟨live_reachable,by decide,by decide,.next unrelated_create_step (.next unrelated_step (.refl _))⟩

def DW55 : Reachable pending ∧ Step pending (.extractionWithdraw withdrawTx) withdrawn ∧
 withdrawTx.input = extraction ∧ History withdrawn withdrawn ∧
 Step pending (.fold extractTx) live ∧ extraction ∈ extractTx.extractions ∧ History live unrelated ∧
 Step pending (.fold accountTx) accountResult ∧ extraction ∈ accountTx.extractions ∧
 History accountResult accountResult :=
 ⟨pending_reachable,withdraw_step,rfl,.refl _,extract_step,by decide,DW54.2.2.2,
 account_step,by decide,.refl _⟩

def DW56 : Reachable refusedPending ∧
 itemAllowed refusedPending.cage ⟨10,15⟩ [] [] (.account refusedOutput (Witnesses.selected false)) :=
 ⟨refused_pending_reachable,refused_account_valid⟩

end RequestApprovalFold.DurableWitnesses
