# Oracle identity theorem and semantic-atom ledgers

This is the **OBSERVATION PROOF REPAIR CANDIDATE** under NOTE-004.
The independent proof audit of `964eb1a` returned PASS for T01-T26, with
advisory observation survivors X45, X47 and X48. The operator commissioned
exact observation laws and their proofs, in two commits: admitted statements
first, then proofs. All 31 theorems are now PROVED. T01-T26 retain their exact declaration and
proof text; T27-T31 retain the types committed first in
`ee92321365293c9f478eec28e5d43863488a5912`. Their concrete witnesses import
only observation vocabulary and the model, never Statements. Model.lean remains
byte-identical. Independent assessment of this new repair is pending.
The full audit report is retained as `inputs/proof-audit-1.md` in the runtime.

Registry integration, judgment binding and price notices remain outside #126
and belong to #127. Creator evidence is a CANDIDATE, not independent acceptance.

## Observation repair (NOTE-004)

| Row | Theorem | Exact guarantee | Witness | Mutant | Outcome |
|---|---|---|---|---|---|
| T27 | paid_to_exact | Sum every matching payment amount, including repeated recipients; exclude other keys | W27: Alice receives 8, repeated payee receives 3+5, zero and empty cases | X45: paidTo key predicate conjoined with False | PROVED |
| T28 | paid_to_partition | Sum paidTo once per distinct payment key equals totalPaid for every payment list | W28: nested payout 11; repeated payee and zero-valued Bob total 8 | X45 | PROVED |
| T29 | recorded_keys_exact | Key record has exactly its key; group flattens every child's keys in order | W29: key, nested group and empty group | X47: recordedKeys key returns [] | PROVED |
| T30 | successful_record_keys_exact | Successful record keys exactly match original-description authorizing branches | W30: nested successful root with signing Carol in a failed subgroup; only Alice retained | X47 | PROVED |
| T31 | signing_keys_exact | Exactly the description keys among signers, in description order with duplicates removed | W31: duplicates and outsider removed; signed Carol retained despite failed subgroup; absent key omitted | X48: omit the signer filter | PROVED |

`ObservationSpec.lean` defines `branchKeys`/`memberBranchKeys` as statement
vocabulary over the original description. A key is included iff it signed;
a group contributes its recursively collected keys iff its direct authorizing
count meets the threshold. This vocabulary calls none of the three repaired
observations. It distinguishes signed keys in failed branches from recorded
keys. T29 fixes all record constructors, including arbitrary records; T30 binds
the observation to an actual successful authorization.

New semantic atoms: A28 paidTo's exact positive/zero aggregate (T27/T28);
A29 recordedKeys leaf and ordered recursive concatenation (T29);
A30 exact description-to-record key projection through successful branches
(T30); A31 signingKeys signer filtering, description order and deduplication
(T31). X45/X47/X48 are KILLED by the bounded creator repair probes below.

All 31 source signatures are captured before proof edits in
`evidence/repair-004/statement-signatures.json`; the original 26 match the
accepted `82bbfcc` signatures. The five additions have these type hashes, unchanged after proof completion:

| Row | SHA256 |
|---|---|
| T27 | `936c284c2548d9afdae415ca2d060580482d0456275cd3c1f38056c61e748841` |
| T28 | `4009a9b9f018ce86454f01e55294cc154f193d68795fbf2f0eaaea488caafc84` |
| T29 | `8b9a4e53d665d4e006264882e70c4e8d2def9c42181613841ac8f44f0b6f7ccd` |
| T30 | `6c10ba546db045f499b304ae14da685a7d0333bcb0cc35f7a9aaa2e78b9cb3c3` |
| T31 | `1820ed697ec1bf3f085ecacefe3199a95416df57988d0211bdd1b7b68691e068` |

The generic JSON surface now exposes `signingKeys` directly for any description
and signers, without requiring authorization. The corpus adds W27-W31 and
X45/X47/X48 scenarios; no per-theorem driver dispatch was added. Kernel witnesses
also cover arbitrary repeated payment recipients and arbitrary records, which
the existing scenario grammar does not accept as inputs.

Statement-phase build: 29 jobs, exit 0, exactly five intentional admissions.
Evidence: `evidence/repair-004/statements-build.log`. Independent audit of the
new statement slice is enabled by its separate commit. NOTE-004 also explicitly
authorizes the following proof commit; no original guarantee is reopened.

### Observation proof and mutation receipts

The clean absent-`.lake` prescribed build passes **30 jobs**, exit 0, with
zero admissions. All 31 theorem and 31 witness axiom inventories contain only
`propext`, `Classical.choice` and `Quot.sound`. The original 26 source
types still match `82bbfcc`; all 31 match the separate statement commit
`ee92321`. Model, Paths, Driver and the prior five proof-helper files are
unchanged from `964eb1a`. ObservationSpec, Witnesses, Surface and Corpus are
unchanged between this repair's statement and proof commits.

`ObservationProofs.lean` proves payment aggregation by list induction. A
finite distinct-key cover partitions the payment list; applying that result to
the deduplicated payee list proves T28 even for repeated recipients and zero
payments. Mutual recursion proves that a raw record's key projection equals
the original description's authorizing branches. The public success inversion
then supplies T30. T29 fixes both constructor equations, while T31 fixes the
existing filter and deduplication exactly.

| Mutant | Owning new rows | Exact semantic counterexample |
|---|---|---|
| X45: conjoin the paidTo key predicate with False | T27, T28 | One Alice payment of 7: paidTo and its distinct-payee partition become 0 |
| X47: recordedKeys key leaf returns [] | T29, T30 | Alice's key record, including a successful Alice authorization, loses its key |
| X48: remove signingKeys signer filter | T31 | Unsigned Alice is wrongly included |

`mutation-manifest.json` freezes the exact-once source edits and all 20 probes
before execution (SHA256 `89fcad9d6e127b1e2aa222d897a0970cb0a1aaf103e2a6b848a7a9da4354723b`).
Every probe embeds the production Model, Paths and ObservationSpec source in an
isolated file; only the named single site changes in mutant copies. Production
Model.lean is never edited. The new theorem type is extracted verbatim from the
statement-phase manifest, and the manifest is checked against `ee92321`.
For each of the five rows: the healthy instance proves; the mutant instance is
semantically false; the mutant's universally quantified statement has a kernel
refutation; the same refutation fails on the healthy model because its concrete
negation is false. All 20 expected outcomes pass. All ten successful probes use
only permitted axioms. A failed proof script alone is never counted as a kill.
This is a bounded creator regression, not a new independent mutation audit.

The generic driver replays **81 corpus scenarios** with 14 expected authorization
refusals, plus six malformed/precondition rejection controls. Positive paidTo,
recordedKeys and signingKeys results are asserted. All 81 codec roundtrips pass.
`signingKeys` observations have no authorization precondition; the no-signer
case specifically exercises that boundary.

Evidence is in `evidence/repair-004/` under the runtime root:
`clean-build.log`, `axiom-inventory.json`, `freeze-check.json`,
`mutation-results.json`, `replay-results.json`, `codecs.log` and
`failure-notes.md`. The final receipt binds both local commits, source and
instrument hashes. No push or hosted CI is claimed. The prior independent audit
PASS applies to `964eb1a`; independent acceptance of this repair is parent-owned.

## Prior statement repair and mutation result

The independent audit of 6333c158 was NOT-READY: the prior statements allowed a
key record to be replaced by an invented singleton group while preserving key
membership and fee behavior. NOTE-001 commissions this repair. In the repair candidate,
T01-T24 declarations were byte-identical, including their then-open proof holes,
and Model.lean was unchanged. T25 fixes both raw and public key records exactly;
its raw-record equality applies at every recursive key call, while T14 binds
retained group members to those records. T26 covers failed subgroups at every
finite member-index path. The accepted types are preserved in the current proof candidate.

`Paths.lean` defines only statement vocabulary: `atPath root path` selects a
subdescription by its original member indices. It includes nonauthorizing
members; it does not traverse the filtered signing record. Empty paths select
the root, missing indices fail, and keys cannot be descended into. T26 quantifies
all paths with no depth bound. W26 reaches a successful root split with a failed
subgroup at path `[0, 1]`; Carol signs inside that subgroup and still receives zero.

M25 is the exact audit survivor: replace the successful key result in
`record.key` by `.group (.cons 1 (.key k) .nil)`. Four isolated compiler probes
bind directly to T25's extracted type, without importing admitted statements:

| Probe | Exit | Evidence |
|---|---|---|
| Healthy model, T25 instance for Alice | 0 | Kernel proof, only propext |
| Mutant model, same T25 instance | 1 | Lean decides that the proposition is false |
| Mutant model, negation of the universally quantified T25 type | 0 | Kernel counterexample proof, only propext |
| Healthy model, same counterexample | 1 | Lean decides that the alleged counterexample is false |

This historical creator regression shows M25 is killed by T25. It is not an
independent audit; the current proof candidate separately proves T25 universally
on the healthy model. Failed elaborations may
print sorryAx for Lean's error placeholders; only the two exit-zero probes count
as proofs. Production Model.lean was never mutated. The generated probes,
single-site edit, digests and outputs are retained under
`evidence/repair-001/` in the runtime. The first probe needed an explicit unfold
of its type alias for decidability; that setup failure is retained separately.
The original 24-row bounded-domain survival result is the independent audit's
finding, not a campaign rerun or acceptance claim by this creator.

## Authority and domain

Base: `5ad9589` (main after PR #125), followed by the parent's ruling commit
`a4e0b3b6b4ab6f3d6d8af5295628d3028aa4d0ab`. The model candidate descends
from that ruling commit.

- `specs/oracle-identity/decisions.md`, SHA256
  `8a66110905fc8c185ebeab66d1f73946b7e6f5cff4ef5cb41403f113247d49bd`.
- `docs/design/registries/oracles.md`, SHA256
  `77b434bd716cacc306e2a6f2a00774ddc197655886436cfd7f5226faa0037905`.
- Operator ruling `A-001-description-domain.md`, SHA256
  `65eecc2052b6523dcaa028919a3c9c7693f92c2a30bb6f68209de583f12c1ca8`,
  in `/code/mpfs-onchain-lean-126-20261028/astra-identities-model/answers/`.
  The parent incorporated this ruling in the decision record in `a4e0b3b`.

A-001 requires finite ordered descriptions, a positive group threshold no greater
than its member count, positive shares, recursive validity, and no repeated key
anywhere within one description. Identical or overlapping subgroups therefore
fail validity. Separate descriptions may use the same key. Every recursively
authorizing member is retained in original order; the submitter cannot select a
subset. A subgroup below its threshold receives nothing, even if some of its keys
signed. Authorization counts member oracles, not shares or raw key signatures.

`Members` and `SignedMembers` are ordinary ordered cons lists expressed as mutual
inductives with their trees. `toList` exposes the corresponding Lean list. This
representation supplies structural recursion and computable equality without
axioms or partial model functions. Signers, fees, thresholds and shares are finite
lists or naturals; duplicate signer entries have no additional authority.

A structured `Identity` has the leading role `oracle` and the complete description.
Injectivity is an abstract name guarantee, not a claim about concrete hashing,
CBOR encoding or cryptographic collision resistance. No mutable identity or key
rotation operation exists. Keys model authenticated transaction signer hashes.

## Statements and witnesses

All theorem names below are in namespace `OracleIdentity`, in
`lean/MpfsCage/OracleIdentity/Statements.lean`. Each W row is a named proof in
`OracleIdentity.Witnesses`, in `Witnesses.lean`, with concrete model calls. This
algebra has no state-machine reachability relation: a reachable witness is an
actual call to the authoritative operation, together with kernel proofs of its
premises and observed result. Refusal arms have actual refusing calls.

The accepted statement-candidate file at `82bbfcc` had SHA256
`42a491ae5424fc78710d93819ce28ffd92172cf2c40b723bb9fa4e08e426f9b9`.
Per NOTE-003, that historical whole-file digest is not the proof-phase freeze:
replacing proof bodies necessarily changes it. The 26 source signatures were
extracted and hashed from the accepted commit before proof edits, and compared
byte-for-byte afterward. Full texts and hashes are retained in
`evidence/proofs/accepted-signatures.json` (SHA256
`0a0f303c7435ed6c09fc2fafb1081a9863a490e3e813bd698b44e342233101b1`);
`freeze-check.json` records the matching final signatures and frozen model.

| Row | Theorem | Obligation | Reachable witness | Named single-atom mutant expected to falsify it | Outcome |
|---|---|---|---|---|---|
| T01 | identity_injective | Equal names imply equal complete descriptions | W01, valid nested description | M01: replace the bound description by one constant key; demo and Bob collide | PROVED |
| T02 | authorization_binds_identity | Success binds the actual supplied description to the expected name | W02 success and mismatched-name refusal | M02: omit the identity equality guard | PROVED |
| T03 | invalid_description_refused | Invalid descriptions refuse both authorization and splitting | W03 zero share, including actual split refusal | M03: omit validity from authorize | PROVED |
| T04 | group_valid_iff | Exact lower/upper threshold, positive shares, nested validity and global key uniqueness | W04 valid nested group, zero threshold, excessive threshold, zero share | M04: omit the positive-threshold guard; empty zero-threshold group becomes valid | PROVED |
| T05 | key_authorizes_iff | A key authorizes exactly when it signs | W05 present and absent key | M05: return a key record without checking signer membership | PROVED |
| T06 | group_authorizes_iff | Validity and at least the threshold of recursively authorizing members | W06, two members authorize a threshold-two group | M06: count signed shares instead of signed members; Alice alone has share two | PROVED |
| T07 | authorization_monotone | Adding signers cannot revoke authorization | W07, Alice/Carol followed by Alice/Carol/Dave | M07: require exact equality to the threshold; the inner group stops authorizing when Dave joins | PROVED |
| T08 | below_threshold_refused | Too few authorizing members cannot authorize a group | W08, two keys inside just one direct member | M08: lower the threshold by one; a flat threshold-two group accepts Alice alone | PROVED |
| T09 | key_is_single_member_case | A positive-share singleton group has the key's authorization and complete payout behavior | W09, singleton share seven and fee eleven | M09: pass fee minus one to group splitting | PROVED |
| T10 | key_receives_whole_fee | A signing key receives exactly the entire fee | W10, fee eleven | M10: pay fee minus one at a key leaf | PROVED |
| T11 | split_conserves_fee | Every successful public split pays exactly its input fee | W11, nested split pays 8 + 2 + 1 = 11 | M11: discard the integer remainder | PROVED |
| T12 | unsigned_key_receives_nothing | No payment to a key absent from the signers | W12, Bob absent and unpaid | M12: retain a fabricated Bob leaf when a member does not authorize | PROVED |
| T13 | nonauthorizing_member_receives_nothing | Every key of a failed direct member receives zero, even when that key signed | W13, Carol signs but her threshold-two subgroup fails | M13: append a one-unit Carol payment at a group split | PROVED |
| T14 | group_record_exact | Record exactly all authorizing members, with their shares and order | W14, all three direct members authorize a threshold-two group | M14: return an empty group record after the threshold check | PROVED |
| T15 | recorded_keys_are_signers | Every recorded key signed and belongs to the actual description | W15, nested recorded keys | M15: substitute an attacker key in the key record | PROVED |
| T16 | record_keys_unique | A successful canonical record never repeats a key | W16, nested record with distinct leaves | M16: duplicate a retained member in signedMembers | PROVED |
| T17 | group_split_exact | Literal proportional floor formula and entire remainder to index zero, recursively | W17, outer and inner remainders plus an unsigned leading member | M17: divide equally instead of using the signed shares | PROVED |
| T18 | key_contributes_to_at_most_one_member | On a valid group, each key belongs to at most one direct member | W18, Carol occurs only within the inner member | M18: omit global key uniqueness; duplicate nested Alice belongs to two members | PROVED |
| T19 | threshold_needs_distinct_signing_keys | Threshold m requires at least m distinct signing keys in the description | W19, duplicate Alice signer entries still give exactly two distinct keys | M19: lower the threshold by one; demo authorizes Alice alone | PROVED |
| T20 | repeated_key_invalid | A repeated key anywhere in the tree makes the description invalid | W20, Alice both direct and nested | M20: omit global key uniqueness | PROVED |
| T21 | authorization_inversion | Success iff name, validity and actual canonical record all match | W21, actual successful canonical record | M21: substitute a fabricated record on success | PROVED |
| T22 | split_refusal_iff | Splitting refuses exactly when authorization refuses | W22, no signers | M22: return some empty payments on authorization refusal | PROVED |
| T23 | signer_set_extensional | Order and multiplicity of signer entries do not change authorization or its record | W23, reordered Alice/Carol signers | M23: check only the first signer for a key oracle | PROVED |
| T24 | recorded_split_replay | Any successful record replays at any later natural fee, agrees with the public split and conserves that fee | W24, one record replayed at fees 0, 11 and 17 | M24: public split replays with fee plus one | PROVED |
| T25 | key_record_exact | A key raw record and public authorization return exactly its key leaf when signed, and none otherwise, at every recursive key call | W25, key present/absent and the nested demo record | M25: replace every key record by a singleton group of share one; kernel refutation and both-way controls pass | PROVED |
| T26 | nonauthorizing_subgroup_at_any_depth_receives_nothing | Every key in a subgroup below threshold receives zero from a successful root split, at any finite original-description path | W26, Carol signs in a failed subgroup at path [0, 1] | M26: append a one-unit Carol payout at a group split | PROVED |

### Accepted source-type hashes

Each digest covers the exact `theorem` declaration through its type, excluding
` := by` and the proof. Row names and types match `82bbfcc` exactly.

| Row | SHA256 |
|---|---|
| T01 | `515b213cfd2939c73e3b1bb01721995ced2ea974f8685b8783a32429ff8687d3` |
| T02 | `2877165ec89bea2648d7929936910a8ce6ef4e2aaf742d7f7664a98dbaf9ea62` |
| T03 | `8ac49c71fe9ebe475dd5c18d3155e75e06999b57ed6a77f840fcac7ed4121171` |
| T04 | `a2b30999fa818fa805f47d97320ddb45eb8385a0fa72487674a16aaba469c2b9` |
| T05 | `25241011d9227814eab74dbc2d96fec752910d3a024787adfd95463722cfc5b6` |
| T06 | `ee847c0a8cd26cc760e3a5a40b97a2ffbb4f1cb8a29924087773de7d949c67fc` |
| T07 | `5b76847a0ec6535aae13fc77bc2e26b4f19c710f87c32c63aef3cb5b362f7764` |
| T08 | `d8b485056bca87a81c6bda09b7af2d47e4fc72132e041fed2f6a1c879a6fd9c1` |
| T09 | `cb1e63b63e0ede279a75e38e21cdcb7e81c8bc257bfc3ca70ab66f5651736148` |
| T10 | `83f887588935cbc0703b0e173197b85ffa780bef4ca24d099850769fa16f2c7d` |
| T11 | `dd7926177d051421b66e5f6efb21f2205063ab301999a3199f0af530cca33c69` |
| T12 | `da679ad555f555ca323dde6f1f00a8c1a0c4a0d9a8623cec2e0c29b9581b0e36` |
| T13 | `025c281f777e5397d18af042185ec54eeadd7ef90f534a0db573099254d88d88` |
| T14 | `489f95e77c91c7f4d01b8eadbd82431397a2f73644409d143e4794f243e78796` |
| T15 | `92dbb4cde740179d600ed575a76ae39d25104ef73fc7be8e1b95ea679a9501d5` |
| T16 | `cdd1ddeb7df9953ebb40c03a8eae8cf60b5422beb90bc331bb0537335d11e1b6` |
| T17 | `4e88284173dc0b11910d43fd18e853f424f80680aa88292ad32c00d06a6ae2ca` |
| T18 | `5bfc46c9c7146210b778aa335ddb6ff9fe8a585f53bfa9ffa44651f5efafbfdf` |
| T19 | `d347297175428eba70fb15d046b2f2ce0ea8b6c97d2198eec71e4b446007d8e0` |
| T20 | `552d23c24de9e0c0ada96920d0b8ac89bf4e6cb0cf9344d96be4fb9056b96898` |
| T21 | `b085fba16e4facaaba15aa5fad1aa481612710195e6da36354253ad54b844188` |
| T22 | `937a15ce893c6d7ff3da8aed6086e8910a76cd4113693bbad30c6a25d904fe73` |
| T23 | `bc9b8cbfa37545d6fdc67dad84111da21ff9dc41c902dac51b772dd43fae378c` |
| T24 | `94aa0848890f927c5900de30676077d97ae335752ddef557a321176498ade121` |
| T25 | `db56744e749f3c4fe47000396839945be0c098be22393cd329df34cfbec7e9ad` |
| T26 | `70298781792b276b667907f9d77817912dda6e71d0b55b9cf76adb0cc35d3d99` |

The original M-series rows remain **expected falsifiers**, except M25's
executed creator regression above. The later independent X-series campaign
on 964eb1a met its 26-row and blocking-atom floor, with the three advisory
survivors now addressed by NOTE-004; its report is retained in the runtime. `Corpus.mutantCorpus` supplies inputs and one
named source edit per row. Some edits deliberately cover several obligations;
M08/M19 and M18/M20 share an edit while targeting different claims. Multi-input
rows carry suffixes, e.g. `M07-small` and `M07`, rather than hiding a comparison.
The corpus is a finite witness set, not a universal proof.

## Semantic atoms

Each guard, effect, refusal and recursive composition point of authorization and
splitting is listed separately. Coverage is a creator claim for audit.

| Atom | Kind and meaning | Owning definition / branch | Statements and witnesses | Expected mutation |
|---|---|---|---|---|
| A01 | Identity binds the entire immutable ordered description and oracle role | identity, Identity | T01; W01 | M01 constant description |
| A02 | No script-credential oracle constructor | Description.key/group | Structural boundary; parser refuses unknown kind | Add a third authorization constructor, outside admitted grammar |
| A03 | Group threshold is positive; empty groups cannot authorize publicly | shapeValid.group lower bound | T03/T04; W04 empty | M04 |
| A04 | Threshold cannot exceed direct member count | shapeValid.group upper bound | T04; W04 high | Remove upper bound |
| A05 | Every member share is strictly positive | membersValid.cons | T03/T04; W03 zero share | Drop positive-share test |
| A06 | Every nested group has valid threshold and shares | membersValid recursive calls | T04; W04 nested | Skip child shapeValid |
| A07 | Every key occurs once in the whole description, including overlap between branches | valid, keys/memberKeys | T18/T19/T20; W18/W19/W20 | M18/M20 |
| A08 | Public authorization checks the expected identity | authorize conjunction | T02/T21; W02 mismatch | M02 |
| A09 | Public authorization rejects all invalid descriptions | authorize conjunction | T03/T21; W03 | M03 |
| A10 | Key authorizes iff its key belongs to the actual signers, and returns exactly its key leaf | record.key | T05/T15/T25; W05/W25 | M05/M15/M25 |
| A11 | Group counts recursively authorizing member oracles, not shares or raw leaf signatures | record.group, signedMembers | T06/T08/T19; W06/W08/W19 | M06/M08/M19 |
| A12 | Authorization uses at least the threshold, and remains true when more sign | record.group comparison | T06/T07/T08; W07 | M07 exact threshold |
| A13 | Failed member is omitted from the record | signedMembers.none | T12/T13/T14; W12/W13 | M12 |
| A14 | Every successful member is retained exactly once | signedMembers.some | T14/T16; W14/W16 | M14/M16 |
| A15 | Record preserves description order, declared shares and recursive child records | signedMembers.cons, record.group | T14/T15; W14/W15 | Swap order, share or child; M14/M15 |
| A16 | Signing record is deterministic; signer order/duplicates grant no extra power | record.key membership and ordered traversal | T07/T23; W19/W23 | M23 |
| A17 | Signed shares alone form the denominator at each level | portions, splitRecorded.group | T17; W17 | Include an unsigned share or M17 equal division |
| A18 | Each signed member starts with floor(fee * share / signed-share-sum) | portions.base | T17; W17 unequal shares | M17 |
| A19 | Entire leftover fee goes to the first signed member, including zero-fee case | portions first/rest | T11/T17/T24; W11/W17/W24 | M11 or redirect remainder to last |
| A20 | Each group allocation is recursively split into that member's keys | splitRecorded.group, splitMembers.cons | T11/T13/T17/T24; W13/W17/W24 | Pass wrong amount or discard child split |
| A21 | Key leaf pays its whole allocation to that key | splitRecorded.key | T09/T10/T15; W09/W10 | M10 or replace recipient |
| A22 | No balance or payout target exists for a group | Payment.key, recursive leaf outputs | T10/T13/T17; W13/W17 | Emit a fabricated group-recipient leaf |
| A23 | Keys of a failed subgroup at any finite depth receive no root allocation even if they individually signed | signedMembers.none and split traversal; atPath addresses the original description | T13/T26; W13/W26 | M13/M26 |
| A24 | Public split succeeds only on an actual authorization record and otherwise refuses | splitFee Option.map | T03/T22/T24; W03/W22/W24 | M22/M24 |
| A25 | Record replay uses only retained members and shares at the supplied credit-time fee | splitRecorded | T17/T24; W24 | Recompute from different signers or M24 |
| A26 | Public successful splits conserve natural-valued fees exactly, with no fee limit or positivity precondition | splitFee, totalPaid | T11/T24; W11/W24 | M11/M24 |
| A27 | No separate member consent or registration guard; a silent key is absent from signers | Description constructors, record.key | T05/T06; W05/W06/W12 | Add a consent/registration predicate |

`splitMembers` also has total helper branches for empty member or allocation
lists. `portions` preserves the list length, so a canonical group never reaches
an allocation-length mismatch. Arbitrary forged/empty signing records have no
conservation guarantee: only records returned by `authorize` have it. No public
split accepts an unchecked record. A consumer replaying `splitRecorded` must
supply a record previously authenticated and bound to its judgment; modeling that
binding is deliberately deferred to #127.

The inversion inventory is T04 (valid group), T05 (key authority), T06 (group
authority), T14 (exact record), T17 (exact group allocation), T21 (authorization
success), T22 (refusal), T25 (exact raw/public key result), plus T10/T24 for
leaf payout and recorded replay. T26 lifts unpaid-subgroup exclusion to arbitrary
depth through the explicit path vocabulary. No
inductive transition relation or separate Bool mirror is introduced:
`Authorizes` is definitionally the success observation of `authorize`.

## Executable surface and corpus

The pure law is `OracleIdentity.authorize` and `OracleIdentity.splitFee`.
Additional algebraic entry points are `identity`, `valid` and authenticated
`splitRecorded`; boundary observations are `recordedKeys`, `paidTo` and
`totalPaid`. All are computable. The qualified model declarations are bound by
`Model.lean` SHA256
`674e33ff3039a722c7ded9444cc7c9f56430d2e362da66b617ae458b343c0a94`.

`Surface.lean` supplies JSON codecs for descriptions, identities, records,
payments and scenarios, plus `OracleIdentity.runScenario`. The driver is
`lean/MpfsCage/OracleIdentity/Driver.lean`, invoked from `lean/` as:

```sh
nix develop ..#aiken --quiet -c lake env lean --run MpfsCage/OracleIdentity/Driver.lean
nix develop ..#aiken --quiet -c lake env lean --run MpfsCage/OracleIdentity/Driver.lean --corpus
```

The first form reads one JSON scenario from stdin and returns one JSON result;
parse errors, unknown surfaces and refused authorization exit 1. Wrong command
arguments exit 2. `valid` returns a Boolean normally, including `false`.
`splitFee` invokes the actual split operation without a duplicate authorization
guard that could mask a mutant. Record replay and payment observations require
a successful authorization and use exactly its returned record. There is no
per-theorem dispatch logic.

`Corpus.witnessCorpus` and `Corpus.mutantCorpus` are the machine-readable witness
and proposed-mutant ledgers, emitted as driver-accepted JSON lines by `--corpus`.
Each line carries its row id and optional named mutation, alongside the actual
operation inputs. The mutation text is metadata: the driver always evaluates the
model compiled into that invocation. It does not pretend to apply edits.

Codec/parser boundary checks cover unknown kinds, wrong identity roles, malformed
JSON, unknown operations and negative natural values. The total recursive JSON
parsers use serialized input length as fuel. Concrete roundtrips are checked over
the corpus; a universal serialization correspondence theorem is not claimed.

| File under `lean/MpfsCage/OracleIdentity/` | SHA256 |
|---|---|
| Model.lean | `674e33ff3039a722c7ded9444cc7c9f56430d2e362da66b617ae458b343c0a94` |
| Paths.lean | `8672468338c1fbde002bca4a2eefd3d6bb9d9f4ec2869576c244778b64c37974` |
| Statements.lean | `d196658f30f6dd86c6b8ebba7fb7ea50e7c427f8429c990a016e84357dcd9e52` |
| Witnesses.lean | `3d6b771f6d7560a848a0cfd1f2799598de87acc61d79b6906b1c61ee85f5fd84` |
| Surface.lean | `04a10b1fe4be21ae915d5362b5ef4b90d863cedf7e3e0ff72aabba0b429f9483` |
| Corpus.lean | `30c5ef0c1c507db05112d8a9634bec9ed777c73954bbf3843a778a2df7bc64b8` |
| Driver.lean | `0de321b7c833888fccb8fc12b2ca83d3cf6cfaa0aae0df5f17a79db47daa6329` |
| Proofs.lean | `5f9182b8283a8c4baa4590001536d10f414bae6c48e3e18d139317c6f1f4b4a0` |
| FeeProofs.lean | `453738253724da13a5bbbaa80997e1f0bdc6c4f668c565daacc1a5791c8a5246` |
| FormulaProofs.lean | `8998df77c6c9a3fd4774d9c99d788b11a8e9bdce232c633ffff862499b1dc6a4` |
| ExclusionProofs.lean | `0245f2dc2d4a8bfe1543abf1e739b337db3c27f8a7c38ab15de851c1bddebe4d` |
| CountingProofs.lean | `e5824cfcbce5e65fd01392f37bb775cce93427ec2b7f3390c3c257b1e8cd5df9` |
| ObservationSpec.lean | `523aec9f03631e840cd37a9612653a81d75ca9171d14bef58f15538ccf572c9a` |
| ObservationProofs.lean | `285755fb0e1938d181a0f240806c7d4fd0583159342157cbfd90fa50f930cdfb` |

## Proof structure

- `Proofs.lean` proves the exact group-validity domain, authorization inversion,
  canonical member list/count, monotonicity and signer-set extensionality.
  Recorded keys form a sublist of description keys and belong to the signers.
- `FeeProofs.lean` introduces proof-only `RecordSound`/`SignedSound` predicates.
  Records returned from shape-valid descriptions have nonempty groups and
  positive retained shares. The sum of floor allocations is at most the fee;
  the first-member remainder makes it exact. Structural recursion then proves
  conservation down to key payments, for every natural fee including zero.
- `FormulaProofs.lean` proves the literal indexed allocation formula for arbitrary
  records, separately from the sound-record conservation precondition.
- `ExclusionProofs.lean` uses global uniqueness to separate sibling key domains.
  Induction on the original-description path excludes keys in a failed subgroup
  at every finite depth. Every payment key must occur in the retained record.
- `CountingProofs.lean` relates member occurrences to key multiplicity and
  retained member counts to nonempty recorded-key sets. A sublist/filter
  argument gives the lower bound on distinct signing keys.

These helpers do not change any executable model definition or accepted type.
The actual `record`, `signedMembers`, `portions`, `splitRecorded`,
`splitMembers`, `authorize` and `splitFee` definitions remain the law used
by the proofs; there is no replacement executable model.

## Prior proof verification at 964eb1a

The following receipts describe the prior 26-theorem proof commit, not this
observation repair. Evidence is under
`/code/mpfs-onchain-lean-126-20261028/astra-identities-model/evidence/proofs/`.
The prescribed command `cd lean && nix develop ..#aiken --quiet -c lake build`
passes from a deleted, absent `.lake`: **28 jobs**, exit 0, no warnings from
Lean and no admissions. The supplied Nix toolchain is Lean 4.29.0; the existing
`lean-toolchain` file was not changed. `clean-build-start.json` and
`clean-build.log` record the clean start and result. `failure-notes.md`
retains the distinction between setup failures and the successful clean run.

`Axioms.lean`, `axioms.log` and `axiom-inventory.json` cover all 26 public
theorems and W01-W26, with only `propext`, `Classical.choice` and
`Quot.sound` allowed. No `sorryAx` or extra axioms occur. The OracleIdentity
source scope contains zero `sorry`/`admit` tokens. W01-W26 are unchanged
and still import only Paths and Model, independently of Statements.
`check-freeze.cjs` re-extracts the 26 accepted signatures from `82bbfcc`,
checks the pre-edit manifest and final source, and verifies Model, Paths,
Witnesses, Surface, Corpus and Driver are byte-identical to that commit.
The current elaborated types are also printed for inspection, but the source
signatures are the selected freeze representation authorized by NOTE-003.

The previous repair evidence remains at `evidence/repair-001/`: 67 corpus
inputs, 14 expected authorization refusals, six rejection controls and 67 codec
roundtrips. Those executable files are unchanged; this proof phase did not
rerun or expand that replay or mutation campaign. The M25 creator regression
is preserved. Other named mutants remain expected falsifiers, not executed
proof-phase findings.

The exact local commit, Git tree and evidence hashes are bound by
`evidence/proofs/receipt.json` and `handoffs/proofs.md` in the runtime.
All prior 26 semantic outcomes are PROVED; none is REFUTED or OPEN. The
independent proof/adequacy assessment subsequently returned PASS with the three
advisory survivors now addressed by NOTE-004. Cryptographic encoding
correspondence, deployed validator conformance, costs, ledger-bound record
authenticity, balances, withdrawals and registry integration remain outside
this result. Nothing is pushed by this worker.
