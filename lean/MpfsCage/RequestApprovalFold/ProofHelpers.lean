import MpfsCage.RequestApprovalFold.Model
import MpfsCage.OracleIdentity.Statements

namespace RequestApprovalFold.ProofHelpers

theorem registry_refl (c : CageState) : SameRegistry c c := ⟨rfl,rfl,rfl,rfl,rfl⟩
theorem registry_trans {a b c : CageState} (h : SameRegistry a b) (k : SameRegistry b c) : SameRegistry a c :=
  ⟨h.1.trans k.1, h.2.1.trans k.2.1, h.2.2.1.trans k.2.2.1,
   h.2.2.2.1.trans k.2.2.2.1, h.2.2.2.2.trans k.2.2.2.2⟩
theorem item_registry (c : CageState) (i : FoldItem) : SameRegistry (itemResult c i) c := by
  cases i <;> exact registry_refl c

theorem result_registry (c : CageState) (items : List FoldItem) : SameRegistry (foldResult c items) c := by
  induction items generalizing c with
  | nil => exact registry_refl c
  | cons i rest ih => exact registry_trans (ih (itemResult c i)) (item_registry c i)

theorem fees_registry {a b : CageState} (h : SameRegistry a b) (r : Request) : totalFees a r = totalFees b r := by
  simp [totalFees, h.2.1]

theorem result_trie (c : CageState) (items : List FoldItem) :
 (foldResult c items).trie = applyAll c.trie (items.flatMap FoldItem.writes) := by
 induction items generalizing c with
 | nil => rfl
 | cons i rest ih =>
   have h := ih (itemResult c i)
   cases i <;> simpa [foldResult, FoldItem.writes, applyAll, itemResult, credit] using h

theorem singleton_accepted (s : State) (iv : Interval) (sigs : List Signer) (i : FoldItem) (folder : Signer)
 (hv : iv.valid) (hi : itemAllowed s.cage iv s.judgments sigs i) :
 foldAccepted (singletonFold s iv sigs i folder) := by
 refine ⟨hv, ?_, by simp [singletonFold], by simp [singletonFold, foldPayments], FoldRun.cons _ _ [] _ hi (FoldRun.nil _)⟩
 cases i <;> simp [singletonFold, FoldTx.requests, FoldTx.claims, FoldItem.request, FoldItem.claimInput]

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
 rename_i tx hc _ _ _ ha
 rw [show (afterFold s tx).cage = tx.cageOut from rfl, run_result ha.2.2.2.2]
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

end RequestApprovalFold.ProofHelpers
