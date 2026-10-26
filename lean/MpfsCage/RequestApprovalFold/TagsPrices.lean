import MpfsCage.RequestApprovalFold.RepairWitnesses

namespace RequestApprovalFold

/-! Oracle discovery and signed, nonbinding price notices. The role field is
    the first field of the collision-free abstract name, not a concrete hash. -/

theorem tag_name_injective (a b : Signer) :
    tagName a = tagName b ↔ a = b := by
  simp [tagName, tokenName]

theorem price_name_injective (a b : Signer) :
    priceName a = priceName b ↔ a = b := by
  simp [priceName, tokenName]

/-- Every pair of different roles is separated, for any payloads. -/
theorem different_roles_never_coincide (a b : TokenRole) (x y : NameBinding) :
    a ≠ b → tokenName a x ≠ tokenName b y := by
  intro hne he
  exact hne (congrArg TokenName.role he)

theorem names_have_leading_roles (c : CageId) (r : Request) (oracle : Signer) :
    (tagName oracle).role = .tag ∧
    (judgmentName c r oracle true).role = .approval ∧
    (judgmentName c r oracle false).role = .refusal ∧
    (priceName oracle).role = .price := by
  exact ⟨rfl, rfl, rfl, rfl⟩

theorem reachable_registry_valid (s : State) :
    Reachable s → s.cage.oracles ≠ [] ∧ s.cage.oracles.Nodup := by
  intro hr
  induction hr with
  | registry c existing hc => exact hc.2.1
  | next _ hs ih =>
    simpa only [(step_preserves_registry hs).2.1] using ih

/-- Exact holdings, not just one direction of discovery. -/
theorem reachable_live_tags (s : State) :
    Reachable s → ∀ o ∈ s.live,
      o.request.cage = s.cage.id ∧ o.tags = s.cage.oracles.map tagName := by
  intro hr
  induction hr with
  | registry => intro o ho; cases ho
  | @next s s' action _ hs ih =>
    have hmeta := step_preserves_registry hs
    have keep : ∀ o ∈ s.live,
        o.request.cage = s'.cage.id ∧ o.tags = s'.cage.oracles.map tagName := by
      intro o ho
      simpa only [hmeta.1, hmeta.2.1] using ih o ho
    intro o ho
    cases hs with
    | create tx created hc ha _ =>
      rcases List.mem_cons.mp ho with rfl | hm
      · exact ⟨ha.2.2.2.1.trans (congrArg CageState.id hc),
          by simpa only [hc] using ha.2.2.2.2.1⟩
      · exact keep o hm
    | judge => exact keep o ho
    | burn => exact keep o ho
    | priceMint => exact keep o ho
    | priceUpdate => exact keep o ho
    | fold => exact keep o (List.mem_filter.mp ho).1
    | account => exact keep o (List.mem_filter.mp ho).1
    | withdraw => exact keep o (List.mem_filter.mp ho).1

theorem reachable_tags_unique (s : State) (o : RequestOutput) :
    Reachable s → o ∈ s.live → o.tags.Nodup := by
  intro hr ho
  rw [(reachable_live_tags s hr o ho).2]
  have hd := (reachable_registry_valid s hr).2
  generalize s.cage.oracles = oracles at *
  induction oracles with
  | nil => simp
  | cons a rest ih =>
    simp only [List.nodup_cons] at hd
    simp only [List.map_cons, List.nodup_cons]
    refine ⟨?_, ih hd.2⟩
    intro hm
    obtain ⟨b, hb, he⟩ := List.mem_map.mp hm
    exact hd.1 ((tag_name_injective b a).mp he ▸ hb)

theorem discovery_iff (s : State) (oracle : Signer) (o : RequestOutput) :
    Reachable s →
      (o ∈ discover oracle s.live ↔ o ∈ s.live ∧ oracle ∈ s.cage.oracles) := by
  intro hr
  simp only [discover, List.mem_filter, decide_eq_true_eq]
  constructor
  · rintro ⟨ho, ht⟩
    rw [(reachable_live_tags s hr o ho).2] at ht
    obtain ⟨member, hm, he⟩ := List.mem_map.mp ht
    exact ⟨ho, (tag_name_injective member oracle).mp he ▸ hm⟩
  · rintro ⟨ho, hm⟩
    refine ⟨ho, ?_⟩
    rw [(reachable_live_tags s hr o ho).2]
    exact List.mem_map.mpr ⟨oracle, hm, rfl⟩

/-- The same asset name finds work in any registry listing this oracle. -/
theorem discovery_across_registries (states : List State) (oracle : Signer)
    (o : RequestOutput) :
    (∀ s ∈ states, Reachable s) →
    (o ∈ discover oracle (states.flatMap State.live) ↔
      ∃ s ∈ states, o ∈ s.live ∧ oracle ∈ s.cage.oracles) := by
  intro hr
  simp only [discover, List.mem_filter, decide_eq_true_eq, List.mem_flatMap]
  constructor
  · rintro ⟨⟨s, hs, ho⟩, ht⟩
    have hquery : o ∈ discover oracle s.live := List.mem_filter.mpr ⟨ho, by simpa using ht⟩
    exact ⟨s, hs, (discovery_iff s oracle o (hr s hs)).mp hquery⟩
  · rintro ⟨s, hs, ho, hm⟩
    have hquery := (discovery_iff s oracle o (hr s hs)).mpr ⟨ho, hm⟩
    exact ⟨⟨s, hs, ho⟩, by simpa using (List.mem_filter.mp hquery).2⟩

/-- All oracle tags are burned by the actual action removing the live output. -/
theorem live_removal_burns_oracle_tags {s s' : State} {action : Action}
    (o : RequestOutput) :
    Reachable s → Step s action s' → o ∈ s.live → o ∉ s'.live →
    ∃ spend, action.spend = some spend ∧ requestSpendAllowed o spend ∧
      ∀ oracle ∈ s.cage.oracles, tagName oracle ∈ spend.burned := by
  intro hr hs ho hgone
  obtain ⟨spend, he, ha, _⟩ := live_removal_is_legal_exit hs o ho hgone
  refine ⟨spend, he, ha, ?_⟩
  intro oracle hm
  apply every_exit_burns_tag o spend ha
  change tagName oracle ∈ o.tags
  rw [(reachable_live_tags s hr o ho).2]
  exact List.mem_map.mpr ⟨oracle, hm, rfl⟩

theorem price_mint_inversion {s s' : State} (tx : PriceMintTx) :
    Step s (.priceMint tx) s' →
    tx.output.oracle ∈ tx.signers ∧
    tx.output.token = ⟨.price, .oracle tx.output.oracle⟩ ∧
    tx.minted = [tx.output.token] ∧ s'.notices = tx.output :: s.notices := by
  intro h
  cases h with
  | priceMint _ ha => exact ⟨ha.1, ha.2.1, ha.2.2, rfl⟩

theorem price_update_inversion {s s' : State} (tx : PriceUpdateTx) :
    Step s (.priceUpdate tx) s' →
    tx.input ∈ s.notices ∧ tx.input.oracle ∈ tx.signers ∧
    tx.input.token = ⟨.price, .oracle tx.input.oracle⟩ ∧
    tx.output.oracle = tx.input.oracle ∧ tx.output.token = tx.input.token ∧
    tx.minted = [] ∧ s'.notices = tx.output :: s.notices.erase tx.input := by
  intro h
  cases h with
  | priceUpdate _ hi ha =>
    exact ⟨hi, ha.1, ha.2.1, ha.2.2.1, ha.2.2.2.1, ha.2.2.2.2, rfl⟩

theorem reachable_notice_names (s : State) :
    Reachable s → ∀ n ∈ s.notices, n.token = ⟨.price, .oracle n.oracle⟩ := by
  intro hr
  induction hr with
  | registry => intro n hn; cases hn
  | next _ hs ih =>
    intro n hn
    cases hs with
    | create => exact ih n hn
    | judge => exact ih n hn
    | fold => exact ih n hn
    | account => exact ih n hn
    | withdraw => exact ih n hn
    | burn => exact ih n hn
    | priceMint tx ha =>
      rcases List.mem_cons.mp hn with rfl | hm
      · exact ha.2.1
      · exact ih n hm
    | priceUpdate tx _ ha =>
      rcases List.mem_cons.mp hn with rfl | hm
      · rw [ha.2.2.2.1, ha.2.2.1]
        exact ha.2.1
      · exact ih n (List.mem_of_mem_erase hm)

/-- Publishing is independent of membership, protocol, and any live request. -/
theorem price_mint_available (s : State) (oracle : Signer) (datum : PriceDatum) :
    Step s (.priceMint ⟨⟨oracle, priceName oracle, datum⟩, [oracle], [priceName oracle]⟩)
      (afterPriceMint s ⟨⟨oracle, priceName oracle, datum⟩, [oracle], [priceName oracle]⟩) := by
  apply Step.priceMint
  exact ⟨List.mem_cons_self, rfl, rfl⟩

/-- Any new advertised datum is permitted, including a higher or lower price. -/
theorem price_update_available (s : State) (n : PriceNotice) (datum : PriceDatum) :
    n ∈ s.notices → n.token = priceName n.oracle →
    Step s (.priceUpdate ⟨n, { n with datum := datum }, [n.oracle], []⟩)
      (afterPriceUpdate s ⟨n, { n with datum := datum }, [n.oracle], []⟩) := by
  intro hn ht
  apply Step.priceUpdate _ _ hn
  exact ⟨List.mem_cons_self, ht, rfl, rfl, rfl⟩

theorem price_notice_noninterference {s s' : State} {action : Action} :
    Step s action s' → action.isPrice = true →
    s'.cage = s.cage ∧ s'.usedSeeds = s.usedSeeds ∧ s'.live = s.live ∧
    s'.judgments = s.judgments ∧ s'.issued = s.issued ∧
    action.spend = none ∧ action.payments = [] := by
  intro hs hp
  cases hs <;> simp [Action.isPrice] at hp
  all_goals exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

/-- Changing or deleting every notice leaves the same non-price transaction
    executable, with the same requests, evidence, time and payments. -/
theorem notices_do_not_bind_protocol {s s' : State} {action : Action}
    (notices : List PriceNotice) :
    Step s action s' → action.isPrice = false →
    Step { s with notices := notices } action { s' with notices := notices } := by
  intro hs hp
  cases hs with
  | create tx o hc ha hf => exact Step.create _ tx o hc ha hf
  | judge tx hc hl ha => exact Step.judge _ tx hc hl ha
  | fold tx hc hl hj ha => exact Step.fold _ tx hc hl hj ha
  | account tx hc hl hj ha => exact Step.account _ tx hc hl hj ha
  | withdraw tx hl ha => exact Step.withdraw _ tx hl ha
  | burn name hm => exact Step.burn _ name hm
  | priceMint => cases hp
  | priceUpdate => cases hp

/-- Every new notice datum has an actual signed mint or update as its source. -/
theorem notice_change_authorized {s s' : State} {action : Action} (n : PriceNotice) :
    Step s action s' → n ∈ s'.notices → n ∉ s.notices →
    (∃ tx, action = .priceMint tx ∧ tx.output = n ∧ n.oracle ∈ tx.signers) ∨
    (∃ tx, action = .priceUpdate tx ∧ tx.input ∈ s.notices ∧
      tx.output = n ∧ tx.input.oracle = n.oracle ∧ n.oracle ∈ tx.signers) := by
  intro hs hn hold
  cases hs with
  | create => exact False.elim (hold hn)
  | judge => exact False.elim (hold hn)
  | fold => exact False.elim (hold hn)
  | account => exact False.elim (hold hn)
  | withdraw => exact False.elim (hold hn)
  | burn => exact False.elim (hold hn)
  | priceMint tx ha =>
    rcases List.mem_cons.mp hn with he | hm
    · subst n
      exact Or.inl ⟨tx, rfl, rfl, ha.1⟩
    · exact False.elim (hold hm)
  | priceUpdate tx hi ha =>
    rcases List.mem_cons.mp hn with he | hm
    · subst n
      exact Or.inr ⟨tx, rfl, hi, rfl, ha.2.2.1.symm, ha.2.2.1 ▸ ha.1⟩
    · exact False.elim (hold (List.mem_of_mem_erase hm))

end RequestApprovalFold
