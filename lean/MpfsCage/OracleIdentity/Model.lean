import Lean

/-!
Oracle identity algebra, independent of any consuming registry.
Authority: specs/oracle-identity/decisions.md and A-001-description-domain.
Keys stand for authenticated transaction signer hashes. Structured names stand
for role-led, collision-free hashes; this is not a cryptographic hash proof.
A consuming contract must retain and authenticate the returned signing record
with its judgment. That ledger binding, balances, withdrawals, price notices,
encoding, costs and registry integration are outside this algebra.
-/
namespace OracleIdentity

abbrev Key := String
abbrev Signers := List Key

mutual
inductive Description where
  | key (key : Key)
  | group (threshold : Nat) (members : Members)
  deriving Repr, DecidableEq
/-- An ordered list of oracle/share pairs, mutually inductive so the entire
    algebra has structural recursion and computable equality. -/
inductive Members where
  | nil
  | cons (oracle : Description) (share : Nat) (rest : Members)
  deriving Repr, DecidableEq
end

def Members.toList : Members → List (Description × Nat)
  | .nil => []
  | .cons d share rest => (d, share) :: rest.toList

def Members.ofList : List (Description × Nat) → Members
  | [] => .nil
  | (d, share) :: rest => .cons d share (ofList rest)

inductive Role where
  | oracle
  deriving Repr, DecidableEq

structure Identity where
  role : Role
  description : Description
  deriving Repr, DecidableEq

def identity (d : Description) : Identity := ⟨.oracle, d⟩

mutual
def keys : Description → List Key
  | .key k => [k]
  | .group _ members => memberKeys members
def memberKeys : Members → List Key
  | .nil => []
  | .cons d _ rest => keys d ++ memberKeys rest
end

mutual
def shapeValid : Description → Bool
  | .key _ => true
  | .group threshold members =>
      decide (0 < threshold ∧ threshold ≤ members.toList.length) && membersValid members
def membersValid : Members → Bool
  | .nil => true
  | .cons d share rest => decide (0 < share) && shapeValid d && membersValid rest
end

/-- Uniqueness is global within this one description, including nested groups. -/
def valid (d : Description) : Bool := shapeValid d && decide (keys d).Nodup

mutual
/-- Only authorizing branches are retained, with the original order and shares. -/
inductive SigningRecord where
  | key (key : Key)
  | group (members : SignedMembers)
  deriving Repr, DecidableEq
inductive SignedMembers where
  | nil
  | cons (share : Nat) (record : SigningRecord) (rest : SignedMembers)
  deriving Repr, DecidableEq
end

def SignedMembers.toList : SignedMembers → List (Nat × SigningRecord)
  | .nil => []
  | .cons share r rest => (share, r) :: rest.toList

mutual
def record (d : Description) (signers : Signers) : Option SigningRecord :=
  match d with
  | .key k => if k ∈ signers then some (.key k) else none
  | .group threshold members =>
      let signed := signedMembers members signers
      if threshold ≤ signed.toList.length then some (.group signed) else none
/-- Keep every recursively authorizing member; there is no subset input. -/
def signedMembers (members : Members) (signers : Signers) : SignedMembers :=
  match members with
  | .nil => .nil
  | .cons d share rest =>
      match record d signers with
      | none => signedMembers rest signers
      | some r => .cons share r (signedMembers rest signers)
end

def authorizingCount (members : Members) (signers : Signers) : Nat :=
  ((members.toList).filter fun m => (record m.1 signers).isSome).length

/-- The single public authorization operation checks the supplied description
    against the named identity and rejects every invalid description. -/
def authorize (expected : Identity) (d : Description) (signers : Signers) :
    Option SigningRecord :=
  if identity d = expected ∧ valid d = true then record d signers else none

def Authorizes (d : Description) (signers : Signers) : Prop :=
  (authorize (identity d) d signers).isSome = true

instance (d : Description) (signers : Signers) : Decidable (Authorizes d signers) :=
  inferInstanceAs (Decidable ((authorize (identity d) d signers).isSome = true))

structure Payment where
  key : Key
  amount : Nat
  deriving Repr, DecidableEq, Lean.ToJson, Lean.FromJson

/-- Floor each signed member's proportional share, then give the entire
    unallocated integer remainder to the first signed member. -/
def portions (fee : Nat) (shares : List Nat) : List Nat :=
  let base := shares.map fun share => fee * share / shares.sum
  match base with
  | [] => []
  | first :: rest => (first + (fee - base.sum)) :: rest

mutual
/-- Replay an authenticated record when the fee is credited. On arbitrary
    forged or empty records this internal operation makes no conservation claim. -/
def splitRecorded : SigningRecord → Nat → List Payment
  | .key k, fee => [⟨k, fee⟩]
  | .group members, fee =>
      splitMembers members (portions fee (members.toList.map Prod.fst))
def splitMembers : SignedMembers → List Nat → List Payment
  | .nil, _ => []
  | .cons _ r rest, amount :: amounts => splitRecorded r amount ++ splitMembers rest amounts
  | .cons _ _ _, [] => []
end

/-- Public end-to-end split: refuse unless authorization produced the record. -/
def splitFee (expected : Identity) (d : Description) (signers : Signers) (fee : Nat) :
    Option (List Payment) :=
  (authorize expected d signers).map fun r => splitRecorded r fee

def paidTo (payments : List Payment) (key : Key) : Nat :=
  ((payments.filter fun p => p.key = key).map Payment.amount).sum

def totalPaid (payments : List Payment) : Nat := (payments.map Payment.amount).sum

mutual
def recordedKeys : SigningRecord → List Key
  | .key k => [k]
  | .group members => signedKeys members
def signedKeys : SignedMembers → List Key
  | .nil => []
  | .cons _ r rest => recordedKeys r ++ signedKeys rest
end

/-- Distinct keys belonging to this description that actually signed. -/
def signingKeys (d : Description) (signers : Signers) : List Key :=
  ((keys d).filter fun k => k ∈ signers).eraseDups

end OracleIdentity
