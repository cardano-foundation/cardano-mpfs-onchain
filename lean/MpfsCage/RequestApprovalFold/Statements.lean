import MpfsCage.RequestApprovalFold.ProofHelpers
import MpfsCage.RequestApprovalFold.Witnesses
import MpfsCage.OracleIdentity.Statements

/-! Proofs against the 142 statements accepted at c569165 (NOTE-003).
The ledger distinguishes axiom-checked PROVED rows from the remaining OPEN
rows, whose original admitted proof bodies are preserved. -/
namespace RequestApprovalFold

theorem applyAll_append (t : Trie) (xs ys : List Write) : applyAll t (xs ++ ys) = applyAll (applyAll t xs) ys := by
  induction xs generalizing t with
  | nil => rfl
  | cons w ws ih => exact ih (w.apply t)

theorem foldRun_step_valid {iv : Interval} {refs : List TokenName} {sigs : List Signer} {c out : CageState} {items : List FoldItem} :
 FoldRun iv refs sigs c items out → ∀ n item, items[n]? = some item →
 itemAllowed (foldResult c (items.take n)) iv refs sigs item := by
  intro h
  induction h with
  | nil => simp
  | cons c i rest out hi hr ih =>
    intro n item hn
    cases n with
    | zero => simp only [List.getElem?_cons_zero, Option.some.injEq] at hn; subst item; exact hi
    | succ n => exact ih n item hn

theorem foldRun_result {iv : Interval} {refs : List TokenName} {sigs : List Signer} {c out : CageState} {items : List FoldItem} :
 FoldRun iv refs sigs c items out → out = foldResult c items := by
  intro h
  induction h with
  | nil => rfl
  | cons c i rest out _ _ ih => exact ih

theorem foldRun_conditions {iv : Interval} {refs : List TokenName} {sigs : List Signer} {c out : CageState} {items : List FoldItem} :
 FoldRun iv refs sigs c items out → ∀ n o e, items[n]? = some (FoldItem.write o e) →
 ∀ condition ∈ o.request.conditions, condition.holds (foldResult c (items.take n)).trie := by
  intro h n o e hn
  exact (foldRun_step_valid h n (.write o e) hn).2.2.2.2.1

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

theorem registry_creation (c : CageState) (existing : List CageId) : registryCreated c existing →
 c.id ∉ existing ∧ (c.oracles ≠ [] ∨ c.rule.isSome) ∧ c.oracles.Nodup ∧ 0 < c.minimum ∧ c.trie = emptyTrie ∧ c.balances = (fun _ => 0) ∧ c.value = 0 := by
  intro h
  exact ⟨h.1, h.2.1.1, h.2.1.2.1, h.2.1.2.2, h.2.2⟩

theorem create_tags_existing_cage (tx : CreateTx) (o : RequestOutput) : createAllowed tx o →
 (tx.cageRef.oracles ≠ [] → o.request.seed ∈ tx.spent) ∧ tx.outputs = [o] ∧
 tx.minted = tx.cageRef.oracles.map tagName ++ [requestName tx.cageRef.id] ∧
 o.request.cage = tx.cageRef.id ∧ o.tags = tx.cageRef.oracles.map tagName ∧
 totalFees tx.cageRef o.request + tx.cageRef.minimum ≤ o.value := by
  intro h
  exact ⟨h.1, h.2.1, h.2.2.1, h.2.2.2.1.1, h.2.2.2.1.2.1, h.2.2.2.1.2.2.1⟩

theorem requests_unique_in_history (history : List CreateTx)
    (a b : CreateTx) (oa ob : RequestOutput) :
    SpentOnce history → a ∈ history → b ∈ history →
    createAllowed a oa → createAllowed b ob → a.cageRef.oracles ≠ [] →
    b.cageRef.oracles ≠ [] → a ≠ b →
    oa.request ≠ ob.request := by
  intro hs ha hb hca hcb hna hnb hne heq
  apply hne
  apply hs a b oa.request.seed ha hb (hca.1 hna)
  rw [heq]
  exact hcb.1 hnb

theorem judgment_authorized_and_bound (tx : JudgmentTx) : judgmentAllowed tx →
 tx.oracle ∈ tx.cageRef.oracles ∧
 OracleIdentity.authorize tx.oracle tx.evidence.description tx.signers = some tx.evidence.record ∧
 tx.interval.valid ∧ tx.interval.upper < tx.requestRef.request.deadline ∧ tx.spent = [] ∧
 tx.requestRef.request.cage = tx.cageRef.id ∧
 tx.minted = [judgmentName tx.cageRef.id tx.requestRef.request tx.oracle tx.evidence.approve
   tx.evidence.record tx.evidence.conditions] := by
  intro h
  refine ⟨h.2.1, ?_, h.2.2.2.2.1, h.2.2.2.2.2.1, h.2.2.2.2.2.2.1, h.1, h.2.2.2.2.2.2.2⟩
  exact h.2.2.1 ▸ h.2.2.2.1

theorem judgment_not_replayable (c c' : CageId) (r r' : Request) (o o' : Oracle) (v v' : Bool)
 (rec rec' : SigningRecord) (cs cs' : List Condition) :
 judgmentName c r o v rec cs = judgmentName c' r' o' v' rec' cs' →
 c = c' ∧ r = r' ∧ o = o' ∧ v = v' ∧ rec = rec' ∧ (v = true → cs = cs') := by
  cases v <;> cases v' <;> simp_all [judgmentName, tokenName, TokenName.mk.injEq, NameBinding.judgment.injEq]

theorem token_roles_separated (o o' : Oracle) (c : CageId) (r : Request) (v : Bool) (rec : SigningRecord) (cs : List Condition) :
 tagName o ≠ judgmentName c r o' v rec cs := by
  cases v <;> simp [tagName, judgmentName, tokenName, TokenName.mk.injEq]

theorem fold_preserves_registry (tx : FoldTx) : foldAccepted tx → SameRegistry tx.cageOut tx.cageIn := by
  intro h
  rw [foldRun_result h.2.2.2.2]
  exact ProofHelpers.result_registry _ _

theorem step_preserves_registry {s s' : State} {a : Action} : Step s a s' → SameRegistry s'.cage s.cage := by
  intro h
  cases h <;> try exact ProofHelpers.registry_refl _
  rename_i tx hc _ _ _ ha
  exact hc ▸ fold_preserves_registry tx ha

theorem history_preserves_registry {s s' : State} : History s s' → SameRegistry s'.cage s.cage := by
  intro h
  induction h with
  | refl => exact ProofHelpers.registry_refl _
  | next hs _ ih => exact ProofHelpers.registry_trans ih (step_preserves_registry hs)

theorem only_fold_changes_tree {s s' : State} {a : Action} : Step s a s' →
 s'.cage.trie ≠ s.cage.trie → ∃ tx, a = .fold tx ∧ foldAccepted tx ∧
 tx.cageIn = s.cage ∧ s' = afterFold s tx := by
  intro h hn
  cases h <;> try exact False.elim (hn rfl)
  rename_i tx hc _ _ _ ha
  exact ⟨tx, rfl, ha, hc, rfl⟩

theorem fold_only_approved_before_deadline (tx : FoldTx) : foldAccepted tx → ∀ n o e,
 tx.items[n]? = some (FoldItem.write o e) → o.request.cage = tx.cageIn.id ∧
 tx.interval.upper < o.request.deadline ∧ hasApproval (atTurn tx n) o.request tx.refs tx.signers e := by
  intro h n o e hn
  have hi := foldRun_step_valid h.2.2.2.2 n (.write o e) hn
  have hr := ProofHelpers.result_registry tx.cageIn (tx.items.take n)
  exact ⟨hi.1.1.trans hr.1, hi.2.2.1, hi.2.2.2.1⟩

theorem fold_conditions_hold_when_applied (tx : FoldTx) : foldAccepted tx → ∀ n o e,
 tx.items[n]? = some (FoldItem.write o e) → ∀ condition ∈ o.request.conditions, condition.holds (atTurn tx n).trie := by
  intro h
  exact foldRun_conditions h.2.2.2.2

theorem fold_root_is_folded_writes (tx : FoldTx) : foldAccepted tx →
 tx.cageOut.trie = applyAll tx.cageIn.trie (tx.items.flatMap FoldItem.writes) := by
  intro h
  rw [foldRun_result h.2.2.2.2]
  exact ProofHelpers.result_trie _ _

theorem fold_burns_tags (tx : FoldTx) : foldAccepted tx → tx.burned = tx.items.flatMap FoldItem.burned := by
  exact fun h => h.2.2.1

theorem fold_pays_and_keeps_rest (tx : FoldTx) : foldAccepted tx → ∀ n o e,
 tx.items[n]? = some (FoldItem.write o e) →
 (itemResult (atTurn tx n) (.write o e)).balances = (fun k => (atTurn tx n).balances k + OracleIdentity.paidTo (credits (atTurn tx n) o.request e) k) ∧
 itemPayments (atTurn tx n) tx.folder (FoldItem.write o e) = [⟨tx.folder, "", o.value - totalFees tx.cageIn o.request⟩] ∧
 ∀ oracle ∈ tx.cageIn.oracles,
 OracleIdentity.totalPaid (oracleCredits o.request oracle (e oracle)) = o.request.fee oracle := by
  intro h n o e hn
  have hi := foldRun_step_valid h.2.2.2.2 n (.write o e) hn
  have hr := ProofHelpers.result_registry tx.cageIn (tx.items.take n)
  refine ⟨rfl, ?_, ?_⟩
  · simp only [itemPayments, remainder, atTurn, ProofHelpers.fees_registry hr]
  · intro oracle ho
    exact ProofHelpers.oracle_total _ _ _ ((hi.2.2.2.1 oracle (hr.2.1 ▸ ho)).1)

theorem allocation_conserves_value (c : CageState) (iv : Interval) (refs : List TokenName)
 (sigs : List Signer) (o : RequestOutput) (e : Selection) :
 (stepValid c iv refs sigs e o ∨ accountAllowed c iv refs o e) →
 o.value = OracleIdentity.totalPaid (credits c o.request e) + remainder c o := by
  intro h
  have hw : wellFormed c o := h.elim (fun h => h.1) (fun h => h.1)
  have ha : ∀ oracle ∈ c.oracles, (e oracle).authorized oracle :=
    h.elim (fun h o ho => (h.2.2.2.1 o ho).1) (fun h o ho => (h.2.2.2.2 o ho).1)
  rw [ProofHelpers.credits_total c o.request e ha]
  unfold remainder
  have := hw.2.2.1
  omega

theorem blind_write_folds_on_any_tree (c : CageState) (iv : Interval) (refs : List TokenName)
 (sigs : List Signer) (o : RequestOutput) (e : Selection) :
 wellFormed c o → iv.valid → iv.upper < o.request.deadline → hasApproval c o.request refs sigs e →
 o.request.conditions = [] → (∀ oracle ∈ c.oracles, (e oracle).conditions = []) →
 ∀ t, FoldRun iv refs sigs { c with trie := t } [FoldItem.write o e]
 (itemResult { c with trie := t } (FoldItem.write o e)) ∧
 (itemResult { c with trie := t } (FoldItem.write o e)).trie = o.request.write.apply t := by
  intro hw hv ht ha hc he t
  refine ⟨FoldRun.cons _ _ [] _ ?_ (FoldRun.nil _), rfl⟩
  refine ⟨hw, hv, ht, ha, ?_, ?_⟩
  · simp [hc]
  · intro oracle ho; simp [he oracle ho]

theorem fold_permissionless (tx : FoldTx) (other : Signer) :
 foldAccepted tx → foldAccepted { tx with submitter := other } := by
  exact fun h => h

theorem absent_inserts_exclusive (tx : FoldTx) (n m : Nat) (a b : RequestOutput) (ea eb : Selection) (k : Key) (v : Val) :
 foldAccepted tx → n < m → tx.items[n]? = some (FoldItem.write a ea) → tx.items[m]? = some (FoldItem.write b eb) →
 a.request.write = .set k v → Condition.absent k ∈ b.request.conditions →
 Write.unset k ∈ ((tx.items.drop (n + 1)).take (m - (n + 1))).flatMap FoldItem.writes := by
  sorry

theorem account_complete_and_pays (tx : FoldTx) : foldAccepted tx → ∀ n o e,
 tx.items[n]? = some (FoldItem.account o e) → hasAccount (atTurn tx n) o.request tx.refs e ∧
 (itemResult (atTurn tx n) (.account o e)).balances = (fun k => (atTurn tx n).balances k + OracleIdentity.paidTo (credits (atTurn tx n) o.request e) k) ∧
 (itemResult (atTurn tx n) (FoldItem.account o e)).trie = (atTurn tx n).trie ∧
 itemPayments (atTurn tx n) tx.folder (FoldItem.account o e) = [⟨o.request.owner, "", remainder tx.cageIn o⟩] ∧
 OracleIdentity.totalPaid (credits (atTurn tx n) o.request e) = totalFees tx.cageIn o.request := by
  intro h n o e hn
  have hi := foldRun_step_valid h.2.2.2.2 n (.account o e) hn
  have hr := ProofHelpers.result_registry tx.cageIn (tx.items.take n)
  refine ⟨hi.2.2.2.2, rfl, rfl, ?_, ?_⟩
  · simp only [itemPayments, remainder, atTurn, ProofHelpers.fees_registry hr]
  · unfold atTurn
    rw [ProofHelpers.credits_total _ _ _ (fun oracle ho => (hi.2.2.2.2 oracle ho).1)]
    exact ProofHelpers.fees_registry hr o.request

theorem account_anyone_in_window (s : State) (o : RequestOutput) (e : Selection) (iv : Interval) (who : Signer) :
 o ∈ s.live → wellFormed s.cage o → hasAccount s.cage o.request s.judgments e →
 iv.valid → o.request.deadline ≤ iv.lower → iv.upper ≤ o.request.deadline + o.request.window →
 Step s (.fold (singletonFold s iv [] (FoldItem.account o e) who))
 (afterFold s (singletonFold s iv [] (FoldItem.account o e) who)) := by
  intro hl hw ha hv ht hu
  apply Step.fold s _ rfl
  · simpa [singletonFold, FoldTx.requests, FoldItem.request] using hl
  · simp [singletonFold, FoldTx.claims, FoldItem.claimInput]
  · exact fun _ h => h
  · exact ProofHelpers.singleton_accepted s iv [] (.account o e) who hv ⟨hw, hv, ht, hu, ha⟩

theorem account_fee_neutral (c : CageState) (iv : Interval) (ra rb : List TokenName)
 (o : RequestOutput) (a b : Selection) (folder : Signer) :
 accountAllowed c iv ra o a → accountAllowed c iv rb o b →
 itemPayments c folder (FoldItem.account o a) = itemPayments c folder (FoldItem.account o b) ∧
 (itemResult c (FoldItem.account o a)).trie = (itemResult c (FoldItem.account o b)).trie ∧
 OracleIdentity.totalPaid (credits c o.request a) = OracleIdentity.totalPaid (credits c o.request b) ∧
 (∀ oracle ∈ c.oracles, OracleIdentity.totalPaid (oracleCredits o.request oracle (a oracle)) =
   OracleIdentity.totalPaid (oracleCredits o.request oracle (b oracle))) ∧
 ((∀ oracle ∈ c.oracles, (a oracle).record = (b oracle).record) →
   itemResult c (FoldItem.account o a) = itemResult c (FoldItem.account o b)) := by
  intro ha hb
  have hta := ProofHelpers.credits_total c o.request a (fun oracle ho => (ha.2.2.2.2 oracle ho).1)
  have htb := ProofHelpers.credits_total c o.request b (fun oracle ho => (hb.2.2.2.2 oracle ho).1)
  refine ⟨rfl,rfl,hta.trans htb.symm,?_,?_⟩
  · intro oracle ho
    exact (ProofHelpers.oracle_total _ _ _ (ha.2.2.2.2 oracle ho).1).trans
      (ProofHelpers.oracle_total _ _ _ (hb.2.2.2.2 oracle ho).1).symm
  · intro hr
    have hc : credits c o.request a = credits c o.request b := by
      unfold credits
      rw [List.flatMap_def, List.flatMap_def]
      apply congrArg List.flatten
      apply List.map_congr_left
      intro oracle ho
      have haa := (ha.2.2.2.2 oracle ho).1
      have hab := (hb.2.2.2.2 oracle ho).1
      change OracleIdentity.authorize oracle (a oracle).description (a oracle).signers = some (a oracle).record at haa
      change OracleIdentity.authorize oracle (b oracle).description (b oracle).signers = some (b oracle).record at hab
      simp [oracleCredits,OracleIdentity.splitFee,haa,hab,hr oracle ho]
    simp only [itemResult,hc]

theorem withdraw_only_owner_after_window (tx : WithdrawTx) : withdrawAllowed tx →
 tx.input.request.owner ∈ tx.signers ∧ tx.input.request.deadline + tx.input.request.window < tx.interval.lower ∧
 tx.interval.valid ∧ tx.burned = tokensOf tx.input ∧ tx.beneficiary = tx.input.request.owner ∧ tx.paid = tx.input.value := by
  intro h
  exact ⟨h.2.2.1, h.2.1, h.1, h.2.2.2⟩

theorem owner_can_withdraw_everything (o : RequestOutput) (iv : Interval) :
 iv.valid → o.request.deadline + o.request.window < iv.lower →
 withdrawAllowed ⟨o, iv, [o.request.owner], tokensOf o, o.request.owner, o.value⟩ := by
  intro hv ht
  exact ⟨hv, ht, by simp, rfl, rfl, rfl⟩

theorem request_spent_only_by_lifecycle (o : RequestOutput) (spend : RequestSpend) : requestSpendAllowed o spend →
 (∃ tx e, spend = .folded tx ∧ foldAccepted tx ∧ FoldItem.write o e ∈ tx.items) ∨
 (∃ tx e, spend = .folded tx ∧ foldAccepted tx ∧ FoldItem.account o e ∈ tx.items) ∨
 (∃ tx, spend = .withdrawn tx ∧ withdrawAllowed tx ∧ tx.input = o) := by
  intro h
  cases spend with
  | folded tx =>
    rcases (ProofHelpers.request_member tx o).mp h.2 with ⟨e, he⟩ | ⟨e, he⟩
    · exact Or.inl ⟨tx, e, rfl, h.1, he⟩
    · exact Or.inr (Or.inl ⟨tx, e, rfl, h.1, he⟩)
  | withdrawn tx => exact Or.inr (Or.inr ⟨tx, rfl, h⟩)

theorem every_exit_burns_tag (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → ∀ tag ∈ tokensOf o, tag ∈ spend.burned := by
  intro h tag ht
  cases spend with
  | folded tx =>
    rw [show (RequestSpend.folded tx).burned = tx.burned from rfl, h.1.2.2.1]
    rcases (ProofHelpers.request_member tx o).mp h.2 with ⟨e, he⟩ | ⟨e, he⟩
    · exact List.mem_flatMap.mpr ⟨.write o e, he, ht⟩
    · exact List.mem_flatMap.mpr ⟨.account o e, he, ht⟩
  | withdrawn tx => simpa only [RequestSpend.burned, h.1.2.2.2.1, h.2] using ht

theorem early_exit_requires_all_judgments (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → spend.interval.lower ≤ o.request.deadline + o.request.window →
 ∃ (tx : FoldTx) (n : Nat) (e : Selection), spend = .folded tx ∧
 ((tx.items[n]? = some (FoldItem.write o e) ∧ hasApproval (atTurn tx n) o.request tx.refs tx.signers e) ∨
 (tx.items[n]? = some (FoldItem.account o e) ∧ hasAccount (atTurn tx n) o.request tx.refs e)) := by
  intro h ht
  rcases request_spent_only_by_lifecycle o spend h with ⟨tx,e,rfl,hf,hi⟩ | ⟨tx,e,rfl,hf,hi⟩ | ⟨tx,rfl,hf,he⟩
  · obtain ⟨n, hn⟩ := List.mem_iff_getElem?.mp hi
    exact ⟨tx,n,e,rfl,Or.inl ⟨hn,(fold_only_approved_before_deadline tx hf n o e hn).2.2⟩⟩
  · obtain ⟨n, hn⟩ := List.mem_iff_getElem?.mp hi
    exact ⟨tx,n,e,rfl,Or.inr ⟨hn,(account_complete_and_pays tx hf n o e hn).1⟩⟩
  · have hm := hf.2.1
    simp only [RequestSpend.interval,he,Time] at hm ht
    omega

theorem early_exit_pays_every_oracle (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → spend.interval.lower ≤ o.request.deadline + o.request.window →
 ∃ (tx : FoldTx) (n : Nat) (e : Selection), spend = .folded tx ∧
 (tx.items[n]? = some (FoldItem.write o e) ∨ tx.items[n]? = some (FoldItem.account o e)) ∧
 (∀ item, tx.items[n]? = some item → (itemResult (atTurn tx n) item).balances =
 (fun k => (atTurn tx n).balances k + OracleIdentity.paidTo (credits (atTurn tx n) o.request e) k)) ∧
 ∀ oracle ∈ tx.cageIn.oracles,
 OracleIdentity.totalPaid (oracleCredits o.request oracle (e oracle)) = o.request.fee oracle := by
  intro h ht
  obtain ⟨tx,n,e,rfl,hi⟩ := early_exit_requires_all_judgments o spend h ht
  rcases hi with ⟨hn,_⟩ | ⟨hn,_⟩
  · have hp := fold_pays_and_keeps_rest tx h.1 n o e hn
    refine ⟨tx,n,e,rfl,Or.inl hn,?_,hp.2.2⟩
    intro item he
    have heq := Option.some.inj (hn.symm.trans he)
    subst item
    rfl
  · have hi := foldRun_step_valid h.1.2.2.2.2 n (.account o e) hn
    refine ⟨tx,n,e,rfl,Or.inr hn,?_,?_⟩
    · intro item he
      have heq := Option.some.inj (hn.symm.trans he)
      subst item
      rfl
    · intro oracle ho
      exact ProofHelpers.oracle_total _ _ _ ((hi.2.2.2.2 oracle
        ((ProofHelpers.result_registry tx.cageIn (tx.items.take n)).2.1 ▸ ho)).1)

theorem before_deadline_only_approvals (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → spend.interval.lower < o.request.deadline →
 ∃ (tx : FoldTx) (n : Nat) (e : Selection), spend = .folded tx ∧ tx.items[n]? = some (FoldItem.write o e) ∧
 hasApproval (atTurn tx n) o.request tx.refs tx.signers e := by
  intro h ht
  have hu : spend.interval.lower ≤ o.request.deadline + o.request.window := by simp only [Time] at *; omega
  obtain ⟨tx,n,e,rfl,hi⟩ := early_exit_requires_all_judgments o spend h hu
  rcases hi with ⟨hn,ha⟩ | ⟨hn,_⟩
  · exact ⟨tx,n,e,rfl,hn,ha⟩
  · have hb := (foldRun_step_valid h.1.2.2.2.2 n (.account o e) hn).2.2.1
    simp only [RequestSpend.interval,Time] at ht hb
    omega

theorem dead_judgment_can_burn (s : State) (c : CageId) (r : Request) (o : Oracle)
 (v : Bool) (rec : SigningRecord) (cs : List Condition) :
 judgmentName c r o v rec cs ∈ s.judgments → (∀ output ∈ s.live, output.request ≠ r) →
 Step s (.burn (judgmentName c r o v rec cs)) (afterBurn s (judgmentName c r o v rec cs)) ∧
 (afterBurn s (judgmentName c r o v rec cs)).cage = s.cage ∧
 (afterBurn s (judgmentName c r o v rec cs)).live = s.live := by
  intro h _
  exact ⟨Step.burn s _ h, rfl, rfl⟩

theorem judgments_do_not_consume (s : State) (tx : JudgmentTx) :
 (afterJudgment s tx).live = s.live ∧ (afterJudgment s tx).claims = s.claims ∧ (afterJudgment s tx).cage = s.cage := by
  exact ⟨rfl, rfl, rfl⟩

theorem exits_remove_consumed (s : State) (o : RequestOutput) : o ∉ (afterExit s o).live := by
  simp [afterExit, removeRequests]

theorem fold_removes_consumed (s : State) (tx : FoldTx) (o : RequestOutput) : o ∈ tx.requests → o ∉ (afterFold s tx).live := by
  intro h
  simp [afterFold, removeRequests, h]

theorem used_seeds_monotone {s s' : State} {a : Action} : Step s a s' → ∀ seed ∈ s.usedSeeds, seed ∈ s'.usedSeeds := by
  intro h seed hs
  cases h <;> try exact hs
  exact List.mem_append_right _ hs

theorem reachable_requests_have_spent_seeds (s : State) : Reachable s → s.cage.oracles ≠ [] →
 ∀ o ∈ s.live, o.request.seed ∈ s.usedSeeds := by
  intro h
  induction h with
  | registry c ex hc => simp [initial]
  | @next s s' a hr hs ih =>
    intro hn o ho
    have hc := step_preserves_registry hs
    have oldne : s.cage.oracles ≠ [] := hc.2.1 ▸ hn
    cases hs <;> try exact ih oldne o ho
    case create tx new he ha hf hf' =>
      rcases List.mem_cons.mp ho with h | h
      · subst o
        exact List.mem_append_left _ (ha.1 (he ▸ oldne))
      · exact List.mem_append_right _ (ih oldne o h)
    case fold tx _ _ _ _ _ => exact ih oldne o (List.mem_filter.mp ho).1
    case withdraw tx _ _ => exact ih oldne o (List.mem_filter.mp ho).1

theorem spent_seed_cannot_create_again (s : State) (tx : CreateTx) (o : RequestOutput) :
 s.cage.oracles ≠ [] → o.request.seed ∈ s.usedSeeds → ¬ ∃ s', Step s (.create tx o) s' := by
  intro hn hs ⟨s', h⟩
  cases h with
  | create _ _ hc ha hf _ => exact hf o.request.seed (ha.1 (hc ▸ hn)) hs

theorem request_never_reappears (s s' : State) (o : RequestOutput) :
 Reachable s → o.ref ∈ s.usedOutputs → o ∉ s.live → History s s' → o ∉ s'.live := by
  sorry

theorem one_oracle_signature_suffices (c : CageState) (r : Request) (oracle : Oracle)
 (e : Selection) (sigs : List Signer) : c.oracles = [oracle] →
 (e oracle).authorized oracle → (e oracle).approve = true → (e oracle).signers = sigs →
 hasApproval c r [] sigs e := by
  intro hc ha hv hs oracle' ho
  have he : oracle' = oracle := by simpa [hc] using ho
  subst oracle'
  exact ⟨ha, hv, Or.inr hs⟩

theorem old_operations_correspond (op : OldOperation) (t : Trie) :
    op.write.apply t = op.apply t ∧
      (match op with
       | .insert k _ => op.condition.holds t ↔ t k = none
       | .delete k v => op.condition.holds t ↔ t k = some v
       | .update k v _ => op.condition.holds t ↔ t k = some v) := by
  cases op <;> simp [OldOperation.write, OldOperation.apply, Write.apply, OldOperation.condition, Condition.holds]

theorem live_removal_is_legal_exit {s s' : State} {a : Action} (o : RequestOutput) :
 Step s a s' → o ∈ s.live → o ∉ s'.live →
 ∃ spend, a.spend = some spend ∧ requestSpendAllowed o spend ∧
 (match spend with
 | .folded tx => s' = afterFold s tx ∧ tx.cageIn = s.cage ∧
     (∀ input ∈ tx.requests, input ∈ s.live) ∧ (∀ claim ∈ tx.claims, claim ∈ s.claims) ∧
     (∀ name ∈ tx.refs, name ∈ s.judgments)
 | .withdrawn tx => s' = afterExit s tx.input) := by
  intro hs ho hn
  cases hs <;> try exact False.elim (hn ho)
  case create tx new hc ha hf hf' => exact False.elim (hn (List.mem_cons_of_mem _ ho))
  case fold tx hc hl hcl hr ha =>
    have hm : o ∈ tx.requests := by
      apply Classical.byContradiction
      intro hm
      exact hn (List.mem_filter.mpr ⟨ho, by simpa using hm⟩)
    exact ⟨.folded tx,rfl,⟨ha,hm⟩,rfl,hc,hl,hcl,hr⟩
  case withdraw tx hl ha =>
    have he : tx.input = o := by
      apply Classical.byContradiction
      intro he
      exact hn (by simpa [afterExit,removeRequests,ne_comm] using And.intro ho he)
    exact ⟨.withdrawn tx,rfl,⟨ha,he⟩,rfl⟩

theorem new_judgment_is_authorized {s s' : State} {a : Action} (name : TokenName) :
 Step s a s' → name ∈ s'.issued → name ∉ s.issued →
 ∃ tx, a = .judge tx ∧ tx.cageRef = s.cage ∧ tx.requestRef ∈ s.live ∧ judgmentAllowed tx ∧ name ∈ tx.minted := by
  intro hs hm hn
  cases hs <;> try exact False.elim (hn hm)
  rename_i tx hc hl ha
  refine ⟨tx,rfl,hc,hl,ha,?_⟩
  rcases List.mem_append.mp hm with hm | hm
  · exact hm
  · exact False.elim (hn hm)

theorem exit_time_window (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → ∀ kind, spend.exitsAs o kind → exitAt o spend.interval kind := by
  intro h kind hk
  cases spend with
  | folded tx =>
    cases kind with
    | write =>
      obtain ⟨e, he⟩ := hk
      obtain ⟨n, hn⟩ := List.mem_iff_getElem?.mp he
      exact ⟨h.1.1, (foldRun_step_valid h.1.2.2.2.2 n (.write o e) hn).2.2.1⟩
    | account =>
      obtain ⟨e, he⟩ := hk
      obtain ⟨n, hn⟩ := List.mem_iff_getElem?.mp he
      have hi := foldRun_step_valid h.1.2.2.2.2 n (.account o e) hn
      exact ⟨h.1.1, hi.2.2.1, hi.2.2.2.1⟩
    | withdraw => exact False.elim hk
  | withdrawn tx =>
    cases kind with
    | write => exact False.elim hk
    | account => exact False.elim hk
    | withdraw => exact ⟨h.1.1, h.2 ▸ h.1.2.1⟩

theorem exit_windows_cover (o : RequestOutput) (now : Time) :
 exitAt o ⟨now, now⟩ .write ∨ exitAt o ⟨now, now⟩ .account ∨ exitAt o ⟨now, now⟩ .withdraw := by
  simp only [exitAt, Interval.valid]
  (simp only [Time] at *; omega)

theorem exit_kind_unique (o : RequestOutput) (a b : RequestSpend) (ka kb : ExitKind) :
 requestSpendAllowed o a → requestSpendAllowed o b → a.interval = b.interval →
 a.exitsAs o ka → b.exitsAs o kb → ka = kb := by
  intro ha hb he hka hkb
  have h1 := exit_time_window o a ha ka hka
  have h2 := exit_time_window o b hb kb hkb
  rw [← he] at h2
  cases ka <;> cases kb <;> simp_all only [exitAt, Interval.valid, Time] <;> omega

theorem fold_references_authentic {s s' : State} (tx : FoldTx) :
 Step s (.fold tx) s' → tx.cageIn = s.cage ∧ (∀ o ∈ tx.requests, o ∈ s.live) ∧
 (∀ o ∈ tx.claims, o ∈ s.claims) ∧ ∀ name ∈ tx.refs, name ∈ s.judgments := by
  intro h
  cases h with
  | fold _ hc hl hcl hr _ => exact ⟨hc, hl, hcl, hr⟩

theorem account_references_authentic {s s' : State} (tx : FoldTx) (n : Nat) (o : RequestOutput) (e : Selection) :
 Step s (.fold tx) s' → tx.items[n]? = some (FoldItem.account o e) →
 ∀ oracle ∈ s.cage.oracles, (e oracle).name s.cage.id o.request oracle ∈ s.judgments := by
  intro hs hn oracle ho
  cases hs with
  | fold tx hc _ _ hr ha =>
    have hp := (account_complete_and_pays tx ha n o e hn).1 oracle
      (by change oracle ∈ (foldResult tx.cageIn (tx.items.take n)).oracles; rw [(ProofHelpers.result_registry tx.cageIn (tx.items.take n)).2.1, hc]; exact ho)
    have hn := hr _ hp.2
    change (e oracle).name (foldResult tx.cageIn (tx.items.take n)).id o.request oracle ∈ s.judgments at hn
    rw [(ProofHelpers.result_registry tx.cageIn (tx.items.take n)).1, hc] at hn
    exact hn

theorem creation_references_source {s s' : State} (tx : CreateTx) (o : RequestOutput) :
 Step s (.create tx o) s' → tx.cageRef = s.cage ∧ o.request.cage = s.cage.id := by
  intro h
  cases h with
  | create _ _ hc ha _ _ => exact ⟨hc, hc ▸ ha.2.2.2.1.1⟩

theorem fold_payments_concrete (tx : FoldTx) (n : Nat) (o : RequestOutput) (e : Selection) :
 foldAccepted tx → tx.items[n]? = some (FoldItem.write o e) →
 (itemResult (atTurn tx n) (FoldItem.write o e)).balances =
 (fun k => (atTurn tx n).balances k + OracleIdentity.paidTo (credits (atTurn tx n) o.request e) k) ∧
 itemPayments (atTurn tx n) tx.folder (FoldItem.write o e) =
 [⟨tx.folder, "", o.value - (tx.cageIn.oracles.map fun oracle =>
 ((o.request.fees.find? (fun p => p.1 == oracle)).map Prod.snd).getD 0).sum⟩] := by
  intro h hn
  have hp := fold_pays_and_keeps_rest tx h n o e hn
  exact ⟨hp.1, hp.2.1⟩

theorem account_payments_concrete (tx : FoldTx) (n : Nat) (o : RequestOutput) (e : Selection) :
 foldAccepted tx → tx.items[n]? = some (FoldItem.account o e) →
 (itemResult (atTurn tx n) (FoldItem.account o e)).balances =
 (fun k => (atTurn tx n).balances k + OracleIdentity.paidTo (credits (atTurn tx n) o.request e) k) ∧
 itemPayments (atTurn tx n) tx.folder (FoldItem.account o e) =
 [⟨o.request.owner, "", o.value - (tx.cageIn.oracles.map fun oracle =>
 ((o.request.fees.find? (fun p => p.1 == oracle)).map Prod.snd).getD 0).sum⟩] := by
  intro h hn
  have hp := account_complete_and_pays tx h n o e hn
  exact ⟨hp.2.1, hp.2.2.2.1⟩

theorem creation_funds_declared_fees {s s' : State} (tx : CreateTx) (o : RequestOutput) :
 Step s (.create tx o) s' → (s.cage.oracles.map fun oracle =>
 ((o.request.fees.find? (fun p => p.1 == oracle)).map Prod.snd).getD 0).sum + s.cage.minimum ≤ o.value := by
  intro h
  cases h with
  | create _ _ hc ha _ _ => exact hc ▸ ha.2.2.2.1.2.2.1

theorem burn_removes_one {s s' : State} (name : TokenName) : Step s (.burn name) s' →
 s'.judgments.count name + 1 = s.judgments.count name ∧ s'.judgments = s.judgments.erase name := by
  intro h
  cases h with
  | burn _ hm =>
    refine ⟨?_, rfl⟩
    change (s.judgments.erase name).count name + 1 = s.judgments.count name
    rw [List.count_erase_self]
    have := List.count_pos_iff.mpr hm
    omega

theorem burn_keeps_history {s s' : State} (name : TokenName) : Step s (.burn name) s' → s'.issued = s.issued := by
  intro h
  cases h
  rfl

theorem fold_requests_unique (tx : FoldTx) : foldAccepted tx →
 (tx.requests.map RequestOutput.ref ++ tx.claims.map ClaimOutput.ref).Nodup ∧ tx.requests.Nodup ∧ tx.claims.Nodup := by
  intro h
  have hn := h.2.1
  have hsplit := List.pairwise_append.mp hn
  refine ⟨hn, ?_, ?_⟩
  · exact List.Pairwise.of_map RequestOutput.ref (fun a b hab he => hab (congrArg RequestOutput.ref he)) hsplit.1
  · exact List.Pairwise.of_map ClaimOutput.ref (fun a b hab he => hab (congrArg ClaimOutput.ref he)) hsplit.2.1

theorem account_accepts_any_verdicts (s : State) (o : RequestOutput) (e : Selection)
 (iv : Interval) (who : Signer) : o ∈ s.live → wellFormed s.cage o → iv.valid →
 o.request.deadline ≤ iv.lower → iv.upper ≤ o.request.deadline + o.request.window →
 (∀ oracle ∈ s.cage.oracles, (e oracle).authorized oracle ∧
   (e oracle).name s.cage.id o.request oracle ∈ s.judgments) →
 Step s (.fold (singletonFold s iv [] (FoldItem.account o e) who))
 (afterFold s (singletonFold s iv [] (FoldItem.account o e) who)) := by
  intro hl hw hv ht hu ha
  exact account_anyone_in_window s o e iv who hl hw ha hv ht hu

theorem equivocation_reachable : ∃ (s : State) (o : RequestOutput) (oracle : Oracle)
 (rec : SigningRecord) (cs : List Condition),
 Reachable s ∧ o ∈ s.live ∧ o.request.cage = s.cage.id ∧ oracle ∈ s.cage.oracles ∧
 judgmentName s.cage.id o.request oracle true rec cs ∈ s.judgments ∧
 judgmentName s.cage.id o.request oracle false rec [] ∈ s.judgments ∧
 judgmentName s.cage.id o.request oracle true rec cs ∈ s.issued ∧
 judgmentName s.cage.id o.request oracle false rec [] ∈ s.issued := by
  exact ⟨Witnesses.s3, Witnesses.output, Witnesses.oracle, Witnesses.rec,
    [.absent "y"], Witnesses.W60⟩

theorem tag_name_injective (a b : Oracle) : tagName a = tagName b ↔ a = b := by
  simp [tagName, tokenName, TokenName.mk.injEq]

theorem price_name_injective (a b : Oracle) : priceName a = priceName b ↔ a = b := by
  simp [priceName, tokenName, TokenName.mk.injEq]

theorem different_roles_never_coincide (a b : TokenRole) (x y : NameBinding) : a ≠ b → tokenName a x ≠ tokenName b y := by
  intro h he
  exact h (congrArg TokenName.role he)

theorem names_have_leading_roles (c : CageId) (r : Request) (o : Oracle) (rec : SigningRecord) (cs : List Condition) :
 (tagName o).role = .tag ∧ (priceName o).role = .price ∧
 (judgmentName c r o true rec cs).role = .approval ∧
 (judgmentName c r o false rec cs).role = .refusal ∧
 (requestName c).role = .request ∧ (claimName c).role = .claim := by
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem reachable_registry_valid (s : State) : Reachable s → RegistryValid s.cage := by
  exact ProofHelpers.registry_valid s

theorem reachable_live_tags (s : State) : Reachable s → ∀ o ∈ s.live,
 o.request.cage = s.cage.id ∧ o.tags = s.cage.oracles.map tagName := by
  intro hs o ho
  have hw := ProofHelpers.live_wf s hs o ho
  exact ⟨hw.1, hw.2.1⟩

theorem reachable_tags_unique (s : State) (o : RequestOutput) : Reachable s → o ∈ s.live →
 o.tags.Nodup ∧ ∀ oracle ∈ s.cage.oracles, o.tags.count (tagName oracle) = 1 := by
  intro hs ho
  have he := (reachable_live_tags s hs o ho).2
  have hn : o.tags.Nodup := by
    rw [he]
    exact List.Pairwise.map tagName (fun a b hab heq => hab ((tag_name_injective a b).mp heq))
      (reachable_registry_valid s hs).2.1
  refine ⟨hn, ?_⟩
  intro oracle hm
  have hmem : tagName oracle ∈ o.tags := by
    rw [he]
    exact List.mem_map.mpr ⟨oracle,hm,rfl⟩
  have hlo := List.count_pos_iff.mpr hmem
  have hhi := (List.nodup_iff_count.mp hn) (tagName oracle)
  omega

theorem discovery_iff (s : State) (oracle : Oracle) (o : RequestOutput) : Reachable s →
 (o ∈ discover oracle s.live ↔ o ∈ s.live ∧ oracle ∈ s.cage.oracles) := by
  intro hs
  simp only [discover, List.mem_filter, decide_eq_true_eq]
  constructor
  · rintro ⟨hl, ht⟩
    rw [(reachable_live_tags s hs o hl).2] at ht
    obtain ⟨a, ha, he⟩ := List.mem_map.mp ht
    have he := (tag_name_injective a oracle).mp he
    exact ⟨hl, he ▸ ha⟩
  · rintro ⟨hl, ho⟩
    exact ⟨hl, by rw [(reachable_live_tags s hs o hl).2]; exact List.mem_map.mpr ⟨oracle, ho, rfl⟩⟩

theorem discovery_across_registries (states : List State) (oracle : Oracle) (o : RequestOutput) :
 (∀ s ∈ states, Reachable s) →
 (o ∈ discover oracle (states.flatMap State.live) ↔ ∃ s ∈ states, o ∈ s.live ∧ oracle ∈ s.cage.oracles) := by
  intro hs
  simp only [discover, List.mem_filter, decide_eq_true_eq, List.mem_flatMap]
  constructor
  · rintro ⟨⟨s, hs', ho⟩, ht⟩
    exact ⟨s, hs', (discovery_iff s oracle o (hs s hs')).mp (List.mem_filter.mpr ⟨ho, by simpa using ht⟩)⟩
  · rintro ⟨s, hs', ho, hm⟩
    have hd := (discovery_iff s oracle o (hs s hs')).mpr ⟨ho, hm⟩
    exact ⟨⟨s, hs', ho⟩, by simpa [discover] using (List.mem_filter.mp hd).2⟩

theorem live_removal_burns_oracle_tags {s s' : State} {a : Action} (o : RequestOutput) :
 Reachable s → Step s a s' → o ∈ s.live → o ∉ s'.live →
 ∃ spend, a.spend = some spend ∧ requestSpendAllowed o spend ∧ ∀ oracle ∈ s.cage.oracles, tagName oracle ∈ spend.burned := by
  intro hs ht ho hn
  obtain ⟨spend,ha,hsp,_⟩ := live_removal_is_legal_exit o ht ho hn
  refine ⟨spend,ha,hsp,?_⟩
  intro oracle hm
  apply every_exit_burns_tag o spend hsp
  apply List.mem_append_left
  rw [(reachable_live_tags s hs o ho).2]
  exact List.mem_map.mpr ⟨oracle,hm,rfl⟩

theorem price_mint_inversion {s s' : State} (tx : PriceMintTx) : Step s (.priceMint tx) s' →
 (OracleIdentity.authorize tx.output.oracle tx.description tx.signers).isSome = true ∧
 tx.output.token = ⟨.price, .oracle tx.output.oracle⟩ ∧ tx.minted = [tx.output.token] ∧
 s'.notices = tx.output :: s.notices := by
  intro h
  cases h with
  | priceMint _ ha => exact ⟨ha.1, ha.2.1, ha.2.2, rfl⟩

theorem price_update_inversion {s s' : State} (tx : PriceUpdateTx) : Step s (.priceUpdate tx) s' →
 tx.input ∈ s.notices ∧ (OracleIdentity.authorize tx.input.oracle tx.description tx.signers).isSome = true ∧
 tx.input.token = ⟨.price, .oracle tx.input.oracle⟩ ∧ tx.output.oracle = tx.input.oracle ∧
 tx.output.token = tx.input.token ∧ tx.minted = [] ∧ s'.notices = tx.output :: s.notices.erase tx.input := by
  intro h
  cases h with
  | priceUpdate _ hl ha => exact ⟨hl, ha.1, ha.2.1, ha.2.2.1, ha.2.2.2.1, ha.2.2.2.2, rfl⟩

theorem reachable_notice_names (s : State) : Reachable s → ∀ n ∈ s.notices, n.token = ⟨.price, .oracle n.oracle⟩ := by
  intro h
  induction h with
  | registry c ex hc => simp [initial]
  | @next s s' a hr hs ih =>
    intro n hn
    cases hs <;> try exact ih n hn
    case priceMint tx ha =>
      rcases List.mem_cons.mp hn with he | he
      · subst n; exact ha.2.1
      · exact ih n he
    case priceUpdate tx hl ha =>
      rcases List.mem_cons.mp hn with he | he
      · subst n; exact ha.2.2.2.1.trans (ha.2.1.trans (congrArg priceName ha.2.2.1.symm))
      · exact ih n (List.mem_of_mem_erase he)

theorem price_mint_available (s : State) (oracle : Oracle) (d : OracleIdentity.Description)
 (sigs : List Signer) (datum : PriceDatum) :
 (OracleIdentity.authorize oracle d sigs).isSome = true →
 let tx : PriceMintTx := ⟨⟨oracle, priceName oracle, datum⟩, d, sigs, [priceName oracle]⟩
 Step s (.priceMint tx) (afterPriceMint s tx) := by
  intro h
  exact Step.priceMint s _ ⟨h, rfl, rfl⟩

theorem price_update_available (s : State) (n : PriceNotice) (d : OracleIdentity.Description)
 (sigs : List Signer) (datum : PriceDatum) : n ∈ s.notices → n.token = priceName n.oracle →
 (OracleIdentity.authorize n.oracle d sigs).isSome = true →
 let tx : PriceUpdateTx := ⟨n, { n with datum := datum }, d, sigs, []⟩
 Step s (.priceUpdate tx) (afterPriceUpdate s tx) := by
  intro hl hn ha
  exact Step.priceUpdate s _ hl ⟨ha, hn, rfl, rfl, rfl⟩

theorem price_notice_noninterference {s s' : State} {a : Action} : Step s a s' → a.isPrice = true →
 s'.cage = s.cage ∧ s'.live = s.live ∧ s'.claims = s.claims ∧ s'.judgments = s.judgments ∧
 s'.issued = s.issued ∧ s'.usedSeeds = s.usedSeeds ∧ s'.usedOutputs = s.usedOutputs ∧
 a.payments = [] ∧ a.spend = none := by
  intro h hp
  cases h <;> simp_all [Action.isPrice, afterPriceMint, afterPriceUpdate, Action.payments, Action.spend]

theorem notices_do_not_bind_protocol {s s' : State} {a : Action} (notices : List PriceNotice) :
 Step s a s' → a.isPrice = false →
 Step { s with notices := notices } a { s' with notices := notices } := by
  intro h hp
  cases h with
  | create tx o hc ha hf ho => exact .create _ tx o hc ha hf ho
  | judge tx hc hl ha => exact .judge _ tx hc hl ha
  | fold tx hc hl hcl hr ha => exact .fold _ tx hc hl hcl hr ha
  | withdraw tx hl ha => exact .withdraw _ tx hl ha
  | burn n hn => exact .burn _ n hn
  | priceMint => cases hp
  | priceUpdate => cases hp
  | claimCreate tx hc ha hf => exact .claimCreate _ tx hc ha hf
  | claimWithdraw tx hl ha => exact .claimWithdraw _ tx hl ha

theorem notice_change_authorized {s s' : State} {a : Action} (n : PriceNotice) :
 Step s a s' → n ∈ s'.notices → n ∉ s.notices →
 (∃ tx, a = .priceMint tx ∧ tx.output = n ∧
 (OracleIdentity.authorize n.oracle tx.description tx.signers).isSome = true) ∨
 (∃ tx, a = .priceUpdate tx ∧ tx.input ∈ s.notices ∧ tx.output = n ∧ tx.input.oracle = n.oracle ∧
 (OracleIdentity.authorize n.oracle tx.description tx.signers).isSome = true) := by
  intro h hm hn
  cases h <;> try exact False.elim (hn hm)
  case priceMint tx ha =>
    rcases List.mem_cons.mp hm with he | he
    · subst n; exact Or.inl ⟨tx,rfl,rfl,ha.1⟩
    · exact False.elim (hn he)
  case priceUpdate tx hl ha =>
    rcases List.mem_cons.mp hm with he | he
    · subst n
      exact Or.inr ⟨tx,rfl,hl,rfl,ha.2.2.1.symm,ha.2.2.1 ▸ ha.1⟩
    · exact False.elim (hn (List.mem_of_mem_erase he))

theorem creation_rule_and_token (tx : CreateTx) (o : RequestOutput) : createAllowed tx o →
 ruleAdmits tx.cageRef o.request tx.signers ∧ tx.outputs = [o] ∧
 o.request.cage = tx.cageRef.id ∧ o.requestTokens = [requestName tx.cageRef.id] ∧
 o.policy = requestPolicy tx.cageRef ∧ tx.policy = requestPolicy tx.cageRef ∧
 tx.minted = tx.cageRef.oracles.map tagName ++ [requestName tx.cageRef.id] ∧
 totalFees tx.cageRef o.request + tx.cageRef.minimum ≤ o.value := by
  intro h
  exact ⟨h.2.2.2.2.1, h.2.1, h.2.2.2.1.1, h.2.2.2.1.2.2.2.1,
    h.2.2.2.1.2.2.2.2, h.2.2.2.2.2, h.2.2.1, h.2.2.2.1.2.2.1⟩

theorem step_rule_immutable {s s' : State} {a : Action} : Step s a s' → s'.cage.rule = s.cage.rule := by
  intro h
  exact (step_preserves_registry h).2.2.2.1

theorem history_rule_immutable {s s' : State} : History s s' → s'.cage.rule = s.cage.rule := by
  intro h
  exact (history_preserves_registry h).2.2.2.1

theorem reachable_rule_admitted (s : State) : Reachable s → ∀ o ∈ s.live,
 ∃ sigs, ruleAdmits s.cage o.request sigs := by
  intro h
  induction h with
  | registry c ex hc => simp [initial]
  | @next s s' a hr hs ih =>
    intro o ho
    have hc := step_preserves_registry hs
    cases hs <;> try exact ih o ho
    case create tx new he ha hf hf' =>
      rcases List.mem_cons.mp ho with h | h
      · subst o; exact ⟨tx.signers, he ▸ ha.2.2.2.2.1⟩
      · exact ih o h
    case fold tx _ _ _ _ _ =>
      obtain ⟨sigs,ha⟩ := ih o (List.mem_filter.mp ho).1
      exact ⟨sigs, by simpa only [ruleAdmits,hc.2.2.2.1] using ha⟩
    case withdraw tx _ _ => exact ih o (List.mem_filter.mp ho).1

theorem every_rule_allows_burn (s : State) (rule : Rule) : s.cage.rule = some rule →
 (∀ tx, tx.cageIn = s.cage → (∀ o ∈ tx.requests, o ∈ s.live) →
 (∀ o ∈ tx.claims, o ∈ s.claims) → (∀ name ∈ tx.refs, name ∈ s.judgments) →
 tx.interval.valid → (tx.requests.map RequestOutput.ref ++ tx.claims.map ClaimOutput.ref).Nodup →
 tx.burned = tx.items.flatMap FoldItem.burned → tx.payments = foldPayments tx.cageIn tx.folder tx.items →
 FoldRun tx.interval tx.refs tx.signers tx.cageIn tx.items tx.cageOut →
 Step s (.fold tx) (afterFold s tx)) ∧
 (∀ tx : WithdrawTx, tx.input ∈ s.live → tx.interval.valid →
 tx.input.request.deadline + tx.input.request.window < tx.interval.lower →
 tx.input.request.owner ∈ tx.signers → tx.burned = tokensOf tx.input →
 tx.beneficiary = tx.input.request.owner → tx.paid = tx.input.value →
 Step s (.withdraw tx) (afterExit s tx.input)) ∧
 (∀ name ∈ s.judgments, Step s (.burn name) (afterBurn s name)) := by
  intro _
  refine ⟨?_, ?_, ?_⟩
  · intro tx hc hl hcl hr hv hn hb hp hrun
    exact Step.fold s tx hc hl hcl hr ⟨hv, hn, hb, hp, hrun⟩
  · intro tx hl hv ht hs hb hp ha
    exact Step.withdraw s tx hl ⟨hv, ht, hs, hb, hp, ha⟩
  · exact fun name hn => Step.burn s name hn

theorem creation_rule_input_binding {s s' : State} {tx : CreateTx} {o : RequestOutput} (rule : Rule) :
 Step s (.create tx o) s' → s.cage.rule = some rule →
 tx.outputs = [o] ∧ o ∈ s'.live ∧ rule.admits o.request tx.signers := by
  intro h hr
  cases h with
  | create _ _ hc ha _ _ =>
    refine ⟨ha.2.1, by simp [afterCreate], ?_⟩
    have hm := ha.2.2.2.2.1
    simpa [ruleAdmits, hc, hr] using hm

theorem creation_request_policy {s s' : State} {tx : CreateTx} {o : RequestOutput} :
 Step s (.create tx o) s' → tx.outputs = [o] ∧
 o.requestTokens = [requestName s.cage.id] ∧
 tx.minted = s.cage.oracles.map tagName ++ [requestName s.cage.id] ∧
 (match s.cage.rule with
 | some rule => tx.policy = .rule rule.hash ∧ o.policy = .rule rule.hash ∧ tx.policy ≠ .release ∧ o.policy ≠ .release
 | none => tx.policy = .release ∧ o.policy = .release) := by
  intro h
  cases h with
  | create _ _ hc ha _ _ =>
    refine ⟨ha.2.1, hc ▸ ha.2.2.2.1.2.2.2.1, hc ▸ ha.2.2.1, ?_⟩
    have ht := hc ▸ ha.2.2.2.2.2
    have ho := hc ▸ ha.2.2.2.1.2.2.2.2
    cases hr : s.cage.rule <;> simp_all [requestPolicy]

theorem fold_rule_predicate_independent (c : CageState) (hash : String) (p q : Request → List Signer → Prop)
 (iv : Interval) (refs : List TokenName) (sigs : List Signer) (i : FoldItem) :
 itemAllowed { c with rule := some ⟨hash, p⟩ } iv refs sigs i ↔
 itemAllowed { c with rule := some ⟨hash, q⟩ } iv refs sigs i := by
  cases i <;> rfl

theorem reachable_request_tokens (s : State) : Reachable s → ∀ o ∈ s.live,
 o.requestTokens = [requestName s.cage.id] ∧ o.policy = requestPolicy s.cage := by
  intro hs o ho
  exact (ProofHelpers.live_wf s hs o ho).2.2.2

theorem fold_requires_request_token (tx : FoldTx) : foldAccepted tx → ∀ o ∈ tx.requests,
 o.requestTokens = [requestName tx.cageIn.id] ∧ o.policy = requestPolicy tx.cageIn := by
  intro h o ho
  rcases (ProofHelpers.request_member tx o).mp ho with ⟨e,he⟩ | ⟨e,he⟩
  all_goals
   obtain ⟨n, hn⟩ := List.mem_iff_getElem?.mp he
   have hr := ProofHelpers.result_registry tx.cageIn (tx.items.take n)
   first
   | exact (ProofHelpers.wf_registry hr o).mp (foldRun_step_valid h.2.2.2.2 n (.write o e) hn).1 |>.2.2.2
   | exact (ProofHelpers.wf_registry hr o).mp (foldRun_step_valid h.2.2.2.2 n (.account o e) hn).1 |>.2.2.2

theorem every_exit_burns_request_token (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → ∀ token ∈ o.requestTokens, token ∈ spend.burned := by
  intro h token ht
  exact every_exit_burns_tag o spend h token (List.mem_append_right o.tags ht)

theorem live_removal_burns_request_token {s s' : State} {a : Action} (o : RequestOutput) :
 Reachable s → Step s a s' → o ∈ s.live → o ∉ s'.live →
 ∃ spend, a.spend = some spend ∧ requestSpendAllowed o spend ∧ requestName s.cage.id ∈ spend.burned := by
  intro hs ht ho hn
  obtain ⟨spend,ha,hsp,_⟩ := live_removal_is_legal_exit o ht ho hn
  refine ⟨spend,ha,hsp,?_⟩
  apply every_exit_burns_request_token o spend hsp
  rw [(reachable_request_tokens s hs o ho).1]
  simp

theorem request_name_injective (a b : CageId) : requestName a = requestName b ↔ a = b := by
  simp [requestName, tokenName, TokenName.mk.injEq]

theorem request_token_discovery (s : State) (id : CageId) (o : RequestOutput) : Reachable s →
 (o ∈ discoverRequests id s.live ↔ o ∈ s.live ∧ s.cage.id = id) := by
  intro hs
  simp only [discoverRequests, List.mem_filter, decide_eq_true_eq]
  constructor
  · rintro ⟨hl, ht⟩
    rw [(reachable_request_tokens s hs o hl).1] at ht
    have he := (request_name_injective id s.cage.id).mp (List.mem_singleton.mp ht)
    exact ⟨hl, he.symm⟩
  · rintro ⟨hl, he⟩
    exact ⟨hl, by rw [(reachable_request_tokens s hs o hl).1, he]; simp⟩

theorem request_token_discovery_across_registries (states : List State) (id : CageId) (o : RequestOutput) :
 (∀ s ∈ states, Reachable s) →
 (o ∈ discoverRequests id (states.flatMap State.live) ↔ ∃ s ∈ states, o ∈ s.live ∧ s.cage.id = id) := by
  intro hs
  simp only [discoverRequests, List.mem_filter, decide_eq_true_eq, List.mem_flatMap]
  constructor
  · rintro ⟨⟨s, hs', ho⟩, ht⟩
    exact ⟨s, hs', (request_token_discovery s id o (hs s hs')).mp (List.mem_filter.mpr ⟨ho, by simpa using ht⟩)⟩
  · rintro ⟨s, hs', ho, hm⟩
    have hd := (request_token_discovery s id o (hs s hs')).mpr ⟨ho, hm⟩
    exact ⟨⟨s, hs', ho⟩, by simpa [discoverRequests] using (List.mem_filter.mp hd).2⟩

theorem output_refs_monotone {s s' : State} {a : Action} : Step s a s' → ∀ ref ∈ s.usedOutputs, ref ∈ s'.usedOutputs := by
  intro h ref hr
  cases h <;> first | exact hr | simp [afterCreate, afterClaimCreate, hr]

theorem reachable_output_refs (s : State) : Reachable s →
 (∀ o ∈ s.live, o.ref ∈ s.usedOutputs) ∧ (∀ o ∈ s.claims, o.ref ∈ s.usedOutputs) := by
  sorry

theorem reachable_output_refs_unique (s : State) : Reachable s →
 (s.live.map RequestOutput.ref ++ s.claims.map ClaimOutput.ref).Nodup := by
  sorry

theorem unguarded_registry_impossible (c : CageState) (existing : List CageId) :
 c.oracles = [] → c.rule = none → ¬ registryCreated c existing := by
  intro ho hr h
  rcases h.2.1.1 with hn | hn
  · exact hn ho
  · simp [hr] at hn

theorem zero_oracle_needs_rule (c : CageState) (existing : List CageId) :
 registryCreated c existing → c.oracles = [] → ∃ rule, c.rule = some rule := by
  intro h ho
  cases hr : c.rule with
  | none => exact False.elim (unguarded_registry_impossible c existing ho hr h)
  | some rule => exact ⟨rule, rfl⟩

theorem zero_oracle_evidence_empty (c : CageState) (r : Request) (e : Selection) :
 c.oracles = [] → hasApproval c r [] [] e ∧ hasAccount c r [] e := by
  intro h
  simp [hasApproval, hasAccount, h]

theorem zero_oracle_creation_without_seed (c : CageState) (o : RequestOutput) (sigs : List Signer) :
 c.oracles = [] → wellFormed c o → ruleAdmits c o.request sigs →
 createAllowed ⟨[], c, [requestName c.id], [o], sigs, requestPolicy c⟩ o := by
  intro ho hw hr
  exact ⟨by simp [ho], rfl, by simp [ho], hw, hr, rfl⟩

theorem zero_oracle_fold_without_approvals (c : CageState) (o : RequestOutput) (iv : Interval) (e : Selection) :
 c.oracles = [] → wellFormed c o → iv.valid → iv.upper < o.request.deadline →
 (∀ condition ∈ o.request.conditions, condition.holds c.trie) →
 FoldRun iv [] [] c [FoldItem.write o e] (itemResult c (FoldItem.write o e)) ∧
 (itemResult c (FoldItem.write o e)).trie = o.request.write.apply c.trie := by
  intro ho hw hv ht hc
  refine ⟨FoldRun.cons _ _ [] _ ?_ (FoldRun.nil _), rfl⟩
  exact ⟨hw, hv, ht, by simp [hasApproval, ho], hc, by simp [ho]⟩

theorem zero_oracle_account_without_verdicts (s : State) (o : RequestOutput) (iv : Interval) (e : Selection) :
 s.cage.oracles = [] → o ∈ s.live → wellFormed s.cage o → iv.valid →
 o.request.deadline ≤ iv.lower → iv.upper ≤ o.request.deadline + o.request.window →
 Step s (.fold (singletonFold s iv [] (FoldItem.account o e) o.request.owner))
 (afterFold s (singletonFold s iv [] (FoldItem.account o e) o.request.owner)) := by
  intro ho hl hw hv ht hu
  exact account_anyone_in_window s o e iv o.request.owner hl hw (by simp [hasAccount, ho]) hv ht hu

theorem present_condition_semantics (t : Trie) (k : Key) : Condition.holds t (.present k) ↔ ∃ v, t k = some v := by
  simp [Condition.holds]

theorem foldRun_oracle_conditions {iv : Interval} {refs : List TokenName} {sigs : List Signer}
 {c out : CageState} {items : List FoldItem} : FoldRun iv refs sigs c items out →
 ∀ n o e, items[n]? = some (FoldItem.write o e) → ∀ oracle ∈ c.oracles,
 ∀ condition ∈ (e oracle).conditions, condition.holds (foldResult c (items.take n)).trie := by
  intro h n o e hn oracle ho
  have hi := foldRun_step_valid h n (.write o e) hn
  exact hi.2.2.2.2.2 oracle ((ProofHelpers.result_registry c (items.take n)).2.1 ▸ ho)

theorem fold_all_conditions_hold (tx : FoldTx) : foldAccepted tx → ∀ n o e,
 tx.items[n]? = some (FoldItem.write o e) →
 (∀ condition ∈ o.request.conditions, condition.holds (atTurn tx n).trie) ∧
 (∀ oracle ∈ tx.cageIn.oracles, ∀ condition ∈ (e oracle).conditions, condition.holds (atTurn tx n).trie) := by
  intro h n o e hn
  exact ⟨fold_conditions_hold_when_applied tx h n o e hn, foldRun_oracle_conditions h.2.2.2.2 n o e hn⟩

theorem approval_conditions_cannot_change (c : CageId) (r : Request) (o : Oracle)
 (rec rec' : SigningRecord) (a b : List Condition) :
 judgmentName c r o true rec a = judgmentName c r o true rec' b ↔ rec = rec' ∧ a = b := by
  simp [judgmentName, tokenName, TokenName.mk.injEq]

theorem stale_approval_unusable (tx : FoldTx) (n : Nat) (o : RequestOutput) (e : Selection)
 (oracle : Oracle) (condition : Condition) : tx.items[n]? = some (FoldItem.write o e) →
 oracle ∈ tx.cageIn.oracles → condition ∈ (e oracle).conditions →
 ¬ condition.holds (atTurn tx n).trie → ¬ foldAccepted tx := by
  intro hi ho hc hn hf
  exact hn ((fold_all_conditions_hold tx hf n o e hi).2 oracle ho condition hc)

theorem fold_evidence_binds_conditions {s s' : State} (tx : FoldTx) (n : Nat) (o : RequestOutput) (e : Selection) :
 Step s (.fold tx) s' → tx.items[n]? = some (FoldItem.write o e) → ∀ oracle ∈ s.cage.oracles,
 (e oracle).authorized oracle ∧ (e oracle).approve = true ∧
 (judgmentName s.cage.id o.request oracle true (e oracle).record (e oracle).conditions ∈ s.judgments ∨
 (e oracle).signers = tx.signers) := by
  intro hs hn oracle ho
  cases hs with
  | fold tx hc _ _ hr hf =>
    have hp := (fold_only_approved_before_deadline tx hf n o e hn).2.2 oracle
      (by change oracle ∈ (foldResult tx.cageIn (tx.items.take n)).oracles; rw [(ProofHelpers.result_registry tx.cageIn (tx.items.take n)).2.1, hc]; exact ho)
    refine ⟨hp.1, hp.2.1, ?_⟩
    rcases hp.2.2 with he | he
    · apply Or.inl
      have h := hr _ he
      simp only [Evidence.name, hp.2.1, atTurn] at h
      rw [(ProofHelpers.result_registry tx.cageIn (tx.items.take n)).1, hc] at h
      exact h
    · exact Or.inr he

theorem expected_approval_lookup (c : CageState) (r : Request) (e : Selection) (refs : List TokenName) :
 hasApproval c r refs [] e ↔
 (∀ oracle ∈ c.oracles, (e oracle).authorized oracle ∧ (e oracle).approve = true) ∧
 (∀ name ∈ expectedApprovals c r e, name ∈ refs) := by
  constructor
  · intro h
    refine ⟨fun oracle ho => ⟨(h oracle ho).1, (h oracle ho).2.1⟩, ?_⟩
    intro name hn
    obtain ⟨oracle, ho, rfl⟩ := List.mem_map.mp hn
    have hp := h oracle ho
    rcases hp.2.2 with hr | hs
    · simpa only [Evidence.name, hp.2.1] using hr
    · exact False.elim (ProofHelpers.authorized_nonempty oracle (e oracle) hp.1 hs)
  · rintro ⟨ha, hr⟩ oracle ho
    refine ⟨(ha oracle ho).1, (ha oracle ho).2, Or.inl ?_⟩
    have hm := hr _ (List.mem_map.mpr ⟨oracle,ho,rfl⟩)
    simpa only [Evidence.name, (ha oracle ho).2] using hm

theorem folder_discovery_exact (s : State) (iv : Interval) (sigs : List Signer) (e : Selection) (o : RequestOutput) :
 Reachable s → (folderFinds s iv sigs e o ↔ o ∈ s.live ∧ stepValid s.cage iv s.judgments sigs e o) := by
  intro hs
  simp only [folderFinds, request_token_discovery s s.cage.id o hs, and_true]

theorem folder_discovery_executable (s : State) (iv : Interval) (sigs : List Signer) (e : Selection) (o : RequestOutput) (folder : Signer) :
 Reachable s → (folderFinds s iv sigs e o ↔
 Step s (.fold (singletonFold s iv sigs (FoldItem.write o e) folder))
 (afterFold s (singletonFold s iv sigs (FoldItem.write o e) folder))) := by
  intro hs
  rw [folder_discovery_exact s iv sigs e o hs]
  constructor
  · rintro ⟨hl, hv⟩
    apply Step.fold s _ rfl
    · simpa [singletonFold, FoldTx.requests, FoldItem.request] using hl
    · simp [singletonFold, FoldTx.claims, FoldItem.claimInput]
    · exact fun _ h => h
    · exact ProofHelpers.singleton_accepted s iv sigs (.write o e) folder hv.2.1 hv
  · intro h
    cases h with
    | fold _ hc hl _ _ hf =>
      refine ⟨hl o (by simp [singletonFold, FoldTx.requests, FoldItem.request]), ?_⟩
      exact foldRun_step_valid hf.2.2.2.2 0 (.write o e) rfl

theorem empty_fold_allowed (s : State) (iv : Interval) (who : Signer) : iv.valid →
 let tx : FoldTx := ⟨s.cage, s.cage, [], [], [], iv, who, who, [], []⟩
 Step s (.fold tx) s := by
  intro hv
  have h := Step.fold s (⟨s.cage,s.cage,[],[],[],iv,who,who,[],[]⟩ : FoldTx) rfl
    (by simp [FoldTx.requests]) (by simp [FoldTx.claims]) (by simp)
    ⟨hv, by simp [FoldTx.requests, FoldTx.claims], rfl, rfl, .nil s.cage⟩
  have hf {α : Type} (xs : List α) : xs.filter (fun _ => true) = xs := List.filter_eq_self.mpr (by simp)
  simpa [afterFold, removeRequests, FoldTx.requests, FoldTx.claims, hf] using h

theorem empty_fold_earns_nothing (tx : FoldTx) : foldAccepted tx → tx.items = [] →
 tx.payments = [] ∧ tx.burned = [] ∧ tx.cageOut = tx.cageIn := by
  intro h hi
  have hr := foldRun_result h.2.2.2.2
  exact ⟨by simpa [hi, foldPayments] using h.2.2.2.1, by simpa [hi] using h.2.2.1,
   by simpa [hi, foldResult] using hr⟩

theorem only_fold_changes_registry {s s' : State} {a : Action} : Step s a s' → s'.cage ≠ s.cage → ∃ tx, a = .fold tx := by
  intro h hn
  cases h <;> try exact False.elim (hn rfl)
  exact ⟨_, rfl⟩

theorem reachable_balances_backed (s : State) : Reachable s → Backed s.cage := by
  sorry

theorem fold_value_conservation (s s' : State) (tx : FoldTx) : Reachable s → Step s (.fold tx) s' →
 s.cage.value + requestEscrows tx.items + claimEscrows tx.items =
 s'.cage.value + requestRemainders s.cage tx.items + claimPayouts s.cage tx.items + claimEscrows tx.items := by
  sorry

theorem fold_request_conservation (tx : FoldTx) : foldAccepted tx →
 requestEscrows tx.items = grossCredits tx.cageIn tx.items + requestRemainders tx.cageIn tx.items := by
  sorry

theorem fold_balance_conservation (s s' : State) (tx : FoldTx) : Reachable s → Step s (.fold tx) s' →
 balanceSum s.cage + grossCredits s.cage tx.items = balanceSum s'.cage + claimPayouts s.cage tx.items := by
  sorry

theorem fold_payments_exact (tx : FoldTx) : foldAccepted tx →
 tx.payments = foldPayments tx.cageIn tx.folder tx.items ∧
 totalPaid tx.payments = requestRemainders tx.cageIn tx.items + claimPayouts tx.cageIn tx.items + claimEscrows tx.items := by
  sorry

theorem group_credits_only_recorded_signers (c : CageState) (r : Request) (o : Oracle) (e : Evidence) (k : Signer) :
 e.authorized o → k ∉ OracleIdentity.recordedKeys e.record → OracleIdentity.paidTo (oracleCredits r o e) k = 0 := by
  intro ha hk
  have he : oracleCredits r o e = OracleIdentity.splitRecorded e.record (r.fee o) := by
    simp [oracleCredits, OracleIdentity.splitFee, Evidence.authorized] at ha ⊢
    rw [ha]
    rfl
  rw [he]
  exact OracleIdentity.unpaid_of_record_absent e.record (r.fee o) k hk

theorem group_credits_exact_split (r : Request) (o : Oracle) (e : Evidence) : e.authorized o →
 oracleCredits r o e = OracleIdentity.splitRecorded e.record (r.fee o) := by
  intro ha
  change OracleIdentity.authorize o e.description e.signers = some e.record at ha
  simp [oracleCredits, OracleIdentity.splitFee, ha]

theorem judgment_record_cannot_change (c : CageId) (r : Request) (o : Oracle) (v : Bool)
 (a b : SigningRecord) (cs : List Condition) : judgmentName c r o v a cs = judgmentName c r o v b cs → a = b := by
  cases v <;> simp [judgmentName, tokenName, TokenName.mk.injEq]

theorem claim_creation_inversion {s s' : State} (tx : ClaimCreateTx) : Step s (.claimCreate tx) s' →
 tx.cageRef = s.cage ∧ tx.output.cage = s.cage.id ∧ tx.output.key ∈ registryKeys s.cage ∧
 tx.output.key ∈ tx.signers ∧ tx.output.tokens = [claimName s.cage.id] ∧
 tx.minted = tx.output.tokens ∧ tx.output.ref ∉ s.usedOutputs ∧ s' = afterClaimCreate s tx := by
  intro h
  cases h with
  | claimCreate _ hc ha hf =>
    exact ⟨hc, hc ▸ ha.1, hc ▸ ha.2.1, ha.2.2.1, hc ▸ ha.2.2.2.1, ha.2.2.2.2, hf, rfl⟩

theorem reachable_claim_authorization (c : CageState) (existing : List CageId)
 (events : List (State × Action × State)) (s : State) (o : ClaimOutput) :
 registryCreated c existing → Trace (initial c) events s → o ∈ s.claims →
 ∃ before after tx, (before, Action.claimCreate tx, after) ∈ events ∧
 Step before (.claimCreate tx) after ∧ tx.output = o ∧ o.key ∈ tx.signers := by
  intro _ ht ho
  rcases ProofHelpers.claim_origin_trace ht o ho with hi | hi
  · simp [initial] at hi
  · exact hi

theorem claim_payout_fixed (tx : FoldTx) (n : Nat) (o : ClaimOutput) : foldAccepted tx →
 tx.items[n]? = some (FoldItem.claim o) →
 itemPayments (atTurn tx n) tx.folder (FoldItem.claim o) =
 [⟨o.destination, o.datum, (atTurn tx n).balances o.key⟩, ⟨tx.folder, "", o.value⟩] ∧
 (itemResult (atTurn tx n) (FoldItem.claim o)).balances o.key = 0 ∧
 (∀ k, k ≠ o.key → (itemResult (atTurn tx n) (FoldItem.claim o)).balances k = (atTurn tx n).balances k) := by
  intro _ _
  refine ⟨rfl, ?_, ?_⟩
  · simp [itemResult]
  · intro k hk; simp [itemResult, hk]

theorem claim_payout_in_actual_outputs (tx : FoldTx) (n : Nat) (o : ClaimOutput) : foldAccepted tx →
 tx.items[n]? = some (FoldItem.claim o) → ⟨o.destination, o.datum, (atTurn tx n).balances o.key⟩ ∈ tx.payments := by
  intro hf hn
  rw [hf.2.2.2.1]
  have hm : ∀ (items : List FoldItem) (c : CageState) (n : Nat), items[n]? = some (.claim o) →
   (⟨o.destination,o.datum,(foldResult c (items.take n)).balances o.key⟩ : Payment) ∈ foldPayments c tx.folder items := by
   intro items
   induction items with
   | nil => simp
   | cons item rest ih =>
     intro c n h
     cases n with
     | zero =>
       simp only [List.getElem?_cons_zero, Option.some.injEq] at h
       subst item
       simp [foldPayments,itemPayments,foldResult]
     | succ n => exact List.mem_append_right _ (ih (itemResult c item) n h)
  exact hm tx.items tx.cageIn n hn

theorem claim_below_minimum_refused (c : CageState) (iv : Interval) (o : ClaimOutput) :
 c.balances o.key < c.minimum → ¬ claimAllowed c iv o := by
  intro h ha
  have := ha.2.2.2.2.2
  omega

theorem claim_turn_balance (c : CageState) (o : RequestOutput) (e : Selection) (claim : ClaimOutput) (folder : Signer) :
 itemPayments (itemResult c (FoldItem.write o e)) folder (FoldItem.claim claim) =
 [⟨claim.destination, claim.datum, c.balances claim.key + OracleIdentity.paidTo (credits c o.request e) claim.key⟩,
 ⟨folder, "", claim.value⟩] := by
  rfl

theorem claim_consumed_and_burned {s s' : State} (tx : FoldTx) (o : ClaimOutput) :
 Step s (.fold tx) s' → o ∈ tx.claims → o ∉ s'.claims ∧ ∀ token ∈ o.tokens, token ∈ tx.burned := by
  intro h ho
  cases h with
  | fold _ _ _ _ _ ha =>
    refine ⟨by simp [afterFold, ho], ?_⟩
    intro token ht
    rw [ha.2.2.1]
    obtain ⟨item, hi, he⟩ := List.mem_filterMap.mp ho
    cases item with
    | write r e => simp [FoldItem.claimInput] at he
    | account r e => simp [FoldItem.claimInput] at he
    | claim c =>
      simp only [FoldItem.claimInput, Option.some.injEq] at he
      subst c
      exact List.mem_flatMap.mpr ⟨.claim o, hi, ht⟩

theorem claim_withdrawal_inversion {s s' : State} (tx : ClaimWithdrawTx) : Reachable s → Step s (.claimWithdraw tx) s' →
 tx.input ∈ s.claims ∧ tx.input.key ∈ tx.signers ∧ tx.input.deadline ≤ tx.interval.lower ∧
 tx.interval.valid ∧ tx.burned = tx.input.tokens ∧ tx.beneficiary = tx.input.key ∧ tx.paid = tx.input.value ∧
 s'.cage = s.cage ∧ tx.input ∉ s'.claims := by
  sorry

theorem claim_withdrawal_available (s : State) (o : ClaimOutput) (iv : Interval) :
 o ∈ s.claims → iv.valid → o.deadline ≤ iv.lower →
 let tx : ClaimWithdrawTx := ⟨o, iv, [o.key], o.tokens, o.key, o.value⟩
 Step s (.claimWithdraw tx) (afterClaimWithdraw s tx) := by
  intro hl hv ht
  exact Step.claimWithdraw s _ hl ⟨hv, ht, by simp, rfl, rfl, rfl⟩

theorem claim_windows_disjoint (c : CageState) (iv : Interval) (o : ClaimOutput) (tx : ClaimWithdrawTx) :
 claimAllowed c iv o → tx.input = o → tx.interval = iv → ¬ claimWithdrawAllowed tx := by
  intro hc ho hi hw
  have h1 := hc.2.2.2.2.1
  have h2 := hw.2.1
  have h3 := hc.2.2.2.1
  simp only [ho, hi, Interval.valid] at h2 h3
  (simp only [Time] at *; omega)

theorem claim_discovery_exact (s : State) (id : CageId) (o : ClaimOutput) : Reachable s →
 (o ∈ discoverClaims id s.claims ↔ o ∈ s.claims ∧ s.cage.id = id) := by
  sorry

theorem request_withdrawal_preserves_registry {s s' : State} (tx : WithdrawTx) : Step s (.withdraw tx) s' → s'.cage = s.cage := by
  intro h
  cases h
  rfl

theorem fold_interval_fits_every_item (tx : FoldTx) : foldAccepted tx → tx.interval.valid ∧
 (∀ o e, FoldItem.write o e ∈ tx.items → tx.interval.upper < o.request.deadline) ∧
 (∀ o e, FoldItem.account o e ∈ tx.items → o.request.deadline ≤ tx.interval.lower ∧
 tx.interval.upper ≤ o.request.deadline + o.request.window) ∧
 (∀ o, FoldItem.claim o ∈ tx.items → tx.interval.upper < o.deadline) := by
  intro h
  refine ⟨h.1, ?_, ?_, ?_⟩
  · intro o e hm
    obtain ⟨n, hn⟩ := List.mem_iff_getElem?.mp hm
    exact (fold_only_approved_before_deadline tx h n o e hn).2.1
  · intro o e hm
    obtain ⟨n, hn⟩ := List.mem_iff_getElem?.mp hm
    have hi := foldRun_step_valid h.2.2.2.2 n (.account o e) hn
    exact ⟨hi.2.2.1, hi.2.2.2.1⟩
  · intro o hm
    obtain ⟨n, hn⟩ := List.mem_iff_getElem?.mp hm
    exact (foldRun_step_valid h.2.2.2.2 n (.claim o) hn).2.2.2.2.1

/-- Public source/action/target inversion. The lower-level guard statements above
pin the meanings of the named guards; this pins the authoritative constructors. -/
theorem step_inversion (s s' : State) (a : Action) : Step s a s' ↔
 (match a with
 | .create tx o => tx.cageRef = s.cage ∧ createAllowed tx o ∧
     (∀ seed ∈ tx.spent, seed ∉ s.usedSeeds) ∧ o.ref ∉ s.usedOutputs ∧ s' = afterCreate s tx o
 | .judge tx => tx.cageRef = s.cage ∧ tx.requestRef ∈ s.live ∧ judgmentAllowed tx ∧ s' = afterJudgment s tx
 | .fold tx => tx.cageIn = s.cage ∧ (∀ o ∈ tx.requests, o ∈ s.live) ∧
     (∀ o ∈ tx.claims, o ∈ s.claims) ∧ (∀ name ∈ tx.refs, name ∈ s.judgments) ∧
     foldAccepted tx ∧ s' = afterFold s tx
 | .withdraw tx => tx.input ∈ s.live ∧ withdrawAllowed tx ∧ s' = afterExit s tx.input
 | .burn name => name ∈ s.judgments ∧ s' = afterBurn s name
 | .priceMint tx => priceMintAllowed tx ∧ s' = afterPriceMint s tx
 | .priceUpdate tx => tx.input ∈ s.notices ∧ priceUpdateAllowed tx ∧ s' = afterPriceUpdate s tx
 | .claimCreate tx => tx.cageRef = s.cage ∧ claimCreateAllowed tx ∧
     tx.output.ref ∉ s.usedOutputs ∧ s' = afterClaimCreate s tx
 | .claimWithdraw tx => tx.input ∈ s.claims ∧ claimWithdrawAllowed tx ∧ s' = afterClaimWithdraw s tx) := by
  constructor
  · intro h; cases h <;> simp_all
  · cases a with
    | create tx o => rintro ⟨hc, ha, hf, ho, rfl⟩; exact .create s tx o hc ha hf ho
    | judge tx => rintro ⟨hc, hl, ha, rfl⟩; exact .judge s tx hc hl ha
    | fold tx => rintro ⟨hc, hl, hcl, hr, ha, rfl⟩; exact .fold s tx hc hl hcl hr ha
    | withdraw tx => rintro ⟨hl, ha, rfl⟩; exact .withdraw s tx hl ha
    | burn n => rintro ⟨hn, rfl⟩; exact .burn s n hn
    | priceMint tx => rintro ⟨ha, rfl⟩; exact .priceMint s tx ha
    | priceUpdate tx => rintro ⟨hl, ha, rfl⟩; exact .priceUpdate s tx hl ha
    | claimCreate tx => rintro ⟨hc, ha, hf, rfl⟩; exact .claimCreate s tx hc ha hf
    | claimWithdraw tx => rintro ⟨hl, ha, rfl⟩; exact .claimWithdraw s tx hl ha

theorem foldRun_inversion (iv : Interval) (refs : List TokenName) (sigs : List Signer)
 (c out : CageState) (items : List FoldItem) : FoldRun iv refs sigs c items out ↔
 (match items with
 | [] => out = c
 | item :: rest => itemAllowed c iv refs sigs item ∧ FoldRun iv refs sigs (itemResult c item) rest out) := by
  constructor
  · intro h; cases h <;> simp_all
  · cases items with
    | nil => intro h; subst out; exact .nil c
    | cons i rest => intro h; exact .cons c i rest out h.1 h.2

theorem claim_item_inversion (tx : FoldTx) (n : Nat) (o : ClaimOutput) :
 foldAccepted tx → tx.items[n]? = some (FoldItem.claim o) →
 o.cage = tx.cageIn.id ∧ o.key ∈ registryKeys tx.cageIn ∧ o.tokens = [claimName tx.cageIn.id] ∧
 tx.interval.valid ∧ tx.interval.upper < o.deadline ∧ tx.cageIn.minimum ≤ (atTurn tx n).balances o.key := by
  intro h hn
  have hi := foldRun_step_valid h.2.2.2.2 n (.claim o) hn
  have hr := ProofHelpers.result_registry tx.cageIn (tx.items.take n)
  exact ⟨hi.1.trans hr.1, by simpa [registryKeys, hr.2.1] using hi.2.1,
   by simpa [hr.1] using hi.2.2.1, hi.2.2.2.1, hi.2.2.2.2.1,
   by simpa [hr.2.2.2.2] using hi.2.2.2.2.2⟩

/-- Point intervals cover every time, including the exact claim deadline. All
non-time claim guards remain explicit; balance sufficiency is not liveness. -/
theorem claim_windows_cover (c : CageState) (o : ClaimOutput) (now : Time) :
 o.cage = c.id → o.key ∈ registryKeys c → o.tokens = [claimName c.id] →
 c.minimum ≤ c.balances o.key →
 claimAllowed c ⟨now, now⟩ o ∨
 claimWithdrawAllowed ⟨o, ⟨now, now⟩, [o.key], o.tokens, o.key, o.value⟩ := by
  intro hc hk hn hb
  by_cases h : now < o.deadline
  · exact Or.inl ⟨hc, hk, hn, Nat.le_refl _, h, hb⟩
  · exact Or.inr ⟨Nat.le_refl _, by (simp only [Time] at *; omega), by simp, rfl, rfl, rfl⟩

/-- Every selected record is bound to a shown judgment or an inline approval.
Across all items, a key absent from all such records cannot gain balance. -/
theorem fold_group_credits_only_recorded_signers (s s' : State) (tx : FoldTx) :
 Step s (.fold tx) s' →
 (∀ (n : Nat) o e, (tx.items[n]? = some (FoldItem.write o e) ∨
   tx.items[n]? = some (FoldItem.account o e)) → ∀ oracle ∈ tx.cageIn.oracles,
   (e oracle).authorized oracle ∧
   ((e oracle).name tx.cageIn.id o.request oracle ∈ s.judgments ∨
     ((e oracle).approve = true ∧ (e oracle).signers = tx.signers)) ∧
   (∀ key, key ∉ OracleIdentity.recordedKeys (e oracle).record →
     OracleIdentity.paidTo (oracleCredits o.request oracle (e oracle)) key = 0)) ∧
 (∀ key, (∀ (n : Nat) o e, (tx.items[n]? = some (FoldItem.write o e) ∨
   tx.items[n]? = some (FoldItem.account o e)) → ∀ oracle ∈ tx.cageIn.oracles,
   key ∉ OracleIdentity.recordedKeys (e oracle).record) →
   s'.cage.balances key ≤ s.cage.balances key) := by
  sorry

/-- The indexed histories used for claim provenance cover exactly Reachable. -/
theorem trace_reachability (s : State) : Reachable s ↔
 ∃ c existing events, registryCreated c existing ∧ Trace (initial c) events s := by
  constructor
  · intro h
    induction h with
    | registry c ex hc => exact ⟨c,ex,[],hc,.nil _⟩
    | @next s s' action hr hs ih =>
      obtain ⟨c,ex,events,hc,ht⟩ := ih
      exact ⟨c,ex,events ++ [(s,action,s')],hc,ProofHelpers.trace_snoc ht hs⟩
  · rintro ⟨c,ex,events,hc,ht⟩
    exact ProofHelpers.trace_reaches ht (.registry c ex hc)

/-- The boundary observation itself has disjoint windows, independently of
actual-spend classification. Together with exit_windows_cover this pins A144. -/
theorem exit_windows_disjoint (o : RequestOutput) (iv : Interval) (a b : ExitKind) :
 exitAt o iv a → exitAt o iv b → a = b := by
  cases a <;> cases b <;> simp only [exitAt, Interval.valid] <;> intros <;> first | exact True.intro | rfl | (simp only [Time] at *; omega)

end RequestApprovalFold
