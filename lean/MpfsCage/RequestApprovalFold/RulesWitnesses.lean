import MpfsCage.RequestApprovalFold.Rules

namespace RequestApprovalFold.Witnesses

/-! Reachable witnesses use constructors, never admitted theorem declarations. -/
def ownerRule : Rule := ⟨"owner-insert", fun r signers =>
  r.owner ∈ signers ∧ Condition.absent "x" ∈ r.conditions⟩
def zeroCage : CageState :=
  ⟨⟨"policy", "personal"⟩, [], "protocol", emptyTrie, some ownerRule⟩
def zeroOutput : RequestOutput :=
  ⟨{ request with cage := zeroCage.id }, 10, [], "zero-output", [requestName zeroCage.id],
    .rule "owner-insert"⟩
def zeroCreate : CreateTx :=
  ⟨[], zeroCage, [requestName zeroCage.id], [zeroOutput], ["owner"], .rule "owner-insert"⟩
def z0 := initial zeroCage
def z1 := afterCreate z0 zeroCreate zeroOutput

def zero_registry_ok : registryCreated zeroCage [] := by
  simp [registryCreated, RegistryValid, zeroCage]
def zero_create_ok : createAllowed zeroCreate zeroOutput := by
  refine ⟨?_, rfl, rfl, ?_, ?_, rfl⟩
  · intro h; exact False.elim (h rfl)
  · concrete
  · exact ⟨by decide, by decide⟩
def reachableZ0 : Reachable z0 := .registry zeroCage [] zero_registry_ok
def zero_step_create : Step z0 (.create zeroCreate zeroOutput) z1 :=
  .create _ _ _ rfl zero_create_ok (by decide) (by decide)
def reachableZ1 : Reachable z1 := .next reachableZ0 zero_step_create

def zeroFold : FoldTx :=
  ⟨zeroCage, { zeroCage with trie := zeroOutput.request.write.apply emptyTrie }, [zeroOutput],
    [], [], 3, "folder", noOracleConditions, "anyone", tokensOf zeroOutput,
    [allocation zeroCage zeroOutput "folder"]⟩
def zero_run : FoldRun zeroCage 3 [] [] noOracleConditions emptyTrie [zeroOutput]
    zeroFold.cageOut.trie := by
  apply FoldRun.cons
  · refine ⟨by concrete, by decide, ?_, ?_, ?_⟩
    · intro oracle h; cases h
    · intro condition h
      simp only [zeroOutput, request, List.mem_singleton] at h
      subst condition; rfl
    · intro oracle h; cases h
  exact FoldRun.nil _
def zero_fold_ok : foldAccepted zeroFold :=
  ⟨rfl, rfl, rfl, rfl, by decide, rfl, rfl, zero_run⟩
def zero_step_fold : Step z1 (.fold zeroFold) (afterFold z1 zeroFold) :=
  .fold _ _ rfl (by decide) (by decide) zero_fold_ok

def zeroAccount : AccountTx :=
  ⟨zeroCage, zeroOutput, [], 10, "anyone", tokensOf zeroOutput,
    allocation zeroCage zeroOutput "owner"⟩
def zero_account_ok : accountAllowed zeroAccount := by
  refine ⟨by concrete, ?_, rfl, rfl, by decide, by decide⟩
  intro oracle h; cases h
def zero_step_account : Step z1 (.account zeroAccount) (afterExit z1 zeroOutput) :=
  .account _ _ rfl (by decide) (by decide) zero_account_ok

def zeroTwin : RequestOutput := { zeroOutput with ref := "zero-twin" }
def twinCreate : CreateTx := { zeroCreate with outputs := [zeroTwin] }
def twins := afterCreate z1 twinCreate zeroTwin

def twin_create_ok : createAllowed twinCreate zeroTwin := by
  refine ⟨?_, rfl, rfl, by concrete, ?_, rfl⟩
  · intro h; exact False.elim (h rfl)
  · exact ⟨by decide, by decide⟩
def step_twin : Step z1 (.create twinCreate zeroTwin) twins :=
  .create _ _ _ rfl twin_create_ok (by decide) (by decide)
def reachableTwins : Reachable twins := .next reachableZ1 step_twin

def oracleAssumptions : OracleConditions := fun _ _ => [.absent "y"]
def conditionalJudge (oracle : Signer) : JudgmentTx :=
  { judge oracle true with
    conditions := [.absent "y"]
    minted := [judgmentName cage.id request oracle true [.absent "y"]] }
def conditional1 := afterJudgment s1 (conditionalJudge "alice")
def conditional2 := afterJudgment conditional1 (conditionalJudge "bob")
def conditional_judge_ok (oracle : Signer) (h : oracle ∈ cage.oracles) :
    judgmentAllowed (conditionalJudge oracle) :=
  ⟨rfl, h, by simp [conditionalJudge, judge], by change 2 < 10; decide, rfl, rfl⟩
def reachableConditional1 : Reachable conditional1 :=
  .next reachable1 (.judge _ _ rfl (by decide) (conditional_judge_ok _ (by decide)))
def reachableConditional2 : Reachable conditional2 :=
  .next reachableConditional1 (.judge _ _ rfl (by decide) (conditional_judge_ok _ (by decide)))
def conditionalFold : FoldTx :=
  { fold with
    refs := [judgmentName cage.id request "alice" true [.absent "y"],
      judgmentName cage.id request "bob" true [.absent "y"]]
    conditions := oracleAssumptions }
def conditional_run : FoldRun cage 3 conditionalFold.refs [] oracleAssumptions emptyTrie
    [output] conditionalFold.cageOut.trie := by
  apply FoldRun.cons
  · refine ⟨by concrete, by decide, ?_, ?_, ?_⟩
    · intro oracle h
      simp only [cage, List.mem_cons, List.not_mem_nil, or_false] at h
      rcases h with rfl | rfl <;> exact Or.inl (by decide)
    · intro condition h
      simp only [output, request, List.mem_singleton] at h
      subst condition; rfl
    · intro oracle _ condition h
      change condition ∈ [Condition.absent "y"] at h
      simp only [List.mem_singleton] at h
      subst condition; rfl
  exact FoldRun.nil _
def conditional_fold_ok : foldAccepted conditionalFold :=
  ⟨rfl, rfl, rfl, rfl, by decide, rfl, rfl, conditional_run⟩
def conditional_step_fold : Step conditional2 (.fold conditionalFold) (afterFold conditional2 conditionalFold) :=
  .fold _ _ rfl (by decide) (by decide) conditional_fold_ok

-- The same assumptions are carried by the signed fold body with no token refs.
def conditionalSigned : FoldTx :=
  { conditionalFold with refs := [], signers := ["alice", "bob"] }
def signed_conditional_ok : foldAccepted conditionalSigned := by
  refine ⟨rfl, rfl, rfl, rfl, by decide, rfl, rfl, ?_⟩
  apply FoldRun.cons
  · refine ⟨by concrete, by decide, ?_, ?_, ?_⟩
    · intro oracle h; exact Or.inr h
    · intro condition h
      simp only [output, request, List.mem_singleton] at h
      subst condition; rfl
    · intro oracle _ condition h
      change condition ∈ [Condition.absent "y"] at h
      simp only [List.mem_singleton] at h
      subst condition; rfl
  exact FoldRun.nil _

-- A different, genuine request changes y while the conditional approval stays held.
def blocker : RequestOutput :=
  { output with
    request := { request with seed := "blocker-seed", write := .set "y" "changed", conditions := [] }
    ref := "blocker-output" }
def blockerCreate : CreateTx :=
  ⟨["blocker-seed"], cage, tokensOf blocker, [blocker], [], .release⟩
def beforeBlock := afterCreate conditional2 blockerCreate blocker

def reachableBeforeBlock : Reachable beforeBlock :=
  .next reachableConditional2 (.create _ _ _ rfl (by concrete) (by decide) (by decide))
def blockerFold : FoldTx :=
  ⟨cage, { cage with trie := blocker.request.write.apply emptyTrie }, [blocker], [],
    ["alice", "bob"], 3, "folder", noOracleConditions, "anyone", tokensOf blocker,
    [allocation cage blocker "folder"]⟩
def blocker_fold_ok : foldAccepted blockerFold := by
  refine ⟨rfl, rfl, rfl, rfl, by decide, rfl, rfl, ?_⟩
  apply FoldRun.cons
  · refine ⟨by concrete, by decide, ?_, ?_, ?_⟩
    · intro oracle h; exact Or.inr h
    · intro condition h; cases h
    · intro oracle _ condition h; cases h
  exact FoldRun.nil _
def staleState := afterFold beforeBlock blockerFold
def reachableStale : Reachable staleState :=
  .next reachableBeforeBlock (.fold _ _ rfl (by decide) (by decide) blocker_fold_ok)
def staleFold : FoldTx :=
  { conditionalFold with
    cageIn := staleState.cage
    cageOut := { staleState.cage with trie := request.write.apply staleState.cage.trie } }

-- W79 creation_rule_and_token: creation executes a nontrivial rule.
example : Reachable z0 ∧ createAllowed zeroCreate zeroOutput := ⟨reachableZ0, zero_create_ok⟩
-- W80 step_rule_immutable: a real rule-gated request is folded.
example : Reachable z1 ∧ Step z1 (.fold zeroFold) (afterFold z1 zeroFold) :=
  ⟨reachableZ1, zero_step_fold⟩
-- W81 history_rule_immutable.
example : Reachable z0 ∧ History z0 (afterFold z1 zeroFold) :=
  ⟨reachableZ0, .next zero_step_create (.next zero_step_fold (.refl _))⟩
-- W82 reachable_rule_admitted.
example : Reachable twins ∧ zeroOutput ∈ twins.live ∧ zeroTwin ∈ twins.live :=
  ⟨reachableTwins, by decide, by decide⟩
-- W83 every_rule_allows_burn: no creator signature is re-requested by an exit.
example : Reachable z1 ∧ Step z1 (.account zeroAccount) (afterExit z1 zeroOutput) ∧
    ¬ ruleAdmits zeroCage zeroOutput.request [] := ⟨reachableZ1, zero_step_account, by change ¬ ("owner" ∈ ([] : List Signer) ∧ _); simp⟩
-- W84 fold_rule_predicate_independent: creating signature is absent at the fold.
example : Reachable z1 ∧ foldAccepted zeroFold ∧ zeroFold.signers = [] :=
  ⟨reachableZ1, zero_fold_ok, rfl⟩
-- W85 reachable_request_tokens.
example : Reachable z1 ∧ zeroOutput ∈ z1.live := ⟨reachableZ1, by decide⟩
-- W86 fold_requires_request_token.
example : Reachable z1 ∧ foldAccepted zeroFold ∧ zeroOutput ∈ zeroFold.requests :=
  ⟨reachableZ1, zero_fold_ok, by decide⟩
-- W87 every_exit_burns_request_token: all three arms have genuine reached inputs.
example : Reachable z1 ∧ requestSpendAllowed zeroOutput (.folded zeroFold) ∧
    requestSpendAllowed zeroOutput (.accounted zeroAccount) ∧
    requestSpendAllowed zeroOutput (.withdrawn
      ⟨zeroOutput, 16, ["owner"], tokensOf zeroOutput, "owner", 10⟩) :=
  ⟨reachableZ1, ⟨zero_fold_ok, by decide⟩, ⟨zero_account_ok, rfl⟩, ⟨by concrete, rfl⟩⟩
-- W88 live_removal_burns_request_token.
example : Reachable z1 ∧ Step z1 (.fold zeroFold) (afterFold z1 zeroFold) ∧
    zeroOutput ∈ z1.live ∧ zeroOutput ∉ (afterFold z1 zeroFold).live :=
  ⟨reachableZ1, zero_step_fold, by decide, by decide⟩
-- W89 request_name_injective.
example : Reachable z1 ∧ Reachable s1 ∧ requestName zeroCage.id ≠ requestName cage.id :=
  ⟨reachableZ1, reachable1, by decide⟩
-- W90 request_token_discovery.
example : Reachable z1 ∧ zeroOutput ∈ discoverRequests zeroCage.id z1.live ∧
    zeroOutput ∉ discoverRequests cage.id z1.live := ⟨reachableZ1, by decide, by decide⟩
-- W91 request_token_discovery_across_registries.
example : Reachable z1 ∧ Reachable s1 ∧
    zeroOutput ∈ discoverRequests zeroCage.id ([z1, s1].flatMap State.live) ∧
    output ∉ discoverRequests zeroCage.id ([z1, s1].flatMap State.live) :=
  ⟨reachableZ1, reachable1, by decide, by decide⟩
-- W92 output_refs_monotone.
example : Reachable z1 ∧ Step z1 (.create twinCreate zeroTwin) twins ∧ zeroOutput.ref ∈ z1.usedOutputs :=
  ⟨reachableZ1, step_twin, by decide⟩
-- W93 reachable_output_refs: equal datums, distinct UTxOs, no spent seed.
example : Reachable twins ∧ zeroOutput.request = zeroTwin.request ∧ twins.usedSeeds = [] ∧
    zeroOutput.ref ≠ zeroTwin.ref := ⟨reachableTwins, rfl, rfl, by decide⟩
-- W94 reachable_output_refs_unique.
example : Reachable twins ∧ (twins.live.map RequestOutput.ref).Nodup := ⟨reachableTwins, by decide⟩
-- W95 unguarded_registry_impossible: reached fresh identity with either gate removed.
example : Reachable z0 ∧ ({ zeroCage with rule := none } : CageState).oracles = [] ∧
    ({ zeroCage with rule := none } : CageState).rule = none := ⟨reachableZ0, rfl, rfl⟩
-- W96 zero_oracle_needs_rule.
example : Reachable z0 ∧ registryCreated zeroCage [] ∧ zeroCage.oracles = [] :=
  ⟨reachableZ0, zero_registry_ok, rfl⟩
-- W97 zero_oracle_evidence_empty.
example : Reachable z1 ∧ zeroCage.oracles = [] := ⟨reachableZ1, rfl⟩
-- W98 zero_oracle_creation_without_seed.
example : Reachable z0 ∧ zeroCage.oracles = [] ∧ wellFormed zeroCage zeroOutput ∧
    ruleAdmits zeroCage zeroOutput.request ["owner"] ∧ zeroCreate.spent = [] :=
  ⟨reachableZ0, rfl, by concrete, ⟨by decide, by decide⟩, rfl⟩
-- W99 zero_oracle_fold_without_approvals.
example : Reachable z1 ∧ FoldRun zeroCage 3 [] [] noOracleConditions emptyTrie [zeroOutput]
    zeroFold.cageOut.trie := ⟨reachableZ1, zero_run⟩
-- W100 zero_oracle_account_without_verdicts.
example : Reachable z1 ∧ zeroOutput ∈ z1.live ∧ wellFormed zeroCage zeroOutput ∧
    zeroOutput.request.deadline ≤ 10 ∧ 10 ≤ zeroOutput.request.deadline + zeroOutput.request.window :=
  ⟨reachableZ1, by decide, by concrete, by decide, by decide⟩
-- W101 present_condition_semantics: present and absent on reached trees.
example : Reachable s0 ∧ Reachable s4 ∧ (Condition.present "x").holds s4.cage.trie ∧
    ¬ (Condition.present "x").holds s0.cage.trie := by
  refine ⟨reachable0, reachable4, ⟨"v", rfl⟩, ?_⟩
  rintro ⟨v, hv⟩; cases hv
-- W102 foldRun_oracle_conditions.
example : Reachable conditional2 ∧ FoldRun cage 3 conditionalFold.refs [] oracleAssumptions
    emptyTrie [output] conditionalFold.cageOut.trie := ⟨reachableConditional2, conditional_run⟩
-- W103 fold_all_conditions_hold: token and signature paths both carry assumptions.
example : Reachable conditional2 ∧ foldAccepted conditionalFold ∧ foldAccepted conditionalSigned :=
  ⟨reachableConditional2, conditional_fold_ok, signed_conditional_ok⟩
-- W104 approval_conditions_cannot_change.
example : Reachable conditional2 ∧
    judgmentName cage.id request "alice" true [.absent "y"] ∈ conditional2.judgments ∧
    judgmentName cage.id request "alice" true [.present "y"] ∉ conditional2.judgments :=
  ⟨reachableConditional2, by decide, by decide⟩
-- W105 stale_approval_unusable: the approval remains held, time is still before deadline.
example : Reachable staleState ∧ output ∈ staleState.live ∧
    judgmentName cage.id request "alice" true [.absent "y"] ∈ staleState.judgments ∧
    staleFold.requests[0]? = some output ∧ "alice" ∈ staleFold.cageIn.oracles ∧
    Condition.absent "y" ∈ staleFold.conditions output.request "alice" ∧
    ¬ (Condition.absent "y").holds staleFold.cageIn.trie :=
  ⟨reachableStale, by decide, by decide, rfl, by decide, by decide, by concrete⟩
-- W106 fold_evidence_binds_conditions.
example : Reachable conditional2 ∧ Step conditional2 (.fold conditionalFold)
    (afterFold conditional2 conditionalFold) := ⟨reachableConditional2, conditional_step_fold⟩
-- W107 expected_approval_lookup.
example : Reachable conditional2 ∧
    hasApproval cage request conditional2.judgments [] oracleAssumptions := by
  refine ⟨reachableConditional2, ?_⟩
  intro oracle h
  simp only [cage, List.mem_cons, List.not_mem_nil, or_false] at h
  rcases h with rfl | rfl <;> exact Or.inl (by decide)
-- W108 folder_discovery_exact.
example : Reachable z1 ∧ folderFinds z1 3 [] noOracleConditions emptyTrie zeroOutput := by
  refine ⟨reachableZ1, by decide, by concrete, by decide, ?_, ?_, ?_⟩
  · intro oracle h; cases h
  · intro condition h
    simp only [zeroOutput, request, List.mem_singleton] at h
    subst condition; rfl
  · intro oracle h; cases h
-- W109 folder_discovery_executable.
example : Reachable conditional2 ∧ Step conditional2
    (.fold (singletonFold conditional2 3 [] oracleAssumptions output "folder"))
    (afterFold conditional2 (singletonFold conditional2 3 [] oracleAssumptions output "folder")) := by
  refine ⟨reachableConditional2, .fold _ _ rfl (by decide) (fun _ h => h) ?_⟩
  refine ⟨rfl, rfl, rfl, rfl, by decide, rfl, rfl, ?_⟩
  apply FoldRun.cons
  · refine ⟨by concrete, by decide, ?_, ?_, ?_⟩
    · intro oracle h
      change oracle ∈ cage.oracles at h
      simp only [cage, List.mem_cons, List.not_mem_nil, or_false] at h
      rcases h with rfl | rfl <;> exact Or.inl (by decide)
    · intro condition h
      simp only [output, request, List.mem_singleton] at h
      subst condition; rfl
    · intro oracle _ condition h
      change condition ∈ [Condition.absent "y"] at h
      simp only [List.mem_singleton] at h
      subst condition; rfl
  exact FoldRun.nil _
-- W110 empty_fold_allowed and W111 empty_fold_earns_nothing: no oracle approval/signature.
def emptyFold : FoldTx :=
  ⟨cage, cage, [], [], [], 3, "anyone", noOracleConditions, "anyone", [], []⟩
def empty_fold_ok : foldAccepted emptyFold :=
  ⟨rfl, rfl, rfl, rfl, by decide, rfl, rfl, .nil _⟩
example : Reachable s1 ∧ Step s1 (.fold emptyFold) (afterFold s1 emptyFold) :=
  ⟨reachable1, .fold _ _ rfl (by decide) (by decide) empty_fold_ok⟩
example : Reachable s1 ∧ foldAccepted emptyFold ∧ emptyFold.requests = [] :=
  ⟨reachable1, empty_fold_ok, rfl⟩

end RequestApprovalFold.Witnesses
