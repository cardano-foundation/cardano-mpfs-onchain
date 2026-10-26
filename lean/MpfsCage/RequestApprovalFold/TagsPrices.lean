import MpfsCage.RequestApprovalFold.RepairWitnesses

namespace RequestApprovalFold

/-! Oracle discovery and signed, nonbinding price notices. The role field is
    the first field of the collision-free abstract name, not a concrete hash. -/

theorem tag_name_injective (a b : Signer) :
    tagName a = tagName b ↔ a = b := by
  sorry

theorem price_name_injective (a b : Signer) :
    priceName a = priceName b ↔ a = b := by
  sorry

/-- Every pair of different roles is separated, for any payloads. -/
theorem different_roles_never_coincide (a b : TokenRole) (x y : NameBinding) :
    a ≠ b → tokenName a x ≠ tokenName b y := by
  sorry

theorem names_have_leading_roles (c : CageId) (r : Request) (oracle : Signer) :
    (tagName oracle).role = .tag ∧
    (judgmentName c r oracle true).role = .approval ∧
    (judgmentName c r oracle false).role = .refusal ∧
    (priceName oracle).role = .price := by
  sorry

theorem reachable_registry_valid (s : State) :
    Reachable s → s.cage.oracles ≠ [] ∧ s.cage.oracles.Nodup := by
  sorry

/-- Exact holdings, not just one direction of discovery. -/
theorem reachable_live_tags (s : State) :
    Reachable s → ∀ o ∈ s.live,
      o.request.cage = s.cage.id ∧ o.tags = s.cage.oracles.map tagName := by
  sorry

theorem reachable_tags_unique (s : State) (o : RequestOutput) :
    Reachable s → o ∈ s.live → o.tags.Nodup := by
  sorry

theorem discovery_iff (s : State) (oracle : Signer) (o : RequestOutput) :
    Reachable s →
      (o ∈ discover oracle s.live ↔ o ∈ s.live ∧ oracle ∈ s.cage.oracles) := by
  sorry

/-- The same asset name finds work in any registry listing this oracle. -/
theorem discovery_across_registries (states : List State) (oracle : Signer)
    (o : RequestOutput) :
    (∀ s ∈ states, Reachable s) →
    (o ∈ discover oracle (states.flatMap State.live) ↔
      ∃ s ∈ states, o ∈ s.live ∧ oracle ∈ s.cage.oracles) := by
  sorry

/-- All oracle tags are burned by the actual action removing the live output. -/
theorem live_removal_burns_oracle_tags {s s' : State} {action : Action}
    (o : RequestOutput) :
    Reachable s → Step s action s' → o ∈ s.live → o ∉ s'.live →
    ∃ spend, action.spend = some spend ∧ requestSpendAllowed o spend ∧
      ∀ oracle ∈ s.cage.oracles, tagName oracle ∈ spend.burned := by
  sorry

theorem price_mint_inversion {s s' : State} (tx : PriceMintTx) :
    Step s (.priceMint tx) s' →
    tx.output.oracle ∈ tx.signers ∧
    tx.output.token = ⟨.price, .oracle tx.output.oracle⟩ ∧
    tx.minted = [tx.output.token] ∧ s'.notices = tx.output :: s.notices := by
  sorry

theorem price_update_inversion {s s' : State} (tx : PriceUpdateTx) :
    Step s (.priceUpdate tx) s' →
    tx.input ∈ s.notices ∧ tx.input.oracle ∈ tx.signers ∧
    tx.input.token = ⟨.price, .oracle tx.input.oracle⟩ ∧
    tx.output.oracle = tx.input.oracle ∧ tx.output.token = tx.input.token ∧
    tx.minted = [] ∧ s'.notices = tx.output :: s.notices.erase tx.input := by
  sorry

theorem reachable_notice_names (s : State) :
    Reachable s → ∀ n ∈ s.notices, n.token = ⟨.price, .oracle n.oracle⟩ := by
  sorry

/-- Publishing is independent of membership, protocol, and any live request. -/
theorem price_mint_available (s : State) (oracle : Signer) (datum : PriceDatum) :
    Step s (.priceMint ⟨⟨oracle, priceName oracle, datum⟩, [oracle], [priceName oracle]⟩)
      (afterPriceMint s ⟨⟨oracle, priceName oracle, datum⟩, [oracle], [priceName oracle]⟩) := by
  sorry

/-- Any new advertised datum is permitted, including a higher or lower price. -/
theorem price_update_available (s : State) (n : PriceNotice) (datum : PriceDatum) :
    n ∈ s.notices → n.token = priceName n.oracle →
    Step s (.priceUpdate ⟨n, { n with datum := datum }, [n.oracle], []⟩)
      (afterPriceUpdate s ⟨n, { n with datum := datum }, [n.oracle], []⟩) := by
  sorry

theorem price_notice_noninterference {s s' : State} {action : Action} :
    Step s action s' → action.isPrice = true →
    s'.cage = s.cage ∧ s'.usedSeeds = s.usedSeeds ∧ s'.live = s.live ∧
    s'.judgments = s.judgments ∧ s'.issued = s.issued ∧
    action.spend = none ∧ action.payments = [] := by
  sorry

/-- Changing or deleting every notice leaves the same non-price transaction
    executable, with the same requests, evidence, time and payments. -/
theorem notices_do_not_bind_protocol {s s' : State} {action : Action}
    (notices : List PriceNotice) :
    Step s action s' → action.isPrice = false →
    Step { s with notices := notices } action { s' with notices := notices } := by
  sorry

/-- Every new notice datum has an actual signed mint or update as its source. -/
theorem notice_change_authorized {s s' : State} {action : Action} (n : PriceNotice) :
    Step s action s' → n ∈ s'.notices → n ∉ s.notices →
    (∃ tx, action = .priceMint tx ∧ tx.output = n ∧ n.oracle ∈ tx.signers) ∨
    (∃ tx, action = .priceUpdate tx ∧ tx.input ∈ s.notices ∧
      tx.output = n ∧ tx.input.oracle = n.oracle ∧ n.oracle ∈ tx.signers) := by
  sorry

end RequestApprovalFold
