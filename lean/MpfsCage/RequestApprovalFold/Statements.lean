import MpfsCage.RequestApprovalFold.ProofHelpers
import MpfsCage.RequestApprovalFold.Witnesses
import MpfsCage.OracleIdentity.Statements

/-! Statement candidate extending the accepted 142 guarantees with durable witnesses.
Intentional theorem admissions await independent statement audit. -/
namespace RequestApprovalFold

theorem applyAll_append (t : Trie) (xs ys : List Write) : applyAll t (xs ++ ys) = applyAll (applyAll t xs) ys := by
  sorry

theorem foldRun_step_valid {iv : Interval} {refs : List TokenName} {sigs : List Signer} {c out : CageState} {items : List FoldItem} :
 FoldRun iv refs sigs c items out → ∀ n item, items[n]? = some item →
 itemAllowed (foldResult c (items.take n)) iv refs sigs item := by
  sorry

theorem foldRun_result {iv : Interval} {refs : List TokenName} {sigs : List Signer} {c out : CageState} {items : List FoldItem} :
 FoldRun iv refs sigs c items out → out = foldResult c items := by
  sorry

theorem foldRun_conditions {iv : Interval} {refs : List TokenName} {sigs : List Signer} {c out : CageState} {items : List FoldItem} :
 FoldRun iv refs sigs c items out → ∀ n o e, items[n]? = some (FoldItem.write o e) →
 ∀ condition ∈ o.request.conditions, condition.holds (foldResult c (items.take n)).trie := by
  sorry

theorem applyAll_keeps_present (k : Key) :
    ∀ (ws : List Write) (t : Trie), (∀ w ∈ ws, w ≠ .unset k) →
      (t k).isSome → (applyAll t ws k).isSome := by
  sorry

theorem registry_creation (c : CageState) (existing : List CageId) : registryCreated c existing →
 c.id ∉ existing ∧ (c.oracles ≠ [] ∨ c.rule.isSome) ∧ c.oracles.Nodup ∧ 0 < c.minimum ∧ c.tree = emptyEntries ∧ c.trie = emptyTrie ∧ c.balances = (fun _ => 0) ∧ c.value = 0 := by
  sorry

theorem create_tags_existing_cage (tx : CreateTx) (o : RequestOutput) : createAllowed tx o →
 (tx.cageRef.oracles ≠ [] → o.request.seed ∈ tx.spent) ∧ tx.outputs = [o] ∧
 tx.minted = tx.cageRef.oracles.map tagName ++ [requestName tx.cageRef.id] ∧
 o.request.cage = tx.cageRef.id ∧ o.tags = tx.cageRef.oracles.map tagName ∧
 totalFees tx.cageRef o.request + tx.cageRef.minimum ≤ o.value := by
  sorry

theorem requests_unique_in_history (history : List CreateTx)
    (a b : CreateTx) (oa ob : RequestOutput) :
    SpentOnce history → a ∈ history → b ∈ history →
    createAllowed a oa → createAllowed b ob → a.cageRef.oracles ≠ [] →
    b.cageRef.oracles ≠ [] → a ≠ b →
    oa.request ≠ ob.request := by
  sorry

theorem judgment_authorized_and_bound (tx : JudgmentTx) : judgmentAllowed tx →
 tx.oracle ∈ tx.cageRef.oracles ∧
 OracleIdentity.authorize tx.oracle tx.evidence.description tx.signers = some tx.evidence.record ∧
 tx.interval.valid ∧ tx.interval.upper < tx.requestRef.request.deadline ∧ tx.spent = [] ∧
 tx.requestRef.request.cage = tx.cageRef.id ∧
 tx.minted = [judgmentName tx.cageRef.id tx.requestRef.request tx.oracle tx.evidence.approve
   tx.evidence.record tx.evidence.conditions] := by
  sorry

theorem judgment_not_replayable (c c' : CageId) (r r' : Request) (o o' : Oracle) (v v' : Bool)
 (rec rec' : SigningRecord) (cs cs' : List Condition) :
 judgmentName c r o v rec cs = judgmentName c' r' o' v' rec' cs' →
 c = c' ∧ r = r' ∧ o = o' ∧ v = v' ∧ rec = rec' ∧ (v = true → cs = cs') := by
  sorry

theorem token_roles_separated (o o' : Oracle) (c : CageId) (r : Request) (v : Bool) (rec : SigningRecord) (cs : List Condition) :
 tagName o ≠ judgmentName c r o' v rec cs := by
  sorry

theorem fold_preserves_registry (tx : FoldTx) : foldAccepted tx → SameRegistry tx.cageOut tx.cageIn := by
  sorry

theorem step_preserves_registry {s s' : State} {a : Action} : Step s a s' → SameRegistry s'.cage s.cage := by
  sorry

theorem history_preserves_registry {s s' : State} : History s s' → SameRegistry s'.cage s.cage := by
  sorry

theorem only_fold_changes_tree {s s' : State} {a : Action} : Step s a s' →
 s'.cage.trie ≠ s.cage.trie → ∃ tx, a = .fold tx ∧ foldAccepted tx ∧
 tx.cageIn = s.cage ∧ s' = afterFold s tx := by
  sorry

theorem fold_only_approved_before_deadline (tx : FoldTx) : foldAccepted tx → ∀ n o e,
 tx.items[n]? = some (FoldItem.write o e) → o.request.cage = tx.cageIn.id ∧
 tx.interval.upper < o.request.deadline ∧ hasApproval (atTurn tx n) o.request tx.refs tx.signers e := by
  sorry

theorem fold_conditions_hold_when_applied (tx : FoldTx) : foldAccepted tx → ∀ n o e,
 tx.items[n]? = some (FoldItem.write o e) → ∀ condition ∈ o.request.conditions, condition.holds (atTurn tx n).trie := by
  sorry

theorem fold_root_is_folded_writes (tx : FoldTx) : foldAccepted tx →
 tx.cageOut.trie = applyAll tx.cageIn.trie (tx.items.flatMap FoldItem.writes) := by
  sorry

theorem fold_burns_tags (tx : FoldTx) : foldAccepted tx → tx.burned = tx.items.flatMap FoldItem.burned := by
  sorry

theorem fold_pays_and_keeps_rest (tx : FoldTx) : foldAccepted tx → ∀ n o e,
 tx.items[n]? = some (FoldItem.write o e) →
 (itemResult (atTurn tx n) (.write o e)).balances = (fun k => (atTurn tx n).balances k + OracleIdentity.paidTo (credits (atTurn tx n) o.request e) k) ∧
 itemPayments (atTurn tx n) tx.folder (FoldItem.write o e) = [⟨tx.folder, "", o.value - totalFees tx.cageIn o.request⟩] ++
 itemWitnessRefunds (atTurn tx n) (.write o e) ∧
 ∀ oracle ∈ tx.cageIn.oracles,
 OracleIdentity.totalPaid (oracleCredits o.request oracle (e oracle)) = o.request.fee oracle := by
  sorry

theorem allocation_conserves_value (c : CageState) (iv : Interval) (refs : List TokenName)
 (sigs : List Signer) (o : RequestOutput) (e : Selection) :
 (stepValid c iv refs sigs e o ∨ accountAllowed c iv refs o e) →
 o.escrow = OracleIdentity.totalPaid (credits c o.request e) + remainder c o + o.request.deposit := by
  sorry

/-- Ordinary blind writes remain available on every encoded tree (A-003). -/
theorem blind_write_folds_on_any_tree (c : CageState) (iv : Interval) (refs : List TokenName)
 (sigs : List Signer) (o : RequestOutput) (e : Selection) :
 wellFormed c o → iv.valid → iv.upper < o.request.deadline → hasApproval c o.request refs sigs e →
 o.request.conditions = [] → (∀ oracle ∈ c.oracles, (e oracle).conditions = []) →
 o.request.witnessing = none →
 ∀ t, FoldRun iv refs sigs { c with tree := t } [FoldItem.write o e]
 (itemResult { c with tree := t } (FoldItem.write o e)) ∧
 (itemResult { c with tree := t } (FoldItem.write o e)).trie = o.request.write.apply (logicalTree t) := by
  sorry

theorem fold_permissionless (tx : FoldTx) (other : Signer) :
 foldAccepted tx → foldAccepted { tx with submitter := other } := by
  sorry

theorem absent_inserts_exclusive (tx : FoldTx) (n m : Nat) (a b : RequestOutput) (ea eb : Selection) (k : Key) (v : Val) :
 foldAccepted tx → n < m → tx.items[n]? = some (FoldItem.write a ea) → tx.items[m]? = some (FoldItem.write b eb) →
 a.request.write = .set k v → Condition.absent k ∈ b.request.conditions →
 Write.unset k ∈ ((tx.items.drop (n + 1)).take (m - (n + 1))).flatMap FoldItem.writes := by
  sorry

theorem account_complete_and_pays (tx : FoldTx) : foldAccepted tx → ∀ n o e,
 tx.items[n]? = some (FoldItem.account o e) → hasAccount (atTurn tx n) o.request tx.refs e ∧
 (itemResult (atTurn tx n) (.account o e)).balances = (fun k => (atTurn tx n).balances k + OracleIdentity.paidTo (credits (atTurn tx n) o.request e) k) ∧
 (itemResult (atTurn tx n) (FoldItem.account o e)).trie = (atTurn tx n).trie ∧
 itemPayments (atTurn tx n) tx.folder (FoldItem.account o e) = [⟨o.request.owner, "", remainder tx.cageIn o⟩] ++
 unusedDepositPayments o ∧
 OracleIdentity.totalPaid (credits (atTurn tx n) o.request e) = totalFees tx.cageIn o.request := by
  sorry

theorem account_anyone_in_window (s : State) (o : RequestOutput) (e : Selection) (iv : Interval) (who : Signer) :
 o ∈ s.live → wellFormed s.cage o → hasAccount s.cage o.request s.judgments e →
 iv.valid → o.request.deadline ≤ iv.lower → iv.upper ≤ o.request.deadline + o.request.window →
 Step s (.fold (singletonFold s iv [] (FoldItem.account o e) who))
 (afterFold s (singletonFold s iv [] (FoldItem.account o e) who)) := by
  sorry

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
  sorry

theorem withdraw_only_owner_after_window (tx : WithdrawTx) : withdrawAllowed tx →
 tx.input.request.owner ∈ tx.signers ∧ tx.input.request.deadline + tx.input.request.window < tx.interval.lower ∧
 tx.interval.valid ∧ tx.burned = tokensOf tx.input ∧ tx.beneficiary = tx.input.request.owner ∧ tx.paid = tx.input.escrow := by
  sorry

theorem owner_can_withdraw_everything (o : RequestOutput) (iv : Interval) :
 iv.valid → o.request.deadline + o.request.window < iv.lower →
 withdrawAllowed ⟨o, iv, [o.request.owner], tokensOf o, o.request.owner, o.escrow⟩ := by
  sorry

theorem request_spent_only_by_lifecycle (o : RequestOutput) (spend : RequestSpend) : requestSpendAllowed o spend →
 (∃ tx e, spend = .folded tx ∧ foldAccepted tx ∧ FoldItem.write o e ∈ tx.items) ∨
 (∃ tx e, spend = .folded tx ∧ foldAccepted tx ∧ FoldItem.account o e ∈ tx.items) ∨
 (∃ tx, spend = .withdrawn tx ∧ withdrawAllowed tx ∧ tx.input = o) := by
  sorry

theorem every_exit_burns_tag (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → ∀ tag ∈ tokensOf o, tag ∈ spend.burned := by
  sorry

theorem early_exit_requires_all_judgments (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → spend.interval.lower ≤ o.request.deadline + o.request.window →
 ∃ (tx : FoldTx) (n : Nat) (e : Selection), spend = .folded tx ∧
 ((tx.items[n]? = some (FoldItem.write o e) ∧ hasApproval (atTurn tx n) o.request tx.refs tx.signers e) ∨
 (tx.items[n]? = some (FoldItem.account o e) ∧ hasAccount (atTurn tx n) o.request tx.refs e)) := by
  sorry

theorem early_exit_pays_every_oracle (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → spend.interval.lower ≤ o.request.deadline + o.request.window →
 ∃ (tx : FoldTx) (n : Nat) (e : Selection), spend = .folded tx ∧
 (tx.items[n]? = some (FoldItem.write o e) ∨ tx.items[n]? = some (FoldItem.account o e)) ∧
 (∀ item, tx.items[n]? = some item → (itemResult (atTurn tx n) item).balances =
 (fun k => (atTurn tx n).balances k + OracleIdentity.paidTo (credits (atTurn tx n) o.request e) k)) ∧
 ∀ oracle ∈ tx.cageIn.oracles,
 OracleIdentity.totalPaid (oracleCredits o.request oracle (e oracle)) = o.request.fee oracle := by
  sorry

theorem before_deadline_only_approvals (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → spend.interval.lower < o.request.deadline →
 ∃ (tx : FoldTx) (n : Nat) (e : Selection), spend = .folded tx ∧ tx.items[n]? = some (FoldItem.write o e) ∧
 hasApproval (atTurn tx n) o.request tx.refs tx.signers e := by
  sorry

theorem dead_judgment_can_burn (s : State) (c : CageId) (r : Request) (o : Oracle)
 (v : Bool) (rec : SigningRecord) (cs : List Condition) :
 judgmentName c r o v rec cs ∈ s.judgments → (∀ output ∈ s.live, output.request ≠ r) →
 Step s (.burn (judgmentName c r o v rec cs)) (afterBurn s (judgmentName c r o v rec cs)) ∧
 (afterBurn s (judgmentName c r o v rec cs)).cage = s.cage ∧
 (afterBurn s (judgmentName c r o v rec cs)).live = s.live := by
  sorry

theorem judgments_do_not_consume (s : State) (tx : JudgmentTx) :
 (afterJudgment s tx).live = s.live ∧ (afterJudgment s tx).claims = s.claims ∧ (afterJudgment s tx).cage = s.cage := by
  sorry

theorem exits_remove_consumed (s : State) (o : RequestOutput) : o ∉ (afterExit s o).live := by
  sorry

theorem fold_removes_consumed (s : State) (tx : FoldTx) (o : RequestOutput) : o ∈ tx.requests → o ∉ (afterFold s tx).live := by
  sorry

theorem used_seeds_monotone {s s' : State} {a : Action} : Step s a s' → ∀ seed ∈ s.usedSeeds, seed ∈ s'.usedSeeds := by
  sorry

theorem reachable_requests_have_spent_seeds (s : State) : Reachable s → s.cage.oracles ≠ [] →
 ∀ o ∈ s.live, o.request.seed ∈ s.usedSeeds := by
  sorry

theorem spent_seed_cannot_create_again (s : State) (tx : CreateTx) (o : RequestOutput) :
 s.cage.oracles ≠ [] → o.request.seed ∈ s.usedSeeds → ¬ ∃ s', Step s (.create tx o) s' := by
  sorry

theorem request_never_reappears (s s' : State) (o : RequestOutput) :
 Reachable s → o.ref ∈ s.usedOutputs → o ∉ s.live → History s s' → o ∉ s'.live := by
  sorry

theorem one_oracle_signature_suffices (c : CageState) (r : Request) (oracle : Oracle)
 (e : Selection) (sigs : List Signer) : c.oracles = [oracle] →
 (e oracle).authorized oracle → (e oracle).approve = true → (e oracle).signers = sigs →
 hasApproval c r [] sigs e := by
  sorry

theorem old_operations_correspond (op : OldOperation) (t : Trie) :
    op.write.apply t = op.apply t ∧
      (match op with
       | .insert k _ => op.condition.holds t ↔ t k = none
       | .delete k v => op.condition.holds t ↔ t k = some v
       | .update k v _ => op.condition.holds t ↔ t k = some v) := by
  sorry

theorem live_removal_is_legal_exit {s s' : State} {a : Action} (o : RequestOutput) :
 Step s a s' → o ∈ s.live → o ∉ s'.live →
 ∃ spend, a.spend = some spend ∧ requestSpendAllowed o spend ∧
 (match spend with
 | .folded tx => s' = afterFold s tx ∧ tx.cageIn = s.cage ∧
     (∀ input ∈ tx.requests, input ∈ s.live) ∧ (∀ claim ∈ tx.claims, claim ∈ s.claims) ∧
     (∀ name ∈ tx.refs, name ∈ s.judgments)
 | .withdrawn tx => s' = afterExit s tx.input) := by
  sorry

theorem new_judgment_is_authorized {s s' : State} {a : Action} (name : TokenName) :
 Step s a s' → name ∈ s'.issued → name ∉ s.issued →
 ∃ tx, a = .judge tx ∧ tx.cageRef = s.cage ∧ tx.requestRef ∈ s.live ∧ judgmentAllowed tx ∧ name ∈ tx.minted := by
  sorry

theorem exit_time_window (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → ∀ kind, spend.exitsAs o kind → exitAt o spend.interval kind := by
  sorry

theorem exit_windows_cover (o : RequestOutput) (now : Time) :
 exitAt o ⟨now, now⟩ .write ∨ exitAt o ⟨now, now⟩ .account ∨ exitAt o ⟨now, now⟩ .withdraw := by
  sorry

theorem exit_kind_unique (o : RequestOutput) (a b : RequestSpend) (ka kb : ExitKind) :
 requestSpendAllowed o a → requestSpendAllowed o b → a.interval = b.interval →
 a.exitsAs o ka → b.exitsAs o kb → ka = kb := by
  sorry

theorem fold_references_authentic {s s' : State} (tx : FoldTx) :
 Step s (.fold tx) s' → tx.cageIn = s.cage ∧ (∀ o ∈ tx.requests, o ∈ s.live) ∧
 (∀ o ∈ tx.claims, o ∈ s.claims) ∧ ∀ name ∈ tx.refs, name ∈ s.judgments := by
  sorry

theorem account_references_authentic {s s' : State} (tx : FoldTx) (n : Nat) (o : RequestOutput) (e : Selection) :
 Step s (.fold tx) s' → tx.items[n]? = some (FoldItem.account o e) →
 ∀ oracle ∈ s.cage.oracles, (e oracle).name s.cage.id o.request oracle ∈ s.judgments := by
  sorry

theorem creation_references_source {s s' : State} (tx : CreateTx) (o : RequestOutput) :
 Step s (.create tx o) s' → tx.cageRef = s.cage ∧ o.request.cage = s.cage.id := by
  sorry

theorem fold_payments_concrete (tx : FoldTx) (n : Nat) (o : RequestOutput) (e : Selection) :
 foldAccepted tx → tx.items[n]? = some (FoldItem.write o e) →
 (itemResult (atTurn tx n) (FoldItem.write o e)).balances =
 (fun k => (atTurn tx n).balances k + OracleIdentity.paidTo (credits (atTurn tx n) o.request e) k) ∧
 itemPayments (atTurn tx n) tx.folder (FoldItem.write o e) =
 [⟨tx.folder, "", o.value - (tx.cageIn.oracles.map fun oracle =>
 ((o.request.fees.find? (fun p => p.1 == oracle)).map Prod.snd).getD 0).sum⟩] ++
 itemWitnessRefunds (atTurn tx n) (.write o e) := by
  sorry

theorem account_payments_concrete (tx : FoldTx) (n : Nat) (o : RequestOutput) (e : Selection) :
 foldAccepted tx → tx.items[n]? = some (FoldItem.account o e) →
 (itemResult (atTurn tx n) (FoldItem.account o e)).balances =
 (fun k => (atTurn tx n).balances k + OracleIdentity.paidTo (credits (atTurn tx n) o.request e) k) ∧
 itemPayments (atTurn tx n) tx.folder (FoldItem.account o e) =
 [⟨o.request.owner, "", o.value - (tx.cageIn.oracles.map fun oracle =>
 ((o.request.fees.find? (fun p => p.1 == oracle)).map Prod.snd).getD 0).sum⟩] ++
 unusedDepositPayments o := by
  sorry

theorem creation_funds_declared_fees {s s' : State} (tx : CreateTx) (o : RequestOutput) :
 Step s (.create tx o) s' → (s.cage.oracles.map fun oracle =>
 ((o.request.fees.find? (fun p => p.1 == oracle)).map Prod.snd).getD 0).sum + s.cage.minimum ≤ o.value := by
  sorry

theorem burn_removes_one {s s' : State} (name : TokenName) : Step s (.burn name) s' →
 s'.judgments.count name + 1 = s.judgments.count name ∧ s'.judgments = s.judgments.erase name := by
  sorry

theorem burn_keeps_history {s s' : State} (name : TokenName) : Step s (.burn name) s' → s'.issued = s.issued := by
  sorry

theorem fold_requests_unique (tx : FoldTx) : foldAccepted tx →
 (tx.requests.map RequestOutput.ref ++ tx.claims.map ClaimOutput.ref ++ tx.extractions.map Extraction.ref).Nodup ∧ tx.requests.Nodup ∧ tx.claims.Nodup := by
  sorry

theorem account_accepts_any_verdicts (s : State) (o : RequestOutput) (e : Selection)
 (iv : Interval) (who : Signer) : o ∈ s.live → wellFormed s.cage o → iv.valid →
 o.request.deadline ≤ iv.lower → iv.upper ≤ o.request.deadline + o.request.window →
 (∀ oracle ∈ s.cage.oracles, (e oracle).authorized oracle ∧
   (e oracle).name s.cage.id o.request oracle ∈ s.judgments) →
 Step s (.fold (singletonFold s iv [] (FoldItem.account o e) who))
 (afterFold s (singletonFold s iv [] (FoldItem.account o e) who)) := by
  sorry

theorem equivocation_reachable : ∃ (s : State) (o : RequestOutput) (oracle : Oracle)
 (rec : SigningRecord) (cs : List Condition),
 Reachable s ∧ o ∈ s.live ∧ o.request.cage = s.cage.id ∧ oracle ∈ s.cage.oracles ∧
 judgmentName s.cage.id o.request oracle true rec cs ∈ s.judgments ∧
 judgmentName s.cage.id o.request oracle false rec [] ∈ s.judgments ∧
 judgmentName s.cage.id o.request oracle true rec cs ∈ s.issued ∧
 judgmentName s.cage.id o.request oracle false rec [] ∈ s.issued := by
  sorry

theorem tag_name_injective (a b : Oracle) : tagName a = tagName b ↔ a = b := by
  sorry

theorem price_name_injective (a b : Oracle) : priceName a = priceName b ↔ a = b := by
  sorry

theorem different_roles_never_coincide (a b : TokenRole) (x y : NameBinding) : a ≠ b → tokenName a x ≠ tokenName b y := by
  sorry

theorem names_have_leading_roles (c : CageId) (r : Request) (o : Oracle) (rec : SigningRecord) (cs : List Condition) :
 (tagName o).role = .tag ∧ (priceName o).role = .price ∧
 (judgmentName c r o true rec cs).role = .approval ∧
 (judgmentName c r o false rec cs).role = .refusal ∧
 (requestName c).role = .request ∧ (claimName c).role = .claim := by
  sorry

theorem reachable_registry_valid (s : State) : Reachable s → RegistryValid s.cage := by
  sorry

theorem reachable_live_tags (s : State) : Reachable s → ∀ o ∈ s.live,
 o.request.cage = s.cage.id ∧ o.tags = s.cage.oracles.map tagName := by
  sorry

theorem reachable_tags_unique (s : State) (o : RequestOutput) : Reachable s → o ∈ s.live →
 o.tags.Nodup ∧ ∀ oracle ∈ s.cage.oracles, o.tags.count (tagName oracle) = 1 := by
  sorry

theorem discovery_iff (s : State) (oracle : Oracle) (o : RequestOutput) : Reachable s →
 (o ∈ discover oracle s.live ↔ o ∈ s.live ∧ oracle ∈ s.cage.oracles) := by
  sorry

theorem discovery_across_registries (states : List State) (oracle : Oracle) (o : RequestOutput) :
 (∀ s ∈ states, Reachable s) →
 (o ∈ discover oracle (states.flatMap State.live) ↔ ∃ s ∈ states, o ∈ s.live ∧ oracle ∈ s.cage.oracles) := by
  sorry

theorem live_removal_burns_oracle_tags {s s' : State} {a : Action} (o : RequestOutput) :
 Reachable s → Step s a s' → o ∈ s.live → o ∉ s'.live →
 ∃ spend, a.spend = some spend ∧ requestSpendAllowed o spend ∧ ∀ oracle ∈ s.cage.oracles, tagName oracle ∈ spend.burned := by
  sorry

theorem price_mint_inversion {s s' : State} (tx : PriceMintTx) : Step s (.priceMint tx) s' →
 (OracleIdentity.authorize tx.output.oracle tx.description tx.signers).isSome = true ∧
 tx.output.token = ⟨.price, .oracle tx.output.oracle⟩ ∧ tx.minted = [tx.output.token] ∧
 s'.notices = tx.output :: s.notices := by
  sorry

theorem price_update_inversion {s s' : State} (tx : PriceUpdateTx) : Step s (.priceUpdate tx) s' →
 tx.input ∈ s.notices ∧ (OracleIdentity.authorize tx.input.oracle tx.description tx.signers).isSome = true ∧
 tx.input.token = ⟨.price, .oracle tx.input.oracle⟩ ∧ tx.output.oracle = tx.input.oracle ∧
 tx.output.token = tx.input.token ∧ tx.minted = [] ∧ s'.notices = tx.output :: s.notices.erase tx.input := by
  sorry

theorem reachable_notice_names (s : State) : Reachable s → ∀ n ∈ s.notices, n.token = ⟨.price, .oracle n.oracle⟩ := by
  sorry

theorem price_mint_available (s : State) (oracle : Oracle) (d : OracleIdentity.Description)
 (sigs : List Signer) (datum : PriceDatum) :
 (OracleIdentity.authorize oracle d sigs).isSome = true →
 let tx : PriceMintTx := ⟨⟨oracle, priceName oracle, datum⟩, d, sigs, [priceName oracle]⟩
 Step s (.priceMint tx) (afterPriceMint s tx) := by
  sorry

theorem price_update_available (s : State) (n : PriceNotice) (d : OracleIdentity.Description)
 (sigs : List Signer) (datum : PriceDatum) : n ∈ s.notices → n.token = priceName n.oracle →
 (OracleIdentity.authorize n.oracle d sigs).isSome = true →
 let tx : PriceUpdateTx := ⟨n, { n with datum := datum }, d, sigs, []⟩
 Step s (.priceUpdate tx) (afterPriceUpdate s tx) := by
  sorry

theorem price_notice_noninterference {s s' : State} {a : Action} : Step s a s' → a.isPrice = true →
 s'.cage = s.cage ∧ s'.live = s.live ∧ s'.claims = s.claims ∧ s'.judgments = s.judgments ∧
 s'.issued = s.issued ∧ s'.usedSeeds = s.usedSeeds ∧ s'.usedOutputs = s.usedOutputs ∧
 a.payments = [] ∧ a.spend = none := by
  sorry

theorem notices_do_not_bind_protocol {s s' : State} {a : Action} (notices : List PriceNotice) :
 Step s a s' → a.isPrice = false →
 Step { s with notices := notices } a { s' with notices := notices } := by
  sorry

theorem notice_change_authorized {s s' : State} {a : Action} (n : PriceNotice) :
 Step s a s' → n ∈ s'.notices → n ∉ s.notices →
 (∃ tx, a = .priceMint tx ∧ tx.output = n ∧
 (OracleIdentity.authorize n.oracle tx.description tx.signers).isSome = true) ∨
 (∃ tx, a = .priceUpdate tx ∧ tx.input ∈ s.notices ∧ tx.output = n ∧ tx.input.oracle = n.oracle ∧
 (OracleIdentity.authorize n.oracle tx.description tx.signers).isSome = true) := by
  sorry

theorem creation_rule_and_token (tx : CreateTx) (o : RequestOutput) : createAllowed tx o →
 ruleAdmits tx.cageRef o.request tx.signers ∧ tx.outputs = [o] ∧
 o.request.cage = tx.cageRef.id ∧ o.requestTokens = [requestName tx.cageRef.id] ∧
 o.policy = requestPolicy tx.cageRef ∧ tx.policy = requestPolicy tx.cageRef ∧
 tx.minted = tx.cageRef.oracles.map tagName ++ [requestName tx.cageRef.id] ∧
 totalFees tx.cageRef o.request + tx.cageRef.minimum ≤ o.value := by
  sorry

theorem step_rule_immutable {s s' : State} {a : Action} : Step s a s' → s'.cage.rule = s.cage.rule := by
  sorry

theorem history_rule_immutable {s s' : State} : History s s' → s'.cage.rule = s.cage.rule := by
  sorry

theorem reachable_rule_admitted (s : State) : Reachable s → ∀ o ∈ s.live,
 ∃ sigs, ruleAdmits s.cage o.request sigs := by
  sorry

theorem every_rule_allows_burn (s : State) (rule : Rule) : s.cage.rule = some rule →
 (∀ tx, tx.cageIn = s.cage → (∀ o ∈ tx.requests, o ∈ s.live) →
 (∀ o ∈ tx.claims, o ∈ s.claims) → (∀ name ∈ tx.refs, name ∈ s.judgments) →
 tx.interval.valid → (tx.requests.map RequestOutput.ref ++ tx.claims.map ClaimOutput.ref ++ tx.extractions.map Extraction.ref).Nodup →
 tx.burned = tx.items.flatMap FoldItem.burned → tx.payments = foldPayments tx.cageIn tx.folder tx.items →
 FoldRun tx.interval tx.refs tx.signers tx.cageIn tx.items tx.cageOut → witnessBoundary tx →
 (∀ o ∈ tx.extractions, o ∈ s.extractions) → (∀ w ∈ tx.witnessInputs, w ∈ s.witnesses) →
 Step s (.fold tx) (afterFold s tx)) ∧
 (∀ tx : WithdrawTx, tx.input ∈ s.live → tx.interval.valid →
 tx.input.request.deadline + tx.input.request.window < tx.interval.lower →
 tx.input.request.owner ∈ tx.signers → tx.burned = tokensOf tx.input →
 tx.beneficiary = tx.input.request.owner → tx.paid = tx.input.escrow →
 Step s (.withdraw tx) (afterExit s tx.input)) ∧
 (∀ name ∈ s.judgments, Step s (.burn name) (afterBurn s name)) := by
  sorry

theorem creation_rule_input_binding {s s' : State} {tx : CreateTx} {o : RequestOutput} (rule : Rule) :
 Step s (.create tx o) s' → s.cage.rule = some rule →
 tx.outputs = [o] ∧ o ∈ s'.live ∧ rule.admits o.request tx.signers := by
  sorry

theorem creation_request_policy {s s' : State} {tx : CreateTx} {o : RequestOutput} :
 Step s (.create tx o) s' → tx.outputs = [o] ∧
 o.requestTokens = [requestName s.cage.id] ∧
 tx.minted = s.cage.oracles.map tagName ++ [requestName s.cage.id] ∧
 (match s.cage.rule with
 | some rule => tx.policy = .rule rule.hash ∧ o.policy = .rule rule.hash ∧ tx.policy ≠ .release ∧ o.policy ≠ .release
 | none => tx.policy = .release ∧ o.policy = .release) := by
  sorry

theorem fold_rule_predicate_independent (c : CageState) (hash : String) (p q : Request → List Signer → Prop)
 (iv : Interval) (refs : List TokenName) (sigs : List Signer) (i : FoldItem) :
 itemAllowed { c with rule := some ⟨hash, p⟩ } iv refs sigs i ↔
 itemAllowed { c with rule := some ⟨hash, q⟩ } iv refs sigs i := by
  sorry

theorem reachable_request_tokens (s : State) : Reachable s → ∀ o ∈ s.live,
 o.requestTokens = [requestName s.cage.id] ∧ o.policy = requestPolicy s.cage := by
  sorry

theorem fold_requires_request_token (tx : FoldTx) : foldAccepted tx → ∀ o ∈ tx.requests,
 o.requestTokens = [requestName tx.cageIn.id] ∧ o.policy = requestPolicy tx.cageIn := by
  sorry

theorem every_exit_burns_request_token (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → ∀ token ∈ o.requestTokens, token ∈ spend.burned := by
  sorry

theorem live_removal_burns_request_token {s s' : State} {a : Action} (o : RequestOutput) :
 Reachable s → Step s a s' → o ∈ s.live → o ∉ s'.live →
 ∃ spend, a.spend = some spend ∧ requestSpendAllowed o spend ∧ requestName s.cage.id ∈ spend.burned := by
  sorry

theorem request_name_injective (a b : CageId) : requestName a = requestName b ↔ a = b := by
  sorry

theorem request_token_discovery (s : State) (id : CageId) (o : RequestOutput) : Reachable s →
 (o ∈ discoverRequests id s.live ↔ o ∈ s.live ∧ s.cage.id = id) := by
  sorry

theorem request_token_discovery_across_registries (states : List State) (id : CageId) (o : RequestOutput) :
 (∀ s ∈ states, Reachable s) →
 (o ∈ discoverRequests id (states.flatMap State.live) ↔ ∃ s ∈ states, o ∈ s.live ∧ s.cage.id = id) := by
  sorry

theorem output_refs_monotone {s s' : State} {a : Action} : Step s a s' → ∀ ref ∈ s.usedOutputs, ref ∈ s'.usedOutputs := by
  sorry

theorem reachable_output_refs (s : State) : Reachable s →
 (∀ o ∈ s.live, o.ref ∈ s.usedOutputs) ∧ (∀ o ∈ s.claims, o.ref ∈ s.usedOutputs) := by
  sorry

theorem reachable_output_refs_unique (s : State) : Reachable s →
 (s.live.map RequestOutput.ref ++ s.claims.map ClaimOutput.ref).Nodup := by
  sorry

theorem unguarded_registry_impossible (c : CageState) (existing : List CageId) :
 c.oracles = [] → c.rule = none → ¬ registryCreated c existing := by
  sorry

theorem zero_oracle_needs_rule (c : CageState) (existing : List CageId) :
 registryCreated c existing → c.oracles = [] → ∃ rule, c.rule = some rule := by
  sorry

theorem zero_oracle_evidence_empty (c : CageState) (r : Request) (e : Selection) :
 c.oracles = [] → hasApproval c r [] [] e ∧ hasAccount c r [] e := by
  sorry

theorem zero_oracle_creation_without_seed (c : CageState) (o : RequestOutput) (sigs : List Signer) :
 c.oracles = [] → wellFormed c o → ruleAdmits c o.request sigs →
 createAllowed ⟨[], c, [requestName c.id], [o], sigs, requestPolicy c⟩ o := by
  sorry

theorem zero_oracle_fold_without_approvals (c : CageState) (o : RequestOutput) (iv : Interval) (e : Selection) :
 c.oracles = [] → wellFormed c o → iv.valid → iv.upper < o.request.deadline →
 witnessWriteAllowed c o.request →
 (∀ condition ∈ o.request.conditions, condition.holds c.trie) →
 FoldRun iv [] [] c [FoldItem.write o e] (itemResult c (FoldItem.write o e)) ∧
 (itemResult c (FoldItem.write o e)).trie = o.request.write.apply c.trie := by
  sorry

theorem zero_oracle_account_without_verdicts (s : State) (o : RequestOutput) (iv : Interval) (e : Selection) :
 s.cage.oracles = [] → o ∈ s.live → wellFormed s.cage o → iv.valid →
 o.request.deadline ≤ iv.lower → iv.upper ≤ o.request.deadline + o.request.window →
 Step s (.fold (singletonFold s iv [] (FoldItem.account o e) o.request.owner))
 (afterFold s (singletonFold s iv [] (FoldItem.account o e) o.request.owner)) := by
  sorry

theorem present_condition_semantics (t : Trie) (k : Key) : Condition.holds t (.present k) ↔ ∃ v, t k = some v := by
  sorry

theorem foldRun_oracle_conditions {iv : Interval} {refs : List TokenName} {sigs : List Signer}
 {c out : CageState} {items : List FoldItem} : FoldRun iv refs sigs c items out →
 ∀ n o e, items[n]? = some (FoldItem.write o e) → ∀ oracle ∈ c.oracles,
 ∀ condition ∈ (e oracle).conditions, condition.holds (foldResult c (items.take n)).trie := by
  sorry

theorem fold_all_conditions_hold (tx : FoldTx) : foldAccepted tx → ∀ n o e,
 tx.items[n]? = some (FoldItem.write o e) →
 (∀ condition ∈ o.request.conditions, condition.holds (atTurn tx n).trie) ∧
 (∀ oracle ∈ tx.cageIn.oracles, ∀ condition ∈ (e oracle).conditions, condition.holds (atTurn tx n).trie) := by
  sorry

theorem approval_conditions_cannot_change (c : CageId) (r : Request) (o : Oracle)
 (rec rec' : SigningRecord) (a b : List Condition) :
 judgmentName c r o true rec a = judgmentName c r o true rec' b ↔ rec = rec' ∧ a = b := by
  sorry

theorem stale_approval_unusable (tx : FoldTx) (n : Nat) (o : RequestOutput) (e : Selection)
 (oracle : Oracle) (condition : Condition) : tx.items[n]? = some (FoldItem.write o e) →
 oracle ∈ tx.cageIn.oracles → condition ∈ (e oracle).conditions →
 ¬ condition.holds (atTurn tx n).trie → ¬ foldAccepted tx := by
  sorry

theorem fold_evidence_binds_conditions {s s' : State} (tx : FoldTx) (n : Nat) (o : RequestOutput) (e : Selection) :
 Step s (.fold tx) s' → tx.items[n]? = some (FoldItem.write o e) → ∀ oracle ∈ s.cage.oracles,
 (e oracle).authorized oracle ∧ (e oracle).approve = true ∧
 (judgmentName s.cage.id o.request oracle true (e oracle).record (e oracle).conditions ∈ s.judgments ∨
 (e oracle).signers = tx.signers) := by
  sorry

theorem expected_approval_lookup (c : CageState) (r : Request) (e : Selection) (refs : List TokenName) :
 hasApproval c r refs [] e ↔
 (∀ oracle ∈ c.oracles, (e oracle).authorized oracle ∧ (e oracle).approve = true) ∧
 (∀ name ∈ expectedApprovals c r e, name ∈ refs) := by
  sorry

theorem folder_discovery_exact (s : State) (iv : Interval) (sigs : List Signer) (e : Selection) (o : RequestOutput) :
 Reachable s → (folderFinds s iv sigs e o ↔ o ∈ s.live ∧ stepValid s.cage iv s.judgments sigs e o) := by
  sorry

theorem folder_discovery_executable (s : State) (iv : Interval) (sigs : List Signer) (e : Selection) (o : RequestOutput) (folder : Signer) :
 Reachable s → (folderFinds s iv sigs e o ↔
 Step s (.fold (singletonFold s iv sigs (FoldItem.write o e) folder))
 (afterFold s (singletonFold s iv sigs (FoldItem.write o e) folder))) := by
  sorry

theorem empty_fold_allowed (s : State) (iv : Interval) (who : Signer) : iv.valid →
 let tx : FoldTx := ⟨s.cage, s.cage, [], [], [], iv, who, who, [], [], [], [], [], [], []⟩
 Step s (.fold tx) s := by
  sorry

theorem empty_fold_earns_nothing (tx : FoldTx) : foldAccepted tx → tx.items = [] →
 tx.payments = [] ∧ tx.burned = [] ∧ tx.cageOut = tx.cageIn := by
  sorry

theorem only_fold_changes_registry {s s' : State} {a : Action} : Step s a s' → s'.cage ≠ s.cage → ∃ tx, a = .fold tx := by
  sorry

theorem reachable_balances_backed (s : State) : Reachable s → Backed s.cage := by
  sorry

theorem fold_value_conservation (s s' : State) (tx : FoldTx) : Reachable s → Step s (.fold tx) s' →
 s.cage.value + requestEscrows tx.items + claimEscrows tx.items + witnessValue tx.witnessInputs =
 s'.cage.value + requestRemainders s.cage tx.items + claimPayouts s.cage tx.items + claimEscrows tx.items +
 unusedDepositRefunds tx.items + witnessRefundTotal s.cage tx.items + witnessValue tx.witnessOutputs := by
  sorry

theorem fold_request_conservation (tx : FoldTx) : foldAccepted tx →
 requestEscrows tx.items = grossCredits tx.cageIn tx.items + requestRemainders tx.cageIn tx.items + requestDepositInputs tx.items := by
  sorry

theorem fold_balance_conservation (s s' : State) (tx : FoldTx) : Reachable s → Step s (.fold tx) s' →
 balanceSum s.cage + grossCredits s.cage tx.items = balanceSum s'.cage + claimPayouts s.cage tx.items := by
  sorry

theorem fold_payments_exact (tx : FoldTx) : foldAccepted tx →
 tx.payments = foldPayments tx.cageIn tx.folder tx.items ∧
 totalPaid tx.payments = requestRemainders tx.cageIn tx.items + claimPayouts tx.cageIn tx.items + claimEscrows tx.items +
 unusedDepositRefunds tx.items + witnessRefundTotal tx.cageIn tx.items := by
  sorry

theorem group_credits_only_recorded_signers (c : CageState) (r : Request) (o : Oracle) (e : Evidence) (k : Signer) :
 e.authorized o → k ∉ OracleIdentity.recordedKeys e.record → OracleIdentity.paidTo (oracleCredits r o e) k = 0 := by
  sorry

theorem group_credits_exact_split (r : Request) (o : Oracle) (e : Evidence) : e.authorized o →
 oracleCredits r o e = OracleIdentity.splitRecorded e.record (r.fee o) := by
  sorry

theorem judgment_record_cannot_change (c : CageId) (r : Request) (o : Oracle) (v : Bool)
 (a b : SigningRecord) (cs : List Condition) : judgmentName c r o v a cs = judgmentName c r o v b cs → a = b := by
  sorry

theorem claim_creation_inversion {s s' : State} (tx : ClaimCreateTx) : Step s (.claimCreate tx) s' →
 tx.cageRef = s.cage ∧ tx.output.cage = s.cage.id ∧ tx.output.key ∈ registryKeys s.cage ∧
 tx.output.key ∈ tx.signers ∧ tx.output.tokens = [claimName s.cage.id] ∧
 tx.minted = tx.output.tokens ∧ tx.output.ref ∉ s.usedOutputs ∧ s' = afterClaimCreate s tx := by
  sorry

theorem reachable_claim_authorization (c : CageState) (existing : List CageId)
 (events : List (State × Action × State)) (s : State) (o : ClaimOutput) :
 registryCreated c existing → Trace (initial c) events s → o ∈ s.claims →
 ∃ before after tx, (before, Action.claimCreate tx, after) ∈ events ∧
 Step before (.claimCreate tx) after ∧ tx.output = o ∧ o.key ∈ tx.signers := by
  sorry

theorem claim_payout_fixed (tx : FoldTx) (n : Nat) (o : ClaimOutput) : foldAccepted tx →
 tx.items[n]? = some (FoldItem.claim o) →
 itemPayments (atTurn tx n) tx.folder (FoldItem.claim o) =
 [⟨o.destination, o.datum, (atTurn tx n).balances o.key⟩, ⟨tx.folder, "", o.value⟩] ∧
 (itemResult (atTurn tx n) (FoldItem.claim o)).balances o.key = 0 ∧
 (∀ k, k ≠ o.key → (itemResult (atTurn tx n) (FoldItem.claim o)).balances k = (atTurn tx n).balances k) := by
  sorry

theorem claim_payout_in_actual_outputs (tx : FoldTx) (n : Nat) (o : ClaimOutput) : foldAccepted tx →
 tx.items[n]? = some (FoldItem.claim o) → ⟨o.destination, o.datum, (atTurn tx n).balances o.key⟩ ∈ tx.payments := by
  sorry

theorem claim_below_minimum_refused (c : CageState) (iv : Interval) (o : ClaimOutput) :
 c.balances o.key < c.minimum → ¬ claimAllowed c iv o := by
  sorry

theorem claim_turn_balance (c : CageState) (o : RequestOutput) (e : Selection) (claim : ClaimOutput) (folder : Signer) :
 itemPayments (itemResult c (FoldItem.write o e)) folder (FoldItem.claim claim) =
 [⟨claim.destination, claim.datum, c.balances claim.key + OracleIdentity.paidTo (credits c o.request e) claim.key⟩,
 ⟨folder, "", claim.value⟩] := by
  sorry

theorem claim_consumed_and_burned {s s' : State} (tx : FoldTx) (o : ClaimOutput) :
 Step s (.fold tx) s' → o ∈ tx.claims → o ∉ s'.claims ∧ ∀ token ∈ o.tokens, token ∈ tx.burned := by
  sorry

theorem claim_withdrawal_inversion {s s' : State} (tx : ClaimWithdrawTx) : Reachable s → Step s (.claimWithdraw tx) s' →
 tx.input ∈ s.claims ∧ tx.input.key ∈ tx.signers ∧ tx.input.deadline ≤ tx.interval.lower ∧
 tx.interval.valid ∧ tx.burned = tx.input.tokens ∧ tx.beneficiary = tx.input.key ∧ tx.paid = tx.input.value ∧
 s'.cage = s.cage ∧ tx.input ∉ s'.claims := by
  sorry

theorem claim_withdrawal_available (s : State) (o : ClaimOutput) (iv : Interval) :
 o ∈ s.claims → iv.valid → o.deadline ≤ iv.lower →
 let tx : ClaimWithdrawTx := ⟨o, iv, [o.key], o.tokens, o.key, o.value⟩
 Step s (.claimWithdraw tx) (afterClaimWithdraw s tx) := by
  sorry

theorem claim_windows_disjoint (c : CageState) (iv : Interval) (o : ClaimOutput) (tx : ClaimWithdrawTx) :
 claimAllowed c iv o → tx.input = o → tx.interval = iv → ¬ claimWithdrawAllowed tx := by
  sorry

theorem claim_discovery_exact (s : State) (id : CageId) (o : ClaimOutput) : Reachable s →
 (o ∈ discoverClaims id s.claims ↔ o ∈ s.claims ∧ s.cage.id = id) := by
  sorry

theorem request_withdrawal_preserves_registry {s s' : State} (tx : WithdrawTx) : Step s (.withdraw tx) s' → s'.cage = s.cage := by
  sorry

theorem fold_interval_fits_every_item (tx : FoldTx) : foldAccepted tx → tx.interval.valid ∧
 (∀ o e, FoldItem.write o e ∈ tx.items → tx.interval.upper < o.request.deadline) ∧
 (∀ o e, FoldItem.account o e ∈ tx.items → o.request.deadline ≤ tx.interval.lower ∧
 tx.interval.upper ≤ o.request.deadline + o.request.window) ∧
 (∀ o, FoldItem.claim o ∈ tx.items → tx.interval.upper < o.deadline) ∧
 (∀ o, FoldItem.extract o ∈ tx.items → tx.interval.upper < o.deadline) ∧
 (∀ o, FoldItem.extractAccount o ∈ tx.items → o.deadline ≤ tx.interval.lower ∧
 tx.interval.upper ≤ o.deadline + o.window) := by
  sorry

theorem step_inversion (s s' : State) (a : Action) : Step s a s' ↔
 (match a with
 | .create tx o => tx.cageRef = s.cage ∧ createAllowed tx o ∧
     (∀ seed ∈ tx.spent, seed ∉ s.usedSeeds) ∧ o.ref ∉ s.usedOutputs ∧ s' = afterCreate s tx o
 | .judge tx => tx.cageRef = s.cage ∧ tx.requestRef ∈ s.live ∧ judgmentAllowed tx ∧ s' = afterJudgment s tx
 | .fold tx => tx.cageIn = s.cage ∧ (∀ o ∈ tx.requests, o ∈ s.live) ∧
     (∀ o ∈ tx.claims, o ∈ s.claims) ∧ (∀ name ∈ tx.refs, name ∈ s.judgments) ∧
     foldAccepted tx ∧ (∀ o ∈ tx.extractions, o ∈ s.extractions) ∧
     (∀ w ∈ tx.witnessInputs, w ∈ s.witnesses) ∧ s' = afterFold s tx
 | .withdraw tx => tx.input ∈ s.live ∧ withdrawAllowed tx ∧ s' = afterExit s tx.input
 | .burn name => name ∈ s.judgments ∧ s' = afterBurn s name
 | .priceMint tx => priceMintAllowed tx ∧ s' = afterPriceMint s tx
 | .priceUpdate tx => tx.input ∈ s.notices ∧ priceUpdateAllowed tx ∧ s' = afterPriceUpdate s tx
 | .claimCreate tx => tx.cageRef = s.cage ∧ claimCreateAllowed tx ∧
     tx.output.ref ∉ s.usedOutputs ∧ s' = afterClaimCreate s tx
 | .claimWithdraw tx => tx.input ∈ s.claims ∧ claimWithdrawAllowed tx ∧ s' = afterClaimWithdraw s tx
 | .extractionCreate tx => tx.cageRef = s.cage ∧ extractionCreateAllowed tx ∧
     tx.output.ref ∉ s.usedOutputs ∧ s' = afterExtractionCreate s tx
 | .extractionWithdraw tx => tx.input ∈ s.extractions ∧ extractionWithdrawAllowed tx ∧
     s' = afterExtractionWithdraw s tx) := by
  sorry

theorem foldRun_inversion (iv : Interval) (refs : List TokenName) (sigs : List Signer)
 (c out : CageState) (items : List FoldItem) : FoldRun iv refs sigs c items out ↔
 (match items with
 | [] => out = c
 | item :: rest => itemAllowed c iv refs sigs item ∧ FoldRun iv refs sigs (itemResult c item) rest out) := by
  sorry

theorem claim_item_inversion (tx : FoldTx) (n : Nat) (o : ClaimOutput) :
 foldAccepted tx → tx.items[n]? = some (FoldItem.claim o) →
 o.cage = tx.cageIn.id ∧ o.key ∈ registryKeys tx.cageIn ∧ o.tokens = [claimName tx.cageIn.id] ∧
 tx.interval.valid ∧ tx.interval.upper < o.deadline ∧ tx.cageIn.minimum ≤ (atTurn tx n).balances o.key := by
  sorry

theorem claim_windows_cover (c : CageState) (o : ClaimOutput) (now : Time) :
 o.cage = c.id → o.key ∈ registryKeys c → o.tokens = [claimName c.id] →
 c.minimum ≤ c.balances o.key →
 claimAllowed c ⟨now, now⟩ o ∨
 claimWithdrawAllowed ⟨o, ⟨now, now⟩, [o.key], o.tokens, o.key, o.value⟩ := by
  sorry

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

theorem trace_reachability (s : State) : Reachable s ↔
 ∃ c existing events, registryCreated c existing ∧ Trace (initial c) events s := by
  sorry

theorem exit_windows_disjoint (o : RequestOutput) (iv : Interval) (a b : ExitKind) :
 exitAt o iv a → exitAt o iv b → a = b := by
  sorry


/-- D01: stripping annotations preserves every logical read. -/
theorem logical_tree_stripped (tree : EntryTree) :
 logicalTree (stripWitnesses tree) = logicalTree tree := by sorry

/-- D02: all condition constructors read through the annotation. -/
theorem conditions_read_logical (tree : EntryTree) (condition : Condition) :
 condition.holds (logicalTree tree) ↔ condition.holds (logicalTree (stripWitnesses tree)) := by sorry

/-- D03: correspondence includes identity, exact fact, issuer, amount and custody. -/
theorem reachable_witness_bijection (s : State) : Reachable s → WitnessBacked s := by sorry

/-- D04: a consumer can use the fact without reading a moving registry output. -/
theorem live_witness_fact (s : State) (out : WitnessOutput) :
 Reachable s → out ∈ s.witnesses →
 out.token.cage = s.cage.id ∧ s.cage.trie out.token.key = out.token.data.fact ∧
 out.address = registryAddress ∧ out.value = out.token.data.deposit := by sorry

/-- D05: exact-value witnesses also certify presence. -/
theorem live_witness_presence (s : State) (out : WitnessOutput) (v : Val) :
 Reachable s → out ∈ s.witnesses → out.token.data.fact = some v →
 Condition.holds s.cage.trie (.present out.token.key) ∧
 Condition.holds s.cage.trie (.equals out.token.key v) := by sorry

/-- D06: the absence entry is logically absent, not an ordinary stored value. -/
theorem live_witness_absence (s : State) (out : WitnessOutput) :
 Reachable s → out ∈ s.witnesses → out.token.data.fact = none →
 Condition.holds s.cage.trie (.absent out.token.key) := by sorry

/-- D07: existing witnessed entries can never have two live outputs. -/
theorem one_live_witness_per_key (s : State) (a b : WitnessOutput) :
 Reachable s → a ∈ s.witnesses → b ∈ s.witnesses → a.token.key = b.token.key → a = b := by sorry

/-- D08: exact event proof, burn, refund and successor for each write. -/
theorem witnessed_write_obligation (tx : FoldTx) (n : Nat) (o : RequestOutput)
 (e : Selection) (w : WitnessData) : foldAccepted tx →
 tx.items[n]? = some (.write o e) →
 witnessAt (atTurn tx n).tree o.request.write.key = some w →
 itemChanges (atTurn tx n) (.write o e) o.request.write.key →
 ∃ event ∈ tx.witnessEvents,
 event.key = o.request.write.key ∧
 event.provedEntry = some (.witnessed w) ∧
 event.consumed = some (witnessOutput tx.cageIn.id o.request.write.key w) ∧
 ⟨w.refund, "", w.deposit⟩ ∈ tx.payments ∧
 (itemResult (atTurn tx n) (.write o e)).tree o.request.write.key =
 writeEntry o.request.write o.request.witnessing o.ref := by sorry

/-- D09: boundary token actions are exactly the net sequential obligations. -/
theorem fold_witness_boundary_exact (tx : FoldTx) : foldAccepted tx →
 tx.witnessEvents = foldWitnessEvents tx.cageIn tx.items ∧
 tx.witnessInputs = externalWitnessInputs tx.witnessEvents ∧
 tx.witnessOutputs = externalWitnessOutputs tx.witnessEvents ∧
 tx.witnessBurned = tx.witnessInputs.map WitnessOutput.token ∧
 tx.witnessMinted = tx.witnessOutputs.map WitnessOutput.token := by sorry

/-- D10: only a fold with a write to the old witness's own key spends it. -/
theorem witness_spent_only_at_own_key (s s' : State) (a : Action) (out : WitnessOutput) :
 Reachable s → Step s a s' → out ∈ s.witnesses → out ∉ s'.witnesses →
 ∃ (tx : FoldTx) (n : Nat) (o : RequestOutput) (e : Selection), a = .fold tx ∧ out ∈ tx.witnessInputs ∧ out.token ∈ tx.witnessBurned ∧
 tx.items[n]? = some (.write o e) ∧ o.request.write.key = out.token.key ∧
 itemChanges (atTurn tx n) (.write o e) out.token.key ∧
 ⟨out.token.data.refund, "", out.token.data.deposit⟩ ∈ tx.payments := by sorry

/-- D11: unrelated items preserve the exact UTxO including its deposit. -/
theorem untouched_witness_survives (s s' : State) (tx : FoldTx) (out : WitnessOutput) :
 Reachable s → Step s (.fold tx) s' → out ∈ s.witnesses →
 (∀ o e, FoldItem.write o e ∈ tx.items → o.request.write.key ≠ out.token.key) →
 out ∈ s'.witnesses ∧ out ∉ tx.witnessInputs ∧ out.token ∉ tx.witnessBurned ∧
 s'.cage.trie out.token.key = s.cage.trie out.token.key := by sorry

/-- D12: complete extraction item inversion, including its refusal domains. -/
theorem extraction_item_inversion (c : CageState) (iv : Interval) (o : Extraction) :
 extractionAllowed c iv o ↔
 o.cage = c.id ∧ c.minimum ≤ o.witness.deposit ∧ o.tokens = [requestName c.id] ∧
 o.policy = .release ∧ c.minimum ≤ o.value ∧ iv.valid ∧ iv.upper < o.deadline ∧
 witnessAt c.tree o.key = none ∧ c.trie o.key = o.wanted := by sorry

/-- D13: turn-specific value binding, not the fold's input root. -/
theorem extraction_attests_requested (tx : FoldTx) (n : Nat) (o : Extraction) :
 foldAccepted tx → tx.items[n]? = some (.extract o) →
 (atTurn tx n).trie o.key = o.wanted ∧
 witnessAt (atTurn tx n).tree o.key = none ∧
 witnessAt (itemResult (atTurn tx n) (.extract o)).tree o.key =
 some ⟨o.wanted,o.witness.refund,o.witness.deposit,o.ref⟩ ∧
 (itemResult (atTurn tx n) (.extract o)).trie = (atTurn tx n).trie := by sorry

/-- D14: extraction pays its ordinary remainder to the folder; its deposit is separate. -/
theorem extraction_normal_request_money (c : CageState) (o : Extraction) (folder : Signer) :
 itemCredits c (.extract o) = [] ∧ itemPayments c folder (.extract o) = [⟨folder,"",o.value⟩] ∧
 o.escrow = o.value + o.witness.deposit ∧
 (itemResult c (.extract o)).balances = c.balances ∧
 (itemResult c (.extract o)).value = c.value := by sorry

/-- D15: a fresh extraction needs no rule admission or creator signature. -/
theorem extraction_permissionless_creation (s : State) (o : Extraction) (sigs : List Signer) :
 extractionWellFormed s.cage o → o.ref ∉ s.usedOutputs →
 let tx : ExtractionCreateTx := ⟨s.cage, o, o.tokens, sigs⟩
 Step s (.extractionCreate tx) (afterExtractionCreate s tx) := by sorry

/-- D16: no approvals are needed even at a registry with oracles and a rule. -/
theorem extraction_permissionless_fold (s : State) (o : Extraction) (iv : Interval) (who : Signer) :
 Reachable s → o ∈ s.extractions → extractionAllowed s.cage iv o →
 let tx := singletonFold s iv [] (.extract o) who
 Step s (.fold tx) (afterFold s tx) := by sorry

/-- D17: extraction is refused on any currently witnessed key. -/
theorem extraction_witnessed_refused (c : CageState) (o : Extraction) (w : WitnessData) (iv : Interval) :
 witnessAt c.tree o.key = some w → ¬ extractionAllowed c iv o := by sorry

/-- D18: a stale value commitment cannot be folded. -/
theorem extraction_stale_refused (c : CageState) (o : Extraction) (iv : Interval) :
 c.trie o.key ≠ o.wanted → ¬ extractionAllowed c iv o := by sorry

/-- D19: a witnessing set replaces the old obligation and refunds its issuer. -/
theorem witnessing_set_replaces (tx : FoldTx) (n : Nat) (o : RequestOutput)
 (e : Selection) (k : Key) (v : Val) (spec : WitnessSpec) (old : WitnessData) :
 foldAccepted tx → tx.items[n]? = some (.write o e) → o.request.write = .set k v →
 o.request.witnessing = some spec → witnessAt (atTurn tx n).tree k = some old →
 witnessAt (itemResult (atTurn tx n) (.write o e)).tree k =
 some ⟨some v, spec.refund, spec.deposit, o.ref⟩ ∧
 itemChanges (atTurn tx n) (.write o e) k ∧
 itemWitnessRefunds (atTurn tx n) (.write o e) = [⟨old.refund, "", old.deposit⟩] := by sorry

/-- D20: value-changing plain set and unset remove the annotation. -/
theorem plain_write_clears_witness (c : CageState) (o : RequestOutput) (e : Selection) :
 o.request.witnessing = none → itemChanges c (.write o e) o.request.write.key →
 witnessAt (itemResult c (.write o e)).tree o.request.write.key = none ∧
 (itemResult c (.write o e)).trie = o.request.write.apply c.trie := by sorry

/-- D21: the complete deposit account, including transient issuances. -/
theorem fold_deposits_conserved (s s' : State) (tx : FoldTx) :
 Reachable s → Step s (.fold tx) s' →
 requestDepositInputs tx.items + witnessValue tx.witnessInputs =
 witnessValue tx.witnessOutputs + witnessRefundTotal s.cage tx.items + unusedDepositRefunds tx.items := by sorry

/-- D22: every finite census of witnessed keys yields exactly the live deposits. -/
theorem live_outputs_hold_deposits (s : State) (keys : List Key) :
 Reachable s → keys.Nodup →
 (∀ k, k ∈ keys ↔ ∃ w, witnessAt s.cage.tree k = some w) →
 witnessValue s.witnesses = entryDeposits s.cage.tree keys := by sorry

/-- D23: amounts and output placement cannot be chosen by a folder. -/
theorem witness_output_custody (s : State) (out : WitnessOutput) :
 Reachable s → out ∈ s.witnesses → out.address = registryAddress ∧
 out.value = out.token.data.deposit ∧ s.cage.minimum ≤ out.value := by sorry

/-- D24: a live witness originates on this exact reachable trace. -/
theorem witness_origin_on_trace (c : CageState) (existing : List CageId) (s : State)
 (events : List (State × Action × State)) (out : WitnessOutput) :
 registryCreated c existing → Trace (initial c) events s → out ∈ s.witnesses →
 ∃ before after tx, (before, Action.fold tx, after) ∈ events ∧
 Step before (.fold tx) after ∧ out ∈ tx.witnessOutputs ∧ out.token ∈ tx.witnessMinted := by sorry

/-- D25: extraction creation inversion exposes every constructor guard. -/
theorem extraction_creation_inversion (s s' : State) (tx : ExtractionCreateTx) :
 Step s (.extractionCreate tx) s' ↔
 tx.cageRef = s.cage ∧ tx.output.cage = s.cage.id ∧ s.cage.minimum ≤ tx.output.witness.deposit ∧
 tx.output.tokens = [requestName s.cage.id] ∧ tx.output.policy = .release ∧ s.cage.minimum ≤ tx.output.value ∧
 tx.minted = tx.output.tokens ∧ tx.output.ref ∉ s.usedOutputs ∧ s' = afterExtractionCreate s tx := by sorry

/-- D26: complete account has no oracle condition and returns the unused deposit. -/
theorem extraction_account_inversion (c : CageState) (iv : Interval) (o : Extraction) (who : Signer) :
 extractionAccountAllowed c iv o ↔
 o.cage = c.id ∧ c.minimum ≤ o.witness.deposit ∧ o.tokens = [requestName c.id] ∧
 o.policy = .release ∧ c.minimum ≤ o.value ∧ iv.valid ∧ o.deadline ≤ iv.lower ∧ iv.upper ≤ o.deadline + o.window ∧
 itemResult c (.extractAccount o) = c ∧
 itemPayments c who (.extractAccount o) = [⟨o.owner, "", o.value⟩, ⟨o.owner, "", o.witness.deposit⟩] := by sorry

/-- D27: owner withdrawal is strictly after the window and returns everything. -/
theorem extraction_withdrawal_inversion (s s' : State) (tx : ExtractionWithdrawTx) :
 Step s (.extractionWithdraw tx) s' ↔ tx.input ∈ s.extractions ∧
 tx.interval.valid ∧ tx.input.deadline + tx.input.window < tx.interval.lower ∧
 tx.input.owner ∈ tx.signers ∧ tx.burned = tx.input.tokens ∧ tx.beneficiary = tx.input.owner ∧
 tx.paid = tx.input.escrow ∧ s' = afterExtractionWithdraw s tx := by sorry

/-- D28: actual extraction spends are confined to exactly their named windows. -/
theorem extraction_exit_window (o : Extraction) (spend : ExtractionSpend) (kind : ExitKind) :
 extractionSpendAllowed o spend → spend.exitsAs o kind → extractionExitAt o spend.interval kind := by sorry

/-- D29: same-time exits cannot race. -/
theorem extraction_exit_exclusive (o : Extraction) (a b : ExtractionSpend) (ka kb : ExitKind) :
 extractionSpendAllowed o a → extractionSpendAllowed o b → a.interval = b.interval →
 a.exitsAs o ka → b.exitsAs o kb → ka = kb := by sorry

/-- D30: no unclassified or unburned removal of an extraction. -/
theorem extraction_removal_legal (s s' : State) (a : Action) (o : Extraction) :
 Step s a s' → o ∈ s.extractions → o ∉ s'.extractions →
 (∃ tx, a = .fold tx ∧ foldAccepted tx ∧ o ∈ tx.extractions ∧
 (∀ token ∈ o.tokens, token ∈ tx.burned) ∧ s' = afterFold s tx) ∨
 (∃ tx, a = .extractionWithdraw tx ∧ tx.input = o ∧ extractionWithdrawAllowed tx ∧
 s' = afterExtractionWithdraw s tx) := by sorry

/-- D31: extraction tokens authenticate the live inventory and support discovery. -/
theorem extraction_discovery_exact (s : State) (o : Extraction) : Reachable s →
 (o ∈ discoverExtractions s.cage.id s.extractions ↔ o ∈ s.extractions) ∧
 (o ∈ s.extractions → extractionWellFormed s.cage o) := by sorry

/-- D32: witnessing deposits are funded separately and cannot witness an unset. -/
theorem witnessing_creation_funded (s s' : State) (tx : CreateTx) (o : RequestOutput) (spec : WitnessSpec) :
 Step s (.create tx o) s' → o.request.witnessing = some spec →
 s.cage.minimum ≤ spec.deposit ∧ (∃ k v, o.request.write = .set k v) ∧
 totalFees s.cage o.request + s.cage.minimum + spec.deposit ≤ o.escrow := by sorry

/-- D33: unused witnessing deposits belong to the request owner. -/
theorem unused_witnessing_deposit_returned (tx : FoldTx) (n : Nat) (o : RequestOutput)
 (e : Selection) (spec : WitnessSpec) : foldAccepted tx →
 tx.items[n]? = some (.account o e) → o.request.witnessing = some spec →
 itemPayments (atTurn tx n) tx.folder (.account o e) =
 [⟨o.request.owner, "", remainder (atTurn tx n) o⟩, ⟨o.request.owner, "", spec.deposit⟩] := by sorry

/-- D34: issuance identity prevents reuse even when every other field matches. -/
theorem witness_token_issuance_bound (c : CageId) (k : Key) (fact : Option Val)
 (refund : String) (deposit : Nat) (a b : OutputRef) :
 (witnessOutput c k ⟨fact,refund,deposit,a⟩).token =
 (witnessOutput c k ⟨fact,refund,deposit,b⟩).token ↔ a = b := by sorry

/-- D35: newly created and consumed obligations net out, preserving refunds. -/
theorem transient_witness_nets (tx : FoldTx) (out : WitnessOutput) :
 foldAccepted tx → out ∈ tx.witnessEvents.filterMap WitnessEvent.produced →
 out ∈ tx.witnessEvents.filterMap WitnessEvent.consumed →
 out ∉ tx.witnessInputs ∧ out ∉ tx.witnessOutputs ∧
 ⟨out.token.data.refund, "", out.value⟩ ∈ tx.payments := by sorry

/-- D36: output changes can only originate in an accepted fold. -/
theorem only_fold_changes_witnesses (s s' : State) (a : Action) :
 Step s a s' → s'.witnesses ≠ s.witnesses →
 ∃ tx, a = .fold tx ∧ foldAccepted tx ∧ s' = afterFold s tx := by sorry

/-- D37: extraction exits cover all point times under their non-time guards. -/
theorem extraction_windows_cover (o : Extraction) (now : Time) :
 extractionExitAt o ⟨now,now⟩ .write ∨ extractionExitAt o ⟨now,now⟩ .account ∨
 extractionExitAt o ⟨now,now⟩ .withdraw := by sorry

/-- D38: extraction has the same nonoverlapping scalar partition. -/
theorem extraction_windows_disjoint (o : Extraction) (iv : Interval) (a b : ExitKind) :
 extractionExitAt o iv a → extractionExitAt o iv b → a = b := by sorry

/-- D39: failed extractions can settle without oracle or rule participation. -/
theorem extraction_later_exits_available (s : State) (o : Extraction) (iv : Interval) (who : Signer) :
 o ∈ s.extractions → extractionWellFormed s.cage o → iv.valid →
 (o.deadline ≤ iv.lower → iv.upper ≤ o.deadline + o.window →
 let tx := singletonFold s iv [] (.extractAccount o) who
 Step s (.fold tx) (afterFold s tx)) ∧
 (o.deadline + o.window < iv.lower →
 let tx : ExtractionWithdrawTx := ⟨o,iv,[o.owner],o.tokens,o.owner,o.escrow⟩
 Step s (.extractionWithdraw tx) (afterExtractionWithdraw s tx)) := by sorry

/-- D40: all data and evidence bindings of an accepted witnessing write. -/
theorem write_item_inversion (c : CageState) (iv : Interval) (refs : List TokenName)
 (sigs : List Signer) (o : RequestOutput) (e : Selection) :
 itemAllowed c iv refs sigs (.write o e) ↔
 (o.request.witnessing = none ∨ witnessAt c.tree o.request.write.key = none ∨
  c.trie o.request.write.key ≠ o.request.write.value) ∧
 o.request.cage = c.id ∧ o.tags = c.oracles.map tagName ∧
 totalFees c o.request + c.minimum ≤ o.value ∧
 o.requestTokens = [requestName c.id] ∧ o.policy = requestPolicy c ∧ o.request.witnessValid c.minimum ∧
 iv.valid ∧ iv.upper < o.request.deadline ∧ hasApproval c o.request refs sigs e ∧
 (∀ condition ∈ o.request.conditions, condition.holds c.trie) ∧
 (∀ oracle ∈ c.oracles, ∀ condition ∈ (e oracle).conditions, condition.holds c.trie) := by sorry

/-- D41: all live input classes share one spent-once output namespace. -/
theorem reachable_input_refs_unique (s : State) : Reachable s →
 (s.live.map RequestOutput.ref ++ s.claims.map ClaimOutput.ref ++ s.extractions.map Extraction.ref).Nodup ∧
 (∀ o ∈ s.extractions, o.ref ∈ s.usedOutputs) := by sorry

/-- D42: a value-changing item must spend the pre-existing witness of its key. -/
theorem touched_old_witness_burned (s s' : State) (tx : FoldTx) (old : WitnessOutput)
 (o : RequestOutput) (e : Selection) (n : Nat) :
 Reachable s → Step s (.fold tx) s' → old ∈ s.witnesses →
 tx.items[n]? = some (.write o e) → o.request.write.key = old.token.key →
 itemChanges (atTurn tx n) (.write o e) old.token.key →
 old ∈ tx.witnessInputs ∧ old.token ∈ tx.witnessBurned ∧ old ∉ s'.witnesses ∧
 ⟨old.token.data.refund, "", old.value⟩ ∈ tx.payments := by sorry

/-- D43: no counterfeit witness input can enter a fold. -/
theorem fold_witness_inputs_authentic (s s' : State) (tx : FoldTx) :
 Step s (.fold tx) s' → (∀ w ∈ tx.witnessInputs, w ∈ s.witnesses) ∧
 (∀ o ∈ tx.extractions, o ∈ s.extractions) := by sorry

/-- D44: uniqueness on the state's own creation history, with no free history. -/
theorem requests_unique_on_trace (c : CageState) (existing : List CageId) (s : State)
 (events : List (State × Action × State)) (beforeA afterA beforeB afterB : State)
 (a b : CreateTx) (oa ob : RequestOutput) :
 registryCreated c existing → Trace (initial c) events s →
 (beforeA,Action.create a oa,afterA) ∈ events → (beforeB,Action.create b ob,afterB) ∈ events →
 a.cageRef.oracles ≠ [] → b.cageRef.oracles ≠ [] → a ≠ b → oa.request ≠ ob.request := by sorry

/-- D45: a reference returns exactly the live fact without a spend transition. -/
theorem witness_reference_sound (s : State) (out : WitnessOutput) (w : WitnessData) :
 Reachable s → (referenceWitness s out = some w ↔ out ∈ s.witnesses ∧ w = out.token.data) ∧
 (referenceWitness s out = some w → s.cage.trie out.token.key = w.fact) := by sorry

/-- D46: the burn/change equivalence is exact at the item's turn. -/
theorem item_burn_iff_value_change (c : CageState) (iv : Interval) (refs : List TokenName)
 (sigs : List Signer) (i : FoldItem) (k : Key) (w : WitnessData) :
 itemAllowed c iv refs sigs i → witnessAt c.tree k = some w →
 ((∃ event ∈ itemWitnessEvents c i,
   event.key = k ∧ event.consumed = some (witnessOutput c.id k w)) ↔ itemChanges c i k) ∧
 (itemChanges c i k → itemWitnessRefunds c i = [⟨w.refund,"",w.deposit⟩]) := by sorry

/-- D47: no value-changing item means exact witness, token, custody and deposit preservation. -/
theorem witness_durability (s s' : State) (a : Action) (out : WitnessOutput) :
 Reachable s → Step s a s' → out ∈ s.witnesses → actionPreservesKey a out.token.key →
 out ∈ s'.witnesses ∧ witnessAt s'.cage.tree out.token.key = witnessAt s.cage.tree out.token.key ∧
 s'.cage.trie out.token.key = s.cage.trie out.token.key ∧
 (∀ tx, a = .fold tx → out ∉ tx.witnessInputs ∧ out.token ∉ tx.witnessBurned) := by sorry

/-- D48: plain same-value set and already-absent unset retain the complete encoded tree. -/
theorem plain_noop_preserves_witness (c : CageState) (o : RequestOutput) (e : Selection) :
 o.request.witnessing = none → c.trie o.request.write.key = o.request.write.value →
 (itemResult c (.write o e)).tree = c.tree ∧
 itemWitnessEvents c (.write o e) = [] ∧ itemWitnessRefunds c (.write o e) = [] := by sorry

/-- D49: an issuer cannot replace a witness via a same-value witnessing set. -/
theorem witnessing_noop_refused (c : CageState) (o : RequestOutput) (e : Selection)
 (iv : Interval) (refs : List TokenName) (sigs : List Signer) (w : WitnessData) (spec : WitnessSpec) :
 witnessAt c.tree o.request.write.key = some w → o.request.witnessing = some spec →
 c.trie o.request.write.key = o.request.write.value → ¬ stepValid c iv refs sigs e o := by sorry

/-- D50: live deposits have no issuer, signature or timeout exit (NOTE-003).
The same exact output includes its address, token and deposit; any release must
occur at an indexed value-changing event and pay exactly the recorded refund. -/
theorem witness_deposit_lock (s s' : State) (a : Action) (out : WitnessOutput) :
 Reachable s → Step s a s' → out ∈ s.witnesses →
 (out ∉ s'.witnesses ∨ ∃ tx, a = .fold tx ∧ out ∈ tx.witnessInputs) →
 ∃ (tx : FoldTx) (n : Nat) (i : FoldItem) (event : WitnessEvent),
 a = .fold tx ∧ tx.items[n]? = some i ∧ itemChanges (atTurn tx n) i out.token.key ∧
 event ∈ itemWitnessEvents (atTurn tx n) i ∧ event.key = out.token.key ∧
 event.consumed = some out ∧ out.token ∈ tx.witnessBurned ∧
 ⟨out.token.data.refund,"",out.token.data.deposit⟩ ∈ itemWitnessRefunds (atTurn tx n) i ∧
 ⟨out.token.data.refund,"",out.token.data.deposit⟩ ∈ tx.payments := by sorry

/-- D51: witnessing blind writes expose the sole additional tree-sensitive refusal. -/
theorem witnessing_blind_write_availability (c : CageState) (iv : Interval) (refs : List TokenName)
 (sigs : List Signer) (o : RequestOutput) (e : Selection) (t : EntryTree) :
 wellFormed c o → iv.valid → iv.upper < o.request.deadline → hasApproval c o.request refs sigs e →
 o.request.conditions = [] → (∀ oracle ∈ c.oracles, (e oracle).conditions = []) →
 witnessWriteAllowed { c with tree := t } o.request →
 FoldRun iv refs sigs { c with tree := t } [.write o e]
 (itemResult { c with tree := t } (.write o e)) ∧
 (itemResult { c with tree := t } (.write o e)).trie = o.request.write.apply (logicalTree t) := by sorry

/-- D52: withdrawal consumes the one authentic extraction from a reachable inventory. -/
theorem extraction_exits_remove_consumed (s s' : State) (tx : ExtractionWithdrawTx) :
 Reachable s → Step s (.extractionWithdraw tx) s' → tx.input ∉ s'.extractions := by sorry

/-- D53: application and complete account both remove every folded extraction. -/
theorem extraction_fold_removes_consumed (s : State) (tx : FoldTx) (o : Extraction) :
 o ∈ tx.extractions → o ∉ (afterFold s tx).extractions := by sorry

/-- D54: a used extraction reference cannot return after it has left the inventory. -/
theorem extraction_never_reappears (s s' : State) (o : Extraction) :
 Reachable s → o.ref ∈ s.usedOutputs → o ∉ s.extractions → History s s' →
 o ∉ s'.extractions := by sorry

/-- D55: all three consumption routes are terminal on the actual successor history. -/
theorem extraction_consumption_terminal (s t u : State) (a : Action) (o : Extraction) :
 Reachable s → Step s a t →
 ((∃ tx, a = .fold tx ∧ o ∈ tx.extractions) ∨
  (∃ tx, a = .extractionWithdraw tx ∧ tx.input = o)) →
 History t u → o ∉ t.extractions ∧ o ∉ u.extractions := by sorry

/-- D56: account exposes all well-formedness, witness funding, time and evidence guards. -/
theorem account_item_inversion (c : CageState) (iv : Interval) (refs : List TokenName)
 (sigs : List Signer) (o : RequestOutput) (e : Selection) :
 itemAllowed c iv refs sigs (.account o e) ↔
 o.request.cage = c.id ∧ o.tags = c.oracles.map tagName ∧
 totalFees c o.request + c.minimum ≤ o.value ∧
 o.requestTokens = [requestName c.id] ∧ o.policy = requestPolicy c ∧
 (match o.request.witnessing with
  | none => True
  | some spec => c.minimum ≤ spec.deposit ∧ ∃ k v, o.request.write = .set k v) ∧
 iv.valid ∧ o.request.deadline ≤ iv.lower ∧ iv.upper ≤ o.request.deadline + o.request.window ∧
 hasAccount c o.request refs e := by sorry

/-- D57: witness events are concatenated in indexed item order, each computed at
its own turn. This specification does not call foldWitnessEvents. -/
theorem fold_witness_events_in_item_order (tx : FoldTx) :
 foldAccepted tx → tx.witnessEvents =
 tx.items.zipIdx.flatMap (fun p => itemWitnessEvents (atTurn tx p.2) p.1) := by sorry

end RequestApprovalFold
