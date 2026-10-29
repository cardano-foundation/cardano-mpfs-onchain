import MpfsCage.RequestApprovalFold.Model

namespace RequestApprovalFold.Witnesses

attribute [local simp] CageState.trie logicalTree Entry.logical Request.witnessValid
  withWitnessBoundary FoldTx.extractions FoldItem.extraction emptyEntries
  writeEntry putEntry Write.key Write.value writeTree witnessWriteAllowed

/-! Kernel-checked reachability traces. This file imports only Model: admitted
statements cannot contaminate antecedent witnesses. -/
def group : OracleIdentity.Description := .group 1 (.cons (.key "alice") 1 (.cons (.key "bob") 1 .nil))
def oracle : Oracle := OracleIdentity.identity group
def rec : SigningRecord := .group (.cons 1 (.key "alice") .nil)
def bobRec : SigningRecord := .group (.cons 1 (.key "bob") .nil)
def cage : CageState := ⟨⟨"policy", "registry"⟩, [oracle], "protocol", emptyEntries, none, fun _ => 0, 0, 2⟩
def request : Request := ⟨cage.id, "owner", "seed", .set "x" "v", [.absent "x"], "evidence", [(oracle, 6)], 10, 5, none⟩
def output : RequestOutput := ⟨request, 10, [tagName oracle], "request-output", [requestName cage.id], .release⟩
def create : CreateTx := ⟨[request.seed], cage, tokensOf output, [output], [], .release⟩
def evidence (v : Bool) : Evidence := ⟨group, ["alice"], rec, v, [.absent "y"]⟩
def selected (v : Bool) : Selection := fun _ => evidence v

def judge (v : Bool) : JudgmentTx := ⟨cage, output, oracle, evidence v, ⟨2, 3⟩, ["alice"], [], [(evidence v).name cage.id request oracle]⟩
def s0 := initial cage
def s1 := afterCreate s0 create output
def s2 := afterJudgment s1 (judge true)
def s3 := afterJudgment s2 (judge false)
def writeTx : FoldTx := singletonFold s3 ⟨3, 4⟩ [] (.write output (selected true)) "folder"
def accountTx (v : Bool) : FoldTx := singletonFold s3 ⟨10, 15⟩ [] (.account output (selected v)) "folder"
def s4 := afterFold s3 writeTx

def withdraw : WithdrawTx := ⟨output, ⟨16, 17⟩, ["owner"], tokensOf output, "owner", 10⟩
def claim : ClaimOutput := ⟨cage.id, "alice", "payout-script", "chosen-datum", 30, 1, "claim-output", [claimName cage.id]⟩
def createClaim : ClaimCreateTx := ⟨s4.cage, claim, ["alice"], claim.tokens⟩
def s5 := afterClaimCreate s4 createClaim
def claimTx : FoldTx := singletonFold s5 ⟨20, 25⟩ [] (.claim claim) "folder"
def s6 := afterFold s5 claimTx

def registry_ok : registryCreated cage [] := by
  simp [registryCreated, RegistryValid, cage]
def reachable0 : Reachable s0 := .registry cage [] registry_ok

def create_ok : createAllowed create output := by
  simp [createAllowed, create, wellFormed, output, request, cage, tokensOf,
    totalFees, Request.fee, requestPolicy, ruleAdmits]

def step_create : Step s0 (.create create output) s1 :=
  .create s0 create output rfl create_ok (by simp [s0, initial]) (by simp [s0, initial])
def reachable1 : Reachable s1 := .next reachable0 step_create

def authorization (v : Bool) : (evidence v).authorized oracle := by
  unfold Evidence.authorized
  decide +revert

def judge_ok (v : Bool) : judgmentAllowed (judge v) := by
  refine ⟨rfl, by simp [judge, cage], rfl, authorization v, by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, rfl, rfl⟩
def step_approve : Step s1 (.judge (judge true)) s2 :=
  .judge s1 (judge true) rfl (by simp [judge, s1, afterCreate]) (judge_ok true)
def reachable2 : Reachable s2 := .next reachable1 step_approve
def step_refuse : Step s2 (.judge (judge false)) s3 :=
  .judge s2 (judge false) rfl (by simp [judge, s2, s1, afterJudgment, afterCreate]) (judge_ok false)
def reachable3 : Reachable s3 := .next reachable2 step_refuse

def wf : wellFormed cage output := by
  simp [wellFormed, output, request, cage, totalFees, Request.fee, requestPolicy]

def approval_ok : hasApproval cage request s3.judgments [] (selected true) := by
  intro o ho
  have h : o = oracle := by simpa [cage] using ho
  subst o
  exact ⟨authorization true, rfl, Or.inl (by simp [s3, s2, s1, s0, afterJudgment, afterCreate, initial, judge, selected])⟩

def account_evidence (v : Bool) : hasAccount cage request s3.judgments (selected v) := by
  intro o ho
  have h : o = oracle := by simpa [cage] using ho
  subst o
  refine ⟨authorization v, ?_⟩
  cases v <;> simp [s3, s2, s1, s0, afterJudgment, afterCreate, initial, judge, selected]

def write_valid : stepValid cage ⟨3, 4⟩ s3.judgments [] (selected true) output := by
  refine ⟨Or.inl rfl, ?_⟩
  refine ⟨wf, by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, approval_ok, ?_, ?_⟩
  · simp [output, request, cage, Condition.holds, emptyTrie]
  · simp [selected, evidence, cage, Condition.holds, emptyTrie]

def write_ok : foldAccepted writeTx := by
  refine ⟨by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, ?_, rfl, ?_, ?_, by exact ⟨rfl, rfl, rfl, rfl, rfl⟩⟩
  · simp [writeTx, singletonFold, FoldTx.requests, FoldTx.claims, FoldItem.request, FoldItem.claimInput]
  · rfl
  · exact .cons _ _ _ _ write_valid (.nil _)

def step_write : Step s3 (.fold writeTx) s4 := by
  apply Step.fold s3 writeTx rfl
  · simp [writeTx, singletonFold, FoldTx.requests, FoldItem.request, s3, s2, s1, afterJudgment, afterCreate]
  · simp [writeTx, singletonFold, FoldTx.claims, FoldItem.claimInput]
  · exact fun _ h => h
  · exact write_ok
  · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
  · intro w h; change w ∈ ([] : List WitnessOutput) at h; contradiction

def reachable4 : Reachable s4 := .next reachable3 step_write

def account_valid (v : Bool) : accountAllowed cage ⟨10, 15⟩ s3.judgments output (selected v) :=
  ⟨wf, by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, account_evidence v⟩

def account_ok (v : Bool) : foldAccepted (accountTx v) := by
  refine ⟨by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, ?_, rfl, rfl, ?_, by exact ⟨rfl, rfl, rfl, rfl, rfl⟩⟩
  · simp [accountTx, singletonFold, FoldTx.requests, FoldTx.claims, FoldItem.request, FoldItem.claimInput]
  · exact .cons _ _ _ _ (account_valid v) (.nil _)

def step_account (v : Bool) : Step s3 (.fold (accountTx v)) (afterFold s3 (accountTx v)) := by
  apply Step.fold s3 (accountTx v) rfl
  · simp [accountTx, singletonFold, FoldTx.requests, FoldItem.request, s3, s2, s1, afterJudgment, afterCreate]
  · simp [accountTx, singletonFold, FoldTx.claims, FoldItem.claimInput]
  · exact fun _ h => h
  · exact account_ok v
  · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
  · intro w h; change w ∈ ([] : List WitnessOutput) at h; contradiction

def reachableAccount (v : Bool) : Reachable (afterFold s3 (accountTx v)) := .next reachable3 (step_account v)
def withdraw_ok : withdrawAllowed withdraw := by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert

def step_withdraw : Step s1 (.withdraw withdraw) (afterExit s1 output) :=
  .withdraw s1 withdraw (by simp [withdraw, s1, afterCreate]) withdraw_ok

def claim_create_ok : claimCreateAllowed createClaim := by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert

def step_claim_create : Step s4 (.claimCreate createClaim) s5 :=
  .claimCreate s4 createClaim rfl claim_create_ok (by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert)
def reachable5 : Reachable s5 := .next reachable4 step_claim_create

def claim_valid : claimAllowed s5.cage ⟨20, 25⟩ claim := by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert

def claim_ok : foldAccepted claimTx := by
  refine ⟨by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, ?_, rfl, rfl, ?_, by exact ⟨rfl, rfl, rfl, rfl, rfl⟩⟩
  · simp [claimTx, singletonFold, FoldTx.requests, FoldTx.claims, FoldItem.request, FoldItem.claimInput]
  · exact .cons _ _ _ _ claim_valid (.nil _)

def step_claim : Step s5 (.fold claimTx) s6 := by
  apply Step.fold s5 claimTx rfl
  · simp [claimTx, singletonFold, FoldTx.requests, FoldItem.request]
  · simp [claimTx, singletonFold, FoldTx.claims, FoldItem.claimInput, s5, afterClaimCreate, createClaim]
  · exact fun _ h => h
  · exact claim_ok
  · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
  · intro w h; change w ∈ ([] : List WitnessOutput) at h; contradiction

def reachable6 : Reachable s6 := .next reachable5 step_claim


macro "finite" : tactic => `(tactic| ((try dsimp only [Interval.valid, withdrawAllowed,
  claimCreateAllowed, claimAllowed, claimWithdrawAllowed, Evidence.authorized, exitAt, itemAllowed]); decide +revert))

def claimWithdraw : ClaimWithdrawTx := ⟨claim, ⟨30, 31⟩, ["alice"], claim.tokens, "alice", 1⟩
def step_claim_withdraw : Step s5 (.claimWithdraw claimWithdraw) (afterClaimWithdraw s5 claimWithdraw) :=
  .claimWithdraw s5 claimWithdraw (by simp [claimWithdraw, s5, afterClaimCreate, createClaim]) (by finite)

def lowClaimCreate : ClaimCreateTx := { createClaim with cageRef := cage }
def lowState := afterClaimCreate s0 lowClaimCreate

def lowReachable : Reachable lowState :=
  .next reachable0 (.claimCreate s0 lowClaimCreate rfl (by finite) (by finite))

def lowRefusal : ¬ claimAllowed lowState.cage ⟨3, 4⟩ claim := by finite

/-- The same claim first waits on zero and then sees credits earlier in its batch. -/
def fundedClaimCreate : ClaimCreateTx := { createClaim with cageRef := s3.cage }
def withClaim := afterClaimCreate s3 fundedClaimCreate
def withClaimReachable : Reachable withClaim :=
  .next reachable3 (.claimCreate s3 fundedClaimCreate rfl (by finite) (by finite))
def writeClaimItems : List FoldItem := [.write output (selected true), .claim claim]
def writeClaimTx : FoldTx :=
  ⟨cage, foldResult cage writeClaimItems, writeClaimItems, s3.judgments, [], ⟨3, 4⟩,
    "folder", "submitter", writeClaimItems.flatMap FoldItem.burned,
    foldPayments cage "folder" writeClaimItems, [], [], [], [], []⟩
def writeClaim_ok : foldAccepted writeClaimTx := by
  refine ⟨by finite, ?_, rfl, rfl, ?_, by exact ⟨rfl, rfl, rfl, rfl, rfl⟩⟩
  · change ([output.ref] ++ [claim.ref]).Nodup
    decide
  · refine FoldRun.cons cage (.write output (selected true)) [.claim claim] _ write_valid ?_
    exact .cons _ _ _ _ (by finite) (.nil _)
def step_write_claim : Step withClaim (.fold writeClaimTx) (afterFold withClaim writeClaimTx) := by
  apply Step.fold withClaim writeClaimTx rfl
  · simp [writeClaimTx, writeClaimItems, FoldTx.requests, FoldItem.request, withClaim,
      afterClaimCreate, s3, s2, s1, afterJudgment, afterCreate]
  · simp [writeClaimTx, writeClaimItems, FoldTx.claims, FoldItem.claimInput, withClaim,
      afterClaimCreate, fundedClaimCreate, createClaim]
  · exact fun _ h => h
  · exact writeClaim_ok
  · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
  · intro w h; change w ∈ ([] : List WitnessOutput) at h; contradiction

def notice : PriceNotice := ⟨oracle, priceName oracle, ⟨7, [("protocol", 9)]⟩⟩
def mintPrice : PriceMintTx := ⟨notice, group, ["alice"], [priceName oracle]⟩
def mintPrice_ok : priceMintAllowed mintPrice := by unfold priceMintAllowed; decide

def step_price : Step s5 (.priceMint mintPrice) (afterPriceMint s5 mintPrice) :=
  .priceMint s5 mintPrice mintPrice_ok
def priceState := afterPriceMint s5 mintPrice
def priceReachable : Reachable priceState := .next reachable5 step_price

def updatePrice : PriceUpdateTx := ⟨notice, { notice with datum := ⟨99, []⟩ }, group, ["bob"], []⟩
def updatePrice_ok : priceUpdateAllowed updatePrice := by unfold priceUpdateAllowed; decide

def step_update : Step priceState (.priceUpdate updatePrice) (afterPriceUpdate priceState updatePrice) :=
  .priceUpdate priceState updatePrice (by simp [updatePrice, priceState, afterPriceMint, mintPrice]) updatePrice_ok

def wrongPrice : PriceMintTx := { mintPrice with signers := [] }
def unsignedPrice_refused : ¬ priceMintAllowed wrongPrice := by unfold priceMintAllowed; decide

def deadName := (evidence true).name cage.id request oracle
def deadBurn : Step s4 (.burn deadName) (afterBurn s4 deadName) :=
  .burn s4 deadName (by simp [s4, afterFold, s3, s2, s1, s0, afterJudgment, afterCreate, initial, deadName, judge])

def history04 : History s0 s4 :=
  .next step_create (.next step_approve (.next step_refuse (.next step_write (.refl _))))

/-- A different canonical signer record is selectable for the same oracle. -/
def bobEvidence : Evidence := ⟨group, ["bob"], bobRec, false, []⟩
def bobSelected : Selection := fun _ => bobEvidence
def bobJudge : JudgmentTx := ⟨cage, output, oracle, bobEvidence, ⟨2, 3⟩, ["bob"], [], [bobEvidence.name cage.id request oracle]⟩
def bobState := afterJudgment s3 bobJudge
def bobJudge_ok : judgmentAllowed bobJudge := by
  unfold judgmentAllowed Evidence.authorized Interval.valid
  decide

def bobStep : Step s3 (.judge bobJudge) bobState :=
  .judge s3 bobJudge rfl (by simp [bobJudge, s3, s2, s1, afterJudgment, afterCreate]) bobJudge_ok
def bobReachable : Reachable bobState := .next reachable3 bobStep

def bobAccountValid : accountAllowed cage ⟨10, 15⟩ bobState.judgments output bobSelected := by
  refine ⟨wf, by finite, by finite, by finite, ?_⟩
  intro o ho
  have h : o = oracle := by simpa [cage] using ho
  subst o
  exact ⟨by finite, by simp [bobState, afterJudgment, bobJudge, bobSelected, output]⟩

def recordChangesPayee :
 OracleIdentity.paidTo (credits cage request (selected true)) "alice" = 6 ∧
 OracleIdentity.paidTo (credits cage request bobSelected) "alice" = 0 ∧
 OracleIdentity.paidTo (credits cage request bobSelected) "bob" = 6 := by decide

namespace Zero

def rule : Rule := ⟨"creator-rule", fun r sigs => r.owner = "owner" ∧ "creator" ∈ sigs⟩
def cage : CageState := { Witnesses.cage with oracles := [], rule := some rule }
def output : RequestOutput :=
 { Witnesses.output with request := { Witnesses.request with fees := [] }, tags := [], policy := .rule "creator-rule" }
def create : CreateTx := ⟨[], cage, tokensOf output, [output], ["creator"], .rule "creator-rule"⟩
def initialState := initial cage
def created := afterCreate initialState create output

def registry_ok : registryCreated cage [] := by
  simp [registryCreated, RegistryValid, cage, Witnesses.cage]
def reachable0 : Reachable initialState := .registry cage [] registry_ok

def create_ok : createAllowed create output := by
  simp [createAllowed, create, wellFormed, ruleAdmits, requestPolicy, totalFees,
    cage, output, rule, tokensOf, Witnesses.cage, Witnesses.output, Witnesses.request]
def createStep : Step initialState (.create create output) created :=
  .create initialState create output rfl create_ok (by simp [create]) (by simp [initialState, initial])
def reachable1 : Reachable created := .next reachable0 createStep

def writeTx : FoldTx := singletonFold created ⟨3, 4⟩ [] (.write output (selected true)) "folder"
def write_valid : stepValid cage ⟨3, 4⟩ [] [] (selected true) output := by
  simp [stepValid, wellFormed, hasApproval, cage, output, totalFees, requestPolicy,
    Interval.valid, Witnesses.output, Witnesses.request, Witnesses.cage, Condition.holds, emptyTrie, rule]
def write_ok : foldAccepted writeTx := by
  refine ⟨by finite, ?_, rfl, rfl, ?_, by exact ⟨rfl, rfl, rfl, rfl, rfl⟩⟩
  · simp [writeTx, singletonFold, FoldTx.requests, FoldTx.claims, FoldItem.request, FoldItem.claimInput]
  · exact .cons _ _ _ _ write_valid (.nil _)
def writeStep : Step created (.fold writeTx) (afterFold created writeTx) := by
  apply Step.fold created writeTx rfl
  · simp [writeTx, singletonFold, FoldTx.requests, FoldItem.request, created, afterCreate, create]
  · simp [writeTx, singletonFold, FoldTx.claims, FoldItem.claimInput]
  · exact fun _ h => h
  · exact write_ok
  · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
  · intro w h; change w ∈ ([] : List WitnessOutput) at h; contradiction

def accountTx : FoldTx := singletonFold created ⟨10, 15⟩ [] (.account output (selected false)) "folder"
def account_valid : accountAllowed cage ⟨10, 15⟩ [] output (selected false) := by
  simp [accountAllowed, wellFormed, hasAccount, cage, output, totalFees, requestPolicy,
    Interval.valid, Witnesses.output, Witnesses.request, Witnesses.cage, rule]
def account_ok : foldAccepted accountTx := by
  refine ⟨by finite, ?_, rfl, rfl, ?_, by exact ⟨rfl, rfl, rfl, rfl, rfl⟩⟩
  · simp [accountTx, singletonFold, FoldTx.requests, FoldTx.claims, FoldItem.request, FoldItem.claimInput]
  · exact .cons _ _ _ _ account_valid (.nil _)
def accountStep : Step created (.fold accountTx) (afterFold created accountTx) := by
  apply Step.fold created accountTx rfl
  · simp [accountTx, singletonFold, FoldTx.requests, FoldItem.request, created, afterCreate, create]
  · simp [accountTx, singletonFold, FoldTx.claims, FoldItem.claimInput]
  · exact fun _ h => h
  · exact account_ok
  · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
  · intro w h; change w ∈ ([] : List WitnessOutput) at h; contradiction

def withdraw : WithdrawTx := { Witnesses.withdraw with input := output, burned := tokensOf output }
def withdrawStep : Step created (.withdraw withdraw) (afterExit created output) :=
  .withdraw created withdraw (by simp [withdraw, created, afterCreate]) (by finite)
end Zero

namespace Ruled
def group : OracleIdentity.Description := .group 1 (.cons (.key "alice") 1 (.cons (.key "bob") 1 .nil))
def oracle : Oracle := OracleIdentity.identity group
def rec : SigningRecord := .group (.cons 1 (.key "alice") .nil)
def bobRec : SigningRecord := .group (.cons 1 (.key "bob") .nil)
def cage : CageState := ⟨⟨"policy", "registry"⟩, [oracle], "protocol", emptyEntries, some Zero.rule, fun _ => 0, 0, 2⟩
def request : Request := ⟨cage.id, "owner", "seed", .set "x" "v", [.absent "x"], "evidence", [(oracle, 6)], 10, 5, none⟩
def output : RequestOutput := ⟨request, 10, [tagName oracle], "request-output", [requestName cage.id], .rule "creator-rule"⟩
def create : CreateTx := ⟨[request.seed], cage, tokensOf output, [output], ["creator"], .rule "creator-rule"⟩
def evidence (v : Bool) : Evidence := ⟨group, ["alice"], rec, v, [.absent "y"]⟩
def selected (v : Bool) : Selection := fun _ => evidence v

def judge (v : Bool) : JudgmentTx := ⟨cage, output, oracle, evidence v, ⟨2, 3⟩, ["alice"], [], [(evidence v).name cage.id request oracle]⟩
def s0 := initial cage
def s1 := afterCreate s0 create output
def s2 := afterJudgment s1 (judge true)
def s3 := afterJudgment s2 (judge false)
def writeTx : FoldTx := singletonFold s3 ⟨3, 4⟩ [] (.write output (selected true)) "folder"
def accountTx (v : Bool) : FoldTx := singletonFold s3 ⟨10, 15⟩ [] (.account output (selected v)) "folder"
def s4 := afterFold s3 writeTx

def withdraw : WithdrawTx := ⟨output, ⟨16, 17⟩, ["owner"], tokensOf output, "owner", 10⟩
def claim : ClaimOutput := ⟨cage.id, "alice", "payout-script", "chosen-datum", 30, 1, "claim-output", [claimName cage.id]⟩
def createClaim : ClaimCreateTx := ⟨s4.cage, claim, ["alice"], claim.tokens⟩
def s5 := afterClaimCreate s4 createClaim
def claimTx : FoldTx := singletonFold s5 ⟨20, 25⟩ [] (.claim claim) "folder"
def s6 := afterFold s5 claimTx

def registry_ok : registryCreated cage [] := by
  simp [registryCreated, RegistryValid, cage]
def reachable0 : Reachable s0 := .registry cage [] registry_ok

def create_ok : createAllowed create output := by
  simp [createAllowed, create, wellFormed, output, request, cage, tokensOf,
    totalFees, Request.fee, requestPolicy, ruleAdmits, Zero.rule]

def step_create : Step s0 (.create create output) s1 :=
  .create s0 create output rfl create_ok (by simp [s0, initial]) (by simp [s0, initial])
def reachable1 : Reachable s1 := .next reachable0 step_create

def authorization (v : Bool) : (evidence v).authorized oracle := by
  unfold Evidence.authorized
  decide +revert

def judge_ok (v : Bool) : judgmentAllowed (judge v) := by
  refine ⟨rfl, by simp [judge, cage], rfl, authorization v, by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, rfl, rfl⟩
def step_approve : Step s1 (.judge (judge true)) s2 :=
  .judge s1 (judge true) rfl (by simp [judge, s1, afterCreate]) (judge_ok true)
def reachable2 : Reachable s2 := .next reachable1 step_approve
def step_refuse : Step s2 (.judge (judge false)) s3 :=
  .judge s2 (judge false) rfl (by simp [judge, s2, s1, afterJudgment, afterCreate]) (judge_ok false)
def reachable3 : Reachable s3 := .next reachable2 step_refuse

def wf : wellFormed cage output := by
  simp [wellFormed, output, request, cage, totalFees, Request.fee, requestPolicy, Zero.rule]

def approval_ok : hasApproval cage request s3.judgments [] (selected true) := by
  intro o ho
  have h : o = oracle := by simpa [cage] using ho
  subst o
  exact ⟨authorization true, rfl, Or.inl (by simp [s3, s2, s1, s0, afterJudgment, afterCreate, initial, judge, selected])⟩

def account_evidence (v : Bool) : hasAccount cage request s3.judgments (selected v) := by
  intro o ho
  have h : o = oracle := by simpa [cage] using ho
  subst o
  refine ⟨authorization v, ?_⟩
  cases v <;> simp [s3, s2, s1, s0, afterJudgment, afterCreate, initial, judge, selected]

def write_valid : stepValid cage ⟨3, 4⟩ s3.judgments [] (selected true) output := by
  refine ⟨Or.inl rfl, ?_⟩
  refine ⟨wf, by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, approval_ok, ?_, ?_⟩
  · simp [output, request, cage, Condition.holds, emptyTrie]
  · simp [selected, evidence, cage, Condition.holds, emptyTrie]

def write_ok : foldAccepted writeTx := by
  refine ⟨by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, ?_, rfl, ?_, ?_, by exact ⟨rfl, rfl, rfl, rfl, rfl⟩⟩
  · simp [writeTx, singletonFold, FoldTx.requests, FoldTx.claims, FoldItem.request, FoldItem.claimInput]
  · rfl
  · exact .cons _ _ _ _ write_valid (.nil _)

def step_write : Step s3 (.fold writeTx) s4 := by
  apply Step.fold s3 writeTx rfl
  · simp [writeTx, singletonFold, FoldTx.requests, FoldItem.request, s3, s2, s1, afterJudgment, afterCreate]
  · simp [writeTx, singletonFold, FoldTx.claims, FoldItem.claimInput]
  · exact fun _ h => h
  · exact write_ok
  · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
  · intro w h; change w ∈ ([] : List WitnessOutput) at h; contradiction

def reachable4 : Reachable s4 := .next reachable3 step_write

def account_valid (v : Bool) : accountAllowed cage ⟨10, 15⟩ s3.judgments output (selected v) :=
  ⟨wf, by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, account_evidence v⟩

def account_ok (v : Bool) : foldAccepted (accountTx v) := by
  refine ⟨by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, ?_, rfl, rfl, ?_, by exact ⟨rfl, rfl, rfl, rfl, rfl⟩⟩
  · simp [accountTx, singletonFold, FoldTx.requests, FoldTx.claims, FoldItem.request, FoldItem.claimInput]
  · exact .cons _ _ _ _ (account_valid v) (.nil _)

def step_account (v : Bool) : Step s3 (.fold (accountTx v)) (afterFold s3 (accountTx v)) := by
  apply Step.fold s3 (accountTx v) rfl
  · simp [accountTx, singletonFold, FoldTx.requests, FoldItem.request, s3, s2, s1, afterJudgment, afterCreate]
  · simp [accountTx, singletonFold, FoldTx.claims, FoldItem.claimInput]
  · exact fun _ h => h
  · exact account_ok v
  · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
  · intro w h; change w ∈ ([] : List WitnessOutput) at h; contradiction

def reachableAccount (v : Bool) : Reachable (afterFold s3 (accountTx v)) := .next reachable3 (step_account v)
def withdraw_ok : withdrawAllowed withdraw := by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert

def step_withdraw : Step s1 (.withdraw withdraw) (afterExit s1 output) :=
  .withdraw s1 withdraw (by simp [withdraw, s1, afterCreate]) withdraw_ok

def claim_create_ok : claimCreateAllowed createClaim := by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert

def step_claim_create : Step s4 (.claimCreate createClaim) s5 :=
  .claimCreate s4 createClaim rfl claim_create_ok (by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert)
def reachable5 : Reachable s5 := .next reachable4 step_claim_create

def claim_valid : claimAllowed s5.cage ⟨20, 25⟩ claim := by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert

def claim_ok : foldAccepted claimTx := by
  refine ⟨by (try dsimp only [Interval.valid, withdrawAllowed, claimCreateAllowed, claimAllowed]); decide +revert, ?_, rfl, rfl, ?_, by exact ⟨rfl, rfl, rfl, rfl, rfl⟩⟩
  · simp [claimTx, singletonFold, FoldTx.requests, FoldTx.claims, FoldItem.request, FoldItem.claimInput]
  · exact .cons _ _ _ _ claim_valid (.nil _)

def step_claim : Step s5 (.fold claimTx) s6 := by
  apply Step.fold s5 claimTx rfl
  · simp [claimTx, singletonFold, FoldTx.requests, FoldItem.request]
  · simp [claimTx, singletonFold, FoldTx.claims, FoldItem.claimInput, s5, afterClaimCreate, createClaim]
  · exact fun _ h => h
  · exact claim_ok
  · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
  · intro w h; change w ∈ ([] : List WitnessOutput) at h; contradiction

def reachable6 : Reachable s6 := .next reachable5 step_claim



def burnStep : Step s4 (.burn ((evidence true).name cage.id request oracle))
 (afterBurn s4 ((evidence true).name cage.id request oracle)) :=
 .burn s4 _ (by simp [s4, afterFold, s3, s2, s1, s0, afterJudgment, afterCreate, initial, judge])
end Ruled


namespace Batch

def unsetOutput : RequestOutput := { output with
  ref := "unset-output"
  request := { request with seed := "unset-seed", write := .unset "x", conditions := [] } }
def againOutput : RequestOutput := { output with ref := "again-output", request := { request with seed := "again-seed" } }
def createUnset : CreateTx := { create with spent := ["unset-seed"], outputs := [unsetOutput] }
def createAgain : CreateTx := { create with spent := ["again-seed"], outputs := [againOutput] }
def withUnset := afterCreate s1 createUnset unsetOutput
def withAgain := afterCreate withUnset createAgain againOutput

def unsetCreate_ok : createAllowed createUnset unsetOutput := by
  simp [createAllowed, createUnset, create, wellFormed, unsetOutput, output, request, cage, tokensOf,
    totalFees, Request.fee, requestPolicy, ruleAdmits]
def againCreate_ok : createAllowed createAgain againOutput := by
  simp [createAllowed, createAgain, create, wellFormed, againOutput, output, request, cage, tokensOf,
    totalFees, Request.fee, requestPolicy, ruleAdmits]
def unsetStep : Step s1 (.create createUnset unsetOutput) withUnset :=
  .create s1 createUnset unsetOutput rfl unsetCreate_ok (by finite) (by finite)
def againStep : Step withUnset (.create createAgain againOutput) withAgain :=
  .create withUnset createAgain againOutput rfl againCreate_ok (by finite) (by finite)
def reachable : Reachable withAgain := .next (.next reachable1 unsetStep) againStep

def items : List FoldItem := [.write output (selected true), .write unsetOutput (selected true), .write againOutput (selected true)]
def tx : FoldTx := ⟨cage, foldResult cage items, items, [], ["alice"], ⟨3, 4⟩,
  "folder", "submitter", items.flatMap FoldItem.burned, foldPayments cage "folder" items, [], [], [], [], []⟩

def firstValid : stepValid cage ⟨3, 4⟩ [] ["alice"] (selected true) output := by
  refine ⟨Or.inl rfl, ?_⟩
  refine ⟨wf, by finite, by finite, ?_, ?_, ?_⟩
  · intro o ho
    have h : o = oracle := by simpa [cage] using ho
    subst o
    exact ⟨authorization true, rfl, Or.inr rfl⟩
  · simp [output, request, cage, Condition.holds, emptyTrie]
  · simp [selected, evidence, cage, Condition.holds, emptyTrie]

def afterFirst := itemResult cage (.write output (selected true))
def afterUnset := itemResult afterFirst (.write unsetOutput (selected true))

def unsetValid : stepValid afterFirst ⟨3, 4⟩ [] ["alice"] (selected true) unsetOutput := by
  refine ⟨Or.inl rfl, ?_⟩
  refine ⟨?_, by finite, by finite, ?_, ?_, ?_⟩
  · simp [wellFormed, afterFirst, itemResult, credit, unsetOutput, output, request,
      cage, totalFees, Request.fee, requestPolicy]
  · intro o ho
    have h : o = oracle := by simpa [afterFirst, itemResult, credit, cage] using ho
    subst o
    exact ⟨authorization true, rfl, Or.inr rfl⟩
  · simp [unsetOutput, request]
  · simp [selected, evidence, afterFirst, itemResult, credit, cage, output, request,
      Condition.holds, Write.apply, emptyTrie]

def againValid : stepValid afterUnset ⟨3, 4⟩ [] ["alice"] (selected true) againOutput := by
  refine ⟨Or.inl rfl, ?_⟩
  refine ⟨?_, by finite, by finite, ?_, ?_, ?_⟩
  · simp [wellFormed, afterUnset, afterFirst, itemResult, credit, againOutput, unsetOutput,
      output, request, cage, totalFees, Request.fee, requestPolicy]
  · intro o ho
    have h : o = oracle := by simpa [afterUnset, afterFirst, itemResult, credit, cage] using ho
    subst o
    exact ⟨authorization true, rfl, Or.inr rfl⟩
  · simp [againOutput, unsetOutput, output, request, afterUnset, afterFirst, itemResult,
      credit, cage, Condition.holds, Write.apply]
  · simp [selected, evidence, afterUnset, afterFirst, itemResult, credit, cage, output, request,
      unsetOutput, Condition.holds, Write.apply, emptyTrie]

def accepted : foldAccepted tx := by
  refine ⟨by finite, ?_, rfl, rfl, ?_, by exact ⟨rfl, rfl, rfl, rfl, rfl⟩⟩
  · change ([output.ref, unsetOutput.ref, againOutput.ref] ++ []).Nodup
    decide
  · exact .cons _ _ _ _ firstValid (.cons _ _ _ _ unsetValid (.cons _ _ _ _ againValid (.nil _)))
def step : Step withAgain (.fold tx) (afterFold withAgain tx) := by
  apply Step.fold withAgain tx rfl
  · simp [tx, items, FoldTx.requests, FoldItem.request, withAgain, withUnset, s1, afterCreate]
  · simp [tx, items, FoldTx.claims, FoldItem.claimInput]
  · simp [tx]
  · exact accepted
  · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
  · intro w h; change w ∈ ([] : List WitnessOutput) at h; contradiction

def spentOnce : SpentOnce [create, createAgain] := by
  intro a b seed ha hb hsa hsb
  simp only [List.mem_cons, List.not_mem_nil, or_false] at ha hb
  rcases ha with rfl | rfl <;> rcases hb with rfl | rfl
  · rfl
  · have h1 : seed = "seed" := by simpa [create, request] using hsa
    have h2 : seed = "again-seed" := by simpa [createAgain] using hsb
    simp [h1] at h2
  · have h1 : seed = "again-seed" := by simpa [createAgain] using hsa
    have h2 : seed = "seed" := by simpa [create, request] using hsb
    simp [h1] at h2
  · rfl
end Batch

namespace Blind

def output : RequestOutput := { Witnesses.output with request := { request with conditions := [] } }
def create : CreateTx := { Witnesses.create with outputs := [output] }
def state := afterCreate s0 create output

def create_ok : createAllowed create output := by
  simp [createAllowed, create, Witnesses.create, wellFormed, output, Witnesses.output,
    request, cage, tokensOf, totalFees, Request.fee, requestPolicy, ruleAdmits]
def reachable : Reachable state :=
  .next reachable0 (.create s0 create output rfl create_ok (by simp [s0, initial]) (by simp [s0, initial]))
def selected : Selection := fun _ => { evidence true with conditions := [] }
def approval : hasApproval cage output.request [] ["alice"] selected := by
  intro o ho
  have h : o = oracle := by simpa [cage] using ho
  subst o
  exact ⟨authorization true, rfl, Or.inr rfl⟩
end Blind


namespace Stale

def evidence : Evidence := { Witnesses.evidence true with conditions := [.present "y"] }
def selected : Selection := fun _ => evidence
def judge : JudgmentTx := { Witnesses.judge true with
  evidence := evidence
  minted := [evidence.name cage.id request oracle] }
def state := afterJudgment s1 judge

def judge_ok : judgmentAllowed judge := by
  unfold judgmentAllowed Evidence.authorized Interval.valid
  decide

def step : Step s1 (.judge judge) state :=
  .judge s1 judge rfl (by simp [judge, Witnesses.judge, s1, afterCreate]) judge_ok
def reachable : Reachable state := .next reachable1 step

def tx : FoldTx := singletonFold state ⟨3, 4⟩ [] (.write output selected) "folder"
def falseCondition : ¬ Condition.holds (atTurn tx 0).trie (.present "y") := by
  simp [Condition.holds, atTurn, tx, singletonFold, foldResult, state, afterJudgment,
    s1, s0, initial, afterCreate, cage, emptyTrie]
end Stale

def writeAntecedent : Reachable s3 ∧ Step s3 (.fold writeTx) s4 ∧ foldAccepted writeTx ∧
 writeTx.items[0]? = some (FoldItem.write output (selected true)) :=
 ⟨reachable3, step_write, write_ok, rfl⟩
def accountAntecedent (v : Bool) : Reachable s3 ∧
 Step s3 (.fold (accountTx v)) (afterFold s3 (accountTx v)) ∧ foldAccepted (accountTx v) ∧
 (accountTx v).items[0]? = some (FoldItem.account output (selected v)) :=
 ⟨reachable3, step_account v, account_ok v, rfl⟩
def claimAntecedent : Reachable s5 ∧ Step s5 (.fold claimTx) s6 ∧ foldAccepted claimTx ∧
 claimTx.items[0]? = some (FoldItem.claim claim) := ⟨reachable5, step_claim, claim_ok, rfl⟩
def createAntecedent : Reachable s0 ∧ Step s0 (.create create output) s1 ∧ createAllowed create output :=
 ⟨reachable0, step_create, create_ok⟩
def judgeAntecedent : Reachable s1 ∧ Step s1 (.judge (judge true)) s2 ∧ judgmentAllowed (judge true) :=
 ⟨reachable1, step_approve, judge_ok true⟩
def liveAntecedent : Reachable s1 ∧ output ∈ s1.live := ⟨reachable1, by simp [s1, afterCreate]⟩
def removalAntecedent : Reachable s3 ∧ Step s3 (.fold writeTx) s4 ∧ output ∈ s3.live ∧ output ∉ s4.live :=
 ⟨reachable3, step_write, by simp [s3, s2, s1, afterJudgment, afterCreate], by
   simp [s4, afterFold, removeRequests, writeTx, singletonFold, FoldTx.requests, FoldItem.request]⟩
def ruledAntecedent : Reachable Zero.initialState ∧
 Step Zero.initialState (.create Zero.create Zero.output) Zero.created ∧
 Zero.cage.rule = some Zero.rule := ⟨Zero.reachable0, Zero.createStep, rfl⟩
def zeroAntecedent : Reachable Zero.created ∧ Zero.created.cage.oracles = [] ∧
 Step Zero.created (.fold Zero.writeTx) (afterFold Zero.created Zero.writeTx) ∧
 Step Zero.created (.fold Zero.accountTx) (afterFold Zero.created Zero.accountTx) :=
 ⟨Zero.reachable1, rfl, Zero.writeStep, Zero.accountStep⟩



namespace OtherRegistry

def cage : CageState := { Witnesses.cage with id := ⟨"policy", "second-registry"⟩ }
def output : RequestOutput := { Witnesses.output with
  request := { request with cage := cage.id }
  requestTokens := [requestName cage.id] }
def create : CreateTx := ⟨["seed"], cage, tokensOf output, [output], [], .release⟩
def state := afterCreate (initial cage) create output

def registry_ok : registryCreated cage [] := by
  simp [registryCreated, RegistryValid, cage, Witnesses.cage]
def create_ok : createAllowed create output := by
  simp [createAllowed, create, wellFormed, output, request, cage, tokensOf,
    totalFees, Request.fee, requestPolicy, ruleAdmits, Witnesses.cage, Witnesses.output]
def reachable : Reachable state :=
 .next (.registry cage [] registry_ok)
  (.create (initial cage) create output rfl create_ok (by simp [initial]) (by simp [initial]))
end OtherRegistry

/-- Reachable antecedent for T01: applyAll_append. -/
def W01 : Reachable s0 ∧ (applyAll emptyTrie [.set "x" "v", .unset "x"]) "x" = none :=
 ⟨reachable0, rfl⟩

/-- Reachable antecedent for T02: foldRun_step_valid. -/
def W02 : Reachable s3 ∧ FoldRun writeTx.interval writeTx.refs writeTx.signers cage writeTx.items writeTx.cageOut ∧ writeTx.items[0]? = some (FoldItem.write output (selected true)) :=
 ⟨reachable3, write_ok.2.2.2.2.1, rfl⟩

/-- Reachable antecedent for T03: foldRun_result. -/
def W03 : Reachable s3 ∧ FoldRun writeTx.interval writeTx.refs writeTx.signers cage writeTx.items writeTx.cageOut ∧ writeTx.items[0]? = some (FoldItem.write output (selected true)) :=
 ⟨reachable3, write_ok.2.2.2.2.1, rfl⟩

/-- Reachable antecedent for T04: foldRun_conditions. -/
def W04 : Reachable s3 ∧ FoldRun writeTx.interval writeTx.refs writeTx.signers cage writeTx.items writeTx.cageOut ∧ writeTx.items[0]? = some (FoldItem.write output (selected true)) :=
 ⟨reachable3, write_ok.2.2.2.2.1, rfl⟩

/-- Reachable antecedent for T05: applyAll_keeps_present. -/
def W05 : Reachable s4 ∧ (s4.cage.trie "x").isSome = true ∧ (∀ w ∈ [Write.set "x" "v2"], w ≠ .unset "x") :=
 ⟨reachable4, rfl, by simp⟩

/-- Reachable antecedent for T06: registry_creation. -/
def W06 : Reachable s0 ∧ registryCreated cage [] :=
 ⟨reachable0, registry_ok⟩

/-- Reachable antecedent for T07: create_tags_existing_cage. -/
def W07 := createAntecedent

/-- Reachable antecedent for T08: requests_unique_in_history. -/
def W08 : Reachable Batch.withAgain ∧ SpentOnce [create, Batch.createAgain] ∧ createAllowed create output ∧ createAllowed Batch.createAgain Batch.againOutput ∧ create.cageRef.oracles ≠ [] ∧ Batch.createAgain.cageRef.oracles ≠ [] ∧ create ≠ Batch.createAgain :=
 by
 refine ⟨Batch.reachable, Batch.spentOnce, create_ok, Batch.againCreate_ok, by simp [create, cage], by simp [Batch.createAgain, create, cage], ?_⟩
 intro h
 have h' := congrArg CreateTx.spent h
 have : (["seed"] : List String) = ["again-seed"] := h'
 contradiction

/-- Reachable antecedent for T09: judgment_authorized_and_bound. -/
def W09 := judgeAntecedent

/-- Reachable antecedent for T10: judgment_not_replayable. -/
def W10 : Reachable s2 ∧ judgmentName cage.id request oracle true rec [.absent "y"] = (evidence true).name cage.id request oracle :=
 ⟨reachable2, rfl⟩

/-- Reachable antecedent for T11: token_roles_separated. -/
def W11 : Reachable s2 ∧ tagName oracle ∈ output.tags ∧ (evidence true).name cage.id request oracle ∈ s2.judgments :=
 ⟨reachable2, by decide, by simp [s2, afterJudgment, judge]⟩

/-- Reachable antecedent for T12: fold_preserves_registry. -/
def W12 := writeAntecedent

/-- Reachable antecedent for T13: step_preserves_registry. -/
def W13 := writeAntecedent

/-- Reachable antecedent for T14: history_preserves_registry. -/
def W14 : Reachable s0 ∧ History s0 s4 :=
 ⟨reachable0, history04⟩

/-- Reachable antecedent for T15: only_fold_changes_tree. -/
def W15 : Reachable s3 ∧ Step s3 (.fold writeTx) s4 ∧ s4.cage.trie ≠ s3.cage.trie := by
 refine ⟨reachable3, step_write, ?_⟩
 intro h
 have hx := congrFun h "x"
 contradiction

/-- Reachable antecedent for T16: fold_only_approved_before_deadline. -/
def W16 := writeAntecedent

/-- Reachable antecedent for T17: fold_conditions_hold_when_applied. -/
def W17 := writeAntecedent

/-- Reachable antecedent for T18: fold_root_is_folded_writes. -/
def W18 := writeAntecedent

/-- Reachable antecedent for T19: fold_burns_tags. -/
def W19 := writeAntecedent

/-- Reachable antecedent for T20: fold_pays_and_keeps_rest. -/
def W20 := writeAntecedent

/-- Reachable antecedent for T21: allocation_conserves_value. -/
def W21 : Reachable s3 ∧ stepValid cage ⟨3,4⟩ s3.judgments [] (selected true) output ∧ accountAllowed cage ⟨10,15⟩ s3.judgments output (selected false) :=
 ⟨reachable3, write_valid, account_valid false⟩

/-- Reachable antecedent for T22: blind_write_folds_on_any_tree. -/
def W22 : Reachable Blind.state ∧ wellFormed cage Blind.output ∧ (⟨3,4⟩ : Interval).valid ∧ 4 < Blind.output.request.deadline ∧ hasApproval cage Blind.output.request [] ["alice"] Blind.selected ∧ Blind.output.request.conditions = [] ∧ (∀ o ∈ cage.oracles, (Blind.selected o).conditions = []) :=
 ⟨Blind.reachable, Blind.create_ok.2.2.2.1, by finite, by finite, Blind.approval, rfl, by simp [Blind.selected]⟩

/-- Reachable antecedent for T23: fold_permissionless. -/
def W23 := writeAntecedent

/-- Reachable antecedent for T24: absent_inserts_exclusive. -/
def W24 : Reachable Batch.withAgain ∧ foldAccepted Batch.tx ∧ (0 : Nat) < 2 ∧ Batch.tx.items[0]? = some (FoldItem.write output (selected true)) ∧ Batch.tx.items[2]? = some (FoldItem.write Batch.againOutput (selected true)) ∧ output.request.write = .set "x" "v" ∧ Condition.absent "x" ∈ Batch.againOutput.request.conditions :=
 ⟨Batch.reachable, Batch.accepted, by decide, rfl, rfl, rfl, by decide⟩

/-- Reachable antecedent for T25: account_complete_and_pays. -/
def W25 := accountAntecedent false

/-- Reachable antecedent for T26: account_anyone_in_window. -/
def W26 := accountAntecedent false

/-- Reachable antecedent for T27: account_fee_neutral. -/
def W27 : Reachable s3 ∧ accountAllowed cage ⟨10,15⟩ s3.judgments output (selected true) ∧ accountAllowed cage ⟨10,15⟩ s3.judgments output (selected false) ∧ (∀ o ∈ cage.oracles, (selected true o).record = (selected false o).record) :=
 ⟨reachable3, account_valid true, account_valid false, by intros; rfl⟩

/-- Reachable antecedent for T28: withdraw_only_owner_after_window. -/
def W28 : Reachable s1 ∧ Step s1 (.withdraw withdraw) (afterExit s1 output) ∧ withdrawAllowed withdraw :=
 ⟨reachable1, step_withdraw, withdraw_ok⟩

/-- Reachable antecedent for T29: owner_can_withdraw_everything. -/
def W29 : Reachable s1 ∧ Step s1 (.withdraw withdraw) (afterExit s1 output) ∧ withdrawAllowed withdraw :=
 ⟨reachable1, step_withdraw, withdraw_ok⟩

/-- Reachable antecedent for T30: request_spent_only_by_lifecycle. -/
def W30 : Reachable s3 ∧ requestSpendAllowed output (.folded writeTx) ∧ requestSpendAllowed output (.folded (accountTx false)) ∧ requestSpendAllowed output (.withdrawn withdraw) :=
 ⟨reachable3, ⟨write_ok, by simp [writeTx, singletonFold, FoldTx.requests, FoldItem.request]⟩, ⟨account_ok false, by simp [accountTx, singletonFold, FoldTx.requests, FoldItem.request]⟩, ⟨withdraw_ok, rfl⟩⟩

/-- Reachable antecedent for T31: every_exit_burns_tag. -/
def W31 : Reachable s3 ∧ requestSpendAllowed output (.folded writeTx) ∧ writeTx.interval.lower < output.request.deadline ∧ writeTx.interval.lower ≤ output.request.deadline + output.request.window :=
 ⟨reachable3, ⟨write_ok, by simp [writeTx, singletonFold, FoldTx.requests, FoldItem.request]⟩, by decide, by decide⟩

/-- Reachable antecedent for T32: early_exit_requires_all_judgments. -/
def W32 : Reachable s3 ∧ requestSpendAllowed output (.folded writeTx) ∧ writeTx.interval.lower < output.request.deadline ∧ writeTx.interval.lower ≤ output.request.deadline + output.request.window :=
 ⟨reachable3, ⟨write_ok, by simp [writeTx, singletonFold, FoldTx.requests, FoldItem.request]⟩, by decide, by decide⟩

/-- Reachable antecedent for T33: early_exit_pays_every_oracle. -/
def W33 : Reachable s3 ∧ requestSpendAllowed output (.folded writeTx) ∧ writeTx.interval.lower < output.request.deadline ∧ writeTx.interval.lower ≤ output.request.deadline + output.request.window :=
 ⟨reachable3, ⟨write_ok, by simp [writeTx, singletonFold, FoldTx.requests, FoldItem.request]⟩, by decide, by decide⟩

/-- Reachable antecedent for T34: before_deadline_only_approvals. -/
def W34 : Reachable s3 ∧ requestSpendAllowed output (.folded writeTx) ∧ writeTx.interval.lower < output.request.deadline ∧ writeTx.interval.lower ≤ output.request.deadline + output.request.window :=
 ⟨reachable3, ⟨write_ok, by simp [writeTx, singletonFold, FoldTx.requests, FoldItem.request]⟩, by decide, by decide⟩

/-- Reachable antecedent for T35: dead_judgment_can_burn. -/
def W35 : Reachable s4 ∧ deadName ∈ s4.judgments ∧ (∀ o ∈ s4.live, o.request ≠ request) ∧ Step s4 (.burn deadName) (afterBurn s4 deadName) :=
 ⟨reachable4, by simp [s4, afterFold, s3, s2, s1, afterJudgment, afterCreate, deadName, judge], by simp [s4, afterFold, removeRequests, writeTx, singletonFold, FoldTx.requests, FoldItem.request, s3, s2, s1, s0, afterJudgment, afterCreate, initial], deadBurn⟩

/-- Reachable antecedent for T36: judgments_do_not_consume. -/
def W36 := judgeAntecedent

/-- Reachable antecedent for T37: exits_remove_consumed. -/
def W37 : Reachable (afterExit s1 output) :=
 Reachable.next reachable1 step_withdraw

/-- Reachable antecedent for T38: fold_removes_consumed. -/
def W38 : Reachable s4 ∧ output ∈ writeTx.requests :=
 ⟨reachable4, by simp [writeTx, singletonFold, FoldTx.requests, FoldItem.request]⟩

/-- Reachable antecedent for T39: used_seeds_monotone. -/
def W39 : Reachable s1 ∧ Step s1 (.judge (judge true)) s2 ∧ request.seed ∈ s1.usedSeeds ∧ output.ref ∈ s1.usedOutputs :=
 ⟨reachable1, step_approve, by decide, by decide⟩

/-- Reachable antecedent for T40: reachable_requests_have_spent_seeds. -/
def W40 := liveAntecedent

/-- Reachable antecedent for T41: spent_seed_cannot_create_again. -/
def W41 : Reachable s4 ∧ s4.cage.oracles ≠ [] ∧ output.request.seed ∈ s4.usedSeeds :=
 ⟨reachable4, by simp [s4, afterFold, writeTx, singletonFold, itemResult, credit, s3, s2, s1, s0, afterJudgment, afterCreate, initial, cage], by decide⟩

/-- Reachable antecedent for T42: request_never_reappears. -/
def W42 : Reachable s4 ∧ output.ref ∈ s4.usedOutputs ∧ output ∉ s4.live ∧ History s4 (afterBurn s4 deadName) :=
 ⟨reachable4, by decide, removalAntecedent.2.2.2, .next deadBurn (.refl _)⟩

/-- Reachable antecedent for T43: one_oracle_signature_suffices. -/
def W43 : Reachable s1 ∧ cage.oracles = [oracle] ∧ (selected true oracle).authorized oracle ∧ (selected true oracle).approve = true ∧ (selected true oracle).signers = ["alice"] :=
 ⟨reachable1, rfl, authorization true, rfl, rfl⟩

/-- Reachable antecedent for T44: old_operations_correspond. -/
def W44 : Reachable s0 ∧ Reachable s4 ∧ (OldOperation.insert "x" "v").condition.holds s0.cage.trie ∧ (OldOperation.delete "x" "v").condition.holds s4.cage.trie ∧ (OldOperation.update "x" "v" "v2").condition.holds s4.cage.trie :=
 ⟨reachable0, reachable4, rfl, rfl, rfl⟩

/-- Reachable antecedent for T45: live_removal_is_legal_exit. -/
def W45 := removalAntecedent

/-- Reachable antecedent for T46: new_judgment_is_authorized. -/
def W46 : Reachable s1 ∧ Step s1 (.judge (judge true)) s2 ∧ deadName ∈ s2.issued ∧ deadName ∉ s1.issued :=
 ⟨reachable1, step_approve, by simp [s2, afterJudgment, judge, deadName], by simp [s1, afterCreate, s0, initial]⟩

/-- Reachable antecedent for T47: exit_time_window. -/
def W47 : Reachable s3 ∧ requestSpendAllowed output (.folded writeTx) ∧
 (RequestSpend.folded writeTx).exitsAs output .write ∧
 requestSpendAllowed output (.folded (accountTx false)) ∧
 (RequestSpend.folded (accountTx false)).exitsAs output .account ∧
 requestSpendAllowed output (.withdrawn withdraw) ∧
 (RequestSpend.withdrawn withdraw).exitsAs output .withdraw := by
 refine ⟨reachable3, ⟨write_ok, ?_⟩, ⟨selected true, ?_⟩,
   ⟨account_ok false, ?_⟩, ⟨selected false, ?_⟩, ⟨withdraw_ok, rfl⟩, rfl⟩
 all_goals simp [writeTx, accountTx, singletonFold, FoldTx.requests, FoldItem.request]

/-- Reachable antecedent for T48: exit_windows_cover. -/
def W48 : Reachable s1 ∧ exitAt output ⟨9,9⟩ .write ∧ exitAt output ⟨10,10⟩ .account ∧ exitAt output ⟨15,15⟩ .account ∧ exitAt output ⟨16,16⟩ .withdraw :=
 ⟨reachable1, by finite, by finite, by finite, by finite⟩

/-- Reachable antecedent for T49: exit_kind_unique. -/
def W49 : Reachable s3 ∧ requestSpendAllowed output (.folded (accountTx true)) ∧
 requestSpendAllowed output (.folded (accountTx false)) ∧
 (RequestSpend.folded (accountTx true)).interval = (RequestSpend.folded (accountTx false)).interval ∧
 (RequestSpend.folded (accountTx true)).exitsAs output .account ∧
 (RequestSpend.folded (accountTx false)).exitsAs output .account := by
 refine ⟨reachable3, ⟨account_ok true, ?_⟩, ⟨account_ok false, ?_⟩,
   rfl, ⟨selected true, ?_⟩, ⟨selected false, ?_⟩⟩
 all_goals simp [accountTx, singletonFold, FoldTx.requests, FoldItem.request]

/-- Reachable antecedent for T50: fold_references_authentic. -/
def W50 := writeAntecedent

/-- Reachable antecedent for T51: account_references_authentic. -/
def W51 := accountAntecedent false

/-- Reachable antecedent for T52: creation_references_source. -/
def W52 := createAntecedent

/-- Reachable antecedent for T53: fold_payments_concrete. -/
def W53 := writeAntecedent

/-- Reachable antecedent for T54: account_payments_concrete. -/
def W54 := accountAntecedent false

/-- Reachable antecedent for T55: creation_funds_declared_fees. -/
def W55 := createAntecedent

/-- Reachable antecedent for T56: burn_removes_one. -/
def W56 : Reachable s4 ∧ Step s4 (.burn deadName) (afterBurn s4 deadName) :=
 ⟨reachable4, deadBurn⟩

/-- Reachable antecedent for T57: burn_keeps_history. -/
def W57 : Reachable s4 ∧ Step s4 (.burn deadName) (afterBurn s4 deadName) :=
 ⟨reachable4, deadBurn⟩

/-- Reachable antecedent for T58: fold_requests_unique. -/
def W58 := writeAntecedent

/-- Reachable antecedent for T59: account_accepts_any_verdicts. -/
def W59 := accountAntecedent false

/-- Reachable antecedent for T60: equivocation_reachable. -/
def W60 : Reachable s3 ∧ output ∈ s3.live ∧ output.request.cage = s3.cage.id ∧
 oracle ∈ s3.cage.oracles ∧
 judgmentName s3.cage.id output.request oracle true rec [.absent "y"] ∈ s3.judgments ∧
 judgmentName s3.cage.id output.request oracle false rec [] ∈ s3.judgments ∧
 judgmentName s3.cage.id output.request oracle true rec [.absent "y"] ∈ s3.issued ∧
 judgmentName s3.cage.id output.request oracle false rec [] ∈ s3.issued := by
 refine ⟨reachable3, ?_, rfl, ?_, ?_, ?_, ?_, ?_⟩
 all_goals simp [s3, s2, s1, s0, afterJudgment, afterCreate, initial, judge,
   cage, output, evidence, Evidence.name, judgmentName]

/-- Reachable antecedent for T61: tag_name_injective. -/
def W61 : Reachable s2 ∧ oracle = OracleIdentity.identity group ∧ TokenRole.approval ≠ TokenRole.refusal ∧ judgmentName cage.id request oracle true rec [.absent "y"] = deadName :=
 ⟨reachable2, rfl, by decide, rfl⟩

/-- Reachable antecedent for T62: price_name_injective. -/
def W62 : Reachable s2 ∧ oracle = OracleIdentity.identity group ∧ TokenRole.approval ≠ TokenRole.refusal ∧ judgmentName cage.id request oracle true rec [.absent "y"] = deadName :=
 ⟨reachable2, rfl, by decide, rfl⟩

/-- Reachable antecedent for T63: different_roles_never_coincide. -/
def W63 : Reachable s2 ∧ oracle = OracleIdentity.identity group ∧ TokenRole.approval ≠ TokenRole.refusal ∧ judgmentName cage.id request oracle true rec [.absent "y"] = deadName :=
 ⟨reachable2, rfl, by decide, rfl⟩

/-- Reachable antecedent for T64: names_have_leading_roles. -/
def W64 : Reachable s2 ∧ oracle = OracleIdentity.identity group ∧ TokenRole.approval ≠ TokenRole.refusal ∧ judgmentName cage.id request oracle true rec [.absent "y"] = deadName :=
 ⟨reachable2, rfl, by decide, rfl⟩

/-- Reachable antecedent for T65: reachable_registry_valid. -/
def W65 := liveAntecedent

/-- Reachable antecedent for T66: reachable_live_tags. -/
def W66 := liveAntecedent

/-- Reachable antecedent for T67: reachable_tags_unique. -/
def W67 := liveAntecedent

/-- Reachable antecedent for T68: discovery_iff. -/
def W68 := liveAntecedent

/-- Reachable antecedent for T69: discovery_across_registries. -/
def W69 : (∀ s ∈ [s1, OtherRegistry.state], Reachable s) ∧ output ∈ s1.live ∧ OtherRegistry.output ∈ OtherRegistry.state.live ∧ s1.cage.id ≠ OtherRegistry.state.cage.id :=
 ⟨by intro s h; simp only [List.mem_cons, List.not_mem_nil, or_false] at h; rcases h with rfl | rfl; exact reachable1; exact OtherRegistry.reachable, liveAntecedent.2, by simp [OtherRegistry.state, afterCreate], by decide⟩

/-- Reachable antecedent for T70: live_removal_burns_oracle_tags. -/
def W70 := removalAntecedent

/-- Reachable antecedent for T71: price_mint_inversion. -/
def W71 : Reachable s5 ∧ Step s5 (.priceMint mintPrice) priceState ∧ priceMintAllowed mintPrice ∧ Action.isPrice (.priceMint mintPrice) = true ∧ notice ∉ s5.notices :=
 ⟨reachable5, step_price, mintPrice_ok, rfl, by decide⟩

/-- Reachable antecedent for T72: price_update_inversion. -/
def W72 : Reachable priceState ∧ notice ∈ priceState.notices ∧ Step priceState (.priceUpdate updatePrice) (afterPriceUpdate priceState updatePrice) ∧ priceUpdateAllowed updatePrice :=
 ⟨priceReachable, by simp [priceState,afterPriceMint,mintPrice], step_update, updatePrice_ok⟩

/-- Reachable antecedent for T73: reachable_notice_names. -/
def W73 : Reachable priceState ∧ notice ∈ priceState.notices ∧ Step priceState (.priceUpdate updatePrice) (afterPriceUpdate priceState updatePrice) ∧ priceUpdateAllowed updatePrice :=
 ⟨priceReachable, by simp [priceState,afterPriceMint,mintPrice], step_update, updatePrice_ok⟩

/-- Reachable antecedent for T74: price_mint_available. -/
def W74 : Reachable s5 ∧ Step s5 (.priceMint mintPrice) priceState ∧ priceMintAllowed mintPrice ∧ Action.isPrice (.priceMint mintPrice) = true ∧ notice ∉ s5.notices :=
 ⟨reachable5, step_price, mintPrice_ok, rfl, by decide⟩

/-- Reachable antecedent for T75: price_update_available. -/
def W75 : Reachable priceState ∧ notice ∈ priceState.notices ∧ Step priceState (.priceUpdate updatePrice) (afterPriceUpdate priceState updatePrice) ∧ priceUpdateAllowed updatePrice :=
 ⟨priceReachable, by simp [priceState,afterPriceMint,mintPrice], step_update, updatePrice_ok⟩

/-- Reachable antecedent for T76: price_notice_noninterference. -/
def W76 : Reachable s5 ∧ Step s5 (.priceMint mintPrice) priceState ∧ priceMintAllowed mintPrice ∧ Action.isPrice (.priceMint mintPrice) = true ∧ notice ∉ s5.notices :=
 ⟨reachable5, step_price, mintPrice_ok, rfl, by decide⟩

/-- Reachable antecedent for T77: notices_do_not_bind_protocol. -/
def W77 : Reachable s3 ∧ Step s3 (.fold writeTx) s4 ∧ Action.isPrice (.fold writeTx) = false ∧ notice.datum.fee ≠ request.fee oracle :=
 ⟨reachable3,step_write,rfl,by decide⟩

/-- Reachable antecedent for T78: notice_change_authorized. -/
def W78 : Reachable s5 ∧ Step s5 (.priceMint mintPrice) priceState ∧ priceMintAllowed mintPrice ∧ Action.isPrice (.priceMint mintPrice) = true ∧ notice ∉ s5.notices :=
 ⟨reachable5, step_price, mintPrice_ok, rfl, by decide⟩

/-- Reachable antecedent for T79: creation_rule_and_token. -/
def W79 := createAntecedent

/-- Reachable antecedent for T80: step_rule_immutable. -/
def W80 : Reachable Ruled.s3 ∧ Step Ruled.s3 (.fold Ruled.writeTx) Ruled.s4 ∧ Ruled.s3.cage.rule = some Zero.rule := ⟨Ruled.reachable3, Ruled.step_write, rfl⟩

/-- Reachable antecedent for T81: history_rule_immutable. -/
def W81 : Reachable Ruled.s0 ∧ History Ruled.s0 Ruled.s4 ∧ Ruled.s0.cage.rule = some Zero.rule :=
 ⟨Ruled.reachable0, .next Ruled.step_create (.next Ruled.step_approve (.next Ruled.step_refuse (.next Ruled.step_write (.refl _)))), rfl⟩

/-- Reachable antecedent for T82: reachable_rule_admitted. -/
def W82 := ruledAntecedent

/-- Reachable antecedent for T83: every_rule_allows_burn. -/
def W83 : Reachable Ruled.s3 ∧ Ruled.s3.cage.rule = some Zero.rule ∧ Step Ruled.s3 (.fold Ruled.writeTx) Ruled.s4 ∧ Step Ruled.s3 (.fold (Ruled.accountTx false)) (afterFold Ruled.s3 (Ruled.accountTx false)) ∧ Step Ruled.s1 (.withdraw Ruled.withdraw) (afterExit Ruled.s1 Ruled.output) ∧ Step Ruled.s4 (.burn ((Ruled.evidence true).name Ruled.cage.id Ruled.request Ruled.oracle)) (afterBurn Ruled.s4 ((Ruled.evidence true).name Ruled.cage.id Ruled.request Ruled.oracle)) :=
 ⟨Ruled.reachable3, rfl, Ruled.step_write, Ruled.step_account false, Ruled.step_withdraw, Ruled.burnStep⟩

/-- Reachable antecedent for T84: fold_rule_predicate_independent. -/
def W84 : Reachable Zero.created ∧ stepValid Zero.cage ⟨3,4⟩ [] [] (selected true) Zero.output ∧ ¬ Zero.rule.admits Zero.output.request [] :=
 ⟨Zero.reachable1,Zero.write_valid, by simp [Zero.rule]⟩

/-- Reachable antecedent for T85: reachable_request_tokens. -/
def W85 := liveAntecedent

/-- Reachable antecedent for T86: fold_requires_request_token. -/
def W86 := writeAntecedent

/-- Reachable antecedent for T87: every_exit_burns_request_token. -/
def W87 : Reachable s3 ∧ requestSpendAllowed output (.folded writeTx) ∧ writeTx.interval.lower < output.request.deadline ∧ writeTx.interval.lower ≤ output.request.deadline + output.request.window :=
 ⟨reachable3, ⟨write_ok, by simp [writeTx, singletonFold, FoldTx.requests, FoldItem.request]⟩, by decide, by decide⟩

/-- Reachable antecedent for T88: live_removal_burns_request_token. -/
def W88 := removalAntecedent

/-- Reachable antecedent for T89: request_name_injective. -/
def W89 : Reachable s2 ∧ oracle = OracleIdentity.identity group ∧ TokenRole.approval ≠ TokenRole.refusal ∧ judgmentName cage.id request oracle true rec [.absent "y"] = deadName :=
 ⟨reachable2, rfl, by decide, rfl⟩

/-- Reachable antecedent for T90: request_token_discovery. -/
def W90 := liveAntecedent

/-- Reachable antecedent for T91: request_token_discovery_across_registries. -/
def W91 : (∀ s ∈ [s1, OtherRegistry.state], Reachable s) ∧ output ∈ s1.live ∧ OtherRegistry.output ∈ OtherRegistry.state.live ∧ s1.cage.id ≠ OtherRegistry.state.cage.id :=
 ⟨by intro s h; simp only [List.mem_cons, List.not_mem_nil, or_false] at h; rcases h with rfl | rfl; exact reachable1; exact OtherRegistry.reachable, liveAntecedent.2, by simp [OtherRegistry.state, afterCreate], by decide⟩

/-- Reachable antecedent for T92: output_refs_monotone. -/
def W92 : Reachable s1 ∧ Step s1 (.judge (judge true)) s2 ∧ request.seed ∈ s1.usedSeeds ∧ output.ref ∈ s1.usedOutputs :=
 ⟨reachable1, step_approve, by decide, by decide⟩

/-- Reachable antecedent for T93: reachable_output_refs. -/
def W93 := liveAntecedent

/-- Reachable antecedent for T94: reachable_output_refs_unique. -/
def W94 := liveAntecedent

/-- Reachable antecedent for T95: unguarded_registry_impossible. -/
def W95 : Reachable s0 ∧ ({ cage with oracles := [], rule := none } : CageState).oracles = [] ∧ ({ cage with oracles := [], rule := none } : CageState).rule = none :=
 ⟨reachable0,rfl,rfl⟩

/-- Reachable antecedent for T96: zero_oracle_needs_rule. -/
def W96 := zeroAntecedent

/-- Reachable antecedent for T97: zero_oracle_evidence_empty. -/
def W97 := zeroAntecedent

/-- Reachable antecedent for T98: zero_oracle_creation_without_seed. -/
def W98 := zeroAntecedent

/-- Reachable antecedent for T99: zero_oracle_fold_without_approvals. -/
def W99 := zeroAntecedent

/-- Reachable antecedent for T100: zero_oracle_account_without_verdicts. -/
def W100 := zeroAntecedent

/-- Reachable antecedent for T101: present_condition_semantics. -/
def W101 : Reachable s4 ∧ Condition.holds s4.cage.trie (.present "x") :=
 ⟨reachable4, ⟨"v",rfl⟩⟩

/-- Reachable antecedent for T102: foldRun_oracle_conditions. -/
def W102 : Reachable s3 ∧ FoldRun writeTx.interval writeTx.refs writeTx.signers cage writeTx.items writeTx.cageOut ∧ writeTx.items[0]? = some (FoldItem.write output (selected true)) :=
 ⟨reachable3, write_ok.2.2.2.2.1, rfl⟩

/-- Reachable antecedent for T103: fold_all_conditions_hold. -/
def W103 := writeAntecedent

/-- Reachable antecedent for T104: approval_conditions_cannot_change. -/
def W104 : Reachable s2 ∧ oracle = OracleIdentity.identity group ∧ TokenRole.approval ≠ TokenRole.refusal ∧ judgmentName cage.id request oracle true rec [.absent "y"] = deadName :=
 ⟨reachable2, rfl, by decide, rfl⟩

/-- Reachable antecedent for T105: stale_approval_unusable. -/
def W105 : Reachable Stale.state ∧ Stale.tx.items[0]? = some (FoldItem.write output Stale.selected) ∧ oracle ∈ Stale.tx.cageIn.oracles ∧ Condition.present "y" ∈ (Stale.selected oracle).conditions ∧ ¬ Condition.holds (atTurn Stale.tx 0).trie (.present "y") :=
 ⟨Stale.reachable,rfl,by simp [Stale.tx,singletonFold,Stale.state,afterJudgment,s1,s0,afterCreate,initial,cage],by decide,Stale.falseCondition⟩

/-- Reachable antecedent for T106: fold_evidence_binds_conditions. -/
def W106 := writeAntecedent

/-- Reachable antecedent for T107: expected_approval_lookup. -/
def W107 : Reachable s3 ∧ hasApproval cage request s3.judgments [] (selected true) ∧
 (∀ name ∈ expectedApprovals cage request (selected true), name ∈ s3.judgments) := by
 refine ⟨reachable3, approval_ok, ?_⟩
 simp [expectedApprovals, cage, selected, evidence, s3, s2, afterJudgment, judge, Evidence.name]

/-- Reachable antecedent for T108: folder_discovery_exact. -/
def W108 : Reachable s3 ∧ output ∈ s3.live ∧ stepValid s3.cage ⟨3,4⟩ s3.judgments [] (selected true) output :=
 ⟨reachable3,by simp [s3,s2,s1,afterJudgment,afterCreate],write_valid⟩

/-- Reachable antecedent for T109: folder_discovery_executable. -/
def W109 : Reachable s3 ∧ output ∈ s3.live ∧ stepValid s3.cage ⟨3,4⟩ s3.judgments [] (selected true) output :=
 ⟨reachable3,by simp [s3,s2,s1,afterJudgment,afterCreate],write_valid⟩

/-- Reachable antecedent for T110: empty_fold_allowed. -/
def W110 : Reachable s4 ∧ (⟨20,21⟩ : Interval).valid ∧ foldAccepted (⟨s4.cage,s4.cage,[],[],[],⟨20,21⟩,"folder","anyone",[],[],[],[],[],[],[]⟩ : FoldTx) :=
 ⟨reachable4,by finite,⟨by finite,by simp [FoldTx.requests,FoldTx.claims],rfl,rfl,.nil _,⟨rfl,rfl,rfl,rfl,rfl⟩⟩⟩

/-- Reachable antecedent for T111: empty_fold_earns_nothing. -/
def W111 : Reachable s4 ∧ (⟨20,21⟩ : Interval).valid ∧ foldAccepted (⟨s4.cage,s4.cage,[],[],[],⟨20,21⟩,"folder","anyone",[],[],[],[],[],[],[]⟩ : FoldTx) :=
 ⟨reachable4,by finite,⟨by finite,by simp [FoldTx.requests,FoldTx.claims],rfl,rfl,.nil _,⟨rfl,rfl,rfl,rfl,rfl⟩⟩⟩

/-- Reachable antecedent for T112: creation_rule_input_binding. -/
def W112 := ruledAntecedent

/-- Reachable antecedent for T113: creation_request_policy. -/
def W113 := ruledAntecedent

/-- Reachable antecedent for T114: only_fold_changes_registry. -/
def W114 : Reachable s3 ∧ Step s3 (.fold writeTx) s4 ∧ s4.cage ≠ s3.cage := by
 refine ⟨reachable3, step_write, ?_⟩
 intro h
 exact W15.2.2 (congrArg CageState.trie h)

/-- Reachable antecedent for T115: reachable_balances_backed. -/
def W115 := claimAntecedent

/-- Reachable antecedent for T116: fold_value_conservation. -/
def W116 : Reachable withClaim ∧ Step withClaim (.fold writeClaimTx) (afterFold withClaim writeClaimTx) ∧ foldAccepted writeClaimTx ∧ (atTurn writeClaimTx 1).balances "alice" = 6 :=
 ⟨withClaimReachable,step_write_claim,writeClaim_ok,by decide⟩

/-- Reachable antecedent for T117: fold_request_conservation. -/
def W117 : Reachable withClaim ∧ Step withClaim (.fold writeClaimTx) (afterFold withClaim writeClaimTx) ∧ foldAccepted writeClaimTx ∧ (atTurn writeClaimTx 1).balances "alice" = 6 :=
 ⟨withClaimReachable,step_write_claim,writeClaim_ok,by decide⟩

/-- Reachable antecedent for T118: fold_balance_conservation. -/
def W118 : Reachable withClaim ∧ Step withClaim (.fold writeClaimTx) (afterFold withClaim writeClaimTx) ∧ foldAccepted writeClaimTx ∧ (atTurn writeClaimTx 1).balances "alice" = 6 :=
 ⟨withClaimReachable,step_write_claim,writeClaim_ok,by decide⟩

/-- Reachable antecedent for T119: fold_payments_exact. -/
def W119 := writeAntecedent

/-- Reachable antecedent for T120: group_credits_only_recorded_signers. -/
def W120 : Reachable s3 ∧ (evidence true).authorized oracle ∧ "bob" ∉ OracleIdentity.recordedKeys rec :=
 ⟨reachable3,authorization true,by decide⟩

/-- Reachable antecedent for T121: group_credits_exact_split. -/
def W121 : Reachable bobState ∧ bobEvidence.authorized oracle ∧ accountAllowed cage ⟨10,15⟩ bobState.judgments output bobSelected :=
 ⟨bobReachable,by finite,bobAccountValid⟩

/-- Reachable antecedent for T122: judgment_record_cannot_change. -/
def W122 : Reachable s2 ∧ oracle = OracleIdentity.identity group ∧ TokenRole.approval ≠ TokenRole.refusal ∧ judgmentName cage.id request oracle true rec [.absent "y"] = deadName :=
 ⟨reachable2, rfl, by decide, rfl⟩

/-- Reachable antecedent for T123: claim_creation_inversion. -/
def W123 : Reachable s4 ∧ Step s4 (.claimCreate createClaim) s5 ∧ Reachable s5 ∧ claim ∈ s5.claims :=
 ⟨reachable4,step_claim_create,reachable5,by simp [s5,afterClaimCreate,createClaim]⟩

def claimEvents : List (State × Action × State) :=
 [(s0, .create create output, s1), (s1, .judge (judge true), s2),
  (s2, .judge (judge false), s3), (s3, .fold writeTx, s4),
  (s4, .claimCreate createClaim, s5)]
def claimTrace : Trace (initial cage) claimEvents s5 :=
 .cons step_create (.cons step_approve (.cons step_refuse
   (.cons step_write (.cons step_claim_create (.nil _)))))

/-- Reachable antecedent for T124: reachable_claim_authorization. -/
def W124 : Reachable s5 ∧ registryCreated cage [] ∧
 Trace (initial cage) claimEvents s5 ∧ claim ∈ s5.claims :=
 ⟨reachable5, registry_ok, claimTrace, by simp [s5,afterClaimCreate,createClaim]⟩

/-- Reachable antecedent for T125: claim_payout_fixed. -/
def W125 := claimAntecedent

/-- Reachable antecedent for T126: claim_payout_in_actual_outputs. -/
def W126 := claimAntecedent

/-- Reachable antecedent for T127: claim_below_minimum_refused. -/
def W127 : Reachable lowState ∧ lowState.cage.balances claim.key < lowState.cage.minimum ∧ ¬ claimAllowed lowState.cage ⟨3,4⟩ claim :=
 ⟨lowReachable,by decide,lowRefusal⟩

/-- Reachable antecedent for T128: claim_turn_balance. -/
def W128 : Reachable withClaim ∧ Step withClaim (.fold writeClaimTx) (afterFold withClaim writeClaimTx) ∧ foldAccepted writeClaimTx ∧ (atTurn writeClaimTx 1).balances "alice" = 6 :=
 ⟨withClaimReachable,step_write_claim,writeClaim_ok,by decide⟩

/-- Reachable antecedent for T129: claim_consumed_and_burned. -/
def W129 := claimAntecedent

/-- Reachable antecedent for T130: claim_withdrawal_inversion. -/
def W130 : Reachable s5 ∧ Step s5 (.claimWithdraw claimWithdraw) (afterClaimWithdraw s5 claimWithdraw) ∧ claimWithdraw.input.deadline = claimWithdraw.interval.lower :=
 ⟨reachable5,step_claim_withdraw,rfl⟩

/-- Reachable antecedent for T131: claim_withdrawal_available. -/
def W131 : Reachable s5 ∧ Step s5 (.claimWithdraw claimWithdraw) (afterClaimWithdraw s5 claimWithdraw) ∧ claimWithdraw.input.deadline = claimWithdraw.interval.lower :=
 ⟨reachable5,step_claim_withdraw,rfl⟩

/-- Reachable antecedent for T132: claim_windows_disjoint. -/
def W132 : Reachable s5 ∧ claimAllowed s5.cage ⟨20,25⟩ claim ∧ ({ claimWithdraw with interval := ⟨20,25⟩ } : ClaimWithdrawTx).input = claim :=
 ⟨reachable5,claim_valid,rfl⟩

/-- Reachable antecedent for T133: claim_discovery_exact. -/
def W133 : Reachable s4 ∧ Step s4 (.claimCreate createClaim) s5 ∧ Reachable s5 ∧ claim ∈ s5.claims :=
 ⟨reachable4,step_claim_create,reachable5,by simp [s5,afterClaimCreate,createClaim]⟩

/-- Reachable antecedent for T134: request_withdrawal_preserves_registry. -/
def W134 : Reachable s1 ∧ Step s1 (.withdraw withdraw) (afterExit s1 output) ∧ withdrawAllowed withdraw :=
 ⟨reachable1, step_withdraw, withdraw_ok⟩

/-- Reachable antecedent for T135: fold_interval_fits_every_item. -/
def W135 := writeAntecedent

/-- T136 exercises all nine authoritative Step constructors. -/
def W136 :
 Step s0 (.create create output) s1 ∧ Step s1 (.judge (judge true)) s2 ∧
 Step s3 (.fold writeTx) s4 ∧ Step s1 (.withdraw withdraw) (afterExit s1 output) ∧
 Step s4 (.burn deadName) (afterBurn s4 deadName) ∧
 Step s5 (.priceMint mintPrice) priceState ∧
 Step priceState (.priceUpdate updatePrice) (afterPriceUpdate priceState updatePrice) ∧
 Step s4 (.claimCreate createClaim) s5 ∧
 Step s5 (.claimWithdraw claimWithdraw) (afterClaimWithdraw s5 claimWithdraw) ∧
 Reachable s0 ∧ Reachable s1 ∧ Reachable s3 ∧ Reachable s4 ∧ Reachable s5 ∧ Reachable priceState :=
 ⟨step_create, step_approve, step_write, step_withdraw, deadBurn, step_price, step_update,
  step_claim_create, step_claim_withdraw, reachable0, reachable1, reachable3, reachable4, reachable5, priceReachable⟩

def W137 := W02

def W138 := claimAntecedent


namespace MixedBatch

def longOutput : RequestOutput := { output with
  ref := "long-output"
  request := { request with seed := "long-seed", deadline := 20 } }
def createLong : CreateTx := { create with spent := ["long-seed"], outputs := [longOutput] }
def withLong := afterCreate s3 createLong longOutput

def create_ok : createAllowed createLong longOutput := by
 simp [createAllowed, createLong, create, wellFormed, longOutput, output, request, cage,
  tokensOf, totalFees, Request.fee, requestPolicy, ruleAdmits]
def longStep : Step s3 (.create createLong longOutput) withLong :=
 .create s3 createLong longOutput rfl create_ok (by finite) (by finite)
def longReachable : Reachable withLong := .next reachable3 longStep

def claimCreate : ClaimCreateTx := { createClaim with cageRef := withLong.cage }
def source := afterClaimCreate withLong claimCreate
def claimStep : Step withLong (.claimCreate claimCreate) source :=
 .claimCreate withLong claimCreate rfl (by finite) (by finite)
def reachable : Reachable source := .next longReachable claimStep

def items : List FoldItem := [.write longOutput (selected true), .account output (selected false), .claim claim]
def afterWrite := itemResult cage (.write longOutput (selected true))
def afterAccount := itemResult afterWrite (.account output (selected false))
def tx : FoldTx := ⟨cage, foldResult cage items, items, source.judgments, ["alice"], ⟨10,12⟩,
 "folder", "submitter", items.flatMap FoldItem.burned, foldPayments cage "folder" items, [], [], [], [], []⟩

def longValid : stepValid cage ⟨10,12⟩ source.judgments ["alice"] (selected true) longOutput := by
 refine ⟨Or.inl rfl, ?_⟩
 refine ⟨?_, by finite, by finite, ?_, ?_, ?_⟩
 · simp [wellFormed, longOutput, output, request, cage, totalFees, Request.fee, requestPolicy]
 · intro o ho
   have h : o = oracle := by simpa [cage] using ho
   subst o
   exact ⟨authorization true, rfl, Or.inr rfl⟩
 · simp [longOutput, output, request, cage, Condition.holds, emptyTrie]
 · simp [selected, evidence, cage, Condition.holds, emptyTrie]

def accountValid : accountAllowed afterWrite ⟨10,12⟩ source.judgments output (selected false) := by
 refine ⟨?_, by finite, by finite, by finite, ?_⟩
 · simp [wellFormed, afterWrite, itemResult, credit, output, request, cage, totalFees, Request.fee, requestPolicy]
 · exact account_evidence false

def accepted : foldAccepted tx := by
 refine ⟨by finite, ?_, rfl, rfl, ?_, by exact ⟨rfl, rfl, rfl, rfl, rfl⟩⟩
 · change ([longOutput.ref, output.ref] ++ [claim.ref]).Nodup
   decide
 · exact .cons _ _ _ _ longValid (.cons _ _ _ _ accountValid (.cons _ _ _ _ (by finite) (.nil _)))

def step : Step source (.fold tx) (afterFold source tx) := by
 apply Step.fold source tx rfl
 · simp [tx, items, FoldTx.requests, FoldItem.request, source, afterClaimCreate, withLong,
     s3, s2, s1, afterCreate, afterJudgment]
 · simp [tx, items, FoldTx.claims, FoldItem.claimInput, source, afterClaimCreate, claimCreate, createClaim]
 · exact fun _ h => h
 · exact accepted
 · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
 · intro w h; change w ∈ ([] : List WitnessOutput) at h; contradiction

def conserved : Reachable source ∧ Step source (.fold tx) (afterFold source tx) ∧
 (atTurn tx 2).balances "alice" = 12 ∧ tx.cageOut.balances "alice" = 0 ∧
 tx.cageIn.value + requestEscrows tx.items + claimEscrows tx.items =
 tx.cageOut.value + requestRemainders tx.cageIn tx.items + claimPayouts tx.cageIn tx.items + claimEscrows tx.items :=
 ⟨reachable, step, by decide, by decide, by decide⟩

def overlapping : Reachable source ∧ foldAccepted tx ∧
 tx.interval = ⟨10,12⟩ ∧ (atTurn tx 1).trie "x" = some "v" ∧
 (atTurn tx 2).trie "x" = some "v" := ⟨reachable, accepted, rfl, rfl, rfl⟩

/-- Widening the shared interval cannot let its account start before deadline. -/
def straddlingRefused : ¬ accountAllowed afterWrite ⟨9,12⟩ source.judgments output (selected false) := by
 intro h
 have : 10 ≤ 9 := h.2.2.1
 omega
end MixedBatch

namespace SharedKey

def keyOracle : Oracle := OracleIdentity.identity (.key "alice")
def cage : CageState := { Witnesses.cage with oracles := [oracle, keyOracle] }
def request : Request := { Witnesses.request with fees := [(oracle, 6), (keyOracle, 4)] }
def output : RequestOutput := { Witnesses.output with request := request, value := 15, tags := cage.oracles.map tagName }
def create : CreateTx := { Witnesses.create with cageRef := cage, outputs := [output], minted := tokensOf output }
def source := afterCreate (initial cage) create output

def registry_ok : registryCreated cage [] := by
 simp [registryCreated, RegistryValid, cage, Witnesses.cage, keyOracle, oracle, OracleIdentity.identity, group]
def create_ok : createAllowed create output := by
 simp [createAllowed, create, wellFormed, output, request, cage, tokensOf, totalFees, Request.fee,
  Witnesses.create, Witnesses.output, Witnesses.request, Witnesses.cage, requestPolicy, ruleAdmits,
  oracle, keyOracle, OracleIdentity.identity, group]
def reachable : Reachable source :=
 .next (.registry cage [] registry_ok)
  (.create (initial cage) create output rfl create_ok (by simp [initial]) (by simp [initial]))

def keyEvidence : Evidence := ⟨.key "alice", ["alice"], .key "alice", true, []⟩
def selected : Selection := fun o => if o = keyOracle then keyEvidence else evidence true

def approval : hasApproval cage request [] ["alice"] selected := by
 intro o ho
 have h : o = oracle ∨ o = keyOracle := by simpa [cage] using ho
 rcases h with rfl | rfl
 · refine ⟨?_, ?_, Or.inr ?_⟩ <;> dsimp [selected, keyOracle, oracle, OracleIdentity.identity, group]
   · exact authorization true
   · rfl
   · rfl
 · refine ⟨?_, ?_, Or.inr ?_⟩ <;> dsimp [selected]
   · unfold Evidence.authorized
     decide
   · rfl
   · rfl

def tx : FoldTx := singletonFold source ⟨3,4⟩ ["alice"] (.write output selected) "folder"
def valid : stepValid cage ⟨3,4⟩ [] ["alice"] selected output := by
 refine ⟨Or.inl rfl, ?_⟩
 refine ⟨create_ok.2.2.2.1, by finite, by finite, approval, ?_, ?_⟩
 · simp [output, request, Witnesses.request, cage, Witnesses.cage, Condition.holds, emptyTrie]
 · intro o ho condition hc
   have h : o = oracle ∨ o = keyOracle := by simpa [cage] using ho
   rcases h with rfl | rfl
   · simp [selected, keyOracle, oracle, OracleIdentity.identity, group, evidence] at hc
     subst condition
     rfl
   · simp [selected, keyEvidence] at hc

def accepted : foldAccepted tx := by
 refine ⟨by finite, ?_, rfl, rfl, ?_, by exact ⟨rfl, rfl, rfl, rfl, rfl⟩⟩
 · simp [tx, singletonFold, FoldTx.requests, FoldTx.claims, FoldItem.request, FoldItem.claimInput]
 · exact .cons _ _ _ _ valid (.nil _)
def step : Step source (.fold tx) (afterFold source tx) := by
 apply Step.fold source tx rfl
 · simp [tx, singletonFold, FoldTx.requests, FoldItem.request, source, afterCreate]
 · simp [tx, singletonFold, FoldTx.claims, FoldItem.claimInput]
 · exact fun _ h => h
 · exact accepted
 · intro o h; change o ∈ ([] : List Extraction) at h; contradiction
 · intro w h; change w ∈ ([] : List WitnessOutput) at h; contradiction

def summedOnce : Reachable source ∧ Step source (.fold tx) (afterFold source tx) ∧
 tx.cageOut.balances "alice" = 10 ∧ tx.cageOut.value = 10 ∧ balanceSum tx.cageOut = 10 ∧
 (registryKeys cage).count "alice" = 1 := ⟨reachable, step, by decide, by decide, by decide, by decide⟩
end SharedKey

/-- Reachable antecedents for T139, and both sides of the boundary. -/
def W139 : Reachable s5 ∧ claim.cage = s5.cage.id ∧
 claim.key ∈ registryKeys s5.cage ∧ claim.tokens = [claimName s5.cage.id] ∧
 s5.cage.minimum ≤ s5.cage.balances claim.key ∧
 claimAllowed s5.cage ⟨29,29⟩ claim ∧
 claimWithdrawAllowed ⟨claim, ⟨30,30⟩, [claim.key], claim.tokens, claim.key, claim.value⟩ := by
 refine ⟨reachable5, rfl, ?_, rfl, ?_, ?_, ?_⟩ <;> finite

/-- A group write/account/claim batch supplies the whole-fold premise of T140. -/
def W140 := MixedBatch.conserved

/-- The same reachable state and full event trace witness both sides of T141. -/
def W141 : Reachable s5 ∧ registryCreated cage [] ∧ Trace (initial cage) claimEvents s5 :=
 ⟨reachable5, registry_ok, claimTrace⟩

/-- T142 has simultaneous non-vacuous antecedents for the same window; the
three time classes are instantiated on a reachable live request. -/
def W142 : Reachable s1 ∧ output ∈ s1.live ∧
 (exitAt output ⟨9,9⟩ .write ∧ exitAt output ⟨9,9⟩ .write) ∧
 (exitAt output ⟨10,10⟩ .account ∧ exitAt output ⟨10,10⟩ .account) ∧
 (exitAt output ⟨16,16⟩ .withdraw ∧ exitAt output ⟨16,16⟩ .withdraw) :=
 ⟨reachable1, by simp [s1, afterCreate], ⟨by finite, by finite⟩,
   ⟨by finite, by finite⟩, ⟨by finite, by finite⟩⟩

end RequestApprovalFold.Witnesses
