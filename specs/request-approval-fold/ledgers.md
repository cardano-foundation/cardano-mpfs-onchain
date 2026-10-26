# Candidate theorem and semantic-atom ledgers

Authority: decisions.md at 097c17a, sha256 eaab55a1d31bfd6d70897f7ae971436922394dd3e56b4410b38b9182d30ac13a;
A-001-model-boundaries items 3/4; A-002 time windows; lean-author-4 answers/A-001-discovery-and-output-identity.md; statement-audit-5 A-001 output-reference clarification.

This is a local repair candidate for statement-audit-5 F1/F2 and mutation-audit-4
A29/A30, not independent acceptance. M48, M67, M69, M88, M91, M96, M103,
M105 and A13 remain accepted mutation-evidence limits and are not repaired here.

## Statements and witnesses

113 theorem declarations: all 111 prior names retained, two additions. This repair
restates only T35 and T83 and adds T112 and T113. In the statement phase these four
are OPEN with intentional sorry; the other 109 proof bodies and statement types
are unchanged. The reachable examples compile without using admitted guarantees.

W01–W46 are in Witnesses.lean, W47–W60 in RepairWitnesses.lean, W61–W78 in
TagsPricesWitnesses.lean, and W79–W113 plus W35b/W83b in RulesWitnesses.lean.
W35b is the audit's dead_condition_bearing_witness, with the nonempty absent-y
approval list now explicitly quantified by T35. W83b reaches a rule-bearing
registry requiring a separate creator signature, then exercises fold, mixed
complete account, owner withdrawal, and a dead conditional judgment burn. The
creator signature is absent from every exit, including the owner's withdrawal.
T83 spells the fold's conditions at every actual write prefix and the ordinary
settlement/withdrawal requirements directly, with no rule-admission premise and
no constant-True wrapper. The unused ruleBurnAllowed helper is removed.

T112 concludes Rule.admits on the actual output request and actual tx.signers,
from an actual creation Step and the source registry's rule. T113 names the rule
policy directly (and excludes release), or release when no rule exists, for both
the mint and output token. It also binds the singleton output and minted name.

Before the statement freeze, each exact audit mutant was applied locally. The
original reachable counterexample was extended with a kernel proof of the
negation of the new owning statement: rule-request and rule-signatures falsify
T112, request-policy-release falsifies T113. All three probes compile using only
Model, with propext as their sole axiom; all edits are reverted. Receipts and
exact instruments: lean-author-5/evidence/statements-<mutant>.log and
instruments/<mutant>-counterexample.lean in the orchestration runtime.
These are creator regression results; fresh independent mutation audit follows.

The semantic law is Step with FoldRun for ordered application. Provenance and
consumption inversions expose actual actions, source references and their evidence.
All payment and time guarantees remain; helper-based payment claims are supplemented
by T53/T54's concrete declared fee/address/remainder statements.

## Earlier extension history

The previous extension restated the following 18 source types. This repair preserves them;
changed definitions below them are reviewed separately. Restatement follows decisions,
not proof convenience. Approval-condition parameters generalize the prior empty-list case.

| Theorem | Reason |
|---|---|
| foldRun_step_valid | Generalizes fold guards to the selected oracle condition lists |
| foldRun_result | Carries the additional oracle-condition plan through ordered execution |
| foldRun_conditions | Carries the additional oracle-condition plan; requester guarantee unchanged |
| registry_creation | At least one oracle OR a rule replaces nonempty oracles |
| create_tags_existing_cage | Exact mint includes the request token; only oracle-bearing registries require spent seeds |
| requests_unique_in_history | Datum uniqueness applies to oracle-bearing registries; seedless identical datums are allowed |
| judgment_authorized_and_bound | Minted approval names bind the carried oracle conditions |
| judgment_not_replayable | Generalizes to condition-bearing names and adds exact approval-condition equality |
| fold_only_approved_before_deadline | Binds approval evidence to the fold-selected oracle conditions |
| blind_write_folds_on_any_tree | Blindness requires both requester and oracle condition lists empty |
| absent_inserts_exclusive | Generalizes ordered run to oracle condition plans; exclusivity unchanged |
| before_deadline_only_approvals | Approval references bind the selected oracle conditions |
| reachable_requests_have_spent_seeds | Seed spending is required only in oracle-bearing registries |
| spent_seed_cannot_create_again | Seed-spend refusal applies when tags are minted |
| request_never_reappears | All-registry output no-resurrection uses retained ledger output reference, not optional datum seed |
| one_oracle_signature_suffices | A signature authenticates the chosen oracle condition list |
| account_accepts_any_verdicts | Generalizes settlement availability to arbitrary condition-bearing approvals |
| reachable_registry_valid | Valid origin is nonempty oracles OR rule, retaining duplicate-free oracles |

T19/T31 now burn tags plus request tokens through tokensOf; their unchanged quantified
statements are stronger. Existing reachable examples specialize condition plans to the
empty list where appropriate. T42 covers every output identity, including seedless
requests; T08/T40/T41 retain seed/datum guarantees precisely where judgments exist.

## Theorems

| Row | Theorem | Decision / semantic obligation | Reachable antecedent | Single-edit production mutant (expected falsifier) | Outcome |
|---|---|---|---|---|---|
| T01 | applyAll_append | Fold composition | W01 | applyAll cons: return w.apply t and discard the tail | PROVED |
| T02 | foldRun_step_valid | Fold guards | W02 | FoldRun.cons: remove stepValid premise | PROVED |
| T03 | foldRun_result | Fold ordered effects | W03 | FoldRun.cons: recurse on t instead of write.apply t | PROVED |
| T04 | foldRun_conditions | Conditions at intermediate tree | W04 | FoldRun.cons: check stepValid against emptyTrie | PROVED |
| T05 | applyAll_keeps_present | Present-key preservation | W05 | Write.apply set: store none instead of some value | PROVED |
| T06 | registry_creation | Registry creation | W06 | registryCreated: remove RegistryValid guard | PROVED |
| T07 | create_tags_existing_cage | Request creation and tag minting | W07 | createAllowed: drop seed-spent guard | PROVED |
| T08 | requests_unique_in_history | Historical request uniqueness | W08 | createAllowed: drop seed-spent guard | PROVED |
| T09 | judgment_authorized_and_bound | Judgment authorization, time, binding | W09 | judgmentAllowed: drop oracle-membership guard | PROVED |
| T10 | judgment_not_replayable | Judgment replay protection | W10 | judgmentName: replace request seed with a constant | PROVED |
| T11 | token_roles_separated | Tag/judgment domain separation | W11 | judgmentName: emit tag-role name | PROVED |
| T12 | fold_preserves_registry | Immutable registry identity | W12 | foldAccepted: drop protocol-preservation guard | PROVED |
| T13 | step_preserves_registry | Immutable registry on every step | W13 | afterJudgment: replace cage.protocol with a constant | PROVED |
| T14 | history_preserves_registry | Immutable registry across composition | W14 | afterJudgment: replace cage.oracles with [] | PROVED |
| T15 | only_fold_changes_tree | Only fold changes cage | W15 | afterJudgment: replace cage.trie with a constant populated trie | PROVED |
| T16 | fold_only_approved_before_deadline | All oracles approve before deadline | W16 | stepValid: drop hasApproval guard | PROVED |
| T17 | fold_conditions_hold_when_applied | Intermediate-tree conditions | W17 | stepValid: test conditions on emptyTrie instead of t | PROVED |
| T18 | fold_root_is_folded_writes | Exact writes in exact order | W18 | FoldRun.cons: recurse on t without applying write | PROVED |
| T19 | fold_burns_tags | Burn tags on fold | W19 | foldAccepted: permit burned=[] | PROVED |
| T20 | fold_pays_and_keeps_rest | All fees paid and folder remainder | W20 | foldAccepted: permit allocations=[] | PROVED |
| T21 | allocation_conserves_value | Money conservation | W21 | allocation: replace remainder with o.value | PROVED |
| T22 | blind_write_folds_on_any_tree | Blind-write availability | W22 | stepValid: require nonempty conditions | PROVED |
| T23 | fold_permissionless | Permissionless submission | W23 | foldAccepted: require submitter=folder | PROVED |
| T24 | absent_inserts_exclusive | Absent-insert exclusivity | W24 + W24b | stepValid: omit condition check | PROVED |
| T25 | account_complete_and_pays | Complete account, fees, owner rest | W25 | accountAllowed: omit hasAccount guard | PROVED |
| T26 | account_anyone_in_window | Anyone may account within the closed account window | W26 | accountAllowed: require now<deadline | PROVED |
| T27 | account_fee_neutral | Approval/refusal fee neutrality | W27 | accountAllowed: increase remainder by one when a refusal is shown | PROVED |
| T28 | withdraw_only_owner_after_window | Owner-only timed withdrawal | W28 | withdrawAllowed: omit owner-signature guard | PROVED |
| T29 | owner_can_withdraw_everything | Withdrawal availability after window | W29 | withdrawAllowed: require paid=0 | PROVED |
| T30 | request_spent_only_by_lifecycle | No other legal request exit | W30 | requestSpendAllowed accounted: accept True | PROVED |
| T31 | every_exit_burns_tag | Every exit burns tags | W31 | withdrawAllowed: omit burned guard | PROVED |
| T32 | early_exit_requires_all_judgments | Early exits show every judgment | W32 | withdrawAllowed: omit after-window guard | PROVED |
| T33 | early_exit_pays_every_oracle | Early exits pay every oracle | W33 | accountAllowed: permit empty oracle payments | PROVED |
| T34 | before_deadline_only_approvals | Before the deadline only approvals or oracle signatures authorize an exit | W34 | hasApproval: use refusal instead of approval | PROVED |
| T35 | dead_judgment_can_burn | Every held dead judgment burns, for every verdict and condition list, preserving cage/live requests | W35 and W35b (dead_condition_bearing_witness) | burn-live-guard; alternatively Step.burn rejects nonempty approval conditions | OPEN |
| T36 | judgments_do_not_consume | Judgment minting consumes no request | W36 | afterJudgment: replace live with [] | PROVED |
| T37 | exits_remove_consumed | Exit terminality | W37 | afterExit: preserve live unchanged | PROVED |
| T38 | fold_removes_consumed | Fold terminality | W38 | afterFold: preserve live unchanged | PROVED |
| T39 | used_seeds_monotone | Spent-once composition | W39 | afterExit: clear usedSeeds | PROVED |
| T40 | reachable_requests_have_spent_seeds | Live oracle-bearing requests have spent seeds | W40 | afterCreate: preserve usedSeeds unchanged | PROVED |
| T41 | spent_seed_cannot_create_again | Seed cannot recur | W41 | createAllowed: omit seed-spent guard | PROVED |
| T42 | request_never_reappears | Consumed requests never reappear | W42 | Step.create: remove fresh-output-reference guard | PROVED |
| T43 | one_oracle_signature_suffices | Single-oracle old-design signature shortcut | W43 | hasApproval: remove signature alternative | PROVED |
| T44 | old_operations_correspond | Old Insert/Delete/Update correspondence | W44 | OldOperation.write delete: use set instead of unset | PROVED |
| T45 | live_removal_is_legal_exit | Authoritative machine exit inversion | W45 | afterBurn: clear live | PROVED |
| T46 | new_judgment_is_authorized | Authoritative machine judgment provenance | W46 | afterBurn: prepend a tag name to issued | PROVED |

| T47 | exit_time_window | Actual transaction observes its exclusive window | W47 | accountAllowed: remove either time bound (A-002) | PROVED |
| T48 | exit_windows_cover | The three scalar windows cover all time | W48 | Request.window: change Nat to Int, permitting negative windows (A-002) | PROVED |
| T49 | exit_kind_unique | At most one exit kind at any time | W49 | accountAllowed: omit upper time bound (A-002) | PROVED |
| T50 | fold_references_authentic | Fold references genuinely held minted tokens | W50 | Step.fold: replace reference authentication with True (a06-fold-auth) | PROVED |
| T51 | account_references_authentic | Account references genuinely held minted tokens | W51 | Step.account: replace reference authentication with True (a06-account-auth) | PROVED |
| T52 | creation_references_source | Creation uses registry in the source state | W52 | Step.create: replace cage equality with True (a07-cage) | PROVED |
| T53 | fold_payments_concrete | Exact declared oracle fees and folder remainder | W53 | allocation: replace beneficiary by attacker; independently Request.fee: use != (a09-recipient, a09-fee-binding) | PROVED |
| T54 | account_payments_concrete | Exact declared oracle fees and owner remainder | W54 | allocation: replace beneficiary by attacker; independently Request.fee: use != (a09-recipient, a09-fee-binding) | PROVED |
| T55 | creation_funds_declared_fees | Creation cannot underfund declared fees | W55 | Request.fee: use !=; registry with one oracle and no other fee makes creation underfunded (A08 collateral) | PROVED |
| T56 | burn_removes_one | One burn decreases held multiplicity by exactly one | W56 | afterBurn: retain judgments unchanged (a16-no-burn) | PROVED |
| T57 | burn_keeps_history | Burn does not erase permanent mint record | W57 | afterBurn: erase name from issued (a13-forget) | PROVED |
| T58 | fold_requests_unique | No duplicate request in accepted fold | W58 | foldAccepted: replace requests.Nodup by True (a18-duplicate) | PROVED |
| T59 | account_accepts_any_verdicts | Every judgment mix is usable in window | W59 | hasAccount: require verdict=true (a12-refusal-account) | PROVED |
| T60 | equivocation_reachable | Both verdicts coexist in reachable holdings and record | W60 | Step.judge: require NonEquivocating issuance (a13-mint-enforce) | PROVED |

| T61 | tag_name_injective | Oracle-bound discovery name | W61 | tagName: replace oracle by a constant | PROVED |
| T62 | price_name_injective | Oracle-bound notice name | W62 | priceName: replace oracle by a constant | PROVED |
| T63 | different_roles_never_coincide | All distinct leading roles are disjoint | W63 | tokenName: replace role by tag | PROVED |
| T64 | names_have_leading_roles | Tag, approval, refusal and price encode their actual roles | W64 | judgmentName: encode both verdicts as approval | PROVED |
| T65 | reachable_registry_valid | Reachable registries have oracles or a rule and duplicate-free oracles | W65 | registryCreated: remove RegistryValid guard | PROVED |
| T66 | reachable_live_tags | Exact per-oracle holdings of every live request | W66 | wellFormed: allow tags=[] | PROVED |
| T67 | reachable_tags_unique | Exactly one occurrence per oracle, no duplicate tags | W67 | registryCreated: allow duplicate oracle entries | PROVED |
| T68 | discovery_iff | Live request tag query is sound and complete | W68 | discover: retain every output regardless of tag | PROVED |
| T69 | discovery_across_registries | One query spans all reachable registries | W69 | discover: query only the first output | PROVED |
| T70 | live_removal_burns_oracle_tags | The actual removing action burns every registry-oracle tag | W70 | withdrawAllowed: remove burned guard | PROVED |
| T71 | price_mint_inversion | Signed mint, bound name, exact issuance and output effect | W71 | priceMintAllowed: remove signature guard | PROVED |
| T72 | price_update_inversion | Held-input authentication, signature, token retention and exact update | W72 | priceUpdateAllowed: remove signature guard | PROVED |
| T73 | reachable_notice_names | All held notices bind their oracle and price role | W73 | priceUpdateAllowed: allow changing output.oracle | PROVED |
| T74 | price_mint_available | Any oracle can publish any advertised datum | W74 | priceMintAllowed: require output.datum.fee=0 | PROVED |
| T75 | price_update_available | Oracle can change a held notice to any datum | W75 | priceUpdateAllowed: require unchanged datum | PROVED |
| T76 | price_notice_noninterference | Price actions preserve registry, requests, judgments, seeds; no payments or exit | W76 | afterPriceMint: clear judgments | PROVED |
| T77 | notices_do_not_bind_protocol | Same protocol action and payments with arbitrary notice observations | W77 | Step.fold: require notices=[] | PROVED |
| T78 | notice_change_authorized | New notice values have a signed actual mint/update origin | W78 | afterJudgment: prepend a fresh price notice | PROVED |

| T79 | creation_rule_and_token | creation rule and token | W79 | drop ruleAdmits from createAllowed | PROVED |
| T80 | step_rule_immutable | step rule immutable | W80 | drop rule-preservation guard in foldAccepted | PROVED |
| T81 | history_rule_immutable | history rule immutable | W81 | afterJudgment clears cage.rule | PROVED |
| T82 | reachable_rule_admitted | reachable rule admitted | W82 | drop ruleAdmits at creation | PROVED |
| T83 | every_rule_allows_burn | Actual fold/account/withdraw/burn Steps available under lifecycle requirements for any rule, without re-admission | W83 and W83b, all four reached rule-bearing exit paths | Step.fold/account/withdraw add ruleAdmits on exit signatures; Step.burn adds a rule gate; stepValid re-runs rule (rule-at-fold) | OPEN |
| T84 | fold_rule_predicate_independent | fold rule predicate independent | W84 | stepValid evaluates the admission predicate again | PROVED |
| T85 | reachable_request_tokens | reachable request tokens | W85 | wellFormed allows no request token | PROVED |
| T86 | fold_requires_request_token | fold requires request token | W86 | stepValid omits wellFormed | PROVED |
| T87 | every_exit_burns_request_token | every exit burns request token | W87 | tokensOf omits requestTokens | PROVED |
| T88 | live_removal_burns_request_token | live removal burns request token | W88 | withdrawAllowed omits burned equality | PROVED |
| T89 | request_name_injective | request name injective | W89 | requestName replaces registry by a constant | PROVED |
| T90 | request_token_discovery | request token discovery | W90 | discoverRequests ignores token membership | PROVED |
| T91 | request_token_discovery_across_registries | request token discovery across registries | W91 | discoverRequests returns only the first output | PROVED |
| T92 | output_refs_monotone | output refs monotone | W92 | afterExit clears usedOutputs | PROVED |
| T93 | reachable_output_refs | reachable output refs | W93 | afterCreate omits usedOutputs insertion | PROVED |
| T94 | reachable_output_refs_unique | reachable output refs unique | W94 | Step.create drops fresh-output guard | PROVED |
| T95 | unguarded_registry_impossible | unguarded registry impossible | W95 | RegistryValid allows neither gate | PROVED |
| T96 | zero_oracle_needs_rule | zero oracle needs rule | W96 | RegistryValid allows neither gate | PROVED |
| T97 | zero_oracle_evidence_empty | zero oracle evidence empty | W97 | hasApproval requires a nonempty oracle list | PROVED |
| T98 | zero_oracle_creation_without_seed | zero oracle creation without seed | W98 | createAllowed always demands a spent seed | PROVED |
| T99 | zero_oracle_fold_without_approvals | zero oracle fold without approvals | W99 | stepValid requires at least one approval | PROVED |
| T100 | zero_oracle_account_without_verdicts | zero oracle account without verdicts | W100 | hasAccount requires at least one verdict | PROVED |
| T101 | present_condition_semantics | present condition semantics | W101 | Condition.holds present means absent | PROVED |
| T102 | foldRun_oracle_conditions | foldRun oracle conditions | W102 | stepValid checks oracle conditions against emptyTrie | PROVED |
| T103 | fold_all_conditions_hold | fold all conditions hold | W103 | stepValid omits oracle conditions | PROVED |
| T104 | approval_conditions_cannot_change | approval conditions cannot change | W104 | judgmentName erases approval conditions | PROVED |
| T105 | stale_approval_unusable | stale approval unusable | W105 | stepValid skips oracle conditions | PROVED |
| T106 | fold_evidence_binds_conditions | fold evidence binds conditions | W106 | hasApproval looks up the empty condition list regardless of selection | PROVED |
| T107 | expected_approval_lookup | expected approval lookup | W107 | expectedApprovals erases conditions | PROVED |
| T108 | folder_discovery_exact | folder discovery exact | W108 | folderFinds omits requester conditions | PROVED |
| T109 | folder_discovery_executable | folder discovery executable | W109 | folderFinds admits unheld request outputs | PROVED |
| T110 | empty_fold_allowed | empty fold allowed | W110 | foldAccepted requires a nonempty batch | PROVED |
| T111 | empty_fold_earns_nothing | empty fold earns nothing | W111 | foldAccepted permits a payment on an empty batch | PROVED |

| T112 | creation_rule_input_binding | Actual creation binds Rule.admits to the singleton output request and exact creating signatures | W112 ruledCreateStep, separate creator signature and demanded condition | rule-request and rule-signatures, exact surviving audit edits | OPEN |
| T113 | creation_request_policy | Actual creation uses rule policy and never release if rule exists, release otherwise; both mint and output provenance | W113 ruledCreateStep and step_create cover both branches | request-policy-release, exact surviving audit edit | OPEN |

## Semantic atoms

| Atom | Class | Production decision/effect | Covered rows | Adversarial case / limit |
|---|---|---|---|---|
| A01 | Authorization | oracle-or-rule gate and unique oracle set; immutable protocol; no owner/end/transfer constructor | T06, T12–T15 | remove creation guard or change metadata during judgment |
| A02 | Authorization | oracle membership AND authenticated signature | T09, T46 | outsider mints; member lacks signature |
| A03 | Authorization | every oracle approval token OR fold signature | T16, T32, T43 | missing one approval; one signer does not speak for all |
| A04 | Authorization | owner signature AND strict after-window time | T28–T29, T32–T33 | deadline+window equality rejects withdrawal |
| A05 | Evidence binding | structured role, registry, full request/seed, oracle, verdict | T07–T11, T34, T46 | copied seed, changed write, other registry/oracle/verdict; concrete encoding excluded |
| A06 | Evidence binding | Step.judge references live output and exact cage; Step.fold/account reference minted tokens | T36, T45–T46, T50–T51 | no mint from a consumed request; fake name is not authentic evidence |
| A07 | Evidence binding | request creation references existing cage, spends fresh seed when minting tags, one tag per oracle and singleton output | T07–T08, T39–T41, T52 | reused seed, extra mint, split tag outputs |
| A08 | Money | creation funds sum of distinct oracles' independent fees | T07, T21, T55 | underfunded escrow; duplicate oracle rejected at origin |
| A09 | Money | fold allocates exact fees and entire remainder to folder | T20–T21, T33, T53 | omit oracle, underpay, double-count same-address allocations |
| A10 | Money | complete account pays exact fees and owner remainder | T25, T27, T33, T54 | refusal changes payment; divert rest |
| A11 | Money | owner withdrawal takes entire input | T28–T29 | partial payout or wrong recipient |
| A12 | Refusal | verdict false satisfies account but not fold approval | T16, T25, T34, T59 | refusal cannot authorize fold; refusal must remain usable in account |
| A13 | Refusal | equivocation is permitted and fee-neutral | T27, T57, T60 | conflicting verdicts coexist; either account pays the same; permanent issued record survives burns |
| A14 | Terminality | only three request exits; all burn their tags | T19, T28, T30–T32, T45 | extra disappearance via unrelated transition |
| A15 | Terminality | consumed output removed; used output refs and spent seeds never clear | T37–T42 | request reappears in a later history |
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


| A29 | Rule authorization | optional immutable predicate evaluated on one request and creating signatures only | T79–T84, T112 | rule-request / rule-signatures substitute request or signatures; T112 directly binds both. T83 forbids exit re-admission; T84 forbids turn re-admission. Fresh audit pending |
| A30 | Token authenticity | exactly one role-led registry request token; selected rule/release policy; singleton creation output | T79, T85–T91, T113 | request-policy-release selects release despite present rule; T113 names both policy branches directly. Absent/wrong/extra token or split output remain covered; fresh audit pending |
| A31 | Output identity | fresh UTxO refs retained forever independently of optional spent seed | T42, T92–T94 | identical seedless datums conflate or resurrect outputs |
| A32 | Zero oracles | require rule; no approvals/verdicts/tags/seed-spend needed | T95–T100 | allow no gate or demand phantom evidence |
| A33 | Tree condition | present means some value, on any key | T101, T103 | absent accepted as present; evaluated at wrong turn |
| A34 | Oracle conditions | bound in approval name or signed fold body, all checked at actual turn | T09–T10, T102–T107 | detach/replace conditions; stale authentic approval reused |
| A35 | Folder discovery | request-token inventory exact, selected full approval names verified, conditions at supplied tree/time | T90–T91, T107–T109 | omit live work, include unheld output, skip guard |
| A36 | Empty fold | permitted without approval, no allocations/burns/tree change | T110–T111 | ban empty fold or mint a reward |

## Modelling choices and omissions

Rules are abstract compiled-policy predicates paired with hashes; code/hash correspondence
is assumed. Predicate equality is fixed by registry immutability. The rule receives no trie,
and fold validity depends on its policy hash and requester/oracle conditions, not evaluation
of its admission predicate. Rule burns are unconditional and exits do not request creation
signatures. Seedless request datums may coincide; UTxO refs distinguish every occurrence.

Structured names represent authenticated tokens with verified carried fields. There is no
independently mutable unverified judgment datum. Approval conditions are selected per
request/oracle in the signed fold body. Refusal names omit conditions. Discovery uses a
complete authentic finite inventory, obtainable in practice from a release-policy token
listing and judgment datums. A request alone cannot compute unknown oracle condition
bytes. expectedApprovals is deterministic after those lists are selected. folderFinds is
an inventory-relative relation, with exact soundness/completeness and a singleton Step
correspondence; arbitrary batch turns supply the prefix-result trie. It is not a search
algorithm or an indexer-completeness claim. D25 is closed only at this model layer.

RequestPolicy distinguishes the rule hash from the release-policy role; real deployed
shared spend/mint identities (D11), cross-policy ledger accounting, concrete CDDL/CBOR/
serialise_data/blake2b encoding and collision resistance remain external. Token-name burns
are the abstract registry-bound token inventory, not an actual multi-policy transaction.
UTxO identity, signatures covering fold bodies, references, ownership, globally spent-once
inputs, scalar time/validity-interval agreement and forestry proof soundness are boundaries.

Price notices remain nonbinding signed occurrence lists with no unique latest price or
canonical schedule claim. Fees use the first matching entry/default zero, fully escrowed.
T53–T55 spell this lookup independently of allocation helpers. No oracle response, fairness,
fee cap, economic honesty or progress guarantee. Arbitrary ordering and hold-up are accepted.
Executable surface/codecs/driver/replay (#109), migration, devnet/cost, validator conformance,
hosted CI, deployment and independent acceptance remain outside scope.
