import MpfsCage.RequestApprovalFold.Repairs

namespace RequestApprovalFold.Witnesses

-- W47: all three actual exits, on reached sources, meet their respective windows.
example : Reachable s3 ∧ Reachable mixed ∧ Reachable s1 ∧
    requestSpendAllowed output (.folded fold) ∧
    requestSpendAllowed output (.accounted (account false)) ∧
    requestSpendAllowed output (.withdrawn withdraw) :=
  ⟨reachable3, reachableMixed, reachable1, ⟨fold_ok, by concrete⟩,
    ⟨account_ok false, rfl⟩, ⟨withdraw_ok, rfl⟩⟩
-- W48: both equality boundaries belong to the complete account, even for window=0.
example : Reachable s1 ∧ request.deadline = 10 ∧ request.window = 5 ∧
    accountAllowed { account false with now := 15 } ∧
    (10 ≤ ({ request with window := 0 } : Request).deadline + 0) := by
  exact ⟨reachable1, rfl, rfl,
    ⟨(account_ok false).1, (account_ok false).2.1, rfl, rfl, by concrete, by concrete⟩,
    by concrete⟩
-- W49: distinct submitters compete within the same exit kind and time.
example : Reachable mixed ∧ accountAllowed (account false) ∧
    accountAllowed { account false with submitter := "another" } ∧
    (account false).now = ({ account false with submitter := "another" } : AccountTx).now :=
  ⟨reachableMixed, account_ok false, account_ok false, rfl⟩
-- W50
example : Reachable s3 ∧ Step s3 (.fold fold) s4 ∧ approved "alice" ∈ fold.refs :=
  ⟨reachable3, step_fold, by concrete⟩
-- W51
example : Reachable mixed ∧ Step mixed (.account (account false)) (afterExit mixed output) ∧
    refused "bob" ∈ (account false).refs := ⟨reachableMixed, step_account, by concrete⟩
-- W52
example : Reachable s0 ∧ Step s0 (.create create output) s1 := ⟨reachable0, step_create⟩
-- W53: different per-oracle fees and a positive folder remainder.
example : Reachable s3 ∧ foldAccepted fold ∧
    fold.allocations = [⟨output, [("alice", 2), ("bob", 3)], "folder", 5⟩] :=
  ⟨reachable3, fold_ok, rfl⟩
-- W54: refusal pays exactly the same declared fee and the owner gets the rest.
example : Reachable mixed ∧ accountAllowed (account false) ∧
    (account false).paid = ⟨output, [("alice", 2), ("bob", 3)], "owner", 5⟩ :=
  ⟨reachableMixed, account_ok false, rfl⟩
-- W55
example : Reachable s0 ∧ Step s0 (.create create output) s1 ∧ output.value = 10 :=
  ⟨reachable0, step_create, rfl⟩
-- W56
example : Reachable s4 ∧ Step s4 (.burn (approved "alice")) (afterBurn s4 (approved "alice")) ∧
    s4.judgments.count (approved "alice") = 1 := ⟨reachable4, deadBurn, by concrete⟩
-- W57
example : Reachable s4 ∧ Step s4 (.burn (approved "alice")) (afterBurn s4 (approved "alice")) ∧
    approved "alice" ∈ s4.issued := ⟨reachable4, deadBurn, by concrete⟩
-- W58
example : Reachable s3 ∧ foldAccepted fold ∧ output ∈ fold.requests :=
  ⟨reachable3, fold_ok, by concrete⟩
-- W59: all antecedents of refusal availability, including authentic holdings.
example : Reachable mixed ∧ output ∈ mixed.live ∧ wellFormed mixed.cage output ∧
    (∀ oracle ∈ mixed.cage.oracles,
      judgmentName mixed.cage.id output.request oracle (oracle == "alice") ∈ mixed.judgments) ∧
    output.request.deadline ≤ 10 ∧ 10 ≤ output.request.deadline + output.request.window := by
  refine ⟨reachableMixed, by concrete, by concrete, ?_, by concrete, by concrete⟩
  intro oracle h
  change oracle ∈ cage.oracles at h
  simp only [cage, List.mem_cons, List.not_mem_nil, or_false] at h
  rcases h with rfl | rfl <;> concrete

-- W60 and strengthened W27: the same reached state can settle either verdict.
example : Reachable equivocal ∧ approved "bob" ∈ equivocal.judgments ∧
    refused "bob" ∈ equivocal.judgments ∧ approved "bob" ∈ equivocal.issued ∧
    refused "bob" ∈ equivocal.issued :=
  ⟨reachableEquivocal, by concrete, by concrete, by concrete, by concrete⟩
example : Reachable equivocal ∧
    Step equivocal (.account (account true)) (afterExit equivocal output) ∧
    Step equivocal (.account (account false)) (afterExit equivocal output) ∧
    (account true).paid = (account false).paid :=
  ⟨reachableEquivocal,
    Step.account equivocal (account true) rfl (by concrete) (by concrete) (account_ok true),
    Step.account equivocal (account false) rfl (by concrete) (by concrete) (account_ok false), rfl⟩

end RequestApprovalFold.Witnesses
