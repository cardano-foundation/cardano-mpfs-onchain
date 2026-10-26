import MpfsCage.RequestApprovalFold.Witnesses

namespace RequestApprovalFold

/-- The time of the supplied transaction determines its only possible exit. -/
theorem exit_time_window (o : RequestOutput) (spend : RequestSpend) :
    requestSpendAllowed o spend →
    match spend with
    | .folded tx => tx.now < o.request.deadline
    | .accounted tx => o.request.deadline ≤ tx.now ∧
        tx.now ≤ o.request.deadline + o.request.window
    | .withdrawn tx => o.request.deadline + o.request.window < tx.now := by
  sorry

/-- This partitions time, not availability: missing evidence can still block an exit. -/
theorem exit_windows_cover (r : Request) (now : Time) :
    now < r.deadline ∨
    (r.deadline ≤ now ∧ now ≤ r.deadline + r.window) ∨
    r.deadline + r.window < now := by
  sorry

/-- Two allowed spends of the same output at the same time have the same exit kind. -/
theorem exit_kind_unique (o : RequestOutput) (a b : RequestSpend) :
    requestSpendAllowed o a → requestSpendAllowed o b → a.now = b.now →
    (match a, b with
     | .folded _, .folded _ => True
     | .accounted _, .accounted _ => True
     | .withdrawn _, .withdrawn _ => True
     | _, _ => False) := by
  sorry

theorem fold_references_authentic {s s' : State} (tx : FoldTx) :
    Step s (.fold tx) s' → ∀ name ∈ tx.refs, name ∈ s.judgments := by
  sorry

theorem account_references_authentic {s s' : State} (tx : AccountTx) :
    Step s (.account tx) s' → ∀ name ∈ tx.refs, name ∈ s.judgments := by
  sorry

theorem creation_references_source {s s' : State} (tx : CreateTx) (o : RequestOutput) :
    Step s (.create tx o) s' → tx.cageRef = s.cage ∧ o.request.cage = s.cage.id := by
  sorry

/-- Expected fees are read directly from the declared fee entries, independently
    of Request.fee, totalFees, oraclePayments and allocation. The whole allocation
    list is fixed, so this also excludes extra or redirected payments. -/
theorem fold_payments_concrete (tx : FoldTx) :
    foldAccepted tx → tx.allocations = tx.requests.map (fun o =>
      { input := o
        oracles := tx.cageIn.oracles.map (fun oracle =>
          (oracle, ((o.request.fees.find? (fun p => p.1 == oracle)).map Prod.snd).getD 0))
        beneficiary := tx.folder
        remainder := o.value - (tx.cageIn.oracles.map (fun oracle =>
          ((o.request.fees.find? (fun p => p.1 == oracle)).map Prod.snd).getD 0)).sum }) := by
  sorry

theorem account_payments_concrete (tx : AccountTx) :
    accountAllowed tx →
    tx.paid.input = tx.input ∧
    tx.paid.oracles = tx.cageRef.oracles.map (fun oracle =>
      (oracle, ((tx.input.request.fees.find? (fun p => p.1 == oracle)).map Prod.snd).getD 0)) ∧
    tx.paid.beneficiary = tx.input.request.owner ∧
    tx.paid.remainder = tx.input.value - (tx.cageRef.oracles.map (fun oracle =>
      ((tx.input.request.fees.find? (fun p => p.1 == oracle)).map Prod.snd).getD 0)).sum := by
  sorry

theorem creation_funds_declared_fees {s s' : State} (tx : CreateTx) (o : RequestOutput) :
    Step s (.create tx o) s' →
    (s.cage.oracles.map (fun oracle =>
      ((o.request.fees.find? (fun p => p.1 == oracle)).map Prod.snd).getD 0)).sum ≤ o.value := by
  sorry

/-- Minting can repeat a name. Burning one token decreases its multiplicity by
    exactly one; it does not erase another token with the same name. -/
theorem burn_removes_one {s s' : State} (name : TokenName) :
    Step s (.burn name) s' → s'.judgments.count name + 1 = s.judgments.count name := by
  sorry

theorem burn_keeps_history {s s' : State} (name : TokenName) :
    Step s (.burn name) s' → s'.issued = s.issued := by
  sorry

theorem fold_requests_unique (tx : FoldTx) :
    foldAccepted tx → tx.requests.Nodup := by
  sorry

/-- Every verdict assignment, including refusals, is usable in the account
    window when all of its genuinely minted judgments are supplied. -/
theorem account_accepts_any_verdicts (s : State) (o : RequestOutput)
    (verdict : Signer → Bool) (conditions : Signer → List Condition) (now : Time) (submitter : Signer) :
    o ∈ s.live → wellFormed s.cage o →
    (∀ oracle ∈ s.cage.oracles,
      judgmentName s.cage.id o.request oracle (verdict oracle) (conditions oracle) ∈ s.judgments) →
    o.request.deadline ≤ now → now ≤ o.request.deadline + o.request.window →
    Step s (.account ⟨s.cage, o,
      s.cage.oracles.map (fun oracle => judgmentName s.cage.id o.request oracle (verdict oracle) (conditions oracle)),
      now, submitter, tokensOf o, allocation s.cage o o.request.owner⟩) (afterExit s o) := by
  sorry

/-- Both conflicting judgments coexist in a reachable state's holdings and
    permanent mint record; minting does not enforce non-equivocation. -/
theorem equivocation_reachable :
    ∃ (s : State) (o : RequestOutput) (oracle : Signer),
      Reachable s ∧ o ∈ s.live ∧ oracle ∈ s.cage.oracles ∧
      judgmentName s.cage.id o.request oracle true ∈ s.judgments ∧
      judgmentName s.cage.id o.request oracle false ∈ s.judgments ∧
      judgmentName s.cage.id o.request oracle true ∈ s.issued ∧
      judgmentName s.cage.id o.request oracle false ∈ s.issued := by
  sorry

end RequestApprovalFold
