import MpfsCage.OracleIdentity.Model

namespace OracleIdentity
open Lean

mutual
def descriptionJson : Description → Json
  | .key k => Json.mkObj [("kind", toJson ("key" : String)), ("key", toJson k)]
  | .group t ms => Json.mkObj [("kind", toJson ("group" : String)),
      ("threshold", toJson t), ("members", toJson (membersJson ms))]
def membersJson : Members → List Json
  | .nil => []
  | .cons d share rest => Json.mkObj [("oracle", descriptionJson d),
      ("share", toJson share)] :: membersJson rest
end

/-- Fuel is taken from the input's serialized length, strictly exceeding its
    nesting depth. It keeps the parser total without restricting the algebra. -/
def parseDescription : Nat → Json → Except String Description
  | 0, _ => .error "description nesting exceeds input length"
  | fuel + 1, j => do
      match ← j.getObjValAs? String "kind" with
      | "key" => return .key (← j.getObjValAs? String "key")
      | "group" =>
          let t ← j.getObjValAs? Nat "threshold"
          let ms ← j.getObjValAs? (Array Json) "members"
          let entries ← ms.toList.mapM fun m => do
            let d ← parseDescription fuel (← m.getObjVal? "oracle")
            let share ← m.getObjValAs? Nat "share"
            return (d, share)
          return .group t (Members.ofList entries)
      | _ => .error "unknown oracle kind"

instance : ToJson Description := ⟨descriptionJson⟩
instance : FromJson Description := ⟨fun j => parseDescription (j.compress.length + 1) j⟩

instance : ToJson Identity := ⟨fun i => Json.mkObj
  [("role", toJson ("oracle" : String)), ("description", toJson i.description)]⟩
instance : FromJson Identity := ⟨fun j => do
  let role ← j.getObjValAs? String "role"
  if role != "oracle" then throw "wrong identity role"
  return identity (← j.getObjValAs? Description "description")⟩

mutual
def recordJson : SigningRecord → Json
  | .key k => Json.mkObj [("kind", toJson ("key" : String)), ("key", toJson k)]
  | .group ms => Json.mkObj [("kind", toJson ("group" : String)),
      ("members", toJson (signedMembersJson ms))]
def signedMembersJson : SignedMembers → List Json
  | .nil => []
  | .cons share r rest => Json.mkObj [("share", toJson share),
      ("record", recordJson r)] :: signedMembersJson rest
end

def parseRecord : Nat → Json → Except String SigningRecord
  | 0, _ => .error "record nesting exceeds input length"
  | fuel + 1, j => do
      match ← j.getObjValAs? String "kind" with
      | "key" => return .key (← j.getObjValAs? String "key")
      | "group" =>
          let ms ← j.getObjValAs? (Array Json) "members"
          let entries ← ms.toList.mapM fun m => do
            let r ← parseRecord fuel (← m.getObjVal? "record")
            let share ← m.getObjValAs? Nat "share"
            return (share, r)
          return .group (entries.foldr (fun (share, r) rest => .cons share r rest) .nil)
      | _ => .error "unknown record kind"

instance : ToJson SigningRecord := ⟨recordJson⟩
instance : FromJson SigningRecord := ⟨fun j => parseRecord (j.compress.length + 1) j⟩

structure Scenario where
  id : String
  mutant : String
  surface : String
  description : Description
  expected : Identity
  signers : Signers
  fee : Nat
  key : Key
  deriving ToJson, FromJson

/-- One generic dispatcher. Refused authorization is a precondition failure for
    payment/record observations, and is also nonzero for the authorize call. -/
def runScenario (s : Scenario) : Except String Json := do
  match s.surface with
  | "identity" => return toJson (identity s.description)
  | "valid" => return toJson (valid s.description)
  | "signingKeys" => return toJson (signingKeys s.description s.signers)
  | "splitFee" =>
      match splitFee s.expected s.description s.signers s.fee with
      | none => .error "authorization refused"
      | some payments => return toJson payments
  | "authorize" | "splitRecorded" | "recordedKeys" | "paidTo" | "totalPaid" =>
      let r ← match authorize s.expected s.description s.signers with
        | none => .error "authorization refused"
        | some r => .ok r
      match s.surface with
      | "authorize" => return toJson r
      | "recordedKeys" => return toJson (recordedKeys r)
      | "splitRecorded" => return toJson (splitRecorded r s.fee)
      | "paidTo" => return toJson (paidTo (splitRecorded r s.fee) s.key)
      | _ => return toJson (totalPaid (splitRecorded r s.fee))
  | _ => .error "unknown surface"

end OracleIdentity
