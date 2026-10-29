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

theorem seeds_monotone {s t : State} {a : Action} (h : Step s a t) :
 s.usedSeeds ⊆ t.usedSeeds := by
 cases h <;> try exact fun _ h => h
 exact fun _ h => List.mem_append_right _ h

theorem trace_create_fresh {s t before after : State} {events : List (State × Action × State)}
 (h : Trace s events t) (tx : CreateTx) (o : RequestOutput)
 (hm : (before, Action.create tx o, after) ∈ events) (hn : tx.cageRef.oracles ≠ []) :
 o.request.seed ∉ s.usedSeeds := by
 induction h with
 | nil => simp at hm
 | @cons s mid t a rest hs ht ih =>
   rcases List.mem_cons.mp hm with he | he
   · cases he
     cases hs with
     | create _ _ _ ha hf _ => exact hf _ (ha.1 hn)
   · exact fun hseed => ih he (seeds_monotone hs hseed)

theorem trace_create_unique {s t : State} {events : List (State × Action × State)}
 (h : Trace s events t) (beforeA afterA beforeB afterB : State)
 (a b : CreateTx) (oa ob : RequestOutput)
 (ha : (beforeA, Action.create a oa, afterA) ∈ events)
 (hb : (beforeB, Action.create b ob, afterB) ∈ events)
 (hna : a.cageRef.oracles ≠ []) (hnb : b.cageRef.oracles ≠ [])
 (hne : a ≠ b) : oa.request ≠ ob.request := by
 induction h with
 | nil => simp at ha
 | @cons s mid t action rest hs ht ih =>
   rcases List.mem_cons.mp ha with hahead | hatail
   · rcases List.mem_cons.mp hb with hbhead | hbtail
     · have he := hahead.trans hbhead.symm
       cases he
       exact False.elim (hne rfl)
     · cases hahead
       cases hs with
       | create _ _ _ hc _ _ =>
         intro he
         have hf := trace_create_fresh ht b ob hbtail hnb
         apply hf
         change ob.request.seed ∈ a.spent ++ beforeA.usedSeeds
         rw [← he]
         exact List.mem_append_left _ (hc.1 hna)
   · rcases List.mem_cons.mp hb with hbhead | hbtail
     · cases hbhead
       cases hs with
       | create _ _ _ hc _ _ =>
         intro he
         have hf := trace_create_fresh ht a oa hatail hna
         apply hf
         change oa.request.seed ∈ b.spent ++ beforeB.usedSeeds
         rw [he]
         exact List.mem_append_left _ (hc.1 hnb)
     · exact ih hatail hbtail

theorem consumed_write {c : CageState} {iv refs sigs i event out}
 (ha : itemAllowed c iv refs sigs i) (he : event ∈ itemWitnessEvents c i)
 (hc : event.consumed = some out) :
 ∃ o e w, i = .write o e ∧ event.key = o.request.write.key ∧
 out = witnessOutput c.id o.request.write.key w ∧
 witnessAt c.tree o.request.write.key = some w := by
 cases i with
 | account o e => simp [itemWitnessEvents,FoldItem.entryKey] at he
 | claim o => simp [itemWitnessEvents,FoldItem.entryKey] at he
 | extractAccount o => simp [itemWitnessEvents,FoldItem.entryKey] at he
 | extract o =>
   simp only [itemWitnessEvents,FoldItem.entryKey] at he
   split at he
   · simp at he
   · simp only [List.mem_singleton] at he
     subst event
     simp [ha.2.2.2.1] at hc
 | write o e =>
   simp only [itemWitnessEvents,FoldItem.entryKey] at he
   split at he
   · simp at he
   · simp only [List.mem_singleton] at he
     subst event
     cases hw : witnessAt c.tree o.request.write.key with
     | none => simp [hw] at hc
     | some w =>
       simp only [hw,Option.map_some,Option.some.injEq] at hc
       exact ⟨o,e,w,rfl,rfl,hc.symm,hw⟩

theorem event_index {c : CageState} {items : List FoldItem} {event : WitnessEvent}
 (he : event ∈ foldWitnessEvents c items) :
 ∃ n i, items[n]? = some i ∧ event ∈ itemWitnessEvents (foldResult c (items.take n)) i := by
 induction items generalizing c with
 | nil => simp [foldWitnessEvents] at he
 | cons i rest ih =>
   rcases List.mem_append.mp he with he | he
   · exact ⟨0,i,rfl,he⟩
   · obtain ⟨n,j,hn,hj⟩ := ih he
     exact ⟨n+1,j,hn,hj⟩

theorem run_item {iv refs sigs c items result} (h : FoldRun iv refs sigs c items result)
 (n : Nat) (i : FoldItem) (hn : items[n]? = some i) :
 itemAllowed (foldResult c (items.take n)) iv refs sigs i := by
 induction h generalizing n with
 | nil => simp at hn
 | cons c j rest out ha hr ih =>
   cases n with
   | zero => simp only [List.getElem?_cons_zero,Option.some.injEq] at hn; subst i; exact ha
   | succ n => exact ih n hn

theorem fold_input_consumed (tx : FoldTx) (out : WitnessOutput)
 (ha : foldAccepted tx) (ho : out ∈ tx.witnessInputs) :
 ∃ n o e event, tx.items[n]? = some (.write o e) ∧
 o.request.write.key = out.token.key ∧
 itemChanges (atTurn tx n) (.write o e) out.token.key ∧
 event ∈ itemWitnessEvents (atTurn tx n) (.write o e) ∧
 event.key = out.token.key ∧ event.consumed = some out ∧
 out.token ∈ tx.witnessBurned ∧
 (⟨out.token.data.refund,"",out.token.data.deposit⟩ : Payment) ∈
   itemWitnessRefunds (atTurn tx n) (.write o e) ∧
 (⟨out.token.data.refund,"",out.token.data.deposit⟩ : Payment) ∈ tx.payments := by
 have hb := ha.2.2.2.2.2
 have hm := ho
 rw [hb.2.1] at hm
 obtain ⟨event,he,hcons⟩ := List.mem_filterMap.mp (List.mem_filter.mp hm).1
 rw [hb.1] at he
 obtain ⟨n,i,hn,hi⟩ := event_index he
 have hai := run_item ha.2.2.2.2.1 n i hn
 obtain ⟨o,e,w,heq,hkey,hout,hw⟩ := consumed_write hai hi hcons
 subst i
 have hc := (item_burn_characterization _ _ _ _ _ _ _ hai hw).1.mp
   ⟨event,hi,hkey,hcons.trans (congrArg some hout)⟩
 have hk : o.request.write.key = out.token.key := by rw [hout]; rfl
 have hv : out.value = out.token.data.deposit := by rw [hout]; rfl
 refine ⟨n,o,e,event,hn,hk,hk ▸ hc,hi,hkey.trans hk,hcons,?_,?_,?_⟩
 · rw [hb.2.2.2.1]
   exact List.mem_map.mpr ⟨out,ho,rfl⟩
 · exact List.mem_filterMap.mpr ⟨event,hi,by simp [hcons,hv]⟩
 · rw [ha.2.2.2.1,← hv]
   exact event_refund_paid ha.2.2.2.2.1 tx.folder event out he hcons

theorem produced_custody {c : CageState} {iv refs sigs i event out}
 (ha : itemAllowed c iv refs sigs i) (he : event ∈ itemWitnessEvents c i)
 (hp : event.produced = some out) :
 out.address = registryAddress ∧ out.value = out.token.data.deposit ∧ c.minimum ≤ out.value := by
 cases i with
 | account o e => simp [itemWitnessEvents,FoldItem.entryKey] at he
 | claim o => simp [itemWitnessEvents,FoldItem.entryKey] at he
 | extractAccount o => simp [itemWitnessEvents,FoldItem.entryKey] at he
 | extract o =>
   simp only [itemWitnessEvents,FoldItem.entryKey] at he
   split at he
   · simp at he
   · simp only [List.mem_singleton] at he
     subst event
     simp only [itemResult,putEntry,ite_true,witnessAt,Option.map_some,Option.some.injEq] at hp
     rw [← hp]
     exact ⟨rfl,rfl,ha.1.2.1⟩
 | write o e =>
   have hv := ha.2.1.2.2.2.2.2
   simp only [itemWitnessEvents,FoldItem.entryKey,itemResult] at he
   unfold writeTree at he
   split at he
   · simp at he
   · split at he
     · simp at he
     · simp only [List.mem_singleton] at he
       subst event
       cases hwrite : o.request.write <;> cases hspec : o.request.witnessing
       all_goals simp [itemResult,writeTree,putEntry,witnessAt,writeEntry,hwrite,hspec,Write.key] at hp
       rename_i k v spec
       rw [← hp]
       refine ⟨rfl,rfl,?_⟩
       simp only [Request.witnessValid,hspec] at hv
       exact hv.1

theorem events_custody {iv refs sigs c items result}
 (h : FoldRun iv refs sigs c items result) {event out}
 (he : event ∈ foldWitnessEvents c items) (hp : event.produced = some out) :
 out.address = registryAddress ∧ out.value = out.token.data.deposit ∧ c.minimum ≤ out.value := by
 induction h with
 | nil => simp [foldWitnessEvents] at he
 | cons c i rest result ha hr ih =>
   rcases List.mem_append.mp he with hfirst | hrest
   · exact produced_custody ha hfirst hp
   · simpa only [(item_registry c i).2.2.2.2] using ih hrest

theorem live_custody (s : State) (hr : Reachable s) :
 ∀ out ∈ s.witnesses, out.address = registryAddress ∧
 out.value = out.token.data.deposit ∧ s.cage.minimum ≤ out.value := by
 induction hr with
 | registry c existing hc => simp [initial]
 | @next s t a hr hs ih =>
   intro out ho
   have same := step_registry hs
   cases hs <;> try exact ih out ho
   case fold tx hc hl hcl href ha hex hw =>
     have hm : out ∈ s.witnesses.filter (fun o => o ∉ tx.witnessInputs) ++ tx.witnessOutputs := ho
     rcases List.mem_append.mp hm with hold | hnew
     · have h := ih out (List.mem_filter.mp hold).1
       exact ⟨h.1,h.2.1,same.2.2.2.2 ▸ h.2.2⟩
     · rw [ha.2.2.2.2.2.2.2.1] at hnew
       obtain ⟨event,he,hp⟩ := List.mem_filterMap.mp (List.mem_filter.mp hnew).1
       rw [ha.2.2.2.2.2.1] at he
       have h := events_custody ha.2.2.2.2.1 he hp
       exact ⟨h.1,h.2.1,(same.2.2.2.2.trans (congrArg CageState.minimum hc).symm) ▸ h.2.2⟩

theorem same_token_eq (a b : WitnessOutput)
 (ha : a.address = registryAddress ∧ a.value = a.token.data.deposit)
 (hb : b.address = registryAddress ∧ b.value = b.token.data.deposit)
 (ht : a.token = b.token) : a = b := by
 cases a; cases b; simp_all

theorem run_untouched {iv refs sigs c items result}
 (run : FoldRun iv refs sigs c items result) (k : Key)
 (hn : ∀ o e, FoldItem.write o e ∈ items → o.request.write.key ≠ k) :
 result.trie k = c.trie k := by
 induction run with
 | nil => rfl
 | cons c i rest result ha hr ih =>
   rw [ih (fun o e h => hn o e (List.mem_cons_of_mem _ h))]
   cases i with
   | account o e => rfl
   | claim o => rfl
   | extractAccount o => rfl
   | extract o =>
     by_cases hk : k = o.key
     · subst k
       simpa [itemResult,CageState.trie,logicalTree,putEntry,Entry.logical,Extraction.data] using ha.2.2.2.2.symm
     · simp [itemResult,CageState.trie,logicalTree,putEntry,hk]
   | write o e =>
     rw [write_trie]
     have hk := hn o e (List.mem_cons_self)
     cases hw : o.request.write <;> simp_all [Write.apply,Write.key,ne_comm]

theorem item_keeps_witness {c : CageState} {iv refs sigs i k w}
 (ha : itemAllowed c iv refs sigs i) (hw : witnessAt c.tree k = some w)
 (hn : ¬ itemChanges c i k) : witnessAt (itemResult c i).tree k = some w := by
 cases i with
 | account o e => exact hw
 | claim o => exact hw
 | extractAccount o => exact hw
 | extract o =>
   have hk : k ≠ o.key := by
     intro he
     subst k
     have hnone := ha.2.2.2.1
     rw [hw] at hnone
     contradiction
   simpa [itemResult,witnessAt,putEntry,hk] using hw
 | write o e =>
   by_cases hk : k = o.request.write.key
   · subst k
     have he : c.trie o.request.write.key = o.request.write.value := by
       have hh := hn
       unfold itemChanges at hh
       rw [write_trie] at hh
       cases hwrite : o.request.write <;> simpa [Write.apply,Write.key,Write.value,hwrite] using (Classical.not_not.mp hh).symm
     have hs : o.request.witnessing = none := by
       rcases ha.1 with h | h | h
       · exact h
       · rw [hw] at h; contradiction
       · exact False.elim (h he)
     simpa [itemResult,writeTree,hs,he] using hw
   · change witnessAt (writeTree c o) k = some w
     unfold writeTree
     split
     · exact hw
     · simpa [witnessAt,putEntry,hk] using hw

theorem run_keeps_witness {iv refs sigs c items result}
 (run : FoldRun iv refs sigs c items result) (k : Key) (w : WitnessData)
 (hw : witnessAt c.tree k = some w)
 (hn : ∀ n i, items[n]? = some i → ¬ itemChanges (foldResult c (items.take n)) i k) :
 witnessAt result.tree k = some w := by
 induction run with
 | nil => exact hw
 | cons c i rest result ha hr ih =>
   exact ih (item_keeps_witness ha hw (hn 0 i rfl)) (fun n j hj => hn (n+1) j hj)

theorem nodup_perm {α : Type} [DecidableEq α] {xs ys : List α}
 (hx : xs.Nodup) (hy : ys.Nodup) (hm : ∀ x, x ∈ xs ↔ x ∈ ys) : xs.Perm ys := by
 induction xs generalizing ys with
 | nil =>
   have he : ys = [] := List.eq_nil_iff_forall_not_mem.mpr (fun x h => List.not_mem_nil ((hm x).mpr h))
   subst ys
   exact List.Perm.refl _
 | cons x xs ih =>
   have hx' := List.nodup_cons.mp hx
   apply List.cons_perm_iff_perm_erase.mpr
   refine ⟨(hm x).mp List.mem_cons_self,ih hx'.2 (hy.sublist List.erase_sublist) ?_⟩
   intro y
   rw [hy.mem_erase_iff,← hm y]
   simp only [List.mem_cons]
   constructor
   · intro h
     exact ⟨fun he => hx'.1 (he ▸ h),Or.inr h⟩
   · rintro ⟨hne,he | h⟩
     · exact False.elim (hne he)
     · exact h

theorem live_refs (s : State) : Reachable s →
 (∀ o ∈ s.live, o.ref ∈ s.usedOutputs) ∧ (∀ o ∈ s.claims, o.ref ∈ s.usedOutputs) := by
  intro h
  induction h with
  | registry c ex hc => simp [initial]
  | @next s s' a hr hs ih =>
    constructor
    · intro o ho
      cases hs <;> try exact ih.1 o ho
      case create tx new hc ha hf hf' =>
        rcases List.mem_cons.mp ho with he | he
        · subst o; exact List.mem_cons_self
        · exact List.mem_cons_of_mem _ (ih.1 o he)
      case fold tx _ _ _ _ _ _ _ => exact ih.1 o (List.mem_filter.mp ho).1
      case withdraw tx _ _ => exact ih.1 o (List.mem_filter.mp ho).1
      case claimCreate tx _ _ _ => exact List.mem_cons_of_mem _ (ih.1 o ho)
      case extractionCreate tx _ _ _ => exact List.mem_cons_of_mem _ (ih.1 o ho)
    · intro o ho
      cases hs <;> try exact ih.2 o ho
      case create tx new _ _ _ _ => exact List.mem_cons_of_mem _ (ih.2 o ho)
      case fold tx _ _ _ _ _ _ _ => exact ih.2 o (List.mem_filter.mp ho).1
      case claimCreate tx _ _ _ =>
        rcases List.mem_cons.mp ho with he | he
        · subst o; exact List.mem_cons_self
        · exact List.mem_cons_of_mem _ (ih.2 o he)
      case claimWithdraw tx _ _ => exact ih.2 o (List.mem_of_mem_erase ho)
      case extractionCreate tx _ _ _ => exact List.mem_cons_of_mem _ (ih.2 o ho)

theorem pending_refs_unique (s : State) : Reachable s →
 (s.live.map RequestOutput.ref ++ s.claims.map ClaimOutput.ref ++ s.extractions.map Extraction.ref).Nodup ∧
 (∀ o ∈ s.extractions, o.ref ∈ s.usedOutputs) := by
 intro h
 refine ⟨?_,extraction_refs s h⟩
 induction h with
 | registry c ex hc => simp [initial]
 | @next s s' a hr hs ih =>
   have hm := live_refs s hr
   have he := extraction_refs s hr
   have bound : ∀ ref ∈ s.live.map RequestOutput.ref ++ s.claims.map ClaimOutput.ref ++ s.extractions.map Extraction.ref, ref ∈ s.usedOutputs := by
     intro ref hh
     rcases List.mem_append.mp hh with hh | hh
     · rcases List.mem_append.mp hh with hh | hh
       · obtain ⟨o,ho,rfl⟩ := List.mem_map.mp hh; exact hm.1 o ho
       · obtain ⟨o,ho,rfl⟩ := List.mem_map.mp hh; exact hm.2 o ho
     · obtain ⟨o,ho,rfl⟩ := List.mem_map.mp hh; exact he o ho
   cases hs <;> try exact ih
   case create tx o hc ha hf hu =>
     exact List.nodup_cons.mpr ⟨fun hh => hu (bound _ hh),ih⟩
   case claimCreate tx hc ha hf =>
     have hn := List.nodup_cons.mpr ⟨fun hh => hf (bound _ hh),ih⟩
     have hn' : (tx.output.ref :: (s.live.map RequestOutput.ref ++ (s.claims.map ClaimOutput.ref ++ s.extractions.map Extraction.ref))).Nodup := by simpa only [List.append_assoc] using hn
     simpa only [afterClaimCreate,List.map_cons,List.append_assoc,List.cons_append] using hn'.perm (List.perm_middle (l₁ := s.live.map RequestOutput.ref) (l₂ := s.claims.map ClaimOutput.ref ++ s.extractions.map Extraction.ref)).symm
   case extractionCreate tx hc ha hf =>
     have hn := List.nodup_cons.mpr ⟨fun hh => hf (bound _ hh),ih⟩
     exact hn.perm List.perm_middle.symm
   case fold tx hc hl hcl href ha hex hw =>
     exact ih.sublist (((List.filter_sublist.map _).append (List.filter_sublist.map _)).append (List.filter_sublist.map _))
   case withdraw tx hl ha =>
     exact ih.sublist (((List.filter_sublist.map _).append (List.Sublist.refl _)).append (List.Sublist.refl _))
   case claimWithdraw tx hl ha =>
     exact ih.sublist (((List.Sublist.refl _).append (List.erase_sublist.map _)).append (List.Sublist.refl _))
   case extractionWithdraw tx hl ha =>
     exact ih.sublist ((List.Sublist.refl _).append (List.erase_sublist.map _))

theorem nodup_map_injective {α β : Type} {f : α → β} {xs : List α}
 (hn : (xs.map f).Nodup) {a b : α} (ha : a ∈ xs) (hb : b ∈ xs)
 (he : f a = f b) : a = b := by
 induction xs with
 | nil => simp at ha
 | cons x xs ih =>
   have hn' := List.nodup_cons.mp hn
   rcases List.mem_cons.mp ha with ha | ha
   · rcases List.mem_cons.mp hb with hb | hb
     · exact ha.trans hb.symm
     · subst a
       exact False.elim (hn'.1 (List.mem_map.mpr ⟨b,hb,he.symm⟩))
   · rcases List.mem_cons.mp hb with hb | hb
     · subst b
       exact False.elim (hn'.1 (List.mem_map.mpr ⟨a,ha,he⟩))
     · exact ih hn'.2 ha hb

theorem produced_source {c : CageState} {i : FoldItem} {event : WitnessEvent} {out : WitnessOutput}
 (he : event ∈ itemWitnessEvents c i) (hp : event.produced = some out) :
 (∃ o e, i = .write o e ∧ out.token.data.issuance = o.ref) ∨
 (∃ o, i = .extract o ∧ out.token.data.issuance = o.ref) := by
 cases i with
 | account o e => simp [itemWitnessEvents,FoldItem.entryKey] at he
 | claim o => simp [itemWitnessEvents,FoldItem.entryKey] at he
 | extractAccount o => simp [itemWitnessEvents,FoldItem.entryKey] at he
 | extract o =>
   simp only [itemWitnessEvents,FoldItem.entryKey] at he
   split at he
   · simp at he
   · simp only [List.mem_singleton] at he
     subst event
     simp only [itemResult,putEntry,ite_true,witnessAt,Option.map_some,Option.some.injEq] at hp
     exact Or.inr ⟨o,rfl,hp ▸ rfl⟩
 | write o e =>
   simp only [itemWitnessEvents,FoldItem.entryKey,itemResult] at he
   unfold writeTree at he
   split at he
   · simp at he
   · split at he
     · simp at he
     · simp only [List.mem_singleton] at he
       subst event
       cases hwrite : o.request.write <;> cases hspec : o.request.witnessing
       all_goals simp [putEntry,witnessAt,writeEntry,hwrite,hspec,Write.key] at hp
       exact Or.inl ⟨o,e,rfl,hp ▸ rfl⟩

theorem fold_produced_source (tx : FoldTx) (out : WitnessOutput)
 (ha : foldAccepted tx) (ho : out ∈ tx.witnessOutputs) :
 (∃ o ∈ tx.requests, out.token.data.issuance = o.ref) ∨
 (∃ o ∈ tx.extractions, out.token.data.issuance = o.ref) := by
 rw [ha.2.2.2.2.2.2.2.1] at ho
 obtain ⟨event,he,hp⟩ := List.mem_filterMap.mp (List.mem_filter.mp ho).1
 rw [ha.2.2.2.2.2.1] at he
 obtain ⟨n,i,hn,hi⟩ := event_index he
 rcases produced_source hi hp with ⟨o,e,rfl,href⟩ | ⟨o,rfl,href⟩
 · exact Or.inl ⟨o,List.mem_filterMap.mpr ⟨.write o e,List.mem_of_getElem? hn,rfl⟩,href⟩
 · exact Or.inr ⟨o,List.mem_filterMap.mpr ⟨.extract o,List.mem_of_getElem? hn,rfl⟩,href⟩

def RetiredRef (s : State) (ref : OutputRef) : Prop :=
 ref ∈ s.usedOutputs ∧ (∀ o ∈ s.live, ref ≠ o.ref) ∧ (∀ o ∈ s.extractions, ref ≠ o.ref)

theorem retired_step {s t : State} {a : Action} {ref : OutputRef}
 (hs : Step s a t) (hr : RetiredRef s ref) : RetiredRef t ref := by
 refine ⟨?_,?_,?_⟩
 · cases hs <;> first | exact hr.1 | exact List.mem_cons_of_mem _ hr.1
 · intro o ho
   cases hs <;> try exact hr.2.1 o ho
   case create tx new hc ha hf hu =>
     rcases List.mem_cons.mp ho with he | he
     · subst o; intro he; exact hu (he ▸ hr.1)
     · exact hr.2.1 o he
   case fold tx hc hl hcl href ha hex hw => exact hr.2.1 o (List.mem_filter.mp ho).1
   case withdraw tx hl ha => exact hr.2.1 o (List.mem_filter.mp ho).1
 · intro o ho
   cases hs <;> try exact hr.2.2 o ho
   case extractionCreate tx hc ha hu =>
     rcases List.mem_cons.mp ho with he | he
     · subst o; intro he; exact hu (he ▸ hr.1)
     · exact hr.2.2 o he
   case fold tx hc hl hcl href ha hex hw => exact hr.2.2 o (List.mem_filter.mp ho).1
   case extractionWithdraw tx hl ha => exact hr.2.2 o (List.mem_of_mem_erase ho)

theorem folded_ref_retired (s : State) (tx : FoldTx) (ref : OutputRef)
 (hr : Reachable s) (hl : ∀ o ∈ tx.requests, o ∈ s.live)
 (hex : ∀ o ∈ tx.extractions, o ∈ s.extractions)
 (hsource : (∃ o ∈ tx.requests, ref = o.ref) ∨ (∃ o ∈ tx.extractions, ref = o.ref)) :
 RetiredRef (afterFold s tx) ref := by
 have hn := (pending_refs_unique s hr).1
 have hn' := List.nodup_append.mp hn
 have hnl := (List.nodup_append.mp hn'.1).1
 have hne := hn'.2.1
 have cross (o : RequestOutput) (ho : o ∈ s.live) (x : Extraction) (hx : x ∈ s.extractions) : o.ref ≠ x.ref :=
   hn'.2.2 o.ref (List.mem_append_left _ (List.mem_map.mpr ⟨o,ho,rfl⟩))
     x.ref (List.mem_map.mpr ⟨x,hx,rfl⟩)
 rcases hsource with ⟨o,ho,rfl⟩ | ⟨o,ho,rfl⟩
 · refine ⟨(live_refs s hr).1 o (hl o ho),?_,?_⟩
   · intro x hx he
     have hx' := List.mem_filter.mp hx
     have eq := nodup_map_injective hnl (hl o ho) hx'.1 he
     have hnot : x ∉ tx.requests := by simpa using hx'.2
     exact hnot (eq ▸ ho)
   · intro x hx
     exact cross o (hl o ho) x (List.mem_filter.mp hx).1
 · refine ⟨extraction_refs s hr o (hex o ho),?_,?_⟩
   · intro x hx he
     exact cross x (List.mem_filter.mp hx).1 o (hex o ho) he.symm
   · intro x hx he
     have hx' := List.mem_filter.mp hx
     have eq := nodup_map_injective hne (hex o ho) hx'.1 he
     have hnot : x ∉ tx.extractions := by simpa using hx'.2
     exact hnot (eq ▸ ho)

theorem live_witness_retired (s : State) (hr : Reachable s) :
 ∀ out ∈ s.witnesses, RetiredRef s out.token.data.issuance := by
 induction hr with
 | registry c existing hc => simp [initial]
 | @next s t a hr hs ih =>
   intro out ho
   have old (hm : out ∈ s.witnesses) := retired_step hs (ih out hm)
   cases hs <;> try exact old ho
   case fold tx hc hl hcl href ha hex hw =>
     rcases List.mem_append.mp ho with hold | hnew
     · exact old (List.mem_filter.mp hold).1
     · exact folded_ref_retired s tx out.token.data.issuance hr hl hex
         (fold_produced_source tx out ha hnew)

theorem fold_no_reproduction (s : State) (tx : FoldTx) (out : WitnessOutput)
 (hr : Reachable s) (ho : out ∈ s.witnesses)
 (hl : ∀ o ∈ tx.requests, o ∈ s.live) (hex : ∀ o ∈ tx.extractions, o ∈ s.extractions)
 (he : WitnessEvent) (hm : he ∈ foldWitnessEvents tx.cageIn tx.items) :
 he.produced ≠ some out := by
 intro hp
 have hret := live_witness_retired s hr out ho
 obtain ⟨n,i,hn,hi⟩ := event_index hm
 rcases produced_source hi hp with ⟨o,e,rfl,href⟩ | ⟨o,rfl,href⟩
 · exact hret.2.1 o (hl o (List.mem_filterMap.mpr ⟨.write o e,List.mem_of_getElem? hn,rfl⟩)) href
 · exact hret.2.2 o (hex o (List.mem_filterMap.mpr ⟨.extract o,List.mem_of_getElem? hn,rfl⟩)) href

theorem run_keeps_unconsumed {iv refs sigs c items result}
 (run : FoldRun iv refs sigs c items result) (k : Key) (w : WitnessData)
 (hw : witnessAt c.tree k = some w)
 (hn : ∀ event ∈ foldWitnessEvents c items, event.consumed ≠ some (witnessOutput c.id k w)) :
 witnessAt result.tree k = some w := by
 induction run with
 | nil => exact hw
 | cons c i rest result ha hr ih =>
   have hchange : ¬ itemChanges c i k := by
     intro hc
     obtain ⟨event,he,hkey,hcons⟩ := (item_burn_characterization _ _ _ _ _ _ _ ha hw).1.mpr hc
     exact hn event (List.mem_append_left _ he) hcons
   apply ih (item_keeps_witness ha hw hchange)
   intro event he
   simpa only [(item_registry c i).1] using hn event (List.mem_append_right _ he)

theorem consumed_on_change {iv refs sigs c items result}
 (run : FoldRun iv refs sigs c items result) (k : Key) (w : WitnessData)
 (hw : witnessAt c.tree k = some w) (n : Nat) (i : FoldItem)
 (hi : items[n]? = some i) (hc : itemChanges (foldResult c (items.take n)) i k) :
 ∃ event ∈ foldWitnessEvents c items, event.consumed = some (witnessOutput c.id k w) := by
 apply Classical.byContradiction
 intro hn
 have hnone : ∀ event ∈ foldWitnessEvents c items,
     event.consumed ≠ some (witnessOutput c.id k w) := by
   intro event he hcons
   exact hn ⟨event,he,hcons⟩
 have hpref : ∀ event ∈ foldWitnessEvents c (items.take n),
     event.consumed ≠ some (witnessOutput c.id k w) := by
   intro event he
   obtain ⟨m,j,hm,hj⟩ := event_index he
   have hlt : m < (items.take n).length := List.getElem?_eq_some_iff.mp hm |>.1
   have hmn : m < n := by simp only [List.length_take] at hlt; omega
   have hfull : items[m]? = some j := by simpa [List.getElem?_take,hmn] using hm
   have htake : (items.take n).take m = items.take m := by rw [List.take_take,Nat.min_eq_left (by omega)]
   rw [htake] at hj
   exact hnone event (indexed_event_mem c items m j event hfull hj)
 have hw' := run_keeps_unconsumed (run_take run n) k w hw hpref
 obtain ⟨event,he,hkey,hcons⟩ := (item_burn_characterization _ _ _ _ _ _ _ (run_item run n i hi) hw').1.mpr hc
 apply hnone event (indexed_event_mem c items n i event hi he)
 simpa only [(result_registry c (items.take n)).1] using hcons

def Inventory (c : CageState) (ws : List WitnessOutput) : Prop :=
 WitnessBacked { initial c with witnesses := ws }

theorem inventory_iff (c : CageState) (ws : List WitnessOutput) :
 Inventory c ws ↔ ws.Nodup ∧ ∀ out, out ∈ ws ↔
 out = witnessOutput c.id out.token.key out.token.data ∧
 witnessAt c.tree out.token.key = some out.token.data := by
 constructor
 · intro h
   refine ⟨h.1,?_⟩
   intro out
   constructor
   · intro ho
     have he := h.2.2 out ho
     exact ⟨he,(h.2.1 _ _).mpr (he ▸ ho)⟩
   · rintro ⟨he,hw⟩
     exact he ▸ (h.2.1 _ _).mp hw
 · rintro ⟨hn,h⟩
   refine ⟨hn,?_,?_⟩
   · intro k w
     constructor
     · intro hw
       exact (h _).mpr ⟨rfl,hw⟩
     · intro ho
       exact ((h _).mp ho).2
   · intro out ho
     exact ((h out).mp ho).1

theorem inventory_update (c d : CageState) (ws : List WitnessOutput) (k : Key)
 (next : Option WitnessData) (hb : Inventory c ws) (hid : d.id = c.id)
 (ht : ∀ q, witnessAt d.tree q = if q = k then next else witnessAt c.tree q) :
 Inventory d (ws.filter (fun out => out.token.key != k) ++
   (next.map (witnessOutput c.id k)).toList) := by
 have hb' := (inventory_iff c ws).mp hb
 apply (inventory_iff _ _).mpr
 constructor
 · apply List.nodup_append.mpr
   refine ⟨hb'.1.filter _,?_,?_⟩
   · cases next <;> simp
   · intro a ha b hb he
     have hne : a.token.key ≠ k := by simpa using (List.mem_filter.mp ha).2
     cases hnext : next with
     | none => simp [hnext] at hb
     | some w =>
       simp only [hnext,Option.map_some,Option.toList_some,List.mem_singleton] at hb
       rw [hb] at he
       exact hne (congrArg (fun x : WitnessOutput => x.token.key) he)
 · intro out
   constructor
   · intro ho
     rcases List.mem_append.mp ho with hold | hnew
     · have ho := (List.mem_filter.mp hold).1
       have hk : out.token.key ≠ k := by simpa using (List.mem_filter.mp hold).2
       have hc := (hb'.2 out).mp ho
       exact ⟨hid ▸ hc.1,by rw [ht,if_neg hk]; exact hc.2⟩
     · cases hnext : next with
       | none => simp [hnext] at hnew
       | some w =>
         simp only [hnext,Option.map_some,Option.toList_some,List.mem_singleton] at hnew
         subst out
         refine ⟨?_,?_⟩
         · simp [witnessOutput,hid]
         · change witnessAt d.tree k = some w
           rw [ht,if_pos rfl,hnext]
   · rintro ⟨hc,hw⟩
     by_cases hk : out.token.key = k
     · apply List.mem_append_right
       have hn : next = some out.token.data := by simpa [ht,hk] using hw
       rw [hn]
       simp only [Option.map_some,Option.toList_some,List.mem_singleton]
       simpa only [hid,hk] using hc
     · apply List.mem_append_left
       apply List.mem_filter.mpr
       refine ⟨(hb'.2 out).mpr ⟨?_,?_⟩,by simpa using hk⟩
       · simpa only [hid] using hc
       · simpa only [ht,if_neg hk] using hw


def applyEvent (ws : List WitnessOutput) (event : WitnessEvent) : List WitnessOutput :=
 ws.filter (fun out => decide (some out ≠ event.consumed)) ++ event.produced.toList

def applyEvents (ws : List WitnessOutput) : List WitnessEvent → List WitnessOutput
 | [] => ws
 | event :: events => applyEvents (applyEvent ws event) events

theorem item_other_witness (c : CageState) (i : FoldItem) (q : Key)
 (h : i.entryKey ≠ some q) : witnessAt (itemResult c i).tree q = witnessAt c.tree q := by
 cases i with
 | write o e =>
   have hk : q ≠ o.request.write.key := by simpa [FoldItem.entryKey,ne_comm] using h
   change witnessAt (writeTree c o) q = _
   unfold writeTree
   split
   · rfl
   · simp [witnessAt,putEntry,hk]
 | extract o =>
   have hk : q ≠ o.key := by simpa [FoldItem.entryKey,ne_comm] using h
   simp [itemResult,witnessAt,putEntry,hk]
 | account o e => rfl
 | claim o => rfl
 | extractAccount o => rfl

theorem inventory_same (c d : CageState) (ws : List WitnessOutput)
 (hb : Inventory c ws) (hid : d.id = c.id)
 (ht : ∀ k, witnessAt d.tree k = witnessAt c.tree k) : Inventory d ws := by
 rw [inventory_iff] at *
 simpa only [hid,ht] using hb

theorem inventory_old (c : CageState) (ws : List WitnessOutput) (k : Key)
 (hb : Inventory c ws) (out : WitnessOutput) (ho : out ∈ ws) :
 (some out = (witnessAt c.tree k).map (witnessOutput c.id k)) ↔ out.token.key = k := by
 have hc := ((inventory_iff c ws).mp hb).2 out |>.mp ho
 constructor
 · intro he
   cases hw : witnessAt c.tree k with
   | none => simp [hw] at he
   | some w =>
     simp only [hw,Option.map_some,Option.some.injEq] at he
     exact congrArg (fun out : WitnessOutput => out.token.key) he
 · intro hk
   rw [← hk,hc.2]
   exact congrArg some hc.1

theorem item_inventory (c : CageState) (i : FoldItem) (ws : List WitnessOutput)
 (hb : Inventory c ws) : Inventory (itemResult c i) (applyEvents ws (itemWitnessEvents c i)) := by
 have hid := (item_registry c i).1
 cases hkey : i.entryKey with
 | none =>
   simp only [itemWitnessEvents,hkey,applyEvents]
   exact inventory_same c _ ws hb hid (fun q => item_other_witness c i q (by simp [hkey]))
 | some k =>
   have hother (q : Key) (hq : q ≠ k) := item_other_witness c i q (by simp [hkey,Ne.symm hq])
   simp only [itemWitnessEvents,hkey]
   split
   · rename_i he
     simp only [applyEvents]
     apply inventory_same c _ ws hb hid
     intro q
     by_cases hq : q = k
     · subst q
       have hh := congrArg (Option.map (fun out : WitnessOutput => out.token.data)) he
       simpa [Option.map_map,witnessOutput,Function.comp_def] using hh.symm
     · exact hother q hq
   · simp only [applyEvents,applyEvent]
     have hf : ws.filter (fun out => decide (some out ≠ (witnessAt c.tree k).map (witnessOutput c.id k))) =
         ws.filter (fun out => out.token.key != k) := by
       apply List.filter_congr
       intro out ho
       apply Bool.eq_iff_iff.mpr
       simp only [bne_iff_ne,decide_eq_true_eq]
       exact not_congr (inventory_old c ws k hb out ho)
     rw [hf]
     apply inventory_update c (itemResult c i) ws k (witnessAt (itemResult c i).tree k) hb hid
     intro q
     by_cases hq : q = k
     · simp [hq]
     · simp [hq,hother q hq]


theorem applyEvents_append (ws : List WitnessOutput) (xs ys : List WitnessEvent) :
 applyEvents ws (xs ++ ys) = applyEvents (applyEvents ws xs) ys := by
 induction xs generalizing ws with
 | nil => rfl
 | cons event rest ih => exact ih (applyEvent ws event)

theorem run_inventory {iv refs sigs c items result} (run : FoldRun iv refs sigs c items result)
 (ws : List WitnessOutput) (hb : Inventory c ws) :
 Inventory result (applyEvents ws (foldWitnessEvents c items)) := by
 induction run generalizing ws with
 | nil => exact hb
 | cons c i rest result ha hr ih =>
   rw [foldWitnessEvents,applyEvents_append]
   exact ih _ (item_inventory c i ws hb)

def EventsLive (ws : List WitnessOutput) : List WitnessEvent → Prop
 | [] => True
 | event :: events => (∀ out, event.consumed = some out → out ∈ ws) ∧ EventsLive (applyEvent ws event) events

theorem eventsLive_append (ws : List WitnessOutput) (xs ys : List WitnessEvent) :
 EventsLive ws (xs ++ ys) ↔ EventsLive ws xs ∧ EventsLive (applyEvents ws xs) ys := by
 induction xs generalizing ws with
 | nil => simp [EventsLive,applyEvents]
 | cons event rest ih => simp only [List.cons_append,EventsLive,applyEvents,ih,and_assoc]

theorem item_events_live {c : CageState} {iv refs sigs i} (ha : itemAllowed c iv refs sigs i)
 (ws : List WitnessOutput) (hb : Inventory c ws) : EventsLive ws (itemWitnessEvents c i) := by
 have hc (event : WitnessEvent) (he : event ∈ itemWitnessEvents c i) (out : WitnessOutput)
     (hcons : event.consumed = some out) : out ∈ ws := by
   obtain ⟨o,e,w,hi,hkey,heq,hw⟩ := consumed_write ha he hcons
   rw [heq]
   exact (hb.2.1 _ _).mp hw
 unfold itemWitnessEvents
 split
 · trivial
 · dsimp only
   split
   · trivial
   · exact ⟨fun out h => hc _ (by simp [itemWitnessEvents, *]) out h,True.intro⟩

theorem run_events_live {iv refs sigs c items result} (run : FoldRun iv refs sigs c items result)
 (ws : List WitnessOutput) (hb : Inventory c ws) : EventsLive ws (foldWitnessEvents c items) := by
 induction run generalizing ws with
 | nil => trivial
 | cons c i rest result ha hr ih =>
   rw [foldWitnessEvents,eventsLive_append]
   exact ⟨item_events_live ha ws hb,ih _ (item_inventory c i ws hb)⟩

def itemRef : FoldItem → OutputRef
 | .write o _ | .account o _ => o.ref
 | .claim o => o.ref
 | .extract o | .extractAccount o => o.ref

theorem item_refs_perm (items : List FoldItem) : (items.map itemRef).Perm
 (((items.filterMap FoldItem.request).map RequestOutput.ref ++
 (items.filterMap FoldItem.claimInput).map ClaimOutput.ref) ++
 (items.filterMap FoldItem.extraction).map Extraction.ref) := by
 induction items with
 | nil => exact List.Perm.refl _
 | cons i rest ih =>
   cases i <;> simp only [List.map_cons,List.filterMap_cons,FoldItem.request,FoldItem.claimInput,
     FoldItem.extraction,itemRef,List.cons_append,List.map_cons]
   · exact ih.cons _
   · exact ih.cons _
   · exact (ih.cons _).trans (by simpa only [List.append_assoc] using List.perm_middle.symm)
   · exact (ih.cons _).trans List.perm_middle.symm
   · exact (ih.cons _).trans List.perm_middle.symm

theorem produced_item_ref {c : CageState} {i : FoldItem} {out : WitnessOutput}
 (ho : out ∈ (itemWitnessEvents c i).filterMap WitnessEvent.produced) : out.token.data.issuance = itemRef i := by
 obtain ⟨event,he,hp⟩ := List.mem_filterMap.mp ho
 rcases produced_source he hp with ⟨o,e,rfl,h⟩ | ⟨o,rfl,h⟩ <;> exact h

theorem produced_ref_member {c : CageState} {items : List FoldItem} {out : WitnessOutput}
 (ho : out ∈ (foldWitnessEvents c items).filterMap WitnessEvent.produced) :
 out.token.data.issuance ∈ items.map itemRef := by
 obtain ⟨event,he,hp⟩ := List.mem_filterMap.mp ho
 obtain ⟨n,i,hn,hi⟩ := event_index he
 exact List.mem_map.mpr ⟨i,List.mem_of_getElem? hn,
   (produced_item_ref (List.mem_filterMap.mpr ⟨event,hi,hp⟩)).symm⟩

theorem produced_nodup (c : CageState) (items : List FoldItem)
 (hn : (items.map itemRef).Nodup) :
 ((foldWitnessEvents c items).filterMap WitnessEvent.produced).Nodup := by
 induction items generalizing c with
 | nil => simp [foldWitnessEvents]
 | cons i rest ih =>
   have hn' := List.nodup_cons.mp hn
   rw [foldWitnessEvents,List.filterMap_append]
   apply List.nodup_append.mpr
   refine ⟨?_,ih _ hn'.2,?_⟩
   · unfold itemWitnessEvents
     split
     · simp
     · dsimp only
       split
       · simp
       · simp only [List.filterMap_cons,List.filterMap_nil]
         split <;> simp
   · intro a ha b hb he
     have href := produced_item_ref ha
     have hm := produced_ref_member hb
     rw [← he,href] at hm
     exact hn'.1 hm

theorem filter_true {α : Type} (xs : List α) : xs.filter (fun _ => true) = xs :=
 List.filter_eq_self.mpr (by simp)

theorem events_net (ws : List WitnessOutput) (events : List WitnessEvent)
 (hl : EventsLive ws events)
 (hp : (events.filterMap WitnessEvent.produced).Nodup)
 (hf : ∀ out ∈ ws, out ∉ events.filterMap WitnessEvent.produced) :
 applyEvents ws events = ws.filter (fun out => out ∉ events.filterMap WitnessEvent.consumed) ++
   (events.filterMap WitnessEvent.produced).filter (fun out => out ∉ events.filterMap WitnessEvent.consumed) := by
 induction events generalizing ws with
 | nil => simp [applyEvents,filter_true]
 | cons event rest ih =>
   have hp' : (rest.filterMap WitnessEvent.produced).Nodup := by
     cases h : event.produced with
     | none => simpa only [List.filterMap_cons,h] using hp
     | some fresh =>
       simp only [List.filterMap_cons,h] at hp
       exact (List.nodup_cons.mp hp).2
   have hf' : ∀ out ∈ applyEvent ws event, out ∉ rest.filterMap WitnessEvent.produced := by
     intro out ho
     rcases List.mem_append.mp ho with hold | hnew
     · intro hm
       exact hf out (List.mem_filter.mp hold).1 (by cases h : event.produced <;> simp [List.filterMap_cons,h,hm])
     · cases h : event.produced with
       | none => simp [h] at hnew
       | some fresh =>
         simp only [h,Option.toList_some,List.mem_singleton] at hnew
         subst out
         simp only [List.filterMap_cons,h] at hp
         exact (List.nodup_cons.mp hp).1
   rw [applyEvents,ih _ hl.2 hp' hf']
   cases hc : event.consumed with
   | none =>
     cases hp0 : event.produced <;>
       simp [applyEvent,hc,hp0,List.filterMap_cons,List.filter_append,List.append_assoc,filter_true]
     all_goals rw [← List.filter_append] <;> rfl
   | some old =>
     have hno := hf old (hl.1 old hc)
     have hfilter : ((event :: rest).filterMap WitnessEvent.produced).filter
         (fun out => out ∉ old :: rest.filterMap WitnessEvent.consumed) =
         ((event :: rest).filterMap WitnessEvent.produced).filter
         (fun out => out ∉ rest.filterMap WitnessEvent.consumed) := by
       apply List.filter_congr
       intro out ho
       have he : out ≠ old := by intro he; exact hno (he ▸ ho)
       simp [he]
     simp only [List.filterMap_cons,hc] at hfilter ⊢
     rw [hfilter]
     cases hp0 : event.produced <;>
       simp [applyEvent,hc,hp0,List.filter_append,List.filter_filter,List.append_assoc,
         Bool.and_comm, Bool.and_assoc,filter_true]
     all_goals rw [← List.filter_append] <;> rfl

theorem events_boundary (ws : List WitnessOutput) (events : List WitnessEvent)
 (hl : EventsLive ws events)
 (hp : (events.filterMap WitnessEvent.produced).Nodup)
 (hf : ∀ out ∈ ws, out ∉ events.filterMap WitnessEvent.produced) :
 applyEvents ws events = ws.filter (fun out => out ∉ externalWitnessInputs events) ++
   externalWitnessOutputs events := by
 rw [events_net ws events hl hp hf]
 apply congrArg (fun xs => xs ++ externalWitnessOutputs events)
 apply List.filter_congr
 intro out ho
 apply Bool.eq_iff_iff.mpr
 simp only [decide_eq_true_eq,externalWitnessInputs,List.mem_filter,decide_eq_true_eq]
 simp only [hf out ho,not_false_eq_true,and_true]

theorem fold_inventory (s : State) (tx : FoldTx)
 (hr : Reachable s) (hb : WitnessBacked s)
 (hc : tx.cageIn = s.cage) (hl : ∀ o ∈ tx.requests, o ∈ s.live)
 (hex : ∀ o ∈ tx.extractions, o ∈ s.extractions) (ha : foldAccepted tx) :
 WitnessBacked (afterFold s tx) := by
 have hstart : Inventory tx.cageIn s.witnesses := hc ▸ hb
 have hrun := run_inventory ha.2.2.2.2.1 s.witnesses hstart
 have hlive := run_events_live ha.2.2.2.2.1 s.witnesses hstart
 have hnodup := produced_nodup tx.cageIn tx.items
   ((item_refs_perm tx.items).symm.nodup ha.2.1)
 have hf : ∀ out ∈ s.witnesses, out ∉ (foldWitnessEvents tx.cageIn tx.items).filterMap WitnessEvent.produced := by
   intro out ho hm
   obtain ⟨event,he,hp⟩ := List.mem_filterMap.mp hm
   exact fold_no_reproduction s tx out hr ho hl hex event he hp
 rw [events_boundary s.witnesses _ hlive hnodup hf] at hrun
 change Inventory tx.cageOut (s.witnesses.filter (fun out => out ∉ tx.witnessInputs) ++ tx.witnessOutputs)
 rw [ha.2.2.2.2.2.2.1,ha.2.2.2.2.2.2.2.1,ha.2.2.2.2.2.1]
 exact hrun

theorem reachable_inventory (s : State) (hr : Reachable s) : WitnessBacked s := by
 induction hr with
 | registry c existing hc =>
   refine ⟨by simp [initial],?_,by simp [initial]⟩
   intro k w
   simp [initial,hc.2.2.1,witnessAt,emptyEntries]
 | @next s t a hr hs ih =>
   cases hs <;> try exact ih
   case fold tx hc hl hcl href ha hex hw => exact fold_inventory s tx hr ih hc hl hex ha


theorem consumed_member (ws : List WitnessOutput) (events : List WitnessEvent)
 (hl : EventsLive ws events) (out : WitnessOutput)
 (ho : out ∈ events.filterMap WitnessEvent.consumed) :
 out ∈ ws ∨ out ∈ events.filterMap WitnessEvent.produced := by
 induction events generalizing ws with
 | nil => simp at ho
 | cons event rest ih =>
   obtain ⟨ev,he,hcons⟩ := List.mem_filterMap.mp ho
   rcases List.mem_cons.mp he with he | he
   · subst ev; exact Or.inl (hl.1 out hcons)
   · rcases ih _ hl.2 (List.mem_filterMap.mpr ⟨ev,he,hcons⟩) with hcur | hprod
     · rcases List.mem_append.mp hcur with hold | hnew
       · exact Or.inl (List.mem_filter.mp hold).1
       · apply Or.inr
         exact List.mem_filterMap.mpr ⟨event,List.mem_cons_self,Option.mem_toList.mp hnew⟩
     · apply Or.inr
       obtain ⟨ev,he,hp⟩ := List.mem_filterMap.mp hprod
       exact List.mem_filterMap.mpr ⟨ev,List.mem_cons_of_mem _ he,hp⟩

theorem events_tail_fresh (ws : List WitnessOutput) (event : WitnessEvent) (rest : List WitnessEvent)
 (hp : ((event :: rest).filterMap WitnessEvent.produced).Nodup)
 (hf : ∀ out ∈ ws, out ∉ (event :: rest).filterMap WitnessEvent.produced) :
 (rest.filterMap WitnessEvent.produced).Nodup ∧
 (∀ out ∈ applyEvent ws event, out ∉ rest.filterMap WitnessEvent.produced) := by
 constructor
 · cases h : event.produced with
   | none => simpa only [List.filterMap_cons,h] using hp
   | some fresh =>
     simp only [List.filterMap_cons,h] at hp
     exact (List.nodup_cons.mp hp).2
 · intro out ho
   rcases List.mem_append.mp ho with hold | hnew
   · intro hm
     exact hf out (List.mem_filter.mp hold).1 (by cases h : event.produced <;> simp [List.filterMap_cons,h,hm])
   · cases h : event.produced with
     | none => simp [h] at hnew
     | some fresh =>
       simp only [h,Option.toList_some,List.mem_singleton] at hnew
       subst out
       simp only [List.filterMap_cons,h] at hp
       exact (List.nodup_cons.mp hp).1

theorem consumed_nodup (ws : List WitnessOutput) (events : List WitnessEvent)
 (hl : EventsLive ws events)
 (hp : (events.filterMap WitnessEvent.produced).Nodup)
 (hf : ∀ out ∈ ws, out ∉ events.filterMap WitnessEvent.produced) :
 (events.filterMap WitnessEvent.consumed).Nodup := by
 induction events generalizing ws with
 | nil => simp
 | cons event rest ih =>
   have ht := events_tail_fresh ws event rest hp hf
   have hi := ih _ hl.2 ht.1 ht.2
   cases hc : event.consumed with
   | none => simpa only [List.filterMap_cons,hc] using hi
   | some old =>
     simp only [List.filterMap_cons,hc]
     apply List.nodup_cons.mpr
     refine ⟨?_,hi⟩
     intro hm
     have hno := hf old (hl.1 old hc)
     rcases consumed_member _ rest hl.2 old hm with hcur | hprod
     · rcases List.mem_append.mp hcur with hold | hnew
       · simpa [hc] using (List.mem_filter.mp hold).2
       · exact hno (List.mem_filterMap.mpr ⟨event,List.mem_cons_self,Option.mem_toList.mp hnew⟩)
     · obtain ⟨ev,he,hp⟩ := List.mem_filterMap.mp hprod
       exact hno (List.mem_filterMap.mpr ⟨ev,List.mem_cons_of_mem _ he,hp⟩)

theorem value_split (xs ys : List WitnessOutput) : witnessValue xs =
 witnessValue (xs.filter (fun out => out ∉ ys)) + witnessValue (xs.filter (fun out => out ∈ ys)) := by
 induction xs with
 | nil => simp [witnessValue]
 | cons x xs ih =>
   by_cases hx : x ∈ ys <;>
     simp [witnessValue,List.filter_cons,hx] at * <;> omega

theorem boundary_value (events : List WitnessEvent)
 (hp : (events.filterMap WitnessEvent.produced).Nodup)
 (hc : (events.filterMap WitnessEvent.consumed).Nodup) :
 witnessValue (events.filterMap WitnessEvent.produced) + witnessValue (externalWitnessInputs events) =
 witnessValue (externalWitnessOutputs events) + witnessValue (events.filterMap WitnessEvent.consumed) := by
 let ps := events.filterMap WitnessEvent.produced
 let cs := events.filterMap WitnessEvent.consumed
 have hperm : (ps.filter (fun out => out ∈ cs)).Perm (cs.filter (fun out => out ∈ ps)) := by
   apply nodup_perm (hp.filter _) (hc.filter _)
   intro out
   simp only [List.mem_filter,decide_eq_true_eq]
   exact And.comm
 have hval : witnessValue (ps.filter (fun out => out ∈ cs)) = witnessValue (cs.filter (fun out => out ∈ ps)) :=
   (hperm.map WitnessOutput.value).sum_nat
 have hps := value_split ps cs
 have hcs := value_split cs ps
 change witnessValue ps + witnessValue (cs.filter (fun out => out ∉ ps)) =
   witnessValue (ps.filter (fun out => out ∉ cs)) + witnessValue cs
 omega

theorem item_deposit_value {c : CageState} {iv refs sigs i}
 (ha : itemAllowed c iv refs sigs i) :
 requestDepositInputs [i] = witnessValue ((itemWitnessEvents c i).filterMap WitnessEvent.produced) +
 unusedDepositRefunds [i] := by
 cases i with
 | account o e =>
   simp [requestDepositInputs,unusedDepositRefunds,itemWitnessEvents,FoldItem.entryKey,FoldItem.request,
     FoldItem.extraction,witnessValue]
 | claim o =>
   simp [requestDepositInputs,unusedDepositRefunds,itemWitnessEvents,FoldItem.entryKey,FoldItem.request,
     FoldItem.extraction,witnessValue]
 | extractAccount o =>
   simp [requestDepositInputs,unusedDepositRefunds,itemWitnessEvents,FoldItem.entryKey,FoldItem.request,
     FoldItem.extraction,witnessValue]
 | extract o =>
   simp only [itemWitnessEvents,FoldItem.entryKey,ha.2.2.2.1,Option.map_none]
   simp [requestDepositInputs,unusedDepositRefunds,itemWitnessEvents,FoldItem.entryKey,FoldItem.request,
     FoldItem.extraction,witnessValue,ha.2.2.2.1,itemResult,witnessAt,putEntry,witnessOutput,Extraction.data]
 | write o e =>
   cases hspec : o.request.witnessing with
   | none =>
     by_cases hnoop : c.trie o.request.write.key = o.request.write.value
     · simp [requestDepositInputs,unusedDepositRefunds,Request.deposit,hspec,itemWitnessEvents,FoldItem.entryKey,
         FoldItem.request,FoldItem.extraction,witnessValue,itemResult,writeTree,hnoop]
     · have hnew : witnessAt (itemResult c (.write o e)).tree o.request.write.key = none := by
         simp only [itemResult,writeTree,hspec,true_and,if_neg hnoop]
         cases hwrite : o.request.write <;> simp [writeEntry,putEntry,witnessAt,Write.key]
       simp only [itemWitnessEvents,FoldItem.entryKey,hnew,Option.map_none]
       split <;> simp [requestDepositInputs,unusedDepositRefunds,FoldItem.request,FoldItem.extraction,
         Request.deposit,hspec,witnessValue]
   | some spec =>
     have hv := ha.2.1.2.2.2.2.2
     simp only [Request.witnessValid,hspec] at hv
     obtain ⟨k,v,hwrite⟩ := hv.2
     have hg := ha.1
     simp only [witnessWriteAllowed,hspec,Option.some_ne_none,false_or,hwrite,Write.key,Write.value] at hg
     cases hw : witnessAt c.tree k with
     | none =>
       simp only [itemWitnessEvents,FoldItem.entryKey,hwrite,Write.key,hw,Option.map_none]
       simp [requestDepositInputs,unusedDepositRefunds,Request.deposit,hspec,itemWitnessEvents,FoldItem.entryKey,
         FoldItem.request,FoldItem.extraction,witnessValue,itemResult,writeTree,hwrite,Write.key,
         writeEntry,witnessAt,putEntry,witnessOutput,hw]
     | some w =>
       have hfact := witness_logical hw
       have hne : w ≠ (⟨some v,spec.refund,spec.deposit,o.ref⟩ : WitnessData) := by
         intro he
         have hg' : c.trie k ≠ some v := by simpa [hw] using hg
         exact hg' (hfact.trans (congrArg WitnessData.fact he))
       simp only [itemWitnessEvents,FoldItem.entryKey,hwrite,Write.key,hw,Option.map_some]
       simp [requestDepositInputs,unusedDepositRefunds,Request.deposit,hspec,
         FoldItem.request,FoldItem.extraction,witnessValue,itemResult,writeTree,hwrite,Write.key,
         writeEntry,putEntry,witnessOutput,witnessAt,hne]

theorem run_deposit_value {iv refs sigs c items result}
 (run : FoldRun iv refs sigs c items result) :
 requestDepositInputs items = witnessValue ((foldWitnessEvents c items).filterMap WitnessEvent.produced) +
 unusedDepositRefunds items := by
 induction run with
 | nil => simp [requestDepositInputs,witnessValue,foldWitnessEvents,unusedDepositRefunds]
 | cons c i rest result ha hr ih =>
   have hi := item_deposit_value ha
   simp only [foldWitnessEvents,List.filterMap_append,witnessValue,List.map_append,List.sum_append]
   cases i <;>
     simp [requestDepositInputs,unusedDepositRefunds,FoldItem.request,FoldItem.extraction,
       witnessValue] at hi ih ⊢ <;> omega

theorem fold_deposit_value (s : State) (tx : FoldTx)
 (hr : Reachable s) (hcage : tx.cageIn = s.cage)
 (hl : ∀ o ∈ tx.requests, o ∈ s.live) (hex : ∀ o ∈ tx.extractions, o ∈ s.extractions)
 (ha : foldAccepted tx) :
 requestDepositInputs tx.items + witnessValue tx.witnessInputs =
 witnessValue tx.witnessOutputs + witnessRefundTotal s.cage tx.items + unusedDepositRefunds tx.items := by
 have hstart : Inventory tx.cageIn s.witnesses := hcage ▸ reachable_inventory s hr
 have helive := run_events_live ha.2.2.2.2.1 s.witnesses hstart
 have hp := produced_nodup tx.cageIn tx.items ((item_refs_perm tx.items).symm.nodup ha.2.1)
 have hf : ∀ out ∈ s.witnesses, out ∉ (foldWitnessEvents tx.cageIn tx.items).filterMap WitnessEvent.produced := by
   intro out ho hm
   obtain ⟨event,he,hprod⟩ := List.mem_filterMap.mp hm
   exact fold_no_reproduction s tx out hr ho hl hex event he hprod
 have hcons := consumed_nodup s.witnesses _ helive hp hf
 have hv := boundary_value _ hp hcons
 have hd := run_deposit_value ha.2.2.2.2.1
 rw [ha.2.2.2.2.2.2.1,ha.2.2.2.2.2.2.2.1,ha.2.2.2.2.2.1]
 unfold witnessRefundTotal
 rw [← hcage]
 omega


end RequestApprovalFold.ProofHelpers
