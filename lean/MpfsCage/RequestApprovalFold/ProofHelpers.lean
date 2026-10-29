import MpfsCage.RequestApprovalFold.Model
import MpfsCage.OracleIdentity.Statements

namespace RequestApprovalFold.ProofHelpers

theorem registry_refl (c : CageState) : SameRegistry c c := by
 sorry

theorem registry_trans {a b c : CageState} (h : SameRegistry a b) (k : SameRegistry b c) : SameRegistry a c := by
 sorry

theorem item_registry (c : CageState) (i : FoldItem) : SameRegistry (itemResult c i) c := by
 sorry

theorem result_registry (c : CageState) (items : List FoldItem) : SameRegistry (foldResult c items) c := by
 sorry

theorem fees_registry {a b : CageState} (h : SameRegistry a b) (r : Request) : totalFees a r = totalFees b r := by
 sorry

theorem result_trie (c : CageState) (items : List FoldItem)
 (iv : Interval) (refs : List TokenName) (sigs : List Signer) (out : CageState)
 (run : FoldRun iv refs sigs c items out) :
 (foldResult c items).trie = applyAll c.trie (items.flatMap FoldItem.writes) := by
 sorry

theorem singleton_accepted (s : State) (iv : Interval) (sigs : List Signer) (i : FoldItem) (folder : Signer)
 (hv : iv.valid) (hi : itemAllowed s.cage iv s.judgments sigs i) :
 foldAccepted (singletonFold s iv sigs i folder) := by
 sorry

theorem oracle_total (r : Request) (o : Oracle) (e : Evidence) (ha : e.authorized o) :
 OracleIdentity.totalPaid (oracleCredits r o e) = r.fee o := by
 sorry

theorem credits_total (c : CageState) (r : Request) (e : Selection)
 (ha : ∀ o ∈ c.oracles, (e o).authorized o) :
 OracleIdentity.totalPaid (credits c r e) = totalFees c r := by
 sorry

theorem run_result {iv refs sigs c items out} (h : FoldRun iv refs sigs c items out) : out = foldResult c items := by
 sorry

theorem step_registry {s s' : State} {a : Action} (h : Step s a s') : SameRegistry s'.cage s.cage := by
 sorry

theorem wf_registry {a b : CageState} (h : SameRegistry a b) (o : RequestOutput) : wellFormed a o ↔ wellFormed b o := by
 sorry

theorem live_wf (s : State) (h : Reachable s) : ∀ o ∈ s.live, wellFormed s.cage o := by
 sorry

theorem registry_valid (s : State) (h : Reachable s) : RegistryValid s.cage := by
 sorry

theorem request_member (tx : FoldTx) (o : RequestOutput) : o ∈ tx.requests ↔
 (∃ e, FoldItem.write o e ∈ tx.items) ∨ (∃ e, FoldItem.account o e ∈ tx.items) := by
 sorry

theorem claim_origin_step {s s' : State} {a : Action} (h : Step s a s') (o : ClaimOutput)
 (ho : o ∈ s'.claims) : o ∈ s.claims ∨ ∃ tx, a = .claimCreate tx ∧ tx.output = o ∧ o.key ∈ tx.signers := by
 sorry

theorem claim_origin_trace {start s : State} {events : List (State × Action × State)}
 (h : Trace start events s) (o : ClaimOutput) (ho : o ∈ s.claims) :
 o ∈ start.claims ∨ ∃ before after tx, (before, Action.claimCreate tx, after) ∈ events ∧
 Step before (.claimCreate tx) after ∧ tx.output = o ∧ o.key ∈ tx.signers := by
 sorry

theorem trace_snoc {a b c : State} {events : List (State × Action × State)} {action : Action}
 (ht : Trace a events b) (hs : Step b action c) : Trace a (events ++ [(b, action, c)]) c := by
 sorry

theorem trace_reaches {a b : State} {events : List (State × Action × State)}
 (ht : Trace a events b) (ha : Reachable a) : Reachable b := by
 sorry

theorem authorized_nonempty (o : Oracle) (e : Evidence) (ha : e.authorized o) : e.signers ≠ [] := by
 sorry

theorem claim_tokens (s : State) (h : Reachable s) :
 ∀ o ∈ s.claims, o.tokens = [claimName s.cage.id] := by
 sorry

theorem run_request_conservation {iv refs sigs c items out}
 (h : FoldRun iv refs sigs c items out) :
 requestEscrows items = grossCredits c items + requestRemainders c items + requestDepositInputs items := by
 sorry

theorem payments_total (c : CageState) (folder : Signer) (items : List FoldItem)
 (iv : Interval) (refs : List TokenName) (sigs : List Signer) (out : CageState)
 (run : FoldRun iv refs sigs c items out) :
 totalPaid (foldPayments c folder items) =
 requestRemainders c items + claimPayouts c items + claimEscrows items +
 unusedDepositRefunds items + witnessRefundTotal c items := by
 sorry

theorem credits_cover (c : CageState) (r : Request) (e : Selection)
 (ha : ∀ o ∈ c.oracles, (e o).authorized o) :
 ∀ p ∈ credits c r e, p.key ∈ registryKeys c := by
 sorry

theorem credit_backed (c : CageState) (ps : List OracleIdentity.Payment) (hb : Backed c)
 (hp : ∀ p ∈ ps, p.key ∈ registryKeys c) : Backed (credit c ps) := by
 sorry

theorem clear_sum (ks : List Signer) (f : Signer → Nat) (key : Signer)
 (hn : ks.Nodup) (hk : key ∈ ks) :
 (ks.map (fun k => if k = key then 0 else f k)).sum + f key = (ks.map f).sum := by
 sorry

theorem claim_balance_sum (c : CageState) (o : ClaimOutput) (hk : o.key ∈ registryKeys c) :
 balanceSum (itemResult c (.claim o)) + c.balances o.key = balanceSum c := by
 sorry

theorem item_backed (c : CageState) (iv : Interval) (refs : List TokenName) (sigs : List Signer)
 (i : FoldItem) (hb : Backed c) (ha : itemAllowed c iv refs sigs i) : Backed (itemResult c i) := by
 sorry

theorem run_backed {iv refs sigs c items out} (h : FoldRun iv refs sigs c items out)
 (hb : Backed c) : Backed out := by
 sorry

theorem run_value_conservation {iv refs sigs c items out} (h : FoldRun iv refs sigs c items out)
 (hb : Backed c) : c.value + grossCredits c items = out.value + claimPayouts c items := by
 sorry

theorem result_append (c : CageState) (xs ys : List FoldItem) :
 foldResult c (xs ++ ys) = foldResult (foldResult c xs) ys := by
 sorry

theorem credits_unpaid (c : CageState) (r : Request) (e : Selection) (k : Signer)
 (hz : ∀ o ∈ c.oracles, OracleIdentity.paidTo (oracleCredits r o (e o)) k = 0) :
 OracleIdentity.paidTo (credits c r e) k = 0 := by
 sorry

theorem run_balance_nonincrease {iv refs sigs c items out} (h : FoldRun iv refs sigs c items out)
 (key : Signer)
 (hz : ∀ (n : Nat) o e, (items[n]? = some (FoldItem.write o e) ∨
   items[n]? = some (FoldItem.account o e)) → ∀ oracle ∈ c.oracles,
   OracleIdentity.paidTo (oracleCredits o.request oracle (e oracle)) key = 0) :
 out.balances key ≤ c.balances key := by
 sorry

end RequestApprovalFold.ProofHelpers
