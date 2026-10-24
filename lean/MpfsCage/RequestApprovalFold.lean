import MpfsCage.Lib

/-!
# MPFS Cage — Requests, Oracle Approvals and Permissionless Folds

Candidate model for removing the per-cage request validator, after the
Singular design in which the request lifecycle belongs to the application.

Three parties check three different things:

- the **requester** states what they want: one write (`set` or `unset`) and
  the conditions on the tree under which it may apply;
- the **oracle** states that the requester may ask for it: an off-chain
  authorization, independent of the tree, carried by an approval token with an
  expiry chosen by the oracle, because an off-chain judgment does not stay
  valid forever;
- the **folder**, anyone, shows that it applies to the tree now: the state
  validator checks every approval and every condition against the
  intermediate root while it applies the writes in order.

One request script per release serves every cage. It is the spending
validator of the request address and the minting policy of two kinds of
token:

- the **tag**, minted by the requester with the request, named after the cage
  so that the oracle finds its pending requests with one asset query;
- the **approval**, minted by the oracle into the request output, named after
  the cage, the request and the expiry.

Every request carries a **seed**, an output reference spent by the
transaction that creates it, so that no two requests in the chain's history
are equal and an approval, or an application signature covering the seed,
cannot be replayed onto a copy.

A request never waits on a clock: its owner may withdraw it at any time.
Withdrawing burns its tag and approval, so the approval dies with it.

The request pays for being judged: its datum declares an approval fee, and
the oracle takes at most that fee from the request's value when it first
approves it. Re-approving an expired approval takes nothing, so the oracle
cannot drain a request by approving it again and again. A request withdrawn
after its approval has therefore already paid the oracle for its work.
The requester also declares a minimum approval window: an approval must stay
live at least that long after the approving transaction, so the oracle cannot
take the fee for an approval that expires before anyone can fold it.

A requester may opt in to a paid refusal by declaring a refusal fee. Before
any approval, the oracle may then refuse: it burns the tag, takes at most that
fee and returns the rest to the refund address in an output whose datum
records the refused request and the oracle's reason. The record is what the
requester pays for. With a zero refusal fee there is no paid refusal, so an
oracle cannot target a requester by refusing.

## Premises

- **Proof soundness.** The tree is modelled by its content (`Trie`). The
  on-chain checks verify Merkle Patricia Forestry proofs against roots; this
  model assumes those proofs are sound and complete for the content the root
  commits to.
- **Name injectivity.** `tagName` and `approvalName` stand for hashes of
  canonical encodings. Their injectivity is an explicit premise of the
  theorems that need it, never a theorem.
- **Spent once.** An output reference is spent by at most one transaction in
  a ledger history (`SpentOnce`).
- **Time.** The fold reads the upper bound of its validity interval.

## Status

Statements only. Every theorem is `sorry` until the statements are reviewed.
-/

namespace RequestApprovalFold

abbrev Key := String
abbrev Val := String
abbrev Signer := String
abbrev Time := Int
abbrev OutputRef := String
abbrev Address := String

/-- The content a cage's root commits to. -/
def Trie := Key → Option Val

/-- A cage is identified by its state token: policy and asset name. -/
structure CageId where
  policy : PolicyId
  asset : AssetName
  deriving DecidableEq

/-- A condition on the tree, checked at the fold against the root reached
    when the request is applied. -/
inductive Condition where
  | absent (k : Key)
  | equals (k : Key) (v : Val)
  deriving DecidableEq

def Condition.holds (t : Trie) : Condition → Prop
  | .absent k => t k = none
  | .equals k v => t k = some v

/-- The one change a request asks for. A blind write is a request without
    conditions; compare-and-swap is a write with a condition on its own key. -/
inductive Write where
  | set (k : Key) (v : Val)
  | unset (k : Key)
  deriving DecidableEq

def Write.apply (t : Trie) : Write → Trie
  | .set k v => fun k' => if k' = k then some v else t k'
  | .unset k => fun k' => if k' = k then none else t k'

/-- A request, as held in its datum at the request address. -/
structure Request where
  cage : CageId
  owner : Signer
  seed : OutputRef
  write : Write
  conditions : List Condition
  /-- The most the requester pays the oracle for its judgment. -/
  approvalFee : Nat
  /-- The shortest time an approval must stay live after the approving
      transaction, so that a paid approval can actually be folded. -/
  minApprovalWindow : Nat
  /-- The most the requester pays for a refusal with a recorded reason;
      zero means the oracle cannot refuse for a fee. -/
  refusalFee : Nat
  /-- Where a refusal returns the request's value. -/
  refundAddress : Address
  deriving DecidableEq

/-- The tag's asset name: a hash of the tag role and the cage. -/
opaque tagName : CageId → AssetName

/-- The approval's asset name: a hash of the approval role, the cage, the
    request and the expiry. -/
opaque approvalName : CageId → Request → Time → AssetName

/-- Premise: distinct approvals have distinct names. -/
def ApprovalNameInjective : Prop :=
  ∀ c r e c' r' e',
    approvalName c r e = approvalName c' r' e' → c = c' ∧ r = r' ∧ e = e'

/-- Premise: a tag name never equals an approval name. -/
def RolesSeparated : Prop :=
  ∀ c c' r e, tagName c ≠ approvalName c' r e

/-- The part of the cage state the protocol reads. -/
structure CageState where
  id : CageId
  oracle : Signer
  trie : Trie

/-- A request output: its request, the tags it holds, and the approval it
    carries, if any, with that approval's expiry. -/
structure RequestOutput where
  request : Request
  lovelace : Int
  tags : List AssetName
  approval : Option (AssetName × Time)

/-! ## Creating a request -/

/-- The transaction creating a request: it spends `spent`, reads the cage
    state by reference and mints one tag into the new request output. -/
structure CreateTx where
  spent : List OutputRef
  cageRef : CageState
  minted : List AssetName
  output : RequestOutput

def createAllowed (tx : CreateTx) : Prop :=
  tx.output.request.seed ∈ tx.spent ∧
  tx.cageRef.id = tx.output.request.cage ∧
  tx.minted = [tagName tx.output.request.cage] ∧
  tx.output.tags = [tagName tx.output.request.cage] ∧
  tx.output.approval = none

/-- Premise over a ledger history: no output reference is spent by two
    distinct transactions. -/
def SpentOnce (history : List CreateTx) : Prop :=
  ∀ a b r, a ∈ history → b ∈ history →
    r ∈ a.spent → r ∈ b.spent → a = b

/-! ## Approving a request -/

/-- The oracle's approval: it spends the request output and recreates it
    unchanged except for the approval it mints into it. The cage state is a
    reference input. -/
structure ApproveTx where
  cageRef : CageState
  input : RequestOutput
  output : RequestOutput
  expiry : Time
  validUntil : Time
  minted : List AssetName
  burned : List AssetName
  signers : List Signer

def approveAllowed (tx : ApproveTx) : Prop :=
  tx.cageRef.id = tx.input.request.cage ∧
  tx.cageRef.oracle ∈ tx.signers ∧
  tx.validUntil + tx.input.request.minApprovalWindow ≤ tx.expiry ∧
  tx.output.request = tx.input.request ∧
  tx.output.tags = tx.input.tags ∧
  tx.minted = [approvalName tx.cageRef.id tx.input.request tx.expiry] ∧
  tx.output.approval =
    some (approvalName tx.cageRef.id tx.input.request tx.expiry, tx.expiry) ∧
  -- a previous approval, expired or not, is replaced and burned
  tx.burned = (tx.input.approval.map Prod.fst).toList ∧
  -- the fee is taken once, at the first approval, and never above the
  -- declared fee
  (match tx.input.approval with
   | none =>
       tx.input.lovelace - tx.input.request.approvalFee ≤ tx.output.lovelace
   | some _ => tx.input.lovelace ≤ tx.output.lovelace) ∧
  tx.output.lovelace ≤ tx.input.lovelace

/-- A sequence of approvals of one request: the first approval and any
    number of re-approvals. -/
inductive ApprovalChain : RequestOutput → RequestOutput → Prop where
  | refl (o : RequestOutput) : ApprovalChain o o
  | step (tx : ApproveTx) (o : RequestOutput) :
      approveAllowed tx →
      ApprovalChain tx.output o →
      ApprovalChain tx.input o

/-! ## Folding -/

/-- The checks the state validator makes for one consumed request output,
    against the root reached so far. -/
def stepValid (cage : CageState) (validUntil : Time) (t : Trie)
    (o : RequestOutput) : Prop :=
  o.request.cage = cage.id ∧
  (∃ e, o.approval = some (approvalName cage.id o.request e, e) ∧
    validUntil ≤ e) ∧
  ∀ c ∈ o.request.conditions, c.holds t

/-- Applying the consumed requests in order, each checked against the
    intermediate tree. -/
inductive FoldRun (cage : CageState) (validUntil : Time) :
    Trie → List RequestOutput → Trie → Prop where
  | nil (t : Trie) : FoldRun cage validUntil t [] t
  | cons (t : Trie) (o : RequestOutput) (os : List RequestOutput)
      (t' : Trie) :
      stepValid cage validUntil t o →
      FoldRun cage validUntil (o.request.write.apply t) os t' →
      FoldRun cage validUntil t (o :: os) t'

/-- The tokens a fold must burn: every tag and approval of every consumed
    request. -/
def tokensOf (o : RequestOutput) : List AssetName :=
  o.tags ++ (o.approval.map Prod.fst).toList

/-- A fold transaction. `signers` is part of the transaction and is
    deliberately not read by `foldAccepted`. -/
structure FoldTx where
  cageIn : CageState
  requests : List RequestOutput
  cageOut : CageState
  validUntil : Time
  burned : List AssetName
  signers : List Signer

def foldAccepted (tx : FoldTx) : Prop :=
  tx.cageOut.id = tx.cageIn.id ∧
  tx.cageOut.oracle = tx.cageIn.oracle ∧
  tx.burned = tx.requests.flatMap tokensOf ∧
  FoldRun tx.cageIn tx.validUntil tx.cageIn.trie tx.requests tx.cageOut.trie

/-- The tree after applying a list of writes, unchecked. -/
def applyAll (t : Trie) : List Write → Trie
  | [] => t
  | w :: ws => applyAll (w.apply t) ws

/-! ## Spending a request output -/

/-- The owner's withdrawal, at any time; tag and approval are burned. -/
def withdrawAllowed (o : RequestOutput) (signers : List Signer)
    (burned : List AssetName) : Prop :=
  o.request.owner ∈ signers ∧ burned = tokensOf o

/-- The record a paid refusal delivers to the requester: the exact request
    refused and the oracle's reason. -/
structure RefusalRecord where
  request : Request
  reason : String

/-- The oracle's paid refusal: it consumes an unapproved request, burns its
    tag, takes at most the declared refusal fee and returns the rest to the
    refund address in an output whose datum is the refusal record. -/
structure RefuseTx where
  cageRef : CageState
  input : RequestOutput
  refundTo : Address
  refundLovelace : Int
  record : RefusalRecord
  burned : List AssetName
  signers : List Signer

def refuseAllowed (tx : RefuseTx) : Prop :=
  tx.cageRef.id = tx.input.request.cage ∧
  tx.cageRef.oracle ∈ tx.signers ∧
  0 < tx.input.request.refusalFee ∧
  tx.input.approval = none ∧
  tx.burned = tokensOf tx.input ∧
  tx.refundTo = tx.input.request.refundAddress ∧
  tx.input.lovelace - tx.input.request.refusalFee ≤ tx.refundLovelace ∧
  tx.record.request = tx.input.request

/-- How a request output may be spent. -/
inductive RequestSpend where
  | folded (tx : FoldTx)
  | approved (tx : ApproveTx)
  | refused (tx : RefuseTx)
  | withdrawn (signers : List Signer) (burned : List AssetName)

def requestSpendAllowed (o : RequestOutput) : RequestSpend → Prop
  | .folded tx => foldAccepted tx ∧ o ∈ tx.requests
  | .approved tx => approveAllowed tx ∧ tx.input = o
  | .refused tx => refuseAllowed tx ∧ tx.input = o
  | .withdrawn signers burned => withdrawAllowed o signers burned

/-! ## Theorems: creation and replay -/

/-- A new request names an existing cage, holds exactly that cage's tag and
    no approval, and its seed is spent by the creating transaction. -/
theorem create_tags_existing_cage (tx : CreateTx) :
    createAllowed tx →
    tx.cageRef.id = tx.output.request.cage ∧
    tx.output.tags = [tagName tx.output.request.cage] ∧
    tx.output.approval = none ∧
    tx.output.request.seed ∈ tx.spent := by
  sorry

/-- Two distinct creations in one ledger history create distinct requests. -/
theorem requests_unique_in_history (history : List CreateTx)
    (a b : CreateTx) :
    SpentOnce history → a ∈ history → b ∈ history →
    createAllowed a → createAllowed b → a ≠ b →
    a.output.request ≠ b.output.request := by
  sorry

/-- An approval minted for one request cannot be folded for another, even a
    copy that differs only in its seed. -/
theorem approval_not_replayable (hinj : ApprovalNameInjective)
    (cage : CageState) (validUntil : Time) (t : Trie)
    (o : RequestOutput) (r : Request) (e : Time) :
    o.approval = some (approvalName cage.id r e, e) →
    stepValid cage validUntil t o →
    o.request = r := by
  sorry

/-! ## Theorems: approval -/

/-- Every approval stays live for at least the requester's window after the
    approving transaction: a fold valid until any time in that window
    accepts it, as far as its expiry is concerned. -/
theorem approval_live_for_window (tx : ApproveTx) (t : Time) :
    approveAllowed tx →
    t ≤ tx.validUntil + tx.input.request.minApprovalWindow →
    ∃ e, tx.output.approval =
      some (approvalName tx.cageRef.id tx.input.request e, e) ∧ t ≤ e := by
  sorry

/-- Over any number of approvals, the oracle takes from a request at most its
    declared approval fee. -/
theorem approval_fee_paid_once (o o' : RequestOutput) :
    o.approval = none → ApprovalChain o o' →
    o.lovelace - o.request.approvalFee ≤ o'.lovelace := by
  sorry

/-- An approval is minted only with the signature of the oracle of the cage
    its request names, and leaves the request and its tags unchanged. -/
theorem approval_requires_cage_oracle (tx : ApproveTx) :
    approveAllowed tx →
    tx.cageRef.oracle ∈ tx.signers ∧
    tx.cageRef.id = tx.input.request.cage ∧
    tx.output.request = tx.input.request ∧
    tx.output.tags = tx.input.tags := by
  sorry

/-- An approval minted for one cage cannot be consumed by a fold of another
    cage. -/
theorem approval_bound_to_cage
    (hinj : ApprovalNameInjective) (atx : ApproveTx) (ftx : FoldTx)
    (o : RequestOutput) :
    approveAllowed atx → foldAccepted ftx → o ∈ ftx.requests →
    o.approval = atx.output.approval →
    ftx.cageIn.id = atx.cageRef.id ∧ o.request = atx.input.request := by
  sorry

/-! ## Theorems: folds -/

/-- Every folded request belongs to this cage and carries a live approval
    named for this cage and this request. -/
theorem fold_only_cage_approved (tx : FoldTx) :
    foldAccepted tx → ∀ o ∈ tx.requests,
      o.request.cage = tx.cageIn.id ∧
      ∃ e, o.approval = some (approvalName tx.cageIn.id o.request e, e) ∧
        tx.validUntil ≤ e := by
  sorry

/-- Every condition of every folded request held on the tree reached just
    before that request was applied. -/
theorem fold_conditions_hold_when_applied (tx : FoldTx) :
    foldAccepted tx → ∀ (n : Nat) (o : RequestOutput),
      tx.requests[n]? = some o →
      ∀ c ∈ o.request.conditions,
        c.holds (applyAll tx.cageIn.trie
          ((tx.requests.take n).map (·.request.write))) := by
  sorry

/-- The tree moves only by the folded writes, in the folded order: there is
    no rejection and no other change. -/
theorem fold_root_is_folded_writes (tx : FoldTx) :
    foldAccepted tx →
    tx.cageOut.trie = applyAll tx.cageIn.trie
      (tx.requests.map (·.request.write)) := by
  sorry

/-- A fold burns every tag and approval of the requests it consumes. -/
theorem fold_burns_request_tokens (tx : FoldTx) :
    foldAccepted tx → ∀ o ∈ tx.requests, ∀ a ∈ tokensOf o, a ∈ tx.burned := by
  sorry

/-- A blind write with a live approval of this cage folds on any tree. -/
theorem blind_write_folds_on_any_tree
    (cage : CageState) (validUntil : Time) (o : RequestOutput) (t : Trie)
    (e : Time) :
    o.request.cage = cage.id →
    o.approval = some (approvalName cage.id o.request e, e) →
    validUntil ≤ e →
    o.request.conditions = [] →
    FoldRun cage validUntil t [o] (o.request.write.apply t) := by
  sorry

/-- Whether a fold is accepted does not depend on who submits it. -/
theorem fold_permissionless (tx : FoldTx) (others : List Signer) :
    foldAccepted tx → foldAccepted { tx with signers := others } := by
  sorry

/-- Two requests that both insert the same key into an absent slot never
    fold together unless a request between them unsets that key. -/
theorem absent_inserts_exclusive (tx : FoldTx) (a b : RequestOutput)
    (k : Key) (v w : Val) (n m : Nat) :
    foldAccepted tx → n < m →
    tx.requests[n]? = some a → tx.requests[m]? = some b →
    a.request.write = .set k v →
    b.request.write = .set k w →
    Condition.absent k ∈ b.request.conditions →
    (∀ p, n < p → p < m → ∀ q, tx.requests[p]? = some q →
      q.request.write ≠ .unset k) →
    False := by
  sorry

/-! ## Theorems: request outputs -/

/-- A request output is spent only by a fold that consumes it, an approval
    that recreates it, or its owner. -/
theorem request_spent_only_by_lifecycle (o : RequestOutput)
    (s : RequestSpend) :
    requestSpendAllowed o s →
    (∃ tx, s = .folded tx ∧ foldAccepted tx ∧ o ∈ tx.requests) ∨
    (∃ tx, s = .approved tx ∧ approveAllowed tx ∧ tx.input = o ∧
      tx.output.request = o.request) ∨
    (∃ tx, s = .refused tx ∧ refuseAllowed tx ∧ tx.input = o) ∨
    (∃ signers burned, s = .withdrawn signers burned ∧
      o.request.owner ∈ signers) := by
  sorry

/-- A requester who declares no refusal fee can never be refused for a fee. -/
theorem refusal_opt_in (tx : RefuseTx) :
    tx.input.request.refusalFee = 0 → ¬ refuseAllowed tx := by
  sorry

/-- A paid refusal is signed by the cage's oracle, happens only before any
    approval (so the requester never pays both fees), takes at most the
    declared refusal fee, returns the rest to the refund address and records
    exactly the refused request. -/
theorem refusal_pays_at_most_fee_and_records (tx : RefuseTx) :
    refuseAllowed tx →
    tx.cageRef.oracle ∈ tx.signers ∧
    tx.input.approval = none ∧
    tx.refundTo = tx.input.request.refundAddress ∧
    tx.input.lovelace - tx.input.request.refusalFee ≤ tx.refundLovelace ∧
    tx.record.request = tx.input.request := by
  sorry

/-- The owner can always withdraw, whatever approval the output carries. -/
theorem owner_withdraws_any_time (o : RequestOutput)
    (signers : List Signer) :
    o.request.owner ∈ signers →
    requestSpendAllowed o (.withdrawn signers (tokensOf o)) := by
  sorry

end RequestApprovalFold
