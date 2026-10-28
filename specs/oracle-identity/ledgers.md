# Candidate theorem and semantic-atom ledgers

This is the **STATEMENT REPAIR CANDIDATE** for #126 after NOTE-001 on
`6333c158`. All 26 guarantees below have intentional `sorry` proofs; none is
claimed proved or independently accepted. The 26 concrete witnesses import only
the model and admission-free path vocabulary and have kernel-checked proofs. PROOFS starts only after the parent accepts the independent
statement audit. Registry integration and judgment binding belong to #127.
**Price notices are excluded from #126:** they are tied to registry pricing and
belong to #127.

## Repair scope and mutation result

The independent audit of 6333c158 was NOT-READY: the prior statements allowed a
key record to be replaced by an invented singleton group while preserving key
membership and fee behavior. NOTE-001 commissions this repair. The existing
T01-T24 declarations are byte-identical, including their proof holes, and
Model.lean is unchanged. T25 fixes both raw and public key records exactly;
its raw-record equality applies at every recursive key call, while T14 binds
retained group members to those records. T26 covers failed subgroups at every
finite member-index path. No theorem proofs have started.

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

This is a creator regression result showing M25 is killed by T25, not an
independent audit or a proof of T25 on the healthy model. Failed elaborations may
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

The entire statement candidate file is bound by SHA256
`42a491ae5424fc78710d93819ce28ffd92172cf2c40b723bb9fa4e08e426f9b9`.
This is a candidate digest for the audit, **not** an accepted statement freeze.
It binds all 26 types and their intentional proof holes together.

| Row | Theorem | Obligation | Reachable witness | Named single-atom mutant expected to falsify it | Outcome |
|---|---|---|---|---|---|
| T01 | identity_injective | Equal names imply equal complete descriptions | W01, valid nested description | M01: replace the bound description by one constant key; demo and Bob collide | OPEN |
| T02 | authorization_binds_identity | Success binds the actual supplied description to the expected name | W02 success and mismatched-name refusal | M02: omit the identity equality guard | OPEN |
| T03 | invalid_description_refused | Invalid descriptions refuse both authorization and splitting | W03 zero share, including actual split refusal | M03: omit validity from authorize | OPEN |
| T04 | group_valid_iff | Exact lower/upper threshold, positive shares, nested validity and global key uniqueness | W04 valid nested group, zero threshold, excessive threshold, zero share | M04: omit the positive-threshold guard; empty zero-threshold group becomes valid | OPEN |
| T05 | key_authorizes_iff | A key authorizes exactly when it signs | W05 present and absent key | M05: return a key record without checking signer membership | OPEN |
| T06 | group_authorizes_iff | Validity and at least the threshold of recursively authorizing members | W06, two members authorize a threshold-two group | M06: count signed shares instead of signed members; Alice alone has share two | OPEN |
| T07 | authorization_monotone | Adding signers cannot revoke authorization | W07, Alice/Carol followed by Alice/Carol/Dave | M07: require exact equality to the threshold; the inner group stops authorizing when Dave joins | OPEN |
| T08 | below_threshold_refused | Too few authorizing members cannot authorize a group | W08, two keys inside just one direct member | M08: lower the threshold by one; a flat threshold-two group accepts Alice alone | OPEN |
| T09 | key_is_single_member_case | A positive-share singleton group has the key's authorization and complete payout behavior | W09, singleton share seven and fee eleven | M09: pass fee minus one to group splitting | OPEN |
| T10 | key_receives_whole_fee | A signing key receives exactly the entire fee | W10, fee eleven | M10: pay fee minus one at a key leaf | OPEN |
| T11 | split_conserves_fee | Every successful public split pays exactly its input fee | W11, nested split pays 8 + 2 + 1 = 11 | M11: discard the integer remainder | OPEN |
| T12 | unsigned_key_receives_nothing | No payment to a key absent from the signers | W12, Bob absent and unpaid | M12: retain a fabricated Bob leaf when a member does not authorize | OPEN |
| T13 | nonauthorizing_member_receives_nothing | Every key of a failed direct member receives zero, even when that key signed | W13, Carol signs but her threshold-two subgroup fails | M13: append a one-unit Carol payment at a group split | OPEN |
| T14 | group_record_exact | Record exactly all authorizing members, with their shares and order | W14, all three direct members authorize a threshold-two group | M14: return an empty group record after the threshold check | OPEN |
| T15 | recorded_keys_are_signers | Every recorded key signed and belongs to the actual description | W15, nested recorded keys | M15: substitute an attacker key in the key record | OPEN |
| T16 | record_keys_unique | A successful canonical record never repeats a key | W16, nested record with distinct leaves | M16: duplicate a retained member in signedMembers | OPEN |
| T17 | group_split_exact | Literal proportional floor formula and entire remainder to index zero, recursively | W17, outer and inner remainders plus an unsigned leading member | M17: divide equally instead of using the signed shares | OPEN |
| T18 | key_contributes_to_at_most_one_member | On a valid group, each key belongs to at most one direct member | W18, Carol occurs only within the inner member | M18: omit global key uniqueness; duplicate nested Alice belongs to two members | OPEN |
| T19 | threshold_needs_distinct_signing_keys | Threshold m requires at least m distinct signing keys in the description | W19, duplicate Alice signer entries still give exactly two distinct keys | M19: lower the threshold by one; demo authorizes Alice alone | OPEN |
| T20 | repeated_key_invalid | A repeated key anywhere in the tree makes the description invalid | W20, Alice both direct and nested | M20: omit global key uniqueness | OPEN |
| T21 | authorization_inversion | Success iff name, validity and actual canonical record all match | W21, actual successful canonical record | M21: substitute a fabricated record on success | OPEN |
| T22 | split_refusal_iff | Splitting refuses exactly when authorization refuses | W22, no signers | M22: return some empty payments on authorization refusal | OPEN |
| T23 | signer_set_extensional | Order and multiplicity of signer entries do not change authorization or its record | W23, reordered Alice/Carol signers | M23: check only the first signer for a key oracle | OPEN |
| T24 | recorded_split_replay | Any successful record replays at any later natural fee, agrees with the public split and conserves that fee | W24, one record replayed at fees 0, 11 and 17 | M24: public split replays with fee plus one | OPEN |
| T25 | key_record_exact | A key raw record and public authorization return exactly its key leaf when signed, and none otherwise, at every recursive key call | W25, key present/absent and the nested demo record | M25: replace every key record by a singleton group of share one; kernel refutation and both-way controls pass | OPEN |
| T26 | nonauthorizing_subgroup_at_any_depth_receives_nothing | Every key in a subgroup below threshold receives zero from a successful root split, at any finite original-description path | W26, Carol signs in a failed subgroup at path [0, 1] | M26: append a one-unit Carol payout at a group split | OPEN |

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
| Statements.lean | `42a491ae5424fc78710d93819ce28ffd92172cf2c40b723bb9fa4e08e426f9b9` |
| Witnesses.lean | `a270c9311d2e5a57f7ec133bed25c92eba211e6d99682e0f70a58a8588ec35fa` |
| Surface.lean | `fbcb78e764c42008099dc4b3333d6a3809c75a3ba40bd1a43b28d0b631132162` |
| Corpus.lean | `22ac3e108f6a82187dc5fb66cefc58461e54ccfa0e67f856dd67ad1262f266cd` |
| Driver.lean | `0de321b7c833888fccb8fc12b2ca83d3cf6cfaa0aae0df5f17a79db47daa6329` |

## Verification and remaining work

Evidence is under
`/code/mpfs-onchain-lean-126-20261028/astra-identities-model/evidence/`.
The prescribed repair build passes with 23 jobs and exactly the 26 declared
theorem admissions. Each of W01-W26 was queried by `#print axioms`: only `propext` and
`Quot.sound` occur (some use no axioms); no witness depends on `sorryAx`.
`Witnesses.lean` imports only Paths and its Model dependency, never Statements. Captured codec/replay
failures are retained alongside repaired-run receipts;
`failure-notes.md` records setup and elaboration failures.

The 67 corpus inputs replay successfully (14 expected authorization refusals),
six rejection controls pass, and codec roundtrips pass for all 67 scenarios.
The repair receipt records corpus replay, codec checks, file hashes, preservation
of the existing statements, the exact M25 counterexample and commit binding.
The statement audit is reopened. Named mutations, including the M25 regression,
remain subject to independent audit. All 26 theorem proofs, cryptographic
encoding correspondence, deployed validator conformance, costs, ledger-bound
record authenticity, balances, withdrawals and registry integration remain
unestablished by this candidate. Nothing is pushed by this worker.
