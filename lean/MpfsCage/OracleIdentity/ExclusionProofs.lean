import MpfsCage.OracleIdentity.FeeProofs
namespace OracleIdentity

/- Global uniqueness makes every member's key domain disjoint from its siblings. -/
theorem signed_avoids_member (ms : Members) (ss : Signers) (child : Description)
    (share : Nat) (k : Key) (hn : (memberKeys ms).Nodup)
    (hm : (child,share) ∈ ms.toList) (hk : k ∈ keys child)
    (hc : ∀ r, record child ss = some r → k ∉ recordedKeys r) :
    k ∉ signedKeys (signedMembers ms ss) := by
  cases ms with
  | nil => simp [Members.toList] at hm
  | cons d s rest =>
    obtain ⟨hd,hr,hdis⟩ := List.nodup_append.mp hn
    simp only [Members.toList, List.mem_cons, Prod.mk.injEq] at hm
    simp only [signedMembers]
    rcases hm with ⟨rfl,rfl⟩ | hm
    · have ht : k ∉ signedKeys (signedMembers rest ss) := by
        intro h
        exact hdis k hk k ((signed_sublist rest ss).subset h) rfl
      cases he : record child ss with
      | none => exact ht
      | some r =>
        simp only [signedKeys, List.mem_append, not_or]
        exact ⟨hc r he,ht⟩
    · have htail := signed_avoids_member rest ss child share k hr hm hk hc
      have hkm : k ∈ memberKeys rest := (member_keys_sublist rest child share hm).subset hk
      cases he : record d ss with
      | none => exact htail
      | some r =>
        simp only [signedKeys, List.mem_append, not_or]
        refine ⟨?_,htail⟩
        intro h
        exact hdis k ((record_sublist d ss r he).subset h) k hkm rfl

theorem path_keys_sublist (root : Description) (path : List Nat) (child : Description)
    (hp : atPath root path = some child) : (keys child).Sublist (keys root) := by
  induction path generalizing root with
  | nil =>
    have he : root = child := Option.some.inj hp
    subst root; exact List.Sublist.refl _
  | cons i path ih =>
    cases root with
    | key k => simp [atPath] at hp
    | group t ms =>
      simp only [atPath] at hp
      cases hm : ms.toList[i]? with
      | none => simp [hm] at hp
      | some m =>
        simp only [hm, Option.bind_some] at hp
        exact (ih m.1 hp).trans (member_keys_sublist ms m.1 m.2 (List.mem_of_getElem? hm))

theorem record_avoids_path (root : Description) (ss : Signers) (r : SigningRecord)
    (path : List Nat) (child : Description) (k : Key)
    (hn : (keys root).Nodup) (hr : record root ss = some r)
    (hp : atPath root path = some child) (hf : record child ss = none)
    (hk : k ∈ keys child) : k ∉ recordedKeys r := by
  induction path generalizing root r with
  | nil =>
    have he : root = child := Option.some.inj hp
    subst root
    rw [hf] at hr
    contradiction
  | cons i path ih =>
    cases root with
    | key key => simp [atPath] at hp
    | group t ms =>
      simp only [record] at hr
      split at hr
      · cases Option.some.inj hr
        simp only [atPath] at hp
        cases hm : ms.toList[i]? with
        | none => simp [hm] at hp
        | some m =>
          simp only [hm, Option.bind_some] at hp
          have hmem := List.mem_of_getElem? hm
          have hsub := member_keys_sublist ms m.1 m.2 hmem
          exact signed_avoids_member ms ss m.1 m.2 k hn hmem
            ((path_keys_sublist m.1 path child hp).subset hk)
            (fun r hr => ih m.1 r (hn.sublist hsub) hr hp)
      · contradiction

theorem unpaid_of_record_absent (r : SigningRecord) (fee : Nat) (k : Key)
    (h : k ∉ recordedKeys r) : paidTo (splitRecorded r fee) k = 0 := by
  apply paid_zero_of_absent
  intro p hp he
  apply h
  simpa [he] using payment_key_recorded r fee p hp

end OracleIdentity
