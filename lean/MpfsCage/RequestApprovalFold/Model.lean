import MpfsCage.Lib
import MpfsCage.OracleIdentity.Model

/-!
Authority: specs/request-approval-fold/decisions.md (27 October), the accepted
OracleIdentity algebra, and creator answer A-001-money-boundaries. Step is the
relational law. Registry value is fee backing, excluding a permanent ledger
reserve; claim value is its tip, with output funding outside this account.
Intervals are closed, nonempty intervals of natural times. Request settlement
includes both endpoints; claim withdrawal begins at its deadline.
Names are structured collision-free preimages, not a cryptographic theorem.
Rule predicates, trie functions, signature verification, authenticated UTxOs,
spent-once seeds and sound trie proofs remain abstract ledger boundaries.
Executable codecs/driver/corpus remain #109, by A-001. No progress is promised.
-/
namespace RequestApprovalFold

abbrev Key := String
abbrev Val := String
abbrev Signer := OracleIdentity.Key
abbrev Oracle := OracleIdentity.Identity
abbrev Time := Nat
abbrev OutputRef := String
abbrev SigningRecord := OracleIdentity.SigningRecord

def Trie := Key → Option Val
def emptyTrie : Trie := fun _ => none

structure Interval where
  lower : Time
  upper : Time
  deriving DecidableEq, Repr

def Interval.valid (i : Interval) : Prop := i.lower ≤ i.upper

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
  fees : List (Oracle × Nat)
  deadline : Time
  window : Nat
  deriving DecidableEq, Repr

def Request.fee (r : Request) (oracle : Oracle) : Nat :=
  ((r.fees.find? (fun p => p.1 == oracle)).map Prod.snd).getD 0

structure Rule where
  hash : String
  admits : Request → List Signer → Prop

structure CageState where
  id : CageId
  oracles : List Oracle
  protocol : String
  trie : Trie
  rule : Option Rule := none
  balances : Signer → Nat := fun _ => 0
  value : Nat := 0
  minimum : Nat := 1

def registryKeys (c : CageState) : List Signer :=
  (c.oracles.flatMap fun o => OracleIdentity.keys o.description).eraseDups

def balanceSum (c : CageState) : Nat := ((registryKeys c).map c.balances).sum

def RegistryValid (c : CageState) : Prop :=
  (c.oracles ≠ [] ∨ c.rule.isSome) ∧ c.oracles.Nodup ∧ 0 < c.minimum

def Backed (c : CageState) : Prop :=
  c.value = balanceSum c ∧ ∀ k, k ∉ registryKeys c → c.balances k = 0

def registryCreated (c : CageState) (existing : List CageId) : Prop :=
  c.id ∉ existing ∧ RegistryValid c ∧ c.trie = emptyTrie ∧
  c.balances = (fun _ => 0) ∧ c.value = 0

def SameRegistry (a b : CageState) : Prop :=
  a.id = b.id ∧ a.oracles = b.oracles ∧ a.protocol = b.protocol ∧
  a.rule = b.rule ∧ a.minimum = b.minimum

inductive RequestPolicy where
  | release
  | rule (hash : String)
  deriving DecidableEq, Repr

def requestPolicy (c : CageState) : RequestPolicy :=
  match c.rule with | none => .release | some rule => .rule rule.hash

def ruleAdmits (c : CageState) (r : Request) (signers : List Signer) : Prop :=
  match c.rule with | none => True | some rule => rule.admits r signers

inductive TokenRole where
  | tag | approval | refusal | price | request | claim
  deriving DecidableEq, Repr

inductive NameBinding where
  | registry (cage : CageId)
  | oracle (oracle : Oracle)
  | judgment (cage : CageId) (request : Request) (oracle : Oracle)
      (record : SigningRecord) (conditions : List Condition)
  deriving DecidableEq, Repr

structure TokenName where
  role : TokenRole
  binding : NameBinding
  deriving DecidableEq, Repr

def tokenName (role : TokenRole) (binding : NameBinding) : TokenName := ⟨role, binding⟩
def tagName (oracle : Oracle) : TokenName := tokenName .tag (.oracle oracle)
def requestName (c : CageId) : TokenName := tokenName .request (.registry c)
def claimName (c : CageId) : TokenName := tokenName .claim (.registry c)
def priceName (oracle : Oracle) : TokenName := tokenName .price (.oracle oracle)
def judgmentName (c : CageId) (r : Request) (o : Oracle) (v : Bool)
    (record : SigningRecord) (conditions : List Condition := []) : TokenName :=
  tokenName (if v then .approval else .refusal)
    (.judgment c r o record (if v then conditions else []))

structure RequestOutput where
  request : Request
  value : Nat
  tags : List TokenName
  ref : OutputRef
  requestTokens : List TokenName
  policy : RequestPolicy
  deriving DecidableEq, Repr

def tokensOf (o : RequestOutput) := o.tags ++ o.requestTokens

def totalFees (c : CageState) (r : Request) : Nat := (c.oracles.map r.fee).sum

def wellFormed (c : CageState) (o : RequestOutput) : Prop :=
  o.request.cage = c.id ∧ o.tags = c.oracles.map tagName ∧
  totalFees c o.request + c.minimum ≤ o.value ∧
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
  ∀ a b seed, a ∈ history → b ∈ history → seed ∈ a.spent → seed ∈ b.spent → a = b

/-- A selected judgment carries the authenticated canonical signing record.
The authorization witness is replayed with the imported algebra, never copied. -/
structure Evidence where
  description : OracleIdentity.Description
  signers : List Signer
  record : SigningRecord
  approve : Bool
  conditions : List Condition
  deriving DecidableEq, Repr

def Evidence.authorized (e : Evidence) (o : Oracle) : Prop :=
  OracleIdentity.authorize o e.description e.signers = some e.record

def Evidence.name (e : Evidence) (c : CageId) (r : Request) (o : Oracle) : TokenName :=
  judgmentName c r o e.approve e.record e.conditions

structure JudgmentTx where
  cageRef : CageState
  requestRef : RequestOutput
  oracle : Oracle
  evidence : Evidence
  interval : Interval
  signers : List Signer
  spent : List OutputRef
  minted : List TokenName

def judgmentAllowed (tx : JudgmentTx) : Prop :=
  tx.requestRef.request.cage = tx.cageRef.id ∧ tx.oracle ∈ tx.cageRef.oracles ∧
  tx.evidence.signers = tx.signers ∧ tx.evidence.authorized tx.oracle ∧
  tx.interval.valid ∧ tx.interval.upper < tx.requestRef.request.deadline ∧ tx.spent = [] ∧
  tx.minted = [tx.evidence.name tx.cageRef.id tx.requestRef.request tx.oracle]

abbrev Selection := Oracle → Evidence

def hasApproval (c : CageState) (r : Request) (refs : List TokenName)
    (signers : List Signer) (selected : Selection) : Prop :=
  ∀ oracle ∈ c.oracles,
    (selected oracle).authorized oracle ∧ (selected oracle).approve = true ∧
    ((selected oracle).name c.id r oracle ∈ refs ∨ (selected oracle).signers = signers)

def hasAccount (c : CageState) (r : Request) (refs : List TokenName) (selected : Selection) : Prop :=
  ∀ oracle ∈ c.oracles,
    (selected oracle).authorized oracle ∧ (selected oracle).name c.id r oracle ∈ refs

/-- The public split is replayed using exactly the selected record's authorization. -/
def oracleCredits (r : Request) (o : Oracle) (e : Evidence) : List OracleIdentity.Payment :=
  (OracleIdentity.splitFee o e.description e.signers (r.fee o)).getD []

def credits (c : CageState) (r : Request) (selected : Selection) : List OracleIdentity.Payment :=
  c.oracles.flatMap fun o => oracleCredits r o (selected o)

def credit (c : CageState) (ps : List OracleIdentity.Payment) : CageState :=
  { c with balances := fun k => c.balances k + OracleIdentity.paidTo ps k
           value := c.value + OracleIdentity.totalPaid ps }

structure ClaimOutput where
  cage : CageId
  key : Signer
  destination : String
  datum : String
  deadline : Time
  value : Nat
  ref : OutputRef
  tokens : List TokenName
  deriving DecidableEq, Repr

structure ClaimCreateTx where
  cageRef : CageState
  output : ClaimOutput
  signers : List Signer
  minted : List TokenName

def claimCreateAllowed (tx : ClaimCreateTx) : Prop :=
  tx.output.cage = tx.cageRef.id ∧ tx.output.key ∈ registryKeys tx.cageRef ∧
  tx.output.key ∈ tx.signers ∧ tx.output.tokens = [claimName tx.cageRef.id] ∧
  tx.minted = tx.output.tokens

structure Payment where
  destination : String
  datum : String
  amount : Nat
  deriving DecidableEq, Repr

def totalPaid (ps : List Payment) : Nat := (ps.map Payment.amount).sum

def remainder (c : CageState) (o : RequestOutput) : Nat := o.value - totalFees c o.request

inductive FoldItem where
  | write (input : RequestOutput) (selected : Selection)
  | account (input : RequestOutput) (selected : Selection)
  | claim (input : ClaimOutput)

def FoldItem.request : FoldItem → Option RequestOutput
  | .write o _ | .account o _ => some o
  | .claim _ => none

def FoldItem.claimInput : FoldItem → Option ClaimOutput
  | .claim o => some o
  | _ => none

def FoldItem.burned : FoldItem → List TokenName
  | .write o _ | .account o _ => tokensOf o
  | .claim o => o.tokens

def FoldItem.writes : FoldItem → List Write
  | .write o _ => [o.request.write]
  | _ => []

def itemCredits (c : CageState) : FoldItem → List OracleIdentity.Payment
  | .write o e | .account o e => credits c o.request e
  | .claim _ => []

def itemResult (c : CageState) : FoldItem → CageState
  | .write o e => { credit c (credits c o.request e) with trie := o.request.write.apply c.trie }
  | .account o e => credit c (credits c o.request e)
  | .claim o => { c with
      balances := fun k => if k = o.key then 0 else c.balances k
      value := c.value - c.balances o.key }

def itemPayments (c : CageState) (folder : Signer) : FoldItem → List Payment
  | .write o _ => [⟨folder, "", remainder c o⟩]
  | .account o _ => [⟨o.request.owner, "", remainder c o⟩]
  | .claim o => [⟨o.destination, o.datum, c.balances o.key⟩, ⟨folder, "", o.value⟩]

def stepValid (c : CageState) (interval : Interval) (refs : List TokenName)
    (signers : List Signer) (selected : Selection) (o : RequestOutput) : Prop :=
  wellFormed c o ∧ interval.valid ∧ interval.upper < o.request.deadline ∧
  hasApproval c o.request refs signers selected ∧
  (∀ condition ∈ o.request.conditions, condition.holds c.trie) ∧
  ∀ oracle ∈ c.oracles, ∀ condition ∈ (selected oracle).conditions, condition.holds c.trie

def accountAllowed (c : CageState) (interval : Interval) (refs : List TokenName)
    (o : RequestOutput) (selected : Selection) : Prop :=
  wellFormed c o ∧ interval.valid ∧ o.request.deadline ≤ interval.lower ∧
  interval.upper ≤ o.request.deadline + o.request.window ∧ hasAccount c o.request refs selected

def claimAllowed (c : CageState) (interval : Interval) (o : ClaimOutput) : Prop :=
  o.cage = c.id ∧ o.key ∈ registryKeys c ∧ o.tokens = [claimName c.id] ∧
  interval.valid ∧ interval.upper < o.deadline ∧ c.minimum ≤ c.balances o.key

def itemAllowed (c : CageState) (interval : Interval) (refs : List TokenName)
    (signers : List Signer) : FoldItem → Prop
  | .write o e => stepValid c interval refs signers e o
  | .account o e => accountAllowed c interval refs o e
  | .claim o => claimAllowed c interval o

/-- Ordered effects and guards use exactly the state left by the previous item. -/
def foldResult (c : CageState) : List FoldItem → CageState
  | [] => c
  | i :: items => foldResult (itemResult c i) items

def foldPayments (c : CageState) (folder : Signer) : List FoldItem → List Payment
  | [] => []
  | i :: items => itemPayments c folder i ++ foldPayments (itemResult c i) folder items

inductive FoldRun (interval : Interval) (refs : List TokenName) (signers : List Signer) :
    CageState → List FoldItem → CageState → Prop where
  | nil (c : CageState) : FoldRun interval refs signers c [] c
  | cons (c : CageState) (item : FoldItem) (items : List FoldItem) (out : CageState) :
      itemAllowed c interval refs signers item →
      FoldRun interval refs signers (itemResult c item) items out →
      FoldRun interval refs signers c (item :: items) out

structure FoldTx where
  cageIn : CageState
  cageOut : CageState
  items : List FoldItem
  refs : List TokenName
  signers : List Signer
  interval : Interval
  folder : Signer
  submitter : Signer
  burned : List TokenName
  payments : List Payment

def FoldTx.requests (tx : FoldTx) := tx.items.filterMap FoldItem.request

def FoldTx.claims (tx : FoldTx) := tx.items.filterMap FoldItem.claimInput

def foldAccepted (tx : FoldTx) : Prop :=
  tx.interval.valid ∧ (tx.requests.map RequestOutput.ref ++ tx.claims.map ClaimOutput.ref).Nodup ∧
  tx.burned = tx.items.flatMap FoldItem.burned ∧
  tx.payments = foldPayments tx.cageIn tx.folder tx.items ∧
  FoldRun tx.interval tx.refs tx.signers tx.cageIn tx.items tx.cageOut

structure WithdrawTx where
  input : RequestOutput
  interval : Interval
  signers : List Signer
  burned : List TokenName
  beneficiary : Signer
  paid : Nat

def withdrawAllowed (tx : WithdrawTx) : Prop :=
  tx.interval.valid ∧ tx.input.request.deadline + tx.input.request.window < tx.interval.lower ∧
  tx.input.request.owner ∈ tx.signers ∧ tx.burned = tokensOf tx.input ∧
  tx.beneficiary = tx.input.request.owner ∧ tx.paid = tx.input.value

structure ClaimWithdrawTx where
  input : ClaimOutput
  interval : Interval
  signers : List Signer
  burned : List TokenName
  beneficiary : Signer
  paid : Nat

def claimWithdrawAllowed (tx : ClaimWithdrawTx) : Prop :=
  tx.interval.valid ∧ tx.input.deadline ≤ tx.interval.lower ∧ tx.input.key ∈ tx.signers ∧
  tx.burned = tx.input.tokens ∧ tx.beneficiary = tx.input.key ∧ tx.paid = tx.input.value

inductive RequestSpend where
  | folded (tx : FoldTx)
  | withdrawn (tx : WithdrawTx)

def requestSpendAllowed (o : RequestOutput) : RequestSpend → Prop
  | .folded tx => foldAccepted tx ∧ o ∈ tx.requests
  | .withdrawn tx => withdrawAllowed tx ∧ tx.input = o

def RequestSpend.interval : RequestSpend → Interval
  | .folded tx => tx.interval
  | .withdrawn tx => tx.interval

def RequestSpend.burned : RequestSpend → List TokenName
  | .folded tx => tx.burned
  | .withdrawn tx => tx.burned

structure PriceDatum where
  fee : Nat
  perProtocol : List (String × Nat)
  deriving DecidableEq, Repr

structure PriceNotice where
  oracle : Oracle
  token : TokenName
  datum : PriceDatum
  deriving DecidableEq, Repr

structure PriceMintTx where
  output : PriceNotice
  description : OracleIdentity.Description
  signers : List Signer
  minted : List TokenName

def priceMintAllowed (tx : PriceMintTx) : Prop :=
  (OracleIdentity.authorize tx.output.oracle tx.description tx.signers).isSome = true ∧
  tx.output.token = priceName tx.output.oracle ∧ tx.minted = [tx.output.token]

structure PriceUpdateTx where
  input : PriceNotice
  output : PriceNotice
  description : OracleIdentity.Description
  signers : List Signer
  minted : List TokenName

def priceUpdateAllowed (tx : PriceUpdateTx) : Prop :=
  (OracleIdentity.authorize tx.input.oracle tx.description tx.signers).isSome = true ∧
  tx.input.token = priceName tx.input.oracle ∧ tx.output.oracle = tx.input.oracle ∧
  tx.output.token = tx.input.token ∧ tx.minted = []

structure State where
  cage : CageState
  usedSeeds : List OutputRef
  live : List RequestOutput
  judgments : List TokenName
  issued : List TokenName
  notices : List PriceNotice
  usedOutputs : List OutputRef
  claims : List ClaimOutput

def initial (c : CageState) : State := ⟨c, [], [], [], [], [], [], []⟩
def removeRequests (live spent : List RequestOutput) := live.filter (fun o => o ∉ spent)
def afterCreate (s : State) (tx : CreateTx) (o : RequestOutput) : State :=
  { s with usedSeeds := tx.spent ++ s.usedSeeds, live := o :: s.live, usedOutputs := o.ref :: s.usedOutputs }
def afterJudgment (s : State) (tx : JudgmentTx) : State :=
  { s with judgments := tx.minted ++ s.judgments, issued := tx.minted ++ s.issued }
def afterFold (s : State) (tx : FoldTx) : State :=
  { s with cage := tx.cageOut, live := removeRequests s.live tx.requests
           claims := s.claims.filter (fun o => o ∉ tx.claims) }
def afterExit (s : State) (o : RequestOutput) : State :=
  { s with live := removeRequests s.live [o] }
def afterBurn (s : State) (name : TokenName) : State :=
  { s with judgments := s.judgments.erase name }
def afterPriceMint (s : State) (tx : PriceMintTx) : State :=
  { s with notices := tx.output :: s.notices }
def afterPriceUpdate (s : State) (tx : PriceUpdateTx) : State :=
  { s with notices := tx.output :: s.notices.erase tx.input }
def afterClaimCreate (s : State) (tx : ClaimCreateTx) : State :=
  { s with claims := tx.output :: s.claims, usedOutputs := tx.output.ref :: s.usedOutputs }
def afterClaimWithdraw (s : State) (tx : ClaimWithdrawTx) : State :=
  { s with claims := s.claims.erase tx.input }

def discover (oracle : Oracle) (outputs : List RequestOutput) : List RequestOutput :=
  outputs.filter (fun o => tagName oracle ∈ o.tags)
def discoverRequests (c : CageId) (outputs : List RequestOutput) : List RequestOutput :=
  outputs.filter (fun o => requestName c ∈ o.requestTokens)
def discoverClaims (c : CageId) (outputs : List ClaimOutput) : List ClaimOutput :=
  outputs.filter (fun o => claimName c ∈ o.tokens)
def expectedApprovals (c : CageState) (r : Request) (selected : Selection) : List TokenName :=
  c.oracles.map (fun oracle => judgmentName c.id r oracle true (selected oracle).record (selected oracle).conditions)
def folderFinds (s : State) (interval : Interval) (signers : List Signer)
    (selected : Selection) (o : RequestOutput) : Prop :=
  o ∈ discoverRequests s.cage.id s.live ∧ stepValid s.cage interval s.judgments signers selected o

inductive Action where
  | create (tx : CreateTx) (output : RequestOutput)
  | judge (tx : JudgmentTx)
  | fold (tx : FoldTx)
  | withdraw (tx : WithdrawTx)
  | burn (name : TokenName)
  | priceMint (tx : PriceMintTx)
  | priceUpdate (tx : PriceUpdateTx)
  | claimCreate (tx : ClaimCreateTx)
  | claimWithdraw (tx : ClaimWithdrawTx)

def Action.spend : Action → Option RequestSpend
  | .fold tx => some (.folded tx)
  | .withdraw tx => some (.withdrawn tx)
  | _ => none

def Action.payments : Action → List Payment
  | .fold tx => tx.payments
  | .withdraw tx => [⟨tx.beneficiary, "", tx.paid⟩]
  | .claimWithdraw tx => [⟨tx.beneficiary, "", tx.paid⟩]
  | _ => []

def Action.isPrice : Action → Bool
  | .priceMint _ | .priceUpdate _ => true
  | _ => false

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
      (∀ o ∈ tx.claims, o ∈ s.claims) → (∀ name ∈ tx.refs, name ∈ s.judgments) →
      foldAccepted tx → Step s (.fold tx) (afterFold s tx)
  | withdraw (s : State) (tx : WithdrawTx) :
      tx.input ∈ s.live → withdrawAllowed tx → Step s (.withdraw tx) (afterExit s tx.input)
  | burn (s : State) (name : TokenName) :
      name ∈ s.judgments → Step s (.burn name) (afterBurn s name)
  | priceMint (s : State) (tx : PriceMintTx) :
      priceMintAllowed tx → Step s (.priceMint tx) (afterPriceMint s tx)
  | priceUpdate (s : State) (tx : PriceUpdateTx) :
      tx.input ∈ s.notices → priceUpdateAllowed tx → Step s (.priceUpdate tx) (afterPriceUpdate s tx)
  | claimCreate (s : State) (tx : ClaimCreateTx) :
      tx.cageRef = s.cage → claimCreateAllowed tx → tx.output.ref ∉ s.usedOutputs →
      Step s (.claimCreate tx) (afterClaimCreate s tx)
  | claimWithdraw (s : State) (tx : ClaimWithdrawTx) :
      tx.input ∈ s.claims → claimWithdrawAllowed tx →
      Step s (.claimWithdraw tx) (afterClaimWithdraw s tx)

inductive Reachable : State → Prop where
  | registry (c : CageState) (existing : List CageId) :
      registryCreated c existing → Reachable (initial c)
  | next {s s' : State} {action : Action} : Reachable s → Step s action s' → Reachable s'

inductive History : State → State → Prop where
  | refl (s : State) : History s s
  | next {s t u : State} {action : Action} : Step s action t → History t u → History s u

/-- An actual history indexed by its exact source/action/target events. This
adds an observation of Step; it does not change any transition or guard. -/
inductive Trace : State → List (State × Action × State) → State → Prop where
  | nil (s : State) : Trace s [] s
  | cons {s t u : State} {a : Action} {events : List (State × Action × State)} :
      Step s a t → Trace t events u → Trace s ((s, a, t) :: events) u

inductive OldOperation where
  | insert (key : Key) (value : Val)
  | delete (key : Key) (oldValue : Val)
  | update (key : Key) (oldValue newValue : Val)
  deriving DecidableEq, Repr

def OldOperation.write : OldOperation → Write
  | .insert k v => .set k v | .delete k _ => .unset k | .update k _ v => .set k v

def OldOperation.condition : OldOperation → Condition
  | .insert k _ => .absent k | .delete k v => .equals k v | .update k v _ => .equals k v

def OldOperation.apply (op : OldOperation) (t : Trie) : Trie :=
  match op with
  | .insert k v => fun q => if q = k then some v else t q
  | .delete k _ => fun q => if q = k then none else t q
  | .update k _ v => fun q => if q = k then some v else t q

/-- Boundary observations for the relational fold; none are validity premises. -/
def atTurn (tx : FoldTx) (n : Nat) : CageState := foldResult tx.cageIn (tx.items.take n)
def requestEscrows (items : List FoldItem) : Nat :=
  ((items.filterMap FoldItem.request).map RequestOutput.value).sum
def claimEscrows (items : List FoldItem) : Nat :=
  ((items.filterMap FoldItem.claimInput).map ClaimOutput.value).sum
def grossCredits (c : CageState) : List FoldItem → Nat
  | [] => 0
  | i :: items => OracleIdentity.totalPaid (itemCredits c i) + grossCredits (itemResult c i) items
def requestRemainders (c : CageState) : List FoldItem → Nat
  | [] => 0
  | i :: items => (match i.request with | some o => remainder c o | none => 0) +
      requestRemainders (itemResult c i) items
def claimPayouts (c : CageState) : List FoldItem → Nat
  | [] => 0
  | i :: items => (match i.claimInput with | some o => c.balances o.key | none => 0) +
      claimPayouts (itemResult c i) items

inductive ExitKind where
  | write | account | withdraw
  deriving DecidableEq, Repr

/-- Classify an actual request consumption without inserting timing premises. -/
def RequestSpend.exitsAs (spend : RequestSpend) (o : RequestOutput) : ExitKind → Prop
  | .write => match spend with
      | .folded tx => ∃ e, FoldItem.write o e ∈ tx.items
      | .withdrawn _ => False
  | .account => match spend with
      | .folded tx => ∃ e, FoldItem.account o e ∈ tx.items
      | .withdrawn _ => False
  | .withdraw => match spend with
      | .folded _ => False
      | .withdrawn tx => tx.input = o

def exitAt (o : RequestOutput) (interval : Interval) : ExitKind → Prop
  | .write => interval.valid ∧ interval.upper < o.request.deadline
  | .account => interval.valid ∧ o.request.deadline ≤ interval.lower ∧
      interval.upper ≤ o.request.deadline + o.request.window
  | .withdraw => interval.valid ∧ o.request.deadline + o.request.window < interval.lower

def singletonFold (s : State) (interval : Interval) (signers : List Signer)
    (item : FoldItem) (folder : Signer) : FoldTx :=
  ⟨s.cage, itemResult s.cage item, [item], s.judgments, signers, interval,
    folder, folder, item.burned, itemPayments s.cage folder item⟩

end RequestApprovalFold
