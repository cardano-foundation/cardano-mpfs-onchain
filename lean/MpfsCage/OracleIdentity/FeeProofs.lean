import MpfsCage.OracleIdentity.Proofs
namespace OracleIdentity

/- Proof-only invariant for records returned from shape-valid descriptions. -/
mutual
def RecordSound : SigningRecord → Prop
  | .key _ => True
  | .group ms => ms.toList ≠ [] ∧ SignedSound ms
def SignedSound : SignedMembers → Prop
  | .nil => True
  | .cons share r rest => 0 < share ∧ RecordSound r ∧ SignedSound rest
end

mutual
theorem record_sound (d : Description) (ss : Signers) (r : SigningRecord)
    (hv : shapeValid d = true) (hr : record d ss = some r) : RecordSound r := by
  cases d with
  | key k =>
    simp only [record] at hr
    split at hr
    · cases Option.some.inj hr; trivial
    · contradiction
  | group t ms =>
    simp only [shapeValid, Bool.and_eq_true, decide_eq_true_eq] at hv
    simp only [record] at hr
    split at hr
    · rename_i hc
      cases Option.some.inj hr
      refine ⟨?_, signed_sound ms ss hv.2⟩
      intro he
      have ht := hv.1.1
      rw [he] at hc
      simp at hc
      omega
    · contradiction
theorem signed_sound (ms : Members) (ss : Signers)
    (hv : membersValid ms = true) : SignedSound (signedMembers ms ss) := by
  cases ms with
  | nil => trivial
  | cons d share rest =>
    simp only [membersValid, Bool.and_eq_true, decide_eq_true_eq] at hv
    simp only [signedMembers]
    cases hr : record d ss with
    | none => exact signed_sound rest ss hv.2
    | some r => exact ⟨hv.1.1, record_sound d ss r hv.1.2 hr, signed_sound rest ss hv.2⟩
end

theorem floor_sum_bound (xs : List Nat) (fee den : Nat) :
    (xs.map (fun s => fee * s / den)).sum * den ≤ fee * xs.sum := by
  induction xs with
  | nil => simp
  | cons s xs ih =>
    simp only [List.map_cons, List.sum_cons, Nat.add_mul, Nat.mul_add]
    exact Nat.add_le_add (Nat.div_mul_le_self _ _) ih

theorem portions_length (xs : List Nat) (fee : Nat) :
    (portions fee xs).length = xs.length := by
  cases xs <;> simp [portions]

theorem portions_sum (xs : List Nat) (fee : Nat) (hp : 0 < xs.sum) :
    (portions fee xs).sum = fee := by
  have hb := (Nat.mul_le_mul_right_iff hp).mp (floor_sum_bound xs fee xs.sum)
  cases xs with
  | nil => simp at hp
  | cons s xs =>
    simp only [portions, List.map_cons, List.sum_cons]
    simp only [List.map_cons, List.sum_cons] at hb
    omega

theorem signed_sum_positive (ms : SignedMembers) (hs : SignedSound ms)
    (hn : ms.toList ≠ []) : 0 < (ms.toList.map Prod.fst).sum := by
  cases ms with
  | nil => exact False.elim (hn rfl)
  | cons s r rest =>
    have hp := hs.1
    simp [SignedMembers.toList]
    omega

mutual
theorem split_sound_total (r : SigningRecord) (fee : Nat) (hs : RecordSound r) :
    totalPaid (splitRecorded r fee) = fee := by
  cases r with
  | key k => simp [splitRecorded, totalPaid]
  | group ms =>
    rw [splitRecorded, split_members_total ms _ hs.2]
    · exact portions_sum _ fee (signed_sum_positive ms hs.2 hs.1)
    · simp [portions_length]
theorem split_members_total (ms : SignedMembers) (amounts : List Nat)
    (hs : SignedSound ms) (hl : amounts.length = ms.toList.length) :
    totalPaid (splitMembers ms amounts) = amounts.sum := by
  cases ms with
  | nil =>
    have : amounts = [] := by simpa [SignedMembers.toList] using hl
    subst amounts; rfl
  | cons share r rest =>
    cases amounts with
    | nil => simp [SignedMembers.toList] at hl
    | cons amount amounts =>
      simp only [SignedMembers.toList, List.length_cons, Nat.add_right_cancel_iff] at hl
      simp only [splitMembers, totalPaid, List.map_append, List.sum_append]
      have h₁ := split_sound_total r amount hs.2.1
      have h₂ := split_members_total rest amounts hs.2.2 hl
      change totalPaid (splitRecorded r amount) + totalPaid (splitMembers rest amounts) = _
      rw [h₁,h₂]; rfl
end

mutual
theorem payment_key_recorded (r : SigningRecord) (fee : Nat) (p : Payment)
    (h : p ∈ splitRecorded r fee) : p.key ∈ recordedKeys r := by
  cases r with
  | key k =>
    have he : p = ⟨k,fee⟩ := by simpa [splitRecorded] using h
    simp [he, recordedKeys]
  | group ms => exact payment_key_signed ms _ p h
theorem payment_key_signed (ms : SignedMembers) (amounts : List Nat) (p : Payment)
    (h : p ∈ splitMembers ms amounts) : p.key ∈ signedKeys ms := by
  cases ms with
  | nil => simp [splitMembers] at h
  | cons share r rest =>
    cases amounts with
    | nil => simp [splitMembers] at h
    | cons a amounts =>
      simp only [splitMembers, List.mem_append] at h
      exact h.elim
        (fun h => List.mem_append_left _ (payment_key_recorded r a p h))
        (fun h => List.mem_append_right _ (payment_key_signed rest amounts p h))
end

theorem paid_zero_of_absent (ps : List Payment) (k : Key)
    (h : ∀ p, p ∈ ps → p.key ≠ k) : paidTo ps k = 0 := by
  have he : ps.filter (fun p => decide (p.key = k)) = [] := by
    apply List.filter_eq_nil_iff.mpr
    intro p hp
    simpa using h p hp
  simp [paidTo, he]

theorem split_success (expected : Identity) (d : Description) (ss : Signers)
    (fee : Nat) (ps : List Payment) (h : splitFee expected d ss fee = some ps) :
    ∃ r, authorize expected d ss = some r ∧ ps = splitRecorded r fee := by
  unfold splitFee at h
  cases hr : authorize expected d ss with
  | none => simp [hr] at h
  | some r => exact ⟨r, rfl, (Option.some.inj (by simpa [hr] using h)).symm⟩

theorem authorized_total (expected : Identity) (d : Description) (ss : Signers)
    (r : SigningRecord) (fee : Nat) (h : authorize expected d ss = some r) :
    totalPaid (splitRecorded r fee) = fee := by
  obtain ⟨_,hv,hr⟩ := (auth_iff _ _ _ _).mp h
  have hvp : shapeValid d = true ∧ (keys d).Nodup := by simpa [valid] using hv
  exact split_sound_total r fee (record_sound d ss r hvp.1 hr)

end OracleIdentity
