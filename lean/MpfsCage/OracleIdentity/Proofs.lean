import MpfsCage.OracleIdentity.Paths
namespace OracleIdentity
@[simp] theorem valid_key (k : Key) : valid (.key k) = true := by
  simp [valid, shapeValid, keys]
theorem auth_iff (expected : Identity) (d : Description) (ss : Signers) (r : SigningRecord) :
    authorize expected d ss = some r ↔
      expected = identity d ∧ valid d = true ∧ record d ss = some r := by
  unfold authorize
  by_cases h : identity d = expected ∧ valid d = true
  · rw [if_pos h]
    exact ⟨fun hr => ⟨h.1.symm,h.2,hr⟩, fun hr => hr.2.2⟩
  · rw [if_neg h]
    constructor
    · intro hn; contradiction
    · rintro ⟨he,hv,_⟩; exact False.elim (h ⟨he.symm,hv⟩)
theorem authorized_iff (d : Description) (ss : Signers) :
    Authorizes d ss ↔ valid d = true ∧ (record d ss).isSome = true := by
  simp only [Authorizes, authorize, true_and]
  split <;> simp_all
theorem signed_list (ms : Members) (ss : Signers) :
    (signedMembers ms ss).toList = ms.toList.filterMap
      (fun m => (record m.1 ss).map (fun r => (m.2, r))) := by
  cases ms with
  | nil => rfl
  | cons d share rest =>
    simp only [signedMembers, Members.toList, List.filterMap_cons]
    cases h : record d ss <;> simp [SignedMembers.toList, signed_list rest ss]
theorem signed_count (ms : Members) (ss : Signers) :
    (signedMembers ms ss).toList.length = authorizingCount ms ss := by
  cases ms with
  | nil => rfl
  | cons d share rest =>
    simp only [signedMembers, authorizingCount, Members.toList, List.filter_cons]
    cases h : record d ss <;> simp_all [SignedMembers.toList, signed_count rest ss, authorizingCount]
theorem members_valid_iff (ms : Members) :
    membersValid ms = true ↔ ∀ d share, (d,share) ∈ ms.toList →
      0 < share ∧ shapeValid d = true := by
  cases ms with
  | nil => simp [Members.toList, membersValid]
  | cons d share rest =>
    simp only [Members.toList, membersValid, members_valid_iff rest, Bool.and_eq_true, decide_eq_true_eq, List.mem_cons, Prod.mk.injEq]
    constructor
    · rintro ⟨⟨hs,hd⟩,hr⟩ e s (he | he)
      · rcases he with ⟨rfl,rfl⟩; exact ⟨hs,hd⟩
      · exact hr e s he
    · intro h
      exact ⟨h d share (Or.inl ⟨rfl,rfl⟩), fun e s he => h e s (Or.inr he)⟩
theorem member_keys_sublist (ms : Members) (d : Description) (share : Nat)
    (h : (d,share) ∈ ms.toList) : (keys d).Sublist (memberKeys ms) := by
  cases ms with
  | nil => simp [Members.toList] at h
  | cons e s rest =>
    simp only [Members.toList, List.mem_cons, Prod.mk.injEq] at h
    rcases h with ⟨rfl,rfl⟩ | h
    · exact List.sublist_append_left _ _
    · exact (member_keys_sublist rest d share h).trans (List.sublist_append_right _ _)
theorem valid_group (t : Nat) (ms : Members) :
    valid (.group t ms) = true ↔
      0 < t ∧ t ≤ ms.toList.length ∧ (memberKeys ms).Nodup ∧
      ∀ d share, (d, share) ∈ ms.toList → 0 < share ∧ valid d = true := by
  simp only [valid, shapeValid, keys, Bool.and_eq_true, decide_eq_true_eq]
  rw [members_valid_iff]
  constructor
  · rintro ⟨⟨⟨ht,hl⟩,hm⟩,hn⟩
    exact ⟨ht,hl,hn,fun d s h => ⟨(hm d s h).1, (hm d s h).2,
      hn.sublist (member_keys_sublist ms d s h)⟩⟩
  · rintro ⟨ht,hl,hn,hm⟩
    exact ⟨⟨⟨ht,hl⟩,fun d s h => ⟨(hm d s h).1,(hm d s h).2.1⟩⟩,hn⟩
mutual
theorem record_ext (d : Description) (ss tt : Signers)
    (h : ∀ k, k ∈ ss ↔ k ∈ tt) : record d ss = record d tt := by
  cases d with
  | key k => simp [record, h k]
  | group t ms => simp only [record, signed_ext ms ss tt h]
theorem signed_ext (ms : Members) (ss tt : Signers)
    (h : ∀ k, k ∈ ss ↔ k ∈ tt) : signedMembers ms ss = signedMembers ms tt := by
  cases ms with
  | nil => rfl
  | cons d share rest => simp only [signedMembers, record_ext d ss tt h, signed_ext rest ss tt h]
end
mutual
theorem record_monotone (d : Description) (ss tt : Signers)
    (h : ∀ k, k ∈ ss → k ∈ tt) :
    (record d ss).isSome = true → (record d tt).isSome = true := by
  cases d with
  | key k =>
    simp only [record]
    split <;> split <;> simp_all
  | group t ms =>
    have hm := signed_monotone ms ss tt h
    simp only [record]
    split <;> split <;> simp_all <;> omega
theorem signed_monotone (ms : Members) (ss tt : Signers)
    (h : ∀ k, k ∈ ss → k ∈ tt) :
    (signedMembers ms ss).toList.length ≤ (signedMembers ms tt).toList.length := by
  cases ms with
  | nil => exact Nat.le_refl _
  | cons d share rest =>
    have ih := signed_monotone rest ss tt h
    have hd := record_monotone d ss tt h
    simp only [signedMembers]
    cases hs : record d ss <;> cases ht : record d tt <;>
      simp_all [SignedMembers.toList] <;> omega
end
mutual
theorem record_sublist (d : Description) (ss : Signers) (r : SigningRecord)
    (h : record d ss = some r) : (recordedKeys r).Sublist (keys d) := by
  cases d with
  | key k =>
    simp only [record] at h
    split at h
    · cases Option.some.inj h; exact List.Sublist.refl _
    · contradiction
  | group t ms =>
    simp only [record] at h
    split at h
    · cases Option.some.inj h; exact signed_sublist ms ss
    · contradiction
theorem signed_sublist (ms : Members) (ss : Signers) :
    (signedKeys (signedMembers ms ss)).Sublist (memberKeys ms) := by
  cases ms with
  | nil => exact List.Sublist.refl _
  | cons d share rest =>
    simp only [signedMembers, memberKeys]
    cases h : record d ss with
    | none => exact (signed_sublist rest ss).trans (List.sublist_append_right _ _)
    | some r => exact (record_sublist d ss r h).append (signed_sublist rest ss)
end
mutual
theorem record_signers (d : Description) (ss : Signers) (r : SigningRecord)
    (h : record d ss = some r) : ∀ k, k ∈ recordedKeys r → k ∈ ss := by
  cases d with
  | key k =>
    simp only [record] at h
    split at h
    · cases Option.some.inj h; simpa [recordedKeys] using ‹k ∈ ss›
    · contradiction
  | group t ms =>
    simp only [record] at h
    split at h
    · cases Option.some.inj h; exact signed_signers ms ss
    · contradiction
theorem signed_signers (ms : Members) (ss : Signers) :
    ∀ k, k ∈ signedKeys (signedMembers ms ss) → k ∈ ss := by
  cases ms with
  | nil => simp [signedMembers, signedKeys]
  | cons d share rest =>
    simp only [signedMembers]
    cases h : record d ss with
    | none => exact signed_signers rest ss
    | some r =>
      intro k hk
      simp only [signedKeys, List.mem_append] at hk
      exact hk.elim (record_signers d ss r h k) (signed_signers rest ss k)
end
end OracleIdentity
