import MpfsCage.OracleIdentity.Paths

/-! Concrete reachable calls and their results. This module imports no admitted
    statements: all witnesses are checked by kernel reduction. -/
namespace OracleIdentity.Witnesses

def alice : Description := .key "alice"
def bob : Description := .key "bob"
def carol : Description := .key "carol"
def dave : Description := .key "dave"
def inner : Description := .group 1 (.cons carol 1 (.cons dave 1 .nil))
def members : Members := .cons alice 2 (.cons bob 1 (.cons inner 1 .nil))
def demo : Description := .group 2 members
def signers : Signers := ["alice", "carol", "dave"]
def innerRecord : SigningRecord :=
  .group (.cons 1 (.key "carol") (.cons 1 (.key "dave") .nil))
def demoSigned : SignedMembers := .cons 2 (.key "alice") (.cons 1 innerRecord .nil)
def demoRecord : SigningRecord := .group demoSigned
def payments : List Payment := [⟨"alice", 8⟩, ⟨"carol", 2⟩, ⟨"dave", 1⟩]
def strictInner : Description := .group 2 (.cons carol 1 (.cons dave 1 .nil))
def partialMembers : Members := .cons alice 1 (.cons strictInner 1 .nil)
def partialGroup : Description := .group 1 partialMembers
def duplicate : Description := .group 2 (.cons alice 1
  (.cons (.group 1 (.cons alice 1 .nil)) 1 .nil))
def flat : Description := .group 2 (.cons alice 1 (.cons bob 1 .nil))
def emptyGroup : Description := .group 0 .nil
def zeroShare : Description := .group 1 (.cons alice 0 .nil)
def highThreshold : Description := .group 2 (.cons alice 1 .nil)
def singleton : Description := .group 1 (.cons alice 7 .nil)
def allSigners : Signers := ["alice", "bob", "carol", "dave"]
def allRecord : SigningRecord := .group
  (.cons 2 (.key "alice") (.cons 1 (.key "bob") (.cons 1 innerRecord .nil)))

def W01 : identity demo = identity demo ∧ valid demo = true := by decide

def W02 : authorize (identity demo) demo signers = some demoRecord ∧
    authorize (identity bob) demo signers = none := by decide

def W03 : valid zeroShare = false ∧
    authorize (identity zeroShare) zeroShare ["alice"] = none ∧
    splitFee (identity zeroShare) zeroShare ["alice"] 11 = none := by decide

def W04 : valid demo = true ∧ valid emptyGroup = false ∧
    valid highThreshold = false ∧ valid zeroShare = false := by decide

def W05 : Authorizes alice ["alice"] ∧ ¬ Authorizes alice [] := by decide

def W06 : Authorizes demo signers ∧ authorizingCount members signers = 2 := by decide

def W07 : (∀ k, k ∈ ["alice", "carol"] → k ∈ signers) ∧
    Authorizes demo ["alice", "carol"] ∧ Authorizes demo signers := by
  constructor
  · intro k h
    simp only [List.mem_cons, List.not_mem_nil, or_false] at h
    rcases h with h | h <;> subst k <;> decide
  · decide

def W08 : authorizingCount members ["carol", "dave"] < 2 ∧
    authorize (identity demo) demo ["carol", "dave"] = none := by decide

def W09 : 0 < (7 : Nat) ∧ Authorizes alice ["alice"] ∧
    Authorizes singleton ["alice"] ∧
    splitFee (identity singleton) singleton ["alice"] 11 = some [⟨"alice", 11⟩] := by decide

def W10 : "alice" ∈ (["alice"] : Signers) ∧
    splitFee (identity alice) alice ["alice"] 11 = some [⟨"alice", 11⟩] := by decide

def W11 : splitFee (identity demo) demo signers 11 = some payments ∧
    totalPaid payments = 11 := by decide

def W12 : splitFee (identity demo) demo signers 11 = some payments ∧
    "bob" ∉ signers ∧ paidTo payments "bob" = 0 := by decide

def W13 : splitFee (identity partialGroup) partialGroup ["alice", "carol"] 11 =
      some [⟨"alice", 11⟩] ∧
    (strictInner, 1) ∈ partialMembers.toList ∧
    record strictInner ["alice", "carol"] = none ∧ "carol" ∈ keys strictInner ∧
    "carol" ∈ (["alice", "carol"] : Signers) := by decide

def W14 : authorize (identity demo) demo allSigners = some allRecord ∧
    authorizingCount members allSigners = 3 := by decide

def W15 : authorize (identity demo) demo signers = some demoRecord ∧
    recordedKeys demoRecord = ["alice", "carol", "dave"] := by decide

def W16 : authorize (identity demo) demo signers = some demoRecord ∧
    (recordedKeys demoRecord).Nodup := by decide

def W17 : splitRecorded (.group demoSigned) 11 = payments ∧
    portions 11 [2, 1] = [8, 3] ∧ portions 3 [1, 1] = [2, 1] ∧
    splitFee (identity demo) demo ["bob", "carol"] 9 =
      some [⟨"bob", 5⟩, ⟨"carol", 4⟩] := by decide

def W18 : valid demo = true ∧
    (members.toList.filter (fun m => "carol" ∈ keys m.1)).length = 1 := by decide

def W19 : Authorizes demo ["alice", "alice", "carol"] ∧
    (signingKeys demo ["alice", "alice", "carol"]).length = 2 := by decide

def W20 : 1 < (keys duplicate).count "alice" ∧ valid duplicate = false ∧
    authorize (identity duplicate) duplicate ["alice"] = none := by decide

def W21 : authorize (identity demo) demo signers = some demoRecord ∧
    valid demo = true ∧ record demo signers = some demoRecord := by decide

def W22 : splitFee (identity demo) demo [] 11 = none ∧
    authorize (identity demo) demo [] = none := by decide

def W23 : (∀ k : Key, k ∈ ["alice", "carol"] ↔ k ∈ ["carol", "alice"]) ∧
    authorize (identity alice) alice ["alice", "carol"] =
      authorize (identity alice) alice ["carol", "alice"] := by
  constructor
  · intro k
    simp only [List.mem_cons, List.not_mem_nil, or_false]
    exact or_comm
  · decide

def W24 : authorize (identity demo) demo signers = some demoRecord ∧
    totalPaid (splitRecorded demoRecord 0) = 0 ∧
    totalPaid (splitRecorded demoRecord 11) = 11 ∧
    totalPaid (splitRecorded demoRecord 17) = 17 := by decide

/-- The failed subgroup is two member edges below the paying root. -/
def deepGroup : Description := .group 1 (.cons partialGroup 1 .nil)
def strictMembers : Members := .cons carol 1 (.cons dave 1 .nil)

def W25 :
    record (.key "alice") ["alice"] = some (.key "alice") ∧
    authorize (identity alice) alice ["alice"] = some (.key "alice") ∧
    record (.key "alice") [] = none ∧ authorize (identity alice) alice [] = none ∧
    authorize (identity demo) demo signers = some demoRecord := by decide

def W26 :
    splitFee (identity deepGroup) deepGroup ["alice", "carol"] 11 =
      some [⟨"alice", 11⟩] ∧
    atPath deepGroup [0, 1] = some (.group 2 strictMembers) ∧
    authorizingCount strictMembers ["alice", "carol"] < 2 ∧
    "carol" ∈ memberKeys strictMembers ∧
    "carol" ∈ (["alice", "carol"] : Signers) ∧
    paidTo [⟨"alice", 11⟩] "carol" = 0 := by decide

end OracleIdentity.Witnesses
