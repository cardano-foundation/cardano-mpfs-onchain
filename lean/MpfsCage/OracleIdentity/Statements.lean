import MpfsCage.OracleIdentity.FormulaProofs
import MpfsCage.OracleIdentity.ExclusionProofs
import MpfsCage.OracleIdentity.CountingProofs

/-! The 26 statements accepted at 82bbfcc, with proofs against the frozen model. -/
namespace OracleIdentity

-- T01
theorem identity_injective (d e : Description) : identity d = identity e → d = e := by
  intro h
  exact congrArg Identity.description h

-- T02
theorem authorization_binds_identity (expected : Identity) (d : Description)
    (ss : Signers) (r : SigningRecord) :
    authorize expected d ss = some r → expected = identity d := by
  intro h
  exact (auth_iff expected d ss r).mp h |>.1

-- T03
theorem invalid_description_refused (expected : Identity) (d : Description)
    (ss : Signers) (fee : Nat) : valid d = false →
    authorize expected d ss = none ∧ splitFee expected d ss fee = none := by
  intro h
  simp [authorize, splitFee, h]

-- T04: exact valid-group domain, including nested validity and global uniqueness.
theorem group_valid_iff (t : Nat) (ms : Members) :
    valid (.group t ms) = true ↔
      0 < t ∧ t ≤ ms.toList.length ∧ (memberKeys ms).Nodup ∧
      ∀ d share, (d, share) ∈ ms.toList → 0 < share ∧ valid d = true := by
  exact valid_group t ms

-- T05
theorem key_authorizes_iff (k : Key) (ss : Signers) :
    Authorizes (.key k) ss ↔ k ∈ ss := by
  simp [authorized_iff, record]

-- T06
theorem group_authorizes_iff (t : Nat) (ms : Members) (ss : Signers) :
    Authorizes (.group t ms) ss ↔
      valid (.group t ms) = true ∧ t ≤ authorizingCount ms ss := by
  simp [authorized_iff, record, signed_count]

-- T07
theorem authorization_monotone (d : Description) (ss more : Signers) :
    (∀ k, k ∈ ss → k ∈ more) → Authorizes d ss → Authorizes d more := by
  intro h ha
  rw [authorized_iff] at ha ⊢
  exact ⟨ha.1, record_monotone d ss more h ha.2⟩

-- T08
theorem below_threshold_refused (t : Nat) (ms : Members) (ss : Signers) :
    authorizingCount ms ss < t →
      authorize (identity (.group t ms)) (.group t ms) ss = none := by
  intro h
  have hn : ¬ t ≤ (signedMembers ms ss).toList.length := by rw [signed_count]; omega
  simp [authorize, record, hn]

-- T09: same behavior, not the same identity or record shape.
theorem key_is_single_member_case (k : Key) (share : Nat) (ss : Signers) (fee : Nat) :
    0 < share →
    (Authorizes (.key k) ss ↔ Authorizes (.group 1 (.cons (.key k) share .nil)) ss) ∧
    splitFee (identity (.key k)) (.key k) ss fee =
      splitFee (identity (.group 1 (.cons (.key k) share .nil)))
        (.group 1 (.cons (.key k) share .nil)) ss fee := by
  intro hs
  by_cases hk : k ∈ ss <;>
    simp [Authorizes, authorize, identity, valid, shapeValid, keys, memberKeys,
      membersValid, Members.toList, record, signedMembers, SignedMembers.toList,
      splitFee, splitRecorded, splitMembers, portions, hk, hs]

-- T10
theorem key_receives_whole_fee (k : Key) (ss : Signers) (fee : Nat) : k ∈ ss →
    splitFee (identity (.key k)) (.key k) ss fee = some [⟨k, fee⟩] := by
  intro h
  simp [splitFee, authorize, record, h, splitRecorded]

-- T11
theorem split_conserves_fee (expected : Identity) (d : Description) (ss : Signers)
    (fee : Nat) (payments : List Payment) :
    splitFee expected d ss fee = some payments → totalPaid payments = fee := by
  intro h
  obtain ⟨r,ha,rfl⟩ := split_success expected d ss fee payments h
  exact authorized_total expected d ss r fee ha

-- T12
theorem unsigned_key_receives_nothing (expected : Identity) (d : Description)
    (ss : Signers) (fee : Nat) (payments : List Payment) (k : Key) :
    splitFee expected d ss fee = some payments → k ∉ ss → paidTo payments k = 0 := by
  intro h hk
  obtain ⟨r,ha,rfl⟩ := split_success expected d ss fee payments h
  apply unpaid_of_record_absent
  intro hkr
  exact hk (record_signers d ss r ((auth_iff _ _ _ _).mp ha).2.2 k hkr)

-- T13: a signed key inside a failed subgroup is still unpaid on this branch.
theorem nonauthorizing_member_receives_nothing (t : Nat) (ms : Members)
    (ss : Signers) (fee : Nat) (payments : List Payment) (child : Description)
    (share : Nat) (k : Key) :
    splitFee (identity (.group t ms)) (.group t ms) ss fee = some payments →
    (child, share) ∈ ms.toList → record child ss = none → k ∈ keys child →
    paidTo payments k = 0 := by
  intro h hm hf hk
  obtain ⟨r,ha,rfl⟩ := split_success _ _ _ _ _ h
  obtain ⟨_,hv,hr⟩ := (auth_iff _ _ _ _).mp ha
  have hn := ((valid_group t ms).mp hv).2.2.1
  apply unpaid_of_record_absent
  simp only [record] at hr
  split at hr
  · cases Option.some.inj hr
    exact signed_avoids_member ms ss child share k hn hm hk
      (fun r he => by rw [hf] at he; contradiction)
  · contradiction

-- T14: exact canonical ordered record, even when more than the threshold sign.
theorem group_record_exact (t : Nat) (ms : Members) (ss : Signers) (r : SigningRecord) :
    authorize (identity (.group t ms)) (.group t ms) ss = some r →
    ∃ signed, r = .group signed ∧
      signed.toList = ms.toList.filterMap (fun m =>
        (record m.1 ss).map (fun child => (m.2, child))) := by
  intro h
  have hr := ((auth_iff _ _ _ _).mp h).2.2
  simp only [record] at hr
  split at hr
  · cases Option.some.inj hr
    exact ⟨signedMembers ms ss, rfl, signed_list ms ss⟩
  · contradiction

-- T15
theorem recorded_keys_are_signers (expected : Identity) (d : Description)
    (ss : Signers) (r : SigningRecord) : authorize expected d ss = some r →
    ∀ k, k ∈ recordedKeys r → k ∈ ss ∧ k ∈ keys d := by
  intro h k hk
  have hr := ((auth_iff _ _ _ _).mp h).2.2
  exact ⟨record_signers d ss r hr k hk, (record_sublist d ss r hr).subset hk⟩

-- T16
theorem record_keys_unique (expected : Identity) (d : Description)
    (ss : Signers) (r : SigningRecord) : authorize expected d ss = some r →
    (recordedKeys r).Nodup := by
  intro h
  obtain ⟨_,hv,hr⟩ := (auth_iff _ _ _ _).mp h
  have hvp : shapeValid d = true ∧ (keys d).Nodup := by simpa [valid] using hv
  have hn := hvp.2
  exact hn.sublist (record_sublist d ss r hr)

-- T17: the literal proportional formula, with the remainder at index zero,
-- applies at each group reached by recursive splitRecorded.
theorem group_split_exact (signed : SignedMembers) (fee : Nat) :
    splitRecorded (.group signed) fee =
      (signed.toList.zipIdx).flatMap (fun (member, i) =>
        splitRecorded member.2
          (fee * member.1 / (signed.toList.map Prod.fst).sum +
            if i = 0 then fee -
              (signed.toList.map (fun m => fee * m.1 / (signed.toList.map Prod.fst).sum)).sum
            else 0)) := by
  exact exact_split_formula signed fee

-- T18: stronger than the signature-specific reading: a key belongs to at
-- most one direct member, whether or not that member authorizes.
theorem key_contributes_to_at_most_one_member (t : Nat) (ms : Members) (k : Key) :
    valid (.group t ms) = true →
      (ms.toList.filter (fun m => k ∈ keys m.1)).length ≤ 1 := by
  intro hv
  have hn := ((valid_group t ms).mp hv).2.2.1
  exact Nat.le_trans (member_occurrences ms k) ((List.nodup_iff_count.mp hn) k)

-- T19: repeated signer entries cannot inflate the distinct signing-key count.
theorem threshold_needs_distinct_signing_keys (t : Nat) (ms : Members) (ss : Signers) :
    Authorizes (.group t ms) ss → t ≤ (signingKeys (.group t ms) ss).length := by
  intro ha
  obtain ⟨hv,hc⟩ := (group_authorizes_iff t ms ss).mp ha
  have hc' : t ≤ (signedMembers ms ss).toList.length := by simpa [signed_count] using hc
  have hr : record (.group t ms) ss = some (.group (signedMembers ms ss)) := by
    simp [record, hc']
  have hs : shapeValid (.group t ms) = true :=
    (show shapeValid (.group t ms) = true ∧ (keys (.group t ms)).Nodup by simpa [valid] using hv).1
  have hsound := record_sound (.group t ms) ss _ hs hr
  exact Nat.le_trans hc' (Nat.le_trans (sound_member_count _ hsound.2)
    (recorded_length_le_signing (.group t ms) ss _ hv hr))

-- T20: global duplicate-key rejection, including overlap across nested groups.
theorem repeated_key_invalid (d : Description) (k : Key) :
    1 < (keys d).count k → valid d = false := by
  intro h
  have hn : ¬ (keys d).Nodup := by
    intro hn
    have hc := (List.nodup_iff_count.mp hn) k
    omega
  simp [valid, hn]

-- T21: successful authorization exposes all checks and the actual record.
theorem authorization_inversion (expected : Identity) (d : Description)
    (ss : Signers) (r : SigningRecord) :
    authorize expected d ss = some r ↔
      expected = identity d ∧ valid d = true ∧ record d ss = some r := by
  exact auth_iff expected d ss r

-- T22
theorem split_refusal_iff (expected : Identity) (d : Description) (ss : Signers) (fee : Nat) :
    splitFee expected d ss fee = none ↔ authorize expected d ss = none := by
  simp [splitFee]

-- T23
theorem signer_set_extensional (expected : Identity) (d : Description) (ss tt : Signers) :
    (∀ k, k ∈ ss ↔ k ∈ tt) → authorize expected d ss = authorize expected d tt := by
  intro h
  simp only [authorize, record_ext d ss tt h]

-- T24: a retained record can be replayed at credit time with any natural fee.
theorem recorded_split_replay (expected : Identity) (d : Description) (ss : Signers)
    (r : SigningRecord) (fee : Nat) : authorize expected d ss = some r →
    splitFee expected d ss fee = some (splitRecorded r fee) ∧
      totalPaid (splitRecorded r fee) = fee := by
  intro h
  exact ⟨by simp [splitFee, h], authorized_total expected d ss r fee h⟩

-- T25: raw record fixes the leaf constructor at every recursive call; the
-- public key-oracle result has exactly that same constructor, never a group.
theorem key_record_exact (k : Key) (ss : Signers) :
    record (.key k) ss = (if k ∈ ss then some (.key k) else none) ∧
    authorize (identity (.key k)) (.key k) ss =
      (if k ∈ ss then some (.key k) else none) := by
  simp [record, authorize]

-- T26: any finite path in the original description, not just a direct member.
theorem nonauthorizing_subgroup_at_any_depth_receives_nothing
    (expected : Identity) (root : Description) (ss : Signers) (fee : Nat)
    (payments : List Payment) (path : List Nat) (t : Nat) (members : Members) (k : Key) :
    splitFee expected root ss fee = some payments →
    atPath root path = some (.group t members) →
    authorizingCount members ss < t → k ∈ memberKeys members →
    paidTo payments k = 0 := by
  intro h hp hc hk
  obtain ⟨r,ha,rfl⟩ := split_success expected root ss fee payments h
  obtain ⟨_,hv,hr⟩ := (auth_iff _ _ _ _).mp ha
  have hn : (keys root).Nodup :=
    (show shapeValid root = true ∧ (keys root).Nodup by simpa [valid] using hv).2
  have hf : record (.group t members) ss = none := by
    have hlt : ¬ t ≤ (signedMembers members ss).toList.length := by
      rw [signed_count]; omega
    simp [record, hlt]
  exact unpaid_of_record_absent r fee k
    (record_avoids_path root ss r path (.group t members) k hn hr hp hf hk)

end OracleIdentity
