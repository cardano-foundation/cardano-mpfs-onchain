# Registry model with fee balances: theorem and atom ledgers (#127)

Status: **142 PROVED, 0 OPEN, 0 REFUTED**, at commit 85f2b3e.
The statements were accepted at c569165 after three independent statement
audits; the third returned READY-TO-PROVE with all 142 rows and 155 of 157
semantic atoms killed by single-atom mutants (two accepted equivalent guard
removals). An independent proof audit of 85f2b3e returned PASS: all 142
elaborated types identical to c569165, Model.lean and Witnesses.lean
byte-identical, no escape hatch, and `#print axioms` on all 142 theorems and
every helper lists only `propext`, `Classical.choice` and `Quot.sound`.

Authority: specs/request-approval-fold/decisions.md (27 October),
specs/oracle-identity/decisions.md and unchanged imported OracleIdentity.Model.
A ruling of 28 October on the money boundaries fixes the interpretations
below.

## Account and time boundaries

- Registry value is the sum backing fee balances; its permanent ledger reserve
  is outside this account. One balance per distinct key, including a key shared
  by multiple named oracle identities. Keys outside the registry have zero.
- Conservation is initial registry value + request escrows + claim escrows =
  final registry value + request remainders + claim payouts + claim tips. Claim
  escrow equals its tip; creation-output minimum funding is external. The
  request and balance component equations are separately stated. The actual
  payment-list equality and total are independently pinned by T119.
- Complete-account verdict neutrality fixes totals and owner remainder. Full
  balance equality additionally fixes signing records. Different authentic
  signer records may select different payees; the witnesses demonstrate this.
- Closed nonempty intervals must fit every item. Writes use upper < deadline;
  accounts use deadline <= lower and upper <= deadline + window; request
  withdrawal uses deadline + window < lower. Claims use upper < deadline;
  signed claim withdrawal uses deadline <= lower. Thus no expiry gap.
- Only fold changes the registry. Claim creation authenticates the key and
  binds the entire immutable live ClaimOutput. Claim consumption and payment
  are bound to that output through Step.fold's authentic input inventory.

## Freeze identity

- Model.lean SHA-256: `d2619890886c8aa19a1cce594bf8467548a9b83a1ae18b287c1fda9494789ade`.
- Full qualified theorem names and source types follow below, with individual
  type digests. These types elaborate in the local build. Proof bytes are
  deliberately excluded from the freeze. The parent accepted the independent
  statement audit in NOTE-003. Current versus c569165 elaborated Expr.hash
  and pp.all text match for all 142 theorem types.
- Witnesses.lean imports Model only. Each W row proves concrete reachable
  premises without importing Statements. All named witness constants, including
  helpers, are checked by #print axioms; only standard axioms are admitted.
- Local full build and axiom/type receipts reside in the creator runtime's
  evidence/ directory. See the completion receipt for exact command, exit and
  artifact hashes. Current proof receipts are in evidence/proofs/: final-build-2.log,
  axioms.log, accepted-types.tsv, current-types.tsv, outcomes.json and verification.json.
  These are local proof results, not hosted CI or implementation conformance.

## Theorem ledger

Each mutant below is a named single semantic edit. The third independent
statement audit found all 142 rows sensitive, with 155 semantic atoms killed
and two accepted equivalent guard removals. The proofs did not change
any statement, so those kills still apply. Earlier targeted creator mutation
receipts are preserved below.
A witness may supply a stronger trace than the raw premise (for example an
actual Step plus foldAccepted); its concrete fields instantiate the row.
W60 constructs the existential equivocation conclusion independently of its
theorem. W136 reaches every Step constructor.

| Row | Theorem | Obligation | Reachable witness | Named mutant | Status |
|---|---|---|---|---|---|
| T01 | applyAll_append | Fold composition | Witnesses.W01 | M-skip-tail | PROVED |
| T02 | foldRun_step_valid | Fold guards | Witnesses.W02 | M-skip-item-guard | PROVED |
| T03 | foldRun_result | Fold ordered effects | Witnesses.W03 | M-skip-run-effect | PROVED |
| T04 | foldRun_conditions | Conditions at intermediate tree | Witnesses.W04 | M-skip-item-guard | PROVED |
| T05 | applyAll_keeps_present | Present-key preservation | Witnesses.W05 | M-set-deletes | PROVED |
| T06 | registry_creation | Registry creation | Witnesses.W06 | M-registry-guard | PROVED |
| T07 | create_tags_existing_cage | Request creation and tag minting | Witnesses.W07 | M-seed-spend | PROVED |
| T08 | requests_unique_in_history | Historical request uniqueness | Witnesses.W08 | M-seed-spend | PROVED |
| T09 | judgment_authorized_and_bound | Judgment authorization, time, binding | Witnesses.W09 | M-oracle-membership | PROVED |
| T10 | judgment_not_replayable | Judgment replay protection | Witnesses.W10 | M-name-seed | PROVED |
| T11 | token_roles_separated | Tag/judgment domain separation | Witnesses.W11 | M-judgment-is-tag | PROVED |
| T12 | fold_preserves_registry | Immutable registry identity | Witnesses.W12 | M-fold-protocol | PROVED |
| T13 | step_preserves_registry | Immutable registry on every step | Witnesses.W13 | M-judge-protocol | PROVED |
| T14 | history_preserves_registry | Immutable registry across composition | Witnesses.W14 | M-judge-protocol | PROVED |
| T15 | only_fold_changes_tree | A trie change identifies an accepted fold, its source and exact successor | Witnesses.W15 | M-judge-trie | PROVED |
| T16 | fold_only_approved_before_deadline | All oracles approve before deadline | Witnesses.W16 | M-skip-item-guard | PROVED |
| T17 | fold_conditions_hold_when_applied | Intermediate-tree conditions | Witnesses.W17 | M-skip-item-guard | PROVED |
| T18 | fold_root_is_folded_writes | Exact writes in exact order | Witnesses.W18 | M-skip-write | PROVED |
| T19 | fold_burns_tags | Burn tags on fold | Witnesses.W19 | M-fold-burns | PROVED |
| T20 | fold_pays_and_keeps_rest | All fees credited and folder remainder | Witnesses.W20 | M-credit-key | PROVED |
| T21 | allocation_conserves_value | Money conservation | Witnesses.W21 | M-remainder | PROVED |
| T22 | blind_write_folds_on_any_tree | Blind write yields a FoldRun and its result on every trie | Witnesses.W22 | M-blind-guard | PROVED |
| T23 | fold_permissionless | Permissionless submission | Witnesses.W23 | M-submitter | PROVED |
| T24 | absent_inserts_exclusive | Absent-insert exclusivity | Witnesses.W24 | M-request-condition | PROVED |
| T25 | account_complete_and_pays | Complete account, fees, owner rest | Witnesses.W25 | M-account-evidence | PROVED |
| T26 | account_anyone_in_window | Anyone may account within the closed account window | Witnesses.W26 | M-account-window | PROVED |
| T27 | account_fee_neutral | Approval/refusal fee neutrality | Witnesses.W27 | M-verdict-dependent-credit | PROVED |
| T28 | withdraw_only_owner_after_window | Owner-only timed withdrawal | Witnesses.W28 | M-withdraw-signature | PROVED |
| T29 | owner_can_withdraw_everything | Withdrawal availability after window | Witnesses.W29 | M-withdraw-zero | PROVED |
| T30 | request_spent_only_by_lifecycle | No other legal request exit | Witnesses.W30 | M-spend-any | PROVED |
| T31 | every_exit_burns_tag | Every exit burns tags | Witnesses.W31 | M-withdraw-burns | PROVED |
| T32 | early_exit_requires_all_judgments | Early exits show every judgment | Witnesses.W32 | M-withdraw-time | PROVED |
| T33 | early_exit_pays_every_oracle | Early exits pay every oracle | Witnesses.W33 | M-credit-key | PROVED |
| T34 | before_deadline_only_approvals | Before the deadline only approvals or oracle signatures authorize an exit | Witnesses.W34 | M-write-approval | PROVED |
| T35 | dead_judgment_can_burn | Every held dead judgment burns, for every verdict and condition list, preserving cage/live requests | Witnesses.W35 | M-burn-live | PROVED |
| T36 | judgments_do_not_consume | Judgment minting consumes no request | Witnesses.W36 | M-judge-consumes | PROVED |
| T37 | exits_remove_consumed | Exit terminality | Witnesses.W37 | M-exit-retains | PROVED |
| T38 | fold_removes_consumed | Fold terminality | Witnesses.W38 | M-fold-retains | PROVED |
| T39 | used_seeds_monotone | Spent-once composition | Witnesses.W39 | M-exit-seeds | PROVED |
| T40 | reachable_requests_have_spent_seeds | Live oracle-bearing requests have spent seeds | Witnesses.W40 | M-create-seeds | PROVED |
| T41 | spent_seed_cannot_create_again | Seed cannot recur | Witnesses.W41 | M-seed-spend | PROVED |
| T42 | request_never_reappears | Consumed requests never reappear | Witnesses.W42 | M-fresh-output | PROVED |
| T43 | one_oracle_signature_suffices | Single-oracle old-design signature shortcut | Witnesses.W43 | M-no-inline | PROVED |
| T44 | old_operations_correspond | Old Insert/Delete/Update correspondence | Witnesses.W44 | M-old-delete | PROVED |
| T45 | live_removal_is_legal_exit | Consumption identifies the allowed spend, source registry, authentic inputs and successor | Witnesses.W45 | M-burn-consumes | PROVED |
| T46 | new_judgment_is_authorized | Authoritative machine judgment provenance | Witnesses.W46 | M-burn-issues | PROVED |
| T47 | exit_time_window | Every actual write, account or owner withdrawal fits its window | Witnesses.W47 | M-account-upper | PROVED |
| T48 | exit_windows_cover | The three scalar windows cover all time | Witnesses.W48 | M-window-gap | PROVED |
| T49 | exit_kind_unique | Two allowed spends at the same interval consume a request by the same exit kind | Witnesses.W49 | M-write-guard-overlap | PROVED |
| T50 | fold_references_authentic | Fold references genuinely held minted tokens | Witnesses.W50 | M-fake-references | PROVED |
| T51 | account_references_authentic | Account references genuinely held minted tokens | Witnesses.W51 | M-account-evidence | PROVED |
| T52 | creation_references_source | Creation uses registry in the source state | Witnesses.W52 | M-create-source | PROVED |
| T53 | fold_payments_concrete | Exact declared oracle fees and folder remainder | Witnesses.W53 | M-credit-key | PROVED |
| T54 | account_payments_concrete | Exact declared oracle fees and owner remainder | Witnesses.W54 | M-credit-key | PROVED |
| T55 | creation_funds_declared_fees | Creation cannot underfund declared fees | Witnesses.W55 | M-creation-minimum | PROVED |
| T56 | burn_removes_one | One burn decreases held multiplicity by exactly one | Witnesses.W56 | M-burn-retains | PROVED |
| T57 | burn_keeps_history | Burn does not erase permanent mint record | Witnesses.W57 | M-burn-forgets | PROVED |
| T58 | fold_requests_unique | No duplicate request in accepted fold | Witnesses.W58 | M-duplicate-input | PROVED |
| T59 | account_accepts_any_verdicts | Any authorized verdict selection in-window gives an actual account Step | Witnesses.W59 | M-account-approvals-only | PROVED |
| T60 | equivocation_reachable | A live request of the reachable registry has both verdicts of a registry oracle with one signing record in holdings and issuance | Witnesses.W60 | M-no-equivocation | PROVED |
| T61 | tag_name_injective | Oracle-bound discovery name | Witnesses.W61 | M-tag-oracle | PROVED |
| T62 | price_name_injective | Oracle-bound notice name | Witnesses.W62 | M-price-oracle | PROVED |
| T63 | different_roles_never_coincide | All distinct leading roles are disjoint | Witnesses.W63 | M-role | PROVED |
| T64 | names_have_leading_roles | Tag, approval, refusal and price encode their actual roles | Witnesses.W64 | M-role | PROVED |
| T65 | reachable_registry_valid | Reachable registries have oracles or a rule and duplicate-free oracles | Witnesses.W65 | M-registry-guard | PROVED |
| T66 | reachable_live_tags | Exact per-oracle holdings of every live request | Witnesses.W66 | M-missing-tags | PROVED |
| T67 | reachable_tags_unique | Exactly one occurrence per oracle, no duplicate tags | Witnesses.W67 | M-registry-guard | PROVED |
| T68 | discovery_iff | Live request tag query is sound and complete | Witnesses.W68 | M-discovery-all | PROVED |
| T69 | discovery_across_registries | One query spans all reachable registries | Witnesses.W69 | M-discovery-all | PROVED |
| T70 | live_removal_burns_oracle_tags | The actual removing action burns every registry-oracle tag | Witnesses.W70 | M-withdraw-burns | PROVED |
| T71 | price_mint_inversion | Signed mint, bound name, exact issuance and output effect | Witnesses.W71 | M-price-mint-auth | PROVED |
| T72 | price_update_inversion | Held-input authentication, signature, token retention and exact update | Witnesses.W72 | M-price-update-auth | PROVED |
| T73 | reachable_notice_names | All held notices bind their oracle and price role | Witnesses.W73 | M-price-transfer | PROVED |
| T74 | price_mint_available | Any oracle can publish any advertised datum | Witnesses.W74 | M-price-free-only | PROVED |
| T75 | price_update_available | Oracle can change a held notice to any datum | Witnesses.W75 | M-price-unchanged | PROVED |
| T76 | price_notice_noninterference | Price actions preserve registry, requests, judgments, seeds; no credits / outputs or exit | Witnesses.W76 | M-price-clears-judgments | PROVED |
| T77 | notices_do_not_bind_protocol | Same protocol action and credits / outputs with arbitrary notice observations | Witnesses.W77 | M-binding-price | PROVED |
| T78 | notice_change_authorized | New notice values have a signed actual mint/update origin | Witnesses.W78 | M-judge-notice | PROVED |
| T79 | creation_rule_and_token | creation rule and token | Witnesses.W79 | M-creation-rule | PROVED |
| T80 | step_rule_immutable | step rule immutable | Witnesses.W80 | M-fold-rule | PROVED |
| T81 | history_rule_immutable | history rule immutable | Witnesses.W81 | M-judge-rule | PROVED |
| T82 | reachable_rule_admitted | reachable rule admitted | Witnesses.W82 | M-creation-rule | PROVED |
| T83 | every_rule_allows_burn | Actual fold/account/withdraw/burn Steps available under lifecycle requirements for any rule, without re-admission | Witnesses.W83 | M-exit-readmits | PROVED |
| T84 | fold_rule_predicate_independent | fold rule predicate independent | Witnesses.W84 | M-rule-at-turn | PROVED |
| T85 | reachable_request_tokens | reachable request tokens | Witnesses.W85 | M-request-token | PROVED |
| T86 | fold_requires_request_token | fold requires request token | Witnesses.W86 | M-request-token | PROVED |
| T87 | every_exit_burns_request_token | every exit burns request token | Witnesses.W87 | M-withdraw-burns | PROVED |
| T88 | live_removal_burns_request_token | live removal burns request token | Witnesses.W88 | M-withdraw-burns | PROVED |
| T89 | request_name_injective | request name injective | Witnesses.W89 | M-request-name | PROVED |
| T90 | request_token_discovery | request token discovery | Witnesses.W90 | M-request-query | PROVED |
| T91 | request_token_discovery_across_registries | request token discovery across registries | Witnesses.W91 | M-request-query | PROVED |
| T92 | output_refs_monotone | output refs monotone | Witnesses.W92 | M-forget-refs | PROVED |
| T93 | reachable_output_refs | reachable output refs | Witnesses.W93 | M-create-refs | PROVED |
| T94 | reachable_output_refs_unique | reachable output refs unique | Witnesses.W94 | M-fresh-output | PROVED |
| T95 | unguarded_registry_impossible | unguarded registry impossible | Witnesses.W95 | M-registry-guard | PROVED |
| T96 | zero_oracle_needs_rule | zero oracle needs rule | Witnesses.W96 | M-registry-guard | PROVED |
| T97 | zero_oracle_evidence_empty | zero oracle evidence empty | Witnesses.W97 | M-zero-evidence | PROVED |
| T98 | zero_oracle_creation_without_seed | zero oracle creation without seed | Witnesses.W98 | M-zero-seed | PROVED |
| T99 | zero_oracle_fold_without_approvals | Zero-oracle write yields a FoldRun and its result | Witnesses.W99 | M-zero-evidence | PROVED |
| T100 | zero_oracle_account_without_verdicts | zero oracle account without verdicts | Witnesses.W100 | M-zero-account | PROVED |
| T101 | present_condition_semantics | present condition semantics | Witnesses.W101 | M-present-absent | PROVED |
| T102 | foldRun_oracle_conditions | foldRun oracle conditions | Witnesses.W102 | M-skip-item-guard | PROVED |
| T103 | fold_all_conditions_hold | fold all conditions hold | Witnesses.W103 | M-skip-item-guard | PROVED |
| T104 | approval_conditions_cannot_change | Approval-name equality iff records and conditions agree | Witnesses.W104 | M-name-conditions | PROVED |
| T105 | stale_approval_unusable | stale approval unusable | Witnesses.W105 | M-skip-item-guard | PROVED |
| T106 | fold_evidence_binds_conditions | fold evidence binds conditions | Witnesses.W106 | M-write-approval | PROVED |
| T107 | expected_approval_lookup | Exact iff between no-inline approval and authorized approval evidence plus computed-name membership | Witnesses.W107 | M-lookup-empty | PROVED |
| T108 | folder_discovery_exact | folder discovery exact | Witnesses.W108 | M-folder-no-conditions | PROVED |
| T109 | folder_discovery_executable | folder discovery executable | Witnesses.W109 | M-folder-no-conditions | PROVED |
| T110 | empty_fold_allowed | An empty fold returns the original State itself | Witnesses.W110 | M-empty-forbidden | PROVED |
| T111 | empty_fold_earns_nothing | empty fold earns nothing | Witnesses.W111 | M-empty-paid | PROVED |
| T112 | creation_rule_input_binding | Actual creation binds Rule.admits to the singleton output request and exact creating signatures | Witnesses.W112 | M-rule-request | PROVED |
| T113 | creation_request_policy | Actual creation uses rule policy and never release if rule exists, release otherwise; both mint and output provenance | Witnesses.W113 | M-release-policy | PROVED |
| T114 | only_fold_changes_registry | only fold changes registry | Witnesses.W114 | M-creation-state | PROVED |
| T115 | reachable_balances_backed | reachable balances backed | Witnesses.W115 | M-credit-unbacked | PROVED |
| T116 | fold_value_conservation | fold value conservation | Witnesses.W116 | M-claim-value | PROVED |
| T117 | fold_request_conservation | fold request conservation | Witnesses.W117 | M-remainder | PROVED |
| T118 | fold_balance_conservation | fold balance conservation | Witnesses.W118 | M-credit-unbacked | PROVED |
| T119 | fold_payments_exact | fold credits / outputs exact | Witnesses.W119 | M-arbitrary-payments | PROVED |
| T120 | group_credits_only_recorded_signers | group credits only recorded signers | Witnesses.W120 | M-unsigned-fees | PROVED |
| T121 | group_credits_exact_split | group credits exact split | Witnesses.W121 | M-extra-fee | PROVED |
| T122 | judgment_record_cannot_change | judgment record cannot change | Witnesses.W122 | M-name-record | PROVED |
| T123 | claim_creation_inversion | claim creation inversion | Witnesses.W123 | M-claim-create-signature | PROVED |
| T124 | reachable_claim_authorization | Every live claim matches a key-signed creation event on the given exact history | Witnesses.W124 | M-claim-create-signature | PROVED |
| T125 | claim_payout_fixed | claim payout fixed | Witnesses.W125 | M-claim-redirect | PROVED |
| T126 | claim_payout_in_actual_outputs | claim payout in actual outputs | Witnesses.W126 | M-arbitrary-payments | PROVED |
| T127 | claim_below_minimum_refused | claim below minimum refused | Witnesses.W127 | M-claim-minimum | PROVED |
| T128 | claim_turn_balance | claim turn balance | Witnesses.W128 | M-claim-prior-balance | PROVED |
| T129 | claim_consumed_and_burned | claim consumed and burned | Witnesses.W129 | M-claim-retained | PROVED |
| T130 | claim_withdrawal_inversion | claim withdrawal inversion | Witnesses.W130 | M-claim-withdraw-signature | PROVED |
| T131 | claim_withdrawal_available | claim withdrawal available | Witnesses.W131 | M-claim-withdraw-strict | PROVED |
| T132 | claim_windows_disjoint | claim windows disjoint | Witnesses.W132 | M-claim-overlap | PROVED |
| T133 | claim_discovery_exact | claim discovery exact | Witnesses.W133 | M-claim-query | PROVED |
| T134 | request_withdrawal_preserves_registry | request withdrawal preserves registry | Witnesses.W134 | M-withdraw-state | PROVED |
| T135 | fold_interval_fits_every_item | fold interval fits every item | Witnesses.W135 | M-skip-item-guard | PROVED |
| T136 | step_inversion | step inversion | Witnesses.W136 | M-claim-source | PROVED |
| T137 | foldRun_inversion | foldRun inversion | Witnesses.W137 | M-skip-run-effect | PROVED |
| T138 | claim_item_inversion | claim item inversion | Witnesses.W138 | M-claim-item-cage | PROVED |
| T139 | claim_windows_cover | Point intervals admit claim fold or withdrawal at every time under the non-time guards | Witnesses.W139 | M-claim-withdraw-gap | PROVED |
| T140 | fold_group_credits_only_recorded_signers | All fold fee records are authenticated; a key absent from all selected records cannot gain balance | Witnesses.W140 | M-fold-unsigned-credit | PROVED |
| T141 | trace_reachability | Indexed event histories and Reachable describe exactly the same states | Witnesses.W141 | M-trace-missing-step | PROVED |
| T142 | exit_windows_disjoint | The exitAt window classes never overlap | Witnesses.W142 | M-window-overlap | PROVED |

## Mutation definitions

| Mutant | Production site | One semantic change |
|---|---|---|
| M-skip-tail | applyAll.cons | Return the first write result and discard the remaining writes |
| M-skip-item-guard | FoldRun.cons | Remove itemAllowed premise |
| M-skip-write | itemResult.write | Keep the incoming trie instead of applying the write |
| M-skip-run-effect | FoldRun.cons | Recurse on the incoming state instead of itemResult |
| M-set-deletes | Write.apply.set | Store none instead of some value |
| M-registry-guard | registryCreated | Remove RegistryValid |
| M-seed-spend | createAllowed | Remove conditional seed-spent premise |
| M-oracle-membership | judgmentAllowed | Remove oracle membership premise |
| M-name-seed | judgmentName | Replace the request seed in the bound request by a constant |
| M-judgment-is-tag | judgmentName | Dispatch to tagName o instead of the judgment constructor |
| M-fold-protocol | itemResult.write | Replace the output protocol by an arbitrary fixed string |
| M-judge-protocol | afterJudgment | Replace cage.protocol by an arbitrary fixed string |
| M-judge-trie | afterJudgment | Replace cage.trie by a fixed populated trie |
| M-fold-burns | foldAccepted | Replace the exact burned-token equality by True |
| M-credit-key | credit | Credit all fees to a fixed registry key rather than each paidTo key |
| M-remainder | remainder | Return the whole escrow instead of subtracting fees |
| M-blind-guard | stepValid | Require a nonempty requester condition list |
| M-submitter | foldAccepted | Require submitter = folder |
| M-request-condition | stepValid | Remove requester condition checks |
| M-account-evidence | accountAllowed | Remove hasAccount premise |
| M-account-window | accountAllowed | Replace deadline <= lower with upper < deadline |
| M-verdict-dependent-credit | itemResult.account | Add one extra balance unit when the selected evidence contains a refusal |
| M-withdraw-signature | withdrawAllowed | Remove owner signature premise |
| M-withdraw-zero | withdrawAllowed | Require paid = 0 instead of full input value |
| M-spend-any | requestSpendAllowed.folded | Return True instead of fold validity and input membership |
| M-withdraw-burns | withdrawAllowed | Remove burned = tokensOf input |
| M-withdraw-time | withdrawAllowed | Remove strict after-window premise |
| M-write-approval | stepValid | Remove hasApproval premise |
| M-burn-live | Step.burn | Require a live request with the judgment request datum |
| M-judge-consumes | afterJudgment | Clear live requests |
| M-exit-retains | afterExit | Keep the consumed request live |
| M-fold-retains | afterFold | Keep consumed requests live |
| M-exit-seeds | afterExit | Clear usedSeeds |
| M-create-seeds | afterCreate | Do not add newly spent seeds |
| M-fresh-output | Step.create | Remove fresh output-reference premise |
| M-no-inline | hasApproval | Remove inline-signature alternative |
| M-old-delete | OldOperation.write.delete | Return a set instead of an unset |
| M-burn-consumes | afterBurn | Clear live requests |
| M-burn-issues | afterBurn | Prepend a fabricated name to issued |
| M-account-upper | accountAllowed | Remove interval upper bound |
| M-window-gap | exitAt.write | Require upper + 1 < deadline |
| M-write-guard-overlap | stepValid | Allow upper <= deadline |
| M-window-overlap | exitAt.write | Allow upper <= deadline instead of upper < deadline |
| M-fake-references | Step.fold | Remove authentic judgment-reference premise |
| M-create-source | Step.create | Remove source cage equality |
| M-creation-minimum | wellFormed | Require only totalFees <= value, omitting minimum |
| M-burn-retains | afterBurn | Keep judgments unchanged |
| M-burn-forgets | afterBurn | Erase the burned name from issued |
| M-duplicate-input | foldAccepted | Remove the reference Nodup premise |
| M-account-approvals-only | hasAccount | Add approve = true for each selected oracle |
| M-no-equivocation | Step.judge | Forbid any already-issued opposite verdict for this registry/request/oracle |
| M-tag-oracle | tagName | Replace oracle identity by a constant |
| M-price-oracle | priceName | Replace oracle identity by a constant |
| M-role | tokenName | Replace supplied role by tag |
| M-missing-tags | wellFormed | Allow empty tags instead of all oracle tags |
| M-discovery-all | discover | Return every input without filtering tags |
| M-price-mint-auth | priceMintAllowed | Remove imported authorize success premise |
| M-price-update-auth | priceUpdateAllowed | Remove imported authorize success premise |
| M-price-transfer | priceUpdateAllowed | Remove output.oracle = input.oracle |
| M-price-free-only | priceMintAllowed | Add output.datum.fee = 0 |
| M-price-unchanged | priceUpdateAllowed | Require unchanged datum |
| M-price-clears-judgments | afterPriceMint | Clear judgment holdings |
| M-binding-price | Step.fold | Require the notice inventory to be empty |
| M-judge-notice | afterJudgment | Prepend a fabricated price notice |
| M-creation-rule | createAllowed | Remove ruleAdmits |
| M-fold-rule | itemResult.write | Clear registry rule |
| M-judge-rule | afterJudgment | Clear registry rule |
| M-exit-readmits | Step.fold | Add ruleAdmits on each request and fold signatures |
| M-rule-at-turn | itemAllowed.write | Add ruleAdmits on the item and fold signatures |
| M-request-token | wellFormed | Allow an empty request-token list |
| M-request-name | requestName | Replace the registry by a constant |
| M-request-query | discoverRequests | Ignore token membership |
| M-forget-refs | afterExit | Clear usedOutputs |
| M-create-refs | afterCreate | Do not record the created output reference |
| M-zero-evidence | hasApproval | Require a nonempty oracle list |
| M-zero-seed | createAllowed | Always require the seed to be spent |
| M-zero-account | hasAccount | Require a nonempty oracle list |
| M-present-absent | Condition.holds.present | Require absence instead of existence |
| M-name-conditions | judgmentName | Replace approval conditions by [] |
| M-lookup-empty | expectedApprovals | Return [] |
| M-folder-no-conditions | folderFinds | Omit stepValid |
| M-empty-forbidden | foldAccepted | Require a nonempty item list |
| M-empty-paid | foldAccepted | Allow an arbitrary payment on the empty batch |
| M-rule-request | createAllowed | Call ruleAdmits on a request with replaced conditions |
| M-release-policy | requestPolicy | Always select release even with a rule |
| M-creation-state | afterCreate | Increment cage.value |
| M-credit-unbacked | credit | Increase value by fee total plus one |
| M-claim-value | itemResult.claim | Do not subtract the claimed balance from value |
| M-arbitrary-payments | foldAccepted | Remove exact payments equality |
| M-unsigned-fees | oracleCredits | Replay splitFee using every description key instead of selected signers |
| M-extra-fee | oracleCredits | Split fee + 1 |
| M-name-record | judgmentName | Replace the signing record by a constant |
| M-claim-create-signature | claimCreateAllowed | Remove key signature premise |
| M-claim-redirect | itemPayments.claim | Replace payout destination by folder |
| M-claim-minimum | claimAllowed | Remove minimum-balance premise |
| M-claim-prior-balance | itemPayments.claim | Pay zero instead of the balance at the turn |
| M-claim-retained | afterFold | Keep consumed claims live |
| M-claim-withdraw-signature | claimWithdrawAllowed | Remove creator signature premise |
| M-claim-withdraw-strict | claimWithdrawAllowed | Use strict deadline < lower |
| M-claim-overlap | claimAllowed | Allow upper <= deadline |
| M-claim-query | discoverClaims | Ignore claim-token membership |
| M-withdraw-state | afterExit | Clear registry balances |
| M-claim-source | Step.claimCreate | Remove source cage equality |
| M-claim-item-cage | claimAllowed | Remove claim registry equality |
| M-claim-history-datum | afterClaimCreate | Store a claim with an altered datum instead of the signed output |
| M-claim-withdraw-gap | claimWithdrawAllowed | Require strict deadline < lower instead of deadline <= lower |
| M-fold-unsigned-credit | credit | Credit a key absent from all selected signing records |
| M-trace-missing-step | Trace.cons | Remove the Step premise from the recorded event |

## Semantic-atom ledger

Every row names one guard, binding, effect, refusal, or composition/observation
site in the new law. An atom mutant removes or changes just that site. The
listed W row supplies a reachable scenario; the named theorem is the expected
falsifier, not a claimed kill. Imported OracleIdentity internals remain frozen:
mutants touch the consuming call or binding only. Some guard-removal mutants
need the same reachable prefix with a malformed proposed action; acceptance
of that malformed action is the intended counterexample, not a new initial state.

| Atom | Class | Site and obligation | Reachable scenario | Expected falsifier | Named single-atom mutant |
|---|---|---|---|---|---|
| A001 | Origin | registryCreated: Fresh registry identity | W06 | registry_creation | M-A001: Remove id-not-existing guard |
| A002 | Origin | RegistryValid: At least one oracle or rule | W95 | unguarded_registry_impossible | M-A002: Allow neither oracle nor rule |
| A003 | Origin | RegistryValid: No repeated oracle identities | W67 | reachable_tags_unique | M-A003: Remove oracles.Nodup |
| A004 | Origin | RegistryValid: Positive output minimum | W06 | registry_creation | M-A004: Remove 0 < minimum |
| A005 | Origin | registryCreated: Empty initial trie | W06 | registry_creation | M-A005: Remove trie = emptyTrie |
| A006 | Origin | registryCreated: Zero initial balance function | W06 | registry_creation | M-A006: Remove zero balances equality |
| A007 | Origin | registryCreated: Zero initial fee backing value | W06 | registry_creation | M-A007: Remove value = 0 |
| A008 | Binding | Step.create: Creation references the actual source registry | W52 | creation_references_source | M-A008: Remove cageRef = source cage |
| A009 | Authorization | createAllowed: Oracle-bearing request spends its seed; zero-oracle request need not | W07 | create_tags_existing_cage | M-A009: Remove seed-spent implication |
| A010 | Binding | Step.create: Every spent seed is fresh in this history | W41 | spent_seed_cannot_create_again | M-A010: Remove fresh-spent-seed premise |
| A011 | Binding | createAllowed: Exactly one declared output | W07 | create_tags_existing_cage | M-A011: Allow outputs to contain additional requests |
| A012 | Binding | createAllowed: Exact mint of all tags plus one request token | W07 | create_tags_existing_cage | M-A012: Allow minted list to omit one tag |
| A013 | Binding | wellFormed: Request datum names source registry | W07 | create_tags_existing_cage | M-A013: Remove request cage equality |
| A014 | Binding | wellFormed: All and only oracle tags reside on the request | W66 | reachable_live_tags | M-A014: Allow tags = [] |
| A015 | Money | wellFormed: Escrow covers fees plus ledger minimum | W55 | creation_funds_declared_fees | M-A015: Remove minimum from funding floor |
| A016 | Binding | wellFormed: Exactly one registry-named request token | W85 | reachable_request_tokens | M-A016: Allow empty requestTokens |
| A017 | Binding | wellFormed: Output request-token policy matches rule or release | W113 | creation_request_policy | M-A017: Always select release |
| A018 | Authorization | createAllowed: Rule sees actual request and actual creation signatures | W112 | creation_rule_input_binding | M-A018: Substitute a request with empty conditions into ruleAdmits |
| A019 | Binding | createAllowed: Mint policy matches the source rule or release | W113 | creation_request_policy | M-A019: Ignore tx.policy equality |
| A020 | Binding | Step.create: Fresh output reference, distinct from seed | W94 | reachable_output_refs_unique | M-A020: Remove ref-not-used premise |
| A021 | Effect | afterCreate: Record spent seeds monotonically | W40 | reachable_requests_have_spent_seeds | M-A021: Omit spent-seed insertion |
| A022 | Effect | afterCreate: Insert exactly the created request | W136 | step_inversion | M-A022: Insert an unrelated request as well |
| A023 | Effect | afterCreate: Record the fresh request output reference | W93 | reachable_output_refs | M-A023: Omit usedOutputs insertion |
| A024 | Binding | Step.judge: Judgment references actual source registry | W46 | new_judgment_is_authorized | M-A024: Drop cageRef equality |
| A025 | Binding | Step.judge: Judgment references an authentic live request | W46 | new_judgment_is_authorized | M-A025: Drop requestRef membership |
| A026 | Binding | judgmentAllowed: Referenced request belongs to referenced registry | W09 | judgment_authorized_and_bound | M-A026: Drop request.cage equality |
| A027 | Authorization | judgmentAllowed: Oracle belongs to registry identities | W09 | judgment_authorized_and_bound | M-A027: Drop oracle membership |
| A028 | Authorization | judgmentAllowed: Evidence signer list equals authenticated transaction signers | W09 | judgment_authorized_and_bound | M-A028: Ignore evidence.signers equality |
| A029 | Authorization | Evidence.authorized: Imported authorization binds supplied description and canonical record to expected identity | W09 | judgment_authorized_and_bound | M-A029: Replace authorize equality by True |
| A030 | Time | judgmentAllowed: Nonempty judgment interval | W09 | judgment_authorized_and_bound | M-A030: Drop interval.valid |
| A031 | Time | judgmentAllowed: Entire judgment interval precedes deadline | W09 | judgment_authorized_and_bound | M-A031: Drop upper < deadline |
| A032 | Effect | judgmentAllowed: Judging consumes no request input | W09 | judgment_authorized_and_bound | M-A032: Allow nonempty spent |
| A033 | Binding | judgmentAllowed: Exact singleton judgment mint | W09 | judgment_authorized_and_bound | M-A033: Allow an additional fabricated name |
| A034 | Binding | judgmentName: Registry, complete request, identity and verdict bound | W10 | judgment_not_replayable | M-A034: Erase the request seed |
| A035 | Binding | judgmentName: Canonical signing record bound | W122 | judgment_record_cannot_change | M-A035: Replace bound record by a constant |
| A036 | Binding | judgmentName: Approval conditions bound; refusal conditions omitted | W104 | approval_conditions_cannot_change | M-A036: Erase approval conditions |
| A037 | Effect | afterJudgment: Prepend all minted holdings without consuming requests | W36 | judgments_do_not_consume | M-A037: Clear live requests |
| A038 | Effect | afterJudgment: Append permanent mint evidence, including both verdicts | W60 | equivocation_reachable | M-A038: Forbid opposite verdict already in issued |
| A039 | Authorization | hasApproval: Every oracle supplies authorized selected evidence | W16 | fold_only_approved_before_deadline | M-A039: Drop hasApproval from write guard |
| A040 | Authorization | hasApproval: Only approvals authorize writes | W106 | fold_evidence_binds_conditions | M-A040: Accept approve = false |
| A041 | Binding | hasApproval: Reference binds the selected record and conditions | W106 | fold_evidence_binds_conditions | M-A041: Look up a name with empty conditions |
| A042 | Authorization | hasApproval: Inline path uses actual fold signers | W43 | one_oracle_signature_suffices | M-A042: Remove inline signature alternative |
| A043 | Money | oracleCredits: Imported splitFee uses selected description/signers and declared fee | W121 | group_credits_exact_split | M-A043: Split fee + 1 |
| A044 | Money | credits: Every oracle contributes exactly one split | W117 | fold_request_conservation | M-A044: Omit the first oracle's credits |
| A045 | Money | credit: Add each split payment to that key's existing balance | W53 | fold_payments_concrete | M-A045: Replace balances instead of incrementing |
| A046 | Money | credit: Add exactly the split total to registry fee backing | W115 | reachable_balances_backed | M-A046: Add total + 1 |
| A047 | Money | remainder: Escrow minus every declared oracle fee | W21 | allocation_conserves_value | M-A047: Return full escrow |
| A048 | Time | stepValid: Nonempty write interval | W109 | folder_discovery_executable | M-A048: Drop interval.valid |
| A049 | Time | stepValid: Write interval entirely before deadline | W135 | fold_interval_fits_every_item | M-A049: Drop upper < deadline |
| A050 | Binding | stepValid: Write requires well-formed request and token | W86 | fold_requires_request_token | M-A050: Drop wellFormed |
| A051 | Condition | stepValid: All requester conditions checked at current trie | W17 | fold_conditions_hold_when_applied | M-A051: Check against emptyTrie |
| A052 | Condition | stepValid: All selected oracle conditions checked at current trie | W103 | fold_all_conditions_hold | M-A052: Omit oracle condition checks |
| A053 | Time | accountAllowed: Nonempty account interval | W135 | None: equivalent guard removal | M-A053: Drop interval.valid |
| A054 | Time | accountAllowed: Account starts at or after deadline | W47 | exit_time_window | M-A054: Drop deadline <= lower |
| A055 | Time | accountAllowed: Account ends no later than deadline plus window | W47 | exit_time_window | M-A055: Drop upper bound |
| A056 | Binding | accountAllowed: Account requires well-formed request and token | W86 | fold_requires_request_token | M-A056: Drop wellFormed |
| A057 | Authorization | hasAccount: Every oracle supplies an authorized authentic selected verdict | W51 | account_references_authentic | M-A057: Drop one oracle from the quantifier |
| A058 | Authorization | hasAccount: Both verdicts permitted, without fold-time condition checks | W59 | account_accepts_any_verdicts | M-A058: Require approve = true |
| A059 | Effect | itemResult.write: Apply only this request's write | W18 | fold_root_is_folded_writes | M-A059: Keep incoming trie |
| A060 | Effect | itemResult.account: No trie write during settlement | W25 | account_complete_and_pays | M-A060: Apply the settled request's write |
| A061 | Money | itemResult.account: Credit fees independently of verdict | W27 | account_fee_neutral | M-A061: Add one unit on a refusal |
| A062 | Money | itemPayments.write: Pay exact remainder to folder with plain datum | W20 | fold_pays_and_keeps_rest | M-A062: Replace beneficiary by a fixed attacker |
| A063 | Money | itemPayments.account: Pay exact remainder to owner with plain datum | W54 | account_payments_concrete | M-A063: Replace beneficiary by folder |
| A064 | Composition | FoldRun.cons: Every item guard sees previous item's resulting state | W02 | foldRun_step_valid | M-A064: Use the initial state for the next guard |
| A065 | Composition | FoldRun.cons: Next item effect consumes previous resulting state | W03 | foldRun_result | M-A065: Recurse on incoming state |
| A066 | Composition | FoldRun.nil: Empty suffix leaves state unchanged | W137 | foldRun_inversion | M-A066: Allow arbitrary final state |
| A067 | Time | foldAccepted: Even an empty fold has a valid interval | W135 | fold_interval_fits_every_item | M-A067: Drop interval.valid |
| A068 | Composition | foldAccepted: No duplicate consumed request or claim references | W58 | fold_requests_unique | M-A068: Drop concatenated-ref Nodup |
| A069 | Effect | foldAccepted: Burn exact request/tag/claim token list in item order | W19 | fold_burns_tags | M-A069: Allow burned = [] |
| A070 | Effect | foldAccepted: Actual outputs equal per-turn foldPayments, with no fee outputs | W119 | fold_payments_exact | M-A070: Allow arbitrary output list |
| A071 | Binding | Step.fold: Fold input is the actual source registry | W50 | fold_references_authentic | M-A071: Drop cageIn equality |
| A072 | Binding | Step.fold: Every consumed request is live | W50 | fold_references_authentic | M-A072: Drop live request membership |
| A073 | Binding | Step.fold: Every consumed claim is live and immutable | W50 | fold_references_authentic | M-A073: Drop live claim membership |
| A074 | Binding | Step.fold: Every referenced judgment token is genuinely held | W50 | fold_references_authentic | M-A074: Drop authentic refs premise |
| A075 | Effect | afterFold: Only fold replaces registry state | W114 | only_fold_changes_registry | M-A075: Let afterCreate increment registry value |
| A076 | Effect | afterFold: Remove all consumed requests | W38 | fold_removes_consumed | M-A076: Retain consumed live requests |
| A077 | Effect | afterFold: Remove all consumed claims | W129 | claim_consumed_and_burned | M-A077: Retain consumed claims |
| A078 | Authorization | foldAccepted: Submission is permissionless | W23 | fold_permissionless | M-A078: Require submitter = folder |
| A079 | Composition | foldAccepted: Empty fold is accepted and earns nothing | W110 | empty_fold_allowed | M-A079: Require nonempty items |
| A080 | Binding | Step.claimCreate: Claim creation references actual source registry | W123 | claim_creation_inversion | M-A080: Drop cageRef equality |
| A081 | Binding | claimCreateAllowed: Claim datum names registry | W123 | claim_creation_inversion | M-A081: Drop output.cage equality |
| A082 | Authorization | claimCreateAllowed: Claiming key belongs to some registry identity | W123 | claim_creation_inversion | M-A082: Drop registryKeys membership |
| A083 | Authorization | claimCreateAllowed: Claim creator key signs | W124 | reachable_claim_authorization | M-A083: Drop key signature requirement |
| A084 | Binding | claimCreateAllowed: Exactly one registry claim token on output | W123 | claim_creation_inversion | M-A084: Allow empty output.tokens |
| A085 | Binding | claimCreateAllowed: Mint exactly output's claim token | W123 | claim_creation_inversion | M-A085: Allow additional minted names |
| A086 | Binding | Step.claimCreate: Claim output reference is fresh | W136 | step_inversion | M-A086: Drop ref-not-used premise |
| A087 | Effect | afterClaimCreate: Insert the whole immutable claim and remember its reference | W124 | reachable_claim_authorization | M-A087: Change payout datum on insertion |
| A088 | Binding | claimAllowed: Claim belongs to current registry | W138 | claim_item_inversion | M-A088: Drop cage equality |
| A089 | Authorization | claimAllowed: Claiming key is a registry key | W138 | claim_item_inversion | M-A089: Drop key membership |
| A090 | Binding | claimAllowed: Claim token names this registry | W138 | claim_item_inversion | M-A090: Ignore claim tokens |
| A091 | Time | claimAllowed: Claim interval is nonempty | W135 | None: equivalent guard removal | M-A091: Drop interval.valid |
| A092 | Time | claimAllowed: Entire claim interval precedes deadline | W135 | fold_interval_fits_every_item | M-A092: Allow upper <= deadline |
| A093 | Refusal | claimAllowed: Balance at turn meets ledger minimum | W127 | claim_below_minimum_refused | M-A093: Remove minimum comparison |
| A094 | Money | itemPayments.claim: Exactly whole turn-time balance to fixed address | W125 | claim_payout_fixed | M-A094: Pay to folder |
| A095 | Money | itemPayments.claim: Exactly claim's fixed datum | W125 | claim_payout_fixed | M-A095: Replace datum by empty string |
| A096 | Money | itemPayments.claim: Entire claim escrow/tip paid separately to folder | W119 | fold_payments_exact | M-A096: Omit tip output |
| A097 | Money | itemResult.claim: Reset only claimed key to zero | W125 | claim_payout_fixed | M-A097: Leave claimed balance unchanged |
| A098 | Money | itemResult.claim: Preserve every other key balance | W125 | claim_payout_fixed | M-A098: Clear all balances |
| A099 | Money | itemResult.claim: Subtract payout from registry value | W116 | fold_value_conservation | M-A099: Keep value unchanged |
| A100 | Binding | Step.withdraw: Owner withdraws an authentic live request | W136 | step_inversion | M-A100: Drop live membership |
| A101 | Time | withdrawAllowed: Nonempty owner withdrawal interval | W28 | withdraw_only_owner_after_window | M-A101: Drop interval.valid |
| A102 | Time | withdrawAllowed: Entire owner withdrawal is strictly after window | W28 | withdraw_only_owner_after_window | M-A102: Allow lower = deadline + window |
| A103 | Authorization | withdrawAllowed: Request owner signs | W28 | withdraw_only_owner_after_window | M-A103: Drop owner signature |
| A104 | Effect | withdrawAllowed: Burn all request tags and token | W31 | every_exit_burns_tag | M-A104: Remove burned equality |
| A105 | Money | withdrawAllowed: Pay all request escrow exactly to owner | W28 | withdraw_only_owner_after_window | M-A105: Permit another beneficiary |
| A106 | Effect | afterExit: Only request inventory changes, registry untouched | W134 | request_withdrawal_preserves_registry | M-A106: Clear registry balances |
| A107 | Binding | Step.claimWithdraw: Claim withdrawal consumes held claim | W130 | claim_withdrawal_inversion | M-A107: Drop claim membership |
| A108 | Time | claimWithdrawAllowed: Nonempty claim withdrawal interval | W130 | claim_withdrawal_inversion | M-A108: Drop interval.valid |
| A109 | Time | claimWithdrawAllowed: Claim withdrawal starts at deadline or later | W130 | claim_withdrawal_inversion | M-A109: Remove deadline bound |
| A110 | Authorization | claimWithdrawAllowed: Claim creator key signs withdrawal | W130 | claim_withdrawal_inversion | M-A110: Drop key signature |
| A111 | Effect | claimWithdrawAllowed: Burn exactly claim tokens | W130 | claim_withdrawal_inversion | M-A111: Remove burned equality |
| A112 | Money | claimWithdrawAllowed: Return full claim escrow/tip to creator key | W130 | claim_withdrawal_inversion | M-A112: Pay the folder instead |
| A113 | Effect | afterClaimWithdraw: Remove exactly claim occurrence, registry untouched | W130 | claim_withdrawal_inversion | M-A113: Alter registry balances |
| A114 | Binding | Step.burn: Burned judgment is held | W136 | step_inversion | M-A114: Remove held-name premise |
| A115 | Effect | afterBurn: Erase exactly one held occurrence | W56 | burn_removes_one | M-A115: Keep holdings unchanged |
| A116 | Effect | afterBurn: Preserve permanent issuance record | W57 | burn_keeps_history | M-A116: Erase issuance record too |
| A117 | Authorization | Step.burn: Dead conditional judgments require no live request or rule re-admission | W35 | dead_judgment_can_burn | M-A117: Require a live request |
| A118 | Authorization | priceMintAllowed: Imported identity authorization for notice mint | W71 | price_mint_inversion | M-A118: Remove authorize success |
| A119 | Binding | priceMintAllowed: Price name binds oracle identity and price role | W71 | price_mint_inversion | M-A119: Allow arbitrary token name |
| A120 | Effect | priceMintAllowed: Mint exactly the notice token | W71 | price_mint_inversion | M-A120: Allow extra minted token |
| A121 | Binding | Step.priceUpdate: Updated notice must be held | W72 | price_update_inversion | M-A121: Drop held-input premise |
| A122 | Authorization | priceUpdateAllowed: Imported identity authorization for update | W72 | price_update_inversion | M-A122: Remove authorize success |
| A123 | Binding | priceUpdateAllowed: Input name authentic, output retains identity and token | W72 | price_update_inversion | M-A123: Allow output oracle change |
| A124 | Effect | priceUpdateAllowed: No mint during update | W72 | price_update_inversion | M-A124: Allow remint |
| A125 | Effect | afterPriceMint: Prepend notice and alter no other protocol state or payment | W76 | price_notice_noninterference | M-A125: Clear judgments |
| A126 | Effect | afterPriceUpdate: Replace one notice occurrence, preserving every protocol field | W76 | price_notice_noninterference | M-A126: Clear live claims |
| A127 | Nonbinding | Step: Arbitrary notice data has no role in nonprice transition validity | W77 | notices_do_not_bind_protocol | M-A127: Require a notice on fold |
| A128 | Binding | tagName: Identity-bound tag supports cross-registry query | W61 | tag_name_injective | M-A128: Replace identity by constant |
| A129 | Binding | requestName: Registry-bound role-led request name | W89 | request_name_injective | M-A129: Replace registry by constant |
| A130 | Binding | claimName: Registry-bound role-led claim name | W133 | claim_discovery_exact | M-A130: Replace registry by constant |
| A131 | Binding | priceName: Identity-bound role-led price name | W62 | price_name_injective | M-A131: Replace identity by constant |
| A132 | Binding | tokenName: Different leading roles distinguish name domains | W63 | different_roles_never_coincide | M-A132: Replace role by tag |
| A133 | Observation | discover: Filter complete live inventory by identity tag | W68 | discovery_iff | M-A133: Return all outputs |
| A134 | Observation | discoverRequests: Filter complete live inventory by registry request token | W90 | request_token_discovery | M-A134: Return all outputs |
| A135 | Observation | discoverClaims: Filter live claims by registry claim token | W133 | claim_discovery_exact | M-A135: Return all outputs |
| A136 | Observation | expectedApprovals: Select full record/conditions-bound approval names | W107 | expected_approval_lookup | M-A136: Return empty list |
| A137 | Observation | folderFinds: Exactly live requests satisfying write guards at this turn | W108 | folder_discovery_exact | M-A137: Omit requester conditions |
| A138 | Composition | requestPolicy: Fixed rule controls creation, unconditional lifecycle burn thereafter | W83 | every_rule_allows_burn | M-A138: Require rule admission at fold |
| A139 | Observation | grossCredits: Sum actual fee credits over sequential turns | W117 | fold_request_conservation | M-A139: Return zero on a nonempty batch |
| A140 | Observation | claimPayouts: Sum whole balances at claim turns | W118 | fold_balance_conservation | M-A140: Use initial rather than current balance |
| A141 | Observation | requestRemainders: Sum only write/account remainders | W117 | fold_request_conservation | M-A141: Include claim escrow in request remainder sum |
| A142 | Observation | foldPayments: Include every turn's exact outputs (output order is not pinned) | W119 | fold_payments_exact | M-A142: Drop the current turn outputs from concatenation |
| A143 | Observation | balanceSum: Sum one balance per distinct registry key | W115 | reachable_balances_backed | M-A143: Count shared keys more than once |
| A144 | Observation | exitAt: Three nonoverlapping window classes, singleton intervals cover all time | W48 / W142 | exit_windows_cover / exit_windows_disjoint | M-A144: Leave deadline minus one uncovered; M-window-overlap: allow write upper <= deadline |
| A145 | Money | claimWithdrawAllowed: Pay the entire claim escrow amount | W130 | claim_withdrawal_inversion | M-A145: Require paid = 0 instead of input.value |
| A146 | Money | withdrawAllowed: Pay the entire request escrow amount | W28 | withdraw_only_owner_after_window | M-A146: Require paid = 0 instead of input.value |
| A147 | Origin | Trace.nil: Empty event history retains its initial state | W141 | trace_reachability | M-A147: Allow an arbitrary target state |
| A148 | Composition | Trace.cons: Every recorded event is an actual Step | W141 | trace_reachability | M-A148: Drop the Step premise |
| A149 | Binding | Trace.cons: Recorded action is the actual action, including the exact signed claim | W124 | reachable_claim_authorization | M-A149: Record a claimCreate action with its signers cleared |
| A150 | Composition | Trace.cons: The next event starts at the preceding target | W124 | reachable_claim_authorization | M-A150: Allow the suffix trace to start from an unrelated state |
| A151 | Observation | RequestSpend.exitsAs.write: Write classification requires this exact write input | W49 | exit_kind_unique | M-A151: Classify every folded account as a write too |
| A152 | Observation | RequestSpend.exitsAs.account: Account classification requires this exact account input | W49 | exit_kind_unique | M-A152: Classify every folded write as an account too |
| A153 | Observation | RequestSpend.exitsAs.withdraw: Withdrawal classification requires the exact withdrawn input | W47 | exit_time_window | M-A153: Classify a folded request as a withdrawal |

| MA1 | Authorization | hasApproval: selected evidence is authorized | W106 | fold_evidence_binds_conditions | M-MA1: drop selected-evidence authorization |
| MA2 | Authorization | hasAccount: selected evidence is authorized | W25 | account_complete_and_pays | M-MA2: drop selected-evidence authorization |
| MA3 | Effect | afterFold: registry becomes cageOut | W116 | fold_value_conservation | M-MA3: keep source registry |
| MA4 | Origin | Step effects: only claimCreate inserts claims | W124 | reachable_claim_authorization | M-MA4: afterJudgment inserts a fabricated claim |

The repair summaries below describe the statement phase before NOTE-003.
Their earlier admission/readiness wording is historical; current proof
outcomes are given above.

## Repair of statement audit 1

NOTE-001 repairs the NOT-READY findings on predecessor c2e5cb0. The revised
candidate has not been independently audited. Earlier mutant results apply
only to that predecessor and are not carried forward as new-candidate kills.

- B1 / T124 uses an explicit Trace indexed by exact source/action/target events.
  A live claim must equal the output of a key-signed creation event on that
  given trace. T141 relates these traces to Reachable in both directions.
  Both A083 (missing signature) and A087 (changed stored datum) falsify
  this revised history statement in targeted creator checks; a different history cannot
  supply its existential event. W124 supplies the full actual trace.
- B2 / T107 again characterizes hasApproval by an iff. Its right side includes
  identity authorization and approval status, as well as computed-name
  membership. Arbitrary Evidence can compute a name without being authorized;
  with authorized approval evidence fixed, this is exactly the original
  membership-only characterization. Empty fold signers cannot authorize an
  inline approval under the unchanged imported identity model.
- The retained guarantees listed in audit section 5 have their successor,
  source, authentication, funding, Step/FoldRun and iff conclusions restored.
  T47 and T49 classify actual allowed spends; W47 covers all three exits and
  W49 uses distinct true/false verdict account spends at the same interval.
  The approved Reachable premise of request_never_reappears is retained.
- T139 states actual claim fold/withdrawal point-interval coverage, including
  the exact deadline; it retains the non-time guards and balance minimum.
  T140 binds every fee record to shown evidence or an inline signed approval,
  and states that a key absent from all records cannot gain balance across
  the whole fold, including mixed write/account/claim batches (W140).
- A048 now targets folder_discovery_executable. A083 targets revised T124
  (and also claim_creation_inversion). A087 targets revised T124, not the
  symbolic successor equality in step_inversion. A142 changes to dropping a
  turn's outputs, targeting fold_payments_exact; output order remains unpinned.
- A053 and A091 guard-removal mutants are equivalent under foldAccepted's
  shared interval.valid guard; these two rows explicitly have no falsifier.
  MA1-MA4 preserve the auditor's missing-atom identifiers. A145-A153 cover
  withdrawal amounts and the newly added trace and exit-class observations.

Witnesses additionally include MixedBatch.conserved (write/account/claim in
one interval), MixedBatch.straddlingRefused, and SharedKey.summedOnce.

## Repair of statement audit 2

NOTE-002 repairs B3 and V1 from the re-audit of 4749209. That audit found all
NOTE-001 items resolved. T60 now binds equivocation to a live request of the
state's registry, one of its oracles, and a shared signing record, with both
verdict names held and issued. W60 directly witnesses every binding. T142
separately states exitAt window disjointness; W142 instantiates all three
classes. A144 names both its coverage and nonoverlap statements and mutants.
M-window-overlap now names the exitAt write-window mutation; the distinct
stepValid mutant for actual-spend T49 is named M-write-guard-overlap.
Model.lean is byte-identical to 4749209. All other theorem types are unchanged.
General proofs remain admitted; this candidate needs independent re-audit.

A targeted creator check in evidence/repair-2-mutant copies the exact T142
header and changes only exitAt.write from upper < deadline to upper <= deadline.
At the point interval [10,10], both write and account then hold for a request
with deadline 10. The negation of T142 compiles with no axioms. Its unmutated
control fails when constructing the write-window premise at the deadline.
This finite check closes the requested M-window-overlap example locally;
it is not independent audit approval.

## Targeted creator mutation receipts

The runtime evidence/repair-mutants directory contains two isolated model
mutants and matching unmutated controls, generated from this frozen Model
and the exact T124 declaration header. A083 drops only the key-signature
guard; A087 changes only the stored claim datum to the empty string. Each
Kill file constructs an actual registry-origin Trace and proves the negation
of T124. Both mutant compilations exit 0, with only propext on the killing
lemma. Both unchanged-model controls exit 1: respectively at the unsigned
claim Step guard and at membership of the altered claim in live claims.
Control errors introduce sorryAx and are expressly excluded from evidence
of a kill. See results.tsv, KillA083.log, KillA087.log, and the Control logs.
Initial harness setup/iteration failures remain in that evidence directory.
These two finite, creator-run checks are not independent approval and do not
carry the predecessor auditor's 138-row kill results onto this candidate.

## Limits and reopened surfaces

All 113 old theorem rows have new local statements; prior PROVED and mutation
receipts apply to the predecessor only. Their fees, exits, evidence, discovery,
rule burns, conditions, naming and price interfaces have reopened. All 142
statements are proved. Witness proofs remain
concrete examples, separate from the universally quantified guarantees.

The authoritative surface is Step, with FoldRun and itemAllowed/itemResult.
Boundary observations are Action.payments, foldPayments, totalPaid, credits,
balanceSum, requestEscrows, claimEscrows, requestRemainders, grossCredits,
claimPayouts, token names, and the three inventory queries. Exact inversions:
step_inversion and foldRun_inversion, supplemented by the action-specific
creation, judgment, payment, price and claim inversions.

Rule.admits remains an arbitrary predicate over one request and creation
signatures. Trie remains a function. A computable rule boundary, executable
stepFn, JSON codecs, generic driver and replay corpus remain #109 by A-001;
this candidate is not handed to production as an executable oracle. No model
claim establishes real signature verification, hash collision resistance,
canonical CDDL/CBOR, deployed policy identity, complete indexer results, MPF
proof soundness, costs, liveness, fairness or validator conformance.

The minimum is an immutable positive registry model parameter. Its agreement
with the current ledger's output-specific minimum calculation is external.
The registry's permanent reserve and claim-output minimum funding are outside
the fee account. Addresses and datums are opaque strings; exact equality is
modelled, script acceptance at the destination is not.

## Frozen theorem names and types

Each digest hashes the following exact source declaration header (the text
inside its code fence, without the trailing newline). The model hash above
fixes every definition that these types reference. Their PROVED status is recorded in the theorem table;
the frozen declaration headers exclude proof bodies.

### RequestApprovalFold.applyAll_append

Type SHA-256: `7d5637ef3d90bef4cf35754f203056ad389919bf2d5ab276dd605a4298651f2c`.

```lean
theorem applyAll_append (t : Trie) (xs ys : List Write) : applyAll t (xs ++ ys) = applyAll (applyAll t xs) ys
```

### RequestApprovalFold.foldRun_step_valid

Type SHA-256: `cbaa277c49a0f4c9acd52f464eca958f909c7bee1976cb37bc50d9490ca4c104`.

```lean
theorem foldRun_step_valid {iv : Interval} {refs : List TokenName} {sigs : List Signer} {c out : CageState} {items : List FoldItem} :
 FoldRun iv refs sigs c items out → ∀ n item, items[n]? = some item →
 itemAllowed (foldResult c (items.take n)) iv refs sigs item
```

### RequestApprovalFold.foldRun_result

Type SHA-256: `f3f510f6c15239f0af039bb2ad25518fad0ddf86607aa8a099aba06342d51a0e`.

```lean
theorem foldRun_result {iv : Interval} {refs : List TokenName} {sigs : List Signer} {c out : CageState} {items : List FoldItem} :
 FoldRun iv refs sigs c items out → out = foldResult c items
```

### RequestApprovalFold.foldRun_conditions

Type SHA-256: `3458e8d09f5ed053c177ae94630a526af8fdb037eb64863131f99cc34e30a140`.

```lean
theorem foldRun_conditions {iv : Interval} {refs : List TokenName} {sigs : List Signer} {c out : CageState} {items : List FoldItem} :
 FoldRun iv refs sigs c items out → ∀ n o e, items[n]? = some (FoldItem.write o e) →
 ∀ condition ∈ o.request.conditions, condition.holds (foldResult c (items.take n)).trie
```

### RequestApprovalFold.applyAll_keeps_present

Type SHA-256: `7163547a98abf081a1a4802b6cfea02eed7369a7c4ce3a81673ae69c39948dcd`.

```lean
theorem applyAll_keeps_present (k : Key) :
    ∀ (ws : List Write) (t : Trie), (∀ w ∈ ws, w ≠ .unset k) →
      (t k).isSome → (applyAll t ws k).isSome
```

### RequestApprovalFold.registry_creation

Type SHA-256: `0ce6521525cba23f659c933a25b87104c3b4e36e218508d2b48593fcc79c39e7`.

```lean
theorem registry_creation (c : CageState) (existing : List CageId) : registryCreated c existing →
 c.id ∉ existing ∧ (c.oracles ≠ [] ∨ c.rule.isSome) ∧ c.oracles.Nodup ∧ 0 < c.minimum ∧ c.trie = emptyTrie ∧ c.balances = (fun _ => 0) ∧ c.value = 0
```

### RequestApprovalFold.create_tags_existing_cage

Type SHA-256: `3eedecdccc98490375956a13483f915de51a8fa9dedf20c7bb2c90508cb32c2a`.

```lean
theorem create_tags_existing_cage (tx : CreateTx) (o : RequestOutput) : createAllowed tx o →
 (tx.cageRef.oracles ≠ [] → o.request.seed ∈ tx.spent) ∧ tx.outputs = [o] ∧
 tx.minted = tx.cageRef.oracles.map tagName ++ [requestName tx.cageRef.id] ∧
 o.request.cage = tx.cageRef.id ∧ o.tags = tx.cageRef.oracles.map tagName ∧
 totalFees tx.cageRef o.request + tx.cageRef.minimum ≤ o.value
```

### RequestApprovalFold.requests_unique_in_history

Type SHA-256: `8b999c8bdbf91990b43066e57edaf1156e8499dc80c62d7e1f2166ef5d61a19b`.

```lean
theorem requests_unique_in_history (history : List CreateTx)
    (a b : CreateTx) (oa ob : RequestOutput) :
    SpentOnce history → a ∈ history → b ∈ history →
    createAllowed a oa → createAllowed b ob → a.cageRef.oracles ≠ [] →
    b.cageRef.oracles ≠ [] → a ≠ b →
    oa.request ≠ ob.request
```

### RequestApprovalFold.judgment_authorized_and_bound

Type SHA-256: `6c851a416edbb4a790f25d909fbb9ec3958a2d8787d2b390c9a52f74bdd346ba`.

```lean
theorem judgment_authorized_and_bound (tx : JudgmentTx) : judgmentAllowed tx →
 tx.oracle ∈ tx.cageRef.oracles ∧
 OracleIdentity.authorize tx.oracle tx.evidence.description tx.signers = some tx.evidence.record ∧
 tx.interval.valid ∧ tx.interval.upper < tx.requestRef.request.deadline ∧ tx.spent = [] ∧
 tx.requestRef.request.cage = tx.cageRef.id ∧
 tx.minted = [judgmentName tx.cageRef.id tx.requestRef.request tx.oracle tx.evidence.approve
   tx.evidence.record tx.evidence.conditions]
```

### RequestApprovalFold.judgment_not_replayable

Type SHA-256: `f9f57654f195a31729bc9552d64bf9ea277141050acb905508bdeb0bf2f17f5c`.

```lean
theorem judgment_not_replayable (c c' : CageId) (r r' : Request) (o o' : Oracle) (v v' : Bool)
 (rec rec' : SigningRecord) (cs cs' : List Condition) :
 judgmentName c r o v rec cs = judgmentName c' r' o' v' rec' cs' →
 c = c' ∧ r = r' ∧ o = o' ∧ v = v' ∧ rec = rec' ∧ (v = true → cs = cs')
```

### RequestApprovalFold.token_roles_separated

Type SHA-256: `648600707204129827ac1399ced3eb3b167b92ea9e7df4b40ed8d332f8c1530d`.

```lean
theorem token_roles_separated (o o' : Oracle) (c : CageId) (r : Request) (v : Bool) (rec : SigningRecord) (cs : List Condition) :
 tagName o ≠ judgmentName c r o' v rec cs
```

### RequestApprovalFold.fold_preserves_registry

Type SHA-256: `cf7dc3744ca198ab7cc34a6e56231fd18f6b0d0cd7e234029fc46fd62113d18a`.

```lean
theorem fold_preserves_registry (tx : FoldTx) : foldAccepted tx → SameRegistry tx.cageOut tx.cageIn
```

### RequestApprovalFold.step_preserves_registry

Type SHA-256: `d7ab3d1f81384cbe8cf500c30d127540004dcb2d7d107260e78f0944a85774b7`.

```lean
theorem step_preserves_registry {s s' : State} {a : Action} : Step s a s' → SameRegistry s'.cage s.cage
```

### RequestApprovalFold.history_preserves_registry

Type SHA-256: `e64d4c8121f49551530a31f367e4f360c90e59214a8b146ebb6d3c0c6a80a3af`.

```lean
theorem history_preserves_registry {s s' : State} : History s s' → SameRegistry s'.cage s.cage
```

### RequestApprovalFold.only_fold_changes_tree

Type SHA-256: `532362e01fc216b79ed1b0bac25fa499309faed7e23f96d737d1b56781c943d8`.

```lean
theorem only_fold_changes_tree {s s' : State} {a : Action} : Step s a s' →
 s'.cage.trie ≠ s.cage.trie → ∃ tx, a = .fold tx ∧ foldAccepted tx ∧
 tx.cageIn = s.cage ∧ s' = afterFold s tx
```

### RequestApprovalFold.fold_only_approved_before_deadline

Type SHA-256: `ebda33452a6d820cadbe33d34e7f546595071dd9ac5da83f506deeb1aee94e0f`.

```lean
theorem fold_only_approved_before_deadline (tx : FoldTx) : foldAccepted tx → ∀ n o e,
 tx.items[n]? = some (FoldItem.write o e) → o.request.cage = tx.cageIn.id ∧
 tx.interval.upper < o.request.deadline ∧ hasApproval (atTurn tx n) o.request tx.refs tx.signers e
```

### RequestApprovalFold.fold_conditions_hold_when_applied

Type SHA-256: `9555a31b96026cb7c16e218efba129825ec5dee590e46c6e11f0de5dde1068bc`.

```lean
theorem fold_conditions_hold_when_applied (tx : FoldTx) : foldAccepted tx → ∀ n o e,
 tx.items[n]? = some (FoldItem.write o e) → ∀ condition ∈ o.request.conditions, condition.holds (atTurn tx n).trie
```

### RequestApprovalFold.fold_root_is_folded_writes

Type SHA-256: `14d1d96df1e0c40f662b15dd4815080d7376f564f8f42b8d5106d43201681e9d`.

```lean
theorem fold_root_is_folded_writes (tx : FoldTx) : foldAccepted tx →
 tx.cageOut.trie = applyAll tx.cageIn.trie (tx.items.flatMap FoldItem.writes)
```

### RequestApprovalFold.fold_burns_tags

Type SHA-256: `b2d368fd88ff69d168086bd3adf2fb8c9bcebaaf3666539c48d67775a0399672`.

```lean
theorem fold_burns_tags (tx : FoldTx) : foldAccepted tx → tx.burned = tx.items.flatMap FoldItem.burned
```

### RequestApprovalFold.fold_pays_and_keeps_rest

Type SHA-256: `3b74eb77bd20c0de8f1cfa334db84113b4c9fb2e72e0814c93def25178d43692`.

```lean
theorem fold_pays_and_keeps_rest (tx : FoldTx) : foldAccepted tx → ∀ n o e,
 tx.items[n]? = some (FoldItem.write o e) →
 (itemResult (atTurn tx n) (.write o e)).balances = (fun k => (atTurn tx n).balances k + OracleIdentity.paidTo (credits (atTurn tx n) o.request e) k) ∧
 itemPayments (atTurn tx n) tx.folder (FoldItem.write o e) = [⟨tx.folder, "", o.value - totalFees tx.cageIn o.request⟩] ∧
 ∀ oracle ∈ tx.cageIn.oracles,
 OracleIdentity.totalPaid (oracleCredits o.request oracle (e oracle)) = o.request.fee oracle
```

### RequestApprovalFold.allocation_conserves_value

Type SHA-256: `c55c5a55d2b40c267e978c376bf257b9e633d31d0705d87c24f5e2bae081e31f`.

```lean
theorem allocation_conserves_value (c : CageState) (iv : Interval) (refs : List TokenName)
 (sigs : List Signer) (o : RequestOutput) (e : Selection) :
 (stepValid c iv refs sigs e o ∨ accountAllowed c iv refs o e) →
 o.value = OracleIdentity.totalPaid (credits c o.request e) + remainder c o
```

### RequestApprovalFold.blind_write_folds_on_any_tree

Type SHA-256: `78369d495630526f316520198b6d88c34f9154e5f5b6e5afd178854eed93ce83`.

```lean
theorem blind_write_folds_on_any_tree (c : CageState) (iv : Interval) (refs : List TokenName)
 (sigs : List Signer) (o : RequestOutput) (e : Selection) :
 wellFormed c o → iv.valid → iv.upper < o.request.deadline → hasApproval c o.request refs sigs e →
 o.request.conditions = [] → (∀ oracle ∈ c.oracles, (e oracle).conditions = []) →
 ∀ t, FoldRun iv refs sigs { c with trie := t } [FoldItem.write o e]
 (itemResult { c with trie := t } (FoldItem.write o e)) ∧
 (itemResult { c with trie := t } (FoldItem.write o e)).trie = o.request.write.apply t
```

### RequestApprovalFold.fold_permissionless

Type SHA-256: `6c59d4b8d70fbd1620354a837a6dc64fb9d56307586291c57acd94d054937cc0`.

```lean
theorem fold_permissionless (tx : FoldTx) (other : Signer) :
 foldAccepted tx → foldAccepted { tx with submitter := other }
```

### RequestApprovalFold.absent_inserts_exclusive

Type SHA-256: `cea1d37b0d80d2f621f420c9a3cf4729ebeee7db1ac50ac55e8ba49619c7b3b9`.

```lean
theorem absent_inserts_exclusive (tx : FoldTx) (n m : Nat) (a b : RequestOutput) (ea eb : Selection) (k : Key) (v : Val) :
 foldAccepted tx → n < m → tx.items[n]? = some (FoldItem.write a ea) → tx.items[m]? = some (FoldItem.write b eb) →
 a.request.write = .set k v → Condition.absent k ∈ b.request.conditions →
 Write.unset k ∈ ((tx.items.drop (n + 1)).take (m - (n + 1))).flatMap FoldItem.writes
```

### RequestApprovalFold.account_complete_and_pays

Type SHA-256: `4109de297a922a78f132a7423030b1df3ad6adbeaac9c4c1c965631d4a94aaad`.

```lean
theorem account_complete_and_pays (tx : FoldTx) : foldAccepted tx → ∀ n o e,
 tx.items[n]? = some (FoldItem.account o e) → hasAccount (atTurn tx n) o.request tx.refs e ∧
 (itemResult (atTurn tx n) (.account o e)).balances = (fun k => (atTurn tx n).balances k + OracleIdentity.paidTo (credits (atTurn tx n) o.request e) k) ∧
 (itemResult (atTurn tx n) (FoldItem.account o e)).trie = (atTurn tx n).trie ∧
 itemPayments (atTurn tx n) tx.folder (FoldItem.account o e) = [⟨o.request.owner, "", remainder tx.cageIn o⟩] ∧
 OracleIdentity.totalPaid (credits (atTurn tx n) o.request e) = totalFees tx.cageIn o.request
```

### RequestApprovalFold.account_anyone_in_window

Type SHA-256: `8a4de0fbb6bd11634c3ce83b52d60744a5f8022a327bba95dc69de8fa4d8b686`.

```lean
theorem account_anyone_in_window (s : State) (o : RequestOutput) (e : Selection) (iv : Interval) (who : Signer) :
 o ∈ s.live → wellFormed s.cage o → hasAccount s.cage o.request s.judgments e →
 iv.valid → o.request.deadline ≤ iv.lower → iv.upper ≤ o.request.deadline + o.request.window →
 Step s (.fold (singletonFold s iv [] (FoldItem.account o e) who))
 (afterFold s (singletonFold s iv [] (FoldItem.account o e) who))
```

### RequestApprovalFold.account_fee_neutral

Type SHA-256: `8ac2cd762c5bbf12f355654d50359fc7d662b272c899834944b1c758fec5f5c3`.

```lean
theorem account_fee_neutral (c : CageState) (iv : Interval) (ra rb : List TokenName)
 (o : RequestOutput) (a b : Selection) (folder : Signer) :
 accountAllowed c iv ra o a → accountAllowed c iv rb o b →
 itemPayments c folder (FoldItem.account o a) = itemPayments c folder (FoldItem.account o b) ∧
 (itemResult c (FoldItem.account o a)).trie = (itemResult c (FoldItem.account o b)).trie ∧
 OracleIdentity.totalPaid (credits c o.request a) = OracleIdentity.totalPaid (credits c o.request b) ∧
 (∀ oracle ∈ c.oracles, OracleIdentity.totalPaid (oracleCredits o.request oracle (a oracle)) =
   OracleIdentity.totalPaid (oracleCredits o.request oracle (b oracle))) ∧
 ((∀ oracle ∈ c.oracles, (a oracle).record = (b oracle).record) →
   itemResult c (FoldItem.account o a) = itemResult c (FoldItem.account o b))
```

### RequestApprovalFold.withdraw_only_owner_after_window

Type SHA-256: `ef53ff5dacc58fbc127dd51c652699d07fe48dc2defa0f6177742740ec44c56e`.

```lean
theorem withdraw_only_owner_after_window (tx : WithdrawTx) : withdrawAllowed tx →
 tx.input.request.owner ∈ tx.signers ∧ tx.input.request.deadline + tx.input.request.window < tx.interval.lower ∧
 tx.interval.valid ∧ tx.burned = tokensOf tx.input ∧ tx.beneficiary = tx.input.request.owner ∧ tx.paid = tx.input.value
```

### RequestApprovalFold.owner_can_withdraw_everything

Type SHA-256: `b00d7304ff02a587e9fe1e54a2245b92cf4256a12813abe75f6ce926d19dd44c`.

```lean
theorem owner_can_withdraw_everything (o : RequestOutput) (iv : Interval) :
 iv.valid → o.request.deadline + o.request.window < iv.lower →
 withdrawAllowed ⟨o, iv, [o.request.owner], tokensOf o, o.request.owner, o.value⟩
```

### RequestApprovalFold.request_spent_only_by_lifecycle

Type SHA-256: `f2cf5ced4f8a4862902421c6f45297bd611200569c65720d4ceb893d2ee5f460`.

```lean
theorem request_spent_only_by_lifecycle (o : RequestOutput) (spend : RequestSpend) : requestSpendAllowed o spend →
 (∃ tx e, spend = .folded tx ∧ foldAccepted tx ∧ FoldItem.write o e ∈ tx.items) ∨
 (∃ tx e, spend = .folded tx ∧ foldAccepted tx ∧ FoldItem.account o e ∈ tx.items) ∨
 (∃ tx, spend = .withdrawn tx ∧ withdrawAllowed tx ∧ tx.input = o)
```

### RequestApprovalFold.every_exit_burns_tag

Type SHA-256: `39d64a55afd6031cfa33f6e1ada02b70cd701b7be4354a74107e2f3443686028`.

```lean
theorem every_exit_burns_tag (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → ∀ tag ∈ tokensOf o, tag ∈ spend.burned
```

### RequestApprovalFold.early_exit_requires_all_judgments

Type SHA-256: `b561529ea7838a7082e08c94da978a11fb67f281e3e7a190c91916264668caf2`.

```lean
theorem early_exit_requires_all_judgments (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → spend.interval.lower ≤ o.request.deadline + o.request.window →
 ∃ (tx : FoldTx) (n : Nat) (e : Selection), spend = .folded tx ∧
 ((tx.items[n]? = some (FoldItem.write o e) ∧ hasApproval (atTurn tx n) o.request tx.refs tx.signers e) ∨
 (tx.items[n]? = some (FoldItem.account o e) ∧ hasAccount (atTurn tx n) o.request tx.refs e))
```

### RequestApprovalFold.early_exit_pays_every_oracle

Type SHA-256: `e68972201eb2e352ea770d71f1e707a640f5156284a4b9a78715c18b3b710b9d`.

```lean
theorem early_exit_pays_every_oracle (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → spend.interval.lower ≤ o.request.deadline + o.request.window →
 ∃ (tx : FoldTx) (n : Nat) (e : Selection), spend = .folded tx ∧
 (tx.items[n]? = some (FoldItem.write o e) ∨ tx.items[n]? = some (FoldItem.account o e)) ∧
 (∀ item, tx.items[n]? = some item → (itemResult (atTurn tx n) item).balances =
 (fun k => (atTurn tx n).balances k + OracleIdentity.paidTo (credits (atTurn tx n) o.request e) k)) ∧
 ∀ oracle ∈ tx.cageIn.oracles,
 OracleIdentity.totalPaid (oracleCredits o.request oracle (e oracle)) = o.request.fee oracle
```

### RequestApprovalFold.before_deadline_only_approvals

Type SHA-256: `ca2b8919c801f86d0f1d71159e64ac15e1bb24c6cda686ca0eb89b1cc6bddaad`.

```lean
theorem before_deadline_only_approvals (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → spend.interval.lower < o.request.deadline →
 ∃ (tx : FoldTx) (n : Nat) (e : Selection), spend = .folded tx ∧ tx.items[n]? = some (FoldItem.write o e) ∧
 hasApproval (atTurn tx n) o.request tx.refs tx.signers e
```

### RequestApprovalFold.dead_judgment_can_burn

Type SHA-256: `4977e0f623ce9ca6c14f494a87fc4994b2cdc53abfc8b1f0b631f840680ec94d`.

```lean
theorem dead_judgment_can_burn (s : State) (c : CageId) (r : Request) (o : Oracle)
 (v : Bool) (rec : SigningRecord) (cs : List Condition) :
 judgmentName c r o v rec cs ∈ s.judgments → (∀ output ∈ s.live, output.request ≠ r) →
 Step s (.burn (judgmentName c r o v rec cs)) (afterBurn s (judgmentName c r o v rec cs)) ∧
 (afterBurn s (judgmentName c r o v rec cs)).cage = s.cage ∧
 (afterBurn s (judgmentName c r o v rec cs)).live = s.live
```

### RequestApprovalFold.judgments_do_not_consume

Type SHA-256: `09e588b05dd8162ce541b9e7ec631c26968d1a203555ee8747cdee68035addf8`.

```lean
theorem judgments_do_not_consume (s : State) (tx : JudgmentTx) :
 (afterJudgment s tx).live = s.live ∧ (afterJudgment s tx).claims = s.claims ∧ (afterJudgment s tx).cage = s.cage
```

### RequestApprovalFold.exits_remove_consumed

Type SHA-256: `1d726d3729978ac4655a9ae237bba02e79648cb7f0bf837c689b587b6eb0be5c`.

```lean
theorem exits_remove_consumed (s : State) (o : RequestOutput) : o ∉ (afterExit s o).live
```

### RequestApprovalFold.fold_removes_consumed

Type SHA-256: `cb5baf676ddb877a89fff0a5db73aba80b02871621cce555492ee7cca403f041`.

```lean
theorem fold_removes_consumed (s : State) (tx : FoldTx) (o : RequestOutput) : o ∈ tx.requests → o ∉ (afterFold s tx).live
```

### RequestApprovalFold.used_seeds_monotone

Type SHA-256: `650fb4b60224a690b07fcee76d63a3071c8699d406eea719e306ed5a04d07cb5`.

```lean
theorem used_seeds_monotone {s s' : State} {a : Action} : Step s a s' → ∀ seed ∈ s.usedSeeds, seed ∈ s'.usedSeeds
```

### RequestApprovalFold.reachable_requests_have_spent_seeds

Type SHA-256: `bd9867af5cd6999481895d699c679b46e523c6ec571f5157f050d10057cab392`.

```lean
theorem reachable_requests_have_spent_seeds (s : State) : Reachable s → s.cage.oracles ≠ [] →
 ∀ o ∈ s.live, o.request.seed ∈ s.usedSeeds
```

### RequestApprovalFold.spent_seed_cannot_create_again

Type SHA-256: `446066011a0664917cd184390c39f72f64e57f3747af124ef6b8c951840cb64c`.

```lean
theorem spent_seed_cannot_create_again (s : State) (tx : CreateTx) (o : RequestOutput) :
 s.cage.oracles ≠ [] → o.request.seed ∈ s.usedSeeds → ¬ ∃ s', Step s (.create tx o) s'
```

### RequestApprovalFold.request_never_reappears

Type SHA-256: `bc2c68c97087e4953eae788eb9581d7801141c620b161b5e8117d385cad1b05c`.

```lean
theorem request_never_reappears (s s' : State) (o : RequestOutput) :
 Reachable s → o.ref ∈ s.usedOutputs → o ∉ s.live → History s s' → o ∉ s'.live
```

### RequestApprovalFold.one_oracle_signature_suffices

Type SHA-256: `c108b1a8c09dede4eb9438969a1041f9261b51741cb7f8231d2a14a488974edc`.

```lean
theorem one_oracle_signature_suffices (c : CageState) (r : Request) (oracle : Oracle)
 (e : Selection) (sigs : List Signer) : c.oracles = [oracle] →
 (e oracle).authorized oracle → (e oracle).approve = true → (e oracle).signers = sigs →
 hasApproval c r [] sigs e
```

### RequestApprovalFold.old_operations_correspond

Type SHA-256: `83dd3652281eeda5560a8360f1a9914c3b6963c9ddc6ccc64d0f1c9fd444e8ea`.

```lean
theorem old_operations_correspond (op : OldOperation) (t : Trie) :
    op.write.apply t = op.apply t ∧
      (match op with
       | .insert k _ => op.condition.holds t ↔ t k = none
       | .delete k v => op.condition.holds t ↔ t k = some v
       | .update k v _ => op.condition.holds t ↔ t k = some v)
```

### RequestApprovalFold.live_removal_is_legal_exit

Type SHA-256: `f7887e931a61e64d006436fa7350046aa1db5381103ea12eb82a92f53d576abc`.

```lean
theorem live_removal_is_legal_exit {s s' : State} {a : Action} (o : RequestOutput) :
 Step s a s' → o ∈ s.live → o ∉ s'.live →
 ∃ spend, a.spend = some spend ∧ requestSpendAllowed o spend ∧
 (match spend with
 | .folded tx => s' = afterFold s tx ∧ tx.cageIn = s.cage ∧
     (∀ input ∈ tx.requests, input ∈ s.live) ∧ (∀ claim ∈ tx.claims, claim ∈ s.claims) ∧
     (∀ name ∈ tx.refs, name ∈ s.judgments)
 | .withdrawn tx => s' = afterExit s tx.input)
```

### RequestApprovalFold.new_judgment_is_authorized

Type SHA-256: `a43a99b070d8be15c0c076611ce05a78eca92dbee1a0d6f0a4d86f931c27200d`.

```lean
theorem new_judgment_is_authorized {s s' : State} {a : Action} (name : TokenName) :
 Step s a s' → name ∈ s'.issued → name ∉ s.issued →
 ∃ tx, a = .judge tx ∧ tx.cageRef = s.cage ∧ tx.requestRef ∈ s.live ∧ judgmentAllowed tx ∧ name ∈ tx.minted
```

### RequestApprovalFold.exit_time_window

Type SHA-256: `650c21a9ae28d2cfbb1b1b114ebc066f224621ca2cc84fb718c4e974cefe5e04`.

```lean
theorem exit_time_window (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → ∀ kind, spend.exitsAs o kind → exitAt o spend.interval kind
```

### RequestApprovalFold.exit_windows_cover

Type SHA-256: `d43117ff85e374c2c9e1c7dc95316da580a268a739b1bc9bfedcd5ea6fd91c42`.

```lean
theorem exit_windows_cover (o : RequestOutput) (now : Time) :
 exitAt o ⟨now, now⟩ .write ∨ exitAt o ⟨now, now⟩ .account ∨ exitAt o ⟨now, now⟩ .withdraw
```

### RequestApprovalFold.exit_kind_unique

Type SHA-256: `fcd3cb0b0d092286d7a5b0b174c410661d12e58b6bcb74d7f75ad131ecee3b47`.

```lean
theorem exit_kind_unique (o : RequestOutput) (a b : RequestSpend) (ka kb : ExitKind) :
 requestSpendAllowed o a → requestSpendAllowed o b → a.interval = b.interval →
 a.exitsAs o ka → b.exitsAs o kb → ka = kb
```

### RequestApprovalFold.fold_references_authentic

Type SHA-256: `a7a997afe42cd6e4cf70183ee6054d36f197de1537d915cc333ba4ee4731c413`.

```lean
theorem fold_references_authentic {s s' : State} (tx : FoldTx) :
 Step s (.fold tx) s' → tx.cageIn = s.cage ∧ (∀ o ∈ tx.requests, o ∈ s.live) ∧
 (∀ o ∈ tx.claims, o ∈ s.claims) ∧ ∀ name ∈ tx.refs, name ∈ s.judgments
```

### RequestApprovalFold.account_references_authentic

Type SHA-256: `0590bc2e646597a3157b20562e4fb064ffba455071cfb36e913a73b8da59f2a3`.

```lean
theorem account_references_authentic {s s' : State} (tx : FoldTx) (n : Nat) (o : RequestOutput) (e : Selection) :
 Step s (.fold tx) s' → tx.items[n]? = some (FoldItem.account o e) →
 ∀ oracle ∈ s.cage.oracles, (e oracle).name s.cage.id o.request oracle ∈ s.judgments
```

### RequestApprovalFold.creation_references_source

Type SHA-256: `fe50387cfd9b8d0d37dc55221b7226109e1ab4082eb6a550414749f8e543283a`.

```lean
theorem creation_references_source {s s' : State} (tx : CreateTx) (o : RequestOutput) :
 Step s (.create tx o) s' → tx.cageRef = s.cage ∧ o.request.cage = s.cage.id
```

### RequestApprovalFold.fold_payments_concrete

Type SHA-256: `ccdc35956fbda6d5bf7693518c54189436c3c395e6a41aa3024d154b44ccb8ec`.

```lean
theorem fold_payments_concrete (tx : FoldTx) (n : Nat) (o : RequestOutput) (e : Selection) :
 foldAccepted tx → tx.items[n]? = some (FoldItem.write o e) →
 (itemResult (atTurn tx n) (FoldItem.write o e)).balances =
 (fun k => (atTurn tx n).balances k + OracleIdentity.paidTo (credits (atTurn tx n) o.request e) k) ∧
 itemPayments (atTurn tx n) tx.folder (FoldItem.write o e) =
 [⟨tx.folder, "", o.value - (tx.cageIn.oracles.map fun oracle =>
 ((o.request.fees.find? (fun p => p.1 == oracle)).map Prod.snd).getD 0).sum⟩]
```

### RequestApprovalFold.account_payments_concrete

Type SHA-256: `3c902a537952261961ee732211b092e97bebfd1e72423a35247a127dfedb5675`.

```lean
theorem account_payments_concrete (tx : FoldTx) (n : Nat) (o : RequestOutput) (e : Selection) :
 foldAccepted tx → tx.items[n]? = some (FoldItem.account o e) →
 (itemResult (atTurn tx n) (FoldItem.account o e)).balances =
 (fun k => (atTurn tx n).balances k + OracleIdentity.paidTo (credits (atTurn tx n) o.request e) k) ∧
 itemPayments (atTurn tx n) tx.folder (FoldItem.account o e) =
 [⟨o.request.owner, "", o.value - (tx.cageIn.oracles.map fun oracle =>
 ((o.request.fees.find? (fun p => p.1 == oracle)).map Prod.snd).getD 0).sum⟩]
```

### RequestApprovalFold.creation_funds_declared_fees

Type SHA-256: `5f25baf3c0f91900089f4350f92de3f55085ad9dcfc36c9b9db476f6e16262a3`.

```lean
theorem creation_funds_declared_fees {s s' : State} (tx : CreateTx) (o : RequestOutput) :
 Step s (.create tx o) s' → (s.cage.oracles.map fun oracle =>
 ((o.request.fees.find? (fun p => p.1 == oracle)).map Prod.snd).getD 0).sum + s.cage.minimum ≤ o.value
```

### RequestApprovalFold.burn_removes_one

Type SHA-256: `17662b067d5ccb54c57d4892a7575d65cecca0b6a7e255b0ecd2863421729613`.

```lean
theorem burn_removes_one {s s' : State} (name : TokenName) : Step s (.burn name) s' →
 s'.judgments.count name + 1 = s.judgments.count name ∧ s'.judgments = s.judgments.erase name
```

### RequestApprovalFold.burn_keeps_history

Type SHA-256: `128d238aca93f772b8b9c7f4ea61f8666e0f42678a591c75bbb205c326133841`.

```lean
theorem burn_keeps_history {s s' : State} (name : TokenName) : Step s (.burn name) s' → s'.issued = s.issued
```

### RequestApprovalFold.fold_requests_unique

Type SHA-256: `62d5ecd826c05808614adee1dfc16ce6b229b07358958c9032f8e4da5ef9dafe`.

```lean
theorem fold_requests_unique (tx : FoldTx) : foldAccepted tx →
 (tx.requests.map RequestOutput.ref ++ tx.claims.map ClaimOutput.ref).Nodup ∧ tx.requests.Nodup ∧ tx.claims.Nodup
```

### RequestApprovalFold.account_accepts_any_verdicts

Type SHA-256: `663e3b0418c940497ef72e272625e458c4b192b3dfa9bb4d904d655e9a0853f2`.

```lean
theorem account_accepts_any_verdicts (s : State) (o : RequestOutput) (e : Selection)
 (iv : Interval) (who : Signer) : o ∈ s.live → wellFormed s.cage o → iv.valid →
 o.request.deadline ≤ iv.lower → iv.upper ≤ o.request.deadline + o.request.window →
 (∀ oracle ∈ s.cage.oracles, (e oracle).authorized oracle ∧
   (e oracle).name s.cage.id o.request oracle ∈ s.judgments) →
 Step s (.fold (singletonFold s iv [] (FoldItem.account o e) who))
 (afterFold s (singletonFold s iv [] (FoldItem.account o e) who))
```

### RequestApprovalFold.equivocation_reachable

Type SHA-256: `deea27ca3141733a5a25a54e909fdd0e18329d9fe33f045a6a56e70486cc8fea`.

```lean
theorem equivocation_reachable : ∃ (s : State) (o : RequestOutput) (oracle : Oracle)
 (rec : SigningRecord) (cs : List Condition),
 Reachable s ∧ o ∈ s.live ∧ o.request.cage = s.cage.id ∧ oracle ∈ s.cage.oracles ∧
 judgmentName s.cage.id o.request oracle true rec cs ∈ s.judgments ∧
 judgmentName s.cage.id o.request oracle false rec [] ∈ s.judgments ∧
 judgmentName s.cage.id o.request oracle true rec cs ∈ s.issued ∧
 judgmentName s.cage.id o.request oracle false rec [] ∈ s.issued
```

### RequestApprovalFold.tag_name_injective

Type SHA-256: `e24d15a970802cab37167b4a480f4d9ca67c9a3406e349234b76084b6c15eb4c`.

```lean
theorem tag_name_injective (a b : Oracle) : tagName a = tagName b ↔ a = b
```

### RequestApprovalFold.price_name_injective

Type SHA-256: `23c4ff5fd194d03eeefdbf6730ca49a5ec616f53d77535aba03ba33e248a0373`.

```lean
theorem price_name_injective (a b : Oracle) : priceName a = priceName b ↔ a = b
```

### RequestApprovalFold.different_roles_never_coincide

Type SHA-256: `f203c019db48a1d6030f4fe5199e271656bdc06ea8f6ffc128ab5d6238f40d39`.

```lean
theorem different_roles_never_coincide (a b : TokenRole) (x y : NameBinding) : a ≠ b → tokenName a x ≠ tokenName b y
```

### RequestApprovalFold.names_have_leading_roles

Type SHA-256: `e3080689485deb431f2d4e724e9e8538812288f4f58edecda2a367cc44efea27`.

```lean
theorem names_have_leading_roles (c : CageId) (r : Request) (o : Oracle) (rec : SigningRecord) (cs : List Condition) :
 (tagName o).role = .tag ∧ (priceName o).role = .price ∧
 (judgmentName c r o true rec cs).role = .approval ∧
 (judgmentName c r o false rec cs).role = .refusal ∧
 (requestName c).role = .request ∧ (claimName c).role = .claim
```

### RequestApprovalFold.reachable_registry_valid

Type SHA-256: `4aeb0371d851a277fd311d6029c474a862d7516733790baf6af1dd990f1cede6`.

```lean
theorem reachable_registry_valid (s : State) : Reachable s → RegistryValid s.cage
```

### RequestApprovalFold.reachable_live_tags

Type SHA-256: `499af749308971156ccbd828581366c21bf745d1d7c13c801fe0e7167be075aa`.

```lean
theorem reachable_live_tags (s : State) : Reachable s → ∀ o ∈ s.live,
 o.request.cage = s.cage.id ∧ o.tags = s.cage.oracles.map tagName
```

### RequestApprovalFold.reachable_tags_unique

Type SHA-256: `be1906bfe96f8f95ccbb5dcae0ad1afabf873291f3255397bbf15ceac77f2564`.

```lean
theorem reachable_tags_unique (s : State) (o : RequestOutput) : Reachable s → o ∈ s.live →
 o.tags.Nodup ∧ ∀ oracle ∈ s.cage.oracles, o.tags.count (tagName oracle) = 1
```

### RequestApprovalFold.discovery_iff

Type SHA-256: `2d2038375dcb26437cb6c35fe4a6f9fcf3a3669d9fdfcb3070231e11e0f3a0de`.

```lean
theorem discovery_iff (s : State) (oracle : Oracle) (o : RequestOutput) : Reachable s →
 (o ∈ discover oracle s.live ↔ o ∈ s.live ∧ oracle ∈ s.cage.oracles)
```

### RequestApprovalFold.discovery_across_registries

Type SHA-256: `8f21ad3e80d607de749fe1aa1819e047b40310763b1fa42967a30d2a393caa0b`.

```lean
theorem discovery_across_registries (states : List State) (oracle : Oracle) (o : RequestOutput) :
 (∀ s ∈ states, Reachable s) →
 (o ∈ discover oracle (states.flatMap State.live) ↔ ∃ s ∈ states, o ∈ s.live ∧ oracle ∈ s.cage.oracles)
```

### RequestApprovalFold.live_removal_burns_oracle_tags

Type SHA-256: `37fbd5fa00a1aa31c19497ca535b3d6255210dc142aaf7a689f350f11c33431c`.

```lean
theorem live_removal_burns_oracle_tags {s s' : State} {a : Action} (o : RequestOutput) :
 Reachable s → Step s a s' → o ∈ s.live → o ∉ s'.live →
 ∃ spend, a.spend = some spend ∧ requestSpendAllowed o spend ∧ ∀ oracle ∈ s.cage.oracles, tagName oracle ∈ spend.burned
```

### RequestApprovalFold.price_mint_inversion

Type SHA-256: `5601738b38344975b0541af48629d6abbc413991bd4986746cec2ff47254c597`.

```lean
theorem price_mint_inversion {s s' : State} (tx : PriceMintTx) : Step s (.priceMint tx) s' →
 (OracleIdentity.authorize tx.output.oracle tx.description tx.signers).isSome = true ∧
 tx.output.token = ⟨.price, .oracle tx.output.oracle⟩ ∧ tx.minted = [tx.output.token] ∧
 s'.notices = tx.output :: s.notices
```

### RequestApprovalFold.price_update_inversion

Type SHA-256: `9adb839af732f3a4e71524abc1df61bea9efeb81c5882676a769e37d17d22303`.

```lean
theorem price_update_inversion {s s' : State} (tx : PriceUpdateTx) : Step s (.priceUpdate tx) s' →
 tx.input ∈ s.notices ∧ (OracleIdentity.authorize tx.input.oracle tx.description tx.signers).isSome = true ∧
 tx.input.token = ⟨.price, .oracle tx.input.oracle⟩ ∧ tx.output.oracle = tx.input.oracle ∧
 tx.output.token = tx.input.token ∧ tx.minted = [] ∧ s'.notices = tx.output :: s.notices.erase tx.input
```

### RequestApprovalFold.reachable_notice_names

Type SHA-256: `ba1f063c0d1e165399dc6cd52e311b3bee0353e9d5f062bc6f5840e012c64dfb`.

```lean
theorem reachable_notice_names (s : State) : Reachable s → ∀ n ∈ s.notices, n.token = ⟨.price, .oracle n.oracle⟩
```

### RequestApprovalFold.price_mint_available

Type SHA-256: `14cd6a2104cd0ec1dbba680d926196f05834d987d8467d5b9948aa3c5da762a3`.

```lean
theorem price_mint_available (s : State) (oracle : Oracle) (d : OracleIdentity.Description)
 (sigs : List Signer) (datum : PriceDatum) :
 (OracleIdentity.authorize oracle d sigs).isSome = true →
 let tx : PriceMintTx := ⟨⟨oracle, priceName oracle, datum⟩, d, sigs, [priceName oracle]⟩
 Step s (.priceMint tx) (afterPriceMint s tx)
```

### RequestApprovalFold.price_update_available

Type SHA-256: `0183b3ccf2abcba6120e5f53d1ab9daf72ddf2fae103a20f17e53dd8c6a9b37e`.

```lean
theorem price_update_available (s : State) (n : PriceNotice) (d : OracleIdentity.Description)
 (sigs : List Signer) (datum : PriceDatum) : n ∈ s.notices → n.token = priceName n.oracle →
 (OracleIdentity.authorize n.oracle d sigs).isSome = true →
 let tx : PriceUpdateTx := ⟨n, { n with datum := datum }, d, sigs, []⟩
 Step s (.priceUpdate tx) (afterPriceUpdate s tx)
```

### RequestApprovalFold.price_notice_noninterference

Type SHA-256: `a53e95a6515761be7675d6fbbb90031d7f126495470f7f68c6d18bf295a55feb`.

```lean
theorem price_notice_noninterference {s s' : State} {a : Action} : Step s a s' → a.isPrice = true →
 s'.cage = s.cage ∧ s'.live = s.live ∧ s'.claims = s.claims ∧ s'.judgments = s.judgments ∧
 s'.issued = s.issued ∧ s'.usedSeeds = s.usedSeeds ∧ s'.usedOutputs = s.usedOutputs ∧
 a.payments = [] ∧ a.spend = none
```

### RequestApprovalFold.notices_do_not_bind_protocol

Type SHA-256: `f9794aa1d89b2b1646234e3ae19f80ec0d9b34a6f954c57bce1248243d82e021`.

```lean
theorem notices_do_not_bind_protocol {s s' : State} {a : Action} (notices : List PriceNotice) :
 Step s a s' → a.isPrice = false →
 Step { s with notices := notices } a { s' with notices := notices }
```

### RequestApprovalFold.notice_change_authorized

Type SHA-256: `5ef9c2cae486bf81c47b5bb9d6cebb70d54fcf0162fc14b7237f51e8db4dc120`.

```lean
theorem notice_change_authorized {s s' : State} {a : Action} (n : PriceNotice) :
 Step s a s' → n ∈ s'.notices → n ∉ s.notices →
 (∃ tx, a = .priceMint tx ∧ tx.output = n ∧
 (OracleIdentity.authorize n.oracle tx.description tx.signers).isSome = true) ∨
 (∃ tx, a = .priceUpdate tx ∧ tx.input ∈ s.notices ∧ tx.output = n ∧ tx.input.oracle = n.oracle ∧
 (OracleIdentity.authorize n.oracle tx.description tx.signers).isSome = true)
```

### RequestApprovalFold.creation_rule_and_token

Type SHA-256: `7028afd727473723d37c45222a847bb99bc7382e4f99ba12a3271aa4949ba3bc`.

```lean
theorem creation_rule_and_token (tx : CreateTx) (o : RequestOutput) : createAllowed tx o →
 ruleAdmits tx.cageRef o.request tx.signers ∧ tx.outputs = [o] ∧
 o.request.cage = tx.cageRef.id ∧ o.requestTokens = [requestName tx.cageRef.id] ∧
 o.policy = requestPolicy tx.cageRef ∧ tx.policy = requestPolicy tx.cageRef ∧
 tx.minted = tx.cageRef.oracles.map tagName ++ [requestName tx.cageRef.id] ∧
 totalFees tx.cageRef o.request + tx.cageRef.minimum ≤ o.value
```

### RequestApprovalFold.step_rule_immutable

Type SHA-256: `c53b083e62231eaa663cd107eb9dc3cfece7b014cd484cfa18e3efc0b6d073a2`.

```lean
theorem step_rule_immutable {s s' : State} {a : Action} : Step s a s' → s'.cage.rule = s.cage.rule
```

### RequestApprovalFold.history_rule_immutable

Type SHA-256: `dec13f60c85041c072611425d43dda150a41915b402dedd7b6c2a7a287099b1a`.

```lean
theorem history_rule_immutable {s s' : State} : History s s' → s'.cage.rule = s.cage.rule
```

### RequestApprovalFold.reachable_rule_admitted

Type SHA-256: `181bc9dea584741a218dd4246196dd66f1004afa24f98f8e5a5c316ef63ea748`.

```lean
theorem reachable_rule_admitted (s : State) : Reachable s → ∀ o ∈ s.live,
 ∃ sigs, ruleAdmits s.cage o.request sigs
```

### RequestApprovalFold.every_rule_allows_burn

Type SHA-256: `5c10d3ad6064180b697c664c5d378c5eecb8139d6ec355ba2f412f5740b77684`.

```lean
theorem every_rule_allows_burn (s : State) (rule : Rule) : s.cage.rule = some rule →
 (∀ tx, tx.cageIn = s.cage → (∀ o ∈ tx.requests, o ∈ s.live) →
 (∀ o ∈ tx.claims, o ∈ s.claims) → (∀ name ∈ tx.refs, name ∈ s.judgments) →
 tx.interval.valid → (tx.requests.map RequestOutput.ref ++ tx.claims.map ClaimOutput.ref).Nodup →
 tx.burned = tx.items.flatMap FoldItem.burned → tx.payments = foldPayments tx.cageIn tx.folder tx.items →
 FoldRun tx.interval tx.refs tx.signers tx.cageIn tx.items tx.cageOut →
 Step s (.fold tx) (afterFold s tx)) ∧
 (∀ tx : WithdrawTx, tx.input ∈ s.live → tx.interval.valid →
 tx.input.request.deadline + tx.input.request.window < tx.interval.lower →
 tx.input.request.owner ∈ tx.signers → tx.burned = tokensOf tx.input →
 tx.beneficiary = tx.input.request.owner → tx.paid = tx.input.value →
 Step s (.withdraw tx) (afterExit s tx.input)) ∧
 (∀ name ∈ s.judgments, Step s (.burn name) (afterBurn s name))
```

### RequestApprovalFold.creation_rule_input_binding

Type SHA-256: `1ed2a337f6684be77807a58b2e6f6c3a6b15c61b306129def193e757425eaca3`.

```lean
theorem creation_rule_input_binding {s s' : State} {tx : CreateTx} {o : RequestOutput} (rule : Rule) :
 Step s (.create tx o) s' → s.cage.rule = some rule →
 tx.outputs = [o] ∧ o ∈ s'.live ∧ rule.admits o.request tx.signers
```

### RequestApprovalFold.creation_request_policy

Type SHA-256: `b84d611ce090010ed8a0682cd1103297500e62789262980edfa2d99cec045f3e`.

```lean
theorem creation_request_policy {s s' : State} {tx : CreateTx} {o : RequestOutput} :
 Step s (.create tx o) s' → tx.outputs = [o] ∧
 o.requestTokens = [requestName s.cage.id] ∧
 tx.minted = s.cage.oracles.map tagName ++ [requestName s.cage.id] ∧
 (match s.cage.rule with
 | some rule => tx.policy = .rule rule.hash ∧ o.policy = .rule rule.hash ∧ tx.policy ≠ .release ∧ o.policy ≠ .release
 | none => tx.policy = .release ∧ o.policy = .release)
```

### RequestApprovalFold.fold_rule_predicate_independent

Type SHA-256: `6e9e1691b547c24408cdd399b525dea2ad99eb854890ffc27577ab82c345069c`.

```lean
theorem fold_rule_predicate_independent (c : CageState) (hash : String) (p q : Request → List Signer → Prop)
 (iv : Interval) (refs : List TokenName) (sigs : List Signer) (i : FoldItem) :
 itemAllowed { c with rule := some ⟨hash, p⟩ } iv refs sigs i ↔
 itemAllowed { c with rule := some ⟨hash, q⟩ } iv refs sigs i
```

### RequestApprovalFold.reachable_request_tokens

Type SHA-256: `ca3a4cf358259d5f5f4e080e1c167984df42a03a3119af97c066fa13d611f7f0`.

```lean
theorem reachable_request_tokens (s : State) : Reachable s → ∀ o ∈ s.live,
 o.requestTokens = [requestName s.cage.id] ∧ o.policy = requestPolicy s.cage
```

### RequestApprovalFold.fold_requires_request_token

Type SHA-256: `7dac24860e96a722d33b04210021d306df8458b00efa829023f5a9ca223dab9b`.

```lean
theorem fold_requires_request_token (tx : FoldTx) : foldAccepted tx → ∀ o ∈ tx.requests,
 o.requestTokens = [requestName tx.cageIn.id] ∧ o.policy = requestPolicy tx.cageIn
```

### RequestApprovalFold.every_exit_burns_request_token

Type SHA-256: `db9fadc0b18497930f785ea03ac2c62c5ee5aaee507f1c7de959b01f3c581824`.

```lean
theorem every_exit_burns_request_token (o : RequestOutput) (spend : RequestSpend) :
 requestSpendAllowed o spend → ∀ token ∈ o.requestTokens, token ∈ spend.burned
```

### RequestApprovalFold.live_removal_burns_request_token

Type SHA-256: `b212cc811863d8d75a47210a209fb25e3064d8b9e70dbaefea643c8fd85fffca`.

```lean
theorem live_removal_burns_request_token {s s' : State} {a : Action} (o : RequestOutput) :
 Reachable s → Step s a s' → o ∈ s.live → o ∉ s'.live →
 ∃ spend, a.spend = some spend ∧ requestSpendAllowed o spend ∧ requestName s.cage.id ∈ spend.burned
```

### RequestApprovalFold.request_name_injective

Type SHA-256: `fd94e6fb3968ffebcb839c02e6f6ca9972d9a4df54aaab24ca0e85a69786067e`.

```lean
theorem request_name_injective (a b : CageId) : requestName a = requestName b ↔ a = b
```

### RequestApprovalFold.request_token_discovery

Type SHA-256: `2b7cd322890f187ca37717498fad2a0d5d79b3a6ee9970c8771cf42b2849501f`.

```lean
theorem request_token_discovery (s : State) (id : CageId) (o : RequestOutput) : Reachable s →
 (o ∈ discoverRequests id s.live ↔ o ∈ s.live ∧ s.cage.id = id)
```

### RequestApprovalFold.request_token_discovery_across_registries

Type SHA-256: `dc2ee4ae4a52d843de6dac89a626538aa71389fd07798a01ec0b1020f5478909`.

```lean
theorem request_token_discovery_across_registries (states : List State) (id : CageId) (o : RequestOutput) :
 (∀ s ∈ states, Reachable s) →
 (o ∈ discoverRequests id (states.flatMap State.live) ↔ ∃ s ∈ states, o ∈ s.live ∧ s.cage.id = id)
```

### RequestApprovalFold.output_refs_monotone

Type SHA-256: `627a54ce6adca37de4eb131bb557a8822c811a76394833a5b32080daf406c112`.

```lean
theorem output_refs_monotone {s s' : State} {a : Action} : Step s a s' → ∀ ref ∈ s.usedOutputs, ref ∈ s'.usedOutputs
```

### RequestApprovalFold.reachable_output_refs

Type SHA-256: `1673b9012b8e44bb1ca2532fd7cfaf6398bbbde758e9964a6518ca92f23df0ee`.

```lean
theorem reachable_output_refs (s : State) : Reachable s →
 (∀ o ∈ s.live, o.ref ∈ s.usedOutputs) ∧ (∀ o ∈ s.claims, o.ref ∈ s.usedOutputs)
```

### RequestApprovalFold.reachable_output_refs_unique

Type SHA-256: `8192fca16cc176b7c9df8ee14bb145652f5f591166842209847542136c09cb7e`.

```lean
theorem reachable_output_refs_unique (s : State) : Reachable s →
 (s.live.map RequestOutput.ref ++ s.claims.map ClaimOutput.ref).Nodup
```

### RequestApprovalFold.unguarded_registry_impossible

Type SHA-256: `43c3c83959cf0aed0f7de3762e67ccadbab8bfcc60023bca5010178e4220cea8`.

```lean
theorem unguarded_registry_impossible (c : CageState) (existing : List CageId) :
 c.oracles = [] → c.rule = none → ¬ registryCreated c existing
```

### RequestApprovalFold.zero_oracle_needs_rule

Type SHA-256: `2acb2ea9d6475057401855551322e6d5db5432c832cd28f8360acab2e9d4e14c`.

```lean
theorem zero_oracle_needs_rule (c : CageState) (existing : List CageId) :
 registryCreated c existing → c.oracles = [] → ∃ rule, c.rule = some rule
```

### RequestApprovalFold.zero_oracle_evidence_empty

Type SHA-256: `83354ae2edc6634bea656628ff5ef64780931ec5f511cbc494660077ef85df3c`.

```lean
theorem zero_oracle_evidence_empty (c : CageState) (r : Request) (e : Selection) :
 c.oracles = [] → hasApproval c r [] [] e ∧ hasAccount c r [] e
```

### RequestApprovalFold.zero_oracle_creation_without_seed

Type SHA-256: `6a41f8250f62b61c8426e27682f8c933eca41666643e3e3b19412e261a473a16`.

```lean
theorem zero_oracle_creation_without_seed (c : CageState) (o : RequestOutput) (sigs : List Signer) :
 c.oracles = [] → wellFormed c o → ruleAdmits c o.request sigs →
 createAllowed ⟨[], c, [requestName c.id], [o], sigs, requestPolicy c⟩ o
```

### RequestApprovalFold.zero_oracle_fold_without_approvals

Type SHA-256: `cca99800bdd3231dccb597f5d39318acf1042d47311aa3077e9e73162ae67a5f`.

```lean
theorem zero_oracle_fold_without_approvals (c : CageState) (o : RequestOutput) (iv : Interval) (e : Selection) :
 c.oracles = [] → wellFormed c o → iv.valid → iv.upper < o.request.deadline →
 (∀ condition ∈ o.request.conditions, condition.holds c.trie) →
 FoldRun iv [] [] c [FoldItem.write o e] (itemResult c (FoldItem.write o e)) ∧
 (itemResult c (FoldItem.write o e)).trie = o.request.write.apply c.trie
```

### RequestApprovalFold.zero_oracle_account_without_verdicts

Type SHA-256: `cb961de35c14ce62a0a00292da9949cd0d92d79df34a4e3cbb098d59f8ab51c1`.

```lean
theorem zero_oracle_account_without_verdicts (s : State) (o : RequestOutput) (iv : Interval) (e : Selection) :
 s.cage.oracles = [] → o ∈ s.live → wellFormed s.cage o → iv.valid →
 o.request.deadline ≤ iv.lower → iv.upper ≤ o.request.deadline + o.request.window →
 Step s (.fold (singletonFold s iv [] (FoldItem.account o e) o.request.owner))
 (afterFold s (singletonFold s iv [] (FoldItem.account o e) o.request.owner))
```

### RequestApprovalFold.present_condition_semantics

Type SHA-256: `f6eaef037c97dbdf0699ec8b3be6c2ad3c912e6c7a778dbf4348f0c1dbe9cbac`.

```lean
theorem present_condition_semantics (t : Trie) (k : Key) : Condition.holds t (.present k) ↔ ∃ v, t k = some v
```

### RequestApprovalFold.foldRun_oracle_conditions

Type SHA-256: `92abc7be7ac841ac1c6b7f7094ba49e012cf730705ebd5da9ba65390915a1ed7`.

```lean
theorem foldRun_oracle_conditions {iv : Interval} {refs : List TokenName} {sigs : List Signer}
 {c out : CageState} {items : List FoldItem} : FoldRun iv refs sigs c items out →
 ∀ n o e, items[n]? = some (FoldItem.write o e) → ∀ oracle ∈ c.oracles,
 ∀ condition ∈ (e oracle).conditions, condition.holds (foldResult c (items.take n)).trie
```

### RequestApprovalFold.fold_all_conditions_hold

Type SHA-256: `5eb65c79175c73699c4d2de8bdf3e9a22e0654afebfe9cfc63f879afa4d643ef`.

```lean
theorem fold_all_conditions_hold (tx : FoldTx) : foldAccepted tx → ∀ n o e,
 tx.items[n]? = some (FoldItem.write o e) →
 (∀ condition ∈ o.request.conditions, condition.holds (atTurn tx n).trie) ∧
 (∀ oracle ∈ tx.cageIn.oracles, ∀ condition ∈ (e oracle).conditions, condition.holds (atTurn tx n).trie)
```

### RequestApprovalFold.approval_conditions_cannot_change

Type SHA-256: `0ff108f18496543dc38726875e9a754e591e1e1579bdc71805cc164fddf10e98`.

```lean
theorem approval_conditions_cannot_change (c : CageId) (r : Request) (o : Oracle)
 (rec rec' : SigningRecord) (a b : List Condition) :
 judgmentName c r o true rec a = judgmentName c r o true rec' b ↔ rec = rec' ∧ a = b
```

### RequestApprovalFold.stale_approval_unusable

Type SHA-256: `f14b86a43303ec0117004c811bd501c11c8ee868350c41596a880ab443239629`.

```lean
theorem stale_approval_unusable (tx : FoldTx) (n : Nat) (o : RequestOutput) (e : Selection)
 (oracle : Oracle) (condition : Condition) : tx.items[n]? = some (FoldItem.write o e) →
 oracle ∈ tx.cageIn.oracles → condition ∈ (e oracle).conditions →
 ¬ condition.holds (atTurn tx n).trie → ¬ foldAccepted tx
```

### RequestApprovalFold.fold_evidence_binds_conditions

Type SHA-256: `0eb256b30e4b0d17dbaef63da7107cac78784f953fbc45aa2e88c33dc95ae247`.

```lean
theorem fold_evidence_binds_conditions {s s' : State} (tx : FoldTx) (n : Nat) (o : RequestOutput) (e : Selection) :
 Step s (.fold tx) s' → tx.items[n]? = some (FoldItem.write o e) → ∀ oracle ∈ s.cage.oracles,
 (e oracle).authorized oracle ∧ (e oracle).approve = true ∧
 (judgmentName s.cage.id o.request oracle true (e oracle).record (e oracle).conditions ∈ s.judgments ∨
 (e oracle).signers = tx.signers)
```

### RequestApprovalFold.expected_approval_lookup

Type SHA-256: `2cfc23bf16457f4cd13bd4d5d9f0af2ca34810042f77c476ac1dbedcfde923b0`.

```lean
theorem expected_approval_lookup (c : CageState) (r : Request) (e : Selection) (refs : List TokenName) :
 hasApproval c r refs [] e ↔
 (∀ oracle ∈ c.oracles, (e oracle).authorized oracle ∧ (e oracle).approve = true) ∧
 (∀ name ∈ expectedApprovals c r e, name ∈ refs)
```

### RequestApprovalFold.folder_discovery_exact

Type SHA-256: `27260c9ccb5a70fd445b1c5757c7547ea12b5881df89e2795e6eb4a1d4f90241`.

```lean
theorem folder_discovery_exact (s : State) (iv : Interval) (sigs : List Signer) (e : Selection) (o : RequestOutput) :
 Reachable s → (folderFinds s iv sigs e o ↔ o ∈ s.live ∧ stepValid s.cage iv s.judgments sigs e o)
```

### RequestApprovalFold.folder_discovery_executable

Type SHA-256: `5cdc630755bcf359a284c339353a39601f3e4638f2b641dab1de16cea7dc3e15`.

```lean
theorem folder_discovery_executable (s : State) (iv : Interval) (sigs : List Signer) (e : Selection) (o : RequestOutput) (folder : Signer) :
 Reachable s → (folderFinds s iv sigs e o ↔
 Step s (.fold (singletonFold s iv sigs (FoldItem.write o e) folder))
 (afterFold s (singletonFold s iv sigs (FoldItem.write o e) folder)))
```

### RequestApprovalFold.empty_fold_allowed

Type SHA-256: `3443eebb93237b6dd7fd2bf2312da37170d857241e9144bddb12bfe2bbae14e6`.

```lean
theorem empty_fold_allowed (s : State) (iv : Interval) (who : Signer) : iv.valid →
 let tx : FoldTx := ⟨s.cage, s.cage, [], [], [], iv, who, who, [], []⟩
 Step s (.fold tx) s
```

### RequestApprovalFold.empty_fold_earns_nothing

Type SHA-256: `c49362d1d63bd7e8258bdee353917bed81518327c0a7eda1ff9c71d067f1afcb`.

```lean
theorem empty_fold_earns_nothing (tx : FoldTx) : foldAccepted tx → tx.items = [] →
 tx.payments = [] ∧ tx.burned = [] ∧ tx.cageOut = tx.cageIn
```

### RequestApprovalFold.only_fold_changes_registry

Type SHA-256: `62a92bddd5e1e13fed668d6f9f225c38a35a3a66655c70c756e17ea6984a3ad6`.

```lean
theorem only_fold_changes_registry {s s' : State} {a : Action} : Step s a s' → s'.cage ≠ s.cage → ∃ tx, a = .fold tx
```

### RequestApprovalFold.reachable_balances_backed

Type SHA-256: `5f6114a1c3dd4259b10fe03c42750a8d02131c511d7c9fdee810047bfc21d7e1`.

```lean
theorem reachable_balances_backed (s : State) : Reachable s → Backed s.cage
```

### RequestApprovalFold.fold_value_conservation

Type SHA-256: `4dba5d71908d8b1b650502b2bae3d1c0041e0f735a71a1374231a0c310d38d14`.

```lean
theorem fold_value_conservation (s s' : State) (tx : FoldTx) : Reachable s → Step s (.fold tx) s' →
 s.cage.value + requestEscrows tx.items + claimEscrows tx.items =
 s'.cage.value + requestRemainders s.cage tx.items + claimPayouts s.cage tx.items + claimEscrows tx.items
```

### RequestApprovalFold.fold_request_conservation

Type SHA-256: `3c6813a95964cd1b9970f847688164c475c148d811d1e4f82ceed0c69733c92c`.

```lean
theorem fold_request_conservation (tx : FoldTx) : foldAccepted tx →
 requestEscrows tx.items = grossCredits tx.cageIn tx.items + requestRemainders tx.cageIn tx.items
```

### RequestApprovalFold.fold_balance_conservation

Type SHA-256: `fc409d8aa0aadb4aa63a3d9a38b5244f7d4b1f8579f5c4bc8b0ddcc328d96596`.

```lean
theorem fold_balance_conservation (s s' : State) (tx : FoldTx) : Reachable s → Step s (.fold tx) s' →
 balanceSum s.cage + grossCredits s.cage tx.items = balanceSum s'.cage + claimPayouts s.cage tx.items
```

### RequestApprovalFold.fold_payments_exact

Type SHA-256: `3e0da1cd4f87126578620c6ecf8167ab228e309f5f1d79903203012b5c39850c`.

```lean
theorem fold_payments_exact (tx : FoldTx) : foldAccepted tx →
 tx.payments = foldPayments tx.cageIn tx.folder tx.items ∧
 totalPaid tx.payments = requestRemainders tx.cageIn tx.items + claimPayouts tx.cageIn tx.items + claimEscrows tx.items
```

### RequestApprovalFold.group_credits_only_recorded_signers

Type SHA-256: `6078c0c877d0f71a7759dd4abe0810bfbc04c63e07407e06a4696ab668a942ff`.

```lean
theorem group_credits_only_recorded_signers (c : CageState) (r : Request) (o : Oracle) (e : Evidence) (k : Signer) :
 e.authorized o → k ∉ OracleIdentity.recordedKeys e.record → OracleIdentity.paidTo (oracleCredits r o e) k = 0
```

### RequestApprovalFold.group_credits_exact_split

Type SHA-256: `970da8af8f1d9a5f0d31defc301e2100de0246286ec47f76389c1b752519ccae`.

```lean
theorem group_credits_exact_split (r : Request) (o : Oracle) (e : Evidence) : e.authorized o →
 oracleCredits r o e = OracleIdentity.splitRecorded e.record (r.fee o)
```

### RequestApprovalFold.judgment_record_cannot_change

Type SHA-256: `1ef846b9c09e3aec4676e3b8d07eba6e3de50a0633903870b34c6a3b3ece434e`.

```lean
theorem judgment_record_cannot_change (c : CageId) (r : Request) (o : Oracle) (v : Bool)
 (a b : SigningRecord) (cs : List Condition) : judgmentName c r o v a cs = judgmentName c r o v b cs → a = b
```

### RequestApprovalFold.claim_creation_inversion

Type SHA-256: `7e27be115e2afa0ed5234cb419f5353595292b56b2139cb5fea981cf596ca0d1`.

```lean
theorem claim_creation_inversion {s s' : State} (tx : ClaimCreateTx) : Step s (.claimCreate tx) s' →
 tx.cageRef = s.cage ∧ tx.output.cage = s.cage.id ∧ tx.output.key ∈ registryKeys s.cage ∧
 tx.output.key ∈ tx.signers ∧ tx.output.tokens = [claimName s.cage.id] ∧
 tx.minted = tx.output.tokens ∧ tx.output.ref ∉ s.usedOutputs ∧ s' = afterClaimCreate s tx
```

### RequestApprovalFold.reachable_claim_authorization

Type SHA-256: `44d4a372347089eac48a99cb3c369dd10aae24608c5261952fb4f74f3a81d97e`.

```lean
theorem reachable_claim_authorization (c : CageState) (existing : List CageId)
 (events : List (State × Action × State)) (s : State) (o : ClaimOutput) :
 registryCreated c existing → Trace (initial c) events s → o ∈ s.claims →
 ∃ before after tx, (before, Action.claimCreate tx, after) ∈ events ∧
 Step before (.claimCreate tx) after ∧ tx.output = o ∧ o.key ∈ tx.signers
```

### RequestApprovalFold.claim_payout_fixed

Type SHA-256: `51e3f7145d8a2c68b947dc18f85a1d37e7795760b467b2ae1e0d1639e013172f`.

```lean
theorem claim_payout_fixed (tx : FoldTx) (n : Nat) (o : ClaimOutput) : foldAccepted tx →
 tx.items[n]? = some (FoldItem.claim o) →
 itemPayments (atTurn tx n) tx.folder (FoldItem.claim o) =
 [⟨o.destination, o.datum, (atTurn tx n).balances o.key⟩, ⟨tx.folder, "", o.value⟩] ∧
 (itemResult (atTurn tx n) (FoldItem.claim o)).balances o.key = 0 ∧
 (∀ k, k ≠ o.key → (itemResult (atTurn tx n) (FoldItem.claim o)).balances k = (atTurn tx n).balances k)
```

### RequestApprovalFold.claim_payout_in_actual_outputs

Type SHA-256: `10fa28cfdc8608101d5e20aeadc4e16f43adfccb1dd6c99af618c28e9c487447`.

```lean
theorem claim_payout_in_actual_outputs (tx : FoldTx) (n : Nat) (o : ClaimOutput) : foldAccepted tx →
 tx.items[n]? = some (FoldItem.claim o) → ⟨o.destination, o.datum, (atTurn tx n).balances o.key⟩ ∈ tx.payments
```

### RequestApprovalFold.claim_below_minimum_refused

Type SHA-256: `8c384ac83eed98586856701874ad2c1670874409b94756b1cdcd6afc84f04047`.

```lean
theorem claim_below_minimum_refused (c : CageState) (iv : Interval) (o : ClaimOutput) :
 c.balances o.key < c.minimum → ¬ claimAllowed c iv o
```

### RequestApprovalFold.claim_turn_balance

Type SHA-256: `9635592f4e177a21fe86aa11b6a6ea66c2f6f4a5334e18b8c7188b570c27fda5`.

```lean
theorem claim_turn_balance (c : CageState) (o : RequestOutput) (e : Selection) (claim : ClaimOutput) (folder : Signer) :
 itemPayments (itemResult c (FoldItem.write o e)) folder (FoldItem.claim claim) =
 [⟨claim.destination, claim.datum, c.balances claim.key + OracleIdentity.paidTo (credits c o.request e) claim.key⟩,
 ⟨folder, "", claim.value⟩]
```

### RequestApprovalFold.claim_consumed_and_burned

Type SHA-256: `b22556aa213c0ce1e17b28e9d06c49d5c4984354314328d5fb91c8fdb2d9c079`.

```lean
theorem claim_consumed_and_burned {s s' : State} (tx : FoldTx) (o : ClaimOutput) :
 Step s (.fold tx) s' → o ∈ tx.claims → o ∉ s'.claims ∧ ∀ token ∈ o.tokens, token ∈ tx.burned
```

### RequestApprovalFold.claim_withdrawal_inversion

Type SHA-256: `fdaf287de5b217b3effa382f61195290f24beb1d831092c5fef8431ba7c8d686`.

```lean
theorem claim_withdrawal_inversion {s s' : State} (tx : ClaimWithdrawTx) : Reachable s → Step s (.claimWithdraw tx) s' →
 tx.input ∈ s.claims ∧ tx.input.key ∈ tx.signers ∧ tx.input.deadline ≤ tx.interval.lower ∧
 tx.interval.valid ∧ tx.burned = tx.input.tokens ∧ tx.beneficiary = tx.input.key ∧ tx.paid = tx.input.value ∧
 s'.cage = s.cage ∧ tx.input ∉ s'.claims
```

### RequestApprovalFold.claim_withdrawal_available

Type SHA-256: `6c5c0c967193cc6a5fd453bc9b3ef15b8b057586031206488e2364475dacbeea`.

```lean
theorem claim_withdrawal_available (s : State) (o : ClaimOutput) (iv : Interval) :
 o ∈ s.claims → iv.valid → o.deadline ≤ iv.lower →
 let tx : ClaimWithdrawTx := ⟨o, iv, [o.key], o.tokens, o.key, o.value⟩
 Step s (.claimWithdraw tx) (afterClaimWithdraw s tx)
```

### RequestApprovalFold.claim_windows_disjoint

Type SHA-256: `072ce3952bd623ea8b5da19e65cbe83760c0053cf71dee733bf21d1426476227`.

```lean
theorem claim_windows_disjoint (c : CageState) (iv : Interval) (o : ClaimOutput) (tx : ClaimWithdrawTx) :
 claimAllowed c iv o → tx.input = o → tx.interval = iv → ¬ claimWithdrawAllowed tx
```

### RequestApprovalFold.claim_discovery_exact

Type SHA-256: `7363def96d84143aa401cad5346e18b83e62b4ba1238478121cdf4b3312d3a89`.

```lean
theorem claim_discovery_exact (s : State) (id : CageId) (o : ClaimOutput) : Reachable s →
 (o ∈ discoverClaims id s.claims ↔ o ∈ s.claims ∧ s.cage.id = id)
```

### RequestApprovalFold.request_withdrawal_preserves_registry

Type SHA-256: `401229cfe75e6c36fc102b47ecdc8d265e9d9ed31ff7e8a880c9f0a353f87b4e`.

```lean
theorem request_withdrawal_preserves_registry {s s' : State} (tx : WithdrawTx) : Step s (.withdraw tx) s' → s'.cage = s.cage
```

### RequestApprovalFold.fold_interval_fits_every_item

Type SHA-256: `1cfcb5d7f8e15d7cc6f6decc50e9a81d7e714b4e9a5ba6bfb81adc6d49bc0daa`.

```lean
theorem fold_interval_fits_every_item (tx : FoldTx) : foldAccepted tx → tx.interval.valid ∧
 (∀ o e, FoldItem.write o e ∈ tx.items → tx.interval.upper < o.request.deadline) ∧
 (∀ o e, FoldItem.account o e ∈ tx.items → o.request.deadline ≤ tx.interval.lower ∧
 tx.interval.upper ≤ o.request.deadline + o.request.window) ∧
 (∀ o, FoldItem.claim o ∈ tx.items → tx.interval.upper < o.deadline)
```

### RequestApprovalFold.step_inversion

Type SHA-256: `72f250708da553709cda7ce5aaeb6e7315372732fc05533e850afb350ac2c2ab`.

```lean
theorem step_inversion (s s' : State) (a : Action) : Step s a s' ↔
 (match a with
 | .create tx o => tx.cageRef = s.cage ∧ createAllowed tx o ∧
     (∀ seed ∈ tx.spent, seed ∉ s.usedSeeds) ∧ o.ref ∉ s.usedOutputs ∧ s' = afterCreate s tx o
 | .judge tx => tx.cageRef = s.cage ∧ tx.requestRef ∈ s.live ∧ judgmentAllowed tx ∧ s' = afterJudgment s tx
 | .fold tx => tx.cageIn = s.cage ∧ (∀ o ∈ tx.requests, o ∈ s.live) ∧
     (∀ o ∈ tx.claims, o ∈ s.claims) ∧ (∀ name ∈ tx.refs, name ∈ s.judgments) ∧
     foldAccepted tx ∧ s' = afterFold s tx
 | .withdraw tx => tx.input ∈ s.live ∧ withdrawAllowed tx ∧ s' = afterExit s tx.input
 | .burn name => name ∈ s.judgments ∧ s' = afterBurn s name
 | .priceMint tx => priceMintAllowed tx ∧ s' = afterPriceMint s tx
 | .priceUpdate tx => tx.input ∈ s.notices ∧ priceUpdateAllowed tx ∧ s' = afterPriceUpdate s tx
 | .claimCreate tx => tx.cageRef = s.cage ∧ claimCreateAllowed tx ∧
     tx.output.ref ∉ s.usedOutputs ∧ s' = afterClaimCreate s tx
 | .claimWithdraw tx => tx.input ∈ s.claims ∧ claimWithdrawAllowed tx ∧ s' = afterClaimWithdraw s tx)
```

### RequestApprovalFold.foldRun_inversion

Type SHA-256: `b2e7884952e260dc93e57ad71668c3adca771d5ffbbd9fc3683ab0678e0ead5d`.

```lean
theorem foldRun_inversion (iv : Interval) (refs : List TokenName) (sigs : List Signer)
 (c out : CageState) (items : List FoldItem) : FoldRun iv refs sigs c items out ↔
 (match items with
 | [] => out = c
 | item :: rest => itemAllowed c iv refs sigs item ∧ FoldRun iv refs sigs (itemResult c item) rest out)
```

### RequestApprovalFold.claim_item_inversion

Type SHA-256: `1beda4784d20b93abb7bc3f995331b9e90d1b22463970fede18ac96edcce567f`.

```lean
theorem claim_item_inversion (tx : FoldTx) (n : Nat) (o : ClaimOutput) :
 foldAccepted tx → tx.items[n]? = some (FoldItem.claim o) →
 o.cage = tx.cageIn.id ∧ o.key ∈ registryKeys tx.cageIn ∧ o.tokens = [claimName tx.cageIn.id] ∧
 tx.interval.valid ∧ tx.interval.upper < o.deadline ∧ tx.cageIn.minimum ≤ (atTurn tx n).balances o.key
```

### RequestApprovalFold.claim_windows_cover

Type SHA-256: `8ad9f2441367f3e28e3733a3afffbc0fa52239fad36aff997780f50ae9366104`.

```lean
theorem claim_windows_cover (c : CageState) (o : ClaimOutput) (now : Time) :
 o.cage = c.id → o.key ∈ registryKeys c → o.tokens = [claimName c.id] →
 c.minimum ≤ c.balances o.key →
 claimAllowed c ⟨now, now⟩ o ∨
 claimWithdrawAllowed ⟨o, ⟨now, now⟩, [o.key], o.tokens, o.key, o.value⟩
```

### RequestApprovalFold.fold_group_credits_only_recorded_signers

Type SHA-256: `91908c3a0f87cf178b46a008845c773a68b8f1f00771b0884b27abb263d8ca34`.

```lean
theorem fold_group_credits_only_recorded_signers (s s' : State) (tx : FoldTx) :
 Step s (.fold tx) s' →
 (∀ (n : Nat) o e, (tx.items[n]? = some (FoldItem.write o e) ∨
   tx.items[n]? = some (FoldItem.account o e)) → ∀ oracle ∈ tx.cageIn.oracles,
   (e oracle).authorized oracle ∧
   ((e oracle).name tx.cageIn.id o.request oracle ∈ s.judgments ∨
     ((e oracle).approve = true ∧ (e oracle).signers = tx.signers)) ∧
   (∀ key, key ∉ OracleIdentity.recordedKeys (e oracle).record →
     OracleIdentity.paidTo (oracleCredits o.request oracle (e oracle)) key = 0)) ∧
 (∀ key, (∀ (n : Nat) o e, (tx.items[n]? = some (FoldItem.write o e) ∨
   tx.items[n]? = some (FoldItem.account o e)) → ∀ oracle ∈ tx.cageIn.oracles,
   key ∉ OracleIdentity.recordedKeys (e oracle).record) →
   s'.cage.balances key ≤ s.cage.balances key)
```

### RequestApprovalFold.trace_reachability

Type SHA-256: `2eab1f59bcc626b164e55a68ba5e8baf2cdcc25d2d3813ba35cadd7005d99963`.

```lean
theorem trace_reachability (s : State) : Reachable s ↔
 ∃ c existing events, registryCreated c existing ∧ Trace (initial c) events s
```

### RequestApprovalFold.exit_windows_disjoint

Type SHA-256: `720e4c63c4a4f5c53be3c1d7ae410b39b93da8022bbaaf5d5e8d968375b0a174`.

```lean
theorem exit_windows_disjoint (o : RequestOutput) (iv : Interval) (a b : ExitKind) :
 exitAt o iv a → exitAt o iv b → a = b
```
