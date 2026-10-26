# Candidate theorem and semantic-atom ledgers

Authority: decisions.md at caaebc5, sha256
35e07d9db8a05ccdf43cd037b5a6783fa849dd110c6d1e604cb24345fa28f79f,
A-001-model-boundaries (time item superseded), and A-002 in lean-author-2/brief.md.

This ledger is an author claim for the tags/prices candidate. Fresh independent
statement and mutation audits are deferred. Every mutant below is a proposed
single edit of a production definition, not a reported mutation kill. Historical
lean-author-2 and mutation-audit-2 receipts concern their frozen predecessor;
they do not establish mutation coverage of this candidate. In particular the
prior mutation report retained M48, A13 and R-a13-mint-enforce as BLOCKED.
W01–W46 label compiled examples in Witnesses.lean; W47–W60 are in
RepairWitnesses.lean under lean/MpfsCage/RequestApprovalFold/. Concrete proof definitions
establish registry creation, live request creation, two independent judgments,
a fold, mixed approval/refusal settlement, owner withdrawal and dead-token burn
using only model constructors and core lemmas. They do not use admitted
candidate theorems. W24b supplies the full insert/unset/insert antecedent.
W61–W78 label compiled examples in TagsPricesWitnesses.lean. They add signed
notice mint/update traces alongside nonempty live requests and judgment holdings,
a second registry sharing alice, both positive and negative discovery queries,
and a successful fold whose declared fee is below the advertised price.

The semantic law is the action-indexed Step in Model.lean, with FoldRun for ordered application.
Public guard inversions are the creation, judgment, fold, account and withdrawal
rows; live_removal_is_legal_exit and new_judgment_is_authorized connect them to
the authoritative state machine. Steps which do not consume are distinguished
from request exits. Request identity includes its globally spent-once seed;
registry-local histories retain used seeds forever. Cross-registry uniqueness
uses the explicit ledger-wide SpentOnce premise, not a global chain simulator.

## Theorems

All names are in RequestApprovalFold. There are 78 theorem declarations: the
60 existing rows and 18 additions. Phase 1 admits 28 changed/new proofs (OPEN);
50 retained proof bodies remain. A retained body may depend on an admitted
helper: no PROVED outcome is inferred from a successful statement-phase build.
All rows await the clean phase-2 build and axiom check. No REFUTED claim.
T20/T25/T33 retain their canonical-allocation helper claims; T53/T54 state exact
payments independently of those shared definitions.

Two existing statements are restated, without dropping a guarantee:

| Row | Change | Reason |
|---|---|---|
| T07 | Minted and output tags equal the referenced registry's oracle list mapped to tagName | One tag per oracle supersedes one registry-named tag; singleton output, seed spending, registry binding and funding retained |
| T11 | First argument is tagOracle : Signer instead of c : CageId | Tags bind oracle identity across registries; separation from every judgment is retained |

T10's full registry/request/seed/oracle/verdict binding stays unchanged. T13,
T15, T39, T40, T42, T45 and T46 require additional price-constructor proof cases;
their statements are unchanged. Other retained statements remain unchanged,
including all payment and time-window guarantees. T31's singular name is retained:
its quantifier already covers every tag in the consumed output.

| Row | Theorem | Decision / semantic obligation | Reachable antecedent | Single-edit production mutant (expected falsifier) | Outcome |
|---|---|---|---|---|---|
| T01 | applyAll_append | Fold composition | W01 | applyAll cons: return w.apply t and discard the tail | OPEN |
| T02 | foldRun_step_valid | Fold guards | W02 | FoldRun.cons: remove stepValid premise | OPEN |
| T03 | foldRun_result | Fold ordered effects | W03 | FoldRun.cons: recurse on t instead of write.apply t | OPEN |
| T04 | foldRun_conditions | Conditions at intermediate tree | W04 | FoldRun.cons: check stepValid against emptyTrie | OPEN |
| T05 | applyAll_keeps_present | Present-key preservation | W05 | Write.apply set: store none instead of some value | OPEN |
| T06 | registry_creation | Registry creation | W06 | registryCreated: remove RegistryValid guard | OPEN |
| T07 | create_tags_existing_cage | Request creation and tag minting | W07 | createAllowed: drop seed-spent guard | OPEN |
| T08 | requests_unique_in_history | Historical request uniqueness | W08 | createAllowed: drop seed-spent guard | OPEN |
| T09 | judgment_authorized_and_bound | Judgment authorization, time, binding | W09 | judgmentAllowed: drop oracle-membership guard | OPEN |
| T10 | judgment_not_replayable | Judgment replay protection | W10 | judgmentName: replace request seed with a constant | OPEN |
| T11 | token_roles_separated | Tag/judgment domain separation | W11 | judgmentName: emit tag-role name | OPEN |
| T12 | fold_preserves_registry | Immutable registry identity | W12 | foldAccepted: drop protocol-preservation guard | OPEN |
| T13 | step_preserves_registry | Immutable registry on every step | W13 | afterJudgment: replace cage.protocol with a constant | OPEN |
| T14 | history_preserves_registry | Immutable registry across composition | W14 | afterJudgment: replace cage.oracles with [] | OPEN |
| T15 | only_fold_changes_tree | Only fold changes cage | W15 | afterJudgment: replace cage.trie with a constant populated trie | OPEN |
| T16 | fold_only_approved_before_deadline | All oracles approve before deadline | W16 | stepValid: drop hasApproval guard | OPEN |
| T17 | fold_conditions_hold_when_applied | Intermediate-tree conditions | W17 | stepValid: test conditions on emptyTrie instead of t | OPEN |
| T18 | fold_root_is_folded_writes | Exact writes in exact order | W18 | FoldRun.cons: recurse on t without applying write | OPEN |
| T19 | fold_burns_tags | Burn tags on fold | W19 | foldAccepted: permit burned=[] | OPEN |
| T20 | fold_pays_and_keeps_rest | All fees paid and folder remainder | W20 | foldAccepted: permit allocations=[] | OPEN |
| T21 | allocation_conserves_value | Money conservation | W21 | allocation: replace remainder with o.value | OPEN |
| T22 | blind_write_folds_on_any_tree | Blind-write availability | W22 | stepValid: require nonempty conditions | OPEN |
| T23 | fold_permissionless | Permissionless submission | W23 | foldAccepted: require submitter=folder | OPEN |
| T24 | absent_inserts_exclusive | Absent-insert exclusivity | W24 + W24b | stepValid: omit condition check | OPEN |
| T25 | account_complete_and_pays | Complete account, fees, owner rest | W25 | accountAllowed: omit hasAccount guard | OPEN |
| T26 | account_anyone_in_window | Anyone may account within the closed account window | W26 | accountAllowed: require now<deadline | OPEN |
| T27 | account_fee_neutral | Approval/refusal fee neutrality | W27 | accountAllowed: increase remainder by one when a refusal is shown | OPEN |
| T28 | withdraw_only_owner_after_window | Owner-only timed withdrawal | W28 | withdrawAllowed: omit owner-signature guard | OPEN |
| T29 | owner_can_withdraw_everything | Withdrawal availability after window | W29 | withdrawAllowed: require paid=0 | OPEN |
| T30 | request_spent_only_by_lifecycle | No other legal request exit | W30 | requestSpendAllowed accounted: accept True | OPEN |
| T31 | every_exit_burns_tag | Every exit burns tags | W31 | withdrawAllowed: omit burned guard | OPEN |
| T32 | early_exit_requires_all_judgments | Early exits show every judgment | W32 | withdrawAllowed: omit after-window guard | OPEN |
| T33 | early_exit_pays_every_oracle | Early exits pay every oracle | W33 | accountAllowed: permit empty oracle payments | OPEN |
| T34 | before_deadline_only_approvals | Before the deadline only approvals or oracle signatures authorize an exit | W34 | hasApproval: use refusal instead of approval | OPEN |
| T35 | dead_judgment_can_burn | Dead judgments always burn | W35 | Step.burn: add a live-request premise | OPEN |
| T36 | judgments_do_not_consume | Judgment minting consumes no request | W36 | afterJudgment: replace live with [] | OPEN |
| T37 | exits_remove_consumed | Exit terminality | W37 | afterExit: preserve live unchanged | OPEN |
| T38 | fold_removes_consumed | Fold terminality | W38 | afterFold: preserve live unchanged | OPEN |
| T39 | used_seeds_monotone | Spent-once composition | W39 | afterExit: clear usedSeeds | OPEN |
| T40 | reachable_requests_have_spent_seeds | Live requests have spent seeds | W40 | afterCreate: preserve usedSeeds unchanged | OPEN |
| T41 | spent_seed_cannot_create_again | Seed cannot recur | W41 | createAllowed: omit seed-spent guard | OPEN |
| T42 | request_never_reappears | Consumed requests never reappear | W42 | Step.create: remove fresh-seed guard | OPEN |
| T43 | one_oracle_signature_suffices | Single-oracle old-design signature shortcut | W43 | hasApproval: remove signature alternative | OPEN |
| T44 | old_operations_correspond | Old Insert/Delete/Update correspondence | W44 | OldOperation.write delete: use set instead of unset | OPEN |
| T45 | live_removal_is_legal_exit | Authoritative machine exit inversion | W45 | afterBurn: clear live | OPEN |
| T46 | new_judgment_is_authorized | Authoritative machine judgment provenance | W46 | afterBurn: prepend a tag name to issued | OPEN |

| T47 | exit_time_window | Actual transaction observes its exclusive window | W47 | accountAllowed: remove either time bound (A-002) | OPEN |
| T48 | exit_windows_cover | The three scalar windows cover all time | W48 | Request.window: change Nat to Int, permitting negative windows (A-002) | OPEN |
| T49 | exit_kind_unique | At most one exit kind at any time | W49 | accountAllowed: omit upper time bound (A-002) | OPEN |
| T50 | fold_references_authentic | Fold references genuinely held minted tokens | W50 | Step.fold: replace reference authentication with True (a06-fold-auth) | OPEN |
| T51 | account_references_authentic | Account references genuinely held minted tokens | W51 | Step.account: replace reference authentication with True (a06-account-auth) | OPEN |
| T52 | creation_references_source | Creation uses registry in the source state | W52 | Step.create: replace cage equality with True (a07-cage) | OPEN |
| T53 | fold_payments_concrete | Exact declared oracle fees and folder remainder | W53 | allocation: replace beneficiary by attacker; independently Request.fee: use != (a09-recipient, a09-fee-binding) | OPEN |
| T54 | account_payments_concrete | Exact declared oracle fees and owner remainder | W54 | allocation: replace beneficiary by attacker; independently Request.fee: use != (a09-recipient, a09-fee-binding) | OPEN |
| T55 | creation_funds_declared_fees | Creation cannot underfund declared fees | W55 | Request.fee: use !=; registry with one oracle and no other fee makes creation underfunded (A08 collateral) | OPEN |
| T56 | burn_removes_one | One burn decreases held multiplicity by exactly one | W56 | afterBurn: retain judgments unchanged (a16-no-burn) | OPEN |
| T57 | burn_keeps_history | Burn does not erase permanent mint record | W57 | afterBurn: erase name from issued (a13-forget) | OPEN |
| T58 | fold_requests_unique | No duplicate request in accepted fold | W58 | foldAccepted: replace requests.Nodup by True (a18-duplicate) | OPEN |
| T59 | account_accepts_any_verdicts | Every judgment mix is usable in window | W59 | hasAccount: require verdict=true (a12-refusal-account) | OPEN |
| T60 | equivocation_reachable | Both verdicts coexist in reachable holdings and record | W60 | Step.judge: require NonEquivocating issuance (a13-mint-enforce) | OPEN |

| T61 | tag_name_injective | Oracle-bound discovery name | W61 | tagName: replace oracle by a constant | OPEN |
| T62 | price_name_injective | Oracle-bound notice name | W62 | priceName: replace oracle by a constant | OPEN |
| T63 | different_roles_never_coincide | All distinct leading roles are disjoint | W63 | tokenName: replace role by tag | OPEN |
| T64 | names_have_leading_roles | Tag, approval, refusal and price encode their actual roles | W64 | judgmentName: encode both verdicts as approval | OPEN |
| T65 | reachable_registry_valid | Reachable oracle sets remain nonempty and duplicate-free | W65 | registryCreated: remove RegistryValid guard | OPEN |
| T66 | reachable_live_tags | Exact per-oracle holdings of every live request | W66 | wellFormed: allow tags=[] | OPEN |
| T67 | reachable_tags_unique | Exactly one occurrence per oracle, no duplicate tags | W67 | registryCreated: allow duplicate oracle entries | OPEN |
| T68 | discovery_iff | Live request tag query is sound and complete | W68 | discover: retain every output regardless of tag | OPEN |
| T69 | discovery_across_registries | One query spans all reachable registries | W69 | discover: query only the first output | OPEN |
| T70 | live_removal_burns_oracle_tags | The actual removing action burns every registry-oracle tag | W70 | withdrawAllowed: remove burned guard | OPEN |
| T71 | price_mint_inversion | Signed mint, bound name, exact issuance and output effect | W71 | priceMintAllowed: remove signature guard | OPEN |
| T72 | price_update_inversion | Held-input authentication, signature, token retention and exact update | W72 | priceUpdateAllowed: remove signature guard | OPEN |
| T73 | reachable_notice_names | All held notices bind their oracle and price role | W73 | priceUpdateAllowed: allow changing output.oracle | OPEN |
| T74 | price_mint_available | Any oracle can publish any advertised datum | W74 | priceMintAllowed: require output.datum.fee=0 | OPEN |
| T75 | price_update_available | Oracle can change a held notice to any datum | W75 | priceUpdateAllowed: require unchanged datum | OPEN |
| T76 | price_notice_noninterference | Price actions preserve registry, requests, judgments, seeds; no payments or exit | W76 | afterPriceMint: clear judgments | OPEN |
| T77 | notices_do_not_bind_protocol | Same protocol action and payments with arbitrary notice observations | W77 | Step.fold: require notices=[] | OPEN |
| T78 | notice_change_authorized | New notice values have a signed actual mint/update origin | W78 | afterJudgment: prepend a fresh price notice | OPEN |

## Semantic atoms

| Atom | Class | Production decision/effect | Covered rows | Adversarial case / limit |
|---|---|---|---|---|
| A01 | Authorization | nonempty unique oracle set; immutable protocol; no owner/end/transfer constructor | T06, T12–T15 | remove creation guard or change metadata during judgment |
| A02 | Authorization | oracle membership AND authenticated signature | T09, T46 | outsider mints; member lacks signature |
| A03 | Authorization | every oracle approval token OR fold signature | T16, T32, T43 | missing one approval; one signer does not speak for all |
| A04 | Authorization | owner signature AND strict after-window time | T28–T29, T32–T33 | deadline+window equality rejects withdrawal |
| A05 | Evidence binding | structured role, registry, full request/seed, oracle, verdict | T07–T11, T34, T46 | copied seed, changed write, other registry/oracle/verdict; concrete encoding excluded |
| A06 | Evidence binding | Step.judge references live output and exact cage; Step.fold/account reference minted tokens | T36, T45–T46, T50–T51 | no mint from a consumed request; fake name is not authentic evidence |
| A07 | Evidence binding | request creation references existing cage, spends fresh seed, one tag per oracle and singleton output | T07–T08, T39–T41, T52 | reused seed, extra mint, split tag outputs |
| A08 | Money | creation funds sum of distinct oracles' independent fees | T07, T21, T55 | underfunded escrow; duplicate oracle rejected at origin |
| A09 | Money | fold allocates exact fees and entire remainder to folder | T20–T21, T33, T53 | omit oracle, underpay, double-count same-address allocations |
| A10 | Money | complete account pays exact fees and owner remainder | T25, T27, T33, T54 | refusal changes payment; divert rest |
| A11 | Money | owner withdrawal takes entire input | T28–T29 | partial payout or wrong recipient |
| A12 | Refusal | verdict false satisfies account but not fold approval | T16, T25, T34, T59 | refusal cannot authorize fold; refusal must remain usable in account |
| A13 | Refusal | equivocation is permitted and fee-neutral | T27, T57, T60 | conflicting verdicts coexist; either account pays the same; permanent issued record survives burns |
| A14 | Terminality | only three request exits; all burn their tags | T19, T28, T30–T32, T45 | extra disappearance via unrelated transition |
| A15 | Terminality | consumed output removed; spent seed never clears | T37–T42 | request reappears in a later history |
| A16 | Terminality | dead judgments burn without cage/request cooperation | T35–T36, T56 | expired request cannot trap a token; holder authentication external |
| A17 | Composition | fold guards check each intermediate tree; all writes applied once in list order | T01–T05, T17–T18, T24 | skip/reorder/change write; conflicting absent inserts without unset |
| A18 | Composition | same request cannot occur twice within a fold | T58; W24b uses distinct seeds | duplicate input is rejected; no global uniqueness of live seeds claimed |
| A19 | Composition | arbitrary submitter; signature shortcut distinct from submitter identity | T23, T26, T43 | changing submitter must not remove oracle evidence |
| A20 | Composition | old operation translation retains own-key precondition and tree effect | T44 | no claim that shipped validators implement this new lifecycle |
| A21 | Time | fold before deadline; account in closed window; withdrawal strictly after | T26, T34, T47–T49 | account at deadline and deadline+window accepted; windows do not promise evidence availability |

| A22 | Discovery | creation mints every oracle tag exactly once, all into the request output | T07, T61, T65–T69 | omit an oracle, add an outsider tag, duplicate a tag, split outputs; queried names do not bind registry identity |
| A23 | Terminality | actual consuming action burns all oracle tags | T19, T28, T31, T66, T70 | burn only one oracle's tag or retain a consumed output in query results |
| A24 | Authorization | price mint needs the named oracle's signature | T62, T71, T74, T78 | wrong signer, wrong name, extra mint, no output; oracle need not belong to current registry |
| A25 | Authorization / effect | update consumes a held notice, requires its oracle signature, retains oracle/token, mints nothing | T72–T73, T75, T78 | forged input, unsigned update, transferred oracle, replaced token, remint; change datum freely |
| A26 | Non-interference | price transitions affect only notices and have no protocol payments | T13–T15, T39–T40, T42, T45–T46, T76 | alter registry, live requests, judgment holdings/history or seeds; emit a payment |
| A27 | Nonbinding | notice datum never constrains creation, judgment, fold, account, withdrawal or burn | T74–T77 | enforce advertised fee or require a notice; holding out and ordering are not prevented |
| A28 | Evidence binding | all hashed names carry role first; names injectively bind their specified fields | T10–T11, T61–T64, T71–T73 | erase oracle, registry, request field, verdict or leading role; no cryptographic/serialization claim |

## Modelling choices and omissions

A-001 authorizes nonempty duplicate-free oracle lists, independent nonnegative
fees, full funding at creation, strict time boundaries, fresh state-token
identity and explicit ledger abstractions. The new Discovery decision replaces
the former registry-named tag choice. T66–T70 close oracle discovery through
live request tags in the abstract model, including a query across registries.
They do not establish an indexer's completeness or concrete chain asset-query
behavior. Names are collision-free structured values: role then binding fields.
Protocol hashes/evidence remain opaque and unexamined.

Folder ordering and complementary-oracle hold-up remain accepted. T01–T04,
T17–T18 and T24 depend explicitly on the supplied ordered list and intermediate
trees; none promises fairness, first-come-first-served order, a fee cap, oracle
response or progress. T27/T53/T54 payments depend on declared fees, not order or
notices. T77 transports the identical transaction, hence identical payments,
when notices change.

PriceDatum carries a default natural fee and an optional list of per-protocol
entries. The model does not interpret that list or claim canonical ordering,
unique entries or price selection; it is advertised data. Notices are a list of
occurrences; updates erase one input occurrence and prepend one output. No
one-mint-per-oracle restriction or unique latest notice is imposed by the
current decisions. A notice observation accompanies each registry-local state;
no global UTxO synchronization is modeled. Payments are observed on actions,
not stored as balances; T76 guarantees price actions pay nothing and preserve
all core state. Release policy identity remains the D11 omission below.

D11 (one request-policy identity per release shared across registries and spend/mint
roles) and D25 (enumerating approved requests from judgments) are explicit
omissions in Model.lean, not covered guarantees. This chooses the omission
alternative authorized by the repair brief.

Judgment holdings are lists of token occurrences. A burn removes one occurrence,
not every repeated mint with the same name. T56 states the exact decrement, and
T57 retains the historical mint record. Fee declarations retain first matching
entry/default-zero semantics; T53–T55 spell that lookup directly and do not call
Request.fee, totalFees, oraclePayments or allocation in their conclusions.

The executable oracle surface, JSON codecs, generic driver and replay corpus
are omitted by the brief. No devnet/cost, concrete serialization, global chain,
implementation conformance, hosted CI, independent audit or accepted-law claim.
