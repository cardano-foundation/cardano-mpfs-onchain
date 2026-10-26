import MpfsCage.RequestApprovalFold.TagsPrices

namespace RequestApprovalFold.Witnesses

/-! These traces depend only on production constructors and prior witness
    definitions; none uses a candidate theorem to construct its antecedents. -/
def notice : PriceNotice := ⟨"alice", priceName "alice", ⟨100, [("protocol", 200)]⟩⟩
def mintPrice : PriceMintTx := ⟨notice, ["alice"], [priceName "alice"]⟩
def priced := afterPriceMint s3 mintPrice

def step_price : Step s3 (.priceMint mintPrice) priced :=
  .priceMint s3 mintPrice ⟨by decide, rfl, rfl⟩
def reachablePriced : Reachable priced := .next reachable3 step_price

def updatePrice : PriceUpdateTx :=
  ⟨notice, { notice with datum := ⟨1, []⟩ }, ["alice"], []⟩
def repriced := afterPriceUpdate priced updatePrice

def step_reprice : Step priced (.priceUpdate updatePrice) repriced :=
  .priceUpdate priced updatePrice (by decide) ⟨by decide, rfl, rfl, rfl, rfl⟩
def reachableRepriced : Reachable repriced := .next reachablePriced step_reprice

-- W61 and W62: names actually held on reachable outputs and notices.
example : Reachable priced ∧ tagName "alice" ∈ output.tags ∧ output ∈ priced.live ∧
    tagName "alice" = tagName notice.oracle := ⟨reachablePriced, by decide, by decide, rfl⟩
example : Reachable priced ∧ notice ∈ priced.notices ∧
    priceName "alice" = notice.token := ⟨reachablePriced, by decide, rfl⟩
-- W63 and W64: all four roles are realized, including both judgment verdicts.
def allRoles := afterPriceMint equivocal mintPrice
example : Reachable allRoles ∧ tagName "alice" ∈ output.tags ∧
    approved "bob" ∈ allRoles.judgments ∧ refused "bob" ∈ allRoles.judgments ∧
    notice ∈ allRoles.notices ∧ (tagName "alice").role ≠ notice.token.role :=
  ⟨.next reachableEquivocal (.priceMint _ _ ⟨by decide, rfl, rfl⟩),
    by decide, by decide, by decide, by decide, by decide⟩
example : Reachable allRoles ∧ notice ∈ allRoles.notices :=
  ⟨.next reachableEquivocal (.priceMint _ _ ⟨by decide, rfl, rfl⟩), by decide⟩
-- W65, W66 and W67: two different registry oracles, exactly one tag each.
example : Reachable repriced ∧ repriced.cage.oracles = ["alice", "bob"] :=
  ⟨reachableRepriced, rfl⟩
example : Reachable repriced ∧ output ∈ repriced.live ∧
    output.tags = [tagName "alice", tagName "bob"] :=
  ⟨reachableRepriced, by decide, rfl⟩
example : Reachable repriced ∧ output ∈ repriced.live ∧ output.tags.Nodup :=
  ⟨reachableRepriced, by decide, by decide⟩
-- W68: both members discover it, an outsider does not, a consumed output is gone.
example : Reachable s1 ∧ Reachable s4 ∧
    output ∈ discover "alice" s1.live ∧ output ∈ discover "bob" s1.live ∧
    output ∉ discover "outsider" s1.live ∧ output ∉ discover "alice" s4.live :=
  ⟨reachable1, reachable4, by decide, by decide, by decide, by decide⟩

-- W69: a distinct registry shares alice, but not bob, with the first registry.
def otherCage : CageState :=
  ⟨⟨"policy", "other-registry"⟩, ["alice", "carol"], "other-protocol", emptyTrie, none⟩
def otherOutput : RequestOutput :=
  ⟨{ request with cage := otherCage.id, seed := "other-seed" }, 10,
    [tagName "alice", tagName "carol"], "other-output", [requestName otherCage.id], .release⟩
def otherCreate : CreateTx :=
  ⟨["other-seed"], otherCage, tokensOf otherOutput, [otherOutput], [], .release⟩
def otherState := afterCreate (initial otherCage) otherCreate otherOutput

def reachableOther : Reachable otherState := by
  apply Reachable.next (Reachable.registry otherCage [] ?_)
  · apply Step.create (initial otherCage) otherCreate otherOutput rfl
    · concrete
    · concrete
    · concrete
  · simp [registryCreated, RegistryValid, otherCage]

example : Reachable s1 ∧ Reachable otherState ∧ s1.cage.id ≠ otherState.cage.id ∧
    output ∈ discover "alice" ([s1, otherState].flatMap State.live) ∧
    otherOutput ∈ discover "alice" ([s1, otherState].flatMap State.live) ∧
    otherOutput ∉ discover "bob" ([s1, otherState].flatMap State.live) :=
  ⟨reachable1, reachableOther, by decide, by decide, by decide, by decide⟩
-- W70: all three exits remove the live request and burn both tags.
example : Reachable s3 ∧ Step s3 (.fold fold) s4 ∧
    Reachable mixed ∧ Step mixed (.account (account false)) (afterExit mixed output) ∧
    Reachable s1 ∧ Step s1 (.withdraw withdraw) (afterExit s1 output) ∧
    output ∈ s3.live ∧ output ∉ s4.live ∧ output ∉ (afterExit mixed output).live ∧
    output ∉ (afterExit s1 output).live :=
  ⟨reachable3, step_fold, reachableMixed, step_account, reachable1, step_withdraw,
    by decide, by decide, by decide, by decide⟩
-- W71 and W72: signed mint and signed update of an authenticated held occurrence.
example : Reachable s3 ∧ Step s3 (.priceMint mintPrice) priced :=
  ⟨reachable3, step_price⟩
example : Reachable priced ∧ Step priced (.priceUpdate updatePrice) repriced ∧
    updatePrice.output.datum ≠ updatePrice.input.datum :=
  ⟨reachablePriced, step_reprice, by decide⟩
-- W73
example : Reachable repriced ∧ updatePrice.output ∈ repriced.notices :=
  ⟨reachableRepriced, by decide⟩
-- W74: an unlisted oracle can publish without any live request.
def outsiderPrice : PriceMintTx :=
  ⟨⟨"outsider", priceName "outsider", ⟨0, []⟩⟩, ["outsider"], [priceName "outsider"]⟩
example : Reachable s0 ∧ "outsider" ∉ s0.cage.oracles ∧
    Step s0 (.priceMint outsiderPrice) (afterPriceMint s0 outsiderPrice) :=
  ⟨reachable0, by decide, .priceMint _ _ ⟨by decide, rfl, rfl⟩⟩
-- W75: price can change downward; a subsequent increase is also allowed.
example : Reachable priced ∧ notice ∈ priced.notices ∧
    notice.token = priceName notice.oracle ∧ notice.datum.fee > 1 :=
  ⟨reachablePriced, by decide, rfl, by decide⟩
-- W76: noninterference has nonempty live, minted judgments and fee allocations.
example : Reachable s3 ∧ Step s3 (.priceMint mintPrice) priced ∧
    Step priced (.priceUpdate updatePrice) repriced ∧
    s3.live ≠ [] ∧ s3.judgments ≠ [] ∧ fold.allocations ≠ [] :=
  ⟨reachable3, step_price, step_reprice, by decide, by decide, by decide⟩
-- W77: the advertised 100/200 does not bind alice's declared fee of 2.
example : Reachable priced ∧ Step priced (.fold fold) (afterFold priced fold) ∧
    notice ∈ priced.notices ∧ request.fee "alice" = 2 ∧ notice.datum.fee = 100 ∧
    (.fold fold : Action).isPrice = false :=
  ⟨reachablePriced, .fold _ _ rfl (by concrete) (by concrete) fold_ok,
    by decide, rfl, rfl, rfl⟩

-- W78: both mint and update introduce a genuinely new notice value.
example : Reachable s3 ∧ Step s3 (.priceMint mintPrice) priced ∧
    notice ∈ priced.notices ∧ notice ∉ s3.notices ∧
    Step priced (.priceUpdate updatePrice) repriced ∧
    updatePrice.output ∈ repriced.notices ∧ updatePrice.output ∉ priced.notices :=
  ⟨reachable3, step_price, by decide, by decide, step_reprice, by decide, by decide⟩

end RequestApprovalFold.Witnesses
