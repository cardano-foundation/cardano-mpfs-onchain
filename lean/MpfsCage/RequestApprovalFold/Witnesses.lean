import MpfsCage.RequestApprovalFold.Statements

namespace RequestApprovalFold.Witnesses

macro "concrete" : tactic => `(tactic| ((try simp only [createAllowed, wellFormed, withdrawAllowed, Condition.holds, stepValid, hasApproval]) <;> decide))

/-! Concrete two-oracle traces. Witness proofs use only production definitions,
    constructors and core lemmas, never the candidate theorem statements. -/
def cage : CageState := ⟨⟨"policy", "registry"⟩, ["alice", "bob"], "protocol", emptyTrie⟩
def request : Request :=
  ⟨cage.id, "owner", "seed0", .set "x" "v", [.absent "x"], "evidence",
    [("alice", 2), ("bob", 3)], 10, 5⟩
def output : RequestOutput := ⟨request, 10, [tagName cage.id]⟩
def create : CreateTx := ⟨[request.seed], cage, [tagName cage.id], [output]⟩
def s0 := initial cage
def s1 := afterCreate s0 create output

def approved (oracle : Signer) := judgmentName cage.id request oracle true
def refused (oracle : Signer) := judgmentName cage.id request oracle false

def judge (oracle : Signer) (verdict : Bool) : JudgmentTx :=
  ⟨cage, output, oracle, verdict, 2, [oracle], [],
    [judgmentName cage.id request oracle verdict]⟩
def s2 := afterJudgment s1 (judge "alice" true)
def s3 := afterJudgment s2 (judge "bob" true)
def mixed := afterJudgment s2 (judge "bob" false)

def fold : FoldTx :=
  ⟨cage, { cage with trie := request.write.apply cage.trie }, [output],
    [approved "alice", approved "bob"], [], 3, "folder", "anybody",
    tokensOf output, [allocation cage output "folder"]⟩
def s4 := afterFold s3 fold

def account (bobVerdict : Bool) : AccountTx :=
  ⟨cage, output, [approved "alice", judgmentName cage.id request "bob" bobVerdict],
    1, "anybody", tokensOf output, allocation cage output "owner"⟩
def withdraw : WithdrawTx := ⟨output, 16, ["owner"], tokensOf output, "owner", 10⟩

def registry_ok : registryCreated cage [] := by
  simp [registryCreated, RegistryValid, cage]
def create_ok : createAllowed create output := by
  concrete

def reachable0 : Reachable s0 := Reachable.registry cage [] registry_ok
def step_create : Step s0 s1 := by
  apply Step.create s0 create output rfl create_ok
  simp [s0, initial]
def reachable1 : Reachable s1 := .next reachable0 step_create

def judge_ok (oracle : Signer) (verdict : Bool) (h : oracle ∈ cage.oracles) :
    judgmentAllowed (judge oracle verdict) := by
  exact ⟨rfl, h, List.mem_cons_self, by change 2 < 10; concrete, rfl, rfl⟩
def step_alice : Step s1 s2 :=
  Step.judge s1 (judge "alice" true) rfl (by concrete) (judge_ok _ _ (by concrete))
def reachable2 : Reachable s2 := .next reachable1 step_alice
def step_bob : Step s2 s3 :=
  Step.judge s2 (judge "bob" true) rfl (by concrete) (judge_ok _ _ (by concrete))
def reachable3 : Reachable s3 := .next reachable2 step_bob

def step_mixed : Step s2 mixed :=
  Step.judge s2 (judge "bob" false) rfl (by concrete) (judge_ok _ _ (by concrete))
def reachableMixed : Reachable mixed := .next reachable2 step_mixed

def valid_step : stepValid cage 3 fold.refs [] cage.trie output := by
  refine ⟨by concrete, by concrete, ?_, ?_⟩
  · intro oracle h
    simp only [cage, List.mem_cons, List.not_mem_nil, or_false] at h
    rcases h with rfl | rfl <;> exact Or.inl (by concrete)
  · intro condition h
    simp only [output, request, List.mem_singleton] at h
    subst condition
    rfl

def run_ok : FoldRun cage 3 fold.refs [] cage.trie [output] fold.cageOut.trie :=
  .cons _ _ _ _ valid_step (.nil _)
def fold_ok : foldAccepted fold :=
  ⟨rfl, rfl, rfl, by concrete, rfl, rfl, run_ok⟩
def step_fold : Step s3 s4 := by
  apply Step.fold s3 fold rfl (by concrete) (by concrete) fold_ok

def reachable4 : Reachable s4 := .next reachable3 step_fold

def account_ok (verdict : Bool) : accountAllowed (account verdict) := by
  refine ⟨?_, ?_, rfl, rfl⟩
  · change wellFormed cage output; concrete
  intro oracle h
  change oracle ∈ cage.oracles at h
  simp only [cage, List.mem_cons, List.not_mem_nil, or_false] at h
  rcases h with rfl | rfl
  · exact ⟨true, by simp [account, approved, output]⟩
  · exact ⟨verdict, by simp [account, output]⟩
def withdraw_ok : withdrawAllowed withdraw := by concrete

def step_account : Step mixed (afterExit mixed output) :=
  Step.account mixed (account false) rfl (by concrete) (by concrete) (account_ok false)
def step_withdraw : Step s1 (afterExit s1 output) :=
  Step.withdraw s1 withdraw (by concrete) withdraw_ok

def history04 : History s0 s4 :=
  .next step_create (.next step_alice (.next step_bob (.next step_fold (.refl _))))

-- W01: nonempty ordered write lists.
example : Reachable s0 ∧ request.write.apply emptyTrie "x" = some "v" :=
  ⟨reachable0, rfl⟩
-- W02
example : Reachable s3 ∧ FoldRun cage 3 fold.refs [] cage.trie [output] fold.cageOut.trie :=
  ⟨reachable3, run_ok⟩
-- W03
example : Reachable s3 ∧ FoldRun cage 3 fold.refs [] cage.trie [output] fold.cageOut.trie :=
  ⟨reachable3, run_ok⟩
-- W04: the absent condition is present in the input, not a vacuous empty list.
example : Reachable s3 ∧ FoldRun cage 3 fold.refs [] cage.trie [output] fold.cageOut.trie ∧
    output.request.conditions = [.absent "x"] := ⟨reachable3, run_ok, rfl⟩
-- W05
example : Reachable s4 ∧ (s4.cage.trie "x").isSome ∧
    (∀ w ∈ [Write.set "x" "v2"], w ≠ .unset "x") := by
  exact ⟨reachable4, rfl, by simp⟩
-- W06
example : registryCreated cage [] ∧ Reachable s0 := ⟨registry_ok, reachable0⟩
-- W07
example : Reachable s0 ∧ createAllowed create output := ⟨reachable0, create_ok⟩

-- A second distinct seed is live alongside the first.
def output1 : RequestOutput := { output with request := { request with seed := "seed1" } }
def create1 : CreateTx := ⟨["seed1"], cage, [tagName cage.id], [output1]⟩
def step_create1 : Step s1 (afterCreate s1 create1 output1) :=
  Step.create s1 create1 output1 rfl (by concrete) (by concrete)
def spent_once : SpentOnce [create, create1] := by
  intro a b seed ha hb hsa hsb
  simp only [List.mem_cons, List.not_mem_nil, or_false] at ha hb
  rcases ha with rfl | rfl <;> rcases hb with rfl | rfl
  · rfl
  · simp [create, create1, request] at hsa hsb
    subst seed
    contradiction
  · simp [create, create1, request] at hsa hsb
    subst seed
    contradiction
  · rfl
-- W08
example : Reachable (afterCreate s1 create1 output1) ∧ SpentOnce [create, create1] ∧
    createAllowed create output ∧ createAllowed create1 output1 ∧ create ≠ create1 := by
  refine ⟨.next reachable1 step_create1, spent_once, create_ok, by concrete, ?_⟩
  intro h
  have hspent := congrArg CreateTx.spent h
  contradiction
-- W09
example : Reachable s1 ∧ judgmentAllowed (judge "alice" true) :=
  ⟨reachable1, judge_ok _ _ (by concrete)⟩
-- W10
example : Reachable s2 ∧ approved "alice" = judgmentName cage.id request "alice" true :=
  ⟨reachable2, rfl⟩
-- W11
example : Reachable s2 ∧ tagName cage.id ∈ output.tags ∧ approved "alice" ∈ s2.judgments :=
  ⟨reachable2, by concrete, by concrete⟩
-- W12
example : Reachable s3 ∧ foldAccepted fold := ⟨reachable3, fold_ok⟩
-- W13
example : Reachable s3 ∧ Step s3 s4 := ⟨reachable3, step_fold⟩
-- W14
example : Reachable s0 ∧ History s0 s4 := ⟨reachable0, history04⟩
-- W15
example : Reachable s3 ∧ Step s3 s4 ∧ s4.cage.trie ≠ s3.cage.trie := by
  refine ⟨reachable3, step_fold, ?_⟩
  intro h
  have hx := congrFun h "x"
  contradiction
-- W16
example : Reachable s3 ∧ foldAccepted fold ∧ output ∈ fold.requests :=
  ⟨reachable3, fold_ok, by concrete⟩
-- W17
example : Reachable s3 ∧ foldAccepted fold ∧ fold.requests[0]? = some output ∧
    Condition.absent "x" ∈ output.request.conditions :=
  ⟨reachable3, fold_ok, rfl, by concrete⟩
-- W18
example : Reachable s3 ∧ foldAccepted fold := ⟨reachable3, fold_ok⟩
-- W19
example : Reachable s3 ∧ foldAccepted fold ∧ fold.burned ≠ [] :=
  ⟨reachable3, fold_ok, by concrete⟩
-- W20
example : Reachable s3 ∧ foldAccepted fold ∧ totalFees cage request = 5 ∧ output.value = 10 :=
  ⟨reachable3, fold_ok, rfl, rfl⟩
-- W21
example : Reachable s1 ∧ wellFormed cage output ∧ (allocation cage output "folder").remainder = 5 :=
  ⟨reachable1, by concrete, rfl⟩

-- Blind writes are separately created, not post-creation datum alterations.
def blind : RequestOutput := { output with request := { request with conditions := [] } }
def createBlind : CreateTx := { create with outputs := [blind] }
def blindState := afterCreate s0 createBlind blind
def reachableBlind : Reachable blindState :=
  .next reachable0 (Step.create s0 createBlind blind rfl (by concrete) (by concrete))
-- W22
example : Reachable blindState ∧ wellFormed cage blind ∧ 3 < blind.request.deadline ∧
    hasApproval cage blind.request [] ["alice", "bob"] ∧ blind.request.conditions = [] := by
  refine ⟨reachableBlind, by concrete, by concrete, ?_, rfl⟩
  intro oracle h
  exact Or.inr h
-- W23
example : Reachable s3 ∧ foldAccepted fold ∧ fold.submitter ≠ "new-submitter" :=
  ⟨reachable3, fold_ok, by concrete⟩
-- W24: accepted single insert and conflicting absent request on reached tree.
-- The theorem's conclusion forces an intervening unset; a complete accepted
-- insert/unset/insert run is supplied below after this elementary conflict.
example : Reachable s4 ∧ s4.cage.trie "x" = some "v" ∧
    ¬ (Condition.absent "x").holds s4.cage.trie := ⟨reachable4, rfl, by concrete⟩
-- W25
example : Reachable mixed ∧ accountAllowed (account false) ∧ Step mixed (afterExit mixed output) :=
  ⟨reachableMixed, account_ok false, step_account⟩
-- W26
example : Reachable mixed ∧ accountAllowed (account false) := ⟨reachableMixed, account_ok false⟩
-- W27: both approval and refusal paths are reachable, with the same money.
example : Reachable s3 ∧ Reachable mixed ∧
    accountAllowed (account true) ∧ accountAllowed (account false) ∧
    (account true).cageRef = (account false).cageRef ∧
    (account true).input = (account false).input :=
  ⟨reachable3, reachableMixed, account_ok true, account_ok false, rfl, rfl⟩
-- W28
example : Reachable s1 ∧ withdrawAllowed withdraw := ⟨reachable1, withdraw_ok⟩
-- W29
example : Reachable s1 ∧ output.request.deadline + output.request.window < 16 :=
  ⟨reachable1, by concrete⟩
-- W30: every lifecycle arm has a reachable accepted transaction.
example : Reachable s3 ∧ Reachable mixed ∧ Reachable s1 ∧
    requestSpendAllowed output (.folded fold) ∧
    requestSpendAllowed output (.accounted (account false)) ∧
    requestSpendAllowed output (.withdrawn withdraw) :=
  ⟨reachable3, reachableMixed, reachable1, ⟨fold_ok, by concrete⟩,
    ⟨account_ok false, rfl⟩, ⟨withdraw_ok, rfl⟩⟩
-- W31
example : Reachable mixed ∧ requestSpendAllowed output (.accounted (account false)) ∧
    tagName cage.id ∈ tokensOf output :=
  ⟨reachableMixed, ⟨account_ok false, rfl⟩, by concrete⟩
-- W32
example : Reachable s3 ∧ requestSpendAllowed output (.folded fold) ∧
    fold.now ≤ request.deadline + request.window ∧
    RequestSpend.cage (.folded fold) = some cage :=
  ⟨reachable3, ⟨fold_ok, by concrete⟩, by concrete, rfl⟩
-- W33
example : Reachable mixed ∧ requestSpendAllowed output (.accounted (account false)) ∧
    (account false).now ≤ request.deadline + request.window ∧
    RequestSpend.cage (.accounted (account false)) = some cage :=
  ⟨reachableMixed, ⟨account_ok false, rfl⟩, by concrete, rfl⟩

def mixed_nonEquivocating : NonEquivocating mixed.issued := by
  intro c r oracle ha hf
  simp [mixed, s2, s1, s0, initial, afterJudgment, afterCreate, judge,
    judgmentName] at ha hf
  have he := ha.2.2.symm.trans hf.2.2
  contradiction
-- W34
example : Reachable mixed ∧ accountAllowed (account false) ∧ NonEquivocating mixed.issued ∧
    (∀ name ∈ (account false).refs, name ∈ mixed.issued) ∧
    "alice" ∈ cage.oracles ∧ approved "alice" ∈ mixed.issued :=
  ⟨reachableMixed, account_ok false, mixed_nonEquivocating, by concrete, by concrete, by concrete⟩
-- W35
example : Reachable s4 ∧ approved "alice" ∈ s4.judgments ∧
    (∀ o ∈ s4.live, o.request ≠ request) := ⟨reachable4, by concrete, by concrete⟩
-- W36
example : Reachable s1 ∧ Step s1 s2 := ⟨reachable1, step_alice⟩
-- W37
example : Reachable (afterExit s1 output) := .next reachable1 step_withdraw
-- W38
example : Reachable s4 ∧ output ∈ fold.requests := ⟨reachable4, by concrete⟩
-- W39
example : Reachable s1 ∧ Step s1 s2 ∧ request.seed ∈ s1.usedSeeds :=
  ⟨reachable1, step_alice, by concrete⟩
-- W40
example : Reachable s1 ∧ output ∈ s1.live := ⟨reachable1, by concrete⟩
-- W41
example : Reachable s4 ∧ request.seed ∈ s4.usedSeeds ∧ createAllowed create output :=
  ⟨reachable4, by concrete, create_ok⟩
-- W42: burning dead evidence is a nontrivial post-exit history.
def deadBurn : Step s4 (afterBurn s4 (approved "alice")) := Step.burn s4 _ (by concrete)
example : Reachable s4 ∧ History s4 (afterBurn s4 (approved "alice")) ∧
    request.seed ∈ s4.usedSeeds ∧ output ∉ s4.live :=
  ⟨reachable4, .next deadBurn (.refl _), by concrete, by concrete⟩
-- W43
example : registryCreated { cage with oracles := ["alice"] } [] ∧
    ({ cage with oracles := ["alice"] } : CageState).oracles = ["alice"] := by
  exact ⟨by simp [registryCreated, RegistryValid, cage], rfl⟩
-- W44
example : Reachable s0 ∧ Reachable s4 ∧
    (OldOperation.insert "x" "v").condition.holds s0.cage.trie ∧
    (OldOperation.delete "x" "v").condition.holds s4.cage.trie ∧
    (OldOperation.update "x" "v" "v2").condition.holds s4.cage.trie :=
  ⟨reachable0, reachable4, rfl, rfl, rfl⟩

-- W45
example : Reachable s3 ∧ Step s3 s4 ∧ output ∈ s3.live ∧ output ∉ s4.live :=
  ⟨reachable3, step_fold, by concrete, by concrete⟩
-- W46
example : Reachable s1 ∧ Step s1 s2 ∧ approved "alice" ∈ s2.issued ∧
    approved "alice" ∉ s1.issued := ⟨reachable1, step_alice, by concrete, by concrete⟩

-- W24b: all antecedents of the exclusivity theorem hold on this reachable
-- batch, including the intervening unset that its conclusion requires.
def unsetOutput : RequestOutput :=
  { output with request := { request with seed := "unset-seed", write := .unset "x", conditions := [] } }
def againOutput : RequestOutput :=
  { output with request := { request with seed := "again-seed" } }
def createUnset : CreateTx := ⟨["unset-seed"], cage, [tagName cage.id], [unsetOutput]⟩
def createAgain : CreateTx := ⟨["again-seed"], cage, [tagName cage.id], [againOutput]⟩
def withUnset := afterCreate s1 createUnset unsetOutput
def withAgain := afterCreate withUnset createAgain againOutput

def reachableBatch : Reachable withAgain := by
  apply Reachable.next (Reachable.next reachable1 (Step.create s1 createUnset unsetOutput rfl
    (by concrete) (by concrete)))
  exact Step.create withUnset createAgain againOutput rfl (by concrete) (by concrete)

def tripleRun : FoldRun cage 3 [] ["alice", "bob"] emptyTrie
    [output, unsetOutput, againOutput]
    (againOutput.request.write.apply
      (unsetOutput.request.write.apply (output.request.write.apply emptyTrie))) := by
  apply FoldRun.cons
  · simp [stepValid, wellFormed, hasApproval, cage, output, request,
      totalFees, Request.fee, Condition.holds, emptyTrie]
  apply FoldRun.cons
  · simp [stepValid, wellFormed, hasApproval, cage, output, request, unsetOutput,
      totalFees, Request.fee, Condition.holds, emptyTrie, Write.apply]
  apply FoldRun.cons
  · simp [stepValid, wellFormed, hasApproval, cage, output, request, unsetOutput,
      againOutput, totalFees, Request.fee, Condition.holds, emptyTrie, Write.apply]
  exact FoldRun.nil _

example : Reachable withAgain ∧
    FoldRun cage 3 [] ["alice", "bob"] emptyTrie
      (output :: ([unsetOutput] ++ againOutput :: []))
      (againOutput.request.write.apply
        (unsetOutput.request.write.apply (output.request.write.apply emptyTrie))) ∧
    output.request.write = .set "x" "v" ∧
    Condition.absent "x" ∈ againOutput.request.conditions :=
  ⟨reachableBatch, tripleRun, rfl, by concrete⟩

end RequestApprovalFold.Witnesses
