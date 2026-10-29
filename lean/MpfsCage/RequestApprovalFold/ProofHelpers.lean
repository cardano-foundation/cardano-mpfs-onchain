import MpfsCage.RequestApprovalFold.Model
import MpfsCage.OracleIdentity.Statements

namespace RequestApprovalFold.ProofHelpers

theorem registry_refl (c : CageState) : SameRegistry c c := ⟨rfl,rfl,rfl,rfl,rfl⟩

theorem registry_trans {a b c : CageState} (h : SameRegistry a b) (k : SameRegistry b c) : SameRegistry a c :=   ⟨h.1.trans k.1, h.2.1.trans k.2.1, h.2.2.1.trans k.2.2.1,
   h.2.2.2.1.trans k.2.2.2.1, h.2.2.2.2.trans k.2.2.2.2⟩

theorem item_registry (c : CageState) (i : FoldItem) : SameRegistry (itemResult c i) c := by
  cases i <;> exact registry_refl c

theorem result_registry (c : CageState) (items : List FoldItem) : SameRegistry (foldResult c items) c := by
  induction items generalizing c with
  | nil => exact registry_refl c
  | cons i rest ih => exact registry_trans (ih (itemResult c i)) (item_registry c i)

theorem fees_registry {a b : CageState} (h : SameRegistry a b) (r : Request) : totalFees a r = totalFees b r := by
  simp [totalFees, h.2.1]

theorem write_trie (c : CageState) (o : RequestOutput) (e : Selection) :
 (itemResult c (.write o e)).trie = o.request.write.apply c.trie := by
 funext k
 simp only [itemResult, CageState.trie]
 unfold writeTree
 split
 · rename_i h
   cases hw : o.request.write with
   | set q v =>
     have hv := h.2
     simp only [hw, Write.key, Write.value] at hv
     by_cases hk : k = q
     · subst k; simpa [Write.apply] using hv
     · simp [Write.apply, hk]
   | unset q =>
     have hv := h.2
     simp only [hw, Write.key, Write.value] at hv
     by_cases hk : k = q
     · subst k; simpa [Write.apply] using hv
     · simp [Write.apply, hk]
 · cases hw : o.request.write <;> cases hs : o.request.witnessing <;>
     simp only [logicalTree, putEntry, writeEntry, Write.key, Write.apply]
   all_goals split <;> simp_all [Entry.logical]

theorem result_trie (c : CageState) (items : List FoldItem)
 (iv : Interval) (refs : List TokenName) (sigs : List Signer) (out : CageState)
 (run : FoldRun iv refs sigs c items out) :
 (foldResult c items).trie = applyAll c.trie (items.flatMap FoldItem.writes) := by
 induction run with
 | nil => rfl
 | cons c i rest out ha hr ih =>
   simp only [foldResult, List.flatMap_cons]
   rw [ih]
   cases i with
   | write o e => simpa [FoldItem.writes, applyAll, write_trie] using congrArg (fun t => applyAll t (rest.flatMap FoldItem.writes)) (write_trie c o e)
   | account o e => rfl
   | claim o => rfl
   | extract o =>
     have he : (itemResult c (.extract o)).trie = c.trie := by
       funext k
       by_cases hk : k = o.key
       · subst k; simpa [itemResult, CageState.trie, logicalTree, putEntry, Entry.logical, Extraction.data] using ha.2.2.2.2.symm
       · simp [itemResult, CageState.trie, logicalTree, putEntry, hk]
     simpa [FoldItem.writes] using congrArg (fun t => applyAll t (rest.flatMap FoldItem.writes)) he
   | extractAccount o => rfl

theorem singleton_accepted (s : State) (iv : Interval) (sigs : List Signer) (i : FoldItem) (folder : Signer)
 (hv : iv.valid) (hi : itemAllowed s.cage iv s.judgments sigs i) :
 foldAccepted (singletonFold s iv sigs i folder) := by
 refine ⟨hv, ?_, by simp [singletonFold, withWitnessBoundary], by simp [singletonFold, withWitnessBoundary, foldPayments], FoldRun.cons _ _ [] _ hi (FoldRun.nil _), ⟨rfl,rfl,rfl,rfl,rfl⟩⟩
 cases i <;> simp [singletonFold, withWitnessBoundary, FoldTx.requests, FoldTx.claims, FoldTx.extractions, FoldItem.request, FoldItem.claimInput, FoldItem.extraction]

theorem oracle_total (r : Request) (o : Oracle) (e : Evidence) (ha : e.authorized o) :
 OracleIdentity.totalPaid (oracleCredits r o e) = r.fee o := by
 change OracleIdentity.authorize o e.description e.signers = some e.record at ha
 simp only [oracleCredits, OracleIdentity.splitFee, ha, Option.map_some, Option.getD_some]
 exact OracleIdentity.authorized_total o e.description e.signers e.record (r.fee o) ha

theorem credits_total (c : CageState) (r : Request) (e : Selection)
 (ha : ∀ o ∈ c.oracles, (e o).authorized o) :
 OracleIdentity.totalPaid (credits c r e) = totalFees c r := by
 unfold credits totalFees
 generalize c.oracles = os at *
 revert ha
 induction os with
 | nil => intro _; rfl
 | cons o os ih =>
   intro ha
   simp only [List.flatMap_cons, List.map_cons, List.sum_cons]
   simp only [OracleIdentity.totalPaid, List.map_append, List.sum_append]
   change OracleIdentity.totalPaid (oracleCredits r o (e o)) + _ = _
   rw [oracle_total r o (e o) (ha o (by simp))]
   exact congrArg (fun x => r.fee o + x) (ih (fun o ho => ha o (by simp [ho])))

theorem run_result {iv refs sigs c items out} (h : FoldRun iv refs sigs c items out) : out = foldResult c items := by
 induction h with
 | nil => rfl
 | cons _ _ _ _ _ _ ih => exact ih

theorem step_registry {s s' : State} {a : Action} (h : Step s a s') : SameRegistry s'.cage s.cage := by
 cases h <;> try exact registry_refl _
 rename_i tx hc _ _ _ ha _ _
 rw [show (afterFold s tx).cage = tx.cageOut from rfl, run_result ha.2.2.2.2.1]
 exact hc ▸ result_registry tx.cageIn tx.items

theorem wf_registry {a b : CageState} (h : SameRegistry a b) (o : RequestOutput) : wellFormed a o ↔ wellFormed b o := by
 simp only [wellFormed, totalFees, requestPolicy, h.1, h.2.1, h.2.2.2.1, h.2.2.2.2]

theorem live_wf (s : State) (h : Reachable s) : ∀ o ∈ s.live, wellFormed s.cage o := by
 induction h with
 | registry c existing hc => simp [initial]
 | @next s s' a hr hs ih =>
   intro o ho
   have hc := step_registry hs
   cases hs <;> try exact ih o ho
   case create tx new he ha hf hf' =>
     rcases List.mem_cons.mp ho with h | h
     · subst o; exact he ▸ ha.2.2.2.1
     · exact ih o h
   case fold tx he hl hcl href ha =>
     exact (wf_registry hc o).mpr (ih o (List.mem_filter.mp ho).1)
   case withdraw tx hl ha => exact ih o (List.mem_filter.mp ho).1

theorem registry_valid (s : State) (h : Reachable s) : RegistryValid s.cage := by
 induction h with
 | registry c ex hc => exact hc.2.1
 | next hr hs ih =>
   have hc := step_registry hs
   simpa only [RegistryValid, hc.2.1, hc.2.2.2.1, hc.2.2.2.2] using ih

theorem request_member (tx : FoldTx) (o : RequestOutput) : o ∈ tx.requests ↔
 (∃ e, FoldItem.write o e ∈ tx.items) ∨ (∃ e, FoldItem.account o e ∈ tx.items) := by
 constructor
 · intro h
   obtain ⟨i, hi, he⟩ := List.mem_filterMap.mp h
   cases i with
   | write x e => simp only [FoldItem.request, Option.some.injEq] at he; subst x; exact Or.inl ⟨e, hi⟩
   | account x e => simp only [FoldItem.request, Option.some.injEq] at he; subst x; exact Or.inr ⟨e, hi⟩
   | claim x => simp [FoldItem.request] at he
   | extract x => simp [FoldItem.request] at he
   | extractAccount x => simp [FoldItem.request] at he
 · rintro (⟨e, he⟩ | ⟨e, he⟩)
   · exact List.mem_filterMap.mpr ⟨.write o e, he, rfl⟩
   · exact List.mem_filterMap.mpr ⟨.account o e, he, rfl⟩

theorem claim_origin_step {s s' : State} {a : Action} (h : Step s a s') (o : ClaimOutput)
 (ho : o ∈ s'.claims) : o ∈ s.claims ∨ ∃ tx, a = .claimCreate tx ∧ tx.output = o ∧ o.key ∈ tx.signers := by
 cases h <;> try exact Or.inl ho
 case fold tx _ _ _ _ _ => exact Or.inl (List.mem_filter.mp ho).1
 case claimCreate tx hc ha hf =>
   rcases List.mem_cons.mp ho with he | he
   · exact Or.inr ⟨tx, rfl, he.symm, he ▸ ha.2.2.1⟩
   · exact Or.inl he
 case claimWithdraw tx _ _ => exact Or.inl (List.mem_of_mem_erase ho)

theorem claim_origin_trace {start s : State} {events : List (State × Action × State)}
 (h : Trace start events s) (o : ClaimOutput) (ho : o ∈ s.claims) :
 o ∈ start.claims ∨ ∃ before after tx, (before, Action.claimCreate tx, after) ∈ events ∧
 Step before (.claimCreate tx) after ∧ tx.output = o ∧ o.key ∈ tx.signers := by
 induction h with
 | nil => exact Or.inl ho
 | @cons a b c action rest hs ht ih =>
   rcases ih ho with hmid | ⟨before, after, tx, hm, hx, he, hk⟩
   · rcases claim_origin_step hs o hmid with hfirst | ⟨tx, he, hout, hk⟩
     · exact Or.inl hfirst
     · subst action
       exact Or.inr ⟨a,b,tx,by simp,hs,hout,hk⟩
   · exact Or.inr ⟨before,after,tx,List.mem_cons_of_mem _ hm,hx,he,hk⟩

theorem trace_snoc {a b c : State} {events : List (State × Action × State)} {action : Action}
 (ht : Trace a events b) (hs : Step b action c) : Trace a (events ++ [(b, action, c)]) c := by
 induction ht with
 | nil => exact .cons hs (.nil _)
 | cons h _ ih => exact .cons h (ih hs)

theorem trace_reaches {a b : State} {events : List (State × Action × State)}
 (ht : Trace a events b) (ha : Reachable a) : Reachable b := by
 induction ht with
 | nil => exact ha
 | cons hs _ ih => exact ih (.next ha hs)

theorem authorized_nonempty (o : Oracle) (e : Evidence) (ha : e.authorized o) : e.signers ≠ [] := by
 intro he
 obtain ⟨_, hv, hr⟩ := (OracleIdentity.auth_iff _ _ _ _).mp ha
 have hv' : OracleIdentity.shapeValid e.description = true :=
   (show OracleIdentity.shapeValid e.description = true ∧ (OracleIdentity.keys e.description).Nodup by simpa [OracleIdentity.valid] using hv).1
 have hp := OracleIdentity.sound_keys_positive e.record (OracleIdentity.record_sound _ _ _ hv' hr)
 have hs := OracleIdentity.record_signers e.description e.signers e.record hr
 have hn : OracleIdentity.recordedKeys e.record = [] := List.eq_nil_iff_forall_not_mem.mpr (by
   intro k hk
   have hm := hs k hk
   simp [he] at hm)
 rw [hn] at hp
 exact Nat.not_lt_zero _ hp

theorem claim_tokens (s : State) (h : Reachable s) :
 ∀ o ∈ s.claims, o.tokens = [claimName s.cage.id] := by
 induction h with
 | registry c ex hc => simp [initial]
 | @next s s' a hr hs ih =>
   intro o ho
   have hc := step_registry hs
   cases hs <;> try exact ih o ho
   case fold tx _ _ _ _ _ =>
     simpa only [hc.1] using ih o (List.mem_filter.mp ho).1
   case claimCreate tx he ha hf =>
     rcases List.mem_cons.mp ho with he' | he'
     · subst o; exact he ▸ ha.2.2.2.1
     · exact ih o he'
   case claimWithdraw tx _ _ => exact ih o (List.mem_of_mem_erase ho)

theorem run_request_conservation {iv refs sigs c items out}
 (h : FoldRun iv refs sigs c items out) :
 requestEscrows items = grossCredits c items + requestRemainders c items + requestDepositInputs items := by
 induction h with
 | nil => simp [requestEscrows, grossCredits, requestRemainders, requestDepositInputs]
 | cons c i items out ha hr ih =>
   cases i with
   | write o e =>
     have ht := credits_total c o.request e (fun x hx => (ha.2.2.2.2.1 x hx).1)
     have hf := ha.2.1.2.2.1
     simp only [requestEscrows, requestDepositInputs, List.filterMap_cons, FoldItem.request, FoldItem.extraction, List.map_cons,
       List.sum_cons, grossCredits, itemCredits, requestRemainders, RequestOutput.escrow] at *
     unfold remainder
     omega
   | account o e =>
     have ht := credits_total c o.request e (fun x hx => (ha.2.2.2.2 x hx).1)
     have hf := ha.1.2.2.1
     simp only [requestEscrows, requestDepositInputs, List.filterMap_cons, FoldItem.request, FoldItem.extraction, List.map_cons,
       List.sum_cons, grossCredits, itemCredits, requestRemainders, RequestOutput.escrow] at *
     unfold remainder
     omega
   | claim o =>
     simpa [requestEscrows, grossCredits, requestRemainders, requestDepositInputs, FoldItem.request,
       FoldItem.extraction, itemCredits, OracleIdentity.totalPaid] using ih
   | extract o =>
     simpa [requestEscrows, grossCredits, requestRemainders, requestDepositInputs, FoldItem.request,
       FoldItem.extraction, itemCredits, OracleIdentity.totalPaid, Extraction.escrow, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using congrArg (fun x => x + o.value + o.witness.deposit) ih
   | extractAccount o =>
     simpa [requestEscrows, grossCredits, requestRemainders, requestDepositInputs, FoldItem.request,
       FoldItem.extraction, itemCredits, OracleIdentity.totalPaid, Extraction.escrow, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using congrArg (fun x => x + o.value + o.witness.deposit) ih

theorem event_refund_total (events : List WitnessEvent) :
 totalPaid (events.filterMap fun event => event.consumed.map fun w => (⟨w.token.data.refund,"",w.value⟩ : Payment)) =
 witnessValue (events.filterMap WitnessEvent.consumed) := by
 induction events with
 | nil => rfl
 | cons e es ih =>
   cases he : e.consumed <;> simp_all [totalPaid, witnessValue]

theorem refund_cons (c : CageState) (i : FoldItem) (items : List FoldItem) :
 witnessRefundTotal c (i :: items) = totalPaid (itemWitnessRefunds c i) + witnessRefundTotal (itemResult c i) items := by
 rw [show totalPaid (itemWitnessRefunds c i) = witnessValue ((itemWitnessEvents c i).filterMap WitnessEvent.consumed) from event_refund_total _]
 simp [witnessRefundTotal,foldWitnessEvents,witnessValue]

theorem payments_total (c : CageState) (folder : Signer) (items : List FoldItem)
 (iv : Interval) (refs : List TokenName) (sigs : List Signer) (out : CageState)
 (run : FoldRun iv refs sigs c items out) :
 totalPaid (foldPayments c folder items) =
 requestRemainders c items + claimPayouts c items + claimEscrows items +
 unusedDepositRefunds items + witnessRefundTotal c items := by
 induction run with
 | nil => simp [foldPayments,totalPaid,requestRemainders,claimPayouts,claimEscrows,unusedDepositRefunds,witnessRefundTotal,foldWitnessEvents,witnessValue]
 | cons c i items out ha hr ih =>
   rw [refund_cons]
   simp only [foldPayments, totalPaid, List.map_append, List.sum_append]
   change totalPaid (itemPayments c folder i) + totalPaid (foldPayments (itemResult c i) folder items) = _
   rw [ih]
   cases i with
   | write o e =>
     simp [itemPayments,totalPaid,requestRemainders,claimPayouts,claimEscrows,unusedDepositRefunds,FoldItem.claimInput,Nat.add_assoc,Nat.add_comm,Nat.add_left_comm]
   | account o e =>
     cases hs : o.request.witnessing <;>
       simp [itemPayments,totalPaid,requestRemainders,claimPayouts,claimEscrows,unusedDepositRefunds,FoldItem.claimInput,itemWitnessRefunds,itemWitnessEvents,FoldItem.entryKey,unusedDepositPayments,Request.deposit,hs,Nat.add_assoc,Nat.add_comm,Nat.add_left_comm]
   | claim o =>
     simp [itemPayments,totalPaid,requestRemainders,claimPayouts,claimEscrows,unusedDepositRefunds,FoldItem.claimInput,itemWitnessRefunds,itemWitnessEvents,FoldItem.entryKey,Nat.add_assoc,Nat.add_comm,Nat.add_left_comm]
   | extract o =>
     have he : itemWitnessRefunds c (.extract o) = [] := by
       simp only [itemWitnessRefunds,itemWitnessEvents,FoldItem.entryKey,ha.2.2.2.1,Option.map_none]
       split <;> simp
     simp [itemPayments,totalPaid,requestRemainders,claimPayouts,claimEscrows,unusedDepositRefunds,FoldItem.claimInput,he,Nat.add_assoc,Nat.add_comm,Nat.add_left_comm]
   | extractAccount o =>
     simp [itemPayments,totalPaid,requestRemainders,claimPayouts,claimEscrows,unusedDepositRefunds,FoldItem.claimInput,itemWitnessRefunds,itemWitnessEvents,FoldItem.entryKey,Nat.add_assoc,Nat.add_comm,Nat.add_left_comm]

theorem credits_cover (c : CageState) (r : Request) (e : Selection)
 (ha : ∀ o ∈ c.oracles, (e o).authorized o) :
 ∀ p ∈ credits c r e, p.key ∈ registryKeys c := by
 intro p hp
 obtain ⟨o, ho, hp⟩ := List.mem_flatMap.mp hp
 have he := ha o ho
 change OracleIdentity.authorize o (e o).description (e o).signers = some (e o).record at he
 have hs : oracleCredits r o (e o) = OracleIdentity.splitRecorded (e o).record (r.fee o) := by
   simp [oracleCredits, OracleIdentity.splitFee, he]
 rw [hs] at hp
 have hk := (OracleIdentity.recorded_keys_are_signers o (e o).description (e o).signers
   (e o).record he p.key (OracleIdentity.payment_key_recorded _ _ _ hp)).2
 have hid := OracleIdentity.authorization_binds_identity _ _ _ _ he
 apply List.mem_eraseDups.mpr
 apply List.mem_flatMap.mpr
 have hd : o.description = (e o).description := congrArg OracleIdentity.Identity.description hid
 exact ⟨o, ho, hd ▸ hk⟩

theorem credit_backed (c : CageState) (ps : List OracleIdentity.Payment) (hb : Backed c)
 (hp : ∀ p ∈ ps, p.key ∈ registryKeys c) : Backed (credit c ps) := by
 constructor
 · change c.value + OracleIdentity.totalPaid ps =
     ((registryKeys c).map (fun k => c.balances k + OracleIdentity.paidTo ps k)).sum
   have hn : (registryKeys c).Nodup := OracleIdentity.dedup_keys_nodup _
   rw [OracleIdentity.sum_map_add, OracleIdentity.sum_paid_over_cover ps (registryKeys c) hn hp]
   exact congrArg (fun n => n + OracleIdentity.totalPaid ps) hb.1
 · intro k hk
   change c.balances k + OracleIdentity.paidTo ps k = 0
   rw [hb.2 k hk, OracleIdentity.paid_zero_of_absent ps k
     (fun p hm he => hk (he ▸ hp p hm))]

theorem clear_sum (ks : List Signer) (f : Signer → Nat) (key : Signer)
 (hn : ks.Nodup) (hk : key ∈ ks) :
 (ks.map (fun k => if k = key then 0 else f k)).sum + f key = (ks.map f).sum := by
 have h := OracleIdentity.sum_map_add ks (fun k => if k = key then 0 else f k)
   (fun k => if key = k then f key else 0)
 rw [OracleIdentity.sum_key_indicator ks key (f key) hn, if_pos hk] at h
 rw [← h]
 congr 1
 apply List.map_congr_left
 intro k _
 by_cases he : k = key
 · subst k; simp
 · have he' : key ≠ k := Ne.symm he
   simp [he, he']

theorem claim_balance_sum (c : CageState) (o : ClaimOutput) (hk : o.key ∈ registryKeys c) :
 balanceSum (itemResult c (.claim o)) + c.balances o.key = balanceSum c := by
 exact clear_sum (registryKeys c) c.balances o.key (OracleIdentity.dedup_keys_nodup _) hk

theorem item_backed (c : CageState) (iv : Interval) (refs : List TokenName) (sigs : List Signer)
 (i : FoldItem) (hb : Backed c) (ha : itemAllowed c iv refs sigs i) : Backed (itemResult c i) := by
 cases i with
 | write o e =>
   exact credit_backed c _ hb (credits_cover c o.request e (fun x hx => (ha.2.2.2.2.1 x hx).1))
 | account o e =>
   exact credit_backed c _ hb (credits_cover c o.request e (fun x hx => (ha.2.2.2.2 x hx).1))
 | claim o =>
   have hsum := claim_balance_sum c o ha.2.1
   constructor
   · change c.value - c.balances o.key = _
     have hv := hb.1
     omega
   · intro k hk
     change (if k = o.key then 0 else c.balances k) = 0
     split
     · rfl
     · exact hb.2 k hk
 | extract _ => exact hb
 | extractAccount _ => exact hb

theorem run_backed {iv refs sigs c items out} (h : FoldRun iv refs sigs c items out)
 (hb : Backed c) : Backed out := by
 induction h with
 | nil => exact hb
 | cons c i rest out ha hr ih => exact ih (item_backed c iv refs sigs i hb ha)

theorem run_value_conservation {iv refs sigs c items out} (h : FoldRun iv refs sigs c items out)
 (hb : Backed c) : c.value + grossCredits c items = out.value + claimPayouts c items := by
 induction h with
 | nil => simp [grossCredits, claimPayouts]
 | cons c i rest out ha hr ih =>
   have ht := ih (item_backed c iv refs sigs i hb ha)
   cases i with
   | write o e =>
     simpa [grossCredits, claimPayouts, FoldItem.claimInput, itemCredits, itemResult, credit,
       Nat.add_assoc] using ht
   | account o e =>
     simpa [grossCredits, claimPayouts, FoldItem.claimInput, itemCredits, itemResult, credit,
       Nat.add_assoc] using ht
   | claim o =>
     have hsum := claim_balance_sum c o ha.2.1
     have hv := hb.1
     simp only [itemResult] at ht
     simp only [grossCredits, itemCredits, OracleIdentity.totalPaid, List.map_nil, List.sum_nil,
       Nat.zero_add, claimPayouts, FoldItem.claimInput, itemResult]
     omega
   | extract o => simpa [grossCredits, claimPayouts, FoldItem.claimInput, itemCredits, OracleIdentity.totalPaid] using ht
   | extractAccount o => simpa [grossCredits, claimPayouts, FoldItem.claimInput, itemCredits, OracleIdentity.totalPaid] using ht

theorem result_append (c : CageState) (xs ys : List FoldItem) :
 foldResult c (xs ++ ys) = foldResult (foldResult c xs) ys := by
 induction xs generalizing c with
 | nil => rfl
 | cons i rest ih => exact ih (itemResult c i)

theorem credits_unpaid (c : CageState) (r : Request) (e : Selection) (k : Signer)
 (hz : ∀ o ∈ c.oracles, OracleIdentity.paidTo (oracleCredits r o (e o)) k = 0) :
 OracleIdentity.paidTo (credits c r e) k = 0 := by
 unfold credits
 generalize c.oracles = os at *
 induction os with
 | nil => rfl
 | cons o os ih =>
   have hh := hz o (by simp)
   have ht := ih (fun x hx => hz x (by simp [hx]))
   simp only [List.flatMap_cons, OracleIdentity.paidTo, List.filter_append,
     List.map_append, List.sum_append] at *
   omega

theorem run_balance_nonincrease {iv refs sigs c items out} (h : FoldRun iv refs sigs c items out)
 (key : Signer)
 (hz : ∀ (n : Nat) o e, (items[n]? = some (FoldItem.write o e) ∨
   items[n]? = some (FoldItem.account o e)) → ∀ oracle ∈ c.oracles,
   OracleIdentity.paidTo (oracleCredits o.request oracle (e oracle)) key = 0) :
 out.balances key ≤ c.balances key := by
 induction h with
 | nil => exact Nat.le_refl _
 | cons c i rest out ha hr ih =>
   have ht := ih (fun n o e hn oracle ho =>
     hz (n+1) o e (by simpa using hn) oracle ((item_registry c i).2.1 ▸ ho))
   apply Nat.le_trans ht
   cases i with
   | write o e =>
     have hp := credits_unpaid c o.request e key (hz 0 o e (Or.inl rfl))
     simp [itemResult, credit, hp]
   | account o e =>
     have hp := credits_unpaid c o.request e key (hz 0 o e (Or.inr rfl))
     simp [itemResult, credit, hp]
   | claim o =>
     simp only [itemResult]
     split <;> omega
   | extract _ => exact Nat.le_refl _
   | extractAccount _ => exact Nat.le_refl _

theorem run_take {iv refs sigs c items out} (h : FoldRun iv refs sigs c items out) (n : Nat) :
 FoldRun iv refs sigs c (items.take n) (foldResult c (items.take n)) := by
 induction h generalizing n with
 | nil => simp only [List.take_nil,List.drop_nil,foldResult]; exact .nil _
 | cons c i rest out ha hr ih =>
   cases n with
   | zero => exact .nil _
   | succ n => exact .cons _ _ _ _ ha (ih n)

theorem run_drop {iv refs sigs c items out} (h : FoldRun iv refs sigs c items out) (n : Nat) :
 FoldRun iv refs sigs (foldResult c (items.take n)) (items.drop n) out := by
 induction h generalizing n with
 | nil => simp only [List.take_nil,List.drop_nil,foldResult]; exact .nil _
 | cons c i rest out ha hr ih =>
   cases n with
   | zero => exact .cons _ _ _ _ ha hr
   | succ n => exact ih n

theorem events_indexed (c : CageState) (items : List FoldItem) :
 foldWitnessEvents c items = items.zipIdx.flatMap (fun p => itemWitnessEvents (foldResult c (items.take p.2)) p.1) := by
 induction items generalizing c with
 | nil => rfl
 | cons i items ih =>
   simp only [foldWitnessEvents,List.zipIdx_cons',List.flatMap_cons,List.take_zero,foldResult,List.flatMap_map,Function.comp_def,Prod.map,Prod.fst,Prod.snd,List.take_succ_cons]
   exact congrArg (itemWitnessEvents c i ++ ·) (ih (itemResult c i))

theorem extraction_wf_registry {a b : CageState} (h : SameRegistry a b) (o : Extraction) :
 extractionWellFormed a o ↔ extractionWellFormed b o := by
 simp only [extractionWellFormed,h.1,h.2.2.2.2]

theorem live_extraction_wf (s : State) (h : Reachable s) :
 ∀ o ∈ s.extractions, extractionWellFormed s.cage o := by
 induction h with
 | registry c ex hc => simp [initial]
 | @next s s' a hr hs ih =>
   intro o ho
   have hc := step_registry hs
   cases hs <;> try exact ih o ho
   case extractionCreate tx he ha hf =>
     rcases List.mem_cons.mp ho with h | h
     · subst o; exact he ▸ ha.1
     · exact ih o h
   case fold tx he hl hcl href ha hex hw =>
     exact (extraction_wf_registry hc o).mpr (ih o (List.mem_filter.mp ho).1)
   case extractionWithdraw tx hl ha => exact ih o (List.mem_of_mem_erase ho)

theorem extraction_refs (s : State) (h : Reachable s) :
 ∀ o ∈ s.extractions, o.ref ∈ s.usedOutputs := by
 induction h with
 | registry c ex hc => simp [initial]
 | @next s s' a hr hs ih =>
   intro o ho
   cases hs <;> try exact ih o ho
   case create tx o hc ha hf hu => exact List.mem_cons_of_mem _ (ih _ ho)
   case claimCreate tx hc ha hf => exact List.mem_cons_of_mem _ (ih _ ho)
   case extractionCreate tx hc ha hf =>
     rcases List.mem_cons.mp ho with h | h
     · subst o; exact List.mem_cons_self
     · exact List.mem_cons_of_mem _ (ih _ h)
   case fold tx hc hl hcl hr ha hex hw => exact ih o (List.mem_filter.mp ho).1
   case extractionWithdraw tx hl ha => exact ih o (List.mem_of_mem_erase ho)

theorem witness_logical {tree : EntryTree} {k : Key} {w : WitnessData}
 (h : witnessAt tree k = some w) : logicalTree tree k = w.fact := by
 cases ht : tree k with
 | none => simp [witnessAt,ht] at h
 | some entry =>
   cases entry with
   | value v => simp [witnessAt,ht] at h
   | witnessed data =>
     have he : data = w := by simpa [witnessAt,ht] using h
     simp [logicalTree,ht,Entry.logical,he]

theorem witness_origin_step {s s' : State} {a : Action} (h : Step s a s')
 (out : WitnessOutput) (ho : out ∈ s'.witnesses) :
 out ∈ s.witnesses ∨ ∃ tx, a = .fold tx ∧ out ∈ tx.witnessOutputs ∧ out.token ∈ tx.witnessMinted := by
 cases h <;> try exact Or.inl ho
 case fold tx hc hl hcl hr ha he hw =>
   rcases List.mem_append.mp ho with h | h
   · exact Or.inl (List.mem_filter.mp h).1
   · refine Or.inr ⟨tx,rfl,h,?_⟩
     rw [ha.2.2.2.2.2.2.2.2.2]
     exact List.mem_map.mpr ⟨out,h,rfl⟩

theorem witness_origin_trace {start s : State} {events : List (State × Action × State)}
 (h : Trace start events s) (out : WitnessOutput) (ho : out ∈ s.witnesses) :
 out ∈ start.witnesses ∨ ∃ before after tx, (before,Action.fold tx,after) ∈ events ∧
 Step before (.fold tx) after ∧ out ∈ tx.witnessOutputs ∧ out.token ∈ tx.witnessMinted := by
 induction h with
 | nil => exact Or.inl ho
 | @cons a b c action rest hs ht ih =>
   rcases ih ho with hm | ⟨before,after,tx,he,hstep,hw,hb⟩
   · rcases witness_origin_step hs out hm with hfirst | ⟨tx,he,hw,hb⟩
     · exact Or.inl hfirst
     · subst action; exact Or.inr ⟨a,b,tx,by simp,hs,hw,hb⟩
   · exact Or.inr ⟨before,after,tx,List.mem_cons_of_mem _ he,hstep,hw,hb⟩

theorem item_burn_characterization (c : CageState) (iv : Interval) (refs : List TokenName)
 (sigs : List Signer) (i : FoldItem) (k : Key) (w : WitnessData) :
 itemAllowed c iv refs sigs i → witnessAt c.tree k = some w →
 ((∃ event ∈ itemWitnessEvents c i,
   event.key = k ∧ event.consumed = some (witnessOutput c.id k w)) ↔ itemChanges c i k) ∧
 (itemChanges c i k → itemWitnessRefunds c i = [⟨w.refund,"",w.deposit⟩]) := by
 intro hi hw
 have hentry : c.tree k = some (.witnessed w) := by
   cases he : c.tree k with
   | none => simp [witnessAt,he] at hw
   | some entry => cases entry <;> simp_all [witnessAt]
 cases i with
 | account o e => simp [itemWitnessEvents,FoldItem.entryKey,itemChanges,itemResult,credit,CageState.trie]
 | claim o => simp [itemWitnessEvents,FoldItem.entryKey,itemChanges,itemResult,CageState.trie]
 | extractAccount o => simp [itemWitnessEvents,FoldItem.entryKey,itemChanges,itemResult]
 | extract o =>
   have hn := hi.2.2.2.1
   by_cases hk : k = o.key
   · subst k; rw [hw] at hn; contradiction
   · simp [itemWitnessEvents,FoldItem.entryKey,itemChanges,itemResult,CageState.trie,logicalTree,putEntry,hk,Ne.symm hk]
 | write o e =>
   have hg := hi.1
   have hv := hi.2.1.2.2.2.2.2
   cases hwrite : o.request.write <;> cases hspec : o.request.witnessing <;>
     by_cases hk : k = o.request.write.key <;>
     by_cases hval : c.trie o.request.write.key = o.request.write.value
   all_goals
     simp only [witnessWriteAllowed,Request.witnessValid,hwrite,hspec] at hg hv
     simp_all [itemChanges,itemWitnessRefunds,itemWitnessEvents,FoldItem.entryKey,itemResult,writeTree,
       witnessAt,putEntry,writeEntry,Write.key,Write.value,CageState.trie,logicalTree,Entry.logical,credit,witnessOutput,ne_comm]
   all_goals cases w; simp_all [and_assoc]
   all_goals grind [putEntry,Entry.logical]

theorem indexed_event_mem (c : CageState) (items : List FoldItem) (n : Nat) (i : FoldItem)
 (event : WitnessEvent) (hn : items[n]? = some i)
 (he : event ∈ itemWitnessEvents (foldResult c (items.take n)) i) :
 event ∈ foldWitnessEvents c items := by
 induction items generalizing c n with
 | nil => simp at hn
 | cons head rest ih =>
   cases n with
   | zero =>
     simp only [List.getElem?_cons_zero,Option.some.injEq] at hn
     subst head
     exact List.mem_append_left _ he
   | succ n => exact List.mem_append_right _ (ih (itemResult c head) n hn he)

theorem indexed_payment_mem (c : CageState) (items : List FoldItem) (folder : Signer)
 (n : Nat) (i : FoldItem) (p : Payment) (hn : items[n]? = some i)
 (hp : p ∈ itemPayments (foldResult c (items.take n)) folder i) :
 p ∈ foldPayments c folder items := by
 induction items generalizing c n with
 | nil => simp at hn
 | cons head rest ih =>
   cases n with
   | zero =>
     simp only [List.getElem?_cons_zero,Option.some.injEq] at hn
     subst head; exact List.mem_append_left _ hp
   | succ n => exact List.mem_append_right _ (ih (itemResult c head) n hn hp)

theorem event_proved (c : CageState) (i : FoldItem) (event : WitnessEvent)
 (h : event ∈ itemWitnessEvents c i) : event.provedEntry = c.tree event.key := by
 unfold itemWitnessEvents at h
 split at h
 · simp at h
 · dsimp only at h
   split at h
   · simp at h
   · have he := List.mem_singleton.mp h
     subst event; rfl

theorem changed_write_tree (c : CageState) (o : RequestOutput) (e : Selection)
 (hc : itemChanges c (.write o e) o.request.write.key) :
 (itemResult c (.write o e)).tree o.request.write.key = writeEntry o.request.write o.request.witnessing o.ref := by
 have hn : ¬ (o.request.witnessing = none ∧ c.trie o.request.write.key = o.request.write.value) := by
   intro h
   apply hc
   change logicalTree (writeTree c o) _ = logicalTree c.tree _
   simp only [writeTree,if_pos h]
 simp [itemResult,writeTree,hn,putEntry]

theorem item_refunds_paid (c : CageState) (iv : Interval) (refs : List TokenName)
 (sigs : List Signer) (i : FoldItem) (folder : Signer) (p : Payment)
 (ha : itemAllowed c iv refs sigs i) (hp : p ∈ itemWitnessRefunds c i) : p ∈ itemPayments c folder i := by
 cases i with
 | write o e => exact List.mem_append_right _ hp
 | account o e => simp [itemWitnessRefunds,itemWitnessEvents,FoldItem.entryKey] at hp
 | claim o => simp [itemWitnessRefunds,itemWitnessEvents,FoldItem.entryKey] at hp
 | extractAccount o => simp [itemWitnessRefunds,itemWitnessEvents,FoldItem.entryKey] at hp
 | extract o =>
   simp only [itemWitnessRefunds,itemWitnessEvents,FoldItem.entryKey,ha.2.2.2.1,Option.map_none] at hp
   split at hp <;> simp at hp

theorem event_refund_paid {iv refs sigs c items out} (run : FoldRun iv refs sigs c items out)
 (folder : Signer) (event : WitnessEvent) (w : WitnessOutput)
 (he : event ∈ foldWitnessEvents c items) (hw : event.consumed = some w) :
 (⟨w.token.data.refund,"",w.value⟩ : Payment) ∈ foldPayments c folder items := by
 induction run with
 | nil => simp [foldWitnessEvents] at he
 | cons c i rest out ha hr ih =>
   rcases List.mem_append.mp he with he | he
   · apply List.mem_append_left
     apply item_refunds_paid c iv refs sigs i folder _ ha
     exact List.mem_filterMap.mpr ⟨event,he,by simp [hw]⟩
   · exact List.mem_append_right _ (ih he)

end RequestApprovalFold.ProofHelpers
