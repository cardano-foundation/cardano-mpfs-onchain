import MpfsCage.RequestApprovalFold.Model

namespace RequestApprovalFold

/-! Statements frozen together before PROOFS. The ledger names each row's
    reachable antecedent example and proposed single-definition mutant. -/

theorem applyAll_append (t : Trie) (xs ys : List Write) :
    applyAll t (xs ++ ys) = applyAll (applyAll t xs) ys := by
  induction xs generalizing t with
  | nil => rfl
  | cons w ws ih => exact ih (w.apply t)

theorem foldRun_step_valid {c : CageState} {now : Time} {refs : List TokenName}
    {signers : List Signer} {t t' : Trie} {os : List RequestOutput}
    (h : FoldRun c now refs signers t os t') :
    ∀ o ∈ os, ∃ t0, stepValid c now refs signers t0 o := by
  induction h with
  | nil => intro o ho; cases ho
  | cons t o' os t' hv _ ih =>
    intro o ho
    cases ho with
    | head => exact ⟨t, hv⟩
    | tail _ hm => exact ih o hm

theorem foldRun_result {c : CageState} {now : Time} {refs : List TokenName}
    {signers : List Signer} {t t' : Trie} {os : List RequestOutput}
    (h : FoldRun c now refs signers t os t') :
    t' = applyAll t (os.map (·.request.write)) := by
  induction h with
  | nil => rfl
  | cons _ _ _ _ _ _ ih => exact ih

theorem foldRun_conditions {c : CageState} {now : Time} {refs : List TokenName}
    {signers : List Signer} {t t' : Trie} {os : List RequestOutput}
    (h : FoldRun c now refs signers t os t') :
    ∀ (n : Nat) (o : RequestOutput), os[n]? = some o → ∀ condition ∈ o.request.conditions,
      condition.holds (applyAll t ((os.take n).map (·.request.write))) := by
  induction h with
  | nil => intro n o ho; simp at ho
  | cons t o' os t' hv _ ih =>
    intro n o ho
    cases n with
    | zero =>
      simp at ho
      subst o
      exact hv.2.2.2
    | succ n =>
      simp only [List.getElem?_cons_succ] at ho
      simpa [List.take_succ_cons, applyAll] using ih n o ho

theorem applyAll_keeps_present (k : Key) :
    ∀ (ws : List Write) (t : Trie), (∀ w ∈ ws, w ≠ .unset k) →
      (t k).isSome → (applyAll t ws k).isSome := by
  intro ws
  induction ws with
  | nil => intro t _ h; exact h
  | cons w ws ih =>
    intro t hw h
    apply ih (w.apply t) (fun w' hm => hw w' (List.mem_cons_of_mem _ hm))
    have hne := hw w List.mem_cons_self
    cases w with
    | set k' v =>
      simp only [Write.apply]
      split <;> simp_all
    | unset k' =>
      simp only [Write.apply]
      split
      · rename_i heq; subst heq; exact absurd rfl hne
      · exact h

theorem registry_creation (c : CageState) (existing : List CageId) :
    registryCreated c existing → c.id ∉ existing ∧ c.oracles ≠ [] ∧
      c.oracles.Nodup ∧ c.trie = emptyTrie := by
  intro ⟨h, ⟨hn, hd⟩, ht⟩
  exact ⟨h, hn, hd, ht⟩

theorem create_tags_existing_cage (tx : CreateTx) (o : RequestOutput) :
    createAllowed tx o → tx.outputs = [o] ∧
      tx.cageRef.id = o.request.cage ∧
      tx.minted = [tagName o.request.cage] ∧
      o.tags = [tagName o.request.cage] ∧ o.request.seed ∈ tx.spent ∧
      totalFees tx.cageRef o.request ≤ o.value := by
  intro ⟨hs, ho, hm, hc, ht, hf⟩
  exact ⟨ho, hc.symm, by simpa [hc] using hm, by simpa [hc] using ht, hs, hf⟩

theorem requests_unique_in_history (history : List CreateTx)
    (a b : CreateTx) (oa ob : RequestOutput) :
    SpentOnce history → a ∈ history → b ∈ history →
    createAllowed a oa → createAllowed b ob → a ≠ b →
    oa.request ≠ ob.request := by
  intro hs ha hb ca cb hne heq
  apply hne
  have hsa := ca.1
  rw [heq] at hsa
  exact hs a b _ ha hb hsa cb.1

theorem judgment_authorized_and_bound (tx : JudgmentTx) :
    judgmentAllowed tx → tx.oracle ∈ tx.cageRef.oracles ∧
      tx.oracle ∈ tx.signers ∧ tx.requestRef.request.cage = tx.cageRef.id ∧
      tx.now < tx.requestRef.request.deadline ∧ tx.spent = [] ∧
      tx.minted = [judgmentName tx.cageRef.id tx.requestRef.request tx.oracle tx.approve] := by
  intro ⟨hc, ho, hs, ht, hp, hm⟩
  exact ⟨ho, hs, hc, ht, hp, hm⟩

theorem judgment_not_replayable (c c' : CageId) (r r' : Request)
    (oracle oracle' : Signer) (verdict verdict' : Bool) :
    judgmentName c r oracle verdict = judgmentName c' r' oracle' verdict' →
      c = c' ∧ r = r' ∧ r.seed = r'.seed ∧ oracle = oracle' ∧ verdict = verdict' := by
  intro h
  cases h
  exact ⟨rfl, rfl, rfl, rfl, rfl⟩

theorem token_roles_separated (c c' : CageId) (r : Request)
    (oracle : Signer) (verdict : Bool) :
    tagName c ≠ judgmentName c' r oracle verdict := by
  intro h
  cases h

theorem fold_preserves_registry (tx : FoldTx) :
    foldAccepted tx → tx.cageOut.id = tx.cageIn.id ∧
      tx.cageOut.oracles = tx.cageIn.oracles ∧
      tx.cageOut.protocol = tx.cageIn.protocol := by
  intro ⟨hi, ho, hp, _⟩
  exact ⟨hi, ho, hp⟩

theorem step_preserves_registry {s s' : State} (h : Step s s') :
    s'.cage.id = s.cage.id ∧ s'.cage.oracles = s.cage.oracles ∧
      s'.cage.protocol = s.cage.protocol := by
  cases h with
  | create => exact ⟨rfl, rfl, rfl⟩
  | judge => exact ⟨rfl, rfl, rfl⟩
  | account => exact ⟨rfl, rfl, rfl⟩
  | withdraw => exact ⟨rfl, rfl, rfl⟩
  | burn => exact ⟨rfl, rfl, rfl⟩
  | fold tx hc _ _ hf => simpa [afterFold, hc] using fold_preserves_registry tx hf

theorem history_preserves_registry {s s' : State} (h : History s s') :
    s'.cage.id = s.cage.id ∧ s'.cage.oracles = s.cage.oracles ∧
      s'.cage.protocol = s.cage.protocol := by
  induction h with
  | refl => exact ⟨rfl, rfl, rfl⟩
  | next hs _ ih =>
    obtain ⟨hi, ho, hp⟩ := step_preserves_registry hs
    exact ⟨ih.1.trans hi, ih.2.1.trans ho, ih.2.2.trans hp⟩

theorem only_fold_changes_tree {s s' : State} (h : Step s s') :
    s'.cage.trie ≠ s.cage.trie →
      ∃ tx, foldAccepted tx ∧ tx.cageIn = s.cage ∧ s' = afterFold s tx := by
  intro hne
  cases h with
  | fold tx hc _ _ hf => exact ⟨tx, hf, hc, rfl⟩
  | create => exact False.elim (hne rfl)
  | judge => exact False.elim (hne rfl)
  | account => exact False.elim (hne rfl)
  | withdraw => exact False.elim (hne rfl)
  | burn => exact False.elim (hne rfl)

theorem fold_only_approved_before_deadline (tx : FoldTx) :
    foldAccepted tx → ∀ o ∈ tx.requests,
      o.request.cage = tx.cageIn.id ∧ tx.now < o.request.deadline ∧
      hasApproval tx.cageIn o.request tx.refs tx.signers := by
  intro ⟨_, _, _, _, _, _, hr⟩ o ho
  obtain ⟨_, hv⟩ := foldRun_step_valid hr o ho
  exact ⟨hv.1.1, hv.2.1, hv.2.2.1⟩

theorem fold_conditions_hold_when_applied (tx : FoldTx) :
    foldAccepted tx → ∀ (n : Nat) (o : RequestOutput), tx.requests[n]? = some o →
      ∀ condition ∈ o.request.conditions,
        condition.holds (applyAll tx.cageIn.trie
          ((tx.requests.take n).map (·.request.write))) := by
  intro ⟨_, _, _, _, _, _, hr⟩
  exact foldRun_conditions hr

theorem fold_root_is_folded_writes (tx : FoldTx) :
    foldAccepted tx → tx.cageOut.trie =
      applyAll tx.cageIn.trie (tx.requests.map (·.request.write)) := by
  intro ⟨_, _, _, _, _, _, hr⟩
  exact foldRun_result hr

theorem fold_burns_tags (tx : FoldTx) :
    foldAccepted tx → tx.burned = tx.requests.flatMap tokensOf := by
  intro ⟨_, _, _, _, hb, _⟩
  exact hb

theorem fold_pays_and_keeps_rest (tx : FoldTx) :
    foldAccepted tx → ∀ o ∈ tx.requests,
      allocation tx.cageIn o tx.folder ∈ tx.allocations ∧
      ∀ oracle ∈ tx.cageIn.oracles,
        (oracle, o.request.fee oracle) ∈ (allocation tx.cageIn o tx.folder).oracles := by
  intro ⟨_, _, _, _, _, hp, _⟩ o ho
  constructor
  · rw [hp]
    exact List.mem_map.mpr ⟨o, ho, rfl⟩
  · intro oracle hm
    exact List.mem_map.mpr ⟨oracle, hm, rfl⟩

theorem allocation_conserves_value (c : CageState) (o : RequestOutput) (to : Signer) :
    wellFormed c o →
      ((allocation c o to).oracles.map Prod.snd).sum +
        (allocation c o to).remainder = o.value := by
  intro ⟨_, _, hf⟩
  have he : ((allocation c o to).oracles.map Prod.snd).sum = totalFees c o.request := by
    simp [allocation, oraclePayments, totalFees, List.map_map, Function.comp_def]
  rw [he]
  change totalFees c o.request + (o.value - totalFees c o.request) = o.value
  omega

theorem blind_write_folds_on_any_tree (c : CageState) (now : Time)
    (refs : List TokenName) (signers : List Signer) (o : RequestOutput) (t : Trie) :
    wellFormed c o → now < o.request.deadline →
    hasApproval c o.request refs signers → o.request.conditions = [] →
    FoldRun c now refs signers t [o] (o.request.write.apply t) := by
  intro hw ht ha hc
  refine FoldRun.cons t o [] _ ⟨hw, ht, ha, ?_⟩ (FoldRun.nil _)
  intro condition hm
  rw [hc] at hm
  cases hm

theorem fold_permissionless (tx : FoldTx) (other : Signer) :
    foldAccepted tx → foldAccepted { tx with submitter := other } := by
  exact fun h => h

/-- An accepted prefix ending in a set cannot reach a later absent condition
    without an intervening unset. `middle` is the exact intervening segment. -/
theorem absent_inserts_exclusive (c : CageState) (now : Time)
    (refs : List TokenName) (signers : List Signer) (t t' : Trie)
    (a b : RequestOutput) (middle tail : List RequestOutput) (k : Key) (v : Val) :
    FoldRun c now refs signers t (a :: (middle ++ b :: tail)) t' →
    a.request.write = .set k v → Condition.absent k ∈ b.request.conditions →
    ∃ q ∈ middle, q.request.write = .unset k := by
  intro hr hset habsent
  have impossible : ∀ (ms : List RequestOutput) (u u' : Trie),
      FoldRun c now refs signers u (ms ++ b :: tail) u' →
      (u k).isSome → (∀ q ∈ ms, q.request.write ≠ .unset k) → False := by
    intro ms
    induction ms with
    | nil =>
      intro u u' hrun hp _
      cases hrun with
      | cons _ _ _ _ hv _ =>
        have hn := hv.2.2.2 (.absent k) habsent
        change u k = none at hn
        rw [hn] at hp
        contradiction
    | cons q qs ih =>
      intro u u' hrun hp hno
      cases hrun with
      | cons _ _ _ _ _ hrest =>
        apply ih (q.request.write.apply u) u' hrest
        · have hkeep := applyAll_keeps_present k [q.request.write] u
            (by intro w hw; simp only [List.mem_singleton] at hw; subst w
                exact hno q List.mem_cons_self) hp
          exact hkeep
        · intro q' hm
          exact hno q' (List.mem_cons_of_mem _ hm)
  by_cases hex : ∃ q ∈ middle, q.request.write = .unset k
  · exact hex
  · cases hr with
    | cons _ _ _ _ _ hrest =>
      apply False.elim
      apply impossible middle (a.request.write.apply t) t' hrest
      · simp [hset, Write.apply]
      · intro q hm he
        exact hex ⟨q, hm, he⟩

theorem account_complete_and_pays (tx : AccountTx) :
    accountAllowed tx → hasAccount tx.cageRef tx.input.request tx.refs ∧
      tx.burned = tokensOf tx.input ∧
      tx.paid = allocation tx.cageRef tx.input tx.input.request.owner := by
  intro ⟨_, ha, hb, hp⟩
  exact ⟨ha, hb, hp⟩

theorem account_anyone_anytime (tx : AccountTx) (now : Time) (other : Signer) :
    accountAllowed tx → accountAllowed { tx with now := now, submitter := other } := by
  exact fun h => h

theorem account_fee_neutral (a b : AccountTx) :
    accountAllowed a → accountAllowed b →
    a.cageRef = b.cageRef → a.input = b.input → a.paid = b.paid := by
  intro ha hb hc hi
  rw [ha.2.2.2, hb.2.2.2, hc, hi]

theorem withdraw_only_owner_after_window (tx : WithdrawTx) :
    withdrawAllowed tx → tx.input.request.owner ∈ tx.signers ∧
      tx.input.request.deadline + tx.input.request.window < tx.now ∧
      tx.burned = tokensOf tx.input ∧ tx.beneficiary = tx.input.request.owner ∧
      tx.paid = tx.input.value := by
  intro ⟨ht, hs, hb, ho, hp⟩
  exact ⟨hs, ht, hb, ho, hp⟩

theorem owner_can_withdraw_everything (o : RequestOutput) (now : Time) :
    o.request.deadline + o.request.window < now →
    withdrawAllowed ⟨o, now, [o.request.owner], tokensOf o, o.request.owner, o.value⟩ := by
  intro ht
  exact ⟨ht, List.mem_cons_self, rfl, rfl, rfl⟩

theorem request_spent_only_by_lifecycle (o : RequestOutput) (spend : RequestSpend) :
    requestSpendAllowed o spend →
      (∃ tx, spend = .folded tx ∧ foldAccepted tx ∧ o ∈ tx.requests) ∨
      (∃ tx, spend = .accounted tx ∧ accountAllowed tx ∧ tx.input = o) ∨
      (∃ tx, spend = .withdrawn tx ∧ withdrawAllowed tx ∧ tx.input = o) := by
  intro h
  cases spend with
  | folded tx => exact Or.inl ⟨tx, rfl, h.1, h.2⟩
  | accounted tx => exact Or.inr (Or.inl ⟨tx, rfl, h.1, h.2⟩)
  | withdrawn tx => exact Or.inr (Or.inr ⟨tx, rfl, h.1, h.2⟩)

theorem every_exit_burns_tag (o : RequestOutput) (spend : RequestSpend) :
    requestSpendAllowed o spend → ∀ tag ∈ tokensOf o, tag ∈ spend.burned := by
  intro h tag ht
  cases spend with
  | folded tx =>
    change tag ∈ tx.burned
    rw [fold_burns_tags tx h.1]
    exact List.mem_flatMap.mpr ⟨o, h.2, ht⟩
  | accounted tx =>
    change tag ∈ tx.burned
    rw [h.1.2.2.1, h.2]
    exact ht
  | withdrawn tx =>
    change tag ∈ tx.burned
    rw [h.1.2.2.1, h.2]
    exact ht

theorem early_exit_requires_all_judgments (o : RequestOutput) (spend : RequestSpend) :
    requestSpendAllowed o spend → spend.now ≤ o.request.deadline + o.request.window →
    ∃ c, spend.cage = some c ∧
      ∀ oracle ∈ c.oracles, spend.evidence o.request oracle := by
  intro h ht
  cases spend with
  | folded tx =>
    exact ⟨tx.cageIn, rfl, (fold_only_approved_before_deadline tx h.1 o h.2).2.2⟩
  | accounted tx =>
    refine ⟨tx.cageRef, rfl, ?_⟩
    simpa only [RequestSpend.evidence, h.2] using h.1.2.1
  | withdrawn tx =>
    have hlate := h.1.1
    rw [h.2] at hlate
    change tx.now ≤ o.request.deadline + o.request.window at ht
    exact False.elim (Nat.not_lt_of_ge ht hlate)

/-- Stronger than the approved-oracle guarantee: every oracle is paid on
    every early exit, even without non-equivocation. -/
theorem early_exit_pays_every_oracle (o : RequestOutput) (spend : RequestSpend) :
    requestSpendAllowed o spend → spend.now ≤ o.request.deadline + o.request.window →
    ∃ c, spend.cage = some c ∧
      ∀ oracle ∈ c.oracles, spend.pays c o oracle := by
  intro h ht
  cases spend with
  | folded tx =>
    refine ⟨tx.cageIn, rfl, ?_⟩
    intro oracle hm
    obtain ⟨ha, hp⟩ := fold_pays_and_keeps_rest tx h.1 o h.2
    exact ⟨rfl, allocation tx.cageIn o tx.folder, ha, rfl, hp oracle hm⟩
  | accounted tx =>
    refine ⟨tx.cageRef, rfl, ?_⟩
    intro oracle hm
    change tx.cageRef.id = tx.cageRef.id ∧ tx.paid.input = o ∧ _
    rw [h.1.2.2.2, h.2]
    exact ⟨rfl, rfl, List.mem_map.mpr ⟨oracle, hm, rfl⟩⟩
  | withdrawn tx =>
    have hlate := h.1.1
    rw [h.2] at hlate
    change tx.now ≤ o.request.deadline + o.request.window at ht
    exact False.elim (Nat.not_lt_of_ge ht hlate)

/-- Non-equivocation additionally forces an issued approval to be disclosed
    in a complete account; it cannot be substituted with a refusal. -/
theorem owner_cannot_hide_approval (tx : AccountTx) (issued : List TokenName)
    (oracle : Signer) :
    accountAllowed tx → NonEquivocating issued →
    (∀ name ∈ tx.refs, name ∈ issued) → oracle ∈ tx.cageRef.oracles →
    judgmentName tx.cageRef.id tx.input.request oracle true ∈ issued →
    judgmentName tx.cageRef.id tx.input.request oracle true ∈ tx.refs := by
  intro ha hn href ho happ
  obtain ⟨v, hv⟩ := ha.2.1 oracle ho
  cases v with
  | true => exact hv
  | false => exact False.elim (hn _ _ _ happ (href _ hv))

theorem dead_judgment_can_burn (s : State) (c : CageId) (r : Request)
    (oracle : Signer) (verdict : Bool) :
    judgmentName c r oracle verdict ∈ s.judgments →
    (∀ o ∈ s.live, o.request ≠ r) →
    Step s (afterBurn s (judgmentName c r oracle verdict)) ∧
      (afterBurn s (judgmentName c r oracle verdict)).live = s.live ∧
      (afterBurn s (judgmentName c r oracle verdict)).cage = s.cage := by
  intro hm _
  exact ⟨Step.burn s _ hm, rfl, rfl⟩

theorem judgments_do_not_consume (s : State) (tx : JudgmentTx) :
    (afterJudgment s tx).live = s.live ∧ (afterJudgment s tx).cage = s.cage := by
  exact ⟨rfl, rfl⟩

theorem exits_remove_consumed (s : State) (o : RequestOutput) :
    o ∉ (afterExit s o).live := by
  simp [afterExit, removeRequests]

theorem fold_removes_consumed (s : State) (tx : FoldTx) (o : RequestOutput) :
    o ∈ tx.requests → o ∉ (afterFold s tx).live := by
  intro ho
  simp [afterFold, removeRequests, ho]

theorem used_seeds_monotone {s s' : State} (h : Step s s') :
    ∀ seed ∈ s.usedSeeds, seed ∈ s'.usedSeeds := by
  intro seed hm
  cases h with
  | create => exact List.mem_append_right _ hm
  | judge => exact hm
  | fold => exact hm
  | account => exact hm
  | withdraw => exact hm
  | burn => exact hm

theorem reachable_requests_have_spent_seeds (s : State) :
    Reachable s → ∀ o ∈ s.live, o.request.seed ∈ s.usedSeeds := by
  intro hr
  induction hr with
  | registry => intro o ho; cases ho
  | @next s s' hr hs ih =>
    intro o ho
    cases hs with
    | create tx created hc hcreate hfresh =>
      change o ∈ created :: _ at ho
      rcases List.mem_cons.mp ho with he | hm
      · subst o
        exact List.mem_append_left _ hcreate.1
      · exact List.mem_append_right _ (ih o hm)
    | judge => exact ih o ho
    | burn => exact ih o ho
    | fold =>
      exact ih o (List.mem_filter.mp ho).1
    | account =>
      exact ih o (List.mem_filter.mp ho).1
    | withdraw =>
      exact ih o (List.mem_filter.mp ho).1

theorem spent_seed_cannot_create_again (s : State) (tx : CreateTx) (o : RequestOutput) :
    o.request.seed ∈ s.usedSeeds → createAllowed tx o →
    ¬ (∀ seed ∈ tx.spent, seed ∉ s.usedSeeds) := by
  intro hs hc hf
  exact hf _ hc.1 hs

/-- A consumed live request is never live again along a subsequent history. -/
theorem request_never_reappears (s s' : State) (o : RequestOutput) :
    History s s' → o.request.seed ∈ s.usedSeeds → o ∉ s.live → o ∉ s'.live := by
  intro hh
  induction hh with
  | refl => intro _ hn; exact hn
  | @next s t u hs hh ih =>
    intro hseed hgone
    apply ih (used_seeds_monotone hs _ hseed)
    intro hm
    cases hs with
    | create tx created hc hcreate hfresh =>
      change o ∈ created :: _ at hm
      rcases List.mem_cons.mp hm with he | hm
      · subst o
        exact hfresh _ hcreate.1 hseed
      · exact hgone hm
    | judge => exact hgone hm
    | burn => exact hgone hm
    | fold => exact hgone (List.mem_filter.mp hm).1
    | account => exact hgone (List.mem_filter.mp hm).1
    | withdraw => exact hgone (List.mem_filter.mp hm).1

theorem one_oracle_signature_suffices (c : CageState) (r : Request) (oracle : Signer) :
    c.oracles = [oracle] → hasApproval c r [] [oracle] := by
  intro hc oracle' hm
  rw [hc] at hm
  exact Or.inr hm

theorem old_operations_correspond (op : OldOperation) (t : Trie) :
    op.write.apply t = op.apply t ∧
      (match op with
       | .insert k _ => op.condition.holds t ↔ t k = none
       | .delete k v => op.condition.holds t ↔ t k = some v
       | .update k v _ => op.condition.holds t ↔ t k = some v) := by
  cases op <;> exact ⟨rfl, Iff.rfl⟩

/-- Inversion at the authoritative state machine: disappearance is an exit,
    not merely an arbitrary externally supplied RequestSpend value. -/
theorem live_removal_is_legal_exit {s s' : State} (h : Step s s') (o : RequestOutput) :
    o ∈ s.live → o ∉ s'.live → ∃ spend, requestSpendAllowed o spend := by
  intro hm hgone
  cases h with
  | create => exact False.elim (hgone (List.mem_cons_of_mem _ hm))
  | judge => exact False.elim (hgone hm)
  | burn => exact False.elim (hgone hm)
  | fold tx hc hl hj hf =>
    refine ⟨.folded tx, hf, ?_⟩
    by_cases ho : o ∈ tx.requests
    · exact ho
    · exact False.elim (hgone (List.mem_filter.mpr ⟨hm, by simpa using ho⟩))
  | account tx hc hl hj ha =>
    by_cases he : tx.input = o
    · exact ⟨.accounted tx, ha, he⟩
    · exact False.elim (hgone (List.mem_filter.mpr ⟨hm, by simp only [decide_eq_true_eq, List.mem_singleton]; exact Ne.symm he⟩))
  | withdraw tx hl hw =>
    by_cases he : tx.input = o
    · exact ⟨.withdrawn tx, hw, he⟩
    · exact False.elim (hgone (List.mem_filter.mpr ⟨hm, by simp only [decide_eq_true_eq, List.mem_singleton]; exact Ne.symm he⟩))

theorem new_judgment_is_authorized {s s' : State} (h : Step s s') (name : TokenName) :
    name ∈ s'.issued → name ∉ s.issued →
    ∃ tx, judgmentAllowed tx ∧ tx.cageRef = s.cage ∧
      tx.requestRef ∈ s.live ∧ name ∈ tx.minted := by
  intro hm hn
  cases h with
  | judge tx hc hl hj =>
    rcases List.mem_append.mp hm with hnew | hold
    · exact ⟨tx, hj, hc, hl, hnew⟩
    · exact False.elim (hn hold)
  | create => exact False.elim (hn hm)
  | fold => exact False.elim (hn hm)
  | account => exact False.elim (hn hm)
  | withdraw => exact False.elim (hn hm)
  | burn => exact False.elim (hn hm)

end RequestApprovalFold
