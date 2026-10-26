import MpfsCage.Lib

/-!
# Permissionless registries: candidate semantic model

Authority: specs/request-approval-fold/decisions.md, with the parent's
A-001-model-boundaries ruling and A-002 time ruling of 25 October 2026. A registry has a fresh state
identity, a nonempty duplicate-free oracle list (representing a finite set),
and an immutable protocol hash. Distinct identities may share that metadata.
Time is a scalar: judgments/folds are strictly before the deadline and owner
withdrawals strictly after deadline + window. Complete accounts require
deadline ≤ now ≤ deadline + window. Equivocation is permitted. Fees are independent natural
amounts, fully escrowed at creation; allocations are per request and per role,
so coincident addresses do not reuse one payment for two obligations.

Creation places one oracle-named tag for every registry oracle into the
request output; every exit burns all these tags. Discovery is modeled as
filtering live request outputs by the queried tag, including across registries.
Arbitrary folder ordering has no auction or fairness guarantee. Protocol hashes
and evidence are opaque strings; no wire format or migration model. Names are
structured values with a leading role and the bound fields: this is a collision-free canonical-encoding abstraction,
not a cryptographic injectivity proof. Trie contents abstract sound forestry
proofs. Signatures, references, token ownership, fresh registry state tokens,
and scalar-time/validity-interval agreement are ledger boundary assumptions.
`spent` denotes protocol inputs; funding inputs and chain transaction fees
are outside the value account. In particular judgment minting spends no
request or cage input, not literally no fee-paying ledger input.

`Step` is the authoritative per-registry transition relation. Its state holds
live outputs, used seeds, and authentic minted judgments. `Reachable` starts
at registry creation; only `Step.fold` can change the cage. Cross-registry
seed uniqueness additionally uses the ledger-wide `SpentOnce` premise.
Structured name equality includes the complete request, hence its seed,
write, conditions, evidence, fees, deadline, window and owner.

D11 (one shared request-policy identity per release in spend and mint roles)
and D25 (enumerating approved work from the judgment record) remain explicit
omissions. Oracle discovery through request tags is now modeled; deployment
identity and folder discovery through judgment tokens remain outside the model.
Judgment lists count token occurrences: one burn erases one occurrence; the
permanent issued record retains every mint, including repeated verdicts.

Price notices are signed, nonbinding advertisements. A datum contains a
nonnegative default fee and optional per-protocol entries; these are advertised
values, never read by request, judgment or exit guards. Notice occurrences are
held in a list: no unique mint per oracle, canonical fee schedule, or oracle
liveness is asserted. Updates consume one held occurrence, preserve its oracle
and token, and require that oracle's signature. Notices may be published by any
oracle, independently of membership in the local registry. The per-registry
machine carries a notice observation alongside its protocol state; no global
UTxO model or cross-registry synchronization of price observations is claimed.
Payments are transaction allocations, not accumulated account balances: price
actions have no payment allocation and preserve all protocol state.

The executable oracle driver, JSON codecs and replay corpus are explicitly
outside this commission. This is a local model candidate, not implementation,
ledger, independent audit or acceptance evidence.
-/
namespace RequestApprovalFold

abbrev Key := String
abbrev Val := String
abbrev Signer := String
abbrev Time := Nat
abbrev OutputRef := String

def Trie := Key → Option Val
def emptyTrie : Trie := fun _ => none

structure CageId where
  policy : PolicyId
  asset : AssetName
  deriving DecidableEq, Repr

inductive Condition where
  | absent (key : Key)
  | equals (key : Key) (value : Val)
  deriving DecidableEq, Repr

def Condition.holds (t : Trie) : Condition → Prop
  | .absent k => t k = none
  | .equals k v => t k = some v

inductive Write where
  | set (key : Key) (value : Val)
  | unset (key : Key)
  deriving DecidableEq, Repr

def Write.apply (t : Trie) : Write → Trie
  | .set k v => fun k' => if k' = k then some v else t k'
  | .unset k => fun k' => if k' = k then none else t k'

def applyAll (t : Trie) : List Write → Trie
  | [] => t
  | w :: ws => applyAll (w.apply t) ws

structure CageState where
  id : CageId
  oracles : List Signer
  protocol : String
  trie : Trie

def RegistryValid (c : CageState) : Prop := c.oracles ≠ [] ∧ c.oracles.Nodup

def registryCreated (c : CageState) (existing : List CageId) : Prop :=
  c.id ∉ existing ∧ RegistryValid c ∧ c.trie = emptyTrie

structure Request where
  cage : CageId
  owner : Signer
  seed : OutputRef
  write : Write
  conditions : List Condition
  evidence : String
  fees : List (Signer × Nat)
  deadline : Time
  window : Nat
  deriving DecidableEq, Repr

def Request.fee (r : Request) (oracle : Signer) : Nat :=
  ((r.fees.find? (fun p => p.1 == oracle)).map Prod.snd).getD 0

/-- The first field of a name is its domain-separating role. -/
inductive TokenRole where
  | tag | approval | refusal | price
  deriving DecidableEq, Repr

inductive NameBinding where
  | oracle (signer : Signer)
  | judgment (cage : CageId) (request : Request) (oracle : Signer)
  deriving DecidableEq, Repr

structure TokenName where
  role : TokenRole
  binding : NameBinding
  deriving DecidableEq, Repr

def tokenName (role : TokenRole) (binding : NameBinding) : TokenName := ⟨role, binding⟩

def tagName (oracle : Signer) : TokenName := tokenName .tag (.oracle oracle)

def judgmentName (c : CageId) (r : Request) (o : Signer) (v : Bool) : TokenName :=
  tokenName (if v then .approval else .refusal) (.judgment c r o)

def priceName (oracle : Signer) : TokenName := tokenName .price (.oracle oracle)

structure RequestOutput where
  request : Request
  value : Nat
  tags : List TokenName
  deriving DecidableEq, Repr

def tokensOf (o : RequestOutput) := o.tags

def totalFees (c : CageState) (r : Request) : Nat :=
  (c.oracles.map r.fee).sum

def wellFormed (c : CageState) (o : RequestOutput) : Prop :=
  o.request.cage = c.id ∧ o.tags = c.oracles.map tagName ∧
  totalFees c o.request ≤ o.value

structure CreateTx where
  spent : List OutputRef
  cageRef : CageState
  minted : List TokenName
  outputs : List RequestOutput

def createAllowed (tx : CreateTx) (o : RequestOutput) : Prop :=
  o.request.seed ∈ tx.spent ∧ tx.outputs = [o] ∧
  tx.minted = tx.cageRef.oracles.map tagName ∧ wellFormed tx.cageRef o

def SpentOnce (history : List CreateTx) : Prop :=
  ∀ a b seed, a ∈ history → b ∈ history →
    seed ∈ a.spent → seed ∈ b.spent → a = b

structure JudgmentTx where
  cageRef : CageState
  requestRef : RequestOutput
  oracle : Signer
  approve : Bool
  now : Time
  signers : List Signer
  spent : List OutputRef
  minted : List TokenName

def judgmentAllowed (tx : JudgmentTx) : Prop :=
  tx.requestRef.request.cage = tx.cageRef.id ∧
  tx.oracle ∈ tx.cageRef.oracles ∧ tx.oracle ∈ tx.signers ∧
  tx.now < tx.requestRef.request.deadline ∧ tx.spent = [] ∧
  tx.minted = [judgmentName tx.cageRef.id tx.requestRef.request tx.oracle tx.approve]

def hasApproval (c : CageState) (r : Request) (refs : List TokenName)
    (signers : List Signer) : Prop :=
  ∀ oracle ∈ c.oracles,
    judgmentName c.id r oracle true ∈ refs ∨ oracle ∈ signers

def hasAccount (c : CageState) (r : Request) (refs : List TokenName) : Prop :=
  ∀ oracle ∈ c.oracles, ∃ verdict,
    judgmentName c.id r oracle verdict ∈ refs

def stepValid (c : CageState) (now : Time) (refs : List TokenName)
    (signers : List Signer) (t : Trie) (o : RequestOutput) : Prop :=
  wellFormed c o ∧ now < o.request.deadline ∧
  hasApproval c o.request refs signers ∧
  ∀ condition ∈ o.request.conditions, condition.holds t

inductive FoldRun (c : CageState) (now : Time) (refs : List TokenName)
    (signers : List Signer) : Trie → List RequestOutput → Trie → Prop where
  | nil (t : Trie) : FoldRun c now refs signers t [] t
  | cons (t : Trie) (o : RequestOutput) (os : List RequestOutput) (t' : Trie) :
      stepValid c now refs signers t o →
      FoldRun c now refs signers (o.request.write.apply t) os t' →
      FoldRun c now refs signers t (o :: os) t'

abbrev Payment := Signer × Nat

def oraclePayments (c : CageState) (r : Request) : List Payment :=
  c.oracles.map (fun oracle => (oracle, r.fee oracle))

structure Allocation where
  input : RequestOutput
  oracles : List Payment
  beneficiary : Signer
  remainder : Nat
  deriving DecidableEq, Repr

def allocation (c : CageState) (o : RequestOutput) (to : Signer) : Allocation :=
  ⟨o, oraclePayments c o.request, to, o.value - totalFees c o.request⟩

structure FoldTx where
  cageIn : CageState
  cageOut : CageState
  requests : List RequestOutput
  refs : List TokenName
  signers : List Signer
  now : Time
  folder : Signer
  submitter : Signer
  burned : List TokenName
  allocations : List Allocation

def foldAccepted (tx : FoldTx) : Prop :=
  tx.cageOut.id = tx.cageIn.id ∧ tx.cageOut.oracles = tx.cageIn.oracles ∧
  tx.cageOut.protocol = tx.cageIn.protocol ∧ tx.requests.Nodup ∧
  tx.burned = tx.requests.flatMap tokensOf ∧
  tx.allocations = tx.requests.map (fun o => allocation tx.cageIn o tx.folder) ∧
  FoldRun tx.cageIn tx.now tx.refs tx.signers tx.cageIn.trie tx.requests tx.cageOut.trie

structure AccountTx where
  cageRef : CageState
  input : RequestOutput
  refs : List TokenName
  now : Time
  submitter : Signer
  burned : List TokenName
  paid : Allocation

def accountAllowed (tx : AccountTx) : Prop :=
  wellFormed tx.cageRef tx.input ∧
  hasAccount tx.cageRef tx.input.request tx.refs ∧
  tx.burned = tokensOf tx.input ∧
  tx.paid = allocation tx.cageRef tx.input tx.input.request.owner ∧
  tx.input.request.deadline ≤ tx.now ∧
  tx.now ≤ tx.input.request.deadline + tx.input.request.window

structure WithdrawTx where
  input : RequestOutput
  now : Time
  signers : List Signer
  burned : List TokenName
  beneficiary : Signer
  paid : Nat

def withdrawAllowed (tx : WithdrawTx) : Prop :=
  tx.input.request.deadline + tx.input.request.window < tx.now ∧
  tx.input.request.owner ∈ tx.signers ∧ tx.burned = tokensOf tx.input ∧
  tx.beneficiary = tx.input.request.owner ∧ tx.paid = tx.input.value

inductive RequestSpend where
  | folded (tx : FoldTx)
  | accounted (tx : AccountTx)
  | withdrawn (tx : WithdrawTx)

def requestSpendAllowed (o : RequestOutput) : RequestSpend → Prop
  | .folded tx => foldAccepted tx ∧ o ∈ tx.requests
  | .accounted tx => accountAllowed tx ∧ tx.input = o
  | .withdrawn tx => withdrawAllowed tx ∧ tx.input = o

def RequestSpend.now : RequestSpend → Time
  | .folded tx => tx.now
  | .accounted tx => tx.now
  | .withdrawn tx => tx.now

def RequestSpend.burned : RequestSpend → List TokenName
  | .folded tx => tx.burned
  | .accounted tx => tx.burned
  | .withdrawn tx => tx.burned

def RequestSpend.pays (s : RequestSpend) (c : CageState)
    (o : RequestOutput) (oracle : Signer) : Prop :=
  match s with
  | .folded tx => c.id = tx.cageIn.id ∧
      ∃ a ∈ tx.allocations, a.input = o ∧ (oracle, o.request.fee oracle) ∈ a.oracles
  | .accounted tx => c.id = tx.cageRef.id ∧ tx.paid.input = o ∧
      (oracle, o.request.fee oracle) ∈ tx.paid.oracles
  | .withdrawn _ => False

def RequestSpend.cage : RequestSpend → Option CageState
  | .folded tx => some tx.cageIn
  | .accounted tx => some tx.cageRef
  | .withdrawn _ => none

def RequestSpend.evidence (s : RequestSpend) (r : Request) (oracle : Signer) : Prop :=
  match s with
  | .folded tx => judgmentName tx.cageIn.id r oracle true ∈ tx.refs ∨ oracle ∈ tx.signers
  | .accounted tx => ∃ verdict, judgmentName tx.cageRef.id r oracle verdict ∈ tx.refs
  | .withdrawn _ => False

def NonEquivocating (names : List TokenName) : Prop :=
  ∀ c r oracle, judgmentName c r oracle true ∈ names →
    judgmentName c r oracle false ∉ names

structure PriceDatum where
  fee : Nat
  perProtocol : List (String × Nat)
  deriving DecidableEq, Repr

structure PriceNotice where
  oracle : Signer
  token : TokenName
  datum : PriceDatum
  deriving DecidableEq, Repr

structure PriceMintTx where
  output : PriceNotice
  signers : List Signer
  minted : List TokenName

def priceMintAllowed (tx : PriceMintTx) : Prop :=
  tx.output.oracle ∈ tx.signers ∧
  tx.output.token = priceName tx.output.oracle ∧ tx.minted = [tx.output.token]

structure PriceUpdateTx where
  input : PriceNotice
  output : PriceNotice
  signers : List Signer
  minted : List TokenName

def priceUpdateAllowed (tx : PriceUpdateTx) : Prop :=
  tx.input.oracle ∈ tx.signers ∧
  tx.input.token = priceName tx.input.oracle ∧
  tx.output.oracle = tx.input.oracle ∧ tx.output.token = tx.input.token ∧
  tx.minted = []

structure State where
  cage : CageState
  usedSeeds : List OutputRef
  live : List RequestOutput
  judgments : List TokenName
  -- A permanent mint record: burning evidence does not erase equivocation.
  issued : List TokenName
  notices : List PriceNotice

def initial (c : CageState) : State := ⟨c, [], [], [], [], []⟩

def removeRequests (live spent : List RequestOutput) :=
  live.filter (fun o => o ∉ spent)

def afterCreate (s : State) (tx : CreateTx) (o : RequestOutput) : State :=
  { s with usedSeeds := tx.spent ++ s.usedSeeds, live := o :: s.live }

def afterJudgment (s : State) (tx : JudgmentTx) : State :=
  { s with judgments := tx.minted ++ s.judgments, issued := tx.minted ++ s.issued }

def afterFold (s : State) (tx : FoldTx) : State :=
  { s with cage := tx.cageOut, live := removeRequests s.live tx.requests }

def afterExit (s : State) (o : RequestOutput) : State :=
  { s with live := removeRequests s.live [o] }

def afterBurn (s : State) (name : TokenName) : State :=
  { s with judgments := s.judgments.erase name }

def afterPriceMint (s : State) (tx : PriceMintTx) : State :=
  { s with notices := tx.output :: s.notices }

def afterPriceUpdate (s : State) (tx : PriceUpdateTx) : State :=
  { s with notices := tx.output :: s.notices.erase tx.input }

/-- One asset query, independent of registry identity. -/
def discover (oracle : Signer) (outputs : List RequestOutput) : List RequestOutput :=
  outputs.filter (fun o => tagName oracle ∈ o.tags)

inductive Action where
  | create (tx : CreateTx) (output : RequestOutput)
  | judge (tx : JudgmentTx)
  | fold (tx : FoldTx)
  | account (tx : AccountTx)
  | withdraw (tx : WithdrawTx)
  | burn (name : TokenName)
  | priceMint (tx : PriceMintTx)
  | priceUpdate (tx : PriceUpdateTx)

def Action.spend : Action → Option RequestSpend
  | .fold tx => some (.folded tx)
  | .account tx => some (.accounted tx)
  | .withdraw tx => some (.withdrawn tx)
  | _ => none

/-- Observable protocol allocations; funding and chain fees remain external. -/
def Action.payments : Action → List Payment
  | .fold tx => tx.allocations.flatMap (fun a => a.oracles ++ [(a.beneficiary, a.remainder)])
  | .account tx => tx.paid.oracles ++ [(tx.paid.beneficiary, tx.paid.remainder)]
  | .withdraw tx => [(tx.beneficiary, tx.paid)]
  | _ => []

def Action.isPrice : Action → Bool
  | .priceMint _ | .priceUpdate _ => true
  | _ => false

/-- Protocol steps consume authenticated live/reference inputs. Funding and
    signatures are boundary observations, not generated by this machine. -/
inductive Step : State → Action → State → Prop where
  | create (s : State) (tx : CreateTx) (o : RequestOutput) :
      tx.cageRef = s.cage → createAllowed tx o →
      (∀ seed ∈ tx.spent, seed ∉ s.usedSeeds) → Step s (.create tx o) (afterCreate s tx o)
  | judge (s : State) (tx : JudgmentTx) :
      tx.cageRef = s.cage → tx.requestRef ∈ s.live → judgmentAllowed tx →
      Step s (.judge tx) (afterJudgment s tx)
  | fold (s : State) (tx : FoldTx) :
      tx.cageIn = s.cage → (∀ o ∈ tx.requests, o ∈ s.live) →
      (∀ name ∈ tx.refs, name ∈ s.judgments) → foldAccepted tx →
      Step s (.fold tx) (afterFold s tx)
  | account (s : State) (tx : AccountTx) :
      tx.cageRef = s.cage → tx.input ∈ s.live →
      (∀ name ∈ tx.refs, name ∈ s.judgments) → accountAllowed tx →
      Step s (.account tx) (afterExit s tx.input)
  | withdraw (s : State) (tx : WithdrawTx) :
      tx.input ∈ s.live → withdrawAllowed tx → Step s (.withdraw tx) (afterExit s tx.input)
  | burn (s : State) (name : TokenName) :
      name ∈ s.judgments → Step s (.burn name) (afterBurn s name)

  | priceMint (s : State) (tx : PriceMintTx) :
      priceMintAllowed tx → Step s (.priceMint tx) (afterPriceMint s tx)
  | priceUpdate (s : State) (tx : PriceUpdateTx) :
      tx.input ∈ s.notices → priceUpdateAllowed tx →
      Step s (.priceUpdate tx) (afterPriceUpdate s tx)

inductive Reachable : State → Prop where
  | registry (c : CageState) (existing : List CageId) :
      registryCreated c existing → Reachable (initial c)
  | next {s s' : State} {action : Action} : Reachable s → Step s action s' → Reachable s'

inductive History : State → State → Prop where
  | refl (s : State) : History s s
  | next {s t u : State} {action : Action} : Step s action t → History t u → History s u

/-- Vocabulary translation of the shipped operations, not a validator proof. -/
inductive OldOperation where
  | insert (key : Key) (value : Val)
  | delete (key : Key) (oldValue : Val)
  | update (key : Key) (oldValue newValue : Val)
  deriving DecidableEq, Repr

def OldOperation.write : OldOperation → Write
  | .insert k v => .set k v
  | .delete k _ => .unset k
  | .update k _ v => .set k v

def OldOperation.condition : OldOperation → Condition
  | .insert k _ => .absent k
  | .delete k v => .equals k v
  | .update k v _ => .equals k v

def OldOperation.apply (op : OldOperation) (t : Trie) : Trie :=
  match op with
  | .insert k v => fun q => if q = k then some v else t q
  | .delete k _ => fun q => if q = k then none else t q
  | .update k _ v => fun q => if q = k then some v else t q

end RequestApprovalFold
