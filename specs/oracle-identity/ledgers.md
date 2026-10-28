# Oracle identity theorem and semantic-atom ledgers

This is the **PROOF CANDIDATE** for #126. All 26 accepted theorem statements
are **PROVED**, with zero admissions and only permitted standard axioms.
The parent accepted the independent statement audit of
`82bbfccfe4976f3a72a55a821bc2fd5a921b421a` in NOTE-002; NOTE-003 freezes
Model.lean byte-for-byte and the 26 theorem names and source types up to `:=`.
Those frozen bytes are unchanged. Proofs, proof-only helpers and this ledger are
the only changes. This creator result awaits independent proof assessment;
it is not self-acceptance, hosted CI or deployment evidence.
Registry integration and judgment binding belong to #127.
**Price notices are excluded from #126:** they are tied to registry pricing and
belong to #127.

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

The mutant rows are **expected falsifiers**, except M25's executed creator
regression above. There is no general mutation campaign or independent adequacy
verdict. `Corpus.mutantCorpus` supplies inputs and one
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
| Statements.lean | `d82b902494bb98c4083220a92f7efc268b99a10737ed75a9e3f31814a94b84c1` |
| Witnesses.lean | `a270c9311d2e5a57f7ec133bed25c92eba211e6d99682e0f70a58a8588ec35fa` |
| Surface.lean | `fbcb78e764c42008099dc4b3333d6a3809c75a3ba40bd1a43b28d0b631132162` |
| Corpus.lean | `22ac3e108f6a82187dc5fb66cefc58461e54ccfa0e67f856dd67ad1262f266cd` |
| Driver.lean | `0de321b7c833888fccb8fc12b2ca83d3cf6cfaa0aae0df5f17a79db47daa6329` |
| Proofs.lean | `5f9182b8283a8c4baa4590001536d10f414bae6c48e3e18d139317c6f1f4b4a0` |
| FeeProofs.lean | `453738253724da13a5bbbaa80997e1f0bdc6c4f668c565daacc1a5791c8a5246` |
| FormulaProofs.lean | `8998df77c6c9a3fd4774d9c99d788b11a8e9bdce232c633ffff862499b1dc6a4` |
| ExclusionProofs.lean | `0245f2dc2d4a8bfe1543abf1e739b337db3c27f8a7c38ab15de851c1bddebe4d` |
| CountingProofs.lean | `e5824cfcbce5e65fd01392f37bb775cce93427ec2b7f3390c3c257b1e8cd5df9` |

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

## Verification and remaining work

Evidence is under
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
All 26 semantic outcomes are PROVED; none is REFUTED or OPEN. Independent
proof/adequacy assessment remains parent-owned. Cryptographic encoding
correspondence, deployed validator conformance, costs, ledger-bound record
authenticity, balances, withdrawals and registry integration remain outside
this result. Nothing is pushed by this worker.
