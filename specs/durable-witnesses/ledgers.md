# Durable witnesses: proof checkpoint (#128)

Status: **PARTIAL PROOF CANDIDATE — 182/199 public theorems PROVED;
17 OPEN.** PROOFS mode was authorized by NOTE-010 after the parent accepted
the third independent statement audit. The model and all 199 public elaborated
types remain frozen at cbf8f3ed629d58fd32f30706ef444388ccf291d3.
No public statement has been refuted. The zero-admission completion gate is
not yet met; this is a capacity-limit continuation checkpoint, not proof completion.

Proof-source commit: `b0520b337dcbfaf7ac8069d19d90e3fb22dd06e8`. Row statuses below bind to that commit.
The current 52 helper lemmas are all proved; all 677 witness/support declarations
are axiom-clean. The 182 PROVED public rows use only propext, Classical.choice
and Quot.sound. OPEN includes completed proof bodies that still depend on an
admitted witness-inventory invariant. No push or independent proof acceptance
is claimed.

Statement-audit history:

- Audit 1 of d2d6f15 returned NOT-READY: the payment-total helper needed a
  FoldRun premise; extraction terminality and complete account inversion needed
  statements; extraction token-burn atoms and retained-row mutation evidence
  needed completion. Repair 32d882c added D52–D56, corrected the helper domain
  and added DA143/DA144. The next audit closed the retained-row evidence gap.
- Audit 2 of 32d882c returned NOT-READY on event ordering (DA062). Repair
  cbf8f3e added the independent indexed order statement D57 and reachable DW57,
  killed the exact reversal mutant, corrected the listed ledger attributions,
  recorded the presence interpretation and removed unused unwitnessedTree.
- Audit 3 of cbf8f3e returned READY-TO-PROVE; NOTE-010 records parent acceptance.
  It replayed the campaign in fresh single-writer trees: 199/199 theorem rows
  killed, all 75 guards across 16 constructors covered, and 300/301 ledger atoms
  killed with A091 proved equivalent. Its 301 includes the four MA supplements
  in addition to the 297 numbered A/DA atoms. These are statement-sensitivity
  and non-vacuity results, distinct from this checkpoint's kernel proofs.

Limits: the withdrawal arms of Action.payments (ordinary request, claim and
extraction) have no statement consumer. Authoritative withdrawal amounts and
recipients are constrained by the transition predicates; #109 must address this
observation-layer gap if its executable interface consumes Action.payments.
The model and statements are unchanged for this advisory. The abstract ledger,
cryptography and implementation boundaries below remain in force.

## Authority and money boundaries

The durable-witness decisions take precedence over the earlier no-per-key-token
rule. OracleIdentity is imported unchanged. The 28 October money and interval
rulings in the request-approval-fold ledger remain in force.

A ruling of 29 October on deposits and witnesses inside one fold fixes the
interpretations below. A-001 is qualified by A-002 and **NOTE-001**, the operator's
correction that extraction is an ordinarily paid request. NOTE-002/003 impose
value-change-only burning and issuer deposit lock. A-003, reaffirmed by NOTE-006,
uses per-item changes. NOTE-005 is withdrawn entirely; NOTE-004 is closed:


- Each witness binds the exact value or absence, refund address, deposit and
  issuance request output reference in the tree entry. Its deposit is at least
  the registry minimum. A plain absent key has no entry. Presence is a consumer
  observation of an exact-value witness. NOTE-009 confirms that extraction
  commits to the named exact value: no value-agnostic presence request exists.
  Any change of that value consumes the witness, including when both values
  are present. A plain same-value set or an unset of an
  already absent key preserves the entry, output, token and deposit unchanged.
- CageState.tree is the authoritative entry tree. CageState.trie is its logical
  projection, not a second stored tree or an external obligation map. Conditions
  and logical root replay use that projection. Physical hashes and Merkle-proof
  cryptography remain abstract; each event's provedEntry is checked against the
  actual tree at that item, under the existing sound-proof boundary.
- RequestOutput.value retains the ordinary fees-and-remainder account. Its
  escrow observation adds the optional witnessing deposit. Extraction.value is
  its ordinary escrow (zero oracle fees, hence all remainder); Extraction.escrow
  adds its witness deposit. BOTH the extraction remainder and deposit meet the
  registry minimum. Extraction pays the remainder to the folder. It does not
  pass a rule, mint oracle tags, require judgments or credit oracle balances.
- Complete account returns the ordinary remainder and unused deposit to the
  request owner as separate payments. Withdrawal returns their sum to the owner.
  The future witness refund address acquires its entitlement only upon issuance.
- Before deadline an extraction folds; inside the closed deadline-to-window-end
  interval it settles by complete account; strictly afterwards its owner
  withdraws. A stale fact or already witnessed key does not prevent settlement.
- FoldRun remains sequential. Per-item WitnessEvent binds the proved entry,
  old output consumed and fresh output produced. The external input/output lists
  cancel intermediate issuance; its refund is STILL paid. Untouched outputs are
  retained, not spent or recreated. A witnessing set whose value equals an already
  witnessed value is refused and retains its ordinary later exits. A witnessing
  set that changes the value refunds the old witness and creates its successor.
- Value changes are per item: a round trip v -> w -> v burns the old witness at
  the first item, even though batch endpoints agree. No batch restriction was
  introduced. Step durability means no sequential item changes the key. The
  itemChanges and actionPreservesKey observations make that domain explicit.
- There is no live-witness withdrawal, deadline, issuer override or retirement.
  Signatures confer no additional witness power. D50 binds any release to the
  indexed value-changing event and exact refund; arbitrary action signatures
  and intervals are quantified. Ordinary request exits concern unminted deposits.
- WitnessOutput carries exactly one structured witness token at the registry
  script address and exactly its deposit. Token names are collision-free structured
  names in this model, as before; concrete hashes and encoding remain outside it.
- Extraction is a distinct typed request inventory, with the SAME registry request
  discovery token under release policy. Both pending request inventories and claims
  share the one fresh usedOutputs namespace and the fold's combined input Nodup
  guard. This preserves the ordinary write-request rule/approval guarantees without
  falsely applying them to extraction. Its exits, discovery and authentication
  have their own complete statement surface.
- The whole-fold equation is: initial registry value + ordinary and extraction
  request escrows + claim tips + consumed witness deposits = final registry value
  + ordinary and extraction remainders + claim payouts + claim tips + unused
  deposits returned to owners + witness refunds + newly surviving witness deposits.
  The request, fee-balance, deposit and actual-output equations are separately
  stated. Deposits never enter fee balances or remainder calculations.

## Scope and evidence classes

The model remains relational Step/FoldRun. The read-only referenceWitness
observation represents a consumer referencing an authentic witness output;
consumer-contract execution, ledger address validation, actual UTxO references,
minimum-ADA calculation, hashes, signatures and Merkle proof soundness remain
abstract boundaries. Executable codecs, generic driver and corpus remain #109.
No OracleIdentity source or decision record changed. Public documentation and
Aiken implementation are outside this commission.

Every scenario below is built from a real registryCreated prefix and actual Step
constructors. Witnesses and DurableWitnesses import no admitted statements.
The latter includes a rejecting-rule, oracle-bearing registry, paid absence and
exact-value extraction, unrelated writes, replacement, same-value plain set,
unset, stale extraction settlement, both later exits and intra-fold cancellation.
It additionally includes absent-unset and same-value durability, a refused
witnessing no-op followed by account or withdrawal, an intra-fold no-op retaining
the earlier witness, a round trip that burns, and a refund with no issuer signature.
Historical uniqueness additionally has D44 over the exact reachable Trace;
T08 remains the stronger standalone SpentOnce algebra lemma. No free history is
used as provenance for a claim or witness in the reachable machine.

ProofHelpers contains 52 proved internal lemmas. NOTE-010 permits their
reorganization while freezing the public surface. The accepted 33 helper types
are retained in the historical freeze below; the current complete helper/type
inventory and axiom receipts are in evidence/proofs under the creator runtime.

## Retained public theorem ledger

All legacy rows are restated over the new model; none is retired. W136 covers the
old constructor cases, supplemented by DW25 and DW27 for the two new constructors.
A witness supplies concrete reachable premises, sometimes more than the theorem
requires. The mutant identifies a semantic edit expected to falsify the statement.
Mutation attributions retain their named audit/candidate provenance; the Status
column now reports the proof census at the exact proof-source commit above.

| Row | Theorem | Obligation | Reachable witness | Named mutant | Status |
|---|---|---|---|---|---|
| T01 | applyAll_append | Fold composition | Witnesses.W01 | M-skip-tail | PROVED @ b0520b3 |
| T02 | foldRun_step_valid | Fold guards | Witnesses.W02 | M-skip-item-guard | PROVED @ b0520b3 |
| T03 | foldRun_result | Fold ordered effects | Witnesses.W03 | M-skip-run-effect | PROVED @ b0520b3 |
| T04 | foldRun_conditions | Conditions at intermediate tree | Witnesses.W04 | M-skip-item-guard | PROVED @ b0520b3 |
| T05 | applyAll_keeps_present | Present-key preservation | Witnesses.W05 | M-set-deletes | PROVED @ b0520b3 |
| T06 | registry_creation | Registry creation | Witnesses.W06 | M-registry-guard | PROVED @ b0520b3 |
| T07 | create_tags_existing_cage | Request creation and tag minting | Witnesses.W07 | M-seed-spend | PROVED @ b0520b3 |
| T08 | requests_unique_in_history | Historical request uniqueness | Witnesses.W08 | M-seed-spend | PROVED @ b0520b3 |
| T09 | judgment_authorized_and_bound | Judgment authorization, time, binding | Witnesses.W09 | M-oracle-membership | PROVED @ b0520b3 |
| T10 | judgment_not_replayable | Judgment replay protection | Witnesses.W10 | M-name-seed | PROVED @ b0520b3 |
| T11 | token_roles_separated | Tag/judgment domain separation | Witnesses.W11 | M-judgment-is-tag | PROVED @ b0520b3 |
| T12 | fold_preserves_registry | Immutable registry identity | Witnesses.W12 | M-fold-protocol | PROVED @ b0520b3 |
| T13 | step_preserves_registry | Immutable registry on every step | Witnesses.W13 | M-judge-protocol | PROVED @ b0520b3 |
| T14 | history_preserves_registry | Immutable registry across composition | Witnesses.W14 | M-judge-protocol | PROVED @ b0520b3 |
| T15 | only_fold_changes_tree | A trie change identifies an accepted fold, its source and exact successor | Witnesses.W15 | M-judge-trie | PROVED @ b0520b3 |
| T16 | fold_only_approved_before_deadline | All oracles approve before deadline | Witnesses.W16 | M-skip-item-guard | PROVED @ b0520b3 |
| T17 | fold_conditions_hold_when_applied | Intermediate-tree conditions | Witnesses.W17 | M-skip-item-guard | PROVED @ b0520b3 |
| T18 | fold_root_is_folded_writes | Exact writes in exact order | Witnesses.W18 | M-skip-write | PROVED @ b0520b3 |
| T19 | fold_burns_tags | Burn tags on fold | Witnesses.W19 | M-fold-burns | PROVED @ b0520b3 |
| T20 | fold_pays_and_keeps_rest | All fees credited and folder remainder | Witnesses.W20 | M-credit-key | PROVED @ b0520b3 |
| T21 | allocation_conserves_value | Money conservation | Witnesses.W21 | M-remainder | PROVED @ b0520b3 |
| T22 | blind_write_folds_on_any_tree | Blind write yields a FoldRun and its result on every trie | Witnesses.W22 | M-blind-guard | PROVED @ b0520b3 |
| T23 | fold_permissionless | Permissionless submission | Witnesses.W23 | M-submitter | PROVED @ b0520b3 |
| T24 | absent_inserts_exclusive | Absent-insert exclusivity | Witnesses.W24 | M-request-condition | PROVED @ b0520b3 |
| T25 | account_complete_and_pays | Complete account, fees, owner rest | Witnesses.W25 | M-account-evidence | PROVED @ b0520b3 |
| T26 | account_anyone_in_window | Anyone may account within the closed account window | Witnesses.W26 | M-account-window | PROVED @ b0520b3 |
| T27 | account_fee_neutral | Approval/refusal fee neutrality | Witnesses.W27 | M-verdict-dependent-credit | PROVED @ b0520b3 |
| T28 | withdraw_only_owner_after_window | Owner-only timed withdrawal | Witnesses.W28 | M-withdraw-signature | PROVED @ b0520b3 |
| T29 | owner_can_withdraw_everything | Withdrawal availability after window | Witnesses.W29 | M-withdraw-zero | PROVED @ b0520b3 |
| T30 | request_spent_only_by_lifecycle | No other legal request exit | Witnesses.W30 | M-spend-any | PROVED @ b0520b3 |
| T31 | every_exit_burns_tag | Every exit burns tags | Witnesses.W31 | M-withdraw-burns | PROVED @ b0520b3 |
| T32 | early_exit_requires_all_judgments | Early exits show every judgment | Witnesses.W32 | M-withdraw-time | PROVED @ b0520b3 |
| T33 | early_exit_pays_every_oracle | Early exits pay every oracle | Witnesses.W33 | M-credit-key | PROVED @ b0520b3 |
| T34 | before_deadline_only_approvals | Before the deadline only approvals or oracle signatures authorize an exit | Witnesses.W34 | M-write-approval | PROVED @ b0520b3 |
| T35 | dead_judgment_can_burn | Every held dead judgment burns, for every verdict and condition list, preserving cage/live requests | Witnesses.W35 | M-burn-live | PROVED @ b0520b3 |
| T36 | judgments_do_not_consume | Judgment minting consumes no request | Witnesses.W36 | M-judge-consumes | PROVED @ b0520b3 |
| T37 | exits_remove_consumed | Exit terminality | Witnesses.W37 | M-exit-retains | PROVED @ b0520b3 |
| T38 | fold_removes_consumed | Fold terminality | Witnesses.W38 | M-fold-retains | PROVED @ b0520b3 |
| T39 | used_seeds_monotone | Spent-once composition | Witnesses.W39 | M-exit-seeds | PROVED @ b0520b3 |
| T40 | reachable_requests_have_spent_seeds | Live oracle-bearing requests have spent seeds | Witnesses.W40 | M-create-seeds | PROVED @ b0520b3 |
| T41 | spent_seed_cannot_create_again | Seed cannot recur | Witnesses.W41 | M-seed-spend | PROVED @ b0520b3 |
| T42 | request_never_reappears | Consumed requests never reappear | Witnesses.W42 | M-fresh-output | PROVED @ b0520b3 |
| T43 | one_oracle_signature_suffices | Single-oracle old-design signature shortcut | Witnesses.W43 | M-no-inline | PROVED @ b0520b3 |
| T44 | old_operations_correspond | Old Insert/Delete/Update correspondence | Witnesses.W44 | M-old-delete | PROVED @ b0520b3 |
| T45 | live_removal_is_legal_exit | Consumption identifies the allowed spend, source registry, authentic inputs and successor | Witnesses.W45 | M-burn-consumes | PROVED @ b0520b3 |
| T46 | new_judgment_is_authorized | Authoritative machine judgment provenance | Witnesses.W46 | M-burn-issues | PROVED @ b0520b3 |
| T47 | exit_time_window | Every actual write, account or owner withdrawal fits its window | Witnesses.W47 | M-account-upper | PROVED @ b0520b3 |
| T48 | exit_windows_cover | The three scalar windows cover all time | Witnesses.W48 | M-window-gap | PROVED @ b0520b3 |
| T49 | exit_kind_unique | Two allowed spends at the same interval consume a request by the same exit kind | Witnesses.W49 | M-write-guard-overlap | PROVED @ b0520b3 |
| T50 | fold_references_authentic | Fold references genuinely held minted tokens | Witnesses.W50 | M-fake-references | PROVED @ b0520b3 |
| T51 | account_references_authentic | Account references genuinely held minted tokens | Witnesses.W51 | M-account-evidence | PROVED @ b0520b3 |
| T52 | creation_references_source | Creation uses registry in the source state | Witnesses.W52 | M-create-source | PROVED @ b0520b3 |
| T53 | fold_payments_concrete | Exact declared oracle fees and folder remainder | Witnesses.W53 | M-credit-key | PROVED @ b0520b3 |
| T54 | account_payments_concrete | Exact declared oracle fees and owner remainder | Witnesses.W54 | M-credit-key | PROVED @ b0520b3 |
| T55 | creation_funds_declared_fees | Creation cannot underfund declared fees | Witnesses.W55 | M-creation-minimum | PROVED @ b0520b3 |
| T56 | burn_removes_one | One burn decreases held multiplicity by exactly one | Witnesses.W56 | M-burn-retains | PROVED @ b0520b3 |
| T57 | burn_keeps_history | Burn does not erase permanent mint record | Witnesses.W57 | M-burn-forgets | PROVED @ b0520b3 |
| T58 | fold_requests_unique | No duplicate request in accepted fold | Witnesses.W58 | M-duplicate-input | PROVED @ b0520b3 |
| T59 | account_accepts_any_verdicts | Any authorized verdict selection in-window gives an actual account Step | Witnesses.W59 | M-account-approvals-only | PROVED @ b0520b3 |
| T60 | equivocation_reachable | A live request of the reachable registry has both verdicts of a registry oracle with one signing record in holdings and issuance | Witnesses.W60 | M-no-equivocation | PROVED @ b0520b3 |
| T61 | tag_name_injective | Oracle-bound discovery name | Witnesses.W61 | M-tag-oracle | PROVED @ b0520b3 |
| T62 | price_name_injective | Oracle-bound notice name | Witnesses.W62 | M-price-oracle | PROVED @ b0520b3 |
| T63 | different_roles_never_coincide | All distinct leading roles are disjoint | Witnesses.W63 | M-role | PROVED @ b0520b3 |
| T64 | names_have_leading_roles | Tag, approval, refusal and price encode their actual roles | Witnesses.W64 | M-role | PROVED @ b0520b3 |
| T65 | reachable_registry_valid | Reachable registries have oracles or a rule and duplicate-free oracles | Witnesses.W65 | M-registry-guard | PROVED @ b0520b3 |
| T66 | reachable_live_tags | Exact per-oracle holdings of every live request | Witnesses.W66 | M-missing-tags | PROVED @ b0520b3 |
| T67 | reachable_tags_unique | Exactly one occurrence per oracle, no duplicate tags | Witnesses.W67 | M-registry-guard | PROVED @ b0520b3 |
| T68 | discovery_iff | Live request tag query is sound and complete | Witnesses.W68 | M-discovery-all | PROVED @ b0520b3 |
| T69 | discovery_across_registries | One query spans all reachable registries | Witnesses.W69 | M-discovery-all | PROVED @ b0520b3 |
| T70 | live_removal_burns_oracle_tags | The actual removing action burns every registry-oracle tag | Witnesses.W70 | M-withdraw-burns | PROVED @ b0520b3 |
| T71 | price_mint_inversion | Signed mint, bound name, exact issuance and output effect | Witnesses.W71 | M-price-mint-auth | PROVED @ b0520b3 |
| T72 | price_update_inversion | Held-input authentication, signature, token retention and exact update | Witnesses.W72 | M-price-update-auth | PROVED @ b0520b3 |
| T73 | reachable_notice_names | All held notices bind their oracle and price role | Witnesses.W73 | M-price-transfer | PROVED @ b0520b3 |
| T74 | price_mint_available | Any oracle can publish any advertised datum | Witnesses.W74 | M-price-free-only | PROVED @ b0520b3 |
| T75 | price_update_available | Oracle can change a held notice to any datum | Witnesses.W75 | M-price-unchanged | PROVED @ b0520b3 |
| T76 | price_notice_noninterference | Price actions preserve registry, requests, judgments, seeds; no credits / outputs or exit | Witnesses.W76 | M-price-clears-judgments | PROVED @ b0520b3 |
| T77 | notices_do_not_bind_protocol | Same protocol action and credits / outputs with arbitrary notice observations | Witnesses.W77 | M-binding-price | PROVED @ b0520b3 |
| T78 | notice_change_authorized | New notice values have a signed actual mint/update origin | Witnesses.W78 | M-judge-notice | PROVED @ b0520b3 |
| T79 | creation_rule_and_token | creation rule and token | Witnesses.W79 | M-creation-rule | PROVED @ b0520b3 |
| T80 | step_rule_immutable | step rule immutable | Witnesses.W80 | M-fold-rule | PROVED @ b0520b3 |
| T81 | history_rule_immutable | history rule immutable | Witnesses.W81 | M-judge-rule | PROVED @ b0520b3 |
| T82 | reachable_rule_admitted | reachable rule admitted | Witnesses.W82 | M-creation-rule | PROVED @ b0520b3 |
| T83 | every_rule_allows_burn | Actual fold/account/withdraw/burn Steps available under lifecycle requirements for any rule, without re-admission | Witnesses.W83 | M-exit-readmits | PROVED @ b0520b3 |
| T84 | fold_rule_predicate_independent | fold rule predicate independent | Witnesses.W84 | M-rule-at-turn | PROVED @ b0520b3 |
| T85 | reachable_request_tokens | reachable request tokens | Witnesses.W85 | M-request-token | PROVED @ b0520b3 |
| T86 | fold_requires_request_token | fold requires request token | Witnesses.W86 | M-request-token | PROVED @ b0520b3 |
| T87 | every_exit_burns_request_token | every exit burns request token | Witnesses.W87 | M-withdraw-burns | PROVED @ b0520b3 |
| T88 | live_removal_burns_request_token | live removal burns request token | Witnesses.W88 | M-withdraw-burns | PROVED @ b0520b3 |
| T89 | request_name_injective | request name injective | Witnesses.W89 | M-request-name | PROVED @ b0520b3 |
| T90 | request_token_discovery | request token discovery | Witnesses.W90 | M-request-query | PROVED @ b0520b3 |
| T91 | request_token_discovery_across_registries | request token discovery across registries | Witnesses.W91 | M-request-query | PROVED @ b0520b3 |
| T92 | output_refs_monotone | output refs monotone | Witnesses.W92 | M-forget-refs | PROVED @ b0520b3 |
| T93 | reachable_output_refs | reachable output refs | Witnesses.W93 | M-create-refs | PROVED @ b0520b3 |
| T94 | reachable_output_refs_unique | reachable output refs unique | Witnesses.W94 | M-fresh-output | PROVED @ b0520b3 |
| T95 | unguarded_registry_impossible | unguarded registry impossible | Witnesses.W95 | M-registry-guard | PROVED @ b0520b3 |
| T96 | zero_oracle_needs_rule | zero oracle needs rule | Witnesses.W96 | M-registry-guard | PROVED @ b0520b3 |
| T97 | zero_oracle_evidence_empty | zero oracle evidence empty | Witnesses.W97 | M-zero-evidence | PROVED @ b0520b3 |
| T98 | zero_oracle_creation_without_seed | zero oracle creation without seed | Witnesses.W98 | M-zero-seed | PROVED @ b0520b3 |
| T99 | zero_oracle_fold_without_approvals | Zero-oracle write yields a FoldRun and its result | Witnesses.W99 | M-zero-evidence | PROVED @ b0520b3 |
| T100 | zero_oracle_account_without_verdicts | zero oracle account without verdicts | Witnesses.W100 | M-zero-account | PROVED @ b0520b3 |
| T101 | present_condition_semantics | present condition semantics | Witnesses.W101 | M-present-absent | PROVED @ b0520b3 |
| T102 | foldRun_oracle_conditions | foldRun oracle conditions | Witnesses.W102 | M-skip-item-guard | PROVED @ b0520b3 |
| T103 | fold_all_conditions_hold | fold all conditions hold | Witnesses.W103 | M-skip-item-guard | PROVED @ b0520b3 |
| T104 | approval_conditions_cannot_change | Approval-name equality iff records and conditions agree | Witnesses.W104 | M-name-conditions | PROVED @ b0520b3 |
| T105 | stale_approval_unusable | stale approval unusable | Witnesses.W105 | M-skip-item-guard | PROVED @ b0520b3 |
| T106 | fold_evidence_binds_conditions | fold evidence binds conditions | Witnesses.W106 | M-write-approval | PROVED @ b0520b3 |
| T107 | expected_approval_lookup | Exact iff between no-inline approval and authorized approval evidence plus computed-name membership | Witnesses.W107 | M-lookup-empty | PROVED @ b0520b3 |
| T108 | folder_discovery_exact | folder discovery exact | Witnesses.W108 | M-folder-no-conditions | PROVED @ b0520b3 |
| T109 | folder_discovery_executable | folder discovery executable | Witnesses.W109 | M-folder-no-conditions | OPEN (sorryAx) |
| T110 | empty_fold_allowed | An empty fold returns the original State itself | Witnesses.W110 | M-empty-forbidden | PROVED @ b0520b3 |
| T111 | empty_fold_earns_nothing | empty fold earns nothing | Witnesses.W111 | M-empty-paid | PROVED @ b0520b3 |
| T112 | creation_rule_input_binding | Actual creation binds Rule.admits to the singleton output request and exact creating signatures | Witnesses.W112 | M-rule-request | PROVED @ b0520b3 |
| T113 | creation_request_policy | Actual creation uses rule policy and never release if rule exists, release otherwise; both mint and output provenance | Witnesses.W113 | M-release-policy | PROVED @ b0520b3 |
| T114 | only_fold_changes_registry | only fold changes registry | Witnesses.W114 | M-creation-state | PROVED @ b0520b3 |
| T115 | reachable_balances_backed | reachable balances backed | Witnesses.W115 | M-credit-unbacked | PROVED @ b0520b3 |
| T116 | fold_value_conservation | fold value conservation | Witnesses.W116 | M-claim-value | OPEN (sorryAx) |
| T117 | fold_request_conservation | fold request conservation | Witnesses.W117 | M-remainder | PROVED @ b0520b3 |
| T118 | fold_balance_conservation | fold balance conservation | Witnesses.W118 | M-claim-payout-stale (audit-2 L4-M09) | PROVED @ b0520b3 |
| T119 | fold_payments_exact | fold credits / outputs exact | Witnesses.W119 | M-arbitrary-payments | PROVED @ b0520b3 |
| T120 | group_credits_only_recorded_signers | group credits only recorded signers | Witnesses.W120 | M-unsigned-fees | PROVED @ b0520b3 |
| T121 | group_credits_exact_split | group credits exact split | Witnesses.W121 | M-extra-fee | PROVED @ b0520b3 |
| T122 | judgment_record_cannot_change | judgment record cannot change | Witnesses.W122 | M-name-record | PROVED @ b0520b3 |
| T123 | claim_creation_inversion | claim creation inversion | Witnesses.W123 | M-claim-create-signature | PROVED @ b0520b3 |
| T124 | reachable_claim_authorization | Every live claim matches a key-signed creation event on the given exact history | Witnesses.W124 | M-claim-create-signature | PROVED @ b0520b3 |
| T125 | claim_payout_fixed | claim payout fixed | Witnesses.W125 | M-claim-redirect | PROVED @ b0520b3 |
| T126 | claim_payout_in_actual_outputs | claim payout in actual outputs | Witnesses.W126 | M-arbitrary-payments | PROVED @ b0520b3 |
| T127 | claim_below_minimum_refused | claim below minimum refused | Witnesses.W127 | M-claim-minimum | PROVED @ b0520b3 |
| T128 | claim_turn_balance | claim turn balance | Witnesses.W128 | M-claim-prior-balance | PROVED @ b0520b3 |
| T129 | claim_consumed_and_burned | claim consumed and burned | Witnesses.W129 | M-claim-retained | PROVED @ b0520b3 |
| T130 | claim_withdrawal_inversion | claim withdrawal inversion | Witnesses.W130 | M-claim-withdraw-signature | PROVED @ b0520b3 |
| T131 | claim_withdrawal_available | claim withdrawal available | Witnesses.W131 | M-claim-withdraw-strict | PROVED @ b0520b3 |
| T132 | claim_windows_disjoint | claim windows disjoint | Witnesses.W132 | M-claim-overlap | PROVED @ b0520b3 |
| T133 | claim_discovery_exact | claim discovery exact | Witnesses.W133 | M-claim-query | PROVED @ b0520b3 |
| T134 | request_withdrawal_preserves_registry | request withdrawal preserves registry | Witnesses.W134 | M-withdraw-state | PROVED @ b0520b3 |
| T135 | fold_interval_fits_every_item | fold interval fits every item | Witnesses.W135 | M-skip-item-guard | PROVED @ b0520b3 |
| T136 | step_inversion | step inversion | Witnesses.W136 + DurableWitnesses.DW25/DW27 | M-claim-source | PROVED @ b0520b3 |
| T137 | foldRun_inversion | foldRun inversion | Witnesses.W137 | M-skip-run-effect | PROVED @ b0520b3 |
| T138 | claim_item_inversion | claim item inversion | Witnesses.W138 | M-claim-item-cage | PROVED @ b0520b3 |
| T139 | claim_windows_cover | Point intervals admit claim fold or withdrawal at every time under the non-time guards | Witnesses.W139 | M-claim-withdraw-gap | PROVED @ b0520b3 |
| T140 | fold_group_credits_only_recorded_signers | All fold fee records are authenticated; a key absent from all selected records cannot gain balance | Witnesses.W140 | M-fold-unsigned-credit | PROVED @ b0520b3 |
| T141 | trace_reachability | Indexed event histories and Reachable describe exactly the same states | Witnesses.W141 | M-trace-missing-step | PROVED @ b0520b3 |
| T142 | exit_windows_disjoint | The exitAt window classes never overlap | Witnesses.W142 | M-window-overlap | PROVED @ b0520b3 |


## New public theorem ledger

| Row | Theorem | Reachable witness | Named single-atom mutant | Status |
|---|---|---|---|---|
| D01 | logical_tree_stripped | DurableWitnesses.DW01 | MD01 | PROVED @ b0520b3 |
| D02 | conditions_read_logical | DurableWitnesses.DW02 | MD02 | PROVED @ b0520b3 |
| D03 | reachable_witness_bijection | DurableWitnesses.DW03 | MD03 | OPEN (sorryAx) |
| D04 | live_witness_fact | DurableWitnesses.DW04 | MD04 | OPEN (sorryAx) |
| D05 | live_witness_presence | DurableWitnesses.DW05 | MD05 | OPEN (sorryAx) |
| D06 | live_witness_absence | DurableWitnesses.DW06 | MD06 | OPEN (sorryAx) |
| D07 | one_live_witness_per_key | DurableWitnesses.DW07 | MD07 | OPEN (sorryAx) |
| D08 | witnessed_write_obligation | DurableWitnesses.DW08 | MD08 | PROVED @ b0520b3 |
| D09 | fold_witness_boundary_exact | DurableWitnesses.DW09 | MD09 | PROVED @ b0520b3 |
| D10 | witness_spent_only_at_own_key | DurableWitnesses.DW10 | MD10 | OPEN (sorryAx) |
| D11 | untouched_witness_survives | DurableWitnesses.DW11 | MD11 | OPEN (sorryAx) |
| D12 | extraction_item_inversion | DurableWitnesses.DW12 | MD12 | PROVED @ b0520b3 |
| D13 | extraction_attests_requested | DurableWitnesses.DW13 | MD13 | PROVED @ b0520b3 |
| D14 | extraction_normal_request_money | DurableWitnesses.DW14 | MD14 | PROVED @ b0520b3 |
| D15 | extraction_permissionless_creation | DurableWitnesses.DW15 | MD15 | PROVED @ b0520b3 |
| D16 | extraction_permissionless_fold | DurableWitnesses.DW16 | MD16 | PROVED @ b0520b3 |
| D17 | extraction_witnessed_refused | DurableWitnesses.DW17 | MD17 | PROVED @ b0520b3 |
| D18 | extraction_stale_refused | DurableWitnesses.DW18 | MD18 | PROVED @ b0520b3 |
| D19 | witnessing_set_replaces | DurableWitnesses.DW19 | MD19 | PROVED @ b0520b3 |
| D20 | plain_write_clears_witness | DurableWitnesses.DW20 | MD20 | PROVED @ b0520b3 |
| D21 | fold_deposits_conserved | DurableWitnesses.DW21 | MD21 | OPEN (sorryAx) |
| D22 | live_outputs_hold_deposits | DurableWitnesses.DW22 | MD22 | OPEN (sorryAx) |
| D23 | witness_output_custody | DurableWitnesses.DW23 | MD23 | OPEN (sorryAx) |
| D24 | witness_origin_on_trace | DurableWitnesses.DW24 | MD24 | PROVED @ b0520b3 |
| D25 | extraction_creation_inversion | DurableWitnesses.DW25 | MD25 | PROVED @ b0520b3 |
| D26 | extraction_account_inversion | DurableWitnesses.DW26 | MD26 | PROVED @ b0520b3 |
| D27 | extraction_withdrawal_inversion | DurableWitnesses.DW27 | MD27 | PROVED @ b0520b3 |
| D28 | extraction_exit_window | DurableWitnesses.DW28 | MD28 | PROVED @ b0520b3 |
| D29 | extraction_exit_exclusive | DurableWitnesses.DW29 | MD29 | PROVED @ b0520b3 |
| D30 | extraction_removal_legal | DurableWitnesses.DW30 | MD30 | PROVED @ b0520b3 |
| D31 | extraction_discovery_exact | DurableWitnesses.DW31 | MD31 | PROVED @ b0520b3 |
| D32 | witnessing_creation_funded | DurableWitnesses.DW32 | MD32 | PROVED @ b0520b3 |
| D33 | unused_witnessing_deposit_returned | DurableWitnesses.DW33 | MD33 | PROVED @ b0520b3 |
| D34 | witness_token_issuance_bound | DurableWitnesses.DW34 | MD34 | PROVED @ b0520b3 |
| D35 | transient_witness_nets | DurableWitnesses.DW35 | MD35 | PROVED @ b0520b3 |
| D36 | only_fold_changes_witnesses | DurableWitnesses.DW36 | MD36 | PROVED @ b0520b3 |
| D37 | extraction_windows_cover | DurableWitnesses.DW37 | MD37 | PROVED @ b0520b3 |
| D38 | extraction_windows_disjoint | DurableWitnesses.DW38 | MD38 | PROVED @ b0520b3 |
| D39 | extraction_later_exits_available | DurableWitnesses.DW39 | MD39 | PROVED @ b0520b3 |
| D40 | write_item_inversion | DurableWitnesses.DW40 | MD40 | PROVED @ b0520b3 |
| D41 | reachable_input_refs_unique | DurableWitnesses.DW41 | MD41 | PROVED @ b0520b3 |
| D42 | touched_old_witness_burned | DurableWitnesses.DW42 | MD42 | OPEN (sorryAx) |
| D43 | fold_witness_inputs_authentic | DurableWitnesses.DW43 | MD43 | PROVED @ b0520b3 |
| D44 | requests_unique_on_trace | DurableWitnesses.DW44 | MD44 | OPEN (sorryAx) |
| D45 | witness_reference_sound | DurableWitnesses.DW45 | MD45 | OPEN (sorryAx) |
| D46 | item_burn_iff_value_change | DurableWitnesses.DW46 | MD46 | PROVED @ b0520b3 |
| D47 | witness_durability | DurableWitnesses.DW47 + refused_exits_preserve | MD47 | OPEN (sorryAx) |
| D48 | plain_noop_preserves_witness | DurableWitnesses.DW48 + absentNoop_effect + intrafold_noop_keeps | MD48 | PROVED @ b0520b3 |
| D49 | witnessing_noop_refused | DurableWitnesses.DW49 | MD49 | PROVED @ b0520b3 |
| D50 | witness_deposit_lock | DurableWitnesses.DW50 | MD50 | OPEN (sorryAx) |
| D51 | witnessing_blind_write_availability | DurableWitnesses.DW51 | MD51 | PROVED @ b0520b3 |
| D52 | extraction_exits_remove_consumed | DurableWitnesses.DW52 | MD52 | PROVED @ b0520b3 |
| D53 | extraction_fold_removes_consumed | DurableWitnesses.DW53 | MD53 | PROVED @ b0520b3 |
| D54 | extraction_never_reappears | DurableWitnesses.DW54 | MD54 | PROVED @ b0520b3 |
| D55 | extraction_consumption_terminal | DurableWitnesses.DW55 | MD55 | PROVED @ b0520b3 |
| D56 | account_item_inversion | DurableWitnesses.DW56 | MD56 | PROVED @ b0520b3 |
| D57 | fold_witness_events_in_item_order | DurableWitnesses.DW57 | MD57 / AT4-DA062 | PROVED @ b0520b3 |

## New mutation definitions

| Mutant | Production site | One semantic change |
|---|---|---|
| MD01 | stripWitnesses | Discard ordinary values while removing annotations |
| MD02 | stripWitnesses | Replace the stripped tree with the empty tree |
| MD03 | afterFold | Do not install the newly produced witness outputs |
| MD04 | Entry.logical.witnessed | Read every witnessed value as absent |
| MD05 | Condition.holds.present | Require the key to be absent |
| MD06 | Entry.logical.witnessed | Read an attested absence as a dummy present value |
| MD07 | afterFold | Keep consumed old witness outputs alongside their replacements |
| MD08 | itemWitnessEvents | Replace provedEntry by none |
| MD09 | witnessBoundary | Remove the witnessBurned equality |
| MD10 | foldAccepted | Remove the actual-payment-list equality |
| MD11 | afterFold | Drop all untouched witness outputs |
| MD12 | extractionAllowed | Remove exact wanted-value equality |
| MD13 | itemResult.extract | Store a witness of a fixed different fact |
| MD14 | itemPayments.extract | Pay no folder remainder |
| MD15 | extractionCreateAllowed | Require a nonempty creator signer list |
| MD16 | extractionAllowed | Require the registry oracle list to be empty |
| MD17 | extractionAllowed | Remove the unwitnessed-key guard |
| MD18 | extractionAllowed | Remove exact wanted-value equality |
| MD19 | writeEntry.set.some | Replace the requested refund address by a fixed other address |
| MD20 | writeEntry.set.none | Create a witnessed entry for a plain set |
| MD21 | externalWitnessOutputs | Do not cancel produced witnesses consumed later in the batch |
| MD22 | witnessValue | Report zero for every witness-output total |
| MD23 | witnessOutput | Set the output value to zero |
| MD24 | afterCreate | Insert a fabricated witness output without any fold |
| MD25 | Step.extractionCreate | Remove the fresh output-reference guard |
| MD26 | itemPayments.extractAccount | Pay the deposit to its future witness refund address instead of its request owner |
| MD27 | extractionWithdrawAllowed | Remove the owner-signature guard |
| MD28 | extractionAllowed | Allow upper = deadline |
| MD29 | extractionAllowed | Allow upper = deadline, overlapping complete account |
| MD30 | afterExtractionCreate | Replace the pending extraction list instead of prepending |
| MD31 | discoverExtractions | Always return an empty list |
| MD32 | Request.witnessValid | Remove the minimum-deposit guard |
| MD33 | unusedDepositPayments | Redirect the unused deposit to the future witness refund address |
| MD34 | witnessOutput | Replace data.issuance in the token by a constant |
| MD35 | externalWitnessInputs | Do not cancel intermediate produced witnesses |
| MD36 | afterExtractionCreate | Clear live witness outputs |
| MD37 | extractionExitAt.account | Use deadline < lower, leaving the deadline uncovered |
| MD38 | extractionExitAt.write | Use upper <= deadline |
| MD39 | extractionAccountAllowed | Require the wanted fact still to hold |
| MD40 | wellFormed | Remove Request.witnessValid |
| MD41 | Step.extractionCreate | Remove the fresh output-reference guard |
| MD42 | afterFold | Retain a consumed pre-existing witness |
| MD43 | Step.fold | Remove witness-input membership in the source state |
| MD44 | Step.create | Remove the fresh spent-seed guard |
| MD45 | referenceWitness | Return a fixed wrong fact for a held witness |
| MD46 | writeTree | Strip the old witness on a plain same-value write |
| MD47 | itemResult.account | Strip the witness annotation during complete account |
| MD48 | writeTree | Use putEntry unconditionally even for a plain no-op |
| MD49 | stepValid | Remove witnessWriteAllowed |
| MD50 | Step | Add an issuer-signed witness withdrawal after a timeout |
| MD51 | writeEntry | Store none as the fact of a witnessing set (audit-2 L6-M20) |
| MD52 | afterExtractionWithdraw | Keep the consumed input (audit M10) |
| MD53 | afterFold | Keep folded extractions (audit M11) |
| MD54 | Step.extractionCreate | Drop fresh output-reference guard, allowing an already consumed extraction to be recreated |
| MD55 | afterFold | Keep folded extractions, allowing repeated consumption (audit M11; M10 also checked) |
| MD56 | accountAllowed | Remove wellFormed, admitting an unfunded witnessing request |
| MD57 | foldWitnessEvents | Concatenate tail events before current item events (exact AT4-DA062) |

Guard-removal counterexamples may use a malformed proposed action after the same
reachable prefix. Redundant guards must be classified by the independent auditor;
no syntactic edit or compilation error is claimed as a semantic kill. In particular,
witness-input membership is redundant from the reachable bijection plus the other
fold checks, but D43 also pins the unrestricted Step constructor authentication
contract. Its full-domain and reachable-domain mutant results must be distinguished.

## Inherited mutation definitions

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
| M-judge-trie | afterJudgment | Replace cage.tree by a fixed populated trie |
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
| M-claim-payout-stale | claimPayouts | Recurse with incoming c instead of itemResult c i (audit-2 L4-M09) |

## Inherited semantic atoms

The 153 inherited atoms A001–A153 remain the inherited denominator. MA1–MA4
are four supplemental mappings, outside that denominator. Names and scenarios are retained;
A005 now means tree = emptyEntries, A146 pays RequestOutput.escrow, and tree mutations
target the encoded tree while logical observations still use CageState.trie. The
new atom table below records the additional obligations and composition cases.

| Atom | Class | Site and obligation | Reachable scenario | Expected falsifier | Named single-atom mutant |
|---|---|---|---|---|---|
| A001 | Origin | registryCreated: Fresh registry identity | W06 | registry_creation | M-A001: Remove id-not-existing guard |
| A002 | Origin | RegistryValid: At least one oracle or rule | W95 | unguarded_registry_impossible | M-A002: Allow neither oracle nor rule |
| A003 | Origin | RegistryValid: No repeated oracle identities | W67 | reachable_tags_unique | M-A003: Remove oracles.Nodup |
| A004 | Origin | RegistryValid: Positive output minimum | W06 | registry_creation | M-A004: Remove 0 < minimum |
| A005 | Origin | registryCreated: Empty initial encoded tree | W06 | registry_creation | M-A005: Remove tree = emptyEntries |
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
| A022 | Effect | afterCreate: Insert exactly the created request | W136 | reachable_output_refs | AT1-A022: afterCreate: also inserts {o with ref := o.ref ++ "-extra"} into live |
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
| A053 | Time | accountAllowed: Nonempty account interval | W135 | account_item_inversion | AT1-A053: accountAllowed: drop interval.valid |
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
| A146 | Money | withdrawAllowed: Pay the entire request escrow amount | W28 | withdraw_only_owner_after_window | M-A146: Require paid = 0 instead of input.escrow |
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


## Restatement census against the accepted baseline

All 142 original qualified public names survive. 18 source signatures
change; the remaining 124 have unchanged source signatures over the extended
model. Every statement is nevertheless reopened: a source-identical type may
refer to changed definitions. The signature comparison is an inventory, not an
independent semantic audit. The exact old/new pairs are retained at
`/code/mpfs-onchain-lean-128-20261029/astra-durable-witnesses-model/evidence/restated-types-final.json`.

| Theorem | Explicit restatement |
|---|---|
| registry_creation | Expose empty encoded tree as well as empty logical tree. |
| fold_pays_and_keeps_rest | Keep the exact fee/remainder account and include separately mandated witness refunds. |
| allocation_conserves_value | Escrow now includes the separate request deposit; allocation still accounts for every unit. |
| blind_write_folds_on_any_tree | A-003/NOTE-006: preserve universal ordinary-write availability; witnessing generalization is D51 and exposes its new refusal guard. |
| account_complete_and_pays | Return the unused witnessing deposit separately to the request owner. |
| withdraw_only_owner_after_window | Whole escrow includes the unused deposit; time and authorization unchanged. |
| owner_can_withdraw_everything | Construct the withdrawal paying the complete escrow. |
| fold_payments_concrete | Retain folder remainder and add exact witness refunds. |
| account_payments_concrete | Retain owner remainder and add the unused deposit. |
| fold_requests_unique | Include extraction references in the combined distinct-input obligation. |
| every_rule_allows_burn | Expose all new fold constructor guards including combined extraction reference uniqueness, witness boundary and live-input checks; do not re-run rule admission. |
| zero_oracle_fold_without_approvals | Expose witnessWriteAllowed under NOTE-002/A-003/NOTE-006; ordinary zero-oracle writes retain their original availability and require no approvals. |
| empty_fold_allowed | Populate the canonical empty witness boundary. |
| fold_value_conservation | Include deposits entering and leaving the full registry/request/witness boundary. |
| fold_request_conservation | Include funded request deposits separately from fees and remainders. |
| fold_payments_exact | Include unused-deposit returns and witness refunds in the exact actual-payment equation. |
| fold_interval_fits_every_item | Add extraction and extraction-account item windows. |
| step_inversion | Expose both added action constructors and new fold live-input guards. |

## Inversions and reachable boundary stories

The exhaustive Step inversion remains T136 and the FoldRun inversion remains
T137. The added action-specific inversions are D25 (extraction creation) and D27
(extraction withdrawal). D12 expands extraction application, D26 its complete
account, and D40 expands write acceptance including witnessWriteAllowed.
Existing request, judgment, claim, notice and withdrawal inversions are retained.
D09 pins every witness-boundary equality; D43 pins authentic live inputs.

| Ruling or edge | Kernel-checked reachable scenario | Statement obligations |
|---|---|---|
| Paid extraction and two independent minimums (NOTE-001) | paid_extraction; underfunded_refused | D12, D14, D25-D27, T116-T119 |
| Rule/oracle bypass despite a rejecting rule and nonempty oracle list | bypasses_rule_and_oracles; DW15; DW16 | D15-D16 |
| Same-value plain set retains output, token and deposit | same_effect; DW47; DW48 | D46-D48 |
| Unset of witnessed absence keeps it | absentNoop_effect | D46-D48 |
| Same-value witnessing set is refused even with refund-address signatures | refused_validity; DW49 | D49 |
| Its unminted deposit returns by account or withdrawal; existing witness stays locked | refused_exits_preserve | D33, D47, D50; ordinary exits |
| A later intra-fold no-op keeps the earlier witness | intrafold_noop_keeps | D46, D48 |
| A later value change burns an intermediate witness and refunds its issuer | transient_effect; DW21; DW35 | D21, D35, D46 |
| Round trip v -> w -> v burns on the first item (A-003, NOTE-006) | roundtrip_burn | D10, D42, D46, D50; outside D47's premise |
| Refund without issuer or refund-address authorization | refund_without_issuer_signature | T109, D50 |

Names in this table are in RequestApprovalFold.DurableWitnesses. These stories
pin the interpretation, not a universal proof. No scenario imports Statements
or ProofHelpers; no witness relies on an intentional theorem admission.

## Added semantic-atom ledger

Rows name single semantic edits. DA105/DA107 have round-1 creator kills;
DA062 has a round-2 creator kill. Audit-2 attributions below refer to 32d882c.
Other mutations have not been rerun on this repair. The scenario
provides a reachable prefix; refusal mutants vary the proposed action after
that prefix. A compilation failure is not a kill. Structural token and field
constraints are tested by changes at their consuming law. There are 144
added atoms and 153 inherited atoms, for 297 numbered atoms. MA1–MA4 are
supplemental mappings. This is a finite coverage claim, with evidence classes below.

| Atom | Production site | Guard, effect, refusal or observation | Reachable scenario | Expected falsifier | Single-atom mutant |
|---|---|---|---|---|---|
| DA001 | Entry.logical.value | Ordinary present values read unchanged | DurableWitnesses.DW02 | conditions_read_logical | M-DA001: Return none for an ordinary value |
| DA002 | Entry.logical.witnessed | Read the attested value or absence | DurableWitnesses.DW04 | live_witness_fact | M-DA002: Return none for every witnessed value |
| DA003 | logicalTree | No entry reads as absence | DurableWitnesses.DW06 | registry_creation | AT3-DA003: logicalTree reads some "dummy" for a missing entry |
| DA004 | stripWitnesses | Remove annotations while retaining logical facts | DurableWitnesses.DW01 | logical_tree_stripped | M-DA004: Discard ordinary values |
| DA005 | CageState.trie | Conditions use the projection of the actual encoded tree | Witnesses.W18 | fold_root_is_folded_writes | M-DA005: Return emptyTrie for every state |
| DA006 | witnessAt | Only witnessed entries carry obligations | DurableWitnesses.DW03 | reachable_witness_bijection | M-DA006: Treat ordinary values as a dummy witness |
| DA007 | registryCreated | The initial encoded tree is empty | Witnesses.W06 | registry_creation | M-DA007: Check only the logical projection is empty, permitting witnessed absence |
| DA008 | initial | No initial witness UTxOs | DurableWitnesses.DW03 | reachable_witness_bijection | M-DA008: Start with a fabricated witness output |
| DA009 | initial | No initial extraction requests | DurableWitnesses.DW31 | extraction_discovery_exact | M-DA009: Start with a fabricated extraction |
| DA010 | Request.deposit | Read the declared witnessing deposit exactly | DurableWitnesses.DW32 | witnessing_creation_funded | M-DA010: Return zero when witnessing is present |
| DA011 | Request.witnessValid | Witnessing deposit meets minimum | DurableWitnesses.DW32 | witnessing_creation_funded | M-DA011: Drop minimum <= deposit |
| DA012 | Request.witnessValid | Only set can request witnessing | DurableWitnesses.DW40 | write_item_inversion | M-DA012: Accept witnessing unset |
| DA013 | RequestOutput.escrow | Deposit is additional to ordinary escrow | Witnesses.W21 | allocation_conserves_value | M-DA013: Omit request deposit from escrow |
| DA014 | Extraction.escrow | Ordinary remainder plus deposit | DurableWitnesses.DW14 | extraction_normal_request_money | M-DA014: Return only the deposit |
| DA015 | extractionWellFormed | Extraction belongs to this registry | DurableWitnesses.DW12 | extraction_item_inversion | M-DA015: Drop cage identity equality |
| DA016 | extractionWellFormed | Witness deposit meets minimum | DurableWitnesses.DW12 | extraction_item_inversion | M-DA016: Drop minimum <= witness.deposit |
| DA017 | extractionWellFormed | Ordinary extraction escrow meets minimum independently | DurableWitnesses.DW12 | extraction_item_inversion | M-DA017: Drop minimum <= value |
| DA018 | extractionWellFormed | Exactly the registry request token | DurableWitnesses.DW12 | extraction_item_inversion | M-DA018: Permit an empty token list |
| DA019 | extractionWellFormed | Release policy bypasses the registry rule | DurableWitnesses.DW12 | extraction_item_inversion | M-DA019: Permit any policy |
| DA020 | extractionCreateAllowed | Mint exactly the request token | DurableWitnesses.DW25 | extraction_creation_inversion | M-DA020: Permit an arbitrary minted list |
| DA021 | extractionCreateAllowed | No creator authorization or rule condition | DurableWitnesses.DW15 | extraction_permissionless_creation | M-DA021: Require nonempty transaction signatures |
| DA022 | Step.extractionCreate | Authenticate the current registry reference | DurableWitnesses.DW25 | extraction_creation_inversion | M-DA022: Drop cageRef = source cage |
| DA023 | Step.extractionCreate | Require the creation predicate | DurableWitnesses.DW25 | extraction_creation_inversion | M-DA023: Drop extractionCreateAllowed |
| DA024 | Step.extractionCreate | Fresh reference across every input class | DurableWitnesses.DW41 | reachable_input_refs_unique | M-DA024: Drop output.ref not-in usedOutputs |
| DA025 | Step.extractionCreate | Store exactly the supplied request | DurableWitnesses.DW25 | extraction_creation_inversion | AT3-DA025: Step.extractionCreate target stores output with refund := "other" |
| DA026 | afterExtractionCreate | Preserve existing pending extractions | DurableWitnesses.DW30 | extraction_removal_legal | M-DA026: Replace the list rather than prepend |
| DA027 | afterExtractionCreate | Record the fresh ref permanently | DurableWitnesses.DW41 | reachable_input_refs_unique | M-DA027: Do not insert the fresh reference |
| DA028 | afterExtractionCreate | Leave registry and live witnesses unchanged | Witnesses.W114 | only_fold_changes_registry | M-DA028: Modify the registry tree during creation |
| DA029 | Extraction.data | Bind the requested fact | DurableWitnesses.DW13 | extraction_attests_requested | M-DA029: Replace wanted with a fixed different fact |
| DA030 | Extraction.data | Bind the requested refund address | DurableWitnesses.DW13 | extraction_attests_requested | M-DA030: Replace witness.refund with a fixed address |
| DA031 | Extraction.data | Bind the funded deposit | DurableWitnesses.DW13 | extraction_attests_requested | M-DA031: Increase the recorded deposit by one |
| DA032 | Extraction.data | Bind issuance to this exact request reference | DurableWitnesses.DW13 | extraction_attests_requested | M-DA032: Replace ref by a constant |
| DA033 | extractionAllowed | Validate its authentic request shape | DurableWitnesses.DW12 | extraction_item_inversion | M-DA033: Remove extractionWellFormed |
| DA034 | extractionAllowed | Closed nonempty interval | DurableWitnesses.DW12 | extraction_item_inversion | M-DA034: Remove interval.valid |
| DA035 | extractionAllowed | Strictly predeadline application | DurableWitnesses.DW28 | extraction_exit_window | M-DA035: Permit upper = deadline |
| DA036 | extractionAllowed | Only an unwitnessed key can be extracted | DurableWitnesses.DW17 | extraction_witnessed_refused | M-DA036: Remove witnessAt = none |
| DA037 | extractionAllowed | Exact wanted fact holds at its turn | DurableWitnesses.DW18 | extraction_stale_refused | M-DA037: Remove trie-key = wanted |
| DA038 | extractionAllowed | No oracle evidence or rule participation | DurableWitnesses.DW16 | extraction_item_inversion | AT4-DA038: extractionAllowed additionally requires c.oracles = [] |
| DA039 | itemAllowed.extract | Call extractionAllowed for the actual item | DurableWitnesses.DW13 | extraction_attests_requested | M-DA039: Accept every extraction item |
| DA040 | itemResult.extract | Replace precisely the extracted key | DurableWitnesses.DW13 | extraction_attests_requested | M-DA040: Update a fixed different key |
| DA041 | itemResult.extract | Preserve every other key | DurableWitnesses.DW11 | untouched_witness_survives | M-DA041: Clear the whole tree before installing the extracted key |
| DA042 | itemResult.extract | Leave fee balances and backing unchanged | DurableWitnesses.DW14 | extraction_normal_request_money | M-DA042: Increment registry fee value |
| DA043 | itemCredits.extract | Extraction pays no oracle fees | DurableWitnesses.DW14 | extraction_normal_request_money | M-DA043: Credit a fabricated oracle payment |
| DA044 | itemPayments.extract | Pay the ordinary remainder to the folder | DurableWitnesses.DW14 | extraction_normal_request_money | M-DA044: Return no payments |
| DA045 | itemPayments.extract | The deposit does not become a tip | DurableWitnesses.DW14 | extraction_normal_request_money | M-DA045: Pay value plus deposit to the folder |
| DA046 | Write.key | Bind obligation processing to the actual written key | DurableWitnesses.DW08 | witnessed_write_obligation | M-DA046: Return a fixed different key |
| DA047 | writeEntry.set.some | Store precisely the written value | DurableWitnesses.DW19 | witnessing_set_replaces | M-DA047: Store a fixed different value |
| DA048 | writeEntry.set.some | Bind the newly requested refund address | DurableWitnesses.DW19 | witnessing_set_replaces | M-DA048: Use a fixed different refund address |
| DA049 | writeEntry.set.some | Bind the newly funded deposit | DurableWitnesses.DW19 | witnessing_set_replaces | M-DA049: Store deposit plus one |
| DA050 | writeEntry.set.some | Bind the new issuance reference | DurableWitnesses.DW19 | witnessing_set_replaces | M-DA050: Use a constant issuance |
| DA051 | writeEntry.set.none | A value-changing plain set leaves an ordinary value | DurableWitnesses.DW20 | plain_write_clears_witness | M-DA051: Store a witnessed entry |
| DA052 | writeEntry.unset | A value-changing unset leaves no entry | DurableWitnesses.DW20 | plain_write_clears_witness | M-DA052: Leave a witnessed absence behind |
| DA053 | putEntry | Leave all other keys unchanged | DurableWitnesses.DW11 | untouched_witness_survives | M-DA053: Clear unrelated keys |
| DA054 | itemResult.write | Update the authoritative entry tree at the write key | Witnesses.W18 | fold_root_is_folded_writes | M-DA054: Leave the old encoded tree unchanged |
| DA055 | itemResult.account | Leave witness obligations unchanged | DurableWitnesses.DW11 | untouched_witness_survives | M-DA055: Strip all witnesses on complete account |
| DA056 | itemResult.claim | Leave witness obligations unchanged | DurableWitnesses.DW11 | reachable_witness_bijection | AT4-DA056: itemResult .claim also tree := stripWitnesses c.tree |
| DA057 | itemWitnessEvents | Event key is the touched key | DurableWitnesses.DW08 | witnessed_write_obligation | M-DA057: Use a fixed other key |
| DA058 | itemWitnessEvents | Prove the exact entry at the item turn | DurableWitnesses.DW08 | witnessed_write_obligation | M-DA058: Set provedEntry to none |
| DA059 | itemWitnessEvents | Consume the old entry witness only when the item changes its value | DurableWitnesses.DW08 | witnessed_write_obligation | M-DA059: Omit consumed |
| DA060 | itemWitnessEvents | Produce exactly the new entry witness | DurableWitnesses.DW03 | reachable_witness_bijection | M-DA060: Omit produced |
| DA061 | itemWitnessEvents | Omit an event when old and new witness are equal | DurableWitnesses.DW48 | plain_noop_preserves_witness | M-DA061: Emit a consumed and produced pair for an unchanged witness |
| DA062 | foldWitnessEvents | Accumulate events in item order | DurableWitnesses.DW57 | fold_witness_events_in_item_order | AT4-DA062: Concatenate tail events before current item events (creator KILLED) |
| DA063 | foldWitnessEvents | Each item sees its predecessor result | DurableWitnesses.DW13 | fold_payments_exact | AT4-DA063: foldWitnessEvents recurses with incoming state c |
| DA064 | witnessOutput | Bind registry identity in the token | DurableWitnesses.DW04 | live_witness_fact | M-DA064: Substitute a different cage |
| DA065 | witnessOutput | Bind the witnessed key in the token | DurableWitnesses.DW03 | reachable_witness_bijection | M-DA065: Substitute a fixed different key |
| DA066 | witnessOutput | Bind the entire fact/refund/deposit/issuance record | DurableWitnesses.DW34 | witness_token_issuance_bound | M-DA066: Erase issuance from the token |
| DA067 | witnessOutput | Custody is the registry state script address | DurableWitnesses.DW23 | witness_output_custody | M-DA067: Send the output to the refund address |
| DA068 | witnessOutput | Output value equals the deposit exactly | DurableWitnesses.DW23 | witness_output_custody | M-DA068: Set output value to zero |
| DA069 | externalWitnessInputs | Spend only externally pre-existing consumed witnesses | DurableWitnesses.DW35 | transient_witness_nets | M-DA069: Retain intermediate issuances as external inputs |
| DA070 | externalWitnessOutputs | Produce only surviving new witnesses | DurableWitnesses.DW21 | fold_deposits_conserved | M-DA070: Retain intermediates already consumed |
| DA071 | witnessBoundary | Check exact ordered event list | DurableWitnesses.DW09 | fold_witness_boundary_exact | M-DA071: Remove witnessEvents equality |
| DA072 | witnessBoundary | Check exact external witness inputs | DurableWitnesses.DW09 | fold_witness_boundary_exact | M-DA072: Remove witnessInputs equality |
| DA073 | witnessBoundary | Check exact external witness outputs | DurableWitnesses.DW09 | fold_witness_boundary_exact | M-DA073: Remove witnessOutputs equality |
| DA074 | witnessBoundary | Burn exactly the external consumed tokens | DurableWitnesses.DW09 | fold_witness_boundary_exact | M-DA074: Remove witnessBurned equality |
| DA075 | witnessBoundary | Mint exactly the external produced tokens | DurableWitnesses.DW09 | fold_witness_boundary_exact | M-DA075: Remove witnessMinted equality |
| DA076 | foldAccepted | Include extraction refs in combined Nodup | DurableWitnesses.DW41 | fold_requests_unique | AT4-DA076: foldAccepted Nodup excludes extraction refs |
| DA077 | foldAccepted | Require the witness boundary as part of fold acceptance | DurableWitnesses.DW09 | fold_witness_boundary_exact | M-DA077: Drop witnessBoundary |
| DA078 | Step.fold | Every consumed extraction is live in this source | DurableWitnesses.DW43 | fold_witness_inputs_authentic | M-DA078: Drop extraction-input membership |
| DA079 | Step.fold | Every spent witness output is live in this source | DurableWitnesses.DW43 | fold_witness_inputs_authentic | M-DA079: Drop witness-input membership |
| DA080 | itemWitnessRefunds | Refund exactly each consumed witness once | DurableWitnesses.DW19 | witnessing_set_replaces | M-DA080: Duplicate each refund |
| DA081 | itemWitnessRefunds | Refund the entry's bound recipient | DurableWitnesses.DW19 | witnessing_set_replaces | M-DA081: Pay the folder instead |
| DA082 | itemWitnessRefunds | Refund exactly the funded deposit | DurableWitnesses.DW19 | witnessing_set_replaces | M-DA082: Refund one less unit |
| DA083 | itemPayments.write | Include all witness refunds in actual outputs | DurableWitnesses.DW10 | witness_spent_only_at_own_key | M-DA083: Omit itemWitnessRefunds |
| DA084 | unusedDepositPayments | Return unused set deposit to request owner | DurableWitnesses.DW33 | unused_witnessing_deposit_returned | M-DA084: Pay future witness refund address |
| DA085 | unusedDepositPayments | Return the exact unused set deposit | DurableWitnesses.DW33 | unused_witnessing_deposit_returned | M-DA085: Return zero |
| DA086 | itemPayments.account | Include the unused witnessing deposit | DurableWitnesses.DW33 | unused_witnessing_deposit_returned | M-DA086: Omit unusedDepositPayments |
| DA087 | withdrawAllowed | Return ordinary request escrow plus unused deposit | Witnesses.W28 | withdraw_only_owner_after_window | M-DA087: Pay only input.value |
| DA088 | extractionAccountAllowed | Require well-formed extraction | DurableWitnesses.DW26 | extraction_account_inversion | M-DA088: Omit extractionWellFormed |
| DA089 | extractionAccountAllowed | Require nonempty interval | DurableWitnesses.DW26 | extraction_account_inversion | M-DA089: Omit interval.valid |
| DA090 | extractionAccountAllowed | Account begins at deadline | DurableWitnesses.DW28 | extraction_exit_window | M-DA090: Permit lower before deadline |
| DA091 | extractionAccountAllowed | Account ends inclusively at window end | DurableWitnesses.DW28 | extraction_exit_window | M-DA091: Drop upper <= deadline + window |
| DA092 | extractionAccountAllowed | No condition, rule or oracle re-admission | DurableWitnesses.DW39 | extraction_later_exits_available | M-DA092: Require the extraction's wanted value still to hold |
| DA093 | itemResult.extractAccount | Preserve the entire registry | DurableWitnesses.DW26 | extraction_account_inversion | M-DA093: Change the logical tree |
| DA094 | itemPayments.extractAccount | Return ordinary remainder to owner | DurableWitnesses.DW26 | extraction_account_inversion | M-DA094: Pay remainder to folder |
| DA095 | itemPayments.extractAccount | Return unused deposit to owner | DurableWitnesses.DW26 | extraction_account_inversion | M-DA095: Pay deposit to future witness refund address |
| DA096 | itemPayments.extractAccount | Preserve exact amounts separately | DurableWitnesses.DW26 | extraction_account_inversion | M-DA096: Omit the deposit payment |
| DA097 | extractionWithdrawAllowed | Require nonempty interval | DurableWitnesses.DW27 | extraction_withdrawal_inversion | M-DA097: Drop interval.valid |
| DA098 | extractionWithdrawAllowed | Strictly after deadline plus window | DurableWitnesses.DW27 | extraction_withdrawal_inversion | M-DA098: Permit withdrawal at the window endpoint |
| DA099 | extractionWithdrawAllowed | Require the request owner's signature | DurableWitnesses.DW27 + DurableWitnesses.refund_without_issuer_signature | extraction_withdrawal_inversion | M-DA099: Drop owner membership in signers |
| DA100 | extractionWithdrawAllowed | Burn all and only extraction request tokens | DurableWitnesses.DW27 | extraction_withdrawal_inversion | M-DA100: Remove burned equality |
| DA101 | extractionWithdrawAllowed | Pay only the request owner | DurableWitnesses.DW27 | extraction_withdrawal_inversion | M-DA101: Remove beneficiary equality |
| DA102 | extractionWithdrawAllowed | Pay all ordinary escrow and deposit | DurableWitnesses.DW27 | extraction_withdrawal_inversion | M-DA102: Pay deposit only |
| DA103 | Step.extractionWithdraw | Consume an authentic pending extraction | DurableWitnesses.DW27 | extraction_withdrawal_inversion | M-DA103: Drop pending-input membership |
| DA104 | Step.extractionWithdraw | Check the complete withdrawal predicate | DurableWitnesses.DW27 | extraction_withdrawal_inversion | M-DA104: Drop extractionWithdrawAllowed |
| DA105 | afterExtractionWithdraw | Remove the consumed extraction | DurableWitnesses.DW52 | extraction_exits_remove_consumed | M-DA105: Leave it live (M10; creator kill) |
| DA106 | afterExtractionWithdraw | Preserve registry and witnesses | DurableWitnesses.DW36 | only_fold_changes_witnesses | M-DA106: Clear witnesses on withdrawal |
| DA107 | afterFold | Remove folded or accounted extraction requests | DurableWitnesses.DW53 | extraction_fold_removes_consumed | M-DA107: Keep them live (M11; creator kill) |
| DA108 | afterFold | Remove externally consumed old witnesses | DurableWitnesses.DW42 | touched_old_witness_burned | M-DA108: Retain consumed witnesses |
| DA109 | afterFold | Install surviving produced witness outputs | DurableWitnesses.DW03 | reachable_witness_bijection | M-DA109: Do not append produced outputs |
| DA110 | afterFold | Preserve untouched outputs exactly | DurableWitnesses.DW11 | untouched_witness_survives | M-DA110: Retain only the transaction's new outputs |
| DA111 | afterFold | Do not mint duplicate witness outputs | DurableWitnesses.DW03 | reachable_witness_bijection | M-DA111: Append each produced output twice |
| DA112 | requestEscrows | Include extraction ordinary escrow and deposit | Witnesses.W117 | fold_request_conservation | M-DA112: Count extraction deposit only |
| DA113 | requestDepositInputs | Count all request-funded witness deposits separately | DurableWitnesses.DW21 | fold_deposits_conserved | M-DA113: Omit extraction deposits |
| DA114 | requestRemainders | Include extraction and extraction-account ordinary remainders | Witnesses.W119 | fold_payments_exact | M-DA114: Ignore extraction remainder |
| DA115 | unusedDepositRefunds | Count set and extraction account deposits | DurableWitnesses.DW21 | fold_deposits_conserved | M-DA115: Ignore extraction-account deposits |
| DA116 | witnessRefundTotal | Include intermediate consumed witness deposits | DurableWitnesses.DW21 | fold_deposits_conserved | M-DA116: Count only external input deposits |
| DA117 | witnessValue | Sum exact output values | DurableWitnesses.DW22 | live_outputs_hold_deposits | M-DA117: Return zero |
| DA118 | entryDeposits | Sum exactly the per-entry declared deposits over a complete key census | DurableWitnesses.DW22 | live_outputs_hold_deposits | M-DA118: Return zero |
| DA119 | extractionSpendAllowed.folded | Require accepted fold and exact extraction membership | DurableWitnesses.DW28 | extraction_exit_window | M-DA119: Accept any folded extraction spend |
| DA120 | extractionSpendAllowed.withdrawn | Require valid withdrawal of this exact input | DurableWitnesses.DW28 | None: equivalent under exitsAs (da120_shadowed) | AT5-DA120: Drop tx.input = o in withdrawn arm; audit-2 equivalence, not a kill |
| DA121 | ExtractionSpend.exitsAs | Classify actual extract/account/withdraw actions separately | DurableWitnesses.DW29 | extraction_exit_exclusive | M-DA121: Classify account as extraction too |
| DA122 | extractionExitAt | Preserve the three closed/nonempty window classes | DurableWitnesses.DW38 | extraction_windows_disjoint | M-DA122: Overlap write and account at deadline |
| DA123 | extractionExitAt | No gap at deadline or window endpoint | DurableWitnesses.DW37 | extraction_windows_cover | M-DA123: Require account lower strictly after deadline |
| DA124 | referenceWitness | Return only a held output's exact record | DurableWitnesses.DW45 | witness_reference_sound | M-DA124: Replace the returned fact |
| DA125 | referenceWitness | Reject an output not currently live | DurableWitnesses.DW45 | witness_reference_sound | M-DA125: Return every supplied output's record |
| DA126 | Write.value | Exact result value for either write constructor | DurableWitnesses.DW46 | item_burn_iff_value_change | M-DA126: Read unset as a dummy present value |
| DA127 | witnessWriteAllowed | Plain writes always pass the witness-specific guard | Witnesses.W22 | blind_write_folds_on_any_tree | M-DA127: Reject plain no-op writes |
| DA128 | witnessWriteAllowed | Witnessing set can create on an unwitnessed key | DurableWitnesses.DW51 | write_item_inversion | AT5-DA128: witnessWriteAllowed: witnessing requires an existing witness and change |
| DA129 | witnessWriteAllowed | Witnessing set on a witnessed key requires an actual value change | DurableWitnesses.DW49 | witnessing_noop_refused | M-DA129: Remove the differing-value condition |
| DA130 | stepValid | Enforce witnessWriteAllowed at this actual turn | DurableWitnesses.DW49 | witnessing_noop_refused | M-DA130: Drop witnessWriteAllowed |
| DA131 | writeTree | Preserve whole encoded tree on a plain same-value write | DurableWitnesses.DW48 | plain_noop_preserves_witness | M-DA131: Apply putEntry unconditionally |
| DA132 | writeTree | Preserve witnessed absence on unset of an already absent key | DurableWitnesses.DW48 + DurableWitnesses.absentNoop_effect | plain_noop_preserves_witness | M-DA132: Drop the no-op branch for unset |
| DA133 | writeTree | A changing write still installs the requested entry | DurableWitnesses.DW46 | blind_write_folds_on_any_tree | AT5-DA133: writeTree: condition reduced to witnessing = none |
| DA134 | FoldItem.entryKey | Only writes and extraction can affect witness entries | DurableWitnesses.DW47 | witness_durability | M-DA134: Return a key for complete-account items |
| DA135 | itemChanges | Compare logical values at the item turn | DurableWitnesses.DW46 | item_burn_iff_value_change | M-DA135: Use write-key equality as the change predicate |
| DA136 | actionPreservesKey | Every sequential item must preserve the key | DurableWitnesses.DW47 | witness_durability | M-DA136: Compare only the fold endpoints |
| DA137 | actionPreservesKey | All non-fold actions preserve witnesses | DurableWitnesses.DW50 | witness_deposit_lock | M-DA137: Allow issuer-signed withdrawal to remove live witness |
| DA138 | Step | No timeout or issuer withdrawal for a live witness | DurableWitnesses.DW50 | witness_deposit_lock | M-DA138: Add a live-witness withdrawal after a deadline |
| DA139 | foldAccepted | Refund does not require issuer or refund-address signature | Witnesses.W109 + DurableWitnesses.refund_without_issuer_signature | folder_discovery_executable | AT5-DA139: foldAccepted: add refund addresses of witnessInputs in signers |
| DA140 | foldWitnessEvents | A later no-op does not burn an earlier intra-fold witness | DurableWitnesses.DW46 + DurableWitnesses.intrafold_noop_keeps | fold_payments_exact | AT5-DA140: foldWitnessEvents: extra consumption event for a no-op unset of a witnessed key |
| DA141 | foldWitnessEvents | A later reversal does not undo the first value-change burn | DurableWitnesses.DW46 + DurableWitnesses.roundtrip_burn | fold_payments_exact | AT5-DA141: foldWitnessEvents: drop consumptions whose fact holds at the fold result |
| DA142 | itemPayments.account | Return only the unused request deposit and keep live witness deposit locked | DurableWitnesses.DW47 | unused_witnessing_deposit_returned | AT5-DA142: itemPayments.account: also pay existing witness deposit to owner |
| DA143 | FoldItem.burned.extract | Burn every extraction request token on application | DurableWitnesses.DW53 | extraction_removal_legal | M-DA143: Return [] for extract |
| DA144 | FoldItem.burned.extractAccount | Burn every extraction request token on complete account | DurableWitnesses.DW53 | extraction_removal_legal | M-DA144: Return [] for extractAccount |

## Accepted freeze and proof-checkpoint verification

Accepted Model SHA-256: `7073843ebcafeb9146208221510594c9d38bd6efbb67acdb0556a3c4d32654a4`.
Model.lean, Witnesses.lean and DurableWitnesses.lean remain byte-identical to
cbf8f3e. All 199 public elaborated types compare byte-identical to the accepted
freeze. The 232 accepted types below include 33 historical helper types; current
helper additions are recorded in the checkpoint-freeze.json receipt.

The required local build passed 26 jobs. Axiom census: 928 declarations,
182 public PROVED, 17 public OPEN, 52 proved helpers and 677 axiom-clean
witness/support declarations. This gate permits the explicitly recorded OPEN
public obligations only for the partial checkpoint; it is not the final gate.

Evidence: `/code/mpfs-onchain-lean-128-20261029/astra-durable-witnesses-model/evidence/proofs/checkpoint-receipt.json`,
checkpoint-build.log, checkpoint-types.log and checkpoint-axioms.log.
The receipt contains source/log hashes, every PROVED and OPEN name, the exact
public freeze comparison, and protected-file hashes. Earlier repair and mutation
receipts remain under evidence/repair-1 and evidence/repair-2; their audit
attribution corrections remain in the atom rows above.

Remaining obligations:

- folder_discovery_executable
- fold_value_conservation
- reachable_witness_bijection
- live_witness_fact
- live_witness_presence
- live_witness_absence
- one_live_witness_per_key
- witness_spent_only_at_own_key
- untouched_witness_survives
- fold_deposits_conserved
- live_outputs_hold_deposits
- witness_output_custody
- touched_old_witness_burned
- requests_unique_on_trace
- witness_reference_sound
- witness_durability
- witness_deposit_lock

Continuation: handoffs/proofs-capacity-1.md under the creator runtime. No ruling
is needed to resume proof work. No PROOF-COMPLETE is claimed.

## Full accepted elaborated statement types (cbf8f3e)

### RequestApprovalFold.applyAll_append

```lean
RequestApprovalFold.applyAll_append : ∀ (t : RequestApprovalFold.Trie) (xs ys : List.{0} RequestApprovalFold.Write),
  @Eq.{1} RequestApprovalFold.Trie
    (RequestApprovalFold.applyAll t
      (@HAppend.hAppend.{0, 0, 0} (List.{0} RequestApprovalFold.Write) (List.{0} RequestApprovalFold.Write)
        (List.{0} RequestApprovalFold.Write)
        (@instHAppendOfAppend.{0} (List.{0} RequestApprovalFold.Write) (@List.instAppend.{0} RequestApprovalFold.Write))
        xs ys))
    (RequestApprovalFold.applyAll (RequestApprovalFold.applyAll t xs) ys)
```

### RequestApprovalFold.foldRun_step_valid

```lean
@RequestApprovalFold.foldRun_step_valid : ∀ {iv : RequestApprovalFold.Interval}
  {refs : List.{0} RequestApprovalFold.TokenName} {sigs : List.{0} RequestApprovalFold.Signer}
  {c out : RequestApprovalFold.CageState} {items : List.{0} RequestApprovalFold.FoldItem},
  RequestApprovalFold.FoldRun iv refs sigs c items out →
    ∀ (n : Nat) (item : RequestApprovalFold.FoldItem),
      @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
          (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
            (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
              @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
            (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) items n)
          (@Option.some.{0} RequestApprovalFold.FoldItem item) →
        RequestApprovalFold.itemAllowed
          (RequestApprovalFold.foldResult c (@List.take.{0} RequestApprovalFold.FoldItem n items)) iv refs sigs item
```

### RequestApprovalFold.foldRun_result

```lean
@RequestApprovalFold.foldRun_result : ∀ {iv : RequestApprovalFold.Interval}
  {refs : List.{0} RequestApprovalFold.TokenName} {sigs : List.{0} RequestApprovalFold.Signer}
  {c out : RequestApprovalFold.CageState} {items : List.{0} RequestApprovalFold.FoldItem},
  RequestApprovalFold.FoldRun iv refs sigs c items out →
    @Eq.{1} RequestApprovalFold.CageState out (RequestApprovalFold.foldResult c items)
```

### RequestApprovalFold.foldRun_conditions

```lean
@RequestApprovalFold.foldRun_conditions : ∀ {iv : RequestApprovalFold.Interval}
  {refs : List.{0} RequestApprovalFold.TokenName} {sigs : List.{0} RequestApprovalFold.Signer}
  {c out : RequestApprovalFold.CageState} {items : List.{0} RequestApprovalFold.FoldItem},
  RequestApprovalFold.FoldRun iv refs sigs c items out →
    ∀ (n : Nat) (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
      @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
          (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
            (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
              @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
            (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) items n)
          (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)) →
        ∀ (condition : RequestApprovalFold.Condition),
          @Membership.mem.{0, 0} RequestApprovalFold.Condition (List.{0} RequestApprovalFold.Condition)
              (@List.instMembership.{0} RequestApprovalFold.Condition)
              (RequestApprovalFold.Request.conditions (RequestApprovalFold.RequestOutput.request o)) condition →
            RequestApprovalFold.Condition.holds
              (RequestApprovalFold.CageState.trie
                (RequestApprovalFold.foldResult c (@List.take.{0} RequestApprovalFold.FoldItem n items)))
              condition
```

### RequestApprovalFold.applyAll_keeps_present

```lean
RequestApprovalFold.applyAll_keeps_present : ∀ (k : RequestApprovalFold.Key) (ws : List.{0} RequestApprovalFold.Write)
  (t : RequestApprovalFold.Trie),
  (∀ (w : RequestApprovalFold.Write),
      @Membership.mem.{0, 0} RequestApprovalFold.Write (List.{0} RequestApprovalFold.Write)
          (@List.instMembership.{0} RequestApprovalFold.Write) ws w →
        @Ne.{1} RequestApprovalFold.Write w (RequestApprovalFold.Write.unset k)) →
    @Eq.{1} Bool (@Option.isSome.{0} RequestApprovalFold.Val (t k)) Bool.true →
      @Eq.{1} Bool (@Option.isSome.{0} RequestApprovalFold.Val (RequestApprovalFold.applyAll t ws k)) Bool.true
```

### RequestApprovalFold.registry_creation

```lean
RequestApprovalFold.registry_creation : ∀ (c : RequestApprovalFold.CageState)
  (existing : List.{0} RequestApprovalFold.CageId),
  RequestApprovalFold.registryCreated c existing →
    And
      (Not
        (@Membership.mem.{0, 0} RequestApprovalFold.CageId (List.{0} RequestApprovalFold.CageId)
          (@List.instMembership.{0} RequestApprovalFold.CageId) existing (RequestApprovalFold.CageState.id c)))
      (And
        (Or
          (@Ne.{1} (List.{0} RequestApprovalFold.Oracle) (RequestApprovalFold.CageState.oracles c)
            (@List.nil.{0} RequestApprovalFold.Oracle))
          (@Eq.{1} Bool (@Option.isSome.{0} RequestApprovalFold.Rule (RequestApprovalFold.CageState.rule c)) Bool.true))
        (And (@List.Nodup.{0} RequestApprovalFold.Oracle (RequestApprovalFold.CageState.oracles c))
          (And
            (@LT.lt.{0} Nat instLTNat (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0)))
              (RequestApprovalFold.CageState.minimum c))
            (And
              (@Eq.{1} RequestApprovalFold.EntryTree (RequestApprovalFold.CageState.tree c)
                RequestApprovalFold.emptyEntries)
              (And
                (@Eq.{1} RequestApprovalFold.Trie (RequestApprovalFold.CageState.trie c) RequestApprovalFold.emptyTrie)
                (And
                  (@Eq.{1} (RequestApprovalFold.Signer → Nat) (RequestApprovalFold.CageState.balances c)
                    fun (x : RequestApprovalFold.Signer) => @OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0)))
                  (@Eq.{1} Nat (RequestApprovalFold.CageState.value c)
                    (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0))))))))))
```

### RequestApprovalFold.create_tags_existing_cage

```lean
RequestApprovalFold.create_tags_existing_cage : ∀ (tx : RequestApprovalFold.CreateTx)
  (o : RequestApprovalFold.RequestOutput),
  RequestApprovalFold.createAllowed tx o →
    And
      (@Ne.{1} (List.{0} RequestApprovalFold.Oracle)
          (RequestApprovalFold.CageState.oracles (RequestApprovalFold.CreateTx.cageRef tx))
          (@List.nil.{0} RequestApprovalFold.Oracle) →
        @Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
          (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.CreateTx.spent tx)
          (RequestApprovalFold.Request.seed (RequestApprovalFold.RequestOutput.request o)))
      (And
        (@Eq.{1} (List.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.CreateTx.outputs tx)
          (@List.cons.{0} RequestApprovalFold.RequestOutput o (@List.nil.{0} RequestApprovalFold.RequestOutput)))
        (And
          (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.CreateTx.minted tx)
            (@HAppend.hAppend.{0, 0, 0} (List.{0} RequestApprovalFold.TokenName)
              (List.{0} RequestApprovalFold.TokenName) (List.{0} RequestApprovalFold.TokenName)
              (@instHAppendOfAppend.{0} (List.{0} RequestApprovalFold.TokenName)
                (@List.instAppend.{0} RequestApprovalFold.TokenName))
              (@List.map.{0, 0} RequestApprovalFold.Oracle RequestApprovalFold.TokenName RequestApprovalFold.tagName
                (RequestApprovalFold.CageState.oracles (RequestApprovalFold.CreateTx.cageRef tx)))
              (@List.cons.{0} RequestApprovalFold.TokenName
                (RequestApprovalFold.requestName
                  (RequestApprovalFold.CageState.id (RequestApprovalFold.CreateTx.cageRef tx)))
                (@List.nil.{0} RequestApprovalFold.TokenName))))
          (And
            (@Eq.{1} RequestApprovalFold.CageId
              (RequestApprovalFold.Request.cage (RequestApprovalFold.RequestOutput.request o))
              (RequestApprovalFold.CageState.id (RequestApprovalFold.CreateTx.cageRef tx)))
            (And
              (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.RequestOutput.tags o)
                (@List.map.{0, 0} RequestApprovalFold.Oracle RequestApprovalFold.TokenName RequestApprovalFold.tagName
                  (RequestApprovalFold.CageState.oracles (RequestApprovalFold.CreateTx.cageRef tx))))
              (@LE.le.{0} Nat instLENat
                (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
                  (RequestApprovalFold.totalFees (RequestApprovalFold.CreateTx.cageRef tx)
                    (RequestApprovalFold.RequestOutput.request o))
                  (RequestApprovalFold.CageState.minimum (RequestApprovalFold.CreateTx.cageRef tx)))
                (RequestApprovalFold.RequestOutput.value o))))))
```

### RequestApprovalFold.requests_unique_in_history

```lean
RequestApprovalFold.requests_unique_in_history : ∀ (history : List.{0} RequestApprovalFold.CreateTx)
  (a b : RequestApprovalFold.CreateTx) (oa ob : RequestApprovalFold.RequestOutput),
  RequestApprovalFold.SpentOnce history →
    @Membership.mem.{0, 0} RequestApprovalFold.CreateTx (List.{0} RequestApprovalFold.CreateTx)
        (@List.instMembership.{0} RequestApprovalFold.CreateTx) history a →
      @Membership.mem.{0, 0} RequestApprovalFold.CreateTx (List.{0} RequestApprovalFold.CreateTx)
          (@List.instMembership.{0} RequestApprovalFold.CreateTx) history b →
        RequestApprovalFold.createAllowed a oa →
          RequestApprovalFold.createAllowed b ob →
            @Ne.{1} (List.{0} RequestApprovalFold.Oracle)
                (RequestApprovalFold.CageState.oracles (RequestApprovalFold.CreateTx.cageRef a))
                (@List.nil.{0} RequestApprovalFold.Oracle) →
              @Ne.{1} (List.{0} RequestApprovalFold.Oracle)
                  (RequestApprovalFold.CageState.oracles (RequestApprovalFold.CreateTx.cageRef b))
                  (@List.nil.{0} RequestApprovalFold.Oracle) →
                @Ne.{1} RequestApprovalFold.CreateTx a b →
                  @Ne.{1} RequestApprovalFold.Request (RequestApprovalFold.RequestOutput.request oa)
                    (RequestApprovalFold.RequestOutput.request ob)
```

### RequestApprovalFold.judgment_authorized_and_bound

```lean
RequestApprovalFold.judgment_authorized_and_bound : ∀ (tx : RequestApprovalFold.JudgmentTx),
  RequestApprovalFold.judgmentAllowed tx →
    And
      (@Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
        (@List.instMembership.{0} RequestApprovalFold.Oracle)
        (RequestApprovalFold.CageState.oracles (RequestApprovalFold.JudgmentTx.cageRef tx))
        (RequestApprovalFold.JudgmentTx.oracle tx))
      (And
        (@Eq.{1} (Option.{0} OracleIdentity.SigningRecord)
          (OracleIdentity.authorize (RequestApprovalFold.JudgmentTx.oracle tx)
            (RequestApprovalFold.Evidence.description (RequestApprovalFold.JudgmentTx.evidence tx))
            (RequestApprovalFold.JudgmentTx.signers tx))
          (@Option.some.{0} RequestApprovalFold.SigningRecord
            (RequestApprovalFold.Evidence.record (RequestApprovalFold.JudgmentTx.evidence tx))))
        (And (RequestApprovalFold.Interval.valid (RequestApprovalFold.JudgmentTx.interval tx))
          (And
            (@LT.lt.{0} RequestApprovalFold.Time instLTNat
              (RequestApprovalFold.Interval.upper (RequestApprovalFold.JudgmentTx.interval tx))
              (RequestApprovalFold.Request.deadline
                (RequestApprovalFold.RequestOutput.request (RequestApprovalFold.JudgmentTx.requestRef tx))))
            (And
              (@Eq.{1} (List.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.JudgmentTx.spent tx)
                (@List.nil.{0} RequestApprovalFold.OutputRef))
              (And
                (@Eq.{1} RequestApprovalFold.CageId
                  (RequestApprovalFold.Request.cage
                    (RequestApprovalFold.RequestOutput.request (RequestApprovalFold.JudgmentTx.requestRef tx)))
                  (RequestApprovalFold.CageState.id (RequestApprovalFold.JudgmentTx.cageRef tx)))
                (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.JudgmentTx.minted tx)
                  (@List.cons.{0} RequestApprovalFold.TokenName
                    (RequestApprovalFold.judgmentName
                      (RequestApprovalFold.CageState.id (RequestApprovalFold.JudgmentTx.cageRef tx))
                      (RequestApprovalFold.RequestOutput.request (RequestApprovalFold.JudgmentTx.requestRef tx))
                      (RequestApprovalFold.JudgmentTx.oracle tx)
                      (RequestApprovalFold.Evidence.approve (RequestApprovalFold.JudgmentTx.evidence tx))
                      (RequestApprovalFold.Evidence.record (RequestApprovalFold.JudgmentTx.evidence tx))
                      (RequestApprovalFold.Evidence.conditions (RequestApprovalFold.JudgmentTx.evidence tx)))
                    (@List.nil.{0} RequestApprovalFold.TokenName))))))))
```

### RequestApprovalFold.judgment_not_replayable

```lean
RequestApprovalFold.judgment_not_replayable : ∀ (c c' : RequestApprovalFold.CageId) (r r' : RequestApprovalFold.Request)
  (o o' : RequestApprovalFold.Oracle) (v v' : Bool) (rec rec' : RequestApprovalFold.SigningRecord)
  (cs cs' : List.{0} RequestApprovalFold.Condition),
  @Eq.{1} RequestApprovalFold.TokenName (RequestApprovalFold.judgmentName c r o v rec cs)
      (RequestApprovalFold.judgmentName c' r' o' v' rec' cs') →
    And (@Eq.{1} RequestApprovalFold.CageId c c')
      (And (@Eq.{1} RequestApprovalFold.Request r r')
        (And (@Eq.{1} RequestApprovalFold.Oracle o o')
          (And (@Eq.{1} Bool v v')
            (And (@Eq.{1} RequestApprovalFold.SigningRecord rec rec')
              (@Eq.{1} Bool v Bool.true → @Eq.{1} (List.{0} RequestApprovalFold.Condition) cs cs')))))
```

### RequestApprovalFold.token_roles_separated

```lean
RequestApprovalFold.token_roles_separated : ∀ (o o' : RequestApprovalFold.Oracle) (c : RequestApprovalFold.CageId)
  (r : RequestApprovalFold.Request) (v : Bool) (rec : RequestApprovalFold.SigningRecord)
  (cs : List.{0} RequestApprovalFold.Condition),
  @Ne.{1} RequestApprovalFold.TokenName (RequestApprovalFold.tagName o)
    (RequestApprovalFold.judgmentName c r o' v rec cs)
```

### RequestApprovalFold.fold_preserves_registry

```lean
RequestApprovalFold.fold_preserves_registry : ∀ (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.foldAccepted tx →
    RequestApprovalFold.SameRegistry (RequestApprovalFold.FoldTx.cageOut tx) (RequestApprovalFold.FoldTx.cageIn tx)
```

### RequestApprovalFold.step_preserves_registry

```lean
@RequestApprovalFold.step_preserves_registry : ∀ {s s' : RequestApprovalFold.State} {a : RequestApprovalFold.Action},
  RequestApprovalFold.Step s a s' →
    RequestApprovalFold.SameRegistry (RequestApprovalFold.State.cage s') (RequestApprovalFold.State.cage s)
```

### RequestApprovalFold.history_preserves_registry

```lean
@RequestApprovalFold.history_preserves_registry : ∀ {s s' : RequestApprovalFold.State},
  RequestApprovalFold.History s s' →
    RequestApprovalFold.SameRegistry (RequestApprovalFold.State.cage s') (RequestApprovalFold.State.cage s)
```

### RequestApprovalFold.only_fold_changes_tree

```lean
@RequestApprovalFold.only_fold_changes_tree : ∀ {s s' : RequestApprovalFold.State} {a : RequestApprovalFold.Action},
  RequestApprovalFold.Step s a s' →
    @Ne.{1} RequestApprovalFold.Trie (RequestApprovalFold.CageState.trie (RequestApprovalFold.State.cage s'))
        (RequestApprovalFold.CageState.trie (RequestApprovalFold.State.cage s)) →
      @Exists.{1} RequestApprovalFold.FoldTx fun (tx : RequestApprovalFold.FoldTx) =>
        And (@Eq.{1} RequestApprovalFold.Action a (RequestApprovalFold.Action.fold tx))
          (And (RequestApprovalFold.foldAccepted tx)
            (And
              (@Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.FoldTx.cageIn tx)
                (RequestApprovalFold.State.cage s))
              (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterFold s tx))))
```

### RequestApprovalFold.fold_only_approved_before_deadline

```lean
RequestApprovalFold.fold_only_approved_before_deadline : ∀ (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.foldAccepted tx →
    ∀ (n : Nat) (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
      @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
          (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
            (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
              @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
            (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
          (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)) →
        And
          (@Eq.{1} RequestApprovalFold.CageId
            (RequestApprovalFold.Request.cage (RequestApprovalFold.RequestOutput.request o))
            (RequestApprovalFold.CageState.id (RequestApprovalFold.FoldTx.cageIn tx)))
          (And
            (@LT.lt.{0} RequestApprovalFold.Time instLTNat
              (RequestApprovalFold.Interval.upper (RequestApprovalFold.FoldTx.interval tx))
              (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o)))
            (RequestApprovalFold.hasApproval (RequestApprovalFold.atTurn tx n)
              (RequestApprovalFold.RequestOutput.request o) (RequestApprovalFold.FoldTx.refs tx)
              (RequestApprovalFold.FoldTx.signers tx) e))
```

### RequestApprovalFold.fold_conditions_hold_when_applied

```lean
RequestApprovalFold.fold_conditions_hold_when_applied : ∀ (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.foldAccepted tx →
    ∀ (n : Nat) (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
      @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
          (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
            (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
              @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
            (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
          (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)) →
        ∀ (condition : RequestApprovalFold.Condition),
          @Membership.mem.{0, 0} RequestApprovalFold.Condition (List.{0} RequestApprovalFold.Condition)
              (@List.instMembership.{0} RequestApprovalFold.Condition)
              (RequestApprovalFold.Request.conditions (RequestApprovalFold.RequestOutput.request o)) condition →
            RequestApprovalFold.Condition.holds (RequestApprovalFold.CageState.trie (RequestApprovalFold.atTurn tx n))
              condition
```

### RequestApprovalFold.fold_root_is_folded_writes

```lean
RequestApprovalFold.fold_root_is_folded_writes : ∀ (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.foldAccepted tx →
    @Eq.{1} RequestApprovalFold.Trie (RequestApprovalFold.CageState.trie (RequestApprovalFold.FoldTx.cageOut tx))
      (RequestApprovalFold.applyAll (RequestApprovalFold.CageState.trie (RequestApprovalFold.FoldTx.cageIn tx))
        (@List.flatMap.{0, 0} RequestApprovalFold.FoldItem RequestApprovalFold.Write RequestApprovalFold.FoldItem.writes
          (RequestApprovalFold.FoldTx.items tx)))
```

### RequestApprovalFold.fold_burns_tags

```lean
RequestApprovalFold.fold_burns_tags : ∀ (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.foldAccepted tx →
    @Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.FoldTx.burned tx)
      (@List.flatMap.{0, 0} RequestApprovalFold.FoldItem RequestApprovalFold.TokenName
        RequestApprovalFold.FoldItem.burned (RequestApprovalFold.FoldTx.items tx))
```

### RequestApprovalFold.fold_pays_and_keeps_rest

```lean
RequestApprovalFold.fold_pays_and_keeps_rest : ∀ (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.foldAccepted tx →
    ∀ (n : Nat) (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
      @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
          (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
            (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
              @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
            (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
          (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)) →
        And
          (@Eq.{1} (RequestApprovalFold.Signer → Nat)
            (RequestApprovalFold.CageState.balances
              (RequestApprovalFold.itemResult (RequestApprovalFold.atTurn tx n)
                (RequestApprovalFold.FoldItem.write o e)))
            fun (k : RequestApprovalFold.Signer) =>
            @HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
              (RequestApprovalFold.CageState.balances (RequestApprovalFold.atTurn tx n) k)
              (OracleIdentity.paidTo
                (RequestApprovalFold.credits (RequestApprovalFold.atTurn tx n)
                  (RequestApprovalFold.RequestOutput.request o) e)
                k))
          (And
            (@Eq.{1} (List.{0} RequestApprovalFold.Payment)
              (RequestApprovalFold.itemPayments (RequestApprovalFold.atTurn tx n) (RequestApprovalFold.FoldTx.folder tx)
                (RequestApprovalFold.FoldItem.write o e))
              (@HAppend.hAppend.{0, 0, 0} (List.{0} RequestApprovalFold.Payment) (List.{0} RequestApprovalFold.Payment)
                (List.{0} RequestApprovalFold.Payment)
                (@instHAppendOfAppend.{0} (List.{0} RequestApprovalFold.Payment)
                  (@List.instAppend.{0} RequestApprovalFold.Payment))
                (@List.cons.{0} RequestApprovalFold.Payment
                  (RequestApprovalFold.Payment.mk (RequestApprovalFold.FoldTx.folder tx) ""
                    (@HSub.hSub.{0, 0, 0} Nat Nat Nat (@instHSub.{0} Nat instSubNat)
                      (RequestApprovalFold.RequestOutput.value o)
                      (RequestApprovalFold.totalFees (RequestApprovalFold.FoldTx.cageIn tx)
                        (RequestApprovalFold.RequestOutput.request o))))
                  (@List.nil.{0} RequestApprovalFold.Payment))
                (RequestApprovalFold.itemWitnessRefunds (RequestApprovalFold.atTurn tx n)
                  (RequestApprovalFold.FoldItem.write o e))))
            (∀ (oracle : RequestApprovalFold.Oracle),
              @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
                  (@List.instMembership.{0} RequestApprovalFold.Oracle)
                  (RequestApprovalFold.CageState.oracles (RequestApprovalFold.FoldTx.cageIn tx)) oracle →
                @Eq.{1} Nat
                  (OracleIdentity.totalPaid
                    (RequestApprovalFold.oracleCredits (RequestApprovalFold.RequestOutput.request o) oracle (e oracle)))
                  (RequestApprovalFold.Request.fee (RequestApprovalFold.RequestOutput.request o) oracle)))
```

### RequestApprovalFold.allocation_conserves_value

```lean
RequestApprovalFold.allocation_conserves_value : ∀ (c : RequestApprovalFold.CageState)
  (iv : RequestApprovalFold.Interval) (refs : List.{0} RequestApprovalFold.TokenName)
  (sigs : List.{0} RequestApprovalFold.Signer) (o : RequestApprovalFold.RequestOutput)
  (e : RequestApprovalFold.Selection),
  Or (RequestApprovalFold.stepValid c iv refs sigs e o) (RequestApprovalFold.accountAllowed c iv refs o e) →
    @Eq.{1} Nat (RequestApprovalFold.RequestOutput.escrow o)
      (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
        (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
          (OracleIdentity.totalPaid (RequestApprovalFold.credits c (RequestApprovalFold.RequestOutput.request o) e))
          (RequestApprovalFold.remainder c o))
        (RequestApprovalFold.Request.deposit (RequestApprovalFold.RequestOutput.request o)))
```

### RequestApprovalFold.blind_write_folds_on_any_tree

```lean
RequestApprovalFold.blind_write_folds_on_any_tree : ∀ (c : RequestApprovalFold.CageState)
  (iv : RequestApprovalFold.Interval) (refs : List.{0} RequestApprovalFold.TokenName)
  (sigs : List.{0} RequestApprovalFold.Signer) (o : RequestApprovalFold.RequestOutput)
  (e : RequestApprovalFold.Selection),
  RequestApprovalFold.wellFormed c o →
    RequestApprovalFold.Interval.valid iv →
      @LT.lt.{0} RequestApprovalFold.Time instLTNat (RequestApprovalFold.Interval.upper iv)
          (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o)) →
        RequestApprovalFold.hasApproval c (RequestApprovalFold.RequestOutput.request o) refs sigs e →
          @Eq.{1} (List.{0} RequestApprovalFold.Condition)
              (RequestApprovalFold.Request.conditions (RequestApprovalFold.RequestOutput.request o))
              (@List.nil.{0} RequestApprovalFold.Condition) →
            (∀ (oracle : RequestApprovalFold.Oracle),
                @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
                    (@List.instMembership.{0} RequestApprovalFold.Oracle) (RequestApprovalFold.CageState.oracles c)
                    oracle →
                  @Eq.{1} (List.{0} RequestApprovalFold.Condition) (RequestApprovalFold.Evidence.conditions (e oracle))
                    (@List.nil.{0} RequestApprovalFold.Condition)) →
              @Eq.{1} (Option.{0} RequestApprovalFold.WitnessSpec)
                  (RequestApprovalFold.Request.witnessing (RequestApprovalFold.RequestOutput.request o))
                  (@Option.none.{0} RequestApprovalFold.WitnessSpec) →
                ∀ (t : RequestApprovalFold.EntryTree),
                  And
                    (RequestApprovalFold.FoldRun iv refs sigs
                      (RequestApprovalFold.CageState.mk (RequestApprovalFold.CageState.id c)
                        (RequestApprovalFold.CageState.oracles c) (RequestApprovalFold.CageState.protocol c) t
                        (RequestApprovalFold.CageState.rule c) (RequestApprovalFold.CageState.balances c)
                        (RequestApprovalFold.CageState.value c) (RequestApprovalFold.CageState.minimum c))
                      (@List.cons.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)
                        (@List.nil.{0} RequestApprovalFold.FoldItem))
                      (RequestApprovalFold.itemResult
                        (RequestApprovalFold.CageState.mk (RequestApprovalFold.CageState.id c)
                          (RequestApprovalFold.CageState.oracles c) (RequestApprovalFold.CageState.protocol c) t
                          (RequestApprovalFold.CageState.rule c) (RequestApprovalFold.CageState.balances c)
                          (RequestApprovalFold.CageState.value c) (RequestApprovalFold.CageState.minimum c))
                        (RequestApprovalFold.FoldItem.write o e)))
                    (@Eq.{1} RequestApprovalFold.Trie
                      (RequestApprovalFold.CageState.trie
                        (RequestApprovalFold.itemResult
                          (RequestApprovalFold.CageState.mk (RequestApprovalFold.CageState.id c)
                            (RequestApprovalFold.CageState.oracles c) (RequestApprovalFold.CageState.protocol c) t
                            (RequestApprovalFold.CageState.rule c) (RequestApprovalFold.CageState.balances c)
                            (RequestApprovalFold.CageState.value c) (RequestApprovalFold.CageState.minimum c))
                          (RequestApprovalFold.FoldItem.write o e)))
                      (RequestApprovalFold.Write.apply (RequestApprovalFold.logicalTree t)
                        (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))))
```

### RequestApprovalFold.fold_permissionless

```lean
RequestApprovalFold.fold_permissionless : ∀ (tx : RequestApprovalFold.FoldTx) (other : RequestApprovalFold.Signer),
  RequestApprovalFold.foldAccepted tx →
    RequestApprovalFold.foldAccepted
      (RequestApprovalFold.FoldTx.mk (RequestApprovalFold.FoldTx.cageIn tx) (RequestApprovalFold.FoldTx.cageOut tx)
        (RequestApprovalFold.FoldTx.items tx) (RequestApprovalFold.FoldTx.refs tx)
        (RequestApprovalFold.FoldTx.signers tx) (RequestApprovalFold.FoldTx.interval tx)
        (RequestApprovalFold.FoldTx.folder tx) other (RequestApprovalFold.FoldTx.burned tx)
        (RequestApprovalFold.FoldTx.payments tx) (RequestApprovalFold.FoldTx.witnessEvents tx)
        (RequestApprovalFold.FoldTx.witnessInputs tx) (RequestApprovalFold.FoldTx.witnessOutputs tx)
        (RequestApprovalFold.FoldTx.witnessBurned tx) (RequestApprovalFold.FoldTx.witnessMinted tx))
```

### RequestApprovalFold.absent_inserts_exclusive

```lean
RequestApprovalFold.absent_inserts_exclusive : ∀ (tx : RequestApprovalFold.FoldTx) (n m : Nat)
  (a b : RequestApprovalFold.RequestOutput) (ea eb : RequestApprovalFold.Selection) (k : RequestApprovalFold.Key)
  (v : RequestApprovalFold.Val),
  RequestApprovalFold.foldAccepted tx →
    @LT.lt.{0} Nat instLTNat n m →
      @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
          (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
            (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
              @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
            (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
          (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write a ea)) →
        @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
            (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
              (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
                @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
              (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) m)
            (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write b eb)) →
          @Eq.{1} RequestApprovalFold.Write
              (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request a))
              (RequestApprovalFold.Write.set k v) →
            @Membership.mem.{0, 0} RequestApprovalFold.Condition (List.{0} RequestApprovalFold.Condition)
                (@List.instMembership.{0} RequestApprovalFold.Condition)
                (RequestApprovalFold.Request.conditions (RequestApprovalFold.RequestOutput.request b))
                (RequestApprovalFold.Condition.absent k) →
              @Membership.mem.{0, 0} RequestApprovalFold.Write (List.{0} RequestApprovalFold.Write)
                (@List.instMembership.{0} RequestApprovalFold.Write)
                (@List.flatMap.{0, 0} RequestApprovalFold.FoldItem RequestApprovalFold.Write
                  RequestApprovalFold.FoldItem.writes
                  (@List.take.{0} RequestApprovalFold.FoldItem
                    (@HSub.hSub.{0, 0, 0} Nat Nat Nat (@instHSub.{0} Nat instSubNat) m
                      (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat) n
                        (@OfNat.ofNat.{0} Nat (nat_lit 1) (instOfNatNat (nat_lit 1)))))
                    (@List.drop.{0} RequestApprovalFold.FoldItem
                      (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat) n
                        (@OfNat.ofNat.{0} Nat (nat_lit 1) (instOfNatNat (nat_lit 1))))
                      (RequestApprovalFold.FoldTx.items tx))))
                (RequestApprovalFold.Write.unset k)
```

### RequestApprovalFold.account_complete_and_pays

```lean
RequestApprovalFold.account_complete_and_pays : ∀ (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.foldAccepted tx →
    ∀ (n : Nat) (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
      @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
          (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
            (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
              @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
            (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
          (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.account o e)) →
        And
          (RequestApprovalFold.hasAccount (RequestApprovalFold.atTurn tx n)
            (RequestApprovalFold.RequestOutput.request o) (RequestApprovalFold.FoldTx.refs tx) e)
          (And
            (@Eq.{1} (RequestApprovalFold.Signer → Nat)
              (RequestApprovalFold.CageState.balances
                (RequestApprovalFold.itemResult (RequestApprovalFold.atTurn tx n)
                  (RequestApprovalFold.FoldItem.account o e)))
              fun (k : RequestApprovalFold.Signer) =>
              @HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
                (RequestApprovalFold.CageState.balances (RequestApprovalFold.atTurn tx n) k)
                (OracleIdentity.paidTo
                  (RequestApprovalFold.credits (RequestApprovalFold.atTurn tx n)
                    (RequestApprovalFold.RequestOutput.request o) e)
                  k))
            (And
              (@Eq.{1} RequestApprovalFold.Trie
                (RequestApprovalFold.CageState.trie
                  (RequestApprovalFold.itemResult (RequestApprovalFold.atTurn tx n)
                    (RequestApprovalFold.FoldItem.account o e)))
                (RequestApprovalFold.CageState.trie (RequestApprovalFold.atTurn tx n)))
              (And
                (@Eq.{1} (List.{0} RequestApprovalFold.Payment)
                  (RequestApprovalFold.itemPayments (RequestApprovalFold.atTurn tx n)
                    (RequestApprovalFold.FoldTx.folder tx) (RequestApprovalFold.FoldItem.account o e))
                  (@HAppend.hAppend.{0, 0, 0} (List.{0} RequestApprovalFold.Payment)
                    (List.{0} RequestApprovalFold.Payment) (List.{0} RequestApprovalFold.Payment)
                    (@instHAppendOfAppend.{0} (List.{0} RequestApprovalFold.Payment)
                      (@List.instAppend.{0} RequestApprovalFold.Payment))
                    (@List.cons.{0} RequestApprovalFold.Payment
                      (RequestApprovalFold.Payment.mk
                        (RequestApprovalFold.Request.owner (RequestApprovalFold.RequestOutput.request o)) ""
                        (RequestApprovalFold.remainder (RequestApprovalFold.FoldTx.cageIn tx) o))
                      (@List.nil.{0} RequestApprovalFold.Payment))
                    (RequestApprovalFold.unusedDepositPayments o)))
                (@Eq.{1} Nat
                  (OracleIdentity.totalPaid
                    (RequestApprovalFold.credits (RequestApprovalFold.atTurn tx n)
                      (RequestApprovalFold.RequestOutput.request o) e))
                  (RequestApprovalFold.totalFees (RequestApprovalFold.FoldTx.cageIn tx)
                    (RequestApprovalFold.RequestOutput.request o))))))
```

### RequestApprovalFold.account_anyone_in_window

```lean
RequestApprovalFold.account_anyone_in_window : ∀ (s : RequestApprovalFold.State) (o : RequestApprovalFold.RequestOutput)
  (e : RequestApprovalFold.Selection) (iv : RequestApprovalFold.Interval) (who : RequestApprovalFold.Signer),
  @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
      (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o →
    RequestApprovalFold.wellFormed (RequestApprovalFold.State.cage s) o →
      RequestApprovalFold.hasAccount (RequestApprovalFold.State.cage s) (RequestApprovalFold.RequestOutput.request o)
          (RequestApprovalFold.State.judgments s) e →
        RequestApprovalFold.Interval.valid iv →
          @LE.le.{0} RequestApprovalFold.Time instLENat
              (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o))
              (RequestApprovalFold.Interval.lower iv) →
            @LE.le.{0} RequestApprovalFold.Time instLENat (RequestApprovalFold.Interval.upper iv)
                (@HAdd.hAdd.{0, 0, 0} RequestApprovalFold.Time Nat RequestApprovalFold.Time
                  (@instHAdd.{0} RequestApprovalFold.Time instAddNat)
                  (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o))
                  (RequestApprovalFold.Request.window (RequestApprovalFold.RequestOutput.request o))) →
              RequestApprovalFold.Step s
                (RequestApprovalFold.Action.fold
                  (RequestApprovalFold.singletonFold s iv (@List.nil.{0} RequestApprovalFold.Signer)
                    (RequestApprovalFold.FoldItem.account o e) who))
                (RequestApprovalFold.afterFold s
                  (RequestApprovalFold.singletonFold s iv (@List.nil.{0} RequestApprovalFold.Signer)
                    (RequestApprovalFold.FoldItem.account o e) who))
```

### RequestApprovalFold.account_fee_neutral

```lean
RequestApprovalFold.account_fee_neutral : ∀ (c : RequestApprovalFold.CageState) (iv : RequestApprovalFold.Interval)
  (ra rb : List.{0} RequestApprovalFold.TokenName) (o : RequestApprovalFold.RequestOutput)
  (a b : RequestApprovalFold.Selection) (folder : RequestApprovalFold.Signer),
  RequestApprovalFold.accountAllowed c iv ra o a →
    RequestApprovalFold.accountAllowed c iv rb o b →
      And
        (@Eq.{1} (List.{0} RequestApprovalFold.Payment)
          (RequestApprovalFold.itemPayments c folder (RequestApprovalFold.FoldItem.account o a))
          (RequestApprovalFold.itemPayments c folder (RequestApprovalFold.FoldItem.account o b)))
        (And
          (@Eq.{1} RequestApprovalFold.Trie
            (RequestApprovalFold.CageState.trie
              (RequestApprovalFold.itemResult c (RequestApprovalFold.FoldItem.account o a)))
            (RequestApprovalFold.CageState.trie
              (RequestApprovalFold.itemResult c (RequestApprovalFold.FoldItem.account o b))))
          (And
            (@Eq.{1} Nat
              (OracleIdentity.totalPaid (RequestApprovalFold.credits c (RequestApprovalFold.RequestOutput.request o) a))
              (OracleIdentity.totalPaid
                (RequestApprovalFold.credits c (RequestApprovalFold.RequestOutput.request o) b)))
            (And
              (∀ (oracle : RequestApprovalFold.Oracle),
                @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
                    (@List.instMembership.{0} RequestApprovalFold.Oracle) (RequestApprovalFold.CageState.oracles c)
                    oracle →
                  @Eq.{1} Nat
                    (OracleIdentity.totalPaid
                      (RequestApprovalFold.oracleCredits (RequestApprovalFold.RequestOutput.request o) oracle
                        (a oracle)))
                    (OracleIdentity.totalPaid
                      (RequestApprovalFold.oracleCredits (RequestApprovalFold.RequestOutput.request o) oracle
                        (b oracle))))
              ((∀ (oracle : RequestApprovalFold.Oracle),
                  @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
                      (@List.instMembership.{0} RequestApprovalFold.Oracle) (RequestApprovalFold.CageState.oracles c)
                      oracle →
                    @Eq.{1} RequestApprovalFold.SigningRecord (RequestApprovalFold.Evidence.record (a oracle))
                      (RequestApprovalFold.Evidence.record (b oracle))) →
                @Eq.{1} RequestApprovalFold.CageState
                  (RequestApprovalFold.itemResult c (RequestApprovalFold.FoldItem.account o a))
                  (RequestApprovalFold.itemResult c (RequestApprovalFold.FoldItem.account o b))))))
```

### RequestApprovalFold.withdraw_only_owner_after_window

```lean
RequestApprovalFold.withdraw_only_owner_after_window : ∀ (tx : RequestApprovalFold.WithdrawTx),
  RequestApprovalFold.withdrawAllowed tx →
    And
      (@Membership.mem.{0, 0} RequestApprovalFold.Signer (List.{0} RequestApprovalFold.Signer)
        (@List.instMembership.{0} RequestApprovalFold.Signer) (RequestApprovalFold.WithdrawTx.signers tx)
        (RequestApprovalFold.Request.owner
          (RequestApprovalFold.RequestOutput.request (RequestApprovalFold.WithdrawTx.input tx))))
      (And
        (@LT.lt.{0} RequestApprovalFold.Time instLTNat
          (@HAdd.hAdd.{0, 0, 0} RequestApprovalFold.Time Nat RequestApprovalFold.Time
            (@instHAdd.{0} RequestApprovalFold.Time instAddNat)
            (RequestApprovalFold.Request.deadline
              (RequestApprovalFold.RequestOutput.request (RequestApprovalFold.WithdrawTx.input tx)))
            (RequestApprovalFold.Request.window
              (RequestApprovalFold.RequestOutput.request (RequestApprovalFold.WithdrawTx.input tx))))
          (RequestApprovalFold.Interval.lower (RequestApprovalFold.WithdrawTx.interval tx)))
        (And (RequestApprovalFold.Interval.valid (RequestApprovalFold.WithdrawTx.interval tx))
          (And
            (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.WithdrawTx.burned tx)
              (RequestApprovalFold.tokensOf (RequestApprovalFold.WithdrawTx.input tx)))
            (And
              (@Eq.{1} RequestApprovalFold.Signer (RequestApprovalFold.WithdrawTx.beneficiary tx)
                (RequestApprovalFold.Request.owner
                  (RequestApprovalFold.RequestOutput.request (RequestApprovalFold.WithdrawTx.input tx))))
              (@Eq.{1} Nat (RequestApprovalFold.WithdrawTx.paid tx)
                (RequestApprovalFold.RequestOutput.escrow (RequestApprovalFold.WithdrawTx.input tx)))))))
```

### RequestApprovalFold.owner_can_withdraw_everything

```lean
RequestApprovalFold.owner_can_withdraw_everything : ∀ (o : RequestApprovalFold.RequestOutput)
  (iv : RequestApprovalFold.Interval),
  RequestApprovalFold.Interval.valid iv →
    @LT.lt.{0} RequestApprovalFold.Time instLTNat
        (@HAdd.hAdd.{0, 0, 0} RequestApprovalFold.Time Nat RequestApprovalFold.Time
          (@instHAdd.{0} RequestApprovalFold.Time instAddNat)
          (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o))
          (RequestApprovalFold.Request.window (RequestApprovalFold.RequestOutput.request o)))
        (RequestApprovalFold.Interval.lower iv) →
      RequestApprovalFold.withdrawAllowed
        (RequestApprovalFold.WithdrawTx.mk o iv
          (@List.cons.{0} RequestApprovalFold.Signer
            (RequestApprovalFold.Request.owner (RequestApprovalFold.RequestOutput.request o))
            (@List.nil.{0} RequestApprovalFold.Signer))
          (RequestApprovalFold.tokensOf o)
          (RequestApprovalFold.Request.owner (RequestApprovalFold.RequestOutput.request o))
          (RequestApprovalFold.RequestOutput.escrow o))
```

### RequestApprovalFold.request_spent_only_by_lifecycle

```lean
RequestApprovalFold.request_spent_only_by_lifecycle : ∀ (o : RequestApprovalFold.RequestOutput)
  (spend : RequestApprovalFold.RequestSpend),
  RequestApprovalFold.requestSpendAllowed o spend →
    Or
      (@Exists.{1} RequestApprovalFold.FoldTx fun (tx : RequestApprovalFold.FoldTx) =>
        @Exists.{1} RequestApprovalFold.Selection fun (e : RequestApprovalFold.Selection) =>
          And (@Eq.{1} RequestApprovalFold.RequestSpend spend (RequestApprovalFold.RequestSpend.folded tx))
            (And (RequestApprovalFold.foldAccepted tx)
              (@Membership.mem.{0, 0} RequestApprovalFold.FoldItem (List.{0} RequestApprovalFold.FoldItem)
                (@List.instMembership.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx)
                (RequestApprovalFold.FoldItem.write o e))))
      (Or
        (@Exists.{1} RequestApprovalFold.FoldTx fun (tx : RequestApprovalFold.FoldTx) =>
          @Exists.{1} RequestApprovalFold.Selection fun (e : RequestApprovalFold.Selection) =>
            And (@Eq.{1} RequestApprovalFold.RequestSpend spend (RequestApprovalFold.RequestSpend.folded tx))
              (And (RequestApprovalFold.foldAccepted tx)
                (@Membership.mem.{0, 0} RequestApprovalFold.FoldItem (List.{0} RequestApprovalFold.FoldItem)
                  (@List.instMembership.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx)
                  (RequestApprovalFold.FoldItem.account o e))))
        (@Exists.{1} RequestApprovalFold.WithdrawTx fun (tx : RequestApprovalFold.WithdrawTx) =>
          And (@Eq.{1} RequestApprovalFold.RequestSpend spend (RequestApprovalFold.RequestSpend.withdrawn tx))
            (And (RequestApprovalFold.withdrawAllowed tx)
              (@Eq.{1} RequestApprovalFold.RequestOutput (RequestApprovalFold.WithdrawTx.input tx) o))))
```

### RequestApprovalFold.every_exit_burns_tag

```lean
RequestApprovalFold.every_exit_burns_tag : ∀ (o : RequestApprovalFold.RequestOutput)
  (spend : RequestApprovalFold.RequestSpend),
  RequestApprovalFold.requestSpendAllowed o spend →
    ∀ (tag : RequestApprovalFold.TokenName),
      @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
          (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.tokensOf o) tag →
        @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
          (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.RequestSpend.burned spend) tag
```

### RequestApprovalFold.early_exit_requires_all_judgments

```lean
RequestApprovalFold.early_exit_requires_all_judgments : ∀ (o : RequestApprovalFold.RequestOutput)
  (spend : RequestApprovalFold.RequestSpend),
  RequestApprovalFold.requestSpendAllowed o spend →
    @LE.le.{0} RequestApprovalFold.Time instLENat
        (RequestApprovalFold.Interval.lower (RequestApprovalFold.RequestSpend.interval spend))
        (@HAdd.hAdd.{0, 0, 0} RequestApprovalFold.Time Nat RequestApprovalFold.Time
          (@instHAdd.{0} RequestApprovalFold.Time instAddNat)
          (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o))
          (RequestApprovalFold.Request.window (RequestApprovalFold.RequestOutput.request o))) →
      @Exists.{1} RequestApprovalFold.FoldTx fun (tx : RequestApprovalFold.FoldTx) =>
        @Exists.{1} Nat fun (n : Nat) =>
          @Exists.{1} RequestApprovalFold.Selection fun (e : RequestApprovalFold.Selection) =>
            And (@Eq.{1} RequestApprovalFold.RequestSpend spend (RequestApprovalFold.RequestSpend.folded tx))
              (Or
                (And
                  (@Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
                    (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat
                      RequestApprovalFold.FoldItem
                      (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
                        @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
                      (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem)
                      (RequestApprovalFold.FoldTx.items tx) n)
                    (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)))
                  (RequestApprovalFold.hasApproval (RequestApprovalFold.atTurn tx n)
                    (RequestApprovalFold.RequestOutput.request o) (RequestApprovalFold.FoldTx.refs tx)
                    (RequestApprovalFold.FoldTx.signers tx) e))
                (And
                  (@Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
                    (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat
                      RequestApprovalFold.FoldItem
                      (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
                        @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
                      (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem)
                      (RequestApprovalFold.FoldTx.items tx) n)
                    (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.account o e)))
                  (RequestApprovalFold.hasAccount (RequestApprovalFold.atTurn tx n)
                    (RequestApprovalFold.RequestOutput.request o) (RequestApprovalFold.FoldTx.refs tx) e)))
```

### RequestApprovalFold.early_exit_pays_every_oracle

```lean
RequestApprovalFold.early_exit_pays_every_oracle : ∀ (o : RequestApprovalFold.RequestOutput)
  (spend : RequestApprovalFold.RequestSpend),
  RequestApprovalFold.requestSpendAllowed o spend →
    @LE.le.{0} RequestApprovalFold.Time instLENat
        (RequestApprovalFold.Interval.lower (RequestApprovalFold.RequestSpend.interval spend))
        (@HAdd.hAdd.{0, 0, 0} RequestApprovalFold.Time Nat RequestApprovalFold.Time
          (@instHAdd.{0} RequestApprovalFold.Time instAddNat)
          (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o))
          (RequestApprovalFold.Request.window (RequestApprovalFold.RequestOutput.request o))) →
      @Exists.{1} RequestApprovalFold.FoldTx fun (tx : RequestApprovalFold.FoldTx) =>
        @Exists.{1} Nat fun (n : Nat) =>
          @Exists.{1} RequestApprovalFold.Selection fun (e : RequestApprovalFold.Selection) =>
            And (@Eq.{1} RequestApprovalFold.RequestSpend spend (RequestApprovalFold.RequestSpend.folded tx))
              (And
                (Or
                  (@Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
                    (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat
                      RequestApprovalFold.FoldItem
                      (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
                        @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
                      (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem)
                      (RequestApprovalFold.FoldTx.items tx) n)
                    (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)))
                  (@Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
                    (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat
                      RequestApprovalFold.FoldItem
                      (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
                        @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
                      (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem)
                      (RequestApprovalFold.FoldTx.items tx) n)
                    (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.account o e))))
                (And
                  (∀ (item : RequestApprovalFold.FoldItem),
                    @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
                        (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat
                          RequestApprovalFold.FoldItem
                          (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
                            @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
                          (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem)
                          (RequestApprovalFold.FoldTx.items tx) n)
                        (@Option.some.{0} RequestApprovalFold.FoldItem item) →
                      @Eq.{1} (RequestApprovalFold.Signer → Nat)
                        (RequestApprovalFold.CageState.balances
                          (RequestApprovalFold.itemResult (RequestApprovalFold.atTurn tx n) item))
                        fun (k : RequestApprovalFold.Signer) =>
                        @HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
                          (RequestApprovalFold.CageState.balances (RequestApprovalFold.atTurn tx n) k)
                          (OracleIdentity.paidTo
                            (RequestApprovalFold.credits (RequestApprovalFold.atTurn tx n)
                              (RequestApprovalFold.RequestOutput.request o) e)
                            k))
                  (∀ (oracle : RequestApprovalFold.Oracle),
                    @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
                        (@List.instMembership.{0} RequestApprovalFold.Oracle)
                        (RequestApprovalFold.CageState.oracles (RequestApprovalFold.FoldTx.cageIn tx)) oracle →
                      @Eq.{1} Nat
                        (OracleIdentity.totalPaid
                          (RequestApprovalFold.oracleCredits (RequestApprovalFold.RequestOutput.request o) oracle
                            (e oracle)))
                        (RequestApprovalFold.Request.fee (RequestApprovalFold.RequestOutput.request o) oracle))))
```

### RequestApprovalFold.before_deadline_only_approvals

```lean
RequestApprovalFold.before_deadline_only_approvals : ∀ (o : RequestApprovalFold.RequestOutput)
  (spend : RequestApprovalFold.RequestSpend),
  RequestApprovalFold.requestSpendAllowed o spend →
    @LT.lt.{0} RequestApprovalFold.Time instLTNat
        (RequestApprovalFold.Interval.lower (RequestApprovalFold.RequestSpend.interval spend))
        (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o)) →
      @Exists.{1} RequestApprovalFold.FoldTx fun (tx : RequestApprovalFold.FoldTx) =>
        @Exists.{1} Nat fun (n : Nat) =>
          @Exists.{1} RequestApprovalFold.Selection fun (e : RequestApprovalFold.Selection) =>
            And (@Eq.{1} RequestApprovalFold.RequestSpend spend (RequestApprovalFold.RequestSpend.folded tx))
              (And
                (@Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
                  (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
                    (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
                      @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
                    (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem)
                    (RequestApprovalFold.FoldTx.items tx) n)
                  (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)))
                (RequestApprovalFold.hasApproval (RequestApprovalFold.atTurn tx n)
                  (RequestApprovalFold.RequestOutput.request o) (RequestApprovalFold.FoldTx.refs tx)
                  (RequestApprovalFold.FoldTx.signers tx) e))
```

### RequestApprovalFold.dead_judgment_can_burn

```lean
RequestApprovalFold.dead_judgment_can_burn : ∀ (s : RequestApprovalFold.State) (c : RequestApprovalFold.CageId)
  (r : RequestApprovalFold.Request) (o : RequestApprovalFold.Oracle) (v : Bool)
  (rec : RequestApprovalFold.SigningRecord) (cs : List.{0} RequestApprovalFold.Condition),
  @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
      (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.judgments s)
      (RequestApprovalFold.judgmentName c r o v rec cs) →
    (∀ (output : RequestApprovalFold.RequestOutput),
        @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
            (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) output →
          @Ne.{1} RequestApprovalFold.Request (RequestApprovalFold.RequestOutput.request output) r) →
      And
        (RequestApprovalFold.Step s (RequestApprovalFold.Action.burn (RequestApprovalFold.judgmentName c r o v rec cs))
          (RequestApprovalFold.afterBurn s (RequestApprovalFold.judgmentName c r o v rec cs)))
        (And
          (@Eq.{1} RequestApprovalFold.CageState
            (RequestApprovalFold.State.cage
              (RequestApprovalFold.afterBurn s (RequestApprovalFold.judgmentName c r o v rec cs)))
            (RequestApprovalFold.State.cage s))
          (@Eq.{1} (List.{0} RequestApprovalFold.RequestOutput)
            (RequestApprovalFold.State.live
              (RequestApprovalFold.afterBurn s (RequestApprovalFold.judgmentName c r o v rec cs)))
            (RequestApprovalFold.State.live s)))
```

### RequestApprovalFold.judgments_do_not_consume

```lean
RequestApprovalFold.judgments_do_not_consume : ∀ (s : RequestApprovalFold.State) (tx : RequestApprovalFold.JudgmentTx),
  And
    (@Eq.{1} (List.{0} RequestApprovalFold.RequestOutput)
      (RequestApprovalFold.State.live (RequestApprovalFold.afterJudgment s tx)) (RequestApprovalFold.State.live s))
    (And
      (@Eq.{1} (List.{0} RequestApprovalFold.ClaimOutput)
        (RequestApprovalFold.State.claims (RequestApprovalFold.afterJudgment s tx))
        (RequestApprovalFold.State.claims s))
      (@Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.State.cage (RequestApprovalFold.afterJudgment s tx))
        (RequestApprovalFold.State.cage s)))
```

### RequestApprovalFold.exits_remove_consumed

```lean
RequestApprovalFold.exits_remove_consumed : ∀ (s : RequestApprovalFold.State) (o : RequestApprovalFold.RequestOutput),
  Not
    (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
      (@List.instMembership.{0} RequestApprovalFold.RequestOutput)
      (RequestApprovalFold.State.live (RequestApprovalFold.afterExit s o)) o)
```

### RequestApprovalFold.fold_removes_consumed

```lean
RequestApprovalFold.fold_removes_consumed : ∀ (s : RequestApprovalFold.State) (tx : RequestApprovalFold.FoldTx)
  (o : RequestApprovalFold.RequestOutput),
  @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
      (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.FoldTx.requests tx) o →
    Not
      (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
        (@List.instMembership.{0} RequestApprovalFold.RequestOutput)
        (RequestApprovalFold.State.live (RequestApprovalFold.afterFold s tx)) o)
```

### RequestApprovalFold.used_seeds_monotone

```lean
@RequestApprovalFold.used_seeds_monotone : ∀ {s s' : RequestApprovalFold.State} {a : RequestApprovalFold.Action},
  RequestApprovalFold.Step s a s' →
    ∀ (seed : RequestApprovalFold.OutputRef),
      @Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
          (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedSeeds s) seed →
        @Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
          (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedSeeds s') seed
```

### RequestApprovalFold.reachable_requests_have_spent_seeds

```lean
RequestApprovalFold.reachable_requests_have_spent_seeds : ∀ (s : RequestApprovalFold.State),
  RequestApprovalFold.Reachable s →
    @Ne.{1} (List.{0} RequestApprovalFold.Oracle)
        (RequestApprovalFold.CageState.oracles (RequestApprovalFold.State.cage s))
        (@List.nil.{0} RequestApprovalFold.Oracle) →
      ∀ (o : RequestApprovalFold.RequestOutput),
        @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
            (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o →
          @Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
            (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedSeeds s)
            (RequestApprovalFold.Request.seed (RequestApprovalFold.RequestOutput.request o))
```

### RequestApprovalFold.spent_seed_cannot_create_again

```lean
RequestApprovalFold.spent_seed_cannot_create_again : ∀ (s : RequestApprovalFold.State)
  (tx : RequestApprovalFold.CreateTx) (o : RequestApprovalFold.RequestOutput),
  @Ne.{1} (List.{0} RequestApprovalFold.Oracle)
      (RequestApprovalFold.CageState.oracles (RequestApprovalFold.State.cage s))
      (@List.nil.{0} RequestApprovalFold.Oracle) →
    @Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
        (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedSeeds s)
        (RequestApprovalFold.Request.seed (RequestApprovalFold.RequestOutput.request o)) →
      Not
        (@Exists.{1} RequestApprovalFold.State fun (s' : RequestApprovalFold.State) =>
          RequestApprovalFold.Step s (RequestApprovalFold.Action.create tx o) s')
```

### RequestApprovalFold.request_never_reappears

```lean
RequestApprovalFold.request_never_reappears : ∀ (s s' : RequestApprovalFold.State)
  (o : RequestApprovalFold.RequestOutput),
  RequestApprovalFold.Reachable s →
    @Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
        (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedOutputs s)
        (RequestApprovalFold.RequestOutput.ref o) →
      Not
          (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
            (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o) →
        RequestApprovalFold.History s s' →
          Not
            (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
              (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s') o)
```

### RequestApprovalFold.one_oracle_signature_suffices

```lean
RequestApprovalFold.one_oracle_signature_suffices : ∀ (c : RequestApprovalFold.CageState)
  (r : RequestApprovalFold.Request) (oracle : RequestApprovalFold.Oracle) (e : RequestApprovalFold.Selection)
  (sigs : List.{0} RequestApprovalFold.Signer),
  @Eq.{1} (List.{0} RequestApprovalFold.Oracle) (RequestApprovalFold.CageState.oracles c)
      (@List.cons.{0} RequestApprovalFold.Oracle oracle (@List.nil.{0} RequestApprovalFold.Oracle)) →
    RequestApprovalFold.Evidence.authorized (e oracle) oracle →
      @Eq.{1} Bool (RequestApprovalFold.Evidence.approve (e oracle)) Bool.true →
        @Eq.{1} (List.{0} RequestApprovalFold.Signer) (RequestApprovalFold.Evidence.signers (e oracle)) sigs →
          RequestApprovalFold.hasApproval c r (@List.nil.{0} RequestApprovalFold.TokenName) sigs e
```

### RequestApprovalFold.old_operations_correspond

```lean
RequestApprovalFold.old_operations_correspond : ∀ (op : RequestApprovalFold.OldOperation)
  (t : RequestApprovalFold.Trie),
  And
    (@Eq.{1} RequestApprovalFold.Trie (RequestApprovalFold.Write.apply t (RequestApprovalFold.OldOperation.write op))
      (RequestApprovalFold.OldOperation.apply op t))
    (RequestApprovalFold.old_operations_correspond.match_1.{1} (fun (op : RequestApprovalFold.OldOperation) => Prop) op
      (fun (k : RequestApprovalFold.Key) (value : RequestApprovalFold.Val) =>
        Iff (RequestApprovalFold.Condition.holds t (RequestApprovalFold.OldOperation.condition op))
          (@Eq.{1} (Option.{0} RequestApprovalFold.Val) (t k) (@Option.none.{0} RequestApprovalFold.Val)))
      (fun (k : RequestApprovalFold.Key) (v : RequestApprovalFold.Val) =>
        Iff (RequestApprovalFold.Condition.holds t (RequestApprovalFold.OldOperation.condition op))
          (@Eq.{1} (Option.{0} RequestApprovalFold.Val) (t k) (@Option.some.{0} RequestApprovalFold.Val v)))
      fun (k : RequestApprovalFold.Key) (v newValue : RequestApprovalFold.Val) =>
      Iff (RequestApprovalFold.Condition.holds t (RequestApprovalFold.OldOperation.condition op))
        (@Eq.{1} (Option.{0} RequestApprovalFold.Val) (t k) (@Option.some.{0} RequestApprovalFold.Val v)))
```

### RequestApprovalFold.live_removal_is_legal_exit

```lean
@RequestApprovalFold.live_removal_is_legal_exit : ∀ {s s' : RequestApprovalFold.State} {a : RequestApprovalFold.Action}
  (o : RequestApprovalFold.RequestOutput),
  RequestApprovalFold.Step s a s' →
    @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
        (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o →
      Not
          (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
            (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s') o) →
        @Exists.{1} RequestApprovalFold.RequestSpend fun (spend : RequestApprovalFold.RequestSpend) =>
          And
            (@Eq.{1} (Option.{0} RequestApprovalFold.RequestSpend) (RequestApprovalFold.Action.spend a)
              (@Option.some.{0} RequestApprovalFold.RequestSpend spend))
            (And (RequestApprovalFold.requestSpendAllowed o spend)
              (RequestApprovalFold.live_removal_is_legal_exit.match_1.{1}
                (fun (spend : RequestApprovalFold.RequestSpend) => Prop) spend
                (fun (tx : RequestApprovalFold.FoldTx) =>
                  And (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterFold s tx))
                    (And
                      (@Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.FoldTx.cageIn tx)
                        (RequestApprovalFold.State.cage s))
                      (And
                        (∀ (input : RequestApprovalFold.RequestOutput),
                          @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput
                              (List.{0} RequestApprovalFold.RequestOutput)
                              (@List.instMembership.{0} RequestApprovalFold.RequestOutput)
                              (RequestApprovalFold.FoldTx.requests tx) input →
                            @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput
                              (List.{0} RequestApprovalFold.RequestOutput)
                              (@List.instMembership.{0} RequestApprovalFold.RequestOutput)
                              (RequestApprovalFold.State.live s) input)
                        (And
                          (∀ (claim : RequestApprovalFold.ClaimOutput),
                            @Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput
                                (List.{0} RequestApprovalFold.ClaimOutput)
                                (@List.instMembership.{0} RequestApprovalFold.ClaimOutput)
                                (RequestApprovalFold.FoldTx.claims tx) claim →
                              @Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput
                                (List.{0} RequestApprovalFold.ClaimOutput)
                                (@List.instMembership.{0} RequestApprovalFold.ClaimOutput)
                                (RequestApprovalFold.State.claims s) claim)
                          (∀ (name : RequestApprovalFold.TokenName),
                            @Membership.mem.{0, 0} RequestApprovalFold.TokenName
                                (List.{0} RequestApprovalFold.TokenName)
                                (@List.instMembership.{0} RequestApprovalFold.TokenName)
                                (RequestApprovalFold.FoldTx.refs tx) name →
                              @Membership.mem.{0, 0} RequestApprovalFold.TokenName
                                (List.{0} RequestApprovalFold.TokenName)
                                (@List.instMembership.{0} RequestApprovalFold.TokenName)
                                (RequestApprovalFold.State.judgments s) name)))))
                fun (tx : RequestApprovalFold.WithdrawTx) =>
                @Eq.{1} RequestApprovalFold.State s'
                  (RequestApprovalFold.afterExit s (RequestApprovalFold.WithdrawTx.input tx))))
```

### RequestApprovalFold.new_judgment_is_authorized

```lean
@RequestApprovalFold.new_judgment_is_authorized : ∀ {s s' : RequestApprovalFold.State} {a : RequestApprovalFold.Action}
  (name : RequestApprovalFold.TokenName),
  RequestApprovalFold.Step s a s' →
    @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
        (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.issued s') name →
      Not
          (@Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
            (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.issued s) name) →
        @Exists.{1} RequestApprovalFold.JudgmentTx fun (tx : RequestApprovalFold.JudgmentTx) =>
          And (@Eq.{1} RequestApprovalFold.Action a (RequestApprovalFold.Action.judge tx))
            (And
              (@Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.JudgmentTx.cageRef tx)
                (RequestApprovalFold.State.cage s))
              (And
                (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
                  (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s)
                  (RequestApprovalFold.JudgmentTx.requestRef tx))
                (And (RequestApprovalFold.judgmentAllowed tx)
                  (@Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                    (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.JudgmentTx.minted tx)
                    name))))
```

### RequestApprovalFold.exit_time_window

```lean
RequestApprovalFold.exit_time_window : ∀ (o : RequestApprovalFold.RequestOutput)
  (spend : RequestApprovalFold.RequestSpend),
  RequestApprovalFold.requestSpendAllowed o spend →
    ∀ (kind : RequestApprovalFold.ExitKind),
      RequestApprovalFold.RequestSpend.exitsAs spend o kind →
        RequestApprovalFold.exitAt o (RequestApprovalFold.RequestSpend.interval spend) kind
```

### RequestApprovalFold.exit_windows_cover

```lean
RequestApprovalFold.exit_windows_cover : ∀ (o : RequestApprovalFold.RequestOutput) (now : RequestApprovalFold.Time),
  Or (RequestApprovalFold.exitAt o (RequestApprovalFold.Interval.mk now now) RequestApprovalFold.ExitKind.write)
    (Or (RequestApprovalFold.exitAt o (RequestApprovalFold.Interval.mk now now) RequestApprovalFold.ExitKind.account)
      (RequestApprovalFold.exitAt o (RequestApprovalFold.Interval.mk now now) RequestApprovalFold.ExitKind.withdraw))
```

### RequestApprovalFold.exit_kind_unique

```lean
RequestApprovalFold.exit_kind_unique : ∀ (o : RequestApprovalFold.RequestOutput)
  (a b : RequestApprovalFold.RequestSpend) (ka kb : RequestApprovalFold.ExitKind),
  RequestApprovalFold.requestSpendAllowed o a →
    RequestApprovalFold.requestSpendAllowed o b →
      @Eq.{1} RequestApprovalFold.Interval (RequestApprovalFold.RequestSpend.interval a)
          (RequestApprovalFold.RequestSpend.interval b) →
        RequestApprovalFold.RequestSpend.exitsAs a o ka →
          RequestApprovalFold.RequestSpend.exitsAs b o kb → @Eq.{1} RequestApprovalFold.ExitKind ka kb
```

### RequestApprovalFold.fold_references_authentic

```lean
@RequestApprovalFold.fold_references_authentic : ∀ {s s' : RequestApprovalFold.State} (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.Step s (RequestApprovalFold.Action.fold tx) s' →
    And
      (@Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.FoldTx.cageIn tx) (RequestApprovalFold.State.cage s))
      (And
        (∀ (o : RequestApprovalFold.RequestOutput),
          @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
              (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.FoldTx.requests tx) o →
            @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
              (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o)
        (And
          (∀ (o : RequestApprovalFold.ClaimOutput),
            @Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
                (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.FoldTx.claims tx) o →
              @Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
                (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.State.claims s) o)
          (∀ (name : RequestApprovalFold.TokenName),
            @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.FoldTx.refs tx) name →
              @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.judgments s) name)))
```

### RequestApprovalFold.account_references_authentic

```lean
@RequestApprovalFold.account_references_authentic : ∀ {s s' : RequestApprovalFold.State}
  (tx : RequestApprovalFold.FoldTx) (n : Nat) (o : RequestApprovalFold.RequestOutput)
  (e : RequestApprovalFold.Selection),
  RequestApprovalFold.Step s (RequestApprovalFold.Action.fold tx) s' →
    @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
        (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
          (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
            @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
          (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
        (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.account o e)) →
      ∀ (oracle : RequestApprovalFold.Oracle),
        @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
            (@List.instMembership.{0} RequestApprovalFold.Oracle)
            (RequestApprovalFold.CageState.oracles (RequestApprovalFold.State.cage s)) oracle →
          @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
            (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.judgments s)
            (RequestApprovalFold.Evidence.name (e oracle)
              (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s))
              (RequestApprovalFold.RequestOutput.request o) oracle)
```

### RequestApprovalFold.creation_references_source

```lean
@RequestApprovalFold.creation_references_source : ∀ {s s' : RequestApprovalFold.State}
  (tx : RequestApprovalFold.CreateTx) (o : RequestApprovalFold.RequestOutput),
  RequestApprovalFold.Step s (RequestApprovalFold.Action.create tx o) s' →
    And
      (@Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.CreateTx.cageRef tx)
        (RequestApprovalFold.State.cage s))
      (@Eq.{1} RequestApprovalFold.CageId
        (RequestApprovalFold.Request.cage (RequestApprovalFold.RequestOutput.request o))
        (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s)))
```

### RequestApprovalFold.fold_payments_concrete

```lean
RequestApprovalFold.fold_payments_concrete : ∀ (tx : RequestApprovalFold.FoldTx) (n : Nat)
  (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
  RequestApprovalFold.foldAccepted tx →
    @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
        (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
          (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
            @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
          (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
        (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)) →
      And
        (@Eq.{1} (RequestApprovalFold.Signer → Nat)
          (RequestApprovalFold.CageState.balances
            (RequestApprovalFold.itemResult (RequestApprovalFold.atTurn tx n) (RequestApprovalFold.FoldItem.write o e)))
          fun (k : RequestApprovalFold.Signer) =>
          @HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
            (RequestApprovalFold.CageState.balances (RequestApprovalFold.atTurn tx n) k)
            (OracleIdentity.paidTo
              (RequestApprovalFold.credits (RequestApprovalFold.atTurn tx n)
                (RequestApprovalFold.RequestOutput.request o) e)
              k))
        (@Eq.{1} (List.{0} RequestApprovalFold.Payment)
          (RequestApprovalFold.itemPayments (RequestApprovalFold.atTurn tx n) (RequestApprovalFold.FoldTx.folder tx)
            (RequestApprovalFold.FoldItem.write o e))
          (@HAppend.hAppend.{0, 0, 0} (List.{0} RequestApprovalFold.Payment) (List.{0} RequestApprovalFold.Payment)
            (List.{0} RequestApprovalFold.Payment)
            (@instHAppendOfAppend.{0} (List.{0} RequestApprovalFold.Payment)
              (@List.instAppend.{0} RequestApprovalFold.Payment))
            (@List.cons.{0} RequestApprovalFold.Payment
              (RequestApprovalFold.Payment.mk (RequestApprovalFold.FoldTx.folder tx) ""
                (@HSub.hSub.{0, 0, 0} Nat Nat Nat (@instHSub.{0} Nat instSubNat)
                  (RequestApprovalFold.RequestOutput.value o)
                  (@List.sum.{0} Nat instAddNat (@Zero.ofOfNat0.{0} Nat (instOfNatNat (nat_lit 0)))
                    (@List.map.{0, 0} RequestApprovalFold.Oracle Nat
                      (fun (oracle : RequestApprovalFold.Oracle) =>
                        @Option.getD.{0} Nat
                          (@Option.map.{0, 0} (Prod.{0, 0} RequestApprovalFold.Oracle Nat) Nat
                            (@Prod.snd.{0, 0} RequestApprovalFold.Oracle Nat)
                            (@List.find?.{0} (Prod.{0, 0} RequestApprovalFold.Oracle Nat)
                              (fun (p : Prod.{0, 0} RequestApprovalFold.Oracle Nat) =>
                                @BEq.beq.{0} RequestApprovalFold.Oracle
                                  (@instBEqOfDecidableEq.{0} RequestApprovalFold.Oracle
                                    OracleIdentity.instDecidableEqIdentity)
                                  (@Prod.fst.{0, 0} RequestApprovalFold.Oracle Nat p) oracle)
                              (RequestApprovalFold.Request.fees (RequestApprovalFold.RequestOutput.request o))))
                          (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0))))
                      (RequestApprovalFold.CageState.oracles (RequestApprovalFold.FoldTx.cageIn tx))))))
              (@List.nil.{0} RequestApprovalFold.Payment))
            (RequestApprovalFold.itemWitnessRefunds (RequestApprovalFold.atTurn tx n)
              (RequestApprovalFold.FoldItem.write o e))))
```

### RequestApprovalFold.account_payments_concrete

```lean
RequestApprovalFold.account_payments_concrete : ∀ (tx : RequestApprovalFold.FoldTx) (n : Nat)
  (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
  RequestApprovalFold.foldAccepted tx →
    @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
        (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
          (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
            @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
          (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
        (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.account o e)) →
      And
        (@Eq.{1} (RequestApprovalFold.Signer → Nat)
          (RequestApprovalFold.CageState.balances
            (RequestApprovalFold.itemResult (RequestApprovalFold.atTurn tx n)
              (RequestApprovalFold.FoldItem.account o e)))
          fun (k : RequestApprovalFold.Signer) =>
          @HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
            (RequestApprovalFold.CageState.balances (RequestApprovalFold.atTurn tx n) k)
            (OracleIdentity.paidTo
              (RequestApprovalFold.credits (RequestApprovalFold.atTurn tx n)
                (RequestApprovalFold.RequestOutput.request o) e)
              k))
        (@Eq.{1} (List.{0} RequestApprovalFold.Payment)
          (RequestApprovalFold.itemPayments (RequestApprovalFold.atTurn tx n) (RequestApprovalFold.FoldTx.folder tx)
            (RequestApprovalFold.FoldItem.account o e))
          (@HAppend.hAppend.{0, 0, 0} (List.{0} RequestApprovalFold.Payment) (List.{0} RequestApprovalFold.Payment)
            (List.{0} RequestApprovalFold.Payment)
            (@instHAppendOfAppend.{0} (List.{0} RequestApprovalFold.Payment)
              (@List.instAppend.{0} RequestApprovalFold.Payment))
            (@List.cons.{0} RequestApprovalFold.Payment
              (RequestApprovalFold.Payment.mk
                (RequestApprovalFold.Request.owner (RequestApprovalFold.RequestOutput.request o)) ""
                (@HSub.hSub.{0, 0, 0} Nat Nat Nat (@instHSub.{0} Nat instSubNat)
                  (RequestApprovalFold.RequestOutput.value o)
                  (@List.sum.{0} Nat instAddNat (@Zero.ofOfNat0.{0} Nat (instOfNatNat (nat_lit 0)))
                    (@List.map.{0, 0} RequestApprovalFold.Oracle Nat
                      (fun (oracle : RequestApprovalFold.Oracle) =>
                        @Option.getD.{0} Nat
                          (@Option.map.{0, 0} (Prod.{0, 0} RequestApprovalFold.Oracle Nat) Nat
                            (@Prod.snd.{0, 0} RequestApprovalFold.Oracle Nat)
                            (@List.find?.{0} (Prod.{0, 0} RequestApprovalFold.Oracle Nat)
                              (fun (p : Prod.{0, 0} RequestApprovalFold.Oracle Nat) =>
                                @BEq.beq.{0} RequestApprovalFold.Oracle
                                  (@instBEqOfDecidableEq.{0} RequestApprovalFold.Oracle
                                    OracleIdentity.instDecidableEqIdentity)
                                  (@Prod.fst.{0, 0} RequestApprovalFold.Oracle Nat p) oracle)
                              (RequestApprovalFold.Request.fees (RequestApprovalFold.RequestOutput.request o))))
                          (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0))))
                      (RequestApprovalFold.CageState.oracles (RequestApprovalFold.FoldTx.cageIn tx))))))
              (@List.nil.{0} RequestApprovalFold.Payment))
            (RequestApprovalFold.unusedDepositPayments o)))
```

### RequestApprovalFold.creation_funds_declared_fees

```lean
@RequestApprovalFold.creation_funds_declared_fees : ∀ {s s' : RequestApprovalFold.State}
  (tx : RequestApprovalFold.CreateTx) (o : RequestApprovalFold.RequestOutput),
  RequestApprovalFold.Step s (RequestApprovalFold.Action.create tx o) s' →
    @LE.le.{0} Nat instLENat
      (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
        (@List.sum.{0} Nat instAddNat (@Zero.ofOfNat0.{0} Nat (instOfNatNat (nat_lit 0)))
          (@List.map.{0, 0} RequestApprovalFold.Oracle Nat
            (fun (oracle : RequestApprovalFold.Oracle) =>
              @Option.getD.{0} Nat
                (@Option.map.{0, 0} (Prod.{0, 0} RequestApprovalFold.Oracle Nat) Nat
                  (@Prod.snd.{0, 0} RequestApprovalFold.Oracle Nat)
                  (@List.find?.{0} (Prod.{0, 0} RequestApprovalFold.Oracle Nat)
                    (fun (p : Prod.{0, 0} RequestApprovalFold.Oracle Nat) =>
                      @BEq.beq.{0} RequestApprovalFold.Oracle
                        (@instBEqOfDecidableEq.{0} RequestApprovalFold.Oracle OracleIdentity.instDecidableEqIdentity)
                        (@Prod.fst.{0, 0} RequestApprovalFold.Oracle Nat p) oracle)
                    (RequestApprovalFold.Request.fees (RequestApprovalFold.RequestOutput.request o))))
                (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0))))
            (RequestApprovalFold.CageState.oracles (RequestApprovalFold.State.cage s))))
        (RequestApprovalFold.CageState.minimum (RequestApprovalFold.State.cage s)))
      (RequestApprovalFold.RequestOutput.value o)
```

### RequestApprovalFold.burn_removes_one

```lean
@RequestApprovalFold.burn_removes_one : ∀ {s s' : RequestApprovalFold.State} (name : RequestApprovalFold.TokenName),
  RequestApprovalFold.Step s (RequestApprovalFold.Action.burn name) s' →
    And
      (@Eq.{1} Nat
        (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
          (@List.count.{0} RequestApprovalFold.TokenName
            (@instBEqOfDecidableEq.{0} RequestApprovalFold.TokenName RequestApprovalFold.instDecidableEqTokenName) name
            (RequestApprovalFold.State.judgments s'))
          (@OfNat.ofNat.{0} Nat (nat_lit 1) (instOfNatNat (nat_lit 1))))
        (@List.count.{0} RequestApprovalFold.TokenName
          (@instBEqOfDecidableEq.{0} RequestApprovalFold.TokenName RequestApprovalFold.instDecidableEqTokenName) name
          (RequestApprovalFold.State.judgments s)))
      (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.judgments s')
        (@List.erase.{0} RequestApprovalFold.TokenName
          (@instBEqOfDecidableEq.{0} RequestApprovalFold.TokenName RequestApprovalFold.instDecidableEqTokenName)
          (RequestApprovalFold.State.judgments s) name))
```

### RequestApprovalFold.burn_keeps_history

```lean
@RequestApprovalFold.burn_keeps_history : ∀ {s s' : RequestApprovalFold.State} (name : RequestApprovalFold.TokenName),
  RequestApprovalFold.Step s (RequestApprovalFold.Action.burn name) s' →
    @Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.issued s')
      (RequestApprovalFold.State.issued s)
```

### RequestApprovalFold.fold_requests_unique

```lean
RequestApprovalFold.fold_requests_unique : ∀ (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.foldAccepted tx →
    And
      (@List.Nodup.{0} RequestApprovalFold.OutputRef
        (@HAppend.hAppend.{0, 0, 0} (List.{0} RequestApprovalFold.OutputRef) (List.{0} RequestApprovalFold.OutputRef)
          (List.{0} RequestApprovalFold.OutputRef)
          (@instHAppendOfAppend.{0} (List.{0} RequestApprovalFold.OutputRef)
            (@List.instAppend.{0} RequestApprovalFold.OutputRef))
          (@HAppend.hAppend.{0, 0, 0} (List.{0} RequestApprovalFold.OutputRef) (List.{0} RequestApprovalFold.OutputRef)
            (List.{0} RequestApprovalFold.OutputRef)
            (@instHAppendOfAppend.{0} (List.{0} RequestApprovalFold.OutputRef)
              (@List.instAppend.{0} RequestApprovalFold.OutputRef))
            (@List.map.{0, 0} RequestApprovalFold.RequestOutput RequestApprovalFold.OutputRef
              RequestApprovalFold.RequestOutput.ref (RequestApprovalFold.FoldTx.requests tx))
            (@List.map.{0, 0} RequestApprovalFold.ClaimOutput RequestApprovalFold.OutputRef
              RequestApprovalFold.ClaimOutput.ref (RequestApprovalFold.FoldTx.claims tx)))
          (@List.map.{0, 0} RequestApprovalFold.Extraction RequestApprovalFold.OutputRef
            RequestApprovalFold.Extraction.ref (RequestApprovalFold.FoldTx.extractions tx))))
      (And (@List.Nodup.{0} RequestApprovalFold.RequestOutput (RequestApprovalFold.FoldTx.requests tx))
        (@List.Nodup.{0} RequestApprovalFold.ClaimOutput (RequestApprovalFold.FoldTx.claims tx)))
```

### RequestApprovalFold.account_accepts_any_verdicts

```lean
RequestApprovalFold.account_accepts_any_verdicts : ∀ (s : RequestApprovalFold.State)
  (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection) (iv : RequestApprovalFold.Interval)
  (who : RequestApprovalFold.Signer),
  @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
      (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o →
    RequestApprovalFold.wellFormed (RequestApprovalFold.State.cage s) o →
      RequestApprovalFold.Interval.valid iv →
        @LE.le.{0} RequestApprovalFold.Time instLENat
            (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o))
            (RequestApprovalFold.Interval.lower iv) →
          @LE.le.{0} RequestApprovalFold.Time instLENat (RequestApprovalFold.Interval.upper iv)
              (@HAdd.hAdd.{0, 0, 0} RequestApprovalFold.Time Nat RequestApprovalFold.Time
                (@instHAdd.{0} RequestApprovalFold.Time instAddNat)
                (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o))
                (RequestApprovalFold.Request.window (RequestApprovalFold.RequestOutput.request o))) →
            (∀ (oracle : RequestApprovalFold.Oracle),
                @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
                    (@List.instMembership.{0} RequestApprovalFold.Oracle)
                    (RequestApprovalFold.CageState.oracles (RequestApprovalFold.State.cage s)) oracle →
                  And (RequestApprovalFold.Evidence.authorized (e oracle) oracle)
                    (@Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                      (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.judgments s)
                      (RequestApprovalFold.Evidence.name (e oracle)
                        (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s))
                        (RequestApprovalFold.RequestOutput.request o) oracle))) →
              RequestApprovalFold.Step s
                (RequestApprovalFold.Action.fold
                  (RequestApprovalFold.singletonFold s iv (@List.nil.{0} RequestApprovalFold.Signer)
                    (RequestApprovalFold.FoldItem.account o e) who))
                (RequestApprovalFold.afterFold s
                  (RequestApprovalFold.singletonFold s iv (@List.nil.{0} RequestApprovalFold.Signer)
                    (RequestApprovalFold.FoldItem.account o e) who))
```

### RequestApprovalFold.equivocation_reachable

```lean
RequestApprovalFold.equivocation_reachable : @Exists.{1} RequestApprovalFold.State
  fun (s : RequestApprovalFold.State) =>
  @Exists.{1} RequestApprovalFold.RequestOutput fun (o : RequestApprovalFold.RequestOutput) =>
    @Exists.{1} RequestApprovalFold.Oracle fun (oracle : RequestApprovalFold.Oracle) =>
      @Exists.{1} RequestApprovalFold.SigningRecord fun (rec : RequestApprovalFold.SigningRecord) =>
        @Exists.{1} (List.{0} RequestApprovalFold.Condition) fun (cs : List.{0} RequestApprovalFold.Condition) =>
          And (RequestApprovalFold.Reachable s)
            (And
              (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
                (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o)
              (And
                (@Eq.{1} RequestApprovalFold.CageId
                  (RequestApprovalFold.Request.cage (RequestApprovalFold.RequestOutput.request o))
                  (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s)))
                (And
                  (@Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
                    (@List.instMembership.{0} RequestApprovalFold.Oracle)
                    (RequestApprovalFold.CageState.oracles (RequestApprovalFold.State.cage s)) oracle)
                  (And
                    (@Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                      (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.judgments s)
                      (RequestApprovalFold.judgmentName
                        (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s))
                        (RequestApprovalFold.RequestOutput.request o) oracle Bool.true rec cs))
                    (And
                      (@Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                        (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.judgments s)
                        (RequestApprovalFold.judgmentName
                          (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s))
                          (RequestApprovalFold.RequestOutput.request o) oracle Bool.false rec
                          (@List.nil.{0} RequestApprovalFold.Condition)))
                      (And
                        (@Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                          (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.issued s)
                          (RequestApprovalFold.judgmentName
                            (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s))
                            (RequestApprovalFold.RequestOutput.request o) oracle Bool.true rec cs))
                        (@Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                          (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.issued s)
                          (RequestApprovalFold.judgmentName
                            (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s))
                            (RequestApprovalFold.RequestOutput.request o) oracle Bool.false rec
                            (@List.nil.{0} RequestApprovalFold.Condition)))))))))
```

### RequestApprovalFold.tag_name_injective

```lean
RequestApprovalFold.tag_name_injective : ∀ (a b : RequestApprovalFold.Oracle),
  Iff (@Eq.{1} RequestApprovalFold.TokenName (RequestApprovalFold.tagName a) (RequestApprovalFold.tagName b))
    (@Eq.{1} RequestApprovalFold.Oracle a b)
```

### RequestApprovalFold.price_name_injective

```lean
RequestApprovalFold.price_name_injective : ∀ (a b : RequestApprovalFold.Oracle),
  Iff (@Eq.{1} RequestApprovalFold.TokenName (RequestApprovalFold.priceName a) (RequestApprovalFold.priceName b))
    (@Eq.{1} RequestApprovalFold.Oracle a b)
```

### RequestApprovalFold.different_roles_never_coincide

```lean
RequestApprovalFold.different_roles_never_coincide : ∀ (a b : RequestApprovalFold.TokenRole)
  (x y : RequestApprovalFold.NameBinding),
  @Ne.{1} RequestApprovalFold.TokenRole a b →
    @Ne.{1} RequestApprovalFold.TokenName (RequestApprovalFold.tokenName a x) (RequestApprovalFold.tokenName b y)
```

### RequestApprovalFold.names_have_leading_roles

```lean
RequestApprovalFold.names_have_leading_roles : ∀ (c : RequestApprovalFold.CageId) (r : RequestApprovalFold.Request)
  (o : RequestApprovalFold.Oracle) (rec : RequestApprovalFold.SigningRecord)
  (cs : List.{0} RequestApprovalFold.Condition),
  And
    (@Eq.{1} RequestApprovalFold.TokenRole (RequestApprovalFold.TokenName.role (RequestApprovalFold.tagName o))
      RequestApprovalFold.TokenRole.tag)
    (And
      (@Eq.{1} RequestApprovalFold.TokenRole (RequestApprovalFold.TokenName.role (RequestApprovalFold.priceName o))
        RequestApprovalFold.TokenRole.price)
      (And
        (@Eq.{1} RequestApprovalFold.TokenRole
          (RequestApprovalFold.TokenName.role (RequestApprovalFold.judgmentName c r o Bool.true rec cs))
          RequestApprovalFold.TokenRole.approval)
        (And
          (@Eq.{1} RequestApprovalFold.TokenRole
            (RequestApprovalFold.TokenName.role (RequestApprovalFold.judgmentName c r o Bool.false rec cs))
            RequestApprovalFold.TokenRole.refusal)
          (And
            (@Eq.{1} RequestApprovalFold.TokenRole
              (RequestApprovalFold.TokenName.role (RequestApprovalFold.requestName c))
              RequestApprovalFold.TokenRole.request)
            (@Eq.{1} RequestApprovalFold.TokenRole
              (RequestApprovalFold.TokenName.role (RequestApprovalFold.claimName c))
              RequestApprovalFold.TokenRole.claim)))))
```

### RequestApprovalFold.reachable_registry_valid

```lean
RequestApprovalFold.reachable_registry_valid : ∀ (s : RequestApprovalFold.State),
  RequestApprovalFold.Reachable s → RequestApprovalFold.RegistryValid (RequestApprovalFold.State.cage s)
```

### RequestApprovalFold.reachable_live_tags

```lean
RequestApprovalFold.reachable_live_tags : ∀ (s : RequestApprovalFold.State),
  RequestApprovalFold.Reachable s →
    ∀ (o : RequestApprovalFold.RequestOutput),
      @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
          (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o →
        And
          (@Eq.{1} RequestApprovalFold.CageId
            (RequestApprovalFold.Request.cage (RequestApprovalFold.RequestOutput.request o))
            (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s)))
          (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.RequestOutput.tags o)
            (@List.map.{0, 0} RequestApprovalFold.Oracle RequestApprovalFold.TokenName RequestApprovalFold.tagName
              (RequestApprovalFold.CageState.oracles (RequestApprovalFold.State.cage s))))
```

### RequestApprovalFold.reachable_tags_unique

```lean
RequestApprovalFold.reachable_tags_unique : ∀ (s : RequestApprovalFold.State) (o : RequestApprovalFold.RequestOutput),
  RequestApprovalFold.Reachable s →
    @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
        (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o →
      And (@List.Nodup.{0} RequestApprovalFold.TokenName (RequestApprovalFold.RequestOutput.tags o))
        (∀ (oracle : RequestApprovalFold.Oracle),
          @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
              (@List.instMembership.{0} RequestApprovalFold.Oracle)
              (RequestApprovalFold.CageState.oracles (RequestApprovalFold.State.cage s)) oracle →
            @Eq.{1} Nat
              (@List.count.{0} RequestApprovalFold.TokenName
                (@instBEqOfDecidableEq.{0} RequestApprovalFold.TokenName RequestApprovalFold.instDecidableEqTokenName)
                (RequestApprovalFold.tagName oracle) (RequestApprovalFold.RequestOutput.tags o))
              (@OfNat.ofNat.{0} Nat (nat_lit 1) (instOfNatNat (nat_lit 1))))
```

### RequestApprovalFold.discovery_iff

```lean
RequestApprovalFold.discovery_iff : ∀ (s : RequestApprovalFold.State) (oracle : RequestApprovalFold.Oracle)
  (o : RequestApprovalFold.RequestOutput),
  RequestApprovalFold.Reachable s →
    Iff
      (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
        (@List.instMembership.{0} RequestApprovalFold.RequestOutput)
        (RequestApprovalFold.discover oracle (RequestApprovalFold.State.live s)) o)
      (And
        (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
          (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o)
        (@Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
          (@List.instMembership.{0} RequestApprovalFold.Oracle)
          (RequestApprovalFold.CageState.oracles (RequestApprovalFold.State.cage s)) oracle))
```

### RequestApprovalFold.discovery_across_registries

```lean
RequestApprovalFold.discovery_across_registries : ∀ (states : List.{0} RequestApprovalFold.State)
  (oracle : RequestApprovalFold.Oracle) (o : RequestApprovalFold.RequestOutput),
  (∀ (s : RequestApprovalFold.State),
      @Membership.mem.{0, 0} RequestApprovalFold.State (List.{0} RequestApprovalFold.State)
          (@List.instMembership.{0} RequestApprovalFold.State) states s →
        RequestApprovalFold.Reachable s) →
    Iff
      (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
        (@List.instMembership.{0} RequestApprovalFold.RequestOutput)
        (RequestApprovalFold.discover oracle
          (@List.flatMap.{0, 0} RequestApprovalFold.State RequestApprovalFold.RequestOutput
            RequestApprovalFold.State.live states))
        o)
      (@Exists.{1} RequestApprovalFold.State fun (s : RequestApprovalFold.State) =>
        And
          (@Membership.mem.{0, 0} RequestApprovalFold.State (List.{0} RequestApprovalFold.State)
            (@List.instMembership.{0} RequestApprovalFold.State) states s)
          (And
            (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
              (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o)
            (@Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
              (@List.instMembership.{0} RequestApprovalFold.Oracle)
              (RequestApprovalFold.CageState.oracles (RequestApprovalFold.State.cage s)) oracle)))
```

### RequestApprovalFold.live_removal_burns_oracle_tags

```lean
@RequestApprovalFold.live_removal_burns_oracle_tags : ∀ {s s' : RequestApprovalFold.State}
  {a : RequestApprovalFold.Action} (o : RequestApprovalFold.RequestOutput),
  RequestApprovalFold.Reachable s →
    RequestApprovalFold.Step s a s' →
      @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
          (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o →
        Not
            (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
              (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s') o) →
          @Exists.{1} RequestApprovalFold.RequestSpend fun (spend : RequestApprovalFold.RequestSpend) =>
            And
              (@Eq.{1} (Option.{0} RequestApprovalFold.RequestSpend) (RequestApprovalFold.Action.spend a)
                (@Option.some.{0} RequestApprovalFold.RequestSpend spend))
              (And (RequestApprovalFold.requestSpendAllowed o spend)
                (∀ (oracle : RequestApprovalFold.Oracle),
                  @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
                      (@List.instMembership.{0} RequestApprovalFold.Oracle)
                      (RequestApprovalFold.CageState.oracles (RequestApprovalFold.State.cage s)) oracle →
                    @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                      (@List.instMembership.{0} RequestApprovalFold.TokenName)
                      (RequestApprovalFold.RequestSpend.burned spend) (RequestApprovalFold.tagName oracle)))
```

### RequestApprovalFold.price_mint_inversion

```lean
@RequestApprovalFold.price_mint_inversion : ∀ {s s' : RequestApprovalFold.State} (tx : RequestApprovalFold.PriceMintTx),
  RequestApprovalFold.Step s (RequestApprovalFold.Action.priceMint tx) s' →
    And
      (@Eq.{1} Bool
        (@Option.isSome.{0} OracleIdentity.SigningRecord
          (OracleIdentity.authorize (RequestApprovalFold.PriceNotice.oracle (RequestApprovalFold.PriceMintTx.output tx))
            (RequestApprovalFold.PriceMintTx.description tx) (RequestApprovalFold.PriceMintTx.signers tx)))
        Bool.true)
      (And
        (@Eq.{1} RequestApprovalFold.TokenName
          (RequestApprovalFold.PriceNotice.token (RequestApprovalFold.PriceMintTx.output tx))
          (RequestApprovalFold.TokenName.mk RequestApprovalFold.TokenRole.price
            (RequestApprovalFold.NameBinding.oracle
              (RequestApprovalFold.PriceNotice.oracle (RequestApprovalFold.PriceMintTx.output tx)))))
        (And
          (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.PriceMintTx.minted tx)
            (@List.cons.{0} RequestApprovalFold.TokenName
              (RequestApprovalFold.PriceNotice.token (RequestApprovalFold.PriceMintTx.output tx))
              (@List.nil.{0} RequestApprovalFold.TokenName)))
          (@Eq.{1} (List.{0} RequestApprovalFold.PriceNotice) (RequestApprovalFold.State.notices s')
            (@List.cons.{0} RequestApprovalFold.PriceNotice (RequestApprovalFold.PriceMintTx.output tx)
              (RequestApprovalFold.State.notices s)))))
```

### RequestApprovalFold.price_update_inversion

```lean
@RequestApprovalFold.price_update_inversion : ∀ {s s' : RequestApprovalFold.State}
  (tx : RequestApprovalFold.PriceUpdateTx),
  RequestApprovalFold.Step s (RequestApprovalFold.Action.priceUpdate tx) s' →
    And
      (@Membership.mem.{0, 0} RequestApprovalFold.PriceNotice (List.{0} RequestApprovalFold.PriceNotice)
        (@List.instMembership.{0} RequestApprovalFold.PriceNotice) (RequestApprovalFold.State.notices s)
        (RequestApprovalFold.PriceUpdateTx.input tx))
      (And
        (@Eq.{1} Bool
          (@Option.isSome.{0} OracleIdentity.SigningRecord
            (OracleIdentity.authorize
              (RequestApprovalFold.PriceNotice.oracle (RequestApprovalFold.PriceUpdateTx.input tx))
              (RequestApprovalFold.PriceUpdateTx.description tx) (RequestApprovalFold.PriceUpdateTx.signers tx)))
          Bool.true)
        (And
          (@Eq.{1} RequestApprovalFold.TokenName
            (RequestApprovalFold.PriceNotice.token (RequestApprovalFold.PriceUpdateTx.input tx))
            (RequestApprovalFold.TokenName.mk RequestApprovalFold.TokenRole.price
              (RequestApprovalFold.NameBinding.oracle
                (RequestApprovalFold.PriceNotice.oracle (RequestApprovalFold.PriceUpdateTx.input tx)))))
          (And
            (@Eq.{1} RequestApprovalFold.Oracle
              (RequestApprovalFold.PriceNotice.oracle (RequestApprovalFold.PriceUpdateTx.output tx))
              (RequestApprovalFold.PriceNotice.oracle (RequestApprovalFold.PriceUpdateTx.input tx)))
            (And
              (@Eq.{1} RequestApprovalFold.TokenName
                (RequestApprovalFold.PriceNotice.token (RequestApprovalFold.PriceUpdateTx.output tx))
                (RequestApprovalFold.PriceNotice.token (RequestApprovalFold.PriceUpdateTx.input tx)))
              (And
                (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.PriceUpdateTx.minted tx)
                  (@List.nil.{0} RequestApprovalFold.TokenName))
                (@Eq.{1} (List.{0} RequestApprovalFold.PriceNotice) (RequestApprovalFold.State.notices s')
                  (@List.cons.{0} RequestApprovalFold.PriceNotice (RequestApprovalFold.PriceUpdateTx.output tx)
                    (@List.erase.{0} RequestApprovalFold.PriceNotice
                      (@instBEqOfDecidableEq.{0} RequestApprovalFold.PriceNotice
                        RequestApprovalFold.instDecidableEqPriceNotice)
                      (RequestApprovalFold.State.notices s) (RequestApprovalFold.PriceUpdateTx.input tx)))))))))
```

### RequestApprovalFold.reachable_notice_names

```lean
RequestApprovalFold.reachable_notice_names : ∀ (s : RequestApprovalFold.State),
  RequestApprovalFold.Reachable s →
    ∀ (n : RequestApprovalFold.PriceNotice),
      @Membership.mem.{0, 0} RequestApprovalFold.PriceNotice (List.{0} RequestApprovalFold.PriceNotice)
          (@List.instMembership.{0} RequestApprovalFold.PriceNotice) (RequestApprovalFold.State.notices s) n →
        @Eq.{1} RequestApprovalFold.TokenName (RequestApprovalFold.PriceNotice.token n)
          (RequestApprovalFold.TokenName.mk RequestApprovalFold.TokenRole.price
            (RequestApprovalFold.NameBinding.oracle (RequestApprovalFold.PriceNotice.oracle n)))
```

### RequestApprovalFold.price_mint_available

```lean
RequestApprovalFold.price_mint_available : ∀ (s : RequestApprovalFold.State) (oracle : RequestApprovalFold.Oracle)
  (d : OracleIdentity.Description) (sigs : List.{0} RequestApprovalFold.Signer)
  (datum : RequestApprovalFold.PriceDatum),
  @Eq.{1} Bool (@Option.isSome.{0} OracleIdentity.SigningRecord (OracleIdentity.authorize oracle d sigs)) Bool.true →
    have tx : RequestApprovalFold.PriceMintTx :=
      RequestApprovalFold.PriceMintTx.mk
        (RequestApprovalFold.PriceNotice.mk oracle (RequestApprovalFold.priceName oracle) datum) d sigs
        (@List.cons.{0} RequestApprovalFold.TokenName (RequestApprovalFold.priceName oracle)
          (@List.nil.{0} RequestApprovalFold.TokenName));
    RequestApprovalFold.Step s (RequestApprovalFold.Action.priceMint tx) (RequestApprovalFold.afterPriceMint s tx)
```

### RequestApprovalFold.price_update_available

```lean
RequestApprovalFold.price_update_available : ∀ (s : RequestApprovalFold.State) (n : RequestApprovalFold.PriceNotice)
  (d : OracleIdentity.Description) (sigs : List.{0} RequestApprovalFold.Signer)
  (datum : RequestApprovalFold.PriceDatum),
  @Membership.mem.{0, 0} RequestApprovalFold.PriceNotice (List.{0} RequestApprovalFold.PriceNotice)
      (@List.instMembership.{0} RequestApprovalFold.PriceNotice) (RequestApprovalFold.State.notices s) n →
    @Eq.{1} RequestApprovalFold.TokenName (RequestApprovalFold.PriceNotice.token n)
        (RequestApprovalFold.priceName (RequestApprovalFold.PriceNotice.oracle n)) →
      @Eq.{1} Bool
          (@Option.isSome.{0} OracleIdentity.SigningRecord
            (OracleIdentity.authorize (RequestApprovalFold.PriceNotice.oracle n) d sigs))
          Bool.true →
        have tx : RequestApprovalFold.PriceUpdateTx :=
          RequestApprovalFold.PriceUpdateTx.mk n
            (RequestApprovalFold.PriceNotice.mk (RequestApprovalFold.PriceNotice.oracle n)
              (RequestApprovalFold.PriceNotice.token n) datum)
            d sigs (@List.nil.{0} RequestApprovalFold.TokenName);
        RequestApprovalFold.Step s (RequestApprovalFold.Action.priceUpdate tx)
          (RequestApprovalFold.afterPriceUpdate s tx)
```

### RequestApprovalFold.price_notice_noninterference

```lean
@RequestApprovalFold.price_notice_noninterference : ∀ {s s' : RequestApprovalFold.State}
  {a : RequestApprovalFold.Action},
  RequestApprovalFold.Step s a s' →
    @Eq.{1} Bool (RequestApprovalFold.Action.isPrice a) Bool.true →
      And (@Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.State.cage s') (RequestApprovalFold.State.cage s))
        (And
          (@Eq.{1} (List.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s')
            (RequestApprovalFold.State.live s))
          (And
            (@Eq.{1} (List.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.State.claims s')
              (RequestApprovalFold.State.claims s))
            (And
              (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.judgments s')
                (RequestApprovalFold.State.judgments s))
              (And
                (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.issued s')
                  (RequestApprovalFold.State.issued s))
                (And
                  (@Eq.{1} (List.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedSeeds s')
                    (RequestApprovalFold.State.usedSeeds s))
                  (And
                    (@Eq.{1} (List.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedOutputs s')
                      (RequestApprovalFold.State.usedOutputs s))
                    (And
                      (@Eq.{1} (List.{0} RequestApprovalFold.Payment) (RequestApprovalFold.Action.payments a)
                        (@List.nil.{0} RequestApprovalFold.Payment))
                      (@Eq.{1} (Option.{0} RequestApprovalFold.RequestSpend) (RequestApprovalFold.Action.spend a)
                        (@Option.none.{0} RequestApprovalFold.RequestSpend)))))))))
```

### RequestApprovalFold.notices_do_not_bind_protocol

```lean
@RequestApprovalFold.notices_do_not_bind_protocol : ∀ {s s' : RequestApprovalFold.State}
  {a : RequestApprovalFold.Action} (notices : List.{0} RequestApprovalFold.PriceNotice),
  RequestApprovalFold.Step s a s' →
    @Eq.{1} Bool (RequestApprovalFold.Action.isPrice a) Bool.false →
      RequestApprovalFold.Step
        (RequestApprovalFold.State.mk (RequestApprovalFold.State.cage s) (RequestApprovalFold.State.usedSeeds s)
          (RequestApprovalFold.State.live s) (RequestApprovalFold.State.judgments s)
          (RequestApprovalFold.State.issued s) notices (RequestApprovalFold.State.usedOutputs s)
          (RequestApprovalFold.State.claims s) (RequestApprovalFold.State.extractions s)
          (RequestApprovalFold.State.witnesses s))
        a
        (RequestApprovalFold.State.mk (RequestApprovalFold.State.cage s') (RequestApprovalFold.State.usedSeeds s')
          (RequestApprovalFold.State.live s') (RequestApprovalFold.State.judgments s')
          (RequestApprovalFold.State.issued s') notices (RequestApprovalFold.State.usedOutputs s')
          (RequestApprovalFold.State.claims s') (RequestApprovalFold.State.extractions s')
          (RequestApprovalFold.State.witnesses s'))
```

### RequestApprovalFold.notice_change_authorized

```lean
@RequestApprovalFold.notice_change_authorized : ∀ {s s' : RequestApprovalFold.State} {a : RequestApprovalFold.Action}
  (n : RequestApprovalFold.PriceNotice),
  RequestApprovalFold.Step s a s' →
    @Membership.mem.{0, 0} RequestApprovalFold.PriceNotice (List.{0} RequestApprovalFold.PriceNotice)
        (@List.instMembership.{0} RequestApprovalFold.PriceNotice) (RequestApprovalFold.State.notices s') n →
      Not
          (@Membership.mem.{0, 0} RequestApprovalFold.PriceNotice (List.{0} RequestApprovalFold.PriceNotice)
            (@List.instMembership.{0} RequestApprovalFold.PriceNotice) (RequestApprovalFold.State.notices s) n) →
        Or
          (@Exists.{1} RequestApprovalFold.PriceMintTx fun (tx : RequestApprovalFold.PriceMintTx) =>
            And (@Eq.{1} RequestApprovalFold.Action a (RequestApprovalFold.Action.priceMint tx))
              (And (@Eq.{1} RequestApprovalFold.PriceNotice (RequestApprovalFold.PriceMintTx.output tx) n)
                (@Eq.{1} Bool
                  (@Option.isSome.{0} OracleIdentity.SigningRecord
                    (OracleIdentity.authorize (RequestApprovalFold.PriceNotice.oracle n)
                      (RequestApprovalFold.PriceMintTx.description tx) (RequestApprovalFold.PriceMintTx.signers tx)))
                  Bool.true)))
          (@Exists.{1} RequestApprovalFold.PriceUpdateTx fun (tx : RequestApprovalFold.PriceUpdateTx) =>
            And (@Eq.{1} RequestApprovalFold.Action a (RequestApprovalFold.Action.priceUpdate tx))
              (And
                (@Membership.mem.{0, 0} RequestApprovalFold.PriceNotice (List.{0} RequestApprovalFold.PriceNotice)
                  (@List.instMembership.{0} RequestApprovalFold.PriceNotice) (RequestApprovalFold.State.notices s)
                  (RequestApprovalFold.PriceUpdateTx.input tx))
                (And (@Eq.{1} RequestApprovalFold.PriceNotice (RequestApprovalFold.PriceUpdateTx.output tx) n)
                  (And
                    (@Eq.{1} RequestApprovalFold.Oracle
                      (RequestApprovalFold.PriceNotice.oracle (RequestApprovalFold.PriceUpdateTx.input tx))
                      (RequestApprovalFold.PriceNotice.oracle n))
                    (@Eq.{1} Bool
                      (@Option.isSome.{0} OracleIdentity.SigningRecord
                        (OracleIdentity.authorize (RequestApprovalFold.PriceNotice.oracle n)
                          (RequestApprovalFold.PriceUpdateTx.description tx)
                          (RequestApprovalFold.PriceUpdateTx.signers tx)))
                      Bool.true)))))
```

### RequestApprovalFold.creation_rule_and_token

```lean
RequestApprovalFold.creation_rule_and_token : ∀ (tx : RequestApprovalFold.CreateTx)
  (o : RequestApprovalFold.RequestOutput),
  RequestApprovalFold.createAllowed tx o →
    And
      (RequestApprovalFold.ruleAdmits (RequestApprovalFold.CreateTx.cageRef tx)
        (RequestApprovalFold.RequestOutput.request o) (RequestApprovalFold.CreateTx.signers tx))
      (And
        (@Eq.{1} (List.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.CreateTx.outputs tx)
          (@List.cons.{0} RequestApprovalFold.RequestOutput o (@List.nil.{0} RequestApprovalFold.RequestOutput)))
        (And
          (@Eq.{1} RequestApprovalFold.CageId
            (RequestApprovalFold.Request.cage (RequestApprovalFold.RequestOutput.request o))
            (RequestApprovalFold.CageState.id (RequestApprovalFold.CreateTx.cageRef tx)))
          (And
            (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.RequestOutput.requestTokens o)
              (@List.cons.{0} RequestApprovalFold.TokenName
                (RequestApprovalFold.requestName
                  (RequestApprovalFold.CageState.id (RequestApprovalFold.CreateTx.cageRef tx)))
                (@List.nil.{0} RequestApprovalFold.TokenName)))
            (And
              (@Eq.{1} RequestApprovalFold.RequestPolicy (RequestApprovalFold.RequestOutput.policy o)
                (RequestApprovalFold.requestPolicy (RequestApprovalFold.CreateTx.cageRef tx)))
              (And
                (@Eq.{1} RequestApprovalFold.RequestPolicy (RequestApprovalFold.CreateTx.policy tx)
                  (RequestApprovalFold.requestPolicy (RequestApprovalFold.CreateTx.cageRef tx)))
                (And
                  (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.CreateTx.minted tx)
                    (@HAppend.hAppend.{0, 0, 0} (List.{0} RequestApprovalFold.TokenName)
                      (List.{0} RequestApprovalFold.TokenName) (List.{0} RequestApprovalFold.TokenName)
                      (@instHAppendOfAppend.{0} (List.{0} RequestApprovalFold.TokenName)
                        (@List.instAppend.{0} RequestApprovalFold.TokenName))
                      (@List.map.{0, 0} RequestApprovalFold.Oracle RequestApprovalFold.TokenName
                        RequestApprovalFold.tagName
                        (RequestApprovalFold.CageState.oracles (RequestApprovalFold.CreateTx.cageRef tx)))
                      (@List.cons.{0} RequestApprovalFold.TokenName
                        (RequestApprovalFold.requestName
                          (RequestApprovalFold.CageState.id (RequestApprovalFold.CreateTx.cageRef tx)))
                        (@List.nil.{0} RequestApprovalFold.TokenName))))
                  (@LE.le.{0} Nat instLENat
                    (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
                      (RequestApprovalFold.totalFees (RequestApprovalFold.CreateTx.cageRef tx)
                        (RequestApprovalFold.RequestOutput.request o))
                      (RequestApprovalFold.CageState.minimum (RequestApprovalFold.CreateTx.cageRef tx)))
                    (RequestApprovalFold.RequestOutput.value o))))))))
```

### RequestApprovalFold.step_rule_immutable

```lean
@RequestApprovalFold.step_rule_immutable : ∀ {s s' : RequestApprovalFold.State} {a : RequestApprovalFold.Action},
  RequestApprovalFold.Step s a s' →
    @Eq.{1} (Option.{0} RequestApprovalFold.Rule)
      (RequestApprovalFold.CageState.rule (RequestApprovalFold.State.cage s'))
      (RequestApprovalFold.CageState.rule (RequestApprovalFold.State.cage s))
```

### RequestApprovalFold.history_rule_immutable

```lean
@RequestApprovalFold.history_rule_immutable : ∀ {s s' : RequestApprovalFold.State},
  RequestApprovalFold.History s s' →
    @Eq.{1} (Option.{0} RequestApprovalFold.Rule)
      (RequestApprovalFold.CageState.rule (RequestApprovalFold.State.cage s'))
      (RequestApprovalFold.CageState.rule (RequestApprovalFold.State.cage s))
```

### RequestApprovalFold.reachable_rule_admitted

```lean
RequestApprovalFold.reachable_rule_admitted : ∀ (s : RequestApprovalFold.State),
  RequestApprovalFold.Reachable s →
    ∀ (o : RequestApprovalFold.RequestOutput),
      @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
          (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o →
        @Exists.{1} (List.{0} RequestApprovalFold.Signer) fun (sigs : List.{0} RequestApprovalFold.Signer) =>
          RequestApprovalFold.ruleAdmits (RequestApprovalFold.State.cage s)
            (RequestApprovalFold.RequestOutput.request o) sigs
```

### RequestApprovalFold.every_rule_allows_burn

```lean
RequestApprovalFold.every_rule_allows_burn : ∀ (s : RequestApprovalFold.State) (rule : RequestApprovalFold.Rule),
  @Eq.{1} (Option.{0} RequestApprovalFold.Rule) (RequestApprovalFold.CageState.rule (RequestApprovalFold.State.cage s))
      (@Option.some.{0} RequestApprovalFold.Rule rule) →
    And
      (∀ (tx : RequestApprovalFold.FoldTx),
        @Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.FoldTx.cageIn tx)
            (RequestApprovalFold.State.cage s) →
          (∀ (o : RequestApprovalFold.RequestOutput),
              @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
                  (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.FoldTx.requests tx)
                  o →
                @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
                  (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o) →
            (∀ (o : RequestApprovalFold.ClaimOutput),
                @Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
                    (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.FoldTx.claims tx)
                    o →
                  @Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
                    (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.State.claims s) o) →
              (∀ (name : RequestApprovalFold.TokenName),
                  @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                      (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.FoldTx.refs tx)
                      name →
                    @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                      (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.judgments s)
                      name) →
                RequestApprovalFold.Interval.valid (RequestApprovalFold.FoldTx.interval tx) →
                  @List.Nodup.{0} RequestApprovalFold.OutputRef
                      (@HAppend.hAppend.{0, 0, 0} (List.{0} RequestApprovalFold.OutputRef)
                        (List.{0} RequestApprovalFold.OutputRef) (List.{0} RequestApprovalFold.OutputRef)
                        (@instHAppendOfAppend.{0} (List.{0} RequestApprovalFold.OutputRef)
                          (@List.instAppend.{0} RequestApprovalFold.OutputRef))
                        (@HAppend.hAppend.{0, 0, 0} (List.{0} RequestApprovalFold.OutputRef)
                          (List.{0} RequestApprovalFold.OutputRef) (List.{0} RequestApprovalFold.OutputRef)
                          (@instHAppendOfAppend.{0} (List.{0} RequestApprovalFold.OutputRef)
                            (@List.instAppend.{0} RequestApprovalFold.OutputRef))
                          (@List.map.{0, 0} RequestApprovalFold.RequestOutput RequestApprovalFold.OutputRef
                            RequestApprovalFold.RequestOutput.ref (RequestApprovalFold.FoldTx.requests tx))
                          (@List.map.{0, 0} RequestApprovalFold.ClaimOutput RequestApprovalFold.OutputRef
                            RequestApprovalFold.ClaimOutput.ref (RequestApprovalFold.FoldTx.claims tx)))
                        (@List.map.{0, 0} RequestApprovalFold.Extraction RequestApprovalFold.OutputRef
                          RequestApprovalFold.Extraction.ref (RequestApprovalFold.FoldTx.extractions tx))) →
                    @Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.FoldTx.burned tx)
                        (@List.flatMap.{0, 0} RequestApprovalFold.FoldItem RequestApprovalFold.TokenName
                          RequestApprovalFold.FoldItem.burned (RequestApprovalFold.FoldTx.items tx)) →
                      @Eq.{1} (List.{0} RequestApprovalFold.Payment) (RequestApprovalFold.FoldTx.payments tx)
                          (RequestApprovalFold.foldPayments (RequestApprovalFold.FoldTx.cageIn tx)
                            (RequestApprovalFold.FoldTx.folder tx) (RequestApprovalFold.FoldTx.items tx)) →
                        RequestApprovalFold.FoldRun (RequestApprovalFold.FoldTx.interval tx)
                            (RequestApprovalFold.FoldTx.refs tx) (RequestApprovalFold.FoldTx.signers tx)
                            (RequestApprovalFold.FoldTx.cageIn tx) (RequestApprovalFold.FoldTx.items tx)
                            (RequestApprovalFold.FoldTx.cageOut tx) →
                          RequestApprovalFold.witnessBoundary tx →
                            (∀ (o : RequestApprovalFold.Extraction),
                                @Membership.mem.{0, 0} RequestApprovalFold.Extraction
                                    (List.{0} RequestApprovalFold.Extraction)
                                    (@List.instMembership.{0} RequestApprovalFold.Extraction)
                                    (RequestApprovalFold.FoldTx.extractions tx) o →
                                  @Membership.mem.{0, 0} RequestApprovalFold.Extraction
                                    (List.{0} RequestApprovalFold.Extraction)
                                    (@List.instMembership.{0} RequestApprovalFold.Extraction)
                                    (RequestApprovalFold.State.extractions s) o) →
                              (∀ (w : RequestApprovalFold.WitnessOutput),
                                  @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput
                                      (List.{0} RequestApprovalFold.WitnessOutput)
                                      (@List.instMembership.{0} RequestApprovalFold.WitnessOutput)
                                      (RequestApprovalFold.FoldTx.witnessInputs tx) w →
                                    @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput
                                      (List.{0} RequestApprovalFold.WitnessOutput)
                                      (@List.instMembership.{0} RequestApprovalFold.WitnessOutput)
                                      (RequestApprovalFold.State.witnesses s) w) →
                                RequestApprovalFold.Step s (RequestApprovalFold.Action.fold tx)
                                  (RequestApprovalFold.afterFold s tx))
      (And
        (∀ (tx : RequestApprovalFold.WithdrawTx),
          @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
              (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s)
              (RequestApprovalFold.WithdrawTx.input tx) →
            RequestApprovalFold.Interval.valid (RequestApprovalFold.WithdrawTx.interval tx) →
              @LT.lt.{0} RequestApprovalFold.Time instLTNat
                  (@HAdd.hAdd.{0, 0, 0} RequestApprovalFold.Time Nat RequestApprovalFold.Time
                    (@instHAdd.{0} RequestApprovalFold.Time instAddNat)
                    (RequestApprovalFold.Request.deadline
                      (RequestApprovalFold.RequestOutput.request (RequestApprovalFold.WithdrawTx.input tx)))
                    (RequestApprovalFold.Request.window
                      (RequestApprovalFold.RequestOutput.request (RequestApprovalFold.WithdrawTx.input tx))))
                  (RequestApprovalFold.Interval.lower (RequestApprovalFold.WithdrawTx.interval tx)) →
                @Membership.mem.{0, 0} RequestApprovalFold.Signer (List.{0} RequestApprovalFold.Signer)
                    (@List.instMembership.{0} RequestApprovalFold.Signer) (RequestApprovalFold.WithdrawTx.signers tx)
                    (RequestApprovalFold.Request.owner
                      (RequestApprovalFold.RequestOutput.request (RequestApprovalFold.WithdrawTx.input tx))) →
                  @Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.WithdrawTx.burned tx)
                      (RequestApprovalFold.tokensOf (RequestApprovalFold.WithdrawTx.input tx)) →
                    @Eq.{1} RequestApprovalFold.Signer (RequestApprovalFold.WithdrawTx.beneficiary tx)
                        (RequestApprovalFold.Request.owner
                          (RequestApprovalFold.RequestOutput.request (RequestApprovalFold.WithdrawTx.input tx))) →
                      @Eq.{1} Nat (RequestApprovalFold.WithdrawTx.paid tx)
                          (RequestApprovalFold.RequestOutput.escrow (RequestApprovalFold.WithdrawTx.input tx)) →
                        RequestApprovalFold.Step s (RequestApprovalFold.Action.withdraw tx)
                          (RequestApprovalFold.afterExit s (RequestApprovalFold.WithdrawTx.input tx)))
        (∀ (name : RequestApprovalFold.TokenName),
          @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
              (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.judgments s) name →
            RequestApprovalFold.Step s (RequestApprovalFold.Action.burn name) (RequestApprovalFold.afterBurn s name)))
```

### RequestApprovalFold.creation_rule_input_binding

```lean
@RequestApprovalFold.creation_rule_input_binding : ∀ {s s' : RequestApprovalFold.State}
  {tx : RequestApprovalFold.CreateTx} {o : RequestApprovalFold.RequestOutput} (rule : RequestApprovalFold.Rule),
  RequestApprovalFold.Step s (RequestApprovalFold.Action.create tx o) s' →
    @Eq.{1} (Option.{0} RequestApprovalFold.Rule)
        (RequestApprovalFold.CageState.rule (RequestApprovalFold.State.cage s))
        (@Option.some.{0} RequestApprovalFold.Rule rule) →
      And
        (@Eq.{1} (List.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.CreateTx.outputs tx)
          (@List.cons.{0} RequestApprovalFold.RequestOutput o (@List.nil.{0} RequestApprovalFold.RequestOutput)))
        (And
          (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
            (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s') o)
          (RequestApprovalFold.Rule.admits rule (RequestApprovalFold.RequestOutput.request o)
            (RequestApprovalFold.CreateTx.signers tx)))
```

### RequestApprovalFold.creation_request_policy

```lean
@RequestApprovalFold.creation_request_policy : ∀ {s s' : RequestApprovalFold.State} {tx : RequestApprovalFold.CreateTx}
  {o : RequestApprovalFold.RequestOutput},
  RequestApprovalFold.Step s (RequestApprovalFold.Action.create tx o) s' →
    And
      (@Eq.{1} (List.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.CreateTx.outputs tx)
        (@List.cons.{0} RequestApprovalFold.RequestOutput o (@List.nil.{0} RequestApprovalFold.RequestOutput)))
      (And
        (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.RequestOutput.requestTokens o)
          (@List.cons.{0} RequestApprovalFold.TokenName
            (RequestApprovalFold.requestName (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s)))
            (@List.nil.{0} RequestApprovalFold.TokenName)))
        (And
          (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.CreateTx.minted tx)
            (@HAppend.hAppend.{0, 0, 0} (List.{0} RequestApprovalFold.TokenName)
              (List.{0} RequestApprovalFold.TokenName) (List.{0} RequestApprovalFold.TokenName)
              (@instHAppendOfAppend.{0} (List.{0} RequestApprovalFold.TokenName)
                (@List.instAppend.{0} RequestApprovalFold.TokenName))
              (@List.map.{0, 0} RequestApprovalFold.Oracle RequestApprovalFold.TokenName RequestApprovalFold.tagName
                (RequestApprovalFold.CageState.oracles (RequestApprovalFold.State.cage s)))
              (@List.cons.{0} RequestApprovalFold.TokenName
                (RequestApprovalFold.requestName (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s)))
                (@List.nil.{0} RequestApprovalFold.TokenName))))
          (RequestApprovalFold.creation_request_policy.match_1.{1}
            (fun (x : Option.{0} RequestApprovalFold.Rule) => Prop)
            (RequestApprovalFold.CageState.rule (RequestApprovalFold.State.cage s))
            (fun (rule : RequestApprovalFold.Rule) =>
              And
                (@Eq.{1} RequestApprovalFold.RequestPolicy (RequestApprovalFold.CreateTx.policy tx)
                  (RequestApprovalFold.RequestPolicy.rule (RequestApprovalFold.Rule.hash rule)))
                (And
                  (@Eq.{1} RequestApprovalFold.RequestPolicy (RequestApprovalFold.RequestOutput.policy o)
                    (RequestApprovalFold.RequestPolicy.rule (RequestApprovalFold.Rule.hash rule)))
                  (And
                    (@Ne.{1} RequestApprovalFold.RequestPolicy (RequestApprovalFold.CreateTx.policy tx)
                      RequestApprovalFold.RequestPolicy.release)
                    (@Ne.{1} RequestApprovalFold.RequestPolicy (RequestApprovalFold.RequestOutput.policy o)
                      RequestApprovalFold.RequestPolicy.release))))
            fun (_ : Unit) =>
            And
              (@Eq.{1} RequestApprovalFold.RequestPolicy (RequestApprovalFold.CreateTx.policy tx)
                RequestApprovalFold.RequestPolicy.release)
              (@Eq.{1} RequestApprovalFold.RequestPolicy (RequestApprovalFold.RequestOutput.policy o)
                RequestApprovalFold.RequestPolicy.release))))
```

### RequestApprovalFold.fold_rule_predicate_independent

```lean
RequestApprovalFold.fold_rule_predicate_independent : ∀ (c : RequestApprovalFold.CageState) (hash : String)
  (p q : RequestApprovalFold.Request → List.{0} RequestApprovalFold.Signer → Prop) (iv : RequestApprovalFold.Interval)
  (refs : List.{0} RequestApprovalFold.TokenName) (sigs : List.{0} RequestApprovalFold.Signer)
  (i : RequestApprovalFold.FoldItem),
  Iff
    (RequestApprovalFold.itemAllowed
      (RequestApprovalFold.CageState.mk (RequestApprovalFold.CageState.id c) (RequestApprovalFold.CageState.oracles c)
        (RequestApprovalFold.CageState.protocol c) (RequestApprovalFold.CageState.tree c)
        (@Option.some.{0} RequestApprovalFold.Rule (RequestApprovalFold.Rule.mk hash p))
        (RequestApprovalFold.CageState.balances c) (RequestApprovalFold.CageState.value c)
        (RequestApprovalFold.CageState.minimum c))
      iv refs sigs i)
    (RequestApprovalFold.itemAllowed
      (RequestApprovalFold.CageState.mk (RequestApprovalFold.CageState.id c) (RequestApprovalFold.CageState.oracles c)
        (RequestApprovalFold.CageState.protocol c) (RequestApprovalFold.CageState.tree c)
        (@Option.some.{0} RequestApprovalFold.Rule (RequestApprovalFold.Rule.mk hash q))
        (RequestApprovalFold.CageState.balances c) (RequestApprovalFold.CageState.value c)
        (RequestApprovalFold.CageState.minimum c))
      iv refs sigs i)
```

### RequestApprovalFold.reachable_request_tokens

```lean
RequestApprovalFold.reachable_request_tokens : ∀ (s : RequestApprovalFold.State),
  RequestApprovalFold.Reachable s →
    ∀ (o : RequestApprovalFold.RequestOutput),
      @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
          (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o →
        And
          (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.RequestOutput.requestTokens o)
            (@List.cons.{0} RequestApprovalFold.TokenName
              (RequestApprovalFold.requestName (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s)))
              (@List.nil.{0} RequestApprovalFold.TokenName)))
          (@Eq.{1} RequestApprovalFold.RequestPolicy (RequestApprovalFold.RequestOutput.policy o)
            (RequestApprovalFold.requestPolicy (RequestApprovalFold.State.cage s)))
```

### RequestApprovalFold.fold_requires_request_token

```lean
RequestApprovalFold.fold_requires_request_token : ∀ (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.foldAccepted tx →
    ∀ (o : RequestApprovalFold.RequestOutput),
      @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
          (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.FoldTx.requests tx) o →
        And
          (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.RequestOutput.requestTokens o)
            (@List.cons.{0} RequestApprovalFold.TokenName
              (RequestApprovalFold.requestName
                (RequestApprovalFold.CageState.id (RequestApprovalFold.FoldTx.cageIn tx)))
              (@List.nil.{0} RequestApprovalFold.TokenName)))
          (@Eq.{1} RequestApprovalFold.RequestPolicy (RequestApprovalFold.RequestOutput.policy o)
            (RequestApprovalFold.requestPolicy (RequestApprovalFold.FoldTx.cageIn tx)))
```

### RequestApprovalFold.every_exit_burns_request_token

```lean
RequestApprovalFold.every_exit_burns_request_token : ∀ (o : RequestApprovalFold.RequestOutput)
  (spend : RequestApprovalFold.RequestSpend),
  RequestApprovalFold.requestSpendAllowed o spend →
    ∀ (token : RequestApprovalFold.TokenName),
      @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
          (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.RequestOutput.requestTokens o)
          token →
        @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
          (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.RequestSpend.burned spend) token
```

### RequestApprovalFold.live_removal_burns_request_token

```lean
@RequestApprovalFold.live_removal_burns_request_token : ∀ {s s' : RequestApprovalFold.State}
  {a : RequestApprovalFold.Action} (o : RequestApprovalFold.RequestOutput),
  RequestApprovalFold.Reachable s →
    RequestApprovalFold.Step s a s' →
      @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
          (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o →
        Not
            (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
              (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s') o) →
          @Exists.{1} RequestApprovalFold.RequestSpend fun (spend : RequestApprovalFold.RequestSpend) =>
            And
              (@Eq.{1} (Option.{0} RequestApprovalFold.RequestSpend) (RequestApprovalFold.Action.spend a)
                (@Option.some.{0} RequestApprovalFold.RequestSpend spend))
              (And (RequestApprovalFold.requestSpendAllowed o spend)
                (@Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                  (@List.instMembership.{0} RequestApprovalFold.TokenName)
                  (RequestApprovalFold.RequestSpend.burned spend)
                  (RequestApprovalFold.requestName
                    (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s)))))
```

### RequestApprovalFold.request_name_injective

```lean
RequestApprovalFold.request_name_injective : ∀ (a b : RequestApprovalFold.CageId),
  Iff (@Eq.{1} RequestApprovalFold.TokenName (RequestApprovalFold.requestName a) (RequestApprovalFold.requestName b))
    (@Eq.{1} RequestApprovalFold.CageId a b)
```

### RequestApprovalFold.request_token_discovery

```lean
RequestApprovalFold.request_token_discovery : ∀ (s : RequestApprovalFold.State) (id : RequestApprovalFold.CageId)
  (o : RequestApprovalFold.RequestOutput),
  RequestApprovalFold.Reachable s →
    Iff
      (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
        (@List.instMembership.{0} RequestApprovalFold.RequestOutput)
        (RequestApprovalFold.discoverRequests id (RequestApprovalFold.State.live s)) o)
      (And
        (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
          (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o)
        (@Eq.{1} RequestApprovalFold.CageId (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s)) id))
```

### RequestApprovalFold.request_token_discovery_across_registries

```lean
RequestApprovalFold.request_token_discovery_across_registries : ∀ (states : List.{0} RequestApprovalFold.State)
  (id : RequestApprovalFold.CageId) (o : RequestApprovalFold.RequestOutput),
  (∀ (s : RequestApprovalFold.State),
      @Membership.mem.{0, 0} RequestApprovalFold.State (List.{0} RequestApprovalFold.State)
          (@List.instMembership.{0} RequestApprovalFold.State) states s →
        RequestApprovalFold.Reachable s) →
    Iff
      (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
        (@List.instMembership.{0} RequestApprovalFold.RequestOutput)
        (RequestApprovalFold.discoverRequests id
          (@List.flatMap.{0, 0} RequestApprovalFold.State RequestApprovalFold.RequestOutput
            RequestApprovalFold.State.live states))
        o)
      (@Exists.{1} RequestApprovalFold.State fun (s : RequestApprovalFold.State) =>
        And
          (@Membership.mem.{0, 0} RequestApprovalFold.State (List.{0} RequestApprovalFold.State)
            (@List.instMembership.{0} RequestApprovalFold.State) states s)
          (And
            (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
              (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o)
            (@Eq.{1} RequestApprovalFold.CageId (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s))
              id)))
```

### RequestApprovalFold.output_refs_monotone

```lean
@RequestApprovalFold.output_refs_monotone : ∀ {s s' : RequestApprovalFold.State} {a : RequestApprovalFold.Action},
  RequestApprovalFold.Step s a s' →
    ∀ (ref : RequestApprovalFold.OutputRef),
      @Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
          (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedOutputs s) ref →
        @Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
          (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedOutputs s') ref
```

### RequestApprovalFold.reachable_output_refs

```lean
RequestApprovalFold.reachable_output_refs : ∀ (s : RequestApprovalFold.State),
  RequestApprovalFold.Reachable s →
    And
      (∀ (o : RequestApprovalFold.RequestOutput),
        @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
            (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o →
          @Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
            (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedOutputs s)
            (RequestApprovalFold.RequestOutput.ref o))
      (∀ (o : RequestApprovalFold.ClaimOutput),
        @Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
            (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.State.claims s) o →
          @Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
            (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedOutputs s)
            (RequestApprovalFold.ClaimOutput.ref o))
```

### RequestApprovalFold.reachable_output_refs_unique

```lean
RequestApprovalFold.reachable_output_refs_unique : ∀ (s : RequestApprovalFold.State),
  RequestApprovalFold.Reachable s →
    @List.Nodup.{0} RequestApprovalFold.OutputRef
      (@HAppend.hAppend.{0, 0, 0} (List.{0} RequestApprovalFold.OutputRef) (List.{0} RequestApprovalFold.OutputRef)
        (List.{0} RequestApprovalFold.OutputRef)
        (@instHAppendOfAppend.{0} (List.{0} RequestApprovalFold.OutputRef)
          (@List.instAppend.{0} RequestApprovalFold.OutputRef))
        (@List.map.{0, 0} RequestApprovalFold.RequestOutput RequestApprovalFold.OutputRef
          RequestApprovalFold.RequestOutput.ref (RequestApprovalFold.State.live s))
        (@List.map.{0, 0} RequestApprovalFold.ClaimOutput RequestApprovalFold.OutputRef
          RequestApprovalFold.ClaimOutput.ref (RequestApprovalFold.State.claims s)))
```

### RequestApprovalFold.unguarded_registry_impossible

```lean
RequestApprovalFold.unguarded_registry_impossible : ∀ (c : RequestApprovalFold.CageState)
  (existing : List.{0} RequestApprovalFold.CageId),
  @Eq.{1} (List.{0} RequestApprovalFold.Oracle) (RequestApprovalFold.CageState.oracles c)
      (@List.nil.{0} RequestApprovalFold.Oracle) →
    @Eq.{1} (Option.{0} RequestApprovalFold.Rule) (RequestApprovalFold.CageState.rule c)
        (@Option.none.{0} RequestApprovalFold.Rule) →
      Not (RequestApprovalFold.registryCreated c existing)
```

### RequestApprovalFold.zero_oracle_needs_rule

```lean
RequestApprovalFold.zero_oracle_needs_rule : ∀ (c : RequestApprovalFold.CageState)
  (existing : List.{0} RequestApprovalFold.CageId),
  RequestApprovalFold.registryCreated c existing →
    @Eq.{1} (List.{0} RequestApprovalFold.Oracle) (RequestApprovalFold.CageState.oracles c)
        (@List.nil.{0} RequestApprovalFold.Oracle) →
      @Exists.{1} RequestApprovalFold.Rule fun (rule : RequestApprovalFold.Rule) =>
        @Eq.{1} (Option.{0} RequestApprovalFold.Rule) (RequestApprovalFold.CageState.rule c)
          (@Option.some.{0} RequestApprovalFold.Rule rule)
```

### RequestApprovalFold.zero_oracle_evidence_empty

```lean
RequestApprovalFold.zero_oracle_evidence_empty : ∀ (c : RequestApprovalFold.CageState) (r : RequestApprovalFold.Request)
  (e : RequestApprovalFold.Selection),
  @Eq.{1} (List.{0} RequestApprovalFold.Oracle) (RequestApprovalFold.CageState.oracles c)
      (@List.nil.{0} RequestApprovalFold.Oracle) →
    And
      (RequestApprovalFold.hasApproval c r (@List.nil.{0} RequestApprovalFold.TokenName)
        (@List.nil.{0} RequestApprovalFold.Signer) e)
      (RequestApprovalFold.hasAccount c r (@List.nil.{0} RequestApprovalFold.TokenName) e)
```

### RequestApprovalFold.zero_oracle_creation_without_seed

```lean
RequestApprovalFold.zero_oracle_creation_without_seed : ∀ (c : RequestApprovalFold.CageState)
  (o : RequestApprovalFold.RequestOutput) (sigs : List.{0} RequestApprovalFold.Signer),
  @Eq.{1} (List.{0} RequestApprovalFold.Oracle) (RequestApprovalFold.CageState.oracles c)
      (@List.nil.{0} RequestApprovalFold.Oracle) →
    RequestApprovalFold.wellFormed c o →
      RequestApprovalFold.ruleAdmits c (RequestApprovalFold.RequestOutput.request o) sigs →
        RequestApprovalFold.createAllowed
          (RequestApprovalFold.CreateTx.mk (@List.nil.{0} RequestApprovalFold.OutputRef) c
            (@List.cons.{0} RequestApprovalFold.TokenName
              (RequestApprovalFold.requestName (RequestApprovalFold.CageState.id c))
              (@List.nil.{0} RequestApprovalFold.TokenName))
            (@List.cons.{0} RequestApprovalFold.RequestOutput o (@List.nil.{0} RequestApprovalFold.RequestOutput)) sigs
            (RequestApprovalFold.requestPolicy c))
          o
```

### RequestApprovalFold.zero_oracle_fold_without_approvals

```lean
RequestApprovalFold.zero_oracle_fold_without_approvals : ∀ (c : RequestApprovalFold.CageState)
  (o : RequestApprovalFold.RequestOutput) (iv : RequestApprovalFold.Interval) (e : RequestApprovalFold.Selection),
  @Eq.{1} (List.{0} RequestApprovalFold.Oracle) (RequestApprovalFold.CageState.oracles c)
      (@List.nil.{0} RequestApprovalFold.Oracle) →
    RequestApprovalFold.wellFormed c o →
      RequestApprovalFold.Interval.valid iv →
        @LT.lt.{0} RequestApprovalFold.Time instLTNat (RequestApprovalFold.Interval.upper iv)
            (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o)) →
          RequestApprovalFold.witnessWriteAllowed c (RequestApprovalFold.RequestOutput.request o) →
            (∀ (condition : RequestApprovalFold.Condition),
                @Membership.mem.{0, 0} RequestApprovalFold.Condition (List.{0} RequestApprovalFold.Condition)
                    (@List.instMembership.{0} RequestApprovalFold.Condition)
                    (RequestApprovalFold.Request.conditions (RequestApprovalFold.RequestOutput.request o)) condition →
                  RequestApprovalFold.Condition.holds (RequestApprovalFold.CageState.trie c) condition) →
              And
                (RequestApprovalFold.FoldRun iv (@List.nil.{0} RequestApprovalFold.TokenName)
                  (@List.nil.{0} RequestApprovalFold.Signer) c
                  (@List.cons.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)
                    (@List.nil.{0} RequestApprovalFold.FoldItem))
                  (RequestApprovalFold.itemResult c (RequestApprovalFold.FoldItem.write o e)))
                (@Eq.{1} RequestApprovalFold.Trie
                  (RequestApprovalFold.CageState.trie
                    (RequestApprovalFold.itemResult c (RequestApprovalFold.FoldItem.write o e)))
                  (RequestApprovalFold.Write.apply (RequestApprovalFold.CageState.trie c)
                    (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))))
```

### RequestApprovalFold.zero_oracle_account_without_verdicts

```lean
RequestApprovalFold.zero_oracle_account_without_verdicts : ∀ (s : RequestApprovalFold.State)
  (o : RequestApprovalFold.RequestOutput) (iv : RequestApprovalFold.Interval) (e : RequestApprovalFold.Selection),
  @Eq.{1} (List.{0} RequestApprovalFold.Oracle)
      (RequestApprovalFold.CageState.oracles (RequestApprovalFold.State.cage s))
      (@List.nil.{0} RequestApprovalFold.Oracle) →
    @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
        (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o →
      RequestApprovalFold.wellFormed (RequestApprovalFold.State.cage s) o →
        RequestApprovalFold.Interval.valid iv →
          @LE.le.{0} RequestApprovalFold.Time instLENat
              (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o))
              (RequestApprovalFold.Interval.lower iv) →
            @LE.le.{0} RequestApprovalFold.Time instLENat (RequestApprovalFold.Interval.upper iv)
                (@HAdd.hAdd.{0, 0, 0} RequestApprovalFold.Time Nat RequestApprovalFold.Time
                  (@instHAdd.{0} RequestApprovalFold.Time instAddNat)
                  (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o))
                  (RequestApprovalFold.Request.window (RequestApprovalFold.RequestOutput.request o))) →
              RequestApprovalFold.Step s
                (RequestApprovalFold.Action.fold
                  (RequestApprovalFold.singletonFold s iv (@List.nil.{0} RequestApprovalFold.Signer)
                    (RequestApprovalFold.FoldItem.account o e)
                    (RequestApprovalFold.Request.owner (RequestApprovalFold.RequestOutput.request o))))
                (RequestApprovalFold.afterFold s
                  (RequestApprovalFold.singletonFold s iv (@List.nil.{0} RequestApprovalFold.Signer)
                    (RequestApprovalFold.FoldItem.account o e)
                    (RequestApprovalFold.Request.owner (RequestApprovalFold.RequestOutput.request o))))
```

### RequestApprovalFold.present_condition_semantics

```lean
RequestApprovalFold.present_condition_semantics : ∀ (t : RequestApprovalFold.Trie) (k : RequestApprovalFold.Key),
  Iff (RequestApprovalFold.Condition.holds t (RequestApprovalFold.Condition.present k))
    (@Exists.{1} RequestApprovalFold.Val fun (v : RequestApprovalFold.Val) =>
      @Eq.{1} (Option.{0} RequestApprovalFold.Val) (t k) (@Option.some.{0} RequestApprovalFold.Val v))
```

### RequestApprovalFold.foldRun_oracle_conditions

```lean
@RequestApprovalFold.foldRun_oracle_conditions : ∀ {iv : RequestApprovalFold.Interval}
  {refs : List.{0} RequestApprovalFold.TokenName} {sigs : List.{0} RequestApprovalFold.Signer}
  {c out : RequestApprovalFold.CageState} {items : List.{0} RequestApprovalFold.FoldItem},
  RequestApprovalFold.FoldRun iv refs sigs c items out →
    ∀ (n : Nat) (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
      @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
          (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
            (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
              @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
            (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) items n)
          (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)) →
        ∀ (oracle : RequestApprovalFold.Oracle),
          @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
              (@List.instMembership.{0} RequestApprovalFold.Oracle) (RequestApprovalFold.CageState.oracles c) oracle →
            ∀ (condition : RequestApprovalFold.Condition),
              @Membership.mem.{0, 0} RequestApprovalFold.Condition (List.{0} RequestApprovalFold.Condition)
                  (@List.instMembership.{0} RequestApprovalFold.Condition)
                  (RequestApprovalFold.Evidence.conditions (e oracle)) condition →
                RequestApprovalFold.Condition.holds
                  (RequestApprovalFold.CageState.trie
                    (RequestApprovalFold.foldResult c (@List.take.{0} RequestApprovalFold.FoldItem n items)))
                  condition
```

### RequestApprovalFold.fold_all_conditions_hold

```lean
RequestApprovalFold.fold_all_conditions_hold : ∀ (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.foldAccepted tx →
    ∀ (n : Nat) (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
      @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
          (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
            (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
              @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
            (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
          (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)) →
        And
          (∀ (condition : RequestApprovalFold.Condition),
            @Membership.mem.{0, 0} RequestApprovalFold.Condition (List.{0} RequestApprovalFold.Condition)
                (@List.instMembership.{0} RequestApprovalFold.Condition)
                (RequestApprovalFold.Request.conditions (RequestApprovalFold.RequestOutput.request o)) condition →
              RequestApprovalFold.Condition.holds (RequestApprovalFold.CageState.trie (RequestApprovalFold.atTurn tx n))
                condition)
          (∀ (oracle : RequestApprovalFold.Oracle),
            @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
                (@List.instMembership.{0} RequestApprovalFold.Oracle)
                (RequestApprovalFold.CageState.oracles (RequestApprovalFold.FoldTx.cageIn tx)) oracle →
              ∀ (condition : RequestApprovalFold.Condition),
                @Membership.mem.{0, 0} RequestApprovalFold.Condition (List.{0} RequestApprovalFold.Condition)
                    (@List.instMembership.{0} RequestApprovalFold.Condition)
                    (RequestApprovalFold.Evidence.conditions (e oracle)) condition →
                  RequestApprovalFold.Condition.holds
                    (RequestApprovalFold.CageState.trie (RequestApprovalFold.atTurn tx n)) condition)
```

### RequestApprovalFold.approval_conditions_cannot_change

```lean
RequestApprovalFold.approval_conditions_cannot_change : ∀ (c : RequestApprovalFold.CageId)
  (r : RequestApprovalFold.Request) (o : RequestApprovalFold.Oracle) (rec rec' : RequestApprovalFold.SigningRecord)
  (a b : List.{0} RequestApprovalFold.Condition),
  Iff
    (@Eq.{1} RequestApprovalFold.TokenName (RequestApprovalFold.judgmentName c r o Bool.true rec a)
      (RequestApprovalFold.judgmentName c r o Bool.true rec' b))
    (And (@Eq.{1} RequestApprovalFold.SigningRecord rec rec') (@Eq.{1} (List.{0} RequestApprovalFold.Condition) a b))
```

### RequestApprovalFold.stale_approval_unusable

```lean
RequestApprovalFold.stale_approval_unusable : ∀ (tx : RequestApprovalFold.FoldTx) (n : Nat)
  (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection) (oracle : RequestApprovalFold.Oracle)
  (condition : RequestApprovalFold.Condition),
  @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
      (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
        (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
          @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
        (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
      (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)) →
    @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
        (@List.instMembership.{0} RequestApprovalFold.Oracle)
        (RequestApprovalFold.CageState.oracles (RequestApprovalFold.FoldTx.cageIn tx)) oracle →
      @Membership.mem.{0, 0} RequestApprovalFold.Condition (List.{0} RequestApprovalFold.Condition)
          (@List.instMembership.{0} RequestApprovalFold.Condition) (RequestApprovalFold.Evidence.conditions (e oracle))
          condition →
        Not
            (RequestApprovalFold.Condition.holds (RequestApprovalFold.CageState.trie (RequestApprovalFold.atTurn tx n))
              condition) →
          Not (RequestApprovalFold.foldAccepted tx)
```

### RequestApprovalFold.fold_evidence_binds_conditions

```lean
@RequestApprovalFold.fold_evidence_binds_conditions : ∀ {s s' : RequestApprovalFold.State}
  (tx : RequestApprovalFold.FoldTx) (n : Nat) (o : RequestApprovalFold.RequestOutput)
  (e : RequestApprovalFold.Selection),
  RequestApprovalFold.Step s (RequestApprovalFold.Action.fold tx) s' →
    @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
        (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
          (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
            @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
          (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
        (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)) →
      ∀ (oracle : RequestApprovalFold.Oracle),
        @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
            (@List.instMembership.{0} RequestApprovalFold.Oracle)
            (RequestApprovalFold.CageState.oracles (RequestApprovalFold.State.cage s)) oracle →
          And (RequestApprovalFold.Evidence.authorized (e oracle) oracle)
            (And (@Eq.{1} Bool (RequestApprovalFold.Evidence.approve (e oracle)) Bool.true)
              (Or
                (@Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                  (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.judgments s)
                  (RequestApprovalFold.judgmentName
                    (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s))
                    (RequestApprovalFold.RequestOutput.request o) oracle Bool.true
                    (RequestApprovalFold.Evidence.record (e oracle))
                    (RequestApprovalFold.Evidence.conditions (e oracle))))
                (@Eq.{1} (List.{0} RequestApprovalFold.Signer) (RequestApprovalFold.Evidence.signers (e oracle))
                  (RequestApprovalFold.FoldTx.signers tx))))
```

### RequestApprovalFold.expected_approval_lookup

```lean
RequestApprovalFold.expected_approval_lookup : ∀ (c : RequestApprovalFold.CageState) (r : RequestApprovalFold.Request)
  (e : RequestApprovalFold.Selection) (refs : List.{0} RequestApprovalFold.TokenName),
  Iff (RequestApprovalFold.hasApproval c r refs (@List.nil.{0} RequestApprovalFold.Signer) e)
    (And
      (∀ (oracle : RequestApprovalFold.Oracle),
        @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
            (@List.instMembership.{0} RequestApprovalFold.Oracle) (RequestApprovalFold.CageState.oracles c) oracle →
          And (RequestApprovalFold.Evidence.authorized (e oracle) oracle)
            (@Eq.{1} Bool (RequestApprovalFold.Evidence.approve (e oracle)) Bool.true))
      (∀ (name : RequestApprovalFold.TokenName),
        @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
            (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.expectedApprovals c r e)
            name →
          @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
            (@List.instMembership.{0} RequestApprovalFold.TokenName) refs name))
```

### RequestApprovalFold.folder_discovery_exact

```lean
RequestApprovalFold.folder_discovery_exact : ∀ (s : RequestApprovalFold.State) (iv : RequestApprovalFold.Interval)
  (sigs : List.{0} RequestApprovalFold.Signer) (e : RequestApprovalFold.Selection)
  (o : RequestApprovalFold.RequestOutput),
  RequestApprovalFold.Reachable s →
    Iff (RequestApprovalFold.folderFinds s iv sigs e o)
      (And
        (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
          (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o)
        (RequestApprovalFold.stepValid (RequestApprovalFold.State.cage s) iv (RequestApprovalFold.State.judgments s)
          sigs e o))
```

### RequestApprovalFold.folder_discovery_executable

```lean
RequestApprovalFold.folder_discovery_executable : ∀ (s : RequestApprovalFold.State) (iv : RequestApprovalFold.Interval)
  (sigs : List.{0} RequestApprovalFold.Signer) (e : RequestApprovalFold.Selection)
  (o : RequestApprovalFold.RequestOutput) (folder : RequestApprovalFold.Signer),
  RequestApprovalFold.Reachable s →
    Iff (RequestApprovalFold.folderFinds s iv sigs e o)
      (RequestApprovalFold.Step s
        (RequestApprovalFold.Action.fold
          (RequestApprovalFold.singletonFold s iv sigs (RequestApprovalFold.FoldItem.write o e) folder))
        (RequestApprovalFold.afterFold s
          (RequestApprovalFold.singletonFold s iv sigs (RequestApprovalFold.FoldItem.write o e) folder)))
```

### RequestApprovalFold.empty_fold_allowed

```lean
RequestApprovalFold.empty_fold_allowed : ∀ (s : RequestApprovalFold.State) (iv : RequestApprovalFold.Interval)
  (who : RequestApprovalFold.Signer),
  RequestApprovalFold.Interval.valid iv →
    have tx : RequestApprovalFold.FoldTx :=
      RequestApprovalFold.FoldTx.mk (RequestApprovalFold.State.cage s) (RequestApprovalFold.State.cage s)
        (@List.nil.{0} RequestApprovalFold.FoldItem) (@List.nil.{0} RequestApprovalFold.TokenName)
        (@List.nil.{0} RequestApprovalFold.Signer) iv who who (@List.nil.{0} RequestApprovalFold.TokenName)
        (@List.nil.{0} RequestApprovalFold.Payment) (@List.nil.{0} RequestApprovalFold.WitnessEvent)
        (@List.nil.{0} RequestApprovalFold.WitnessOutput) (@List.nil.{0} RequestApprovalFold.WitnessOutput)
        (@List.nil.{0} RequestApprovalFold.WitnessToken) (@List.nil.{0} RequestApprovalFold.WitnessToken);
    RequestApprovalFold.Step s (RequestApprovalFold.Action.fold tx) s
```

### RequestApprovalFold.empty_fold_earns_nothing

```lean
RequestApprovalFold.empty_fold_earns_nothing : ∀ (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.foldAccepted tx →
    @Eq.{1} (List.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx)
        (@List.nil.{0} RequestApprovalFold.FoldItem) →
      And
        (@Eq.{1} (List.{0} RequestApprovalFold.Payment) (RequestApprovalFold.FoldTx.payments tx)
          (@List.nil.{0} RequestApprovalFold.Payment))
        (And
          (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.FoldTx.burned tx)
            (@List.nil.{0} RequestApprovalFold.TokenName))
          (@Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.FoldTx.cageOut tx)
            (RequestApprovalFold.FoldTx.cageIn tx)))
```

### RequestApprovalFold.only_fold_changes_registry

```lean
@RequestApprovalFold.only_fold_changes_registry : ∀ {s s' : RequestApprovalFold.State} {a : RequestApprovalFold.Action},
  RequestApprovalFold.Step s a s' →
    @Ne.{1} RequestApprovalFold.CageState (RequestApprovalFold.State.cage s') (RequestApprovalFold.State.cage s) →
      @Exists.{1} RequestApprovalFold.FoldTx fun (tx : RequestApprovalFold.FoldTx) =>
        @Eq.{1} RequestApprovalFold.Action a (RequestApprovalFold.Action.fold tx)
```

### RequestApprovalFold.reachable_balances_backed

```lean
RequestApprovalFold.reachable_balances_backed : ∀ (s : RequestApprovalFold.State),
  RequestApprovalFold.Reachable s → RequestApprovalFold.Backed (RequestApprovalFold.State.cage s)
```

### RequestApprovalFold.fold_value_conservation

```lean
RequestApprovalFold.fold_value_conservation : ∀ (s s' : RequestApprovalFold.State) (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.Reachable s →
    RequestApprovalFold.Step s (RequestApprovalFold.Action.fold tx) s' →
      @Eq.{1} Nat
        (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
          (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
            (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
              (RequestApprovalFold.CageState.value (RequestApprovalFold.State.cage s))
              (RequestApprovalFold.requestEscrows (RequestApprovalFold.FoldTx.items tx)))
            (RequestApprovalFold.claimEscrows (RequestApprovalFold.FoldTx.items tx)))
          (RequestApprovalFold.witnessValue (RequestApprovalFold.FoldTx.witnessInputs tx)))
        (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
          (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
            (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
              (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
                (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
                  (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
                    (RequestApprovalFold.CageState.value (RequestApprovalFold.State.cage s'))
                    (RequestApprovalFold.requestRemainders (RequestApprovalFold.State.cage s)
                      (RequestApprovalFold.FoldTx.items tx)))
                  (RequestApprovalFold.claimPayouts (RequestApprovalFold.State.cage s)
                    (RequestApprovalFold.FoldTx.items tx)))
                (RequestApprovalFold.claimEscrows (RequestApprovalFold.FoldTx.items tx)))
              (RequestApprovalFold.unusedDepositRefunds (RequestApprovalFold.FoldTx.items tx)))
            (RequestApprovalFold.witnessRefundTotal (RequestApprovalFold.State.cage s)
              (RequestApprovalFold.FoldTx.items tx)))
          (RequestApprovalFold.witnessValue (RequestApprovalFold.FoldTx.witnessOutputs tx)))
```

### RequestApprovalFold.fold_request_conservation

```lean
RequestApprovalFold.fold_request_conservation : ∀ (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.foldAccepted tx →
    @Eq.{1} Nat (RequestApprovalFold.requestEscrows (RequestApprovalFold.FoldTx.items tx))
      (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
        (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
          (RequestApprovalFold.grossCredits (RequestApprovalFold.FoldTx.cageIn tx)
            (RequestApprovalFold.FoldTx.items tx))
          (RequestApprovalFold.requestRemainders (RequestApprovalFold.FoldTx.cageIn tx)
            (RequestApprovalFold.FoldTx.items tx)))
        (RequestApprovalFold.requestDepositInputs (RequestApprovalFold.FoldTx.items tx)))
```

### RequestApprovalFold.fold_balance_conservation

```lean
RequestApprovalFold.fold_balance_conservation : ∀ (s s' : RequestApprovalFold.State) (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.Reachable s →
    RequestApprovalFold.Step s (RequestApprovalFold.Action.fold tx) s' →
      @Eq.{1} Nat
        (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
          (RequestApprovalFold.balanceSum (RequestApprovalFold.State.cage s))
          (RequestApprovalFold.grossCredits (RequestApprovalFold.State.cage s) (RequestApprovalFold.FoldTx.items tx)))
        (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
          (RequestApprovalFold.balanceSum (RequestApprovalFold.State.cage s'))
          (RequestApprovalFold.claimPayouts (RequestApprovalFold.State.cage s) (RequestApprovalFold.FoldTx.items tx)))
```

### RequestApprovalFold.fold_payments_exact

```lean
RequestApprovalFold.fold_payments_exact : ∀ (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.foldAccepted tx →
    And
      (@Eq.{1} (List.{0} RequestApprovalFold.Payment) (RequestApprovalFold.FoldTx.payments tx)
        (RequestApprovalFold.foldPayments (RequestApprovalFold.FoldTx.cageIn tx) (RequestApprovalFold.FoldTx.folder tx)
          (RequestApprovalFold.FoldTx.items tx)))
      (@Eq.{1} Nat (RequestApprovalFold.totalPaid (RequestApprovalFold.FoldTx.payments tx))
        (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
          (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
            (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
              (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
                (RequestApprovalFold.requestRemainders (RequestApprovalFold.FoldTx.cageIn tx)
                  (RequestApprovalFold.FoldTx.items tx))
                (RequestApprovalFold.claimPayouts (RequestApprovalFold.FoldTx.cageIn tx)
                  (RequestApprovalFold.FoldTx.items tx)))
              (RequestApprovalFold.claimEscrows (RequestApprovalFold.FoldTx.items tx)))
            (RequestApprovalFold.unusedDepositRefunds (RequestApprovalFold.FoldTx.items tx)))
          (RequestApprovalFold.witnessRefundTotal (RequestApprovalFold.FoldTx.cageIn tx)
            (RequestApprovalFold.FoldTx.items tx))))
```

### RequestApprovalFold.group_credits_only_recorded_signers

```lean
RequestApprovalFold.group_credits_only_recorded_signers : ∀ (c : RequestApprovalFold.CageState)
  (r : RequestApprovalFold.Request) (o : RequestApprovalFold.Oracle) (e : RequestApprovalFold.Evidence)
  (k : RequestApprovalFold.Signer),
  RequestApprovalFold.Evidence.authorized e o →
    Not
        (@Membership.mem.{0, 0} RequestApprovalFold.Signer (List.{0} OracleIdentity.Key)
          (@List.instMembership.{0} OracleIdentity.Key)
          (OracleIdentity.recordedKeys (RequestApprovalFold.Evidence.record e)) k) →
      @Eq.{1} Nat (OracleIdentity.paidTo (RequestApprovalFold.oracleCredits r o e) k)
        (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0)))
```

### RequestApprovalFold.group_credits_exact_split

```lean
RequestApprovalFold.group_credits_exact_split : ∀ (r : RequestApprovalFold.Request) (o : RequestApprovalFold.Oracle)
  (e : RequestApprovalFold.Evidence),
  RequestApprovalFold.Evidence.authorized e o →
    @Eq.{1} (List.{0} OracleIdentity.Payment) (RequestApprovalFold.oracleCredits r o e)
      (OracleIdentity.splitRecorded (RequestApprovalFold.Evidence.record e) (RequestApprovalFold.Request.fee r o))
```

### RequestApprovalFold.judgment_record_cannot_change

```lean
RequestApprovalFold.judgment_record_cannot_change : ∀ (c : RequestApprovalFold.CageId) (r : RequestApprovalFold.Request)
  (o : RequestApprovalFold.Oracle) (v : Bool) (a b : RequestApprovalFold.SigningRecord)
  (cs : List.{0} RequestApprovalFold.Condition),
  @Eq.{1} RequestApprovalFold.TokenName (RequestApprovalFold.judgmentName c r o v a cs)
      (RequestApprovalFold.judgmentName c r o v b cs) →
    @Eq.{1} RequestApprovalFold.SigningRecord a b
```

### RequestApprovalFold.claim_creation_inversion

```lean
@RequestApprovalFold.claim_creation_inversion : ∀ {s s' : RequestApprovalFold.State}
  (tx : RequestApprovalFold.ClaimCreateTx),
  RequestApprovalFold.Step s (RequestApprovalFold.Action.claimCreate tx) s' →
    And
      (@Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.ClaimCreateTx.cageRef tx)
        (RequestApprovalFold.State.cage s))
      (And
        (@Eq.{1} RequestApprovalFold.CageId
          (RequestApprovalFold.ClaimOutput.cage (RequestApprovalFold.ClaimCreateTx.output tx))
          (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s)))
        (And
          (@Membership.mem.{0, 0} RequestApprovalFold.Signer (List.{0} RequestApprovalFold.Signer)
            (@List.instMembership.{0} RequestApprovalFold.Signer)
            (RequestApprovalFold.registryKeys (RequestApprovalFold.State.cage s))
            (RequestApprovalFold.ClaimOutput.key (RequestApprovalFold.ClaimCreateTx.output tx)))
          (And
            (@Membership.mem.{0, 0} RequestApprovalFold.Signer (List.{0} RequestApprovalFold.Signer)
              (@List.instMembership.{0} RequestApprovalFold.Signer) (RequestApprovalFold.ClaimCreateTx.signers tx)
              (RequestApprovalFold.ClaimOutput.key (RequestApprovalFold.ClaimCreateTx.output tx)))
            (And
              (@Eq.{1} (List.{0} RequestApprovalFold.TokenName)
                (RequestApprovalFold.ClaimOutput.tokens (RequestApprovalFold.ClaimCreateTx.output tx))
                (@List.cons.{0} RequestApprovalFold.TokenName
                  (RequestApprovalFold.claimName (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s)))
                  (@List.nil.{0} RequestApprovalFold.TokenName)))
              (And
                (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.ClaimCreateTx.minted tx)
                  (RequestApprovalFold.ClaimOutput.tokens (RequestApprovalFold.ClaimCreateTx.output tx)))
                (And
                  (Not
                    (@Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
                      (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedOutputs s)
                      (RequestApprovalFold.ClaimOutput.ref (RequestApprovalFold.ClaimCreateTx.output tx))))
                  (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterClaimCreate s tx))))))))
```

### RequestApprovalFold.reachable_claim_authorization

```lean
RequestApprovalFold.reachable_claim_authorization : ∀ (c : RequestApprovalFold.CageState)
  (existing : List.{0} RequestApprovalFold.CageId)
  (events :
    List.{0} (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
  (s : RequestApprovalFold.State) (o : RequestApprovalFold.ClaimOutput),
  RequestApprovalFold.registryCreated c existing →
    RequestApprovalFold.Trace (RequestApprovalFold.initial c) events s →
      @Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
          (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.State.claims s) o →
        @Exists.{1} RequestApprovalFold.State fun (before : RequestApprovalFold.State) =>
          @Exists.{1} RequestApprovalFold.State fun (after : RequestApprovalFold.State) =>
            @Exists.{1} RequestApprovalFold.ClaimCreateTx fun (tx : RequestApprovalFold.ClaimCreateTx) =>
              And
                (@Membership.mem.{0, 0}
                  (Prod.{0, 0} RequestApprovalFold.State
                    (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State))
                  (List.{0}
                    (Prod.{0, 0} RequestApprovalFold.State
                      (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
                  (@List.instMembership.{0}
                    (Prod.{0, 0} RequestApprovalFold.State
                      (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
                  events
                  (@Prod.mk.{0, 0} RequestApprovalFold.State
                    (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State) before
                    (@Prod.mk.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State
                      (RequestApprovalFold.Action.claimCreate tx) after)))
                (And (RequestApprovalFold.Step before (RequestApprovalFold.Action.claimCreate tx) after)
                  (And (@Eq.{1} RequestApprovalFold.ClaimOutput (RequestApprovalFold.ClaimCreateTx.output tx) o)
                    (@Membership.mem.{0, 0} RequestApprovalFold.Signer (List.{0} RequestApprovalFold.Signer)
                      (@List.instMembership.{0} RequestApprovalFold.Signer)
                      (RequestApprovalFold.ClaimCreateTx.signers tx) (RequestApprovalFold.ClaimOutput.key o))))
```

### RequestApprovalFold.claim_payout_fixed

```lean
RequestApprovalFold.claim_payout_fixed : ∀ (tx : RequestApprovalFold.FoldTx) (n : Nat)
  (o : RequestApprovalFold.ClaimOutput),
  RequestApprovalFold.foldAccepted tx →
    @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
        (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
          (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
            @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
          (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
        (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.claim o)) →
      And
        (@Eq.{1} (List.{0} RequestApprovalFold.Payment)
          (RequestApprovalFold.itemPayments (RequestApprovalFold.atTurn tx n) (RequestApprovalFold.FoldTx.folder tx)
            (RequestApprovalFold.FoldItem.claim o))
          (@List.cons.{0} RequestApprovalFold.Payment
            (RequestApprovalFold.Payment.mk (RequestApprovalFold.ClaimOutput.destination o)
              (RequestApprovalFold.ClaimOutput.datum o)
              (RequestApprovalFold.CageState.balances (RequestApprovalFold.atTurn tx n)
                (RequestApprovalFold.ClaimOutput.key o)))
            (@List.cons.{0} RequestApprovalFold.Payment
              (RequestApprovalFold.Payment.mk (RequestApprovalFold.FoldTx.folder tx) ""
                (RequestApprovalFold.ClaimOutput.value o))
              (@List.nil.{0} RequestApprovalFold.Payment))))
        (And
          (@Eq.{1} Nat
            (RequestApprovalFold.CageState.balances
              (RequestApprovalFold.itemResult (RequestApprovalFold.atTurn tx n) (RequestApprovalFold.FoldItem.claim o))
              (RequestApprovalFold.ClaimOutput.key o))
            (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0))))
          (∀ (k : RequestApprovalFold.Signer),
            @Ne.{1} RequestApprovalFold.Signer k (RequestApprovalFold.ClaimOutput.key o) →
              @Eq.{1} Nat
                (RequestApprovalFold.CageState.balances
                  (RequestApprovalFold.itemResult (RequestApprovalFold.atTurn tx n)
                    (RequestApprovalFold.FoldItem.claim o))
                  k)
                (RequestApprovalFold.CageState.balances (RequestApprovalFold.atTurn tx n) k)))
```

### RequestApprovalFold.claim_payout_in_actual_outputs

```lean
RequestApprovalFold.claim_payout_in_actual_outputs : ∀ (tx : RequestApprovalFold.FoldTx) (n : Nat)
  (o : RequestApprovalFold.ClaimOutput),
  RequestApprovalFold.foldAccepted tx →
    @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
        (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
          (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
            @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
          (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
        (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.claim o)) →
      @Membership.mem.{0, 0} RequestApprovalFold.Payment (List.{0} RequestApprovalFold.Payment)
        (@List.instMembership.{0} RequestApprovalFold.Payment) (RequestApprovalFold.FoldTx.payments tx)
        (RequestApprovalFold.Payment.mk (RequestApprovalFold.ClaimOutput.destination o)
          (RequestApprovalFold.ClaimOutput.datum o)
          (RequestApprovalFold.CageState.balances (RequestApprovalFold.atTurn tx n)
            (RequestApprovalFold.ClaimOutput.key o)))
```

### RequestApprovalFold.claim_below_minimum_refused

```lean
RequestApprovalFold.claim_below_minimum_refused : ∀ (c : RequestApprovalFold.CageState)
  (iv : RequestApprovalFold.Interval) (o : RequestApprovalFold.ClaimOutput),
  @LT.lt.{0} Nat instLTNat (RequestApprovalFold.CageState.balances c (RequestApprovalFold.ClaimOutput.key o))
      (RequestApprovalFold.CageState.minimum c) →
    Not (RequestApprovalFold.claimAllowed c iv o)
```

### RequestApprovalFold.claim_turn_balance

```lean
RequestApprovalFold.claim_turn_balance : ∀ (c : RequestApprovalFold.CageState) (o : RequestApprovalFold.RequestOutput)
  (e : RequestApprovalFold.Selection) (claim : RequestApprovalFold.ClaimOutput) (folder : RequestApprovalFold.Signer),
  @Eq.{1} (List.{0} RequestApprovalFold.Payment)
    (RequestApprovalFold.itemPayments (RequestApprovalFold.itemResult c (RequestApprovalFold.FoldItem.write o e)) folder
      (RequestApprovalFold.FoldItem.claim claim))
    (@List.cons.{0} RequestApprovalFold.Payment
      (RequestApprovalFold.Payment.mk (RequestApprovalFold.ClaimOutput.destination claim)
        (RequestApprovalFold.ClaimOutput.datum claim)
        (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
          (RequestApprovalFold.CageState.balances c (RequestApprovalFold.ClaimOutput.key claim))
          (OracleIdentity.paidTo (RequestApprovalFold.credits c (RequestApprovalFold.RequestOutput.request o) e)
            (RequestApprovalFold.ClaimOutput.key claim))))
      (@List.cons.{0} RequestApprovalFold.Payment
        (RequestApprovalFold.Payment.mk folder "" (RequestApprovalFold.ClaimOutput.value claim))
        (@List.nil.{0} RequestApprovalFold.Payment)))
```

### RequestApprovalFold.claim_consumed_and_burned

```lean
@RequestApprovalFold.claim_consumed_and_burned : ∀ {s s' : RequestApprovalFold.State} (tx : RequestApprovalFold.FoldTx)
  (o : RequestApprovalFold.ClaimOutput),
  RequestApprovalFold.Step s (RequestApprovalFold.Action.fold tx) s' →
    @Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
        (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.FoldTx.claims tx) o →
      And
        (Not
          (@Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
            (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.State.claims s') o))
        (∀ (token : RequestApprovalFold.TokenName),
          @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
              (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.ClaimOutput.tokens o)
              token →
            @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
              (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.FoldTx.burned tx) token)
```

### RequestApprovalFold.claim_withdrawal_inversion

```lean
@RequestApprovalFold.claim_withdrawal_inversion : ∀ {s s' : RequestApprovalFold.State}
  (tx : RequestApprovalFold.ClaimWithdrawTx),
  RequestApprovalFold.Reachable s →
    RequestApprovalFold.Step s (RequestApprovalFold.Action.claimWithdraw tx) s' →
      And
        (@Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
          (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.State.claims s)
          (RequestApprovalFold.ClaimWithdrawTx.input tx))
        (And
          (@Membership.mem.{0, 0} RequestApprovalFold.Signer (List.{0} RequestApprovalFold.Signer)
            (@List.instMembership.{0} RequestApprovalFold.Signer) (RequestApprovalFold.ClaimWithdrawTx.signers tx)
            (RequestApprovalFold.ClaimOutput.key (RequestApprovalFold.ClaimWithdrawTx.input tx)))
          (And
            (@LE.le.{0} RequestApprovalFold.Time instLENat
              (RequestApprovalFold.ClaimOutput.deadline (RequestApprovalFold.ClaimWithdrawTx.input tx))
              (RequestApprovalFold.Interval.lower (RequestApprovalFold.ClaimWithdrawTx.interval tx)))
            (And (RequestApprovalFold.Interval.valid (RequestApprovalFold.ClaimWithdrawTx.interval tx))
              (And
                (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.ClaimWithdrawTx.burned tx)
                  (RequestApprovalFold.ClaimOutput.tokens (RequestApprovalFold.ClaimWithdrawTx.input tx)))
                (And
                  (@Eq.{1} RequestApprovalFold.Signer (RequestApprovalFold.ClaimWithdrawTx.beneficiary tx)
                    (RequestApprovalFold.ClaimOutput.key (RequestApprovalFold.ClaimWithdrawTx.input tx)))
                  (And
                    (@Eq.{1} Nat (RequestApprovalFold.ClaimWithdrawTx.paid tx)
                      (RequestApprovalFold.ClaimOutput.value (RequestApprovalFold.ClaimWithdrawTx.input tx)))
                    (And
                      (@Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.State.cage s')
                        (RequestApprovalFold.State.cage s))
                      (Not
                        (@Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput
                          (List.{0} RequestApprovalFold.ClaimOutput)
                          (@List.instMembership.{0} RequestApprovalFold.ClaimOutput)
                          (RequestApprovalFold.State.claims s') (RequestApprovalFold.ClaimWithdrawTx.input tx))))))))))
```

### RequestApprovalFold.claim_withdrawal_available

```lean
RequestApprovalFold.claim_withdrawal_available : ∀ (s : RequestApprovalFold.State) (o : RequestApprovalFold.ClaimOutput)
  (iv : RequestApprovalFold.Interval),
  @Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
      (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.State.claims s) o →
    RequestApprovalFold.Interval.valid iv →
      @LE.le.{0} RequestApprovalFold.Time instLENat (RequestApprovalFold.ClaimOutput.deadline o)
          (RequestApprovalFold.Interval.lower iv) →
        have tx : RequestApprovalFold.ClaimWithdrawTx :=
          RequestApprovalFold.ClaimWithdrawTx.mk o iv
            (@List.cons.{0} RequestApprovalFold.Signer (RequestApprovalFold.ClaimOutput.key o)
              (@List.nil.{0} RequestApprovalFold.Signer))
            (RequestApprovalFold.ClaimOutput.tokens o) (RequestApprovalFold.ClaimOutput.key o)
            (RequestApprovalFold.ClaimOutput.value o);
        RequestApprovalFold.Step s (RequestApprovalFold.Action.claimWithdraw tx)
          (RequestApprovalFold.afterClaimWithdraw s tx)
```

### RequestApprovalFold.claim_windows_disjoint

```lean
RequestApprovalFold.claim_windows_disjoint : ∀ (c : RequestApprovalFold.CageState) (iv : RequestApprovalFold.Interval)
  (o : RequestApprovalFold.ClaimOutput) (tx : RequestApprovalFold.ClaimWithdrawTx),
  RequestApprovalFold.claimAllowed c iv o →
    @Eq.{1} RequestApprovalFold.ClaimOutput (RequestApprovalFold.ClaimWithdrawTx.input tx) o →
      @Eq.{1} RequestApprovalFold.Interval (RequestApprovalFold.ClaimWithdrawTx.interval tx) iv →
        Not (RequestApprovalFold.claimWithdrawAllowed tx)
```

### RequestApprovalFold.claim_discovery_exact

```lean
RequestApprovalFold.claim_discovery_exact : ∀ (s : RequestApprovalFold.State) (id : RequestApprovalFold.CageId)
  (o : RequestApprovalFold.ClaimOutput),
  RequestApprovalFold.Reachable s →
    Iff
      (@Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
        (@List.instMembership.{0} RequestApprovalFold.ClaimOutput)
        (RequestApprovalFold.discoverClaims id (RequestApprovalFold.State.claims s)) o)
      (And
        (@Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
          (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.State.claims s) o)
        (@Eq.{1} RequestApprovalFold.CageId (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s)) id))
```

### RequestApprovalFold.request_withdrawal_preserves_registry

```lean
@RequestApprovalFold.request_withdrawal_preserves_registry : ∀ {s s' : RequestApprovalFold.State}
  (tx : RequestApprovalFold.WithdrawTx),
  RequestApprovalFold.Step s (RequestApprovalFold.Action.withdraw tx) s' →
    @Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.State.cage s') (RequestApprovalFold.State.cage s)
```

### RequestApprovalFold.fold_interval_fits_every_item

```lean
RequestApprovalFold.fold_interval_fits_every_item : ∀ (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.foldAccepted tx →
    And (RequestApprovalFold.Interval.valid (RequestApprovalFold.FoldTx.interval tx))
      (And
        (∀ (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
          @Membership.mem.{0, 0} RequestApprovalFold.FoldItem (List.{0} RequestApprovalFold.FoldItem)
              (@List.instMembership.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx)
              (RequestApprovalFold.FoldItem.write o e) →
            @LT.lt.{0} RequestApprovalFold.Time instLTNat
              (RequestApprovalFold.Interval.upper (RequestApprovalFold.FoldTx.interval tx))
              (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o)))
        (And
          (∀ (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
            @Membership.mem.{0, 0} RequestApprovalFold.FoldItem (List.{0} RequestApprovalFold.FoldItem)
                (@List.instMembership.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx)
                (RequestApprovalFold.FoldItem.account o e) →
              And
                (@LE.le.{0} RequestApprovalFold.Time instLENat
                  (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o))
                  (RequestApprovalFold.Interval.lower (RequestApprovalFold.FoldTx.interval tx)))
                (@LE.le.{0} RequestApprovalFold.Time instLENat
                  (RequestApprovalFold.Interval.upper (RequestApprovalFold.FoldTx.interval tx))
                  (@HAdd.hAdd.{0, 0, 0} RequestApprovalFold.Time Nat RequestApprovalFold.Time
                    (@instHAdd.{0} RequestApprovalFold.Time instAddNat)
                    (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o))
                    (RequestApprovalFold.Request.window (RequestApprovalFold.RequestOutput.request o)))))
          (And
            (∀ (o : RequestApprovalFold.ClaimOutput),
              @Membership.mem.{0, 0} RequestApprovalFold.FoldItem (List.{0} RequestApprovalFold.FoldItem)
                  (@List.instMembership.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx)
                  (RequestApprovalFold.FoldItem.claim o) →
                @LT.lt.{0} RequestApprovalFold.Time instLTNat
                  (RequestApprovalFold.Interval.upper (RequestApprovalFold.FoldTx.interval tx))
                  (RequestApprovalFold.ClaimOutput.deadline o))
            (And
              (∀ (o : RequestApprovalFold.Extraction),
                @Membership.mem.{0, 0} RequestApprovalFold.FoldItem (List.{0} RequestApprovalFold.FoldItem)
                    (@List.instMembership.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx)
                    (RequestApprovalFold.FoldItem.extract o) →
                  @LT.lt.{0} RequestApprovalFold.Time instLTNat
                    (RequestApprovalFold.Interval.upper (RequestApprovalFold.FoldTx.interval tx))
                    (RequestApprovalFold.Extraction.deadline o))
              (∀ (o : RequestApprovalFold.Extraction),
                @Membership.mem.{0, 0} RequestApprovalFold.FoldItem (List.{0} RequestApprovalFold.FoldItem)
                    (@List.instMembership.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx)
                    (RequestApprovalFold.FoldItem.extractAccount o) →
                  And
                    (@LE.le.{0} RequestApprovalFold.Time instLENat (RequestApprovalFold.Extraction.deadline o)
                      (RequestApprovalFold.Interval.lower (RequestApprovalFold.FoldTx.interval tx)))
                    (@LE.le.{0} RequestApprovalFold.Time instLENat
                      (RequestApprovalFold.Interval.upper (RequestApprovalFold.FoldTx.interval tx))
                      (@HAdd.hAdd.{0, 0, 0} RequestApprovalFold.Time Nat RequestApprovalFold.Time
                        (@instHAdd.{0} RequestApprovalFold.Time instAddNat) (RequestApprovalFold.Extraction.deadline o)
                        (RequestApprovalFold.Extraction.window o))))))))
```

### RequestApprovalFold.step_inversion

```lean
RequestApprovalFold.step_inversion : ∀ (s s' : RequestApprovalFold.State) (a : RequestApprovalFold.Action),
  Iff (RequestApprovalFold.Step s a s')
    (RequestApprovalFold.step_inversion.match_1.{1} (fun (a : RequestApprovalFold.Action) => Prop) a
      (fun (tx : RequestApprovalFold.CreateTx) (o : RequestApprovalFold.RequestOutput) =>
        And
          (@Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.CreateTx.cageRef tx)
            (RequestApprovalFold.State.cage s))
          (And (RequestApprovalFold.createAllowed tx o)
            (And
              (∀ (seed : RequestApprovalFold.OutputRef),
                @Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
                    (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.CreateTx.spent tx)
                    seed →
                  Not
                    (@Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
                      (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedSeeds s)
                      seed))
              (And
                (Not
                  (@Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
                    (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedOutputs s)
                    (RequestApprovalFold.RequestOutput.ref o)))
                (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterCreate s tx o))))))
      (fun (tx : RequestApprovalFold.JudgmentTx) =>
        And
          (@Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.JudgmentTx.cageRef tx)
            (RequestApprovalFold.State.cage s))
          (And
            (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
              (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s)
              (RequestApprovalFold.JudgmentTx.requestRef tx))
            (And (RequestApprovalFold.judgmentAllowed tx)
              (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterJudgment s tx)))))
      (fun (tx : RequestApprovalFold.FoldTx) =>
        And
          (@Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.FoldTx.cageIn tx)
            (RequestApprovalFold.State.cage s))
          (And
            (∀ (o : RequestApprovalFold.RequestOutput),
              @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
                  (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.FoldTx.requests tx)
                  o →
                @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
                  (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o)
            (And
              (∀ (o : RequestApprovalFold.ClaimOutput),
                @Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
                    (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.FoldTx.claims tx)
                    o →
                  @Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
                    (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.State.claims s) o)
              (And
                (∀ (name : RequestApprovalFold.TokenName),
                  @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                      (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.FoldTx.refs tx)
                      name →
                    @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                      (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.judgments s)
                      name)
                (And (RequestApprovalFold.foldAccepted tx)
                  (And
                    (∀ (o : RequestApprovalFold.Extraction),
                      @Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
                          (@List.instMembership.{0} RequestApprovalFold.Extraction)
                          (RequestApprovalFold.FoldTx.extractions tx) o →
                        @Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
                          (@List.instMembership.{0} RequestApprovalFold.Extraction)
                          (RequestApprovalFold.State.extractions s) o)
                    (And
                      (∀ (w : RequestApprovalFold.WitnessOutput),
                        @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput
                            (List.{0} RequestApprovalFold.WitnessOutput)
                            (@List.instMembership.{0} RequestApprovalFold.WitnessOutput)
                            (RequestApprovalFold.FoldTx.witnessInputs tx) w →
                          @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput
                            (List.{0} RequestApprovalFold.WitnessOutput)
                            (@List.instMembership.{0} RequestApprovalFold.WitnessOutput)
                            (RequestApprovalFold.State.witnesses s) w)
                      (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterFold s tx)))))))))
      (fun (tx : RequestApprovalFold.WithdrawTx) =>
        And
          (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
            (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s)
            (RequestApprovalFold.WithdrawTx.input tx))
          (And (RequestApprovalFold.withdrawAllowed tx)
            (@Eq.{1} RequestApprovalFold.State s'
              (RequestApprovalFold.afterExit s (RequestApprovalFold.WithdrawTx.input tx)))))
      (fun (name : RequestApprovalFold.TokenName) =>
        And
          (@Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
            (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.judgments s) name)
          (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterBurn s name)))
      (fun (tx : RequestApprovalFold.PriceMintTx) =>
        And (RequestApprovalFold.priceMintAllowed tx)
          (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterPriceMint s tx)))
      (fun (tx : RequestApprovalFold.PriceUpdateTx) =>
        And
          (@Membership.mem.{0, 0} RequestApprovalFold.PriceNotice (List.{0} RequestApprovalFold.PriceNotice)
            (@List.instMembership.{0} RequestApprovalFold.PriceNotice) (RequestApprovalFold.State.notices s)
            (RequestApprovalFold.PriceUpdateTx.input tx))
          (And (RequestApprovalFold.priceUpdateAllowed tx)
            (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterPriceUpdate s tx))))
      (fun (tx : RequestApprovalFold.ClaimCreateTx) =>
        And
          (@Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.ClaimCreateTx.cageRef tx)
            (RequestApprovalFold.State.cage s))
          (And (RequestApprovalFold.claimCreateAllowed tx)
            (And
              (Not
                (@Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
                  (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedOutputs s)
                  (RequestApprovalFold.ClaimOutput.ref (RequestApprovalFold.ClaimCreateTx.output tx))))
              (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterClaimCreate s tx)))))
      (fun (tx : RequestApprovalFold.ClaimWithdrawTx) =>
        And
          (@Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
            (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.State.claims s)
            (RequestApprovalFold.ClaimWithdrawTx.input tx))
          (And (RequestApprovalFold.claimWithdrawAllowed tx)
            (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterClaimWithdraw s tx))))
      (fun (tx : RequestApprovalFold.ExtractionCreateTx) =>
        And
          (@Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.ExtractionCreateTx.cageRef tx)
            (RequestApprovalFold.State.cage s))
          (And (RequestApprovalFold.extractionCreateAllowed tx)
            (And
              (Not
                (@Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
                  (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedOutputs s)
                  (RequestApprovalFold.Extraction.ref (RequestApprovalFold.ExtractionCreateTx.output tx))))
              (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterExtractionCreate s tx)))))
      fun (tx : RequestApprovalFold.ExtractionWithdrawTx) =>
      And
        (@Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
          (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.State.extractions s)
          (RequestApprovalFold.ExtractionWithdrawTx.input tx))
        (And (RequestApprovalFold.extractionWithdrawAllowed tx)
          (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterExtractionWithdraw s tx))))
```

### RequestApprovalFold.foldRun_inversion

```lean
RequestApprovalFold.foldRun_inversion : ∀ (iv : RequestApprovalFold.Interval)
  (refs : List.{0} RequestApprovalFold.TokenName) (sigs : List.{0} RequestApprovalFold.Signer)
  (c out : RequestApprovalFold.CageState) (items : List.{0} RequestApprovalFold.FoldItem),
  Iff (RequestApprovalFold.FoldRun iv refs sigs c items out)
    (RequestApprovalFold.foldRun_inversion.match_1.{1} (fun (items : List.{0} RequestApprovalFold.FoldItem) => Prop)
      items (fun (_ : Unit) => @Eq.{1} RequestApprovalFold.CageState out c)
      fun (item : RequestApprovalFold.FoldItem) (rest : List.{0} RequestApprovalFold.FoldItem) =>
      And (RequestApprovalFold.itemAllowed c iv refs sigs item)
        (RequestApprovalFold.FoldRun iv refs sigs (RequestApprovalFold.itemResult c item) rest out))
```

### RequestApprovalFold.claim_item_inversion

```lean
RequestApprovalFold.claim_item_inversion : ∀ (tx : RequestApprovalFold.FoldTx) (n : Nat)
  (o : RequestApprovalFold.ClaimOutput),
  RequestApprovalFold.foldAccepted tx →
    @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
        (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
          (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
            @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
          (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
        (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.claim o)) →
      And
        (@Eq.{1} RequestApprovalFold.CageId (RequestApprovalFold.ClaimOutput.cage o)
          (RequestApprovalFold.CageState.id (RequestApprovalFold.FoldTx.cageIn tx)))
        (And
          (@Membership.mem.{0, 0} RequestApprovalFold.Signer (List.{0} RequestApprovalFold.Signer)
            (@List.instMembership.{0} RequestApprovalFold.Signer)
            (RequestApprovalFold.registryKeys (RequestApprovalFold.FoldTx.cageIn tx))
            (RequestApprovalFold.ClaimOutput.key o))
          (And
            (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.ClaimOutput.tokens o)
              (@List.cons.{0} RequestApprovalFold.TokenName
                (RequestApprovalFold.claimName
                  (RequestApprovalFold.CageState.id (RequestApprovalFold.FoldTx.cageIn tx)))
                (@List.nil.{0} RequestApprovalFold.TokenName)))
            (And (RequestApprovalFold.Interval.valid (RequestApprovalFold.FoldTx.interval tx))
              (And
                (@LT.lt.{0} RequestApprovalFold.Time instLTNat
                  (RequestApprovalFold.Interval.upper (RequestApprovalFold.FoldTx.interval tx))
                  (RequestApprovalFold.ClaimOutput.deadline o))
                (@LE.le.{0} Nat instLENat (RequestApprovalFold.CageState.minimum (RequestApprovalFold.FoldTx.cageIn tx))
                  (RequestApprovalFold.CageState.balances (RequestApprovalFold.atTurn tx n)
                    (RequestApprovalFold.ClaimOutput.key o)))))))
```

### RequestApprovalFold.claim_windows_cover

```lean
RequestApprovalFold.claim_windows_cover : ∀ (c : RequestApprovalFold.CageState) (o : RequestApprovalFold.ClaimOutput)
  (now : RequestApprovalFold.Time),
  @Eq.{1} RequestApprovalFold.CageId (RequestApprovalFold.ClaimOutput.cage o) (RequestApprovalFold.CageState.id c) →
    @Membership.mem.{0, 0} RequestApprovalFold.Signer (List.{0} RequestApprovalFold.Signer)
        (@List.instMembership.{0} RequestApprovalFold.Signer) (RequestApprovalFold.registryKeys c)
        (RequestApprovalFold.ClaimOutput.key o) →
      @Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.ClaimOutput.tokens o)
          (@List.cons.{0} RequestApprovalFold.TokenName
            (RequestApprovalFold.claimName (RequestApprovalFold.CageState.id c))
            (@List.nil.{0} RequestApprovalFold.TokenName)) →
        @LE.le.{0} Nat instLENat (RequestApprovalFold.CageState.minimum c)
            (RequestApprovalFold.CageState.balances c (RequestApprovalFold.ClaimOutput.key o)) →
          Or (RequestApprovalFold.claimAllowed c (RequestApprovalFold.Interval.mk now now) o)
            (RequestApprovalFold.claimWithdrawAllowed
              (RequestApprovalFold.ClaimWithdrawTx.mk o (RequestApprovalFold.Interval.mk now now)
                (@List.cons.{0} RequestApprovalFold.Signer (RequestApprovalFold.ClaimOutput.key o)
                  (@List.nil.{0} RequestApprovalFold.Signer))
                (RequestApprovalFold.ClaimOutput.tokens o) (RequestApprovalFold.ClaimOutput.key o)
                (RequestApprovalFold.ClaimOutput.value o)))
```

### RequestApprovalFold.fold_group_credits_only_recorded_signers

```lean
RequestApprovalFold.fold_group_credits_only_recorded_signers : ∀ (s s' : RequestApprovalFold.State)
  (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.Step s (RequestApprovalFold.Action.fold tx) s' →
    And
      (∀ (n : Nat) (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
        Or
            (@Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
              (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
                (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
                  @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
                (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx)
                n)
              (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)))
            (@Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
              (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
                (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
                  @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
                (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx)
                n)
              (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.account o e))) →
          ∀ (oracle : RequestApprovalFold.Oracle),
            @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
                (@List.instMembership.{0} RequestApprovalFold.Oracle)
                (RequestApprovalFold.CageState.oracles (RequestApprovalFold.FoldTx.cageIn tx)) oracle →
              And (RequestApprovalFold.Evidence.authorized (e oracle) oracle)
                (And
                  (Or
                    (@Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                      (@List.instMembership.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.State.judgments s)
                      (RequestApprovalFold.Evidence.name (e oracle)
                        (RequestApprovalFold.CageState.id (RequestApprovalFold.FoldTx.cageIn tx))
                        (RequestApprovalFold.RequestOutput.request o) oracle))
                    (And (@Eq.{1} Bool (RequestApprovalFold.Evidence.approve (e oracle)) Bool.true)
                      (@Eq.{1} (List.{0} RequestApprovalFold.Signer) (RequestApprovalFold.Evidence.signers (e oracle))
                        (RequestApprovalFold.FoldTx.signers tx))))
                  (∀ (key : OracleIdentity.Key),
                    Not
                        (@Membership.mem.{0, 0} OracleIdentity.Key (List.{0} OracleIdentity.Key)
                          (@List.instMembership.{0} OracleIdentity.Key)
                          (OracleIdentity.recordedKeys (RequestApprovalFold.Evidence.record (e oracle))) key) →
                      @Eq.{1} Nat
                        (OracleIdentity.paidTo
                          (RequestApprovalFold.oracleCredits (RequestApprovalFold.RequestOutput.request o) oracle
                            (e oracle))
                          key)
                        (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0))))))
      (∀ (key : OracleIdentity.Key),
        (∀ (n : Nat) (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
            Or
                (@Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
                  (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
                    (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
                      @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
                    (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem)
                    (RequestApprovalFold.FoldTx.items tx) n)
                  (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)))
                (@Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
                  (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
                    (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
                      @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
                    (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem)
                    (RequestApprovalFold.FoldTx.items tx) n)
                  (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.account o e))) →
              ∀ (oracle : RequestApprovalFold.Oracle),
                @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
                    (@List.instMembership.{0} RequestApprovalFold.Oracle)
                    (RequestApprovalFold.CageState.oracles (RequestApprovalFold.FoldTx.cageIn tx)) oracle →
                  Not
                    (@Membership.mem.{0, 0} OracleIdentity.Key (List.{0} OracleIdentity.Key)
                      (@List.instMembership.{0} OracleIdentity.Key)
                      (OracleIdentity.recordedKeys (RequestApprovalFold.Evidence.record (e oracle))) key)) →
          @LE.le.{0} Nat instLENat (RequestApprovalFold.CageState.balances (RequestApprovalFold.State.cage s') key)
            (RequestApprovalFold.CageState.balances (RequestApprovalFold.State.cage s) key))
```

### RequestApprovalFold.trace_reachability

```lean
RequestApprovalFold.trace_reachability : ∀ (s : RequestApprovalFold.State),
  Iff (RequestApprovalFold.Reachable s)
    (@Exists.{1} RequestApprovalFold.CageState fun (c : RequestApprovalFold.CageState) =>
      @Exists.{1} (List.{0} RequestApprovalFold.CageId) fun (existing : List.{0} RequestApprovalFold.CageId) =>
        @Exists.{1}
          (List.{0}
            (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
          fun
            (events :
              List.{0}
                (Prod.{0, 0} RequestApprovalFold.State
                  (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State))) =>
          And (RequestApprovalFold.registryCreated c existing)
            (RequestApprovalFold.Trace (RequestApprovalFold.initial c) events s))
```

### RequestApprovalFold.exit_windows_disjoint

```lean
RequestApprovalFold.exit_windows_disjoint : ∀ (o : RequestApprovalFold.RequestOutput)
  (iv : RequestApprovalFold.Interval) (a b : RequestApprovalFold.ExitKind),
  RequestApprovalFold.exitAt o iv a → RequestApprovalFold.exitAt o iv b → @Eq.{1} RequestApprovalFold.ExitKind a b
```

### RequestApprovalFold.logical_tree_stripped

```lean
RequestApprovalFold.logical_tree_stripped : ∀ (tree : RequestApprovalFold.EntryTree),
  @Eq.{1} RequestApprovalFold.Trie (RequestApprovalFold.logicalTree (RequestApprovalFold.stripWitnesses tree))
    (RequestApprovalFold.logicalTree tree)
```

### RequestApprovalFold.conditions_read_logical

```lean
RequestApprovalFold.conditions_read_logical : ∀ (tree : RequestApprovalFold.EntryTree)
  (condition : RequestApprovalFold.Condition),
  Iff (RequestApprovalFold.Condition.holds (RequestApprovalFold.logicalTree tree) condition)
    (RequestApprovalFold.Condition.holds (RequestApprovalFold.logicalTree (RequestApprovalFold.stripWitnesses tree))
      condition)
```

### RequestApprovalFold.reachable_witness_bijection

```lean
RequestApprovalFold.reachable_witness_bijection : ∀ (s : RequestApprovalFold.State),
  RequestApprovalFold.Reachable s → RequestApprovalFold.WitnessBacked s
```

### RequestApprovalFold.live_witness_fact

```lean
RequestApprovalFold.live_witness_fact : ∀ (s : RequestApprovalFold.State) (out : RequestApprovalFold.WitnessOutput),
  RequestApprovalFold.Reachable s →
    @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
        (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s) out →
      And
        (@Eq.{1} RequestApprovalFold.CageId
          (RequestApprovalFold.WitnessToken.cage (RequestApprovalFold.WitnessOutput.token out))
          (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s)))
        (And
          (@Eq.{1} (Option.{0} RequestApprovalFold.Val)
            (RequestApprovalFold.CageState.trie (RequestApprovalFold.State.cage s)
              (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token out)))
            (RequestApprovalFold.WitnessData.fact
              (RequestApprovalFold.WitnessToken.data (RequestApprovalFold.WitnessOutput.token out))))
          (And (@Eq.{1} String (RequestApprovalFold.WitnessOutput.address out) RequestApprovalFold.registryAddress)
            (@Eq.{1} Nat (RequestApprovalFold.WitnessOutput.value out)
              (RequestApprovalFold.WitnessData.deposit
                (RequestApprovalFold.WitnessToken.data (RequestApprovalFold.WitnessOutput.token out))))))
```

### RequestApprovalFold.live_witness_presence

```lean
RequestApprovalFold.live_witness_presence : ∀ (s : RequestApprovalFold.State) (out : RequestApprovalFold.WitnessOutput)
  (v : RequestApprovalFold.Val),
  RequestApprovalFold.Reachable s →
    @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
        (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s) out →
      @Eq.{1} (Option.{0} RequestApprovalFold.Val)
          (RequestApprovalFold.WitnessData.fact
            (RequestApprovalFold.WitnessToken.data (RequestApprovalFold.WitnessOutput.token out)))
          (@Option.some.{0} RequestApprovalFold.Val v) →
        And
          (RequestApprovalFold.Condition.holds (RequestApprovalFold.CageState.trie (RequestApprovalFold.State.cage s))
            (RequestApprovalFold.Condition.present
              (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token out))))
          (RequestApprovalFold.Condition.holds (RequestApprovalFold.CageState.trie (RequestApprovalFold.State.cage s))
            (RequestApprovalFold.Condition.equals
              (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token out)) v))
```

### RequestApprovalFold.live_witness_absence

```lean
RequestApprovalFold.live_witness_absence : ∀ (s : RequestApprovalFold.State) (out : RequestApprovalFold.WitnessOutput),
  RequestApprovalFold.Reachable s →
    @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
        (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s) out →
      @Eq.{1} (Option.{0} RequestApprovalFold.Val)
          (RequestApprovalFold.WitnessData.fact
            (RequestApprovalFold.WitnessToken.data (RequestApprovalFold.WitnessOutput.token out)))
          (@Option.none.{0} RequestApprovalFold.Val) →
        RequestApprovalFold.Condition.holds (RequestApprovalFold.CageState.trie (RequestApprovalFold.State.cage s))
          (RequestApprovalFold.Condition.absent
            (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token out)))
```

### RequestApprovalFold.one_live_witness_per_key

```lean
RequestApprovalFold.one_live_witness_per_key : ∀ (s : RequestApprovalFold.State)
  (a b : RequestApprovalFold.WitnessOutput),
  RequestApprovalFold.Reachable s →
    @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
        (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s) a →
      @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
          (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s) b →
        @Eq.{1} RequestApprovalFold.Key
            (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token a))
            (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token b)) →
          @Eq.{1} RequestApprovalFold.WitnessOutput a b
```

### RequestApprovalFold.witnessed_write_obligation

```lean
RequestApprovalFold.witnessed_write_obligation : ∀ (tx : RequestApprovalFold.FoldTx) (n : Nat)
  (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection) (w : RequestApprovalFold.WitnessData),
  RequestApprovalFold.foldAccepted tx →
    @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
        (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
          (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
            @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
          (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
        (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)) →
      @Eq.{1} (Option.{0} RequestApprovalFold.WitnessData)
          (RequestApprovalFold.witnessAt (RequestApprovalFold.CageState.tree (RequestApprovalFold.atTurn tx n))
            (RequestApprovalFold.Write.key
              (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))))
          (@Option.some.{0} RequestApprovalFold.WitnessData w) →
        RequestApprovalFold.itemChanges (RequestApprovalFold.atTurn tx n) (RequestApprovalFold.FoldItem.write o e)
            (RequestApprovalFold.Write.key
              (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))) →
          @Exists.{1} RequestApprovalFold.WitnessEvent fun (event : RequestApprovalFold.WitnessEvent) =>
            And
              (@Membership.mem.{0, 0} RequestApprovalFold.WitnessEvent (List.{0} RequestApprovalFold.WitnessEvent)
                (@List.instMembership.{0} RequestApprovalFold.WitnessEvent)
                (RequestApprovalFold.FoldTx.witnessEvents tx) event)
              (And
                (@Eq.{1} RequestApprovalFold.Key (RequestApprovalFold.WitnessEvent.key event)
                  (RequestApprovalFold.Write.key
                    (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))))
                (And
                  (@Eq.{1} (Option.{0} RequestApprovalFold.Entry) (RequestApprovalFold.WitnessEvent.provedEntry event)
                    (@Option.some.{0} RequestApprovalFold.Entry (RequestApprovalFold.Entry.witnessed w)))
                  (And
                    (@Eq.{1} (Option.{0} RequestApprovalFold.WitnessOutput)
                      (RequestApprovalFold.WitnessEvent.consumed event)
                      (@Option.some.{0} RequestApprovalFold.WitnessOutput
                        (RequestApprovalFold.witnessOutput
                          (RequestApprovalFold.CageState.id (RequestApprovalFold.FoldTx.cageIn tx))
                          (RequestApprovalFold.Write.key
                            (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o)))
                          w)))
                    (And
                      (@Membership.mem.{0, 0} RequestApprovalFold.Payment (List.{0} RequestApprovalFold.Payment)
                        (@List.instMembership.{0} RequestApprovalFold.Payment) (RequestApprovalFold.FoldTx.payments tx)
                        (RequestApprovalFold.Payment.mk (RequestApprovalFold.WitnessData.refund w) ""
                          (RequestApprovalFold.WitnessData.deposit w)))
                      (@Eq.{1} (Option.{0} RequestApprovalFold.Entry)
                        (RequestApprovalFold.CageState.tree
                          (RequestApprovalFold.itemResult (RequestApprovalFold.atTurn tx n)
                            (RequestApprovalFold.FoldItem.write o e))
                          (RequestApprovalFold.Write.key
                            (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))))
                        (RequestApprovalFold.writeEntry
                          (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))
                          (RequestApprovalFold.Request.witnessing (RequestApprovalFold.RequestOutput.request o))
                          (RequestApprovalFold.RequestOutput.ref o)))))))
```

### RequestApprovalFold.fold_witness_boundary_exact

```lean
RequestApprovalFold.fold_witness_boundary_exact : ∀ (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.foldAccepted tx →
    And
      (@Eq.{1} (List.{0} RequestApprovalFold.WitnessEvent) (RequestApprovalFold.FoldTx.witnessEvents tx)
        (RequestApprovalFold.foldWitnessEvents (RequestApprovalFold.FoldTx.cageIn tx)
          (RequestApprovalFold.FoldTx.items tx)))
      (And
        (@Eq.{1} (List.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.FoldTx.witnessInputs tx)
          (RequestApprovalFold.externalWitnessInputs (RequestApprovalFold.FoldTx.witnessEvents tx)))
        (And
          (@Eq.{1} (List.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.FoldTx.witnessOutputs tx)
            (RequestApprovalFold.externalWitnessOutputs (RequestApprovalFold.FoldTx.witnessEvents tx)))
          (And
            (@Eq.{1} (List.{0} RequestApprovalFold.WitnessToken) (RequestApprovalFold.FoldTx.witnessBurned tx)
              (@List.map.{0, 0} RequestApprovalFold.WitnessOutput RequestApprovalFold.WitnessToken
                RequestApprovalFold.WitnessOutput.token (RequestApprovalFold.FoldTx.witnessInputs tx)))
            (@Eq.{1} (List.{0} RequestApprovalFold.WitnessToken) (RequestApprovalFold.FoldTx.witnessMinted tx)
              (@List.map.{0, 0} RequestApprovalFold.WitnessOutput RequestApprovalFold.WitnessToken
                RequestApprovalFold.WitnessOutput.token (RequestApprovalFold.FoldTx.witnessOutputs tx))))))
```

### RequestApprovalFold.witness_spent_only_at_own_key

```lean
RequestApprovalFold.witness_spent_only_at_own_key : ∀ (s s' : RequestApprovalFold.State)
  (a : RequestApprovalFold.Action) (out : RequestApprovalFold.WitnessOutput),
  RequestApprovalFold.Reachable s →
    RequestApprovalFold.Step s a s' →
      @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
          (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s) out →
        Not
            (@Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
              (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s')
              out) →
          @Exists.{1} RequestApprovalFold.FoldTx fun (tx : RequestApprovalFold.FoldTx) =>
            @Exists.{1} Nat fun (n : Nat) =>
              @Exists.{1} RequestApprovalFold.RequestOutput fun (o : RequestApprovalFold.RequestOutput) =>
                @Exists.{1} RequestApprovalFold.Selection fun (e : RequestApprovalFold.Selection) =>
                  And (@Eq.{1} RequestApprovalFold.Action a (RequestApprovalFold.Action.fold tx))
                    (And
                      (@Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput
                        (List.{0} RequestApprovalFold.WitnessOutput)
                        (@List.instMembership.{0} RequestApprovalFold.WitnessOutput)
                        (RequestApprovalFold.FoldTx.witnessInputs tx) out)
                      (And
                        (@Membership.mem.{0, 0} RequestApprovalFold.WitnessToken
                          (List.{0} RequestApprovalFold.WitnessToken)
                          (@List.instMembership.{0} RequestApprovalFold.WitnessToken)
                          (RequestApprovalFold.FoldTx.witnessBurned tx) (RequestApprovalFold.WitnessOutput.token out))
                        (And
                          (@Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
                            (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat
                              RequestApprovalFold.FoldItem
                              (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
                                @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
                              (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem)
                              (RequestApprovalFold.FoldTx.items tx) n)
                            (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)))
                          (And
                            (@Eq.{1} RequestApprovalFold.Key
                              (RequestApprovalFold.Write.key
                                (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o)))
                              (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token out)))
                            (And
                              (RequestApprovalFold.itemChanges (RequestApprovalFold.atTurn tx n)
                                (RequestApprovalFold.FoldItem.write o e)
                                (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token out)))
                              (@Membership.mem.{0, 0} RequestApprovalFold.Payment (List.{0} RequestApprovalFold.Payment)
                                (@List.instMembership.{0} RequestApprovalFold.Payment)
                                (RequestApprovalFold.FoldTx.payments tx)
                                (RequestApprovalFold.Payment.mk
                                  (RequestApprovalFold.WitnessData.refund
                                    (RequestApprovalFold.WitnessToken.data
                                      (RequestApprovalFold.WitnessOutput.token out)))
                                  ""
                                  (RequestApprovalFold.WitnessData.deposit
                                    (RequestApprovalFold.WitnessToken.data
                                      (RequestApprovalFold.WitnessOutput.token out))))))))))
```

### RequestApprovalFold.untouched_witness_survives

```lean
RequestApprovalFold.untouched_witness_survives : ∀ (s s' : RequestApprovalFold.State) (tx : RequestApprovalFold.FoldTx)
  (out : RequestApprovalFold.WitnessOutput),
  RequestApprovalFold.Reachable s →
    RequestApprovalFold.Step s (RequestApprovalFold.Action.fold tx) s' →
      @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
          (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s) out →
        (∀ (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
            @Membership.mem.{0, 0} RequestApprovalFold.FoldItem (List.{0} RequestApprovalFold.FoldItem)
                (@List.instMembership.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx)
                (RequestApprovalFold.FoldItem.write o e) →
              @Ne.{1} RequestApprovalFold.Key
                (RequestApprovalFold.Write.key
                  (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o)))
                (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token out))) →
          And
            (@Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
              (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s') out)
            (And
              (Not
                (@Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
                  (@List.instMembership.{0} RequestApprovalFold.WitnessOutput)
                  (RequestApprovalFold.FoldTx.witnessInputs tx) out))
              (And
                (Not
                  (@Membership.mem.{0, 0} RequestApprovalFold.WitnessToken (List.{0} RequestApprovalFold.WitnessToken)
                    (@List.instMembership.{0} RequestApprovalFold.WitnessToken)
                    (RequestApprovalFold.FoldTx.witnessBurned tx) (RequestApprovalFold.WitnessOutput.token out)))
                (@Eq.{1} (Option.{0} RequestApprovalFold.Val)
                  (RequestApprovalFold.CageState.trie (RequestApprovalFold.State.cage s')
                    (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token out)))
                  (RequestApprovalFold.CageState.trie (RequestApprovalFold.State.cage s)
                    (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token out))))))
```

### RequestApprovalFold.extraction_item_inversion

```lean
RequestApprovalFold.extraction_item_inversion : ∀ (c : RequestApprovalFold.CageState)
  (iv : RequestApprovalFold.Interval) (o : RequestApprovalFold.Extraction),
  Iff (RequestApprovalFold.extractionAllowed c iv o)
    (And
      (@Eq.{1} RequestApprovalFold.CageId (RequestApprovalFold.Extraction.cage o) (RequestApprovalFold.CageState.id c))
      (And
        (@LE.le.{0} Nat instLENat (RequestApprovalFold.CageState.minimum c)
          (RequestApprovalFold.WitnessSpec.deposit (RequestApprovalFold.Extraction.witness o)))
        (And
          (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.Extraction.tokens o)
            (@List.cons.{0} RequestApprovalFold.TokenName
              (RequestApprovalFold.requestName (RequestApprovalFold.CageState.id c))
              (@List.nil.{0} RequestApprovalFold.TokenName)))
          (And
            (@Eq.{1} RequestApprovalFold.RequestPolicy (RequestApprovalFold.Extraction.policy o)
              RequestApprovalFold.RequestPolicy.release)
            (And
              (@LE.le.{0} Nat instLENat (RequestApprovalFold.CageState.minimum c)
                (RequestApprovalFold.Extraction.value o))
              (And (RequestApprovalFold.Interval.valid iv)
                (And
                  (@LT.lt.{0} RequestApprovalFold.Time instLTNat (RequestApprovalFold.Interval.upper iv)
                    (RequestApprovalFold.Extraction.deadline o))
                  (And
                    (@Eq.{1} (Option.{0} RequestApprovalFold.WitnessData)
                      (RequestApprovalFold.witnessAt (RequestApprovalFold.CageState.tree c)
                        (RequestApprovalFold.Extraction.key o))
                      (@Option.none.{0} RequestApprovalFold.WitnessData))
                    (@Eq.{1} (Option.{0} RequestApprovalFold.Val)
                      (RequestApprovalFold.CageState.trie c (RequestApprovalFold.Extraction.key o))
                      (RequestApprovalFold.Extraction.wanted o))))))))))
```

### RequestApprovalFold.extraction_attests_requested

```lean
RequestApprovalFold.extraction_attests_requested : ∀ (tx : RequestApprovalFold.FoldTx) (n : Nat)
  (o : RequestApprovalFold.Extraction),
  RequestApprovalFold.foldAccepted tx →
    @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
        (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
          (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
            @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
          (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
        (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.extract o)) →
      And
        (@Eq.{1} (Option.{0} RequestApprovalFold.Val)
          (RequestApprovalFold.CageState.trie (RequestApprovalFold.atTurn tx n) (RequestApprovalFold.Extraction.key o))
          (RequestApprovalFold.Extraction.wanted o))
        (And
          (@Eq.{1} (Option.{0} RequestApprovalFold.WitnessData)
            (RequestApprovalFold.witnessAt (RequestApprovalFold.CageState.tree (RequestApprovalFold.atTurn tx n))
              (RequestApprovalFold.Extraction.key o))
            (@Option.none.{0} RequestApprovalFold.WitnessData))
          (And
            (@Eq.{1} (Option.{0} RequestApprovalFold.WitnessData)
              (RequestApprovalFold.witnessAt
                (RequestApprovalFold.CageState.tree
                  (RequestApprovalFold.itemResult (RequestApprovalFold.atTurn tx n)
                    (RequestApprovalFold.FoldItem.extract o)))
                (RequestApprovalFold.Extraction.key o))
              (@Option.some.{0} RequestApprovalFold.WitnessData
                (RequestApprovalFold.WitnessData.mk (RequestApprovalFold.Extraction.wanted o)
                  (RequestApprovalFold.WitnessSpec.refund (RequestApprovalFold.Extraction.witness o))
                  (RequestApprovalFold.WitnessSpec.deposit (RequestApprovalFold.Extraction.witness o))
                  (RequestApprovalFold.Extraction.ref o))))
            (@Eq.{1} RequestApprovalFold.Trie
              (RequestApprovalFold.CageState.trie
                (RequestApprovalFold.itemResult (RequestApprovalFold.atTurn tx n)
                  (RequestApprovalFold.FoldItem.extract o)))
              (RequestApprovalFold.CageState.trie (RequestApprovalFold.atTurn tx n)))))
```

### RequestApprovalFold.extraction_normal_request_money

```lean
RequestApprovalFold.extraction_normal_request_money : ∀ (c : RequestApprovalFold.CageState)
  (o : RequestApprovalFold.Extraction) (folder : RequestApprovalFold.Signer),
  And
    (@Eq.{1} (List.{0} OracleIdentity.Payment)
      (RequestApprovalFold.itemCredits c (RequestApprovalFold.FoldItem.extract o))
      (@List.nil.{0} OracleIdentity.Payment))
    (And
      (@Eq.{1} (List.{0} RequestApprovalFold.Payment)
        (RequestApprovalFold.itemPayments c folder (RequestApprovalFold.FoldItem.extract o))
        (@List.cons.{0} RequestApprovalFold.Payment
          (RequestApprovalFold.Payment.mk folder "" (RequestApprovalFold.Extraction.value o))
          (@List.nil.{0} RequestApprovalFold.Payment)))
      (And
        (@Eq.{1} Nat (RequestApprovalFold.Extraction.escrow o)
          (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat) (RequestApprovalFold.Extraction.value o)
            (RequestApprovalFold.WitnessSpec.deposit (RequestApprovalFold.Extraction.witness o))))
        (And
          (@Eq.{1} (RequestApprovalFold.Signer → Nat)
            (RequestApprovalFold.CageState.balances
              (RequestApprovalFold.itemResult c (RequestApprovalFold.FoldItem.extract o)))
            (RequestApprovalFold.CageState.balances c))
          (@Eq.{1} Nat
            (RequestApprovalFold.CageState.value
              (RequestApprovalFold.itemResult c (RequestApprovalFold.FoldItem.extract o)))
            (RequestApprovalFold.CageState.value c)))))
```

### RequestApprovalFold.extraction_permissionless_creation

```lean
RequestApprovalFold.extraction_permissionless_creation : ∀ (s : RequestApprovalFold.State)
  (o : RequestApprovalFold.Extraction) (sigs : List.{0} RequestApprovalFold.Signer),
  RequestApprovalFold.extractionWellFormed (RequestApprovalFold.State.cage s) o →
    Not
        (@Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
          (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedOutputs s)
          (RequestApprovalFold.Extraction.ref o)) →
      have tx : RequestApprovalFold.ExtractionCreateTx :=
        RequestApprovalFold.ExtractionCreateTx.mk (RequestApprovalFold.State.cage s) o
          (RequestApprovalFold.Extraction.tokens o) sigs;
      RequestApprovalFold.Step s (RequestApprovalFold.Action.extractionCreate tx)
        (RequestApprovalFold.afterExtractionCreate s tx)
```

### RequestApprovalFold.extraction_permissionless_fold

```lean
RequestApprovalFold.extraction_permissionless_fold : ∀ (s : RequestApprovalFold.State)
  (o : RequestApprovalFold.Extraction) (iv : RequestApprovalFold.Interval) (who : RequestApprovalFold.Signer),
  RequestApprovalFold.Reachable s →
    @Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
        (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.State.extractions s) o →
      RequestApprovalFold.extractionAllowed (RequestApprovalFold.State.cage s) iv o →
        have tx : RequestApprovalFold.FoldTx :=
          RequestApprovalFold.singletonFold s iv (@List.nil.{0} RequestApprovalFold.Signer)
            (RequestApprovalFold.FoldItem.extract o) who;
        RequestApprovalFold.Step s (RequestApprovalFold.Action.fold tx) (RequestApprovalFold.afterFold s tx)
```

### RequestApprovalFold.extraction_witnessed_refused

```lean
RequestApprovalFold.extraction_witnessed_refused : ∀ (c : RequestApprovalFold.CageState)
  (o : RequestApprovalFold.Extraction) (w : RequestApprovalFold.WitnessData) (iv : RequestApprovalFold.Interval),
  @Eq.{1} (Option.{0} RequestApprovalFold.WitnessData)
      (RequestApprovalFold.witnessAt (RequestApprovalFold.CageState.tree c) (RequestApprovalFold.Extraction.key o))
      (@Option.some.{0} RequestApprovalFold.WitnessData w) →
    Not (RequestApprovalFold.extractionAllowed c iv o)
```

### RequestApprovalFold.extraction_stale_refused

```lean
RequestApprovalFold.extraction_stale_refused : ∀ (c : RequestApprovalFold.CageState)
  (o : RequestApprovalFold.Extraction) (iv : RequestApprovalFold.Interval),
  @Ne.{1} (Option.{0} RequestApprovalFold.Val)
      (RequestApprovalFold.CageState.trie c (RequestApprovalFold.Extraction.key o))
      (RequestApprovalFold.Extraction.wanted o) →
    Not (RequestApprovalFold.extractionAllowed c iv o)
```

### RequestApprovalFold.witnessing_set_replaces

```lean
RequestApprovalFold.witnessing_set_replaces : ∀ (tx : RequestApprovalFold.FoldTx) (n : Nat)
  (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection) (k : RequestApprovalFold.Key)
  (v : RequestApprovalFold.Val) (spec : RequestApprovalFold.WitnessSpec) (old : RequestApprovalFold.WitnessData),
  RequestApprovalFold.foldAccepted tx →
    @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
        (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
          (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
            @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
          (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
        (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)) →
      @Eq.{1} RequestApprovalFold.Write
          (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))
          (RequestApprovalFold.Write.set k v) →
        @Eq.{1} (Option.{0} RequestApprovalFold.WitnessSpec)
            (RequestApprovalFold.Request.witnessing (RequestApprovalFold.RequestOutput.request o))
            (@Option.some.{0} RequestApprovalFold.WitnessSpec spec) →
          @Eq.{1} (Option.{0} RequestApprovalFold.WitnessData)
              (RequestApprovalFold.witnessAt (RequestApprovalFold.CageState.tree (RequestApprovalFold.atTurn tx n)) k)
              (@Option.some.{0} RequestApprovalFold.WitnessData old) →
            And
              (@Eq.{1} (Option.{0} RequestApprovalFold.WitnessData)
                (RequestApprovalFold.witnessAt
                  (RequestApprovalFold.CageState.tree
                    (RequestApprovalFold.itemResult (RequestApprovalFold.atTurn tx n)
                      (RequestApprovalFold.FoldItem.write o e)))
                  k)
                (@Option.some.{0} RequestApprovalFold.WitnessData
                  (RequestApprovalFold.WitnessData.mk (@Option.some.{0} RequestApprovalFold.Val v)
                    (RequestApprovalFold.WitnessSpec.refund spec) (RequestApprovalFold.WitnessSpec.deposit spec)
                    (RequestApprovalFold.RequestOutput.ref o))))
              (And
                (RequestApprovalFold.itemChanges (RequestApprovalFold.atTurn tx n)
                  (RequestApprovalFold.FoldItem.write o e) k)
                (@Eq.{1} (List.{0} RequestApprovalFold.Payment)
                  (RequestApprovalFold.itemWitnessRefunds (RequestApprovalFold.atTurn tx n)
                    (RequestApprovalFold.FoldItem.write o e))
                  (@List.cons.{0} RequestApprovalFold.Payment
                    (RequestApprovalFold.Payment.mk (RequestApprovalFold.WitnessData.refund old) ""
                      (RequestApprovalFold.WitnessData.deposit old))
                    (@List.nil.{0} RequestApprovalFold.Payment))))
```

### RequestApprovalFold.plain_write_clears_witness

```lean
RequestApprovalFold.plain_write_clears_witness : ∀ (c : RequestApprovalFold.CageState)
  (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
  @Eq.{1} (Option.{0} RequestApprovalFold.WitnessSpec)
      (RequestApprovalFold.Request.witnessing (RequestApprovalFold.RequestOutput.request o))
      (@Option.none.{0} RequestApprovalFold.WitnessSpec) →
    RequestApprovalFold.itemChanges c (RequestApprovalFold.FoldItem.write o e)
        (RequestApprovalFold.Write.key
          (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))) →
      And
        (@Eq.{1} (Option.{0} RequestApprovalFold.WitnessData)
          (RequestApprovalFold.witnessAt
            (RequestApprovalFold.CageState.tree
              (RequestApprovalFold.itemResult c (RequestApprovalFold.FoldItem.write o e)))
            (RequestApprovalFold.Write.key
              (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))))
          (@Option.none.{0} RequestApprovalFold.WitnessData))
        (@Eq.{1} RequestApprovalFold.Trie
          (RequestApprovalFold.CageState.trie
            (RequestApprovalFold.itemResult c (RequestApprovalFold.FoldItem.write o e)))
          (RequestApprovalFold.Write.apply (RequestApprovalFold.CageState.trie c)
            (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))))
```

### RequestApprovalFold.fold_deposits_conserved

```lean
RequestApprovalFold.fold_deposits_conserved : ∀ (s s' : RequestApprovalFold.State) (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.Reachable s →
    RequestApprovalFold.Step s (RequestApprovalFold.Action.fold tx) s' →
      @Eq.{1} Nat
        (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
          (RequestApprovalFold.requestDepositInputs (RequestApprovalFold.FoldTx.items tx))
          (RequestApprovalFold.witnessValue (RequestApprovalFold.FoldTx.witnessInputs tx)))
        (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
          (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
            (RequestApprovalFold.witnessValue (RequestApprovalFold.FoldTx.witnessOutputs tx))
            (RequestApprovalFold.witnessRefundTotal (RequestApprovalFold.State.cage s)
              (RequestApprovalFold.FoldTx.items tx)))
          (RequestApprovalFold.unusedDepositRefunds (RequestApprovalFold.FoldTx.items tx)))
```

### RequestApprovalFold.live_outputs_hold_deposits

```lean
RequestApprovalFold.live_outputs_hold_deposits : ∀ (s : RequestApprovalFold.State)
  (keys : List.{0} RequestApprovalFold.Key),
  RequestApprovalFold.Reachable s →
    @List.Nodup.{0} RequestApprovalFold.Key keys →
      (∀ (k : RequestApprovalFold.Key),
          Iff
            (@Membership.mem.{0, 0} RequestApprovalFold.Key (List.{0} RequestApprovalFold.Key)
              (@List.instMembership.{0} RequestApprovalFold.Key) keys k)
            (@Exists.{1} RequestApprovalFold.WitnessData fun (w : RequestApprovalFold.WitnessData) =>
              @Eq.{1} (Option.{0} RequestApprovalFold.WitnessData)
                (RequestApprovalFold.witnessAt (RequestApprovalFold.CageState.tree (RequestApprovalFold.State.cage s))
                  k)
                (@Option.some.{0} RequestApprovalFold.WitnessData w))) →
        @Eq.{1} Nat (RequestApprovalFold.witnessValue (RequestApprovalFold.State.witnesses s))
          (RequestApprovalFold.entryDeposits (RequestApprovalFold.CageState.tree (RequestApprovalFold.State.cage s))
            keys)
```

### RequestApprovalFold.witness_output_custody

```lean
RequestApprovalFold.witness_output_custody : ∀ (s : RequestApprovalFold.State)
  (out : RequestApprovalFold.WitnessOutput),
  RequestApprovalFold.Reachable s →
    @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
        (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s) out →
      And (@Eq.{1} String (RequestApprovalFold.WitnessOutput.address out) RequestApprovalFold.registryAddress)
        (And
          (@Eq.{1} Nat (RequestApprovalFold.WitnessOutput.value out)
            (RequestApprovalFold.WitnessData.deposit
              (RequestApprovalFold.WitnessToken.data (RequestApprovalFold.WitnessOutput.token out))))
          (@LE.le.{0} Nat instLENat (RequestApprovalFold.CageState.minimum (RequestApprovalFold.State.cage s))
            (RequestApprovalFold.WitnessOutput.value out)))
```

### RequestApprovalFold.witness_origin_on_trace

```lean
RequestApprovalFold.witness_origin_on_trace : ∀ (c : RequestApprovalFold.CageState)
  (existing : List.{0} RequestApprovalFold.CageId) (s : RequestApprovalFold.State)
  (events :
    List.{0} (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
  (out : RequestApprovalFold.WitnessOutput),
  RequestApprovalFold.registryCreated c existing →
    RequestApprovalFold.Trace (RequestApprovalFold.initial c) events s →
      @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
          (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s) out →
        @Exists.{1} RequestApprovalFold.State fun (before : RequestApprovalFold.State) =>
          @Exists.{1} RequestApprovalFold.State fun (after : RequestApprovalFold.State) =>
            @Exists.{1} RequestApprovalFold.FoldTx fun (tx : RequestApprovalFold.FoldTx) =>
              And
                (@Membership.mem.{0, 0}
                  (Prod.{0, 0} RequestApprovalFold.State
                    (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State))
                  (List.{0}
                    (Prod.{0, 0} RequestApprovalFold.State
                      (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
                  (@List.instMembership.{0}
                    (Prod.{0, 0} RequestApprovalFold.State
                      (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
                  events
                  (@Prod.mk.{0, 0} RequestApprovalFold.State
                    (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State) before
                    (@Prod.mk.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State
                      (RequestApprovalFold.Action.fold tx) after)))
                (And (RequestApprovalFold.Step before (RequestApprovalFold.Action.fold tx) after)
                  (And
                    (@Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput
                      (List.{0} RequestApprovalFold.WitnessOutput)
                      (@List.instMembership.{0} RequestApprovalFold.WitnessOutput)
                      (RequestApprovalFold.FoldTx.witnessOutputs tx) out)
                    (@Membership.mem.{0, 0} RequestApprovalFold.WitnessToken (List.{0} RequestApprovalFold.WitnessToken)
                      (@List.instMembership.{0} RequestApprovalFold.WitnessToken)
                      (RequestApprovalFold.FoldTx.witnessMinted tx) (RequestApprovalFold.WitnessOutput.token out))))
```

### RequestApprovalFold.extraction_creation_inversion

```lean
RequestApprovalFold.extraction_creation_inversion : ∀ (s s' : RequestApprovalFold.State)
  (tx : RequestApprovalFold.ExtractionCreateTx),
  Iff (RequestApprovalFold.Step s (RequestApprovalFold.Action.extractionCreate tx) s')
    (And
      (@Eq.{1} RequestApprovalFold.CageState (RequestApprovalFold.ExtractionCreateTx.cageRef tx)
        (RequestApprovalFold.State.cage s))
      (And
        (@Eq.{1} RequestApprovalFold.CageId
          (RequestApprovalFold.Extraction.cage (RequestApprovalFold.ExtractionCreateTx.output tx))
          (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s)))
        (And
          (@LE.le.{0} Nat instLENat (RequestApprovalFold.CageState.minimum (RequestApprovalFold.State.cage s))
            (RequestApprovalFold.WitnessSpec.deposit
              (RequestApprovalFold.Extraction.witness (RequestApprovalFold.ExtractionCreateTx.output tx))))
          (And
            (@Eq.{1} (List.{0} RequestApprovalFold.TokenName)
              (RequestApprovalFold.Extraction.tokens (RequestApprovalFold.ExtractionCreateTx.output tx))
              (@List.cons.{0} RequestApprovalFold.TokenName
                (RequestApprovalFold.requestName (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s)))
                (@List.nil.{0} RequestApprovalFold.TokenName)))
            (And
              (@Eq.{1} RequestApprovalFold.RequestPolicy
                (RequestApprovalFold.Extraction.policy (RequestApprovalFold.ExtractionCreateTx.output tx))
                RequestApprovalFold.RequestPolicy.release)
              (And
                (@LE.le.{0} Nat instLENat (RequestApprovalFold.CageState.minimum (RequestApprovalFold.State.cage s))
                  (RequestApprovalFold.Extraction.value (RequestApprovalFold.ExtractionCreateTx.output tx)))
                (And
                  (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.ExtractionCreateTx.minted tx)
                    (RequestApprovalFold.Extraction.tokens (RequestApprovalFold.ExtractionCreateTx.output tx)))
                  (And
                    (Not
                      (@Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
                        (@List.instMembership.{0} RequestApprovalFold.OutputRef)
                        (RequestApprovalFold.State.usedOutputs s)
                        (RequestApprovalFold.Extraction.ref (RequestApprovalFold.ExtractionCreateTx.output tx))))
                    (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterExtractionCreate s tx))))))))))
```

### RequestApprovalFold.extraction_account_inversion

```lean
RequestApprovalFold.extraction_account_inversion : ∀ (c : RequestApprovalFold.CageState)
  (iv : RequestApprovalFold.Interval) (o : RequestApprovalFold.Extraction) (who : RequestApprovalFold.Signer),
  Iff (RequestApprovalFold.extractionAccountAllowed c iv o)
    (And
      (@Eq.{1} RequestApprovalFold.CageId (RequestApprovalFold.Extraction.cage o) (RequestApprovalFold.CageState.id c))
      (And
        (@LE.le.{0} Nat instLENat (RequestApprovalFold.CageState.minimum c)
          (RequestApprovalFold.WitnessSpec.deposit (RequestApprovalFold.Extraction.witness o)))
        (And
          (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.Extraction.tokens o)
            (@List.cons.{0} RequestApprovalFold.TokenName
              (RequestApprovalFold.requestName (RequestApprovalFold.CageState.id c))
              (@List.nil.{0} RequestApprovalFold.TokenName)))
          (And
            (@Eq.{1} RequestApprovalFold.RequestPolicy (RequestApprovalFold.Extraction.policy o)
              RequestApprovalFold.RequestPolicy.release)
            (And
              (@LE.le.{0} Nat instLENat (RequestApprovalFold.CageState.minimum c)
                (RequestApprovalFold.Extraction.value o))
              (And (RequestApprovalFold.Interval.valid iv)
                (And
                  (@LE.le.{0} RequestApprovalFold.Time instLENat (RequestApprovalFold.Extraction.deadline o)
                    (RequestApprovalFold.Interval.lower iv))
                  (And
                    (@LE.le.{0} RequestApprovalFold.Time instLENat (RequestApprovalFold.Interval.upper iv)
                      (@HAdd.hAdd.{0, 0, 0} RequestApprovalFold.Time Nat RequestApprovalFold.Time
                        (@instHAdd.{0} RequestApprovalFold.Time instAddNat) (RequestApprovalFold.Extraction.deadline o)
                        (RequestApprovalFold.Extraction.window o)))
                    (And
                      (@Eq.{1} RequestApprovalFold.CageState
                        (RequestApprovalFold.itemResult c (RequestApprovalFold.FoldItem.extractAccount o)) c)
                      (@Eq.{1} (List.{0} RequestApprovalFold.Payment)
                        (RequestApprovalFold.itemPayments c who (RequestApprovalFold.FoldItem.extractAccount o))
                        (@List.cons.{0} RequestApprovalFold.Payment
                          (RequestApprovalFold.Payment.mk (RequestApprovalFold.Extraction.owner o) ""
                            (RequestApprovalFold.Extraction.value o))
                          (@List.cons.{0} RequestApprovalFold.Payment
                            (RequestApprovalFold.Payment.mk (RequestApprovalFold.Extraction.owner o) ""
                              (RequestApprovalFold.WitnessSpec.deposit (RequestApprovalFold.Extraction.witness o)))
                            (@List.nil.{0} RequestApprovalFold.Payment)))))))))))))
```

### RequestApprovalFold.extraction_withdrawal_inversion

```lean
RequestApprovalFold.extraction_withdrawal_inversion : ∀ (s s' : RequestApprovalFold.State)
  (tx : RequestApprovalFold.ExtractionWithdrawTx),
  Iff (RequestApprovalFold.Step s (RequestApprovalFold.Action.extractionWithdraw tx) s')
    (And
      (@Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
        (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.State.extractions s)
        (RequestApprovalFold.ExtractionWithdrawTx.input tx))
      (And (RequestApprovalFold.Interval.valid (RequestApprovalFold.ExtractionWithdrawTx.interval tx))
        (And
          (@LT.lt.{0} RequestApprovalFold.Time instLTNat
            (@HAdd.hAdd.{0, 0, 0} RequestApprovalFold.Time Nat RequestApprovalFold.Time
              (@instHAdd.{0} RequestApprovalFold.Time instAddNat)
              (RequestApprovalFold.Extraction.deadline (RequestApprovalFold.ExtractionWithdrawTx.input tx))
              (RequestApprovalFold.Extraction.window (RequestApprovalFold.ExtractionWithdrawTx.input tx)))
            (RequestApprovalFold.Interval.lower (RequestApprovalFold.ExtractionWithdrawTx.interval tx)))
          (And
            (@Membership.mem.{0, 0} RequestApprovalFold.Signer (List.{0} RequestApprovalFold.Signer)
              (@List.instMembership.{0} RequestApprovalFold.Signer)
              (RequestApprovalFold.ExtractionWithdrawTx.signers tx)
              (RequestApprovalFold.Extraction.owner (RequestApprovalFold.ExtractionWithdrawTx.input tx)))
            (And
              (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.ExtractionWithdrawTx.burned tx)
                (RequestApprovalFold.Extraction.tokens (RequestApprovalFold.ExtractionWithdrawTx.input tx)))
              (And
                (@Eq.{1} RequestApprovalFold.Signer (RequestApprovalFold.ExtractionWithdrawTx.beneficiary tx)
                  (RequestApprovalFold.Extraction.owner (RequestApprovalFold.ExtractionWithdrawTx.input tx)))
                (And
                  (@Eq.{1} Nat (RequestApprovalFold.ExtractionWithdrawTx.paid tx)
                    (RequestApprovalFold.Extraction.escrow (RequestApprovalFold.ExtractionWithdrawTx.input tx)))
                  (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterExtractionWithdraw s tx)))))))))
```

### RequestApprovalFold.extraction_exit_window

```lean
RequestApprovalFold.extraction_exit_window : ∀ (o : RequestApprovalFold.Extraction)
  (spend : RequestApprovalFold.ExtractionSpend) (kind : RequestApprovalFold.ExitKind),
  RequestApprovalFold.extractionSpendAllowed o spend →
    RequestApprovalFold.ExtractionSpend.exitsAs spend o kind →
      RequestApprovalFold.extractionExitAt o (RequestApprovalFold.ExtractionSpend.interval spend) kind
```

### RequestApprovalFold.extraction_exit_exclusive

```lean
RequestApprovalFold.extraction_exit_exclusive : ∀ (o : RequestApprovalFold.Extraction)
  (a b : RequestApprovalFold.ExtractionSpend) (ka kb : RequestApprovalFold.ExitKind),
  RequestApprovalFold.extractionSpendAllowed o a →
    RequestApprovalFold.extractionSpendAllowed o b →
      @Eq.{1} RequestApprovalFold.Interval (RequestApprovalFold.ExtractionSpend.interval a)
          (RequestApprovalFold.ExtractionSpend.interval b) →
        RequestApprovalFold.ExtractionSpend.exitsAs a o ka →
          RequestApprovalFold.ExtractionSpend.exitsAs b o kb → @Eq.{1} RequestApprovalFold.ExitKind ka kb
```

### RequestApprovalFold.extraction_removal_legal

```lean
RequestApprovalFold.extraction_removal_legal : ∀ (s s' : RequestApprovalFold.State) (a : RequestApprovalFold.Action)
  (o : RequestApprovalFold.Extraction),
  RequestApprovalFold.Step s a s' →
    @Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
        (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.State.extractions s) o →
      Not
          (@Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
            (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.State.extractions s') o) →
        Or
          (@Exists.{1} RequestApprovalFold.FoldTx fun (tx : RequestApprovalFold.FoldTx) =>
            And (@Eq.{1} RequestApprovalFold.Action a (RequestApprovalFold.Action.fold tx))
              (And (RequestApprovalFold.foldAccepted tx)
                (And
                  (@Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
                    (@List.instMembership.{0} RequestApprovalFold.Extraction)
                    (RequestApprovalFold.FoldTx.extractions tx) o)
                  (And
                    (∀ (token : RequestApprovalFold.TokenName),
                      @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                          (@List.instMembership.{0} RequestApprovalFold.TokenName)
                          (RequestApprovalFold.Extraction.tokens o) token →
                        @Membership.mem.{0, 0} RequestApprovalFold.TokenName (List.{0} RequestApprovalFold.TokenName)
                          (@List.instMembership.{0} RequestApprovalFold.TokenName)
                          (RequestApprovalFold.FoldTx.burned tx) token)
                    (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterFold s tx))))))
          (@Exists.{1} RequestApprovalFold.ExtractionWithdrawTx fun (tx : RequestApprovalFold.ExtractionWithdrawTx) =>
            And (@Eq.{1} RequestApprovalFold.Action a (RequestApprovalFold.Action.extractionWithdraw tx))
              (And (@Eq.{1} RequestApprovalFold.Extraction (RequestApprovalFold.ExtractionWithdrawTx.input tx) o)
                (And (RequestApprovalFold.extractionWithdrawAllowed tx)
                  (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterExtractionWithdraw s tx)))))
```

### RequestApprovalFold.extraction_discovery_exact

```lean
RequestApprovalFold.extraction_discovery_exact : ∀ (s : RequestApprovalFold.State) (o : RequestApprovalFold.Extraction),
  RequestApprovalFold.Reachable s →
    And
      (Iff
        (@Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
          (@List.instMembership.{0} RequestApprovalFold.Extraction)
          (RequestApprovalFold.discoverExtractions (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s))
            (RequestApprovalFold.State.extractions s))
          o)
        (@Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
          (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.State.extractions s) o))
      (@Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
          (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.State.extractions s) o →
        RequestApprovalFold.extractionWellFormed (RequestApprovalFold.State.cage s) o)
```

### RequestApprovalFold.witnessing_creation_funded

```lean
RequestApprovalFold.witnessing_creation_funded : ∀ (s s' : RequestApprovalFold.State)
  (tx : RequestApprovalFold.CreateTx) (o : RequestApprovalFold.RequestOutput) (spec : RequestApprovalFold.WitnessSpec),
  RequestApprovalFold.Step s (RequestApprovalFold.Action.create tx o) s' →
    @Eq.{1} (Option.{0} RequestApprovalFold.WitnessSpec)
        (RequestApprovalFold.Request.witnessing (RequestApprovalFold.RequestOutput.request o))
        (@Option.some.{0} RequestApprovalFold.WitnessSpec spec) →
      And
        (@LE.le.{0} Nat instLENat (RequestApprovalFold.CageState.minimum (RequestApprovalFold.State.cage s))
          (RequestApprovalFold.WitnessSpec.deposit spec))
        (And
          (@Exists.{1} RequestApprovalFold.Key fun (k : RequestApprovalFold.Key) =>
            @Exists.{1} RequestApprovalFold.Val fun (v : RequestApprovalFold.Val) =>
              @Eq.{1} RequestApprovalFold.Write
                (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))
                (RequestApprovalFold.Write.set k v))
          (@LE.le.{0} Nat instLENat
            (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
              (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
                (RequestApprovalFold.totalFees (RequestApprovalFold.State.cage s)
                  (RequestApprovalFold.RequestOutput.request o))
                (RequestApprovalFold.CageState.minimum (RequestApprovalFold.State.cage s)))
              (RequestApprovalFold.WitnessSpec.deposit spec))
            (RequestApprovalFold.RequestOutput.escrow o)))
```

### RequestApprovalFold.unused_witnessing_deposit_returned

```lean
RequestApprovalFold.unused_witnessing_deposit_returned : ∀ (tx : RequestApprovalFold.FoldTx) (n : Nat)
  (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection) (spec : RequestApprovalFold.WitnessSpec),
  RequestApprovalFold.foldAccepted tx →
    @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
        (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
          (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
            @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
          (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
        (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.account o e)) →
      @Eq.{1} (Option.{0} RequestApprovalFold.WitnessSpec)
          (RequestApprovalFold.Request.witnessing (RequestApprovalFold.RequestOutput.request o))
          (@Option.some.{0} RequestApprovalFold.WitnessSpec spec) →
        @Eq.{1} (List.{0} RequestApprovalFold.Payment)
          (RequestApprovalFold.itemPayments (RequestApprovalFold.atTurn tx n) (RequestApprovalFold.FoldTx.folder tx)
            (RequestApprovalFold.FoldItem.account o e))
          (@List.cons.{0} RequestApprovalFold.Payment
            (RequestApprovalFold.Payment.mk
              (RequestApprovalFold.Request.owner (RequestApprovalFold.RequestOutput.request o)) ""
              (RequestApprovalFold.remainder (RequestApprovalFold.atTurn tx n) o))
            (@List.cons.{0} RequestApprovalFold.Payment
              (RequestApprovalFold.Payment.mk
                (RequestApprovalFold.Request.owner (RequestApprovalFold.RequestOutput.request o)) ""
                (RequestApprovalFold.WitnessSpec.deposit spec))
              (@List.nil.{0} RequestApprovalFold.Payment)))
```

### RequestApprovalFold.witness_token_issuance_bound

```lean
RequestApprovalFold.witness_token_issuance_bound : ∀ (c : RequestApprovalFold.CageId) (k : RequestApprovalFold.Key)
  (fact : Option.{0} RequestApprovalFold.Val) (refund : String) (deposit : Nat) (a b : RequestApprovalFold.OutputRef),
  Iff
    (@Eq.{1} RequestApprovalFold.WitnessToken
      (RequestApprovalFold.WitnessOutput.token
        (RequestApprovalFold.witnessOutput c k (RequestApprovalFold.WitnessData.mk fact refund deposit a)))
      (RequestApprovalFold.WitnessOutput.token
        (RequestApprovalFold.witnessOutput c k (RequestApprovalFold.WitnessData.mk fact refund deposit b))))
    (@Eq.{1} RequestApprovalFold.OutputRef a b)
```

### RequestApprovalFold.transient_witness_nets

```lean
RequestApprovalFold.transient_witness_nets : ∀ (tx : RequestApprovalFold.FoldTx)
  (out : RequestApprovalFold.WitnessOutput),
  RequestApprovalFold.foldAccepted tx →
    @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
        (@List.instMembership.{0} RequestApprovalFold.WitnessOutput)
        (@List.filterMap.{0, 0} RequestApprovalFold.WitnessEvent RequestApprovalFold.WitnessOutput
          RequestApprovalFold.WitnessEvent.produced (RequestApprovalFold.FoldTx.witnessEvents tx))
        out →
      @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
          (@List.instMembership.{0} RequestApprovalFold.WitnessOutput)
          (@List.filterMap.{0, 0} RequestApprovalFold.WitnessEvent RequestApprovalFold.WitnessOutput
            RequestApprovalFold.WitnessEvent.consumed (RequestApprovalFold.FoldTx.witnessEvents tx))
          out →
        And
          (Not
            (@Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
              (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.FoldTx.witnessInputs tx)
              out))
          (And
            (Not
              (@Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
                (@List.instMembership.{0} RequestApprovalFold.WitnessOutput)
                (RequestApprovalFold.FoldTx.witnessOutputs tx) out))
            (@Membership.mem.{0, 0} RequestApprovalFold.Payment (List.{0} RequestApprovalFold.Payment)
              (@List.instMembership.{0} RequestApprovalFold.Payment) (RequestApprovalFold.FoldTx.payments tx)
              (RequestApprovalFold.Payment.mk
                (RequestApprovalFold.WitnessData.refund
                  (RequestApprovalFold.WitnessToken.data (RequestApprovalFold.WitnessOutput.token out)))
                "" (RequestApprovalFold.WitnessOutput.value out))))
```

### RequestApprovalFold.only_fold_changes_witnesses

```lean
RequestApprovalFold.only_fold_changes_witnesses : ∀ (s s' : RequestApprovalFold.State) (a : RequestApprovalFold.Action),
  RequestApprovalFold.Step s a s' →
    @Ne.{1} (List.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s')
        (RequestApprovalFold.State.witnesses s) →
      @Exists.{1} RequestApprovalFold.FoldTx fun (tx : RequestApprovalFold.FoldTx) =>
        And (@Eq.{1} RequestApprovalFold.Action a (RequestApprovalFold.Action.fold tx))
          (And (RequestApprovalFold.foldAccepted tx)
            (@Eq.{1} RequestApprovalFold.State s' (RequestApprovalFold.afterFold s tx)))
```

### RequestApprovalFold.extraction_windows_cover

```lean
RequestApprovalFold.extraction_windows_cover : ∀ (o : RequestApprovalFold.Extraction) (now : RequestApprovalFold.Time),
  Or
    (RequestApprovalFold.extractionExitAt o (RequestApprovalFold.Interval.mk now now)
      RequestApprovalFold.ExitKind.write)
    (Or
      (RequestApprovalFold.extractionExitAt o (RequestApprovalFold.Interval.mk now now)
        RequestApprovalFold.ExitKind.account)
      (RequestApprovalFold.extractionExitAt o (RequestApprovalFold.Interval.mk now now)
        RequestApprovalFold.ExitKind.withdraw))
```

### RequestApprovalFold.extraction_windows_disjoint

```lean
RequestApprovalFold.extraction_windows_disjoint : ∀ (o : RequestApprovalFold.Extraction)
  (iv : RequestApprovalFold.Interval) (a b : RequestApprovalFold.ExitKind),
  RequestApprovalFold.extractionExitAt o iv a →
    RequestApprovalFold.extractionExitAt o iv b → @Eq.{1} RequestApprovalFold.ExitKind a b
```

### RequestApprovalFold.extraction_later_exits_available

```lean
RequestApprovalFold.extraction_later_exits_available : ∀ (s : RequestApprovalFold.State)
  (o : RequestApprovalFold.Extraction) (iv : RequestApprovalFold.Interval) (who : RequestApprovalFold.Signer),
  @Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
      (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.State.extractions s) o →
    RequestApprovalFold.extractionWellFormed (RequestApprovalFold.State.cage s) o →
      RequestApprovalFold.Interval.valid iv →
        And
          (@LE.le.{0} RequestApprovalFold.Time instLENat (RequestApprovalFold.Extraction.deadline o)
              (RequestApprovalFold.Interval.lower iv) →
            @LE.le.{0} RequestApprovalFold.Time instLENat (RequestApprovalFold.Interval.upper iv)
                (@HAdd.hAdd.{0, 0, 0} RequestApprovalFold.Time Nat RequestApprovalFold.Time
                  (@instHAdd.{0} RequestApprovalFold.Time instAddNat) (RequestApprovalFold.Extraction.deadline o)
                  (RequestApprovalFold.Extraction.window o)) →
              have tx : RequestApprovalFold.FoldTx :=
                RequestApprovalFold.singletonFold s iv (@List.nil.{0} RequestApprovalFold.Signer)
                  (RequestApprovalFold.FoldItem.extractAccount o) who;
              RequestApprovalFold.Step s (RequestApprovalFold.Action.fold tx) (RequestApprovalFold.afterFold s tx))
          (@LT.lt.{0} RequestApprovalFold.Time instLTNat
              (@HAdd.hAdd.{0, 0, 0} RequestApprovalFold.Time Nat RequestApprovalFold.Time
                (@instHAdd.{0} RequestApprovalFold.Time instAddNat) (RequestApprovalFold.Extraction.deadline o)
                (RequestApprovalFold.Extraction.window o))
              (RequestApprovalFold.Interval.lower iv) →
            have tx : RequestApprovalFold.ExtractionWithdrawTx :=
              RequestApprovalFold.ExtractionWithdrawTx.mk o iv
                (@List.cons.{0} RequestApprovalFold.Signer (RequestApprovalFold.Extraction.owner o)
                  (@List.nil.{0} RequestApprovalFold.Signer))
                (RequestApprovalFold.Extraction.tokens o) (RequestApprovalFold.Extraction.owner o)
                (RequestApprovalFold.Extraction.escrow o);
            RequestApprovalFold.Step s (RequestApprovalFold.Action.extractionWithdraw tx)
              (RequestApprovalFold.afterExtractionWithdraw s tx))
```

### RequestApprovalFold.write_item_inversion

```lean
RequestApprovalFold.write_item_inversion : ∀ (c : RequestApprovalFold.CageState) (iv : RequestApprovalFold.Interval)
  (refs : List.{0} RequestApprovalFold.TokenName) (sigs : List.{0} RequestApprovalFold.Signer)
  (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
  Iff (RequestApprovalFold.itemAllowed c iv refs sigs (RequestApprovalFold.FoldItem.write o e))
    (And
      (Or
        (@Eq.{1} (Option.{0} RequestApprovalFold.WitnessSpec)
          (RequestApprovalFold.Request.witnessing (RequestApprovalFold.RequestOutput.request o))
          (@Option.none.{0} RequestApprovalFold.WitnessSpec))
        (Or
          (@Eq.{1} (Option.{0} RequestApprovalFold.WitnessData)
            (RequestApprovalFold.witnessAt (RequestApprovalFold.CageState.tree c)
              (RequestApprovalFold.Write.key
                (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))))
            (@Option.none.{0} RequestApprovalFold.WitnessData))
          (@Ne.{1} (Option.{0} RequestApprovalFold.Val)
            (RequestApprovalFold.CageState.trie c
              (RequestApprovalFold.Write.key
                (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))))
            (RequestApprovalFold.Write.value
              (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))))))
      (And
        (@Eq.{1} RequestApprovalFold.CageId
          (RequestApprovalFold.Request.cage (RequestApprovalFold.RequestOutput.request o))
          (RequestApprovalFold.CageState.id c))
        (And
          (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.RequestOutput.tags o)
            (@List.map.{0, 0} RequestApprovalFold.Oracle RequestApprovalFold.TokenName RequestApprovalFold.tagName
              (RequestApprovalFold.CageState.oracles c)))
          (And
            (@LE.le.{0} Nat instLENat
              (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
                (RequestApprovalFold.totalFees c (RequestApprovalFold.RequestOutput.request o))
                (RequestApprovalFold.CageState.minimum c))
              (RequestApprovalFold.RequestOutput.value o))
            (And
              (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.RequestOutput.requestTokens o)
                (@List.cons.{0} RequestApprovalFold.TokenName
                  (RequestApprovalFold.requestName (RequestApprovalFold.CageState.id c))
                  (@List.nil.{0} RequestApprovalFold.TokenName)))
              (And
                (@Eq.{1} RequestApprovalFold.RequestPolicy (RequestApprovalFold.RequestOutput.policy o)
                  (RequestApprovalFold.requestPolicy c))
                (And
                  (RequestApprovalFold.Request.witnessValid (RequestApprovalFold.RequestOutput.request o)
                    (RequestApprovalFold.CageState.minimum c))
                  (And (RequestApprovalFold.Interval.valid iv)
                    (And
                      (@LT.lt.{0} RequestApprovalFold.Time instLTNat (RequestApprovalFold.Interval.upper iv)
                        (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o)))
                      (And (RequestApprovalFold.hasApproval c (RequestApprovalFold.RequestOutput.request o) refs sigs e)
                        (And
                          (∀ (condition : RequestApprovalFold.Condition),
                            @Membership.mem.{0, 0} RequestApprovalFold.Condition
                                (List.{0} RequestApprovalFold.Condition)
                                (@List.instMembership.{0} RequestApprovalFold.Condition)
                                (RequestApprovalFold.Request.conditions (RequestApprovalFold.RequestOutput.request o))
                                condition →
                              RequestApprovalFold.Condition.holds (RequestApprovalFold.CageState.trie c) condition)
                          (∀ (oracle : RequestApprovalFold.Oracle),
                            @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
                                (@List.instMembership.{0} RequestApprovalFold.Oracle)
                                (RequestApprovalFold.CageState.oracles c) oracle →
                              ∀ (condition : RequestApprovalFold.Condition),
                                @Membership.mem.{0, 0} RequestApprovalFold.Condition
                                    (List.{0} RequestApprovalFold.Condition)
                                    (@List.instMembership.{0} RequestApprovalFold.Condition)
                                    (RequestApprovalFold.Evidence.conditions (e oracle)) condition →
                                  RequestApprovalFold.Condition.holds (RequestApprovalFold.CageState.trie c)
                                    condition))))))))))))
```

### RequestApprovalFold.reachable_input_refs_unique

```lean
RequestApprovalFold.reachable_input_refs_unique : ∀ (s : RequestApprovalFold.State),
  RequestApprovalFold.Reachable s →
    And
      (@List.Nodup.{0} RequestApprovalFold.OutputRef
        (@HAppend.hAppend.{0, 0, 0} (List.{0} RequestApprovalFold.OutputRef) (List.{0} RequestApprovalFold.OutputRef)
          (List.{0} RequestApprovalFold.OutputRef)
          (@instHAppendOfAppend.{0} (List.{0} RequestApprovalFold.OutputRef)
            (@List.instAppend.{0} RequestApprovalFold.OutputRef))
          (@HAppend.hAppend.{0, 0, 0} (List.{0} RequestApprovalFold.OutputRef) (List.{0} RequestApprovalFold.OutputRef)
            (List.{0} RequestApprovalFold.OutputRef)
            (@instHAppendOfAppend.{0} (List.{0} RequestApprovalFold.OutputRef)
              (@List.instAppend.{0} RequestApprovalFold.OutputRef))
            (@List.map.{0, 0} RequestApprovalFold.RequestOutput RequestApprovalFold.OutputRef
              RequestApprovalFold.RequestOutput.ref (RequestApprovalFold.State.live s))
            (@List.map.{0, 0} RequestApprovalFold.ClaimOutput RequestApprovalFold.OutputRef
              RequestApprovalFold.ClaimOutput.ref (RequestApprovalFold.State.claims s)))
          (@List.map.{0, 0} RequestApprovalFold.Extraction RequestApprovalFold.OutputRef
            RequestApprovalFold.Extraction.ref (RequestApprovalFold.State.extractions s))))
      (∀ (o : RequestApprovalFold.Extraction),
        @Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
            (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.State.extractions s) o →
          @Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
            (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedOutputs s)
            (RequestApprovalFold.Extraction.ref o))
```

### RequestApprovalFold.touched_old_witness_burned

```lean
RequestApprovalFold.touched_old_witness_burned : ∀ (s s' : RequestApprovalFold.State) (tx : RequestApprovalFold.FoldTx)
  (old : RequestApprovalFold.WitnessOutput) (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection)
  (n : Nat),
  RequestApprovalFold.Reachable s →
    RequestApprovalFold.Step s (RequestApprovalFold.Action.fold tx) s' →
      @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
          (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s) old →
        @Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
            (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
              (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
                @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
              (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx) n)
            (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)) →
          @Eq.{1} RequestApprovalFold.Key
              (RequestApprovalFold.Write.key
                (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o)))
              (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token old)) →
            RequestApprovalFold.itemChanges (RequestApprovalFold.atTurn tx n) (RequestApprovalFold.FoldItem.write o e)
                (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token old)) →
              And
                (@Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
                  (@List.instMembership.{0} RequestApprovalFold.WitnessOutput)
                  (RequestApprovalFold.FoldTx.witnessInputs tx) old)
                (And
                  (@Membership.mem.{0, 0} RequestApprovalFold.WitnessToken (List.{0} RequestApprovalFold.WitnessToken)
                    (@List.instMembership.{0} RequestApprovalFold.WitnessToken)
                    (RequestApprovalFold.FoldTx.witnessBurned tx) (RequestApprovalFold.WitnessOutput.token old))
                  (And
                    (Not
                      (@Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput
                        (List.{0} RequestApprovalFold.WitnessOutput)
                        (@List.instMembership.{0} RequestApprovalFold.WitnessOutput)
                        (RequestApprovalFold.State.witnesses s') old))
                    (@Membership.mem.{0, 0} RequestApprovalFold.Payment (List.{0} RequestApprovalFold.Payment)
                      (@List.instMembership.{0} RequestApprovalFold.Payment) (RequestApprovalFold.FoldTx.payments tx)
                      (RequestApprovalFold.Payment.mk
                        (RequestApprovalFold.WitnessData.refund
                          (RequestApprovalFold.WitnessToken.data (RequestApprovalFold.WitnessOutput.token old)))
                        "" (RequestApprovalFold.WitnessOutput.value old)))))
```

### RequestApprovalFold.fold_witness_inputs_authentic

```lean
RequestApprovalFold.fold_witness_inputs_authentic : ∀ (s s' : RequestApprovalFold.State)
  (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.Step s (RequestApprovalFold.Action.fold tx) s' →
    And
      (∀ (w : RequestApprovalFold.WitnessOutput),
        @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
            (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.FoldTx.witnessInputs tx)
            w →
          @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
            (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s) w)
      (∀ (o : RequestApprovalFold.Extraction),
        @Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
            (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.FoldTx.extractions tx) o →
          @Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
            (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.State.extractions s) o)
```

### RequestApprovalFold.requests_unique_on_trace

```lean
RequestApprovalFold.requests_unique_on_trace : ∀ (c : RequestApprovalFold.CageState)
  (existing : List.{0} RequestApprovalFold.CageId) (s : RequestApprovalFold.State)
  (events :
    List.{0} (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
  (beforeA afterA beforeB afterB : RequestApprovalFold.State) (a b : RequestApprovalFold.CreateTx)
  (oa ob : RequestApprovalFold.RequestOutput),
  RequestApprovalFold.registryCreated c existing →
    RequestApprovalFold.Trace (RequestApprovalFold.initial c) events s →
      @Membership.mem.{0, 0}
          (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State))
          (List.{0}
            (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
          (@List.instMembership.{0}
            (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
          events
          (@Prod.mk.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)
            beforeA
            (@Prod.mk.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State
              (RequestApprovalFold.Action.create a oa) afterA)) →
        @Membership.mem.{0, 0}
            (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State))
            (List.{0}
              (Prod.{0, 0} RequestApprovalFold.State
                (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
            (@List.instMembership.{0}
              (Prod.{0, 0} RequestApprovalFold.State
                (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
            events
            (@Prod.mk.{0, 0} RequestApprovalFold.State
              (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State) beforeB
              (@Prod.mk.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State
                (RequestApprovalFold.Action.create b ob) afterB)) →
          @Ne.{1} (List.{0} RequestApprovalFold.Oracle)
              (RequestApprovalFold.CageState.oracles (RequestApprovalFold.CreateTx.cageRef a))
              (@List.nil.{0} RequestApprovalFold.Oracle) →
            @Ne.{1} (List.{0} RequestApprovalFold.Oracle)
                (RequestApprovalFold.CageState.oracles (RequestApprovalFold.CreateTx.cageRef b))
                (@List.nil.{0} RequestApprovalFold.Oracle) →
              @Ne.{1} RequestApprovalFold.CreateTx a b →
                @Ne.{1} RequestApprovalFold.Request (RequestApprovalFold.RequestOutput.request oa)
                  (RequestApprovalFold.RequestOutput.request ob)
```

### RequestApprovalFold.witness_reference_sound

```lean
RequestApprovalFold.witness_reference_sound : ∀ (s : RequestApprovalFold.State)
  (out : RequestApprovalFold.WitnessOutput) (w : RequestApprovalFold.WitnessData),
  RequestApprovalFold.Reachable s →
    And
      (Iff
        (@Eq.{1} (Option.{0} RequestApprovalFold.WitnessData) (RequestApprovalFold.referenceWitness s out)
          (@Option.some.{0} RequestApprovalFold.WitnessData w))
        (And
          (@Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
            (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s) out)
          (@Eq.{1} RequestApprovalFold.WitnessData w
            (RequestApprovalFold.WitnessToken.data (RequestApprovalFold.WitnessOutput.token out)))))
      (@Eq.{1} (Option.{0} RequestApprovalFold.WitnessData) (RequestApprovalFold.referenceWitness s out)
          (@Option.some.{0} RequestApprovalFold.WitnessData w) →
        @Eq.{1} (Option.{0} RequestApprovalFold.Val)
          (RequestApprovalFold.CageState.trie (RequestApprovalFold.State.cage s)
            (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token out)))
          (RequestApprovalFold.WitnessData.fact w))
```

### RequestApprovalFold.item_burn_iff_value_change

```lean
RequestApprovalFold.item_burn_iff_value_change : ∀ (c : RequestApprovalFold.CageState)
  (iv : RequestApprovalFold.Interval) (refs : List.{0} RequestApprovalFold.TokenName)
  (sigs : List.{0} RequestApprovalFold.Signer) (i : RequestApprovalFold.FoldItem) (k : RequestApprovalFold.Key)
  (w : RequestApprovalFold.WitnessData),
  RequestApprovalFold.itemAllowed c iv refs sigs i →
    @Eq.{1} (Option.{0} RequestApprovalFold.WitnessData)
        (RequestApprovalFold.witnessAt (RequestApprovalFold.CageState.tree c) k)
        (@Option.some.{0} RequestApprovalFold.WitnessData w) →
      And
        (Iff
          (@Exists.{1} RequestApprovalFold.WitnessEvent fun (event : RequestApprovalFold.WitnessEvent) =>
            And
              (@Membership.mem.{0, 0} RequestApprovalFold.WitnessEvent (List.{0} RequestApprovalFold.WitnessEvent)
                (@List.instMembership.{0} RequestApprovalFold.WitnessEvent) (RequestApprovalFold.itemWitnessEvents c i)
                event)
              (And (@Eq.{1} RequestApprovalFold.Key (RequestApprovalFold.WitnessEvent.key event) k)
                (@Eq.{1} (Option.{0} RequestApprovalFold.WitnessOutput)
                  (RequestApprovalFold.WitnessEvent.consumed event)
                  (@Option.some.{0} RequestApprovalFold.WitnessOutput
                    (RequestApprovalFold.witnessOutput (RequestApprovalFold.CageState.id c) k w)))))
          (RequestApprovalFold.itemChanges c i k))
        (RequestApprovalFold.itemChanges c i k →
          @Eq.{1} (List.{0} RequestApprovalFold.Payment) (RequestApprovalFold.itemWitnessRefunds c i)
            (@List.cons.{0} RequestApprovalFold.Payment
              (RequestApprovalFold.Payment.mk (RequestApprovalFold.WitnessData.refund w) ""
                (RequestApprovalFold.WitnessData.deposit w))
              (@List.nil.{0} RequestApprovalFold.Payment)))
```

### RequestApprovalFold.witness_durability

```lean
RequestApprovalFold.witness_durability : ∀ (s s' : RequestApprovalFold.State) (a : RequestApprovalFold.Action)
  (out : RequestApprovalFold.WitnessOutput),
  RequestApprovalFold.Reachable s →
    RequestApprovalFold.Step s a s' →
      @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
          (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s) out →
        RequestApprovalFold.actionPreservesKey a
            (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token out)) →
          And
            (@Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
              (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s') out)
            (And
              (@Eq.{1} (Option.{0} RequestApprovalFold.WitnessData)
                (RequestApprovalFold.witnessAt (RequestApprovalFold.CageState.tree (RequestApprovalFold.State.cage s'))
                  (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token out)))
                (RequestApprovalFold.witnessAt (RequestApprovalFold.CageState.tree (RequestApprovalFold.State.cage s))
                  (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token out))))
              (And
                (@Eq.{1} (Option.{0} RequestApprovalFold.Val)
                  (RequestApprovalFold.CageState.trie (RequestApprovalFold.State.cage s')
                    (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token out)))
                  (RequestApprovalFold.CageState.trie (RequestApprovalFold.State.cage s)
                    (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token out))))
                (∀ (tx : RequestApprovalFold.FoldTx),
                  @Eq.{1} RequestApprovalFold.Action a (RequestApprovalFold.Action.fold tx) →
                    And
                      (Not
                        (@Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput
                          (List.{0} RequestApprovalFold.WitnessOutput)
                          (@List.instMembership.{0} RequestApprovalFold.WitnessOutput)
                          (RequestApprovalFold.FoldTx.witnessInputs tx) out))
                      (Not
                        (@Membership.mem.{0, 0} RequestApprovalFold.WitnessToken
                          (List.{0} RequestApprovalFold.WitnessToken)
                          (@List.instMembership.{0} RequestApprovalFold.WitnessToken)
                          (RequestApprovalFold.FoldTx.witnessBurned tx)
                          (RequestApprovalFold.WitnessOutput.token out))))))
```

### RequestApprovalFold.plain_noop_preserves_witness

```lean
RequestApprovalFold.plain_noop_preserves_witness : ∀ (c : RequestApprovalFold.CageState)
  (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
  @Eq.{1} (Option.{0} RequestApprovalFold.WitnessSpec)
      (RequestApprovalFold.Request.witnessing (RequestApprovalFold.RequestOutput.request o))
      (@Option.none.{0} RequestApprovalFold.WitnessSpec) →
    @Eq.{1} (Option.{0} RequestApprovalFold.Val)
        (RequestApprovalFold.CageState.trie c
          (RequestApprovalFold.Write.key
            (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))))
        (RequestApprovalFold.Write.value
          (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))) →
      And
        (@Eq.{1} RequestApprovalFold.EntryTree
          (RequestApprovalFold.CageState.tree
            (RequestApprovalFold.itemResult c (RequestApprovalFold.FoldItem.write o e)))
          (RequestApprovalFold.CageState.tree c))
        (And
          (@Eq.{1} (List.{0} RequestApprovalFold.WitnessEvent)
            (RequestApprovalFold.itemWitnessEvents c (RequestApprovalFold.FoldItem.write o e))
            (@List.nil.{0} RequestApprovalFold.WitnessEvent))
          (@Eq.{1} (List.{0} RequestApprovalFold.Payment)
            (RequestApprovalFold.itemWitnessRefunds c (RequestApprovalFold.FoldItem.write o e))
            (@List.nil.{0} RequestApprovalFold.Payment)))
```

### RequestApprovalFold.witnessing_noop_refused

```lean
RequestApprovalFold.witnessing_noop_refused : ∀ (c : RequestApprovalFold.CageState)
  (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection) (iv : RequestApprovalFold.Interval)
  (refs : List.{0} RequestApprovalFold.TokenName) (sigs : List.{0} RequestApprovalFold.Signer)
  (w : RequestApprovalFold.WitnessData) (spec : RequestApprovalFold.WitnessSpec),
  @Eq.{1} (Option.{0} RequestApprovalFold.WitnessData)
      (RequestApprovalFold.witnessAt (RequestApprovalFold.CageState.tree c)
        (RequestApprovalFold.Write.key
          (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))))
      (@Option.some.{0} RequestApprovalFold.WitnessData w) →
    @Eq.{1} (Option.{0} RequestApprovalFold.WitnessSpec)
        (RequestApprovalFold.Request.witnessing (RequestApprovalFold.RequestOutput.request o))
        (@Option.some.{0} RequestApprovalFold.WitnessSpec spec) →
      @Eq.{1} (Option.{0} RequestApprovalFold.Val)
          (RequestApprovalFold.CageState.trie c
            (RequestApprovalFold.Write.key
              (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))))
          (RequestApprovalFold.Write.value
            (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))) →
        Not (RequestApprovalFold.stepValid c iv refs sigs e o)
```

### RequestApprovalFold.witness_deposit_lock

```lean
RequestApprovalFold.witness_deposit_lock : ∀ (s s' : RequestApprovalFold.State) (a : RequestApprovalFold.Action)
  (out : RequestApprovalFold.WitnessOutput),
  RequestApprovalFold.Reachable s →
    RequestApprovalFold.Step s a s' →
      @Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
          (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s) out →
        Or
            (Not
              (@Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
                (@List.instMembership.{0} RequestApprovalFold.WitnessOutput) (RequestApprovalFold.State.witnesses s')
                out))
            (@Exists.{1} RequestApprovalFold.FoldTx fun (tx : RequestApprovalFold.FoldTx) =>
              And (@Eq.{1} RequestApprovalFold.Action a (RequestApprovalFold.Action.fold tx))
                (@Membership.mem.{0, 0} RequestApprovalFold.WitnessOutput (List.{0} RequestApprovalFold.WitnessOutput)
                  (@List.instMembership.{0} RequestApprovalFold.WitnessOutput)
                  (RequestApprovalFold.FoldTx.witnessInputs tx) out)) →
          @Exists.{1} RequestApprovalFold.FoldTx fun (tx : RequestApprovalFold.FoldTx) =>
            @Exists.{1} Nat fun (n : Nat) =>
              @Exists.{1} RequestApprovalFold.FoldItem fun (i : RequestApprovalFold.FoldItem) =>
                @Exists.{1} RequestApprovalFold.WitnessEvent fun (event : RequestApprovalFold.WitnessEvent) =>
                  And (@Eq.{1} RequestApprovalFold.Action a (RequestApprovalFold.Action.fold tx))
                    (And
                      (@Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
                        (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat
                          RequestApprovalFold.FoldItem
                          (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
                            @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
                          (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem)
                          (RequestApprovalFold.FoldTx.items tx) n)
                        (@Option.some.{0} RequestApprovalFold.FoldItem i))
                      (And
                        (RequestApprovalFold.itemChanges (RequestApprovalFold.atTurn tx n) i
                          (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token out)))
                        (And
                          (@Membership.mem.{0, 0} RequestApprovalFold.WitnessEvent
                            (List.{0} RequestApprovalFold.WitnessEvent)
                            (@List.instMembership.{0} RequestApprovalFold.WitnessEvent)
                            (RequestApprovalFold.itemWitnessEvents (RequestApprovalFold.atTurn tx n) i) event)
                          (And
                            (@Eq.{1} RequestApprovalFold.Key (RequestApprovalFold.WitnessEvent.key event)
                              (RequestApprovalFold.WitnessToken.key (RequestApprovalFold.WitnessOutput.token out)))
                            (And
                              (@Eq.{1} (Option.{0} RequestApprovalFold.WitnessOutput)
                                (RequestApprovalFold.WitnessEvent.consumed event)
                                (@Option.some.{0} RequestApprovalFold.WitnessOutput out))
                              (And
                                (@Membership.mem.{0, 0} RequestApprovalFold.WitnessToken
                                  (List.{0} RequestApprovalFold.WitnessToken)
                                  (@List.instMembership.{0} RequestApprovalFold.WitnessToken)
                                  (RequestApprovalFold.FoldTx.witnessBurned tx)
                                  (RequestApprovalFold.WitnessOutput.token out))
                                (And
                                  (@Membership.mem.{0, 0} RequestApprovalFold.Payment
                                    (List.{0} RequestApprovalFold.Payment)
                                    (@List.instMembership.{0} RequestApprovalFold.Payment)
                                    (RequestApprovalFold.itemWitnessRefunds (RequestApprovalFold.atTurn tx n) i)
                                    (RequestApprovalFold.Payment.mk
                                      (RequestApprovalFold.WitnessData.refund
                                        (RequestApprovalFold.WitnessToken.data
                                          (RequestApprovalFold.WitnessOutput.token out)))
                                      ""
                                      (RequestApprovalFold.WitnessData.deposit
                                        (RequestApprovalFold.WitnessToken.data
                                          (RequestApprovalFold.WitnessOutput.token out)))))
                                  (@Membership.mem.{0, 0} RequestApprovalFold.Payment
                                    (List.{0} RequestApprovalFold.Payment)
                                    (@List.instMembership.{0} RequestApprovalFold.Payment)
                                    (RequestApprovalFold.FoldTx.payments tx)
                                    (RequestApprovalFold.Payment.mk
                                      (RequestApprovalFold.WitnessData.refund
                                        (RequestApprovalFold.WitnessToken.data
                                          (RequestApprovalFold.WitnessOutput.token out)))
                                      ""
                                      (RequestApprovalFold.WitnessData.deposit
                                        (RequestApprovalFold.WitnessToken.data
                                          (RequestApprovalFold.WitnessOutput.token out))))))))))))
```

### RequestApprovalFold.witnessing_blind_write_availability

```lean
RequestApprovalFold.witnessing_blind_write_availability : ∀ (c : RequestApprovalFold.CageState)
  (iv : RequestApprovalFold.Interval) (refs : List.{0} RequestApprovalFold.TokenName)
  (sigs : List.{0} RequestApprovalFold.Signer) (o : RequestApprovalFold.RequestOutput)
  (e : RequestApprovalFold.Selection) (t : RequestApprovalFold.EntryTree),
  RequestApprovalFold.wellFormed c o →
    RequestApprovalFold.Interval.valid iv →
      @LT.lt.{0} RequestApprovalFold.Time instLTNat (RequestApprovalFold.Interval.upper iv)
          (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o)) →
        RequestApprovalFold.hasApproval c (RequestApprovalFold.RequestOutput.request o) refs sigs e →
          @Eq.{1} (List.{0} RequestApprovalFold.Condition)
              (RequestApprovalFold.Request.conditions (RequestApprovalFold.RequestOutput.request o))
              (@List.nil.{0} RequestApprovalFold.Condition) →
            (∀ (oracle : RequestApprovalFold.Oracle),
                @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
                    (@List.instMembership.{0} RequestApprovalFold.Oracle) (RequestApprovalFold.CageState.oracles c)
                    oracle →
                  @Eq.{1} (List.{0} RequestApprovalFold.Condition) (RequestApprovalFold.Evidence.conditions (e oracle))
                    (@List.nil.{0} RequestApprovalFold.Condition)) →
              RequestApprovalFold.witnessWriteAllowed
                  (RequestApprovalFold.CageState.mk (RequestApprovalFold.CageState.id c)
                    (RequestApprovalFold.CageState.oracles c) (RequestApprovalFold.CageState.protocol c) t
                    (RequestApprovalFold.CageState.rule c) (RequestApprovalFold.CageState.balances c)
                    (RequestApprovalFold.CageState.value c) (RequestApprovalFold.CageState.minimum c))
                  (RequestApprovalFold.RequestOutput.request o) →
                And
                  (RequestApprovalFold.FoldRun iv refs sigs
                    (RequestApprovalFold.CageState.mk (RequestApprovalFold.CageState.id c)
                      (RequestApprovalFold.CageState.oracles c) (RequestApprovalFold.CageState.protocol c) t
                      (RequestApprovalFold.CageState.rule c) (RequestApprovalFold.CageState.balances c)
                      (RequestApprovalFold.CageState.value c) (RequestApprovalFold.CageState.minimum c))
                    (@List.cons.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)
                      (@List.nil.{0} RequestApprovalFold.FoldItem))
                    (RequestApprovalFold.itemResult
                      (RequestApprovalFold.CageState.mk (RequestApprovalFold.CageState.id c)
                        (RequestApprovalFold.CageState.oracles c) (RequestApprovalFold.CageState.protocol c) t
                        (RequestApprovalFold.CageState.rule c) (RequestApprovalFold.CageState.balances c)
                        (RequestApprovalFold.CageState.value c) (RequestApprovalFold.CageState.minimum c))
                      (RequestApprovalFold.FoldItem.write o e)))
                  (@Eq.{1} RequestApprovalFold.Trie
                    (RequestApprovalFold.CageState.trie
                      (RequestApprovalFold.itemResult
                        (RequestApprovalFold.CageState.mk (RequestApprovalFold.CageState.id c)
                          (RequestApprovalFold.CageState.oracles c) (RequestApprovalFold.CageState.protocol c) t
                          (RequestApprovalFold.CageState.rule c) (RequestApprovalFold.CageState.balances c)
                          (RequestApprovalFold.CageState.value c) (RequestApprovalFold.CageState.minimum c))
                        (RequestApprovalFold.FoldItem.write o e)))
                    (RequestApprovalFold.Write.apply (RequestApprovalFold.logicalTree t)
                      (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))))
```

### RequestApprovalFold.extraction_exits_remove_consumed

```lean
RequestApprovalFold.extraction_exits_remove_consumed : ∀ (s s' : RequestApprovalFold.State)
  (tx : RequestApprovalFold.ExtractionWithdrawTx),
  RequestApprovalFold.Reachable s →
    RequestApprovalFold.Step s (RequestApprovalFold.Action.extractionWithdraw tx) s' →
      Not
        (@Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
          (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.State.extractions s')
          (RequestApprovalFold.ExtractionWithdrawTx.input tx))
```

### RequestApprovalFold.extraction_fold_removes_consumed

```lean
RequestApprovalFold.extraction_fold_removes_consumed : ∀ (s : RequestApprovalFold.State)
  (tx : RequestApprovalFold.FoldTx) (o : RequestApprovalFold.Extraction),
  @Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
      (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.FoldTx.extractions tx) o →
    Not
      (@Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
        (@List.instMembership.{0} RequestApprovalFold.Extraction)
        (RequestApprovalFold.State.extractions (RequestApprovalFold.afterFold s tx)) o)
```

### RequestApprovalFold.extraction_never_reappears

```lean
RequestApprovalFold.extraction_never_reappears : ∀ (s s' : RequestApprovalFold.State)
  (o : RequestApprovalFold.Extraction),
  RequestApprovalFold.Reachable s →
    @Membership.mem.{0, 0} RequestApprovalFold.OutputRef (List.{0} RequestApprovalFold.OutputRef)
        (@List.instMembership.{0} RequestApprovalFold.OutputRef) (RequestApprovalFold.State.usedOutputs s)
        (RequestApprovalFold.Extraction.ref o) →
      Not
          (@Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
            (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.State.extractions s) o) →
        RequestApprovalFold.History s s' →
          Not
            (@Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
              (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.State.extractions s') o)
```

### RequestApprovalFold.extraction_consumption_terminal

```lean
RequestApprovalFold.extraction_consumption_terminal : ∀ (s t u : RequestApprovalFold.State)
  (a : RequestApprovalFold.Action) (o : RequestApprovalFold.Extraction),
  RequestApprovalFold.Reachable s →
    RequestApprovalFold.Step s a t →
      Or
          (@Exists.{1} RequestApprovalFold.FoldTx fun (tx : RequestApprovalFold.FoldTx) =>
            And (@Eq.{1} RequestApprovalFold.Action a (RequestApprovalFold.Action.fold tx))
              (@Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
                (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.FoldTx.extractions tx)
                o))
          (@Exists.{1} RequestApprovalFold.ExtractionWithdrawTx fun (tx : RequestApprovalFold.ExtractionWithdrawTx) =>
            And (@Eq.{1} RequestApprovalFold.Action a (RequestApprovalFold.Action.extractionWithdraw tx))
              (@Eq.{1} RequestApprovalFold.Extraction (RequestApprovalFold.ExtractionWithdrawTx.input tx) o)) →
        RequestApprovalFold.History t u →
          And
            (Not
              (@Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
                (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.State.extractions t) o))
            (Not
              (@Membership.mem.{0, 0} RequestApprovalFold.Extraction (List.{0} RequestApprovalFold.Extraction)
                (@List.instMembership.{0} RequestApprovalFold.Extraction) (RequestApprovalFold.State.extractions u) o))
```

### RequestApprovalFold.account_item_inversion

```lean
RequestApprovalFold.account_item_inversion : ∀ (c : RequestApprovalFold.CageState) (iv : RequestApprovalFold.Interval)
  (refs : List.{0} RequestApprovalFold.TokenName) (sigs : List.{0} RequestApprovalFold.Signer)
  (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
  Iff (RequestApprovalFold.itemAllowed c iv refs sigs (RequestApprovalFold.FoldItem.account o e))
    (And
      (@Eq.{1} RequestApprovalFold.CageId
        (RequestApprovalFold.Request.cage (RequestApprovalFold.RequestOutput.request o))
        (RequestApprovalFold.CageState.id c))
      (And
        (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.RequestOutput.tags o)
          (@List.map.{0, 0} RequestApprovalFold.Oracle RequestApprovalFold.TokenName RequestApprovalFold.tagName
            (RequestApprovalFold.CageState.oracles c)))
        (And
          (@LE.le.{0} Nat instLENat
            (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
              (RequestApprovalFold.totalFees c (RequestApprovalFold.RequestOutput.request o))
              (RequestApprovalFold.CageState.minimum c))
            (RequestApprovalFold.RequestOutput.value o))
          (And
            (@Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.RequestOutput.requestTokens o)
              (@List.cons.{0} RequestApprovalFold.TokenName
                (RequestApprovalFold.requestName (RequestApprovalFold.CageState.id c))
                (@List.nil.{0} RequestApprovalFold.TokenName)))
            (And
              (@Eq.{1} RequestApprovalFold.RequestPolicy (RequestApprovalFold.RequestOutput.policy o)
                (RequestApprovalFold.requestPolicy c))
              (And
                (RequestApprovalFold.account_item_inversion.match_1.{1}
                  (fun (x : Option.{0} RequestApprovalFold.WitnessSpec) => Prop)
                  (RequestApprovalFold.Request.witnessing (RequestApprovalFold.RequestOutput.request o))
                  (fun (_ : Unit) => True) fun (spec : RequestApprovalFold.WitnessSpec) =>
                  And
                    (@LE.le.{0} Nat instLENat (RequestApprovalFold.CageState.minimum c)
                      (RequestApprovalFold.WitnessSpec.deposit spec))
                    (@Exists.{1} RequestApprovalFold.Key fun (k : RequestApprovalFold.Key) =>
                      @Exists.{1} RequestApprovalFold.Val fun (v : RequestApprovalFold.Val) =>
                        @Eq.{1} RequestApprovalFold.Write
                          (RequestApprovalFold.Request.write (RequestApprovalFold.RequestOutput.request o))
                          (RequestApprovalFold.Write.set k v)))
                (And (RequestApprovalFold.Interval.valid iv)
                  (And
                    (@LE.le.{0} RequestApprovalFold.Time instLENat
                      (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o))
                      (RequestApprovalFold.Interval.lower iv))
                    (And
                      (@LE.le.{0} RequestApprovalFold.Time instLENat (RequestApprovalFold.Interval.upper iv)
                        (@HAdd.hAdd.{0, 0, 0} RequestApprovalFold.Time Nat RequestApprovalFold.Time
                          (@instHAdd.{0} RequestApprovalFold.Time instAddNat)
                          (RequestApprovalFold.Request.deadline (RequestApprovalFold.RequestOutput.request o))
                          (RequestApprovalFold.Request.window (RequestApprovalFold.RequestOutput.request o))))
                      (RequestApprovalFold.hasAccount c (RequestApprovalFold.RequestOutput.request o) refs e))))))))))
```

### RequestApprovalFold.fold_witness_events_in_item_order

```lean
RequestApprovalFold.fold_witness_events_in_item_order : ∀ (tx : RequestApprovalFold.FoldTx),
  RequestApprovalFold.foldAccepted tx →
    @Eq.{1} (List.{0} RequestApprovalFold.WitnessEvent) (RequestApprovalFold.FoldTx.witnessEvents tx)
      (@List.flatMap.{0, 0} (Prod.{0, 0} RequestApprovalFold.FoldItem Nat) RequestApprovalFold.WitnessEvent
        (fun (p : Prod.{0, 0} RequestApprovalFold.FoldItem Nat) =>
          RequestApprovalFold.itemWitnessEvents
            (RequestApprovalFold.atTurn tx (@Prod.snd.{0, 0} RequestApprovalFold.FoldItem Nat p))
            (@Prod.fst.{0, 0} RequestApprovalFold.FoldItem Nat p))
        (@List.zipIdx.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldTx.items tx)
          (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0)))))
```

### RequestApprovalFold.ProofHelpers.registry_refl

```lean
RequestApprovalFold.ProofHelpers.registry_refl : ∀ (c : RequestApprovalFold.CageState),
  RequestApprovalFold.SameRegistry c c
```

### RequestApprovalFold.ProofHelpers.registry_trans

```lean
@RequestApprovalFold.ProofHelpers.registry_trans : ∀ {a b c : RequestApprovalFold.CageState}
  (h : RequestApprovalFold.SameRegistry a b) (k : RequestApprovalFold.SameRegistry b c),
  RequestApprovalFold.SameRegistry a c
```

### RequestApprovalFold.ProofHelpers.item_registry

```lean
RequestApprovalFold.ProofHelpers.item_registry : ∀ (c : RequestApprovalFold.CageState)
  (i : RequestApprovalFold.FoldItem), RequestApprovalFold.SameRegistry (RequestApprovalFold.itemResult c i) c
```

### RequestApprovalFold.ProofHelpers.result_registry

```lean
RequestApprovalFold.ProofHelpers.result_registry : ∀ (c : RequestApprovalFold.CageState)
  (items : List.{0} RequestApprovalFold.FoldItem),
  RequestApprovalFold.SameRegistry (RequestApprovalFold.foldResult c items) c
```

### RequestApprovalFold.ProofHelpers.fees_registry

```lean
@RequestApprovalFold.ProofHelpers.fees_registry : ∀ {a b : RequestApprovalFold.CageState}
  (h : RequestApprovalFold.SameRegistry a b) (r : RequestApprovalFold.Request),
  @Eq.{1} Nat (RequestApprovalFold.totalFees a r) (RequestApprovalFold.totalFees b r)
```

### RequestApprovalFold.ProofHelpers.result_trie

```lean
RequestApprovalFold.ProofHelpers.result_trie : ∀ (c : RequestApprovalFold.CageState)
  (items : List.{0} RequestApprovalFold.FoldItem) (iv : RequestApprovalFold.Interval)
  (refs : List.{0} RequestApprovalFold.TokenName) (sigs : List.{0} RequestApprovalFold.Signer)
  (out : RequestApprovalFold.CageState) (run : RequestApprovalFold.FoldRun iv refs sigs c items out),
  @Eq.{1} RequestApprovalFold.Trie (RequestApprovalFold.CageState.trie (RequestApprovalFold.foldResult c items))
    (RequestApprovalFold.applyAll (RequestApprovalFold.CageState.trie c)
      (@List.flatMap.{0, 0} RequestApprovalFold.FoldItem RequestApprovalFold.Write RequestApprovalFold.FoldItem.writes
        items))
```

### RequestApprovalFold.ProofHelpers.singleton_accepted

```lean
RequestApprovalFold.ProofHelpers.singleton_accepted : ∀ (s : RequestApprovalFold.State)
  (iv : RequestApprovalFold.Interval) (sigs : List.{0} RequestApprovalFold.Signer) (i : RequestApprovalFold.FoldItem)
  (folder : RequestApprovalFold.Signer) (hv : RequestApprovalFold.Interval.valid iv)
  (hi :
    RequestApprovalFold.itemAllowed (RequestApprovalFold.State.cage s) iv (RequestApprovalFold.State.judgments s) sigs
      i),
  RequestApprovalFold.foldAccepted (RequestApprovalFold.singletonFold s iv sigs i folder)
```

### RequestApprovalFold.ProofHelpers.oracle_total

```lean
RequestApprovalFold.ProofHelpers.oracle_total : ∀ (r : RequestApprovalFold.Request) (o : RequestApprovalFold.Oracle)
  (e : RequestApprovalFold.Evidence) (ha : RequestApprovalFold.Evidence.authorized e o),
  @Eq.{1} Nat (OracleIdentity.totalPaid (RequestApprovalFold.oracleCredits r o e)) (RequestApprovalFold.Request.fee r o)
```

### RequestApprovalFold.ProofHelpers.credits_total

```lean
RequestApprovalFold.ProofHelpers.credits_total : ∀ (c : RequestApprovalFold.CageState) (r : RequestApprovalFold.Request)
  (e : RequestApprovalFold.Selection)
  (ha :
    ∀ (o : RequestApprovalFold.Oracle),
      @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
          (@List.instMembership.{0} RequestApprovalFold.Oracle) (RequestApprovalFold.CageState.oracles c) o →
        RequestApprovalFold.Evidence.authorized (e o) o),
  @Eq.{1} Nat (OracleIdentity.totalPaid (RequestApprovalFold.credits c r e)) (RequestApprovalFold.totalFees c r)
```

### RequestApprovalFold.ProofHelpers.run_result

```lean
@RequestApprovalFold.ProofHelpers.run_result : ∀ {iv : RequestApprovalFold.Interval}
  {refs : List.{0} RequestApprovalFold.TokenName} {sigs : List.{0} RequestApprovalFold.Signer}
  {c : RequestApprovalFold.CageState} {items : List.{0} RequestApprovalFold.FoldItem}
  {out : RequestApprovalFold.CageState} (h : RequestApprovalFold.FoldRun iv refs sigs c items out),
  @Eq.{1} RequestApprovalFold.CageState out (RequestApprovalFold.foldResult c items)
```

### RequestApprovalFold.ProofHelpers.step_registry

```lean
@RequestApprovalFold.ProofHelpers.step_registry : ∀ {s s' : RequestApprovalFold.State} {a : RequestApprovalFold.Action}
  (h : RequestApprovalFold.Step s a s'),
  RequestApprovalFold.SameRegistry (RequestApprovalFold.State.cage s') (RequestApprovalFold.State.cage s)
```

### RequestApprovalFold.ProofHelpers.wf_registry

```lean
@RequestApprovalFold.ProofHelpers.wf_registry : ∀ {a b : RequestApprovalFold.CageState}
  (h : RequestApprovalFold.SameRegistry a b) (o : RequestApprovalFold.RequestOutput),
  Iff (RequestApprovalFold.wellFormed a o) (RequestApprovalFold.wellFormed b o)
```

### RequestApprovalFold.ProofHelpers.live_wf

```lean
RequestApprovalFold.ProofHelpers.live_wf : ∀ (s : RequestApprovalFold.State) (h : RequestApprovalFold.Reachable s)
  (o : RequestApprovalFold.RequestOutput),
  @Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
      (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.State.live s) o →
    RequestApprovalFold.wellFormed (RequestApprovalFold.State.cage s) o
```

### RequestApprovalFold.ProofHelpers.registry_valid

```lean
RequestApprovalFold.ProofHelpers.registry_valid : ∀ (s : RequestApprovalFold.State)
  (h : RequestApprovalFold.Reachable s), RequestApprovalFold.RegistryValid (RequestApprovalFold.State.cage s)
```

### RequestApprovalFold.ProofHelpers.request_member

```lean
RequestApprovalFold.ProofHelpers.request_member : ∀ (tx : RequestApprovalFold.FoldTx)
  (o : RequestApprovalFold.RequestOutput),
  Iff
    (@Membership.mem.{0, 0} RequestApprovalFold.RequestOutput (List.{0} RequestApprovalFold.RequestOutput)
      (@List.instMembership.{0} RequestApprovalFold.RequestOutput) (RequestApprovalFold.FoldTx.requests tx) o)
    (Or
      (@Exists.{1} RequestApprovalFold.Selection fun (e : RequestApprovalFold.Selection) =>
        @Membership.mem.{0, 0} RequestApprovalFold.FoldItem (List.{0} RequestApprovalFold.FoldItem)
          (@List.instMembership.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx)
          (RequestApprovalFold.FoldItem.write o e))
      (@Exists.{1} RequestApprovalFold.Selection fun (e : RequestApprovalFold.Selection) =>
        @Membership.mem.{0, 0} RequestApprovalFold.FoldItem (List.{0} RequestApprovalFold.FoldItem)
          (@List.instMembership.{0} RequestApprovalFold.FoldItem) (RequestApprovalFold.FoldTx.items tx)
          (RequestApprovalFold.FoldItem.account o e)))
```

### RequestApprovalFold.ProofHelpers.claim_origin_step

```lean
@RequestApprovalFold.ProofHelpers.claim_origin_step : ∀ {s s' : RequestApprovalFold.State}
  {a : RequestApprovalFold.Action} (h : RequestApprovalFold.Step s a s') (o : RequestApprovalFold.ClaimOutput)
  (ho :
    @Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
      (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.State.claims s') o),
  Or
    (@Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
      (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.State.claims s) o)
    (@Exists.{1} RequestApprovalFold.ClaimCreateTx fun (tx : RequestApprovalFold.ClaimCreateTx) =>
      And (@Eq.{1} RequestApprovalFold.Action a (RequestApprovalFold.Action.claimCreate tx))
        (And (@Eq.{1} RequestApprovalFold.ClaimOutput (RequestApprovalFold.ClaimCreateTx.output tx) o)
          (@Membership.mem.{0, 0} RequestApprovalFold.Signer (List.{0} RequestApprovalFold.Signer)
            (@List.instMembership.{0} RequestApprovalFold.Signer) (RequestApprovalFold.ClaimCreateTx.signers tx)
            (RequestApprovalFold.ClaimOutput.key o))))
```

### RequestApprovalFold.ProofHelpers.claim_origin_trace

```lean
@RequestApprovalFold.ProofHelpers.claim_origin_trace : ∀ {start s : RequestApprovalFold.State}
  {events :
    List.{0} (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State))}
  (h : RequestApprovalFold.Trace start events s) (o : RequestApprovalFold.ClaimOutput)
  (ho :
    @Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
      (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.State.claims s) o),
  Or
    (@Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
      (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.State.claims start) o)
    (@Exists.{1} RequestApprovalFold.State fun (before : RequestApprovalFold.State) =>
      @Exists.{1} RequestApprovalFold.State fun (after : RequestApprovalFold.State) =>
        @Exists.{1} RequestApprovalFold.ClaimCreateTx fun (tx : RequestApprovalFold.ClaimCreateTx) =>
          And
            (@Membership.mem.{0, 0}
              (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State))
              (List.{0}
                (Prod.{0, 0} RequestApprovalFold.State
                  (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
              (@List.instMembership.{0}
                (Prod.{0, 0} RequestApprovalFold.State
                  (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
              events
              (@Prod.mk.{0, 0} RequestApprovalFold.State
                (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State) before
                (@Prod.mk.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State
                  (RequestApprovalFold.Action.claimCreate tx) after)))
            (And (RequestApprovalFold.Step before (RequestApprovalFold.Action.claimCreate tx) after)
              (And (@Eq.{1} RequestApprovalFold.ClaimOutput (RequestApprovalFold.ClaimCreateTx.output tx) o)
                (@Membership.mem.{0, 0} RequestApprovalFold.Signer (List.{0} RequestApprovalFold.Signer)
                  (@List.instMembership.{0} RequestApprovalFold.Signer) (RequestApprovalFold.ClaimCreateTx.signers tx)
                  (RequestApprovalFold.ClaimOutput.key o)))))
```

### RequestApprovalFold.ProofHelpers.trace_snoc

```lean
@RequestApprovalFold.ProofHelpers.trace_snoc : ∀ {a b c : RequestApprovalFold.State}
  {events :
    List.{0} (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State))}
  {action : RequestApprovalFold.Action} (ht : RequestApprovalFold.Trace a events b)
  (hs : RequestApprovalFold.Step b action c),
  RequestApprovalFold.Trace a
    (@HAppend.hAppend.{0, 0, 0}
      (List.{0}
        (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
      (List.{0}
        (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
      (List.{0}
        (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
      (@instHAppendOfAppend.{0}
        (List.{0}
          (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))
        (@List.instAppend.{0}
          (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State))))
      events
      (@List.cons.{0}
        (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State))
        (@Prod.mk.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State) b
          (@Prod.mk.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State action c))
        (@List.nil.{0}
          (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State)))))
    c
```

### RequestApprovalFold.ProofHelpers.trace_reaches

```lean
@RequestApprovalFold.ProofHelpers.trace_reaches : ∀ {a b : RequestApprovalFold.State}
  {events :
    List.{0} (Prod.{0, 0} RequestApprovalFold.State (Prod.{0, 0} RequestApprovalFold.Action RequestApprovalFold.State))}
  (ht : RequestApprovalFold.Trace a events b) (ha : RequestApprovalFold.Reachable a), RequestApprovalFold.Reachable b
```

### RequestApprovalFold.ProofHelpers.authorized_nonempty

```lean
RequestApprovalFold.ProofHelpers.authorized_nonempty : ∀ (o : RequestApprovalFold.Oracle)
  (e : RequestApprovalFold.Evidence) (ha : RequestApprovalFold.Evidence.authorized e o),
  @Ne.{1} (List.{0} RequestApprovalFold.Signer) (RequestApprovalFold.Evidence.signers e)
    (@List.nil.{0} RequestApprovalFold.Signer)
```

### RequestApprovalFold.ProofHelpers.claim_tokens

```lean
RequestApprovalFold.ProofHelpers.claim_tokens : ∀ (s : RequestApprovalFold.State) (h : RequestApprovalFold.Reachable s)
  (o : RequestApprovalFold.ClaimOutput),
  @Membership.mem.{0, 0} RequestApprovalFold.ClaimOutput (List.{0} RequestApprovalFold.ClaimOutput)
      (@List.instMembership.{0} RequestApprovalFold.ClaimOutput) (RequestApprovalFold.State.claims s) o →
    @Eq.{1} (List.{0} RequestApprovalFold.TokenName) (RequestApprovalFold.ClaimOutput.tokens o)
      (@List.cons.{0} RequestApprovalFold.TokenName
        (RequestApprovalFold.claimName (RequestApprovalFold.CageState.id (RequestApprovalFold.State.cage s)))
        (@List.nil.{0} RequestApprovalFold.TokenName))
```

### RequestApprovalFold.ProofHelpers.run_request_conservation

```lean
@RequestApprovalFold.ProofHelpers.run_request_conservation : ∀ {iv : RequestApprovalFold.Interval}
  {refs : List.{0} RequestApprovalFold.TokenName} {sigs : List.{0} RequestApprovalFold.Signer}
  {c : RequestApprovalFold.CageState} {items : List.{0} RequestApprovalFold.FoldItem}
  {out : RequestApprovalFold.CageState} (h : RequestApprovalFold.FoldRun iv refs sigs c items out),
  @Eq.{1} Nat (RequestApprovalFold.requestEscrows items)
    (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
      (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat) (RequestApprovalFold.grossCredits c items)
        (RequestApprovalFold.requestRemainders c items))
      (RequestApprovalFold.requestDepositInputs items))
```

### RequestApprovalFold.ProofHelpers.payments_total

```lean
RequestApprovalFold.ProofHelpers.payments_total : ∀ (c : RequestApprovalFold.CageState)
  (folder : RequestApprovalFold.Signer) (items : List.{0} RequestApprovalFold.FoldItem)
  (iv : RequestApprovalFold.Interval) (refs : List.{0} RequestApprovalFold.TokenName)
  (sigs : List.{0} RequestApprovalFold.Signer) (out : RequestApprovalFold.CageState)
  (run : RequestApprovalFold.FoldRun iv refs sigs c items out),
  @Eq.{1} Nat (RequestApprovalFold.totalPaid (RequestApprovalFold.foldPayments c folder items))
    (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
      (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
        (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
          (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
            (RequestApprovalFold.requestRemainders c items) (RequestApprovalFold.claimPayouts c items))
          (RequestApprovalFold.claimEscrows items))
        (RequestApprovalFold.unusedDepositRefunds items))
      (RequestApprovalFold.witnessRefundTotal c items))
```

### RequestApprovalFold.ProofHelpers.credits_cover

```lean
RequestApprovalFold.ProofHelpers.credits_cover : ∀ (c : RequestApprovalFold.CageState) (r : RequestApprovalFold.Request)
  (e : RequestApprovalFold.Selection)
  (ha :
    ∀ (o : RequestApprovalFold.Oracle),
      @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
          (@List.instMembership.{0} RequestApprovalFold.Oracle) (RequestApprovalFold.CageState.oracles c) o →
        RequestApprovalFold.Evidence.authorized (e o) o)
  (p : OracleIdentity.Payment),
  @Membership.mem.{0, 0} OracleIdentity.Payment (List.{0} OracleIdentity.Payment)
      (@List.instMembership.{0} OracleIdentity.Payment) (RequestApprovalFold.credits c r e) p →
    @Membership.mem.{0, 0} OracleIdentity.Key (List.{0} RequestApprovalFold.Signer)
      (@List.instMembership.{0} RequestApprovalFold.Signer) (RequestApprovalFold.registryKeys c)
      (OracleIdentity.Payment.key p)
```

### RequestApprovalFold.ProofHelpers.credit_backed

```lean
RequestApprovalFold.ProofHelpers.credit_backed : ∀ (c : RequestApprovalFold.CageState)
  (ps : List.{0} OracleIdentity.Payment) (hb : RequestApprovalFold.Backed c)
  (hp :
    ∀ (p : OracleIdentity.Payment),
      @Membership.mem.{0, 0} OracleIdentity.Payment (List.{0} OracleIdentity.Payment)
          (@List.instMembership.{0} OracleIdentity.Payment) ps p →
        @Membership.mem.{0, 0} OracleIdentity.Key (List.{0} RequestApprovalFold.Signer)
          (@List.instMembership.{0} RequestApprovalFold.Signer) (RequestApprovalFold.registryKeys c)
          (OracleIdentity.Payment.key p)),
  RequestApprovalFold.Backed (RequestApprovalFold.credit c ps)
```

### RequestApprovalFold.ProofHelpers.clear_sum

```lean
RequestApprovalFold.ProofHelpers.clear_sum : ∀ (ks : List.{0} RequestApprovalFold.Signer)
  (f : RequestApprovalFold.Signer → Nat) (key : RequestApprovalFold.Signer)
  (hn : @List.Nodup.{0} RequestApprovalFold.Signer ks)
  (hk :
    @Membership.mem.{0, 0} RequestApprovalFold.Signer (List.{0} RequestApprovalFold.Signer)
      (@List.instMembership.{0} RequestApprovalFold.Signer) ks key),
  @Eq.{1} Nat
    (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
      (@List.sum.{0} Nat instAddNat (@Zero.ofOfNat0.{0} Nat (instOfNatNat (nat_lit 0)))
        (@List.map.{0, 0} RequestApprovalFold.Signer Nat
          (fun (k : RequestApprovalFold.Signer) =>
            @ite.{1} Nat (@Eq.{1} RequestApprovalFold.Signer k key) (instDecidableEqString k key)
              (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0))) (f k))
          ks))
      (f key))
    (@List.sum.{0} Nat instAddNat (@Zero.ofOfNat0.{0} Nat (instOfNatNat (nat_lit 0)))
      (@List.map.{0, 0} RequestApprovalFold.Signer Nat f ks))
```

### RequestApprovalFold.ProofHelpers.claim_balance_sum

```lean
RequestApprovalFold.ProofHelpers.claim_balance_sum : ∀ (c : RequestApprovalFold.CageState)
  (o : RequestApprovalFold.ClaimOutput)
  (hk :
    @Membership.mem.{0, 0} RequestApprovalFold.Signer (List.{0} RequestApprovalFold.Signer)
      (@List.instMembership.{0} RequestApprovalFold.Signer) (RequestApprovalFold.registryKeys c)
      (RequestApprovalFold.ClaimOutput.key o)),
  @Eq.{1} Nat
    (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat)
      (RequestApprovalFold.balanceSum (RequestApprovalFold.itemResult c (RequestApprovalFold.FoldItem.claim o)))
      (RequestApprovalFold.CageState.balances c (RequestApprovalFold.ClaimOutput.key o)))
    (RequestApprovalFold.balanceSum c)
```

### RequestApprovalFold.ProofHelpers.item_backed

```lean
RequestApprovalFold.ProofHelpers.item_backed : ∀ (c : RequestApprovalFold.CageState) (iv : RequestApprovalFold.Interval)
  (refs : List.{0} RequestApprovalFold.TokenName) (sigs : List.{0} RequestApprovalFold.Signer)
  (i : RequestApprovalFold.FoldItem) (hb : RequestApprovalFold.Backed c)
  (ha : RequestApprovalFold.itemAllowed c iv refs sigs i),
  RequestApprovalFold.Backed (RequestApprovalFold.itemResult c i)
```

### RequestApprovalFold.ProofHelpers.run_backed

```lean
@RequestApprovalFold.ProofHelpers.run_backed : ∀ {iv : RequestApprovalFold.Interval}
  {refs : List.{0} RequestApprovalFold.TokenName} {sigs : List.{0} RequestApprovalFold.Signer}
  {c : RequestApprovalFold.CageState} {items : List.{0} RequestApprovalFold.FoldItem}
  {out : RequestApprovalFold.CageState} (h : RequestApprovalFold.FoldRun iv refs sigs c items out)
  (hb : RequestApprovalFold.Backed c), RequestApprovalFold.Backed out
```

### RequestApprovalFold.ProofHelpers.run_value_conservation

```lean
@RequestApprovalFold.ProofHelpers.run_value_conservation : ∀ {iv : RequestApprovalFold.Interval}
  {refs : List.{0} RequestApprovalFold.TokenName} {sigs : List.{0} RequestApprovalFold.Signer}
  {c : RequestApprovalFold.CageState} {items : List.{0} RequestApprovalFold.FoldItem}
  {out : RequestApprovalFold.CageState} (h : RequestApprovalFold.FoldRun iv refs sigs c items out)
  (hb : RequestApprovalFold.Backed c),
  @Eq.{1} Nat
    (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat) (RequestApprovalFold.CageState.value c)
      (RequestApprovalFold.grossCredits c items))
    (@HAdd.hAdd.{0, 0, 0} Nat Nat Nat (@instHAdd.{0} Nat instAddNat) (RequestApprovalFold.CageState.value out)
      (RequestApprovalFold.claimPayouts c items))
```

### RequestApprovalFold.ProofHelpers.result_append

```lean
RequestApprovalFold.ProofHelpers.result_append : ∀ (c : RequestApprovalFold.CageState)
  (xs ys : List.{0} RequestApprovalFold.FoldItem),
  @Eq.{1} RequestApprovalFold.CageState
    (RequestApprovalFold.foldResult c
      (@HAppend.hAppend.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) (List.{0} RequestApprovalFold.FoldItem)
        (List.{0} RequestApprovalFold.FoldItem)
        (@instHAppendOfAppend.{0} (List.{0} RequestApprovalFold.FoldItem)
          (@List.instAppend.{0} RequestApprovalFold.FoldItem))
        xs ys))
    (RequestApprovalFold.foldResult (RequestApprovalFold.foldResult c xs) ys)
```

### RequestApprovalFold.ProofHelpers.credits_unpaid

```lean
RequestApprovalFold.ProofHelpers.credits_unpaid : ∀ (c : RequestApprovalFold.CageState)
  (r : RequestApprovalFold.Request) (e : RequestApprovalFold.Selection) (k : RequestApprovalFold.Signer)
  (hz :
    ∀ (o : RequestApprovalFold.Oracle),
      @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
          (@List.instMembership.{0} RequestApprovalFold.Oracle) (RequestApprovalFold.CageState.oracles c) o →
        @Eq.{1} Nat (OracleIdentity.paidTo (RequestApprovalFold.oracleCredits r o (e o)) k)
          (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0)))),
  @Eq.{1} Nat (OracleIdentity.paidTo (RequestApprovalFold.credits c r e) k)
    (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0)))
```

### RequestApprovalFold.ProofHelpers.run_balance_nonincrease

```lean
@RequestApprovalFold.ProofHelpers.run_balance_nonincrease : ∀ {iv : RequestApprovalFold.Interval}
  {refs : List.{0} RequestApprovalFold.TokenName} {sigs : List.{0} RequestApprovalFold.Signer}
  {c : RequestApprovalFold.CageState} {items : List.{0} RequestApprovalFold.FoldItem}
  {out : RequestApprovalFold.CageState} (h : RequestApprovalFold.FoldRun iv refs sigs c items out)
  (key : RequestApprovalFold.Signer)
  (hz :
    ∀ (n : Nat) (o : RequestApprovalFold.RequestOutput) (e : RequestApprovalFold.Selection),
      Or
          (@Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
            (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
              (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
                @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
              (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) items n)
            (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.write o e)))
          (@Eq.{1} (Option.{0} RequestApprovalFold.FoldItem)
            (@GetElem?.getElem?.{0, 0, 0} (List.{0} RequestApprovalFold.FoldItem) Nat RequestApprovalFold.FoldItem
              (fun (as : List.{0} RequestApprovalFold.FoldItem) (i : Nat) =>
                @LT.lt.{0} Nat instLTNat i (@List.length.{0} RequestApprovalFold.FoldItem as))
              (@List.instGetElem?NatLtLength.{0} RequestApprovalFold.FoldItem) items n)
            (@Option.some.{0} RequestApprovalFold.FoldItem (RequestApprovalFold.FoldItem.account o e))) →
        ∀ (oracle : RequestApprovalFold.Oracle),
          @Membership.mem.{0, 0} RequestApprovalFold.Oracle (List.{0} RequestApprovalFold.Oracle)
              (@List.instMembership.{0} RequestApprovalFold.Oracle) (RequestApprovalFold.CageState.oracles c) oracle →
            @Eq.{1} Nat
              (OracleIdentity.paidTo
                (RequestApprovalFold.oracleCredits (RequestApprovalFold.RequestOutput.request o) oracle (e oracle)) key)
              (@OfNat.ofNat.{0} Nat (nat_lit 0) (instOfNatNat (nat_lit 0)))),
  @LE.le.{0} Nat instLENat (RequestApprovalFold.CageState.balances out key)
    (RequestApprovalFold.CageState.balances c key)
```
