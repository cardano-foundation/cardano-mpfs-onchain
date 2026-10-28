import MpfsCage.OracleIdentity.FeeProofs
namespace OracleIdentity

theorem member_occurrences (ms : Members) (k : Key) :
    (ms.toList.filter (fun m => decide (k ∈ keys m.1))).length ≤ (memberKeys ms).count k := by
  cases ms with
  | nil => simp [Members.toList, memberKeys]
  | cons d share rest =>
    have ih := member_occurrences rest k
    simp only [Members.toList, List.filter_cons, memberKeys, List.count_append]
    by_cases hk : k ∈ keys d
    · have hc := List.count_pos_iff.mpr hk
      simp only [hk, decide_true, if_true, List.length_cons]
      omega
    · simp only [hk, decide_false, Bool.false_eq_true, if_false]
      omega

theorem eraseDups_nodup (xs : List Key) (hn : xs.Nodup) : xs.eraseDups = xs := by
  induction xs with
  | nil => rfl
  | cons k xs ih =>
    obtain ⟨hk,ht⟩ := List.nodup_cons.mp hn
    have hf : xs.filter (fun b => !b == k) = xs := by
      apply List.filter_eq_self.mpr
      intro b hb
      have he : b ≠ k := by intro he; subst b; exact hk hb
      simpa using he
    rw [List.eraseDups_cons, hf, ih ht]

mutual
theorem sound_keys_positive (r : SigningRecord) (hs : RecordSound r) :
    0 < (recordedKeys r).length := by
  cases r with
  | key k => simp [recordedKeys]
  | group ms =>
    have hl := sound_member_count ms hs.2
    have hn : 0 < ms.toList.length := List.length_pos_iff.mpr hs.1
    change 0 < (signedKeys ms).length
    omega
theorem sound_member_count (ms : SignedMembers) (hs : SignedSound ms) :
    ms.toList.length ≤ (signedKeys ms).length := by
  cases ms with
  | nil => simp [SignedMembers.toList, signedKeys]
  | cons share r rest =>
    have hr := sound_keys_positive r hs.2.1
    have ht := sound_member_count rest hs.2.2
    simp only [SignedMembers.toList, signedKeys, List.length_cons, List.length_append]
    omega
end

theorem recorded_length_le_signing (d : Description) (ss : Signers) (r : SigningRecord)
    (hv : valid d = true) (hr : record d ss = some r) :
    (recordedKeys r).length ≤ (signingKeys d ss).length := by
  have hn : (keys d).Nodup := (show shapeValid d = true ∧ (keys d).Nodup by simpa [valid] using hv).2
  have hf : (recordedKeys r).filter (fun k => decide (k ∈ ss)) = recordedKeys r := by
    apply List.filter_eq_self.mpr
    intro k hk
    simpa using record_signers d ss r hr k hk
  have hsub := (record_sublist d ss r hr).filter (fun k => decide (k ∈ ss))
  rw [hf] at hsub
  unfold signingKeys
  rw [eraseDups_nodup _ (hn.sublist (List.filter_sublist))]
  exact hsub.length_le

end OracleIdentity
