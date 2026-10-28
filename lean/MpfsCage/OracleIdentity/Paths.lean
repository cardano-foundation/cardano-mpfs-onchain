import MpfsCage.OracleIdentity.Model

namespace OracleIdentity

/-- Statement vocabulary for any finite depth. Indices follow the original
    description's member order, including members that did not authorize.
    An empty path selects the root; a missing index or descent into a key fails. -/
def atPath (root : Description) (path : List Nat) : Option Description :=
  match path with
  | [] => some root
  | i :: rest =>
      match root with
      | .key _ => none
      | .group _ members =>
          (members.toList[i]?).bind fun member => atPath member.1 rest

end OracleIdentity
