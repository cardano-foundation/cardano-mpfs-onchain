import MpfsCage.OracleIdentity.Paths

/-! Statement vocabulary for the original description's authorizing branches.
This traversal uses signer membership and the actual member authorization count;
it does not call recordedKeys, signedKeys or signingKeys. A failed subgroup
contributes no keys, even when individual keys inside it signed. -/
namespace OracleIdentity

mutual
def branchKeys : Description → Signers → List Key
  | .key k, ss => if k ∈ ss then [k] else []
  | .group t ms, ss =>
      if t ≤ authorizingCount ms ss then memberBranchKeys ms ss else []
def memberBranchKeys : Members → Signers → List Key
  | .nil, _ => []
  | .cons d _ rest, ss => branchKeys d ss ++ memberBranchKeys rest ss
end

end OracleIdentity
