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
  intro h
  exact ⟨h.2.2.2.2.1, h.2.1, h.2.2.2.1.1, h.2.2.2.1.2.2.2.1,
    h.2.2.2.1.2.2.2.2, h.2.2.2.2.2, h.2.2.1⟩

theorem step_rule_immutable {s s' : State} {a : Action} :
    Step s a s' → s'.cage.rule = s.cage.rule := by
  intro hs
  cases hs with
  | fold tx hc _ _ hf => simpa only [afterFold, hc] using hf.2.2.2.1
  | create => rfl
  | judge => rfl
  | account => rfl
  | withdraw => rfl
  | burn => rfl
  | priceMint => rfl
  | priceUpdate => rfl

theorem history_rule_immutable {s s' : State} :
    History s s' → s'.cage.rule = s.cage.rule := by
  intro h
  induction h with
  | refl => rfl
  | next hs _ ih => exact ih.trans (step_rule_immutable hs)

theorem reachable_rule_admitted (s : State) :
    Reachable s → ∀ o ∈ s.live, ∃ signers, ruleAdmits s.cage o.request signers := by
  intro hr
  induction hr with
  | registry => intro o ho; cases ho
  | @next s s' a _ hs ih =>
    have keep : ∀ o ∈ s.live, ∃ signers, ruleAdmits s'.cage o.request signers := by
      intro o ho
      simpa only [ruleAdmits, step_rule_immutable hs] using ih o ho
    intro o ho
    cases hs with
    | create tx created hc ha _ _ =>
      rcases List.mem_cons.mp ho with rfl | hm
      · exact ⟨tx.signers, by simpa only [afterCreate, hc] using ha.2.2.2.2.1⟩
      · exact keep o hm
    | judge => exact keep o ho
    | burn => exact keep o ho
    | priceMint => exact keep o ho
    | priceUpdate => exact keep o ho
    | fold => exact keep o (List.mem_filter.mp ho).1
    | account => exact keep o (List.mem_filter.mp ho).1
    | withdraw => exact keep o (List.mem_filter.mp ho).1

/-- Every exit is available under its lifecycle requirements, for any admission
    predicate. Fold conditions are stated at each actual prefix, without using
    the creation rule or an exit-acceptance helper as a premise. -/
theorem every_rule_allows_burn (s : State) (rule : Rule)
    (_hrule : s.cage.rule = some rule) :
    (∀ tx : FoldTx,
      tx.cageIn = s.cage →
      (∀ o ∈ tx.requests, o ∈ s.live) →
      (∀ name ∈ tx.refs, name ∈ s.judgments) →
      tx.cageOut.id = tx.cageIn.id →
      tx.cageOut.oracles = tx.cageIn.oracles →
      tx.cageOut.protocol = tx.cageIn.protocol →
      tx.cageOut.rule = tx.cageIn.rule →
      tx.requests.Nodup →
      tx.burned = tx.requests.flatMap tokensOf →
      tx.allocations = tx.requests.map (fun o => allocation tx.cageIn o tx.folder) →
      tx.cageOut.trie = applyAll tx.cageIn.trie (tx.requests.map (·.request.write)) →
      (∀ (i : Nat) (o : RequestOutput), tx.requests[i]? = some o →
        wellFormed tx.cageIn o ∧ tx.now < o.request.deadline ∧
        hasApproval tx.cageIn o.request tx.refs tx.signers tx.conditions ∧
        (∀ condition ∈ o.request.conditions,
          condition.holds (applyAll tx.cageIn.trie ((tx.requests.take i).map (·.request.write)))) ∧
        ∀ oracle ∈ tx.cageIn.oracles, ∀ condition ∈ tx.conditions o.request oracle,
          condition.holds (applyAll tx.cageIn.trie ((tx.requests.take i).map (·.request.write)))) →
      Step s (.fold tx) (afterFold s tx)) ∧
    (∀ tx : AccountTx,
      tx.cageRef = s.cage → tx.input ∈ s.live →
      (∀ name ∈ tx.refs, name ∈ s.judgments) →
      wellFormed tx.cageRef tx.input → hasAccount tx.cageRef tx.input.request tx.refs →
      tx.burned = tokensOf tx.input →
      tx.paid = allocation tx.cageRef tx.input tx.input.request.owner →
      tx.input.request.deadline ≤ tx.now →
      tx.now ≤ tx.input.request.deadline + tx.input.request.window →
      Step s (.account tx) (afterExit s tx.input)) ∧
    (∀ tx : WithdrawTx,
      tx.input ∈ s.live → tx.input.request.deadline + tx.input.request.window < tx.now →
      tx.input.request.owner ∈ tx.signers → tx.burned = tokensOf tx.input →
      tx.beneficiary = tx.input.request.owner → tx.paid = tx.input.value →
      Step s (.withdraw tx) (afterExit s tx.input)) ∧
    (∀ name ∈ s.judgments, Step s (.burn name) (afterBurn s name)) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · intro tx hc hl he hid ho hp hr hn hb ha ht hg
    apply Step.fold s tx hc hl he
    refine ⟨hid, ho, hp, hr, hn, hb, ha, ?_⟩
    have buildRun : ∀ (os : List RequestOutput) (t : Trie),
        (∀ (i : Nat) (o : RequestOutput), os[i]? = some o →
          wellFormed tx.cageIn o ∧ tx.now < o.request.deadline ∧
          hasApproval tx.cageIn o.request tx.refs tx.signers tx.conditions ∧
          (∀ condition ∈ o.request.conditions,
            condition.holds (applyAll t ((os.take i).map (·.request.write)))) ∧
          ∀ oracle ∈ tx.cageIn.oracles, ∀ condition ∈ tx.conditions o.request oracle,
            condition.holds (applyAll t ((os.take i).map (·.request.write)))) →
        FoldRun tx.cageIn tx.now tx.refs tx.signers tx.conditions t os
          (applyAll t (os.map (·.request.write))) := by
      intro os
      induction os with
      | nil => intro t _; exact .nil t
      | cons o os ih =>
        intro t guards
        apply FoldRun.cons
        · simpa only [List.take_zero, List.map_nil, applyAll] using guards 0 o rfl
        · apply ih (o.request.write.apply t)
          intro i out hout
          simpa only [List.take_succ_cons, List.map_cons, applyAll] using
            guards (i + 1) out (by simpa only [List.getElem?_cons_succ] using hout)
    rw [ht]
    exact buildRun tx.requests tx.cageIn.trie hg
  · intro tx hc hl he hw hv hb hp hlo hhi
    exact Step.account s tx hc hl he ⟨hw, hv, hb, hp, hlo, hhi⟩
  · intro tx hl ht hs hb hp hv
    exact Step.withdraw s tx hl ⟨ht, hs, hb, hp, hv⟩
  · intro name hn
    exact Step.burn s name hn

/-- The rule receives the request actually created and the actual creating signatures. -/
theorem creation_rule_input_binding {s s' : State} {tx : CreateTx} {o : RequestOutput}
    (rule : Rule) :
    Step s (.create tx o) s' → s.cage.rule = some rule →
      tx.outputs = [o] ∧ o ∈ s'.live ∧ rule.admits o.request tx.signers := by
  intro hs hr
  cases hs with
  | create tx o hc ha _ _ =>
    refine ⟨ha.2.1, List.mem_cons_self, ?_⟩
    simpa only [ruleAdmits, hc, hr] using ha.2.2.2.2.1

/-- The abstract minting and held-token policies agree with the registry's choice. -/
theorem creation_request_policy {s s' : State} {tx : CreateTx} {o : RequestOutput} :
    Step s (.create tx o) s' →
      tx.outputs = [o] ∧ o.requestTokens = [requestName s.cage.id] ∧
      requestName s.cage.id ∈ tx.minted ∧
      (∀ rule, s.cage.rule = some rule →
        tx.policy = .rule rule.hash ∧ o.policy = .rule rule.hash ∧
        tx.policy ≠ .release ∧ o.policy ≠ .release) ∧
      (s.cage.rule = none → tx.policy = .release ∧ o.policy = .release) := by
  intro hs
  cases hs with
  | create tx o hc ha _ _ =>
    have hm : tx.policy = requestPolicy s.cage := by
      simpa only [hc] using ha.2.2.2.2.2
    have ho : o.policy = requestPolicy s.cage := by
      simpa only [hc] using ha.2.2.2.1.2.2.2.2
    refine ⟨ha.2.1, ?_, ?_, ?_, ?_⟩
    · simpa only [hc] using ha.2.2.2.1.2.2.2.1
    · rw [ha.2.2.1, hc]
      simp
    · intro rule hr
      simp only [requestPolicy, hr] at hm ho
      exact ⟨hm, ho, by simp [hm], by simp [ho]⟩
    · intro hr
      simpa only [requestPolicy, hr] using And.intro hm ho

/-- The fold cannot re-evaluate a rule: replacing its predicate without changing
    its hash has no effect on the turn's checks. Creation still evaluates it. -/
theorem fold_rule_predicate_independent (c : CageState) (hash : String)
    (p q : Request → List Signer → Prop) (now : Time) (refs : List TokenName)
    (signers : List Signer) (conditions : OracleConditions) (t : Trie) (o : RequestOutput) :
    stepValid { c with rule := some ⟨hash, p⟩ } now refs signers conditions t o ↔
    stepValid { c with rule := some ⟨hash, q⟩ } now refs signers conditions t o := by
  rfl

theorem reachable_request_tokens (s : State) :
    Reachable s → ∀ o ∈ s.live,
      o.requestTokens = [⟨.request, .registry s.cage.id⟩] ∧
      o.policy = requestPolicy s.cage := by
  intro hr
  induction hr with
  | registry => intro o ho; cases ho
  | @next s s' a _ hs ih =>
    have keep : ∀ o ∈ s.live,
        o.requestTokens = [⟨.request, .registry s'.cage.id⟩] ∧ o.policy = requestPolicy s'.cage := by
      intro o ho
      simpa only [(step_preserves_registry hs).1, requestPolicy, step_rule_immutable hs] using ih o ho
    intro o ho
    cases hs with
    | create tx created hc ha _ _ =>
      rcases List.mem_cons.mp ho with rfl | hm
      · simpa only [afterCreate, hc] using ha.2.2.2.1.2.2.2
      · exact keep o hm
    | judge => exact keep o ho
    | burn => exact keep o ho
    | priceMint => exact keep o ho
    | priceUpdate => exact keep o ho
    | fold => exact keep o (List.mem_filter.mp ho).1
    | account => exact keep o (List.mem_filter.mp ho).1
    | withdraw => exact keep o (List.mem_filter.mp ho).1

theorem fold_requires_request_token (tx : FoldTx) :
    foldAccepted tx → ∀ o ∈ tx.requests,
      o.requestTokens = [⟨.request, .registry tx.cageIn.id⟩] ∧
      o.policy = requestPolicy tx.cageIn := by
  intro h o ho
  obtain ⟨t, hv⟩ := foldRun_step_valid h.2.2.2.2.2.2.2 o ho
  exact hv.1.2.2.2

theorem every_exit_burns_request_token (o : RequestOutput) (spend : RequestSpend) :
    requestSpendAllowed o spend → ∀ token ∈ o.requestTokens, token ∈ spend.burned := by
  intro hs token ht
  exact every_exit_burns_tag o spend hs token (List.mem_append_right _ ht)

theorem live_removal_burns_request_token {s s' : State} {a : Action} (o : RequestOutput) :
    Reachable s → Step s a s' → o ∈ s.live → o ∉ s'.live →
    ∃ spend, a.spend = some spend ∧ requestSpendAllowed o spend ∧
      (⟨.request, .registry s.cage.id⟩ : TokenName) ∈ spend.burned := by
  intro hr hs ho hn
  obtain ⟨spend, ha, hp, _⟩ := live_removal_is_legal_exit hs o ho hn
  refine ⟨spend, ha, hp, every_exit_burns_request_token o spend hp _ ?_⟩
  rw [(reachable_request_tokens s hr o ho).1]
  exact List.mem_cons_self

theorem request_name_injective (a b : CageId) : requestName a = requestName b ↔ a = b := by
  simp [requestName, tokenName]

theorem request_token_discovery (s : State) (id : CageId) (o : RequestOutput) :
    Reachable s →
      (o ∈ discoverRequests id s.live ↔ o ∈ s.live ∧ s.cage.id = id) := by
  intro hr
  simp only [discoverRequests, List.mem_filter, decide_eq_true_eq]
  constructor
  · rintro ⟨ho, ht⟩
    rw [(reachable_request_tokens s hr o ho).1] at ht
    have he : requestName id = requestName s.cage.id := List.mem_singleton.mp ht
    exact ⟨ho, ((request_name_injective id s.cage.id).mp he).symm⟩
  · rintro ⟨ho, hi⟩
    refine ⟨ho, ?_⟩
    rw [(reachable_request_tokens s hr o ho).1, hi]
    exact List.mem_cons_self

theorem request_token_discovery_across_registries (states : List State)
    (id : CageId) (o : RequestOutput) :
    (∀ s ∈ states, Reachable s) →
    (o ∈ discoverRequests id (states.flatMap State.live) ↔
      ∃ s ∈ states, o ∈ s.live ∧ s.cage.id = id) := by
  intro hr
  simp only [discoverRequests, List.mem_filter, decide_eq_true_eq, List.mem_flatMap]
  constructor
  · rintro ⟨⟨s, hs, ho⟩, ht⟩
    have hquery : o ∈ discoverRequests id s.live := List.mem_filter.mpr ⟨ho, by simpa using ht⟩
    exact ⟨s, hs, (request_token_discovery s id o (hr s hs)).mp hquery⟩
  · rintro ⟨s, hs, ho, hm⟩
    have hquery := (request_token_discovery s id o (hr s hs)).mpr ⟨ho, hm⟩
    exact ⟨⟨s, hs, ho⟩, by simpa using (List.mem_filter.mp hquery).2⟩

theorem output_refs_monotone {s s' : State} {a : Action} :
    Step s a s' → ∀ ref ∈ s.usedOutputs, ref ∈ s'.usedOutputs := by
  intro hs ref hm
  cases hs with
  | create => exact List.mem_cons_of_mem _ hm
  | judge => exact hm
  | fold => exact hm
  | account => exact hm
  | withdraw => exact hm
  | burn => exact hm
  | priceMint => exact hm
  | priceUpdate => exact hm

theorem reachable_output_refs (s : State) :
    Reachable s → ∀ o ∈ s.live, o.ref ∈ s.usedOutputs := by
  intro hr
  induction hr with
  | registry => intro o ho; cases ho
  | @next s s' a _ hs ih =>
    intro o ho
    cases hs with
    | create tx created _ _ _ _ =>
      rcases List.mem_cons.mp ho with rfl | hm
      · exact List.mem_cons_self
      · exact List.mem_cons_of_mem _ (ih o hm)
    | judge => exact ih o ho
    | burn => exact ih o ho
    | priceMint => exact ih o ho
    | priceUpdate => exact ih o ho
    | fold => exact ih o (List.mem_filter.mp ho).1
    | account => exact ih o (List.mem_filter.mp ho).1
    | withdraw => exact ih o (List.mem_filter.mp ho).1

theorem reachable_output_refs_unique (s : State) :
    Reachable s → (s.live.map RequestOutput.ref).Nodup := by
  intro hr
  induction hr with
  | registry => exact List.nodup_nil
  | @next s s' a hr hs ih =>
    cases hs with
    | create tx o _ _ _ hf =>
      change (o.ref :: s.live.map RequestOutput.ref).Nodup
      refine List.nodup_cons.mpr ⟨?_, ih⟩
      intro hm
      obtain ⟨q, hq, he⟩ := List.mem_map.mp hm
      exact hf (he ▸ reachable_output_refs s hr q hq)
    | judge => exact ih
    | burn => exact ih
    | priceMint => exact ih
    | priceUpdate => exact ih
    | fold => exact ih.sublist (List.Sublist.map _ (List.filter_sublist))
    | account => exact ih.sublist (List.Sublist.map _ (List.filter_sublist))
    | withdraw => exact ih.sublist (List.Sublist.map _ (List.filter_sublist))

theorem unguarded_registry_impossible (c : CageState) (existing : List CageId) :
    c.oracles = [] → c.rule = none → ¬ registryCreated c existing := by
  intro ho hr hc
  rcases hc.2.1.1 with hn | hs
  · exact hn ho
  · simp [hr] at hs

theorem zero_oracle_needs_rule (c : CageState) (existing : List CageId) :
    registryCreated c existing → c.oracles = [] → ∃ rule, c.rule = some rule := by
  intro hc ho
  cases he : c.rule with
  | none => exact False.elim (unguarded_registry_impossible c existing ho he hc)
  | some rule => exact ⟨rule, rfl⟩

theorem zero_oracle_evidence_empty (c : CageState) (r : Request) (conditions : OracleConditions) :
    c.oracles = [] → hasApproval c r [] [] conditions ∧ hasAccount c r [] := by
  intro ho
  constructor <;> intro oracle hm <;> rw [ho] at hm <;> cases hm

/-- No seed-spend input is required here, and there are no tags to mint. -/
theorem zero_oracle_creation_without_seed (c : CageState) (o : RequestOutput) (signers : List Signer) :
    c.oracles = [] → wellFormed c o → ruleAdmits c o.request signers →
    createAllowed ⟨[], c, [requestName c.id], [o], signers, requestPolicy c⟩ o := by
  intro ho hw ha
  exact ⟨fun hn => False.elim (hn ho), rfl, by simp [ho], hw, ha, rfl⟩

theorem zero_oracle_fold_without_approvals (c : CageState) (o : RequestOutput)
    (now : Time) (t : Trie) (conditions : OracleConditions) :
    c.oracles = [] → wellFormed c o → now < o.request.deadline →
    (∀ condition ∈ o.request.conditions, condition.holds t) →
    FoldRun c now [] [] conditions t [o] (o.request.write.apply t) := by
  intro ho hw ht hc
  apply FoldRun.cons
  · refine ⟨hw, ht, ?_, hc, ?_⟩
    · intro oracle hm; rw [ho] at hm; cases hm
    · intro oracle hm; rw [ho] at hm; cases hm
  exact FoldRun.nil _

theorem zero_oracle_account_without_verdicts (s : State) (o : RequestOutput) (now : Time) :
    s.cage.oracles = [] → o ∈ s.live → wellFormed s.cage o →
    o.request.deadline ≤ now → now ≤ o.request.deadline + o.request.window →
    Step s (.account ⟨s.cage, o, [], now, "anyone", tokensOf o,
      allocation s.cage o o.request.owner⟩) (afterExit s o) := by
  intro ho hl hw hlo hhi
  apply Step.account s _ rfl hl
  · intro name hm; cases hm
  · refine ⟨hw, ?_, rfl, rfl, hlo, hhi⟩
    intro oracle hm; rw [ho] at hm; cases hm

theorem present_condition_semantics (t : Trie) (k : Key) :
    (Condition.present k).holds t ↔ ∃ v, t k = some v := by
  rfl

theorem foldRun_oracle_conditions {c : CageState} {now : Time} {refs : List TokenName}
    {signers : List Signer} {conditions : OracleConditions} {t t' : Trie} {os : List RequestOutput} :
    FoldRun c now refs signers conditions t os t' →
    ∀ n o, os[n]? = some o → ∀ oracle ∈ c.oracles,
      ∀ condition ∈ conditions o.request oracle,
        condition.holds (applyAll t ((os.take n).map (·.request.write))) := by
  intro h
  induction h with
  | nil => intro n o ho; simp at ho
  | cons t o' os t' hv _ ih =>
    intro n o ho
    cases n with
    | zero =>
      simp at ho
      subst o
      exact hv.2.2.2.2
    | succ n =>
      simp only [List.getElem?_cons_succ] at ho
      simpa [List.take_succ_cons, applyAll] using ih n o ho

theorem fold_all_conditions_hold (tx : FoldTx) :
    foldAccepted tx → ∀ n o, tx.requests[n]? = some o →
      (∀ condition ∈ o.request.conditions,
        condition.holds (applyAll tx.cageIn.trie ((tx.requests.take n).map (·.request.write)))) ∧
      (∀ oracle ∈ tx.cageIn.oracles, ∀ condition ∈ tx.conditions o.request oracle,
        condition.holds (applyAll tx.cageIn.trie ((tx.requests.take n).map (·.request.write)))) := by
  intro h n o ho
  exact ⟨fold_conditions_hold_when_applied tx h n o ho,
    foldRun_oracle_conditions h.2.2.2.2.2.2.2 n o ho⟩

theorem approval_conditions_cannot_change (c : CageId) (r : Request) (oracle : Signer)
    (a b : List Condition) :
    judgmentName c r oracle true a = judgmentName c r oracle true b ↔ a = b := by
  simp [judgmentName, tokenName]

/-- Staleness is about the selected approval at its actual turn, not expiry. -/
theorem stale_approval_unusable (tx : FoldTx) (n : Nat) (o : RequestOutput)
    (oracle : Signer) (condition : Condition) :
    tx.requests[n]? = some o → oracle ∈ tx.cageIn.oracles →
    condition ∈ tx.conditions o.request oracle →
    ¬ condition.holds (applyAll tx.cageIn.trie ((tx.requests.take n).map (·.request.write))) →
    ¬ foldAccepted tx := by
  intro hn hm hc hfalse hf
  exact hfalse ((fold_all_conditions_hold tx hf n o hn).2 oracle hm condition hc)

theorem fold_evidence_binds_conditions {s s' : State} (tx : FoldTx) :
    Step s (.fold tx) s' → ∀ o ∈ tx.requests, ∀ oracle ∈ tx.cageIn.oracles,
      judgmentName tx.cageIn.id o.request oracle true (tx.conditions o.request oracle) ∈ s.judgments ∨
      oracle ∈ tx.signers := by
  intro hs o ho oracle hm
  cases hs with
  | fold _ _ _ href ha =>
    rcases (fold_only_approved_before_deadline tx ha o ho).2.2 oracle hm with htoken | hsign
    · exact Or.inl (href _ htoken)
    · exact Or.inr hsign

/-- Each selected condition-bearing approval has an exact, deterministic name. -/
theorem expected_approval_lookup (c : CageState) (r : Request) (conditions : OracleConditions)
    (refs : List TokenName) :
    hasApproval c r refs [] conditions ↔ ∀ name ∈ expectedApprovals c r conditions, name ∈ refs := by
  constructor
  · intro h name hm
    obtain ⟨oracle, ho, rfl⟩ := List.mem_map.mp hm
    rcases h oracle ho with ht | hs
    · exact ht
    · cases hs
  · intro h oracle ho
    exact Or.inl (h _ (List.mem_map.mpr ⟨oracle, ho, rfl⟩))

/-- Both directions, relative to the complete authenticated finite inventory.
    The trie parameter may be the result of any already applied batch prefix. -/
theorem folder_discovery_exact (s : State) (now : Time) (signers : List Signer)
    (conditions : OracleConditions) (t : Trie) (o : RequestOutput) :
    Reachable s →
    (folderFinds s now signers conditions t o ↔
      o ∈ s.live ∧ stepValid s.cage now s.judgments signers conditions t o) := by
  intro hr
  unfold folderFinds
  rw [request_token_discovery s s.cage.id o hr]
  simp only [and_true]
  rfl

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
  intro hr
  rw [folder_discovery_exact s now signers conditions s.cage.trie o hr]
  constructor
  · rintro ⟨hl, hv⟩
    apply Step.fold s _ rfl
    · intro q hq
      have he : q = o := List.mem_singleton.mp hq
      exact he ▸ hl
    · intro name hm; exact hm
    · exact ⟨rfl, rfl, rfl, rfl, by simp [singletonFold], by simp [singletonFold], rfl,
        .cons _ _ _ _ hv (.nil _)⟩
  · intro hs
    cases hs with
    | fold _ _ hl _ ha =>
      refine ⟨hl o List.mem_cons_self, ?_⟩
      have hrun := ha.2.2.2.2.2.2.2
      cases hrun with
      | cons _ _ _ _ hv _ => exact hv

theorem empty_fold_allowed (s : State) (now : Time) (submitter : Signer) :
    Step s (.fold ⟨s.cage, s.cage, [], [], [], now, submitter, noOracleConditions,
      submitter, [], []⟩) s := by
  let tx : FoldTx := ⟨s.cage, s.cage, [], [], [], now, submitter, noOracleConditions,
    submitter, [], []⟩
  have hs : Step s (.fold tx) (afterFold s tx) := by
    apply Step.fold s tx rfl
    · intro o ho; cases ho
    · intro name hn; cases hn
    · exact ⟨rfl, rfl, rfl, rfl, List.nodup_nil, rfl, rfl, .nil _⟩
  have hfilter : s.live.filter (fun _ => true) = s.live :=
    List.filter_eq_self.mpr (fun _ _ => rfl)
  simpa [afterFold, removeRequests, tx, hfilter] using hs

theorem empty_fold_earns_nothing (tx : FoldTx) :
    foldAccepted tx → tx.requests = [] → tx.allocations = [] ∧ tx.burned = [] ∧
      tx.cageOut.trie = tx.cageIn.trie := by
  intro h hn
  refine ⟨?_, ?_, ?_⟩
  · simpa only [hn, List.map_nil] using h.2.2.2.2.2.2.1
  · simpa only [hn, List.flatMap_nil] using h.2.2.2.2.2.1
  · simpa only [hn, List.map_nil, applyAll] using fold_root_is_folded_writes tx h

end RequestApprovalFold
