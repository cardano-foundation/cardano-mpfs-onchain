# Candidate theorem and semantic-atom ledgers

Authority: decisions.md at c89669a, sha256
1cc759018a5d148068ad05a55938b69206b07f049546e333fd8ac1ecb4ed4e27,
plus the parent ruling A-001-model-boundaries.md in the lean-author-1 runtime.

This ledger is an author claim. Audit is deferred. Mutants below are proposed
single edits of production definitions, expected to falsify the named row;
no mutation campaign has been executed and no coverage/kill verdict is claimed.
Every W-number labels a compiled example in
lean/MpfsCage/RequestApprovalFold/Witnesses.lean. Concrete proof definitions
establish registry creation, live request creation, two independent judgments,
a fold, mixed approval/refusal settlement, owner withdrawal and dead-token burn
using only model constructors and core lemmas. They do not use admitted
candidate theorems. W24b supplies the full insert/unset/insert antecedent.

The semantic law is Step in Model.lean, with FoldRun for ordered application.
Public guard inversions are the creation, judgment, fold, account and withdrawal
rows; live_removal_is_legal_exit and new_judgment_is_authorized connect them to
the authoritative state machine. Steps which do not consume are distinguished
from request exits. Request identity includes its globally spent-once seed;
registry-local histories retain used seeds forever. Cross-registry uniqueness
uses the explicit ledger-wide SpentOnce premise, not a global chain simulator.

## Theorems

All names are in RequestApprovalFold. All 46 frozen statements are PROVED.
Phase 1 retained intentional sorry statements; phase 2 changed only proof
bodies in Lean. The clean-build and axiom receipts are in the creator handoff.
One proposed mutant description was corrected during author review: applying
a head twice still satisfies append composition; discarding the tail does not.

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
| T11 | token_roles_separated | Tag/judgment domain separation | W11 | tagName: emit a judgment-role name for a fixed request/oracle | PROVED |
| T12 | fold_preserves_registry | Immutable registry identity | W12 | foldAccepted: drop protocol-preservation guard | PROVED |
| T13 | step_preserves_registry | Immutable registry on every step | W13 | afterJudgment: replace cage.protocol with a constant | PROVED |
| T14 | history_preserves_registry | Immutable registry across composition | W14 | afterJudgment: replace cage.oracles with [] | PROVED |
| T15 | only_fold_changes_tree | Only fold changes cage | W15 | afterJudgment: replace cage.trie with emptyTrie | PROVED |
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
| T26 | account_anyone_anytime | Anyone may account at any time | W26 | accountAllowed: require now<deadline | PROVED |
| T27 | account_fee_neutral | Approval/refusal fee neutrality | W27 | accountAllowed: increase remainder by one when a refusal is shown | PROVED |
| T28 | withdraw_only_owner_after_window | Owner-only timed withdrawal | W28 | withdrawAllowed: omit owner-signature guard | PROVED |
| T29 | owner_can_withdraw_everything | Withdrawal availability after window | W29 | withdrawAllowed: require paid=0 | PROVED |
| T30 | request_spent_only_by_lifecycle | No other legal request exit | W30 | requestSpendAllowed accounted: accept True | PROVED |
| T31 | every_exit_burns_tag | Every exit burns tags | W31 | withdrawAllowed: omit burned guard | PROVED |
| T32 | early_exit_requires_all_judgments | Early exits show every judgment | W32 | withdrawAllowed: omit after-window guard | PROVED |
| T33 | early_exit_pays_every_oracle | Early exits pay every oracle | W33 | accountAllowed: permit empty oracle payments | PROVED |
| T34 | owner_cannot_hide_approval | An approval cannot be hidden | W34 | hasAccount: require evidence from only the first oracle | PROVED |
| T35 | dead_judgment_can_burn | Dead judgments always burn | W35 | Step.burn: add a live-request premise | PROVED |
| T36 | judgments_do_not_consume | Judgment minting consumes no request | W36 | afterJudgment: replace live with [] | PROVED |
| T37 | exits_remove_consumed | Exit terminality | W37 | afterExit: preserve live unchanged | PROVED |
| T38 | fold_removes_consumed | Fold terminality | W38 | afterFold: preserve live unchanged | PROVED |
| T39 | used_seeds_monotone | Spent-once composition | W39 | afterExit: clear usedSeeds | PROVED |
| T40 | reachable_requests_have_spent_seeds | Live requests have spent seeds | W40 | afterCreate: preserve usedSeeds unchanged | PROVED |
| T41 | spent_seed_cannot_create_again | Seed cannot recur | W41 | createAllowed: omit seed-spent guard | PROVED |
| T42 | request_never_reappears | Consumed requests never reappear | W42 | afterJudgment: prepend requestRef to live | PROVED |
| T43 | one_oracle_signature_suffices | Single-oracle old-design signature shortcut | W43 | hasApproval: remove signature alternative | PROVED |
| T44 | old_operations_correspond | Old Insert/Delete/Update correspondence | W44 | OldOperation.write delete: use set instead of unset | PROVED |
| T45 | live_removal_is_legal_exit | Authoritative machine exit inversion | W45 | afterBurn: clear live | PROVED |
| T46 | new_judgment_is_authorized | Authoritative machine judgment provenance | W46 | afterBurn: prepend a tag name to issued | PROVED |

## Semantic atoms

| Class | Production decision/effect | Covered rows | Adversarial case / limit |
|---|---|---|---|
| Authorization | nonempty unique oracle set; immutable protocol; no owner/end/transfer constructor | T06, T12–T15 | remove creation guard or change metadata during judgment |
| Authorization | oracle membership AND authenticated signature | T09, T46 | outsider mints; member lacks signature |
| Authorization | every oracle approval token OR fold signature | T16, T32, T43 | missing one approval; one signer does not speak for all |
| Authorization | owner signature AND strict after-window time | T28–T29, T32–T33 | deadline+window equality rejects withdrawal |
| Evidence binding | structured role, registry, full request/seed, oracle, verdict | T07–T11, T34, T46 | copied seed, changed write, other registry/oracle/verdict; concrete encoding excluded |
| Evidence binding | Step.judge references live output and exact cage; Step.fold/account reference minted tokens | T36, T45–T46 | no mint from a consumed request; fake name is not authentic evidence |
| Evidence binding | request creation references existing cage, spends fresh seed, singleton tag and singleton output | T07–T08, T39–T41 | reused seed, extra mint, split tag outputs |
| Money | creation funds sum of distinct oracles' independent fees | T07, T21 | underfunded escrow; duplicate oracle rejected at origin |
| Money | fold allocates exact fees and entire remainder to folder | T20–T21, T33 | omit oracle, underpay, double-count same-address allocations |
| Money | complete account pays exact fees and owner remainder | T25, T27, T33 | refusal changes payment; divert rest |
| Money | owner withdrawal takes entire input | T28–T29 | partial payout or wrong recipient |
| Refusal | verdict false satisfies account but not fold approval | T16, T25, T34 | substitute refusal in fold; hide approval via equivocation |
| Refusal | non-equivocation is an explicit historical premise, never enforced by mint | T34 | conflicting verdicts can be minted; permanent issued record retains them after burns |
| Terminality | only three request exits; all burn their tags | T19, T28, T30–T32, T45 | extra disappearance via unrelated transition |
| Terminality | consumed output removed; spent seed never clears | T37–T42 | request reappears in a later history |
| Terminality | dead judgments burn without cage/request cooperation | T35–T36 | expired request cannot trap a token; holder authentication external |
| Composition | fold guards check each intermediate tree; all writes applied once in list order | T01–T05, T17–T18, T24 | skip/reorder/change write; conflicting absent inserts without unset |
| Composition | same request cannot occur twice within a fold | foldAccepted requests.Nodup; W24b uses distinct seeds | duplicate input is rejected by guard; no independent theorem row claims uniqueness of all live seeds |
| Composition | arbitrary submitter; signature shortcut distinct from submitter identity | T23, T26, T43 | changing submitter must not remove oracle evidence |
| Composition | old operation translation retains own-key precondition and tree effect | T44 | no claim that shipped validators implement this new lifecycle |

## Modelling choices and omissions

A-001 authorizes nonempty duplicate-free oracle lists, independent nonnegative
fees, full funding at creation, strict time boundaries, fresh state-token
identity and explicit ledger abstractions. One registry-named tag and arbitrary
folder order are the selected "Not decided" choices. Names are structured
collision-free values. Protocol hashes/evidence are opaque and unexamined.

The executable oracle surface, JSON codecs, generic driver and replay corpus
are omitted by the brief. No devnet/cost, concrete serialization, global chain,
implementation conformance, hosted CI, independent audit or accepted-law claim.
