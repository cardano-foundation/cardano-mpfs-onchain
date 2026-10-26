import MpfsCage.Lib

/-!
# Permissionless registries: candidate semantic model

Authority: decisions.md at 097c17a; A-001-model-boundaries items 3/4;
A-002 time windows; lean-author-4 A-001 discovery/output-identity ruling.
Registry creation requires at least one oracle or a rule and duplicate-free
oracles. State-token identity, protocol, oracle list and optional rule are
immutable. A rule packages its opaque compiled-policy hash with an abstract
predicate on the one request and creating signatures. The predicate sees no
trie; it runs only in createAllowed. Predicates and hashes are assumed to name
the same policy consistently, rather than proving code/hash correspondence.

A request output has a fresh ledger output reference, retained in usedOutputs,
separate from its datum seed. Only nonempty oracle lists require a spent seed
when tags are minted. Seedless requests may have identical datums: distinct
output references preserve UTxO uniqueness and no resurrection. Judgment-bound
datum uniqueness uses spent seeds for oracle-bearing registries, with ledger-wide
SpentOnce for cross-registry uniqueness. The opaque seed field remains present
but need not be spent by a zero-oracle request.

Creation has one request output, exactly one registry-named request token and
one tag per oracle. Its policy is the rule hash when present, otherwise the
shared release-policy role. All exits burn the request token and every tag.
Token names are collision-free structured values with a leading role, not a
cryptographic injectivity or canonical-encoding proof. RequestPolicy is an
abstract policy-source distinction; real deployed mint/spend identities and
cross-policy asset accounting remain ledger boundaries (D11).

Judgment names bind registry, complete request, oracle, verdict and approval
conditions. Refusals carry no conditions in their name. A structured name
stands for an authenticated token whose carried datum has been decoded and
checked against the recomputed name; no separate unchecked datum is admitted.
FoldTx.conditions selects the condition list for each request/oracle. A token
reference must bind that exact list; an oracle signature authenticates the
whole fold body, including the selection. Both paths prove the conditions at
the actual intermediate trie, together with the requester's conditions.

Request-token queries enumerate all live requests of the named registry.
Approval discovery is relative to the complete authentic judgment inventory,
including carried condition lists, and explicit signatures; a request alone
cannot predict arbitrary oracle-selected conditions. Operationally this is a
release-policy token listing with each judgment datum. expectedApprovals
recomputes names after selecting those conditions; folderFinds checks the
actual tree/time/turn. This closes D25 at the inventory-relative model layer,
not indexer completeness or an off-chain search/selection algorithm.

Step is the authoritative per-registry relation; Reachable starts at creation.
Only folding changes the trie. Empty folds are allowed and earn nothing.
Time is scalar: judgments/folds need now < deadline; account settlement needs
deadline ≤ now ≤ deadline + window; owner withdrawal needs deadline + window
< now. Scalar-time/validity-interval agreement is an external assumption.
Equivocation is allowed. Judgment holdings count occurrences; one burn erases
one, while issued retains every mint. Signatures, authenticated references,
ownership, fresh UTxO/state-token identities, spent-once inputs and sound trie
proofs are ledger boundary assumptions. Unconditional rule burns are independent
of the admission predicate; no exit requests the creating signatures again.

Fees are independent naturals, fully escrowed at creation. Allocations are per
request and role: exact declared fees, then the entire remainder to the folder
on fold or owner on settlement; withdrawal returns everything. Coincident
addresses do not reuse payments. Funding inputs and chain fees are outside the
protocol account. Registry protocol hashes and request evidence are opaque.

Price notices are signed, nonbinding advertisements. Each has a natural default
fee and optional per-protocol entries, never read by protocol guards. Updates
consume one held occurrence, preserve its oracle/token, and need its signature.
No unique mint, canonical schedule, liveness or global synchronized notice view
is asserted. Any oracle can advertise. Payments are action allocations, not
accumulated balances. Price actions preserve protocol state and pay nothing.

Arbitrary folder order, hold-up and oracle silence are accepted; no fairness,
response or progress guarantee. Concrete CDDL/CBOR/hash encoding, migration,
real policy deployment, cost/devnet evidence, executable surface, JSON codecs,
driver and replay corpus are outside this commission. This is an abstract local
candidate, not implementation, ledger, hosted CI or independent acceptance.
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
  | present (key : Key)
  | absent (key : Key)
  | equals (key : Key) (value : Val)
  deriving DecidableEq, Repr

def Condition.holds (t : Trie) : Condition → Prop
  | .present k => ∃ v, t k = some v
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

/-- Abstract compiled policy: its hash and meaning are fixed together. No tree argument. -/
structure Rule where
  hash : String
  admits : Request → List Signer → Prop

structure CageState where
  id : CageId
  oracles : List Signer
  protocol : String
  trie : Trie
  rule : Option Rule := none

def RegistryValid (c : CageState) : Prop := (c.oracles ≠ [] ∨ c.rule.isSome) ∧ c.oracles.Nodup

def registryCreated (c : CageState) (existing : List CageId) : Prop :=
  c.id ∉ existing ∧ RegistryValid c ∧ c.trie = emptyTrie

inductive RequestPolicy where
  | release
  | rule (hash : String)
  deriving DecidableEq, Repr

def requestPolicy (c : CageState) : RequestPolicy :=
  match c.rule with
  | none => .release
  | some rule => .rule rule.hash

def ruleAdmits (c : CageState) (r : Request) (signers : List Signer) : Prop :=
  match c.rule with
  | none => True
  | some rule => rule.admits r signers

/-- Burns have no rule predicate; every exit is admitted by the rule policy. -/
def ruleBurnAllowed (_rule : Rule) : Prop := True

/-- The first field of a name is its domain-separating role. -/
inductive TokenRole where
  | tag | approval | refusal | price | request
  deriving DecidableEq, Repr

inductive NameBinding where
  | registry (cage : CageId)
  | oracle (signer : Signer)
  | judgment (cage : CageId) (request : Request) (oracle : Signer) (conditions : List Condition)
  deriving DecidableEq, Repr

structure TokenName where
  role : TokenRole
  binding : NameBinding
  deriving DecidableEq, Repr

def tokenName (role : TokenRole) (binding : NameBinding) : TokenName := ⟨role, binding⟩

def tagName (oracle : Signer) : TokenName := tokenName .tag (.oracle oracle)

def requestName (c : CageId) : TokenName := tokenName .request (.registry c)

def judgmentName (c : CageId) (r : Request) (o : Signer) (v : Bool)
    (conditions : List Condition := []) : TokenName :=
  tokenName (if v then .approval else .refusal) (.judgment c r o (if v then conditions else []))

def priceName (oracle : Signer) : TokenName := tokenName .price (.oracle oracle)

structure RequestOutput where
  request : Request
  value : Nat
  tags : List TokenName
  ref : OutputRef
  requestTokens : List TokenName
  policy : RequestPolicy
  deriving DecidableEq, Repr

def tokensOf (o : RequestOutput) := o.tags ++ o.requestTokens

def totalFees (c : CageState) (r : Request) : Nat :=
  (c.oracles.map r.fee).sum

def wellFormed (c : CageState) (o : RequestOutput) : Prop :=
  o.request.cage = c.id ∧ o.tags = c.oracles.map tagName ∧
  totalFees c o.request ≤ o.value ∧
  o.requestTokens = [requestName c.id] ∧ o.policy = requestPolicy c

structure CreateTx where
  spent : List OutputRef
  cageRef : CageState
  minted : List TokenName
  outputs : List RequestOutput
  signers : List Signer
  policy : RequestPolicy

def createAllowed (tx : CreateTx) (o : RequestOutput) : Prop :=
  (tx.cageRef.oracles ≠ [] → o.request.seed ∈ tx.spent) ∧ tx.outputs = [o] ∧
  tx.minted = tx.cageRef.oracles.map tagName ++ [requestName tx.cageRef.id] ∧
  wellFormed tx.cageRef o ∧ ruleAdmits tx.cageRef o.request tx.signers ∧
  tx.policy = requestPolicy tx.cageRef

def SpentOnce (history : List CreateTx) : Prop :=
  ∀ a b seed, a ∈ history → b ∈ history →
    seed ∈ a.spent → seed ∈ b.spent → a = b

structure JudgmentTx where
  cageRef : CageState
  requestRef : RequestOutput
  oracle : Signer
  approve : Bool
  conditions : List Condition
  now : Time
  signers : List Signer
  spent : List OutputRef
  minted : List TokenName

def judgmentAllowed (tx : JudgmentTx) : Prop :=
  tx.requestRef.request.cage = tx.cageRef.id ∧
  tx.oracle ∈ tx.cageRef.oracles ∧ tx.oracle ∈ tx.signers ∧
  tx.now < tx.requestRef.request.deadline ∧ tx.spent = [] ∧
  tx.minted = [judgmentName tx.cageRef.id tx.requestRef.request tx.oracle tx.approve tx.conditions]

/-- Chosen conditions for each request/oracle, in the signed fold body.
    References must bind exactly this selection; signers authenticate the whole body. -/
abbrev OracleConditions := Request → Signer → List Condition

def noOracleConditions : OracleConditions := fun _ _ => []

def hasApproval (c : CageState) (r : Request) (refs : List TokenName)
    (signers : List Signer) (conditions : OracleConditions) : Prop :=
  ∀ oracle ∈ c.oracles,
    judgmentName c.id r oracle true (conditions r oracle) ∈ refs ∨ oracle ∈ signers

def hasAccount (c : CageState) (r : Request) (refs : List TokenName) : Prop :=
  ∀ oracle ∈ c.oracles, ∃ verdict conditions,
    judgmentName c.id r oracle verdict conditions ∈ refs

def stepValid (c : CageState) (now : Time) (refs : List TokenName)
    (signers : List Signer) (conditions : OracleConditions) (t : Trie) (o : RequestOutput) : Prop :=
  wellFormed c o ∧ now < o.request.deadline ∧
  hasApproval c o.request refs signers conditions ∧
  (∀ condition ∈ o.request.conditions, condition.holds t) ∧
  ∀ oracle ∈ c.oracles, ∀ condition ∈ conditions o.request oracle, condition.holds t

inductive FoldRun (c : CageState) (now : Time) (refs : List TokenName)
    (signers : List Signer) (conditions : OracleConditions) : Trie → List RequestOutput → Trie → Prop where
  | nil (t : Trie) : FoldRun c now refs signers conditions t [] t
  | cons (t : Trie) (o : RequestOutput) (os : List RequestOutput) (t' : Trie) :
      stepValid c now refs signers conditions t o →
      FoldRun c now refs signers conditions (o.request.write.apply t) os t' →
      FoldRun c now refs signers conditions t (o :: os) t'

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
  conditions : OracleConditions
  submitter : Signer
  burned : List TokenName
  allocations : List Allocation

def foldAccepted (tx : FoldTx) : Prop :=
  tx.cageOut.id = tx.cageIn.id ∧ tx.cageOut.oracles = tx.cageIn.oracles ∧
  tx.cageOut.protocol = tx.cageIn.protocol ∧ tx.cageOut.rule = tx.cageIn.rule ∧ tx.requests.Nodup ∧
  tx.burned = tx.requests.flatMap tokensOf ∧
  tx.allocations = tx.requests.map (fun o => allocation tx.cageIn o tx.folder) ∧
  FoldRun tx.cageIn tx.now tx.refs tx.signers tx.conditions tx.cageIn.trie tx.requests tx.cageOut.trie

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
  | .folded tx => judgmentName tx.cageIn.id r oracle true (tx.conditions r oracle) ∈ tx.refs ∨ oracle ∈ tx.signers
  | .accounted tx => ∃ verdict conditions, judgmentName tx.cageRef.id r oracle verdict conditions ∈ tx.refs
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
  usedOutputs : List OutputRef

def initial (c : CageState) : State := ⟨c, [], [], [], [], [], []⟩

def removeRequests (live spent : List RequestOutput) :=
  live.filter (fun o => o ∉ spent)

def afterCreate (s : State) (tx : CreateTx) (o : RequestOutput) : State :=
  { s with
    usedSeeds := tx.spent ++ s.usedSeeds
    live := o :: s.live
    usedOutputs := o.ref :: s.usedOutputs }

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

/-- Request-token query; the input list is the authenticated UTxO inventory. -/
def discoverRequests (c : CageId) (outputs : List RequestOutput) : List RequestOutput :=
  outputs.filter (fun o => requestName c ∈ o.requestTokens)

/-- Full recomputed approval name for each chosen carried condition list. -/
def expectedApprovals (c : CageState) (r : Request) (conditions : OracleConditions) : List TokenName :=
  c.oracles.map (fun oracle => judgmentName c.id r oracle true (conditions r oracle))

/-- Inventory-relative work at a particular turn, including signed redeemer evidence.
    This relation does not promise a computable enumeration of arbitrary predicates/trees. -/
def folderFinds (s : State) (now : Time) (signers : List Signer)
    (conditions : OracleConditions) (t : Trie) (o : RequestOutput) : Prop :=
  o ∈ discoverRequests s.cage.id s.live ∧
  wellFormed s.cage o ∧ now < o.request.deadline ∧
  (∀ oracle ∈ s.cage.oracles,
    judgmentName s.cage.id o.request oracle true (conditions o.request oracle) ∈ s.judgments ∨
    oracle ∈ signers) ∧
  (∀ condition ∈ o.request.conditions, condition.holds t) ∧
  ∀ oracle ∈ s.cage.oracles, ∀ condition ∈ conditions o.request oracle, condition.holds t

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
      (∀ seed ∈ tx.spent, seed ∉ s.usedSeeds) → o.ref ∉ s.usedOutputs →
      Step s (.create tx o) (afterCreate s tx o)
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
