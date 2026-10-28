import MpfsCage.OracleIdentity.ObservationSpec
import MpfsCage.OracleIdentity.Proofs

namespace OracleIdentity

theorem paid_cons (p : Payment) (ps : List Payment) (k : Key) :
    paidTo (p :: ps) k = (if p.key = k then p.amount else 0) + paidTo ps k := by
  by_cases h : p.key = k <;> simp [paidTo, h]

theorem payment_fold (ps : List Payment) (k : Key) :
    paidTo ps k = ps.foldr (fun p amount => (if p.key = k then p.amount else 0) + amount) 0 := by
  induction ps with
  | nil => rfl
  | cons p ps ih => simp only [paid_cons, List.foldr_cons, ih]

theorem sum_map_add (ks : List Key) (f g : Key → Nat) :
    (ks.map (fun k => f k + g k)).sum = (ks.map f).sum + (ks.map g).sum := by
  induction ks with
  | nil => rfl
  | cons k ks ih => simp only [List.map_cons, List.sum_cons, ih]; omega

theorem sum_key_indicator (ks : List Key) (k : Key) (amount : Nat) (hn : ks.Nodup) :
    (ks.map (fun key => if k = key then amount else 0)).sum =
      if k ∈ ks then amount else 0 := by
  induction ks with
  | nil => simp
  | cons key ks ih =>
    obtain ⟨hk,ht⟩ := List.nodup_cons.mp hn
    by_cases he : k = key
    · subst k
      simp [ih ht, hk]
    · simp [ih ht, he]

theorem sum_paid_over_cover (ps : List Payment) (ks : List Key) (hn : ks.Nodup)
    (hc : ∀ p, p ∈ ps → p.key ∈ ks) :
    (ks.map (paidTo ps)).sum = totalPaid ps := by
  induction ps with
  | nil =>
    change (ks.map (fun k => paidTo [] k)).sum = totalPaid []
    simp only [paidTo, List.filter_nil, List.map_nil, List.sum_nil, totalPaid]
    induction ks <;> simp_all
  | cons p ps ih =>
    have hp := hc p (by simp)
    have ht := ih (fun q hq => hc q (by simp [hq]))
    change (ks.map (fun k => paidTo (p :: ps) k)).sum = _
    simp only [paid_cons]
    rw [sum_map_add, sum_key_indicator ks p.key p.amount hn, if_pos hp, ht]
    simp [totalPaid]

theorem dedup_keys_nodup (ks : List Key) : ks.eraseDups.Nodup := by
  cases ks with
  | nil => simp
  | cons k ks =>
    rw [List.eraseDups_cons, List.nodup_cons]
    constructor
    · simp [List.mem_eraseDups]
    · exact dedup_keys_nodup (ks.filter (fun b => !b == k))
termination_by ks.length
decreasing_by
  have h := List.length_filter_le (p := fun b => !b == k) (l := ks)
  simp only [List.length_cons]
  omega

theorem payment_partition (ps : List Payment) :
    (((ps.map Payment.key).eraseDups).map (paidTo ps)).sum = totalPaid ps := by
  apply sum_paid_over_cover ps _ (dedup_keys_nodup _)
  intro p hp
  apply List.mem_eraseDups.mpr
  exact List.mem_map.mpr ⟨p,hp,rfl⟩

theorem signed_keys_flat (ms : SignedMembers) :
    signedKeys ms = ms.toList.flatMap (fun m => recordedKeys m.2) := by
  cases ms with
  | nil => rfl
  | cons s r rest =>
    simp only [signedKeys, SignedMembers.toList, List.flatMap_cons, signed_keys_flat rest]

theorem branch_keys_of_none (d : Description) (ss : Signers)
    (h : record d ss = none) : branchKeys d ss = [] := by
  cases d with
  | key k =>
    simp only [record] at h
    split at h
    · contradiction
    · simp [branchKeys, *]
  | group t ms =>
    simp only [record] at h
    split at h
    · contradiction
    · rename_i hn
      simp only [branchKeys, ← signed_count, if_neg hn]

mutual
theorem record_branch_keys (d : Description) (ss : Signers) :
    (record d ss).map recordedKeys =
      if (record d ss).isSome then some (branchKeys d ss) else none := by
  cases d with
  | key k => by_cases hk : k ∈ ss <;> simp [record, recordedKeys, branchKeys, hk]
  | group t ms =>
    simp only [record, branchKeys, ← signed_count]
    split <;> simp_all [recordedKeys, signed_branch_keys ms ss]
theorem signed_branch_keys (ms : Members) (ss : Signers) :
    signedKeys (signedMembers ms ss) = memberBranchKeys ms ss := by
  cases ms with
  | nil => rfl
  | cons d share rest =>
    have hr := record_branch_keys d ss
    simp only [signedMembers, memberBranchKeys]
    cases he : record d ss with
    | none =>
      have hb : branchKeys d ss = [] := branch_keys_of_none d ss he
      simp [hb, signed_branch_keys rest ss]
    | some r =>
      simp only [he, Option.map_some, Option.isSome_some, if_true, Option.some.injEq] at hr
      simp only [signedKeys, hr, signed_branch_keys rest ss]
end

end OracleIdentity
