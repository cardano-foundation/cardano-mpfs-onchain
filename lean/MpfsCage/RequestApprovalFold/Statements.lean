import MpfsCage.RequestApprovalFold.Model

namespace RequestApprovalFold

/-! Statements frozen together before PROOFS. The ledger names each row's
    reachable antecedent example and proposed single-definition mutant. -/

theorem applyAll_append (t : Trie) (xs ys : List Write) :
    applyAll t (xs ++ ys) = applyAll (applyAll t xs) ys := by
  sorry

theorem foldRun_step_valid {c : CageState} {now : Time} {refs : List TokenName}
    {signers : List Signer} {t t' : Trie} {os : List RequestOutput}
    (h : FoldRun c now refs signers t os t') :
    ∀ o ∈ os, ∃ t0, stepValid c now refs signers t0 o := by
  sorry

theorem foldRun_result {c : CageState} {now : Time} {refs : List TokenName}
    {signers : List Signer} {t t' : Trie} {os : List RequestOutput}
    (h : FoldRun c now refs signers t os t') :
    t' = applyAll t (os.map (·.request.write)) := by
  sorry

theorem foldRun_conditions {c : CageState} {now : Time} {refs : List TokenName}
    {signers : List Signer} {t t' : Trie} {os : List RequestOutput}
    (h : FoldRun c now refs signers t os t') :
    ∀ (n : Nat) (o : RequestOutput), os[n]? = some o → ∀ condition ∈ o.request.conditions,
      condition.holds (applyAll t ((os.take n).map (·.request.write))) := by
  sorry

theorem applyAll_keeps_present (k : Key) :
    ∀ (ws : List Write) (t : Trie), (∀ w ∈ ws, w ≠ .unset k) →
      (t k).isSome → (applyAll t ws k).isSome := by
  sorry

theorem registry_creation (c : CageState) (existing : List CageId) :
    registryCreated c existing → c.id ∉ existing ∧ c.oracles ≠ [] ∧
      c.oracles.Nodup ∧ c.trie = emptyTrie := by
  sorry

theorem create_tags_existing_cage (tx : CreateTx) (o : RequestOutput) :
    createAllowed tx o → tx.outputs = [o] ∧
      tx.cageRef.id = o.request.cage ∧
      tx.minted = [tagName o.request.cage] ∧
      o.tags = [tagName o.request.cage] ∧ o.request.seed ∈ tx.spent ∧
      totalFees tx.cageRef o.request ≤ o.value := by
  sorry

theorem requests_unique_in_history (history : List CreateTx)
    (a b : CreateTx) (oa ob : RequestOutput) :
    SpentOnce history → a ∈ history → b ∈ history →
    createAllowed a oa → createAllowed b ob → a ≠ b →
    oa.request ≠ ob.request := by
  sorry

theorem judgment_authorized_and_bound (tx : JudgmentTx) :
    judgmentAllowed tx → tx.oracle ∈ tx.cageRef.oracles ∧
      tx.oracle ∈ tx.signers ∧ tx.requestRef.request.cage = tx.cageRef.id ∧
      tx.now < tx.requestRef.request.deadline ∧ tx.spent = [] ∧
      tx.minted = [judgmentName tx.cageRef.id tx.requestRef.request tx.oracle tx.approve] := by
  sorry

theorem judgment_not_replayable (c c' : CageId) (r r' : Request)
    (oracle oracle' : Signer) (verdict verdict' : Bool) :
    judgmentName c r oracle verdict = judgmentName c' r' oracle' verdict' →
      c = c' ∧ r = r' ∧ r.seed = r'.seed ∧ oracle = oracle' ∧ verdict = verdict' := by
  sorry

theorem token_roles_separated (c c' : CageId) (r : Request)
    (oracle : Signer) (verdict : Bool) :
    tagName c ≠ judgmentName c' r oracle verdict := by
  sorry

theorem fold_preserves_registry (tx : FoldTx) :
    foldAccepted tx → tx.cageOut.id = tx.cageIn.id ∧
      tx.cageOut.oracles = tx.cageIn.oracles ∧
      tx.cageOut.protocol = tx.cageIn.protocol := by
  sorry

theorem step_preserves_registry {s s' : State} (h : Step s s') :
    s'.cage.id = s.cage.id ∧ s'.cage.oracles = s.cage.oracles ∧
      s'.cage.protocol = s.cage.protocol := by
  sorry

theorem history_preserves_registry {s s' : State} (h : History s s') :
    s'.cage.id = s.cage.id ∧ s'.cage.oracles = s.cage.oracles ∧
      s'.cage.protocol = s.cage.protocol := by
  sorry

theorem only_fold_changes_tree {s s' : State} (h : Step s s') :
    s'.cage.trie ≠ s.cage.trie →
      ∃ tx, foldAccepted tx ∧ tx.cageIn = s.cage ∧ s' = afterFold s tx := by
  sorry

theorem fold_only_approved_before_deadline (tx : FoldTx) :
    foldAccepted tx → ∀ o ∈ tx.requests,
      o.request.cage = tx.cageIn.id ∧ tx.now < o.request.deadline ∧
      hasApproval tx.cageIn o.request tx.refs tx.signers := by
  sorry

theorem fold_conditions_hold_when_applied (tx : FoldTx) :
    foldAccepted tx → ∀ (n : Nat) (o : RequestOutput), tx.requests[n]? = some o →
      ∀ condition ∈ o.request.conditions,
        condition.holds (applyAll tx.cageIn.trie
          ((tx.requests.take n).map (·.request.write))) := by
  sorry

theorem fold_root_is_folded_writes (tx : FoldTx) :
    foldAccepted tx → tx.cageOut.trie =
      applyAll tx.cageIn.trie (tx.requests.map (·.request.write)) := by
  sorry

theorem fold_burns_tags (tx : FoldTx) :
    foldAccepted tx → tx.burned = tx.requests.flatMap tokensOf := by
  sorry

theorem fold_pays_and_keeps_rest (tx : FoldTx) :
    foldAccepted tx → ∀ o ∈ tx.requests,
      allocation tx.cageIn o tx.folder ∈ tx.allocations ∧
      ∀ oracle ∈ tx.cageIn.oracles,
        (oracle, o.request.fee oracle) ∈ (allocation tx.cageIn o tx.folder).oracles := by
  sorry

theorem allocation_conserves_value (c : CageState) (o : RequestOutput) (to : Signer) :
    wellFormed c o →
      ((allocation c o to).oracles.map Prod.snd).sum +
        (allocation c o to).remainder = o.value := by
  sorry

theorem blind_write_folds_on_any_tree (c : CageState) (now : Time)
    (refs : List TokenName) (signers : List Signer) (o : RequestOutput) (t : Trie) :
    wellFormed c o → now < o.request.deadline →
    hasApproval c o.request refs signers → o.request.conditions = [] →
    FoldRun c now refs signers t [o] (o.request.write.apply t) := by
  sorry

theorem fold_permissionless (tx : FoldTx) (other : Signer) :
    foldAccepted tx → foldAccepted { tx with submitter := other } := by
  sorry

/-- An accepted prefix ending in a set cannot reach a later absent condition
    without an intervening unset. `middle` is the exact intervening segment. -/
theorem absent_inserts_exclusive (c : CageState) (now : Time)
    (refs : List TokenName) (signers : List Signer) (t t' : Trie)
    (a b : RequestOutput) (middle tail : List RequestOutput) (k : Key) (v : Val) :
    FoldRun c now refs signers t (a :: (middle ++ b :: tail)) t' →
    a.request.write = .set k v → Condition.absent k ∈ b.request.conditions →
    ∃ q ∈ middle, q.request.write = .unset k := by
  sorry

theorem account_complete_and_pays (tx : AccountTx) :
    accountAllowed tx → hasAccount tx.cageRef tx.input.request tx.refs ∧
      tx.burned = tokensOf tx.input ∧
      tx.paid = allocation tx.cageRef tx.input tx.input.request.owner := by
  sorry

theorem account_anyone_anytime (tx : AccountTx) (now : Time) (other : Signer) :
    accountAllowed tx → accountAllowed { tx with now := now, submitter := other } := by
  sorry

theorem account_fee_neutral (a b : AccountTx) :
    accountAllowed a → accountAllowed b →
    a.cageRef = b.cageRef → a.input = b.input → a.paid = b.paid := by
  sorry

theorem withdraw_only_owner_after_window (tx : WithdrawTx) :
    withdrawAllowed tx → tx.input.request.owner ∈ tx.signers ∧
      tx.input.request.deadline + tx.input.request.window < tx.now ∧
      tx.burned = tokensOf tx.input ∧ tx.beneficiary = tx.input.request.owner ∧
      tx.paid = tx.input.value := by
  sorry

theorem owner_can_withdraw_everything (o : RequestOutput) (now : Time) :
    o.request.deadline + o.request.window < now →
    withdrawAllowed ⟨o, now, [o.request.owner], tokensOf o, o.request.owner, o.value⟩ := by
  sorry

theorem request_spent_only_by_lifecycle (o : RequestOutput) (spend : RequestSpend) :
    requestSpendAllowed o spend →
      (∃ tx, spend = .folded tx ∧ foldAccepted tx ∧ o ∈ tx.requests) ∨
      (∃ tx, spend = .accounted tx ∧ accountAllowed tx ∧ tx.input = o) ∨
      (∃ tx, spend = .withdrawn tx ∧ withdrawAllowed tx ∧ tx.input = o) := by
  sorry

theorem every_exit_burns_tag (o : RequestOutput) (spend : RequestSpend) :
    requestSpendAllowed o spend → ∀ tag ∈ tokensOf o, tag ∈ spend.burned := by
  sorry

theorem early_exit_requires_all_judgments (o : RequestOutput) (spend : RequestSpend) :
    requestSpendAllowed o spend → spend.now ≤ o.request.deadline + o.request.window →
    ∃ c, spend.cage = some c ∧
      ∀ oracle ∈ c.oracles, spend.evidence o.request oracle := by
  sorry

/-- Stronger than the approved-oracle guarantee: every oracle is paid on
    every early exit, even without non-equivocation. -/
theorem early_exit_pays_every_oracle (o : RequestOutput) (spend : RequestSpend) :
    requestSpendAllowed o spend → spend.now ≤ o.request.deadline + o.request.window →
    ∃ c, spend.cage = some c ∧
      ∀ oracle ∈ c.oracles, spend.pays c o oracle := by
  sorry

/-- Non-equivocation additionally forces an issued approval to be disclosed
    in a complete account; it cannot be substituted with a refusal. -/
theorem owner_cannot_hide_approval (tx : AccountTx) (issued : List TokenName)
    (oracle : Signer) :
    accountAllowed tx → NonEquivocating issued →
    (∀ name ∈ tx.refs, name ∈ issued) → oracle ∈ tx.cageRef.oracles →
    judgmentName tx.cageRef.id tx.input.request oracle true ∈ issued →
    judgmentName tx.cageRef.id tx.input.request oracle true ∈ tx.refs := by
  sorry

theorem dead_judgment_can_burn (s : State) (c : CageId) (r : Request)
    (oracle : Signer) (verdict : Bool) :
    judgmentName c r oracle verdict ∈ s.judgments →
    (∀ o ∈ s.live, o.request ≠ r) →
    Step s (afterBurn s (judgmentName c r oracle verdict)) ∧
      (afterBurn s (judgmentName c r oracle verdict)).live = s.live ∧
      (afterBurn s (judgmentName c r oracle verdict)).cage = s.cage := by
  sorry

theorem judgments_do_not_consume (s : State) (tx : JudgmentTx) :
    (afterJudgment s tx).live = s.live ∧ (afterJudgment s tx).cage = s.cage := by
  sorry

theorem exits_remove_consumed (s : State) (o : RequestOutput) :
    o ∉ (afterExit s o).live := by
  sorry

theorem fold_removes_consumed (s : State) (tx : FoldTx) (o : RequestOutput) :
    o ∈ tx.requests → o ∉ (afterFold s tx).live := by
  sorry

theorem used_seeds_monotone {s s' : State} (h : Step s s') :
    ∀ seed ∈ s.usedSeeds, seed ∈ s'.usedSeeds := by
  sorry

theorem reachable_requests_have_spent_seeds (s : State) :
    Reachable s → ∀ o ∈ s.live, o.request.seed ∈ s.usedSeeds := by
  sorry

theorem spent_seed_cannot_create_again (s : State) (tx : CreateTx) (o : RequestOutput) :
    o.request.seed ∈ s.usedSeeds → createAllowed tx o →
    ¬ (∀ seed ∈ tx.spent, seed ∉ s.usedSeeds) := by
  sorry

/-- A consumed live request is never live again along a subsequent history. -/
theorem request_never_reappears (s s' : State) (o : RequestOutput) :
    History s s' → o.request.seed ∈ s.usedSeeds → o ∉ s.live → o ∉ s'.live := by
  sorry

theorem one_oracle_signature_suffices (c : CageState) (r : Request) (oracle : Signer) :
    c.oracles = [oracle] → hasApproval c r [] [oracle] := by
  sorry

theorem old_operations_correspond (op : OldOperation) (t : Trie) :
    op.write.apply t = op.apply t ∧
      (match op with
       | .insert k _ => op.condition.holds t ↔ t k = none
       | .delete k v => op.condition.holds t ↔ t k = some v
       | .update k v _ => op.condition.holds t ↔ t k = some v) := by
  sorry

/-- Inversion at the authoritative state machine: disappearance is an exit,
    not merely an arbitrary externally supplied RequestSpend value. -/
theorem live_removal_is_legal_exit {s s' : State} (h : Step s s') (o : RequestOutput) :
    o ∈ s.live → o ∉ s'.live → ∃ spend, requestSpendAllowed o spend := by
  sorry

theorem new_judgment_is_authorized {s s' : State} (h : Step s s') (name : TokenName) :
    name ∈ s'.issued → name ∉ s.issued →
    ∃ tx, judgmentAllowed tx ∧ tx.cageRef = s.cage ∧
      tx.requestRef ∈ s.live ∧ name ∈ tx.minted := by
  sorry

end RequestApprovalFold
