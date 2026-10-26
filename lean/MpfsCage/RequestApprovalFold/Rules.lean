import MpfsCage.RequestApprovalFold.TagsPricesWitnesses

namespace RequestApprovalFold

/-! Rules, request-token authenticity and condition-bearing approval discovery.
    All claims concern the abstract machine and authenticated finite inventory. -/

theorem creation_rule_and_token (tx : CreateTx) (o : RequestOutput) :
    createAllowed tx o →
      ruleAdmits tx.cageRef o.request tx.signers ∧
      tx.outputs = [o] ∧ o.request.cage = tx.cageRef.id ∧
      o.requestTokens = [⟨.request, .registry tx.cageRef.id⟩] ∧
      o.policy = requestPolicy tx.cageRef ∧ tx.policy = requestPolicy tx.cageRef ∧
      tx.minted = tx.cageRef.oracles.map tagName ++ [⟨.request, .registry tx.cageRef.id⟩] := by
  sorry

theorem step_rule_immutable {s s' : State} {a : Action} :
    Step s a s' → s'.cage.rule = s.cage.rule := by
  sorry

theorem history_rule_immutable {s s' : State} :
    History s s' → s'.cage.rule = s.cage.rule := by
  sorry

theorem reachable_rule_admitted (s : State) :
    Reachable s → ∀ o ∈ s.live, ∃ signers, ruleAdmits s.cage o.request signers := by
  sorry

theorem every_rule_allows_burn (rule : Rule) : ruleBurnAllowed rule := by
  sorry

/-- The fold cannot re-evaluate a rule: replacing its predicate without changing
    its hash has no effect on the turn's checks. Creation still evaluates it. -/
theorem fold_rule_predicate_independent (c : CageState) (hash : String)
    (p q : Request → List Signer → Prop) (now : Time) (refs : List TokenName)
    (signers : List Signer) (conditions : OracleConditions) (t : Trie) (o : RequestOutput) :
    stepValid { c with rule := some ⟨hash, p⟩ } now refs signers conditions t o ↔
    stepValid { c with rule := some ⟨hash, q⟩ } now refs signers conditions t o := by
  sorry

theorem reachable_request_tokens (s : State) :
    Reachable s → ∀ o ∈ s.live,
      o.requestTokens = [⟨.request, .registry s.cage.id⟩] ∧
      o.policy = requestPolicy s.cage := by
  sorry

theorem fold_requires_request_token (tx : FoldTx) :
    foldAccepted tx → ∀ o ∈ tx.requests,
      o.requestTokens = [⟨.request, .registry tx.cageIn.id⟩] ∧
      o.policy = requestPolicy tx.cageIn := by
  sorry

theorem every_exit_burns_request_token (o : RequestOutput) (spend : RequestSpend) :
    requestSpendAllowed o spend → ∀ token ∈ o.requestTokens, token ∈ spend.burned := by
  sorry

theorem live_removal_burns_request_token {s s' : State} {a : Action} (o : RequestOutput) :
    Reachable s → Step s a s' → o ∈ s.live → o ∉ s'.live →
    ∃ spend, a.spend = some spend ∧ requestSpendAllowed o spend ∧
      (⟨.request, .registry s.cage.id⟩ : TokenName) ∈ spend.burned := by
  sorry

theorem request_name_injective (a b : CageId) : requestName a = requestName b ↔ a = b := by
  sorry

theorem request_token_discovery (s : State) (id : CageId) (o : RequestOutput) :
    Reachable s →
      (o ∈ discoverRequests id s.live ↔ o ∈ s.live ∧ s.cage.id = id) := by
  sorry

theorem request_token_discovery_across_registries (states : List State)
    (id : CageId) (o : RequestOutput) :
    (∀ s ∈ states, Reachable s) →
    (o ∈ discoverRequests id (states.flatMap State.live) ↔
      ∃ s ∈ states, o ∈ s.live ∧ s.cage.id = id) := by
  sorry

theorem output_refs_monotone {s s' : State} {a : Action} :
    Step s a s' → ∀ ref ∈ s.usedOutputs, ref ∈ s'.usedOutputs := by
  sorry

theorem reachable_output_refs (s : State) :
    Reachable s → ∀ o ∈ s.live, o.ref ∈ s.usedOutputs := by
  sorry

theorem reachable_output_refs_unique (s : State) :
    Reachable s → (s.live.map RequestOutput.ref).Nodup := by
  sorry

theorem unguarded_registry_impossible (c : CageState) (existing : List CageId) :
    c.oracles = [] → c.rule = none → ¬ registryCreated c existing := by
  sorry

theorem zero_oracle_needs_rule (c : CageState) (existing : List CageId) :
    registryCreated c existing → c.oracles = [] → ∃ rule, c.rule = some rule := by
  sorry

theorem zero_oracle_evidence_empty (c : CageState) (r : Request) (conditions : OracleConditions) :
    c.oracles = [] → hasApproval c r [] [] conditions ∧ hasAccount c r [] := by
  sorry

/-- No seed-spend input is required here, and there are no tags to mint. -/
theorem zero_oracle_creation_without_seed (c : CageState) (o : RequestOutput) (signers : List Signer) :
    c.oracles = [] → wellFormed c o → ruleAdmits c o.request signers →
    createAllowed ⟨[], c, [requestName c.id], [o], signers, requestPolicy c⟩ o := by
  sorry

theorem zero_oracle_fold_without_approvals (c : CageState) (o : RequestOutput)
    (now : Time) (t : Trie) (conditions : OracleConditions) :
    c.oracles = [] → wellFormed c o → now < o.request.deadline →
    (∀ condition ∈ o.request.conditions, condition.holds t) →
    FoldRun c now [] [] conditions t [o] (o.request.write.apply t) := by
  sorry

theorem zero_oracle_account_without_verdicts (s : State) (o : RequestOutput) (now : Time) :
    s.cage.oracles = [] → o ∈ s.live → wellFormed s.cage o →
    o.request.deadline ≤ now → now ≤ o.request.deadline + o.request.window →
    Step s (.account ⟨s.cage, o, [], now, "anyone", tokensOf o,
      allocation s.cage o o.request.owner⟩) (afterExit s o) := by
  sorry

theorem present_condition_semantics (t : Trie) (k : Key) :
    (Condition.present k).holds t ↔ ∃ v, t k = some v := by
  sorry

theorem foldRun_oracle_conditions {c : CageState} {now : Time} {refs : List TokenName}
    {signers : List Signer} {conditions : OracleConditions} {t t' : Trie} {os : List RequestOutput} :
    FoldRun c now refs signers conditions t os t' →
    ∀ n o, os[n]? = some o → ∀ oracle ∈ c.oracles,
      ∀ condition ∈ conditions o.request oracle,
        condition.holds (applyAll t ((os.take n).map (·.request.write))) := by
  sorry

theorem fold_all_conditions_hold (tx : FoldTx) :
    foldAccepted tx → ∀ n o, tx.requests[n]? = some o →
      (∀ condition ∈ o.request.conditions,
        condition.holds (applyAll tx.cageIn.trie ((tx.requests.take n).map (·.request.write)))) ∧
      (∀ oracle ∈ tx.cageIn.oracles, ∀ condition ∈ tx.conditions o.request oracle,
        condition.holds (applyAll tx.cageIn.trie ((tx.requests.take n).map (·.request.write)))) := by
  sorry

theorem approval_conditions_cannot_change (c : CageId) (r : Request) (oracle : Signer)
    (a b : List Condition) :
    judgmentName c r oracle true a = judgmentName c r oracle true b ↔ a = b := by
  sorry

/-- Staleness is about the selected approval at its actual turn, not expiry. -/
theorem stale_approval_unusable (tx : FoldTx) (n : Nat) (o : RequestOutput)
    (oracle : Signer) (condition : Condition) :
    tx.requests[n]? = some o → oracle ∈ tx.cageIn.oracles →
    condition ∈ tx.conditions o.request oracle →
    ¬ condition.holds (applyAll tx.cageIn.trie ((tx.requests.take n).map (·.request.write))) →
    ¬ foldAccepted tx := by
  sorry

theorem fold_evidence_binds_conditions {s s' : State} (tx : FoldTx) :
    Step s (.fold tx) s' → ∀ o ∈ tx.requests, ∀ oracle ∈ tx.cageIn.oracles,
      judgmentName tx.cageIn.id o.request oracle true (tx.conditions o.request oracle) ∈ s.judgments ∨
      oracle ∈ tx.signers := by
  sorry

/-- Each selected condition-bearing approval has an exact, deterministic name. -/
theorem expected_approval_lookup (c : CageState) (r : Request) (conditions : OracleConditions)
    (refs : List TokenName) :
    hasApproval c r refs [] conditions ↔ ∀ name ∈ expectedApprovals c r conditions, name ∈ refs := by
  sorry

/-- Both directions, relative to the complete authenticated finite inventory.
    The trie parameter may be the result of any already applied batch prefix. -/
theorem folder_discovery_exact (s : State) (now : Time) (signers : List Signer)
    (conditions : OracleConditions) (t : Trie) (o : RequestOutput) :
    Reachable s →
    (folderFinds s now signers conditions t o ↔
      o ∈ s.live ∧ stepValid s.cage now s.judgments signers conditions t o) := by
  sorry

def singletonFold (s : State) (now : Time) (signers : List Signer)
    (conditions : OracleConditions) (o : RequestOutput) (folder : Signer) : FoldTx :=
  ⟨s.cage, { s.cage with trie := o.request.write.apply s.cage.trie }, [o],
    s.judgments, signers, now, folder, conditions, folder, tokensOf o,
    [allocation s.cage o folder]⟩

theorem folder_discovery_executable (s : State) (now : Time) (signers : List Signer)
    (conditions : OracleConditions) (o : RequestOutput) (folder : Signer) :
    Reachable s →
    (folderFinds s now signers conditions s.cage.trie o ↔
      Step s (.fold (singletonFold s now signers conditions o folder))
        (afterFold s (singletonFold s now signers conditions o folder))) := by
  sorry

theorem empty_fold_allowed (s : State) (now : Time) (submitter : Signer) :
    Step s (.fold ⟨s.cage, s.cage, [], [], [], now, submitter, noOracleConditions,
      submitter, [], []⟩) s := by
  sorry

theorem empty_fold_earns_nothing (tx : FoldTx) :
    foldAccepted tx → tx.requests = [] → tx.allocations = [] ∧ tx.burned = [] ∧
      tx.cageOut.trie = tx.cageIn.trie := by
  sorry

end RequestApprovalFold
