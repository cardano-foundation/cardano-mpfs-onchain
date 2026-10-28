import MpfsCage.OracleIdentity.Paths

/-! Statement candidate. Admissions are intentional pending independent statement
    audit. No guarantee below is claimed proved. -/
namespace OracleIdentity

-- T01
theorem identity_injective (d e : Description) : identity d = identity e → d = e := by
  sorry

-- T02
theorem authorization_binds_identity (expected : Identity) (d : Description)
    (ss : Signers) (r : SigningRecord) :
    authorize expected d ss = some r → expected = identity d := by
  sorry

-- T03
theorem invalid_description_refused (expected : Identity) (d : Description)
    (ss : Signers) (fee : Nat) : valid d = false →
    authorize expected d ss = none ∧ splitFee expected d ss fee = none := by
  sorry

-- T04: exact valid-group domain, including nested validity and global uniqueness.
theorem group_valid_iff (t : Nat) (ms : Members) :
    valid (.group t ms) = true ↔
      0 < t ∧ t ≤ ms.toList.length ∧ (memberKeys ms).Nodup ∧
      ∀ d share, (d, share) ∈ ms.toList → 0 < share ∧ valid d = true := by
  sorry

-- T05
theorem key_authorizes_iff (k : Key) (ss : Signers) :
    Authorizes (.key k) ss ↔ k ∈ ss := by
  sorry

-- T06
theorem group_authorizes_iff (t : Nat) (ms : Members) (ss : Signers) :
    Authorizes (.group t ms) ss ↔
      valid (.group t ms) = true ∧ t ≤ authorizingCount ms ss := by
  sorry

-- T07
theorem authorization_monotone (d : Description) (ss more : Signers) :
    (∀ k, k ∈ ss → k ∈ more) → Authorizes d ss → Authorizes d more := by
  sorry

-- T08
theorem below_threshold_refused (t : Nat) (ms : Members) (ss : Signers) :
    authorizingCount ms ss < t →
      authorize (identity (.group t ms)) (.group t ms) ss = none := by
  sorry

-- T09: same behavior, not the same identity or record shape.
theorem key_is_single_member_case (k : Key) (share : Nat) (ss : Signers) (fee : Nat) :
    0 < share →
    (Authorizes (.key k) ss ↔ Authorizes (.group 1 (.cons (.key k) share .nil)) ss) ∧
    splitFee (identity (.key k)) (.key k) ss fee =
      splitFee (identity (.group 1 (.cons (.key k) share .nil)))
        (.group 1 (.cons (.key k) share .nil)) ss fee := by
  sorry

-- T10
theorem key_receives_whole_fee (k : Key) (ss : Signers) (fee : Nat) : k ∈ ss →
    splitFee (identity (.key k)) (.key k) ss fee = some [⟨k, fee⟩] := by
  sorry

-- T11
theorem split_conserves_fee (expected : Identity) (d : Description) (ss : Signers)
    (fee : Nat) (payments : List Payment) :
    splitFee expected d ss fee = some payments → totalPaid payments = fee := by
  sorry

-- T12
theorem unsigned_key_receives_nothing (expected : Identity) (d : Description)
    (ss : Signers) (fee : Nat) (payments : List Payment) (k : Key) :
    splitFee expected d ss fee = some payments → k ∉ ss → paidTo payments k = 0 := by
  sorry

-- T13: a signed key inside a failed subgroup is still unpaid on this branch.
theorem nonauthorizing_member_receives_nothing (t : Nat) (ms : Members)
    (ss : Signers) (fee : Nat) (payments : List Payment) (child : Description)
    (share : Nat) (k : Key) :
    splitFee (identity (.group t ms)) (.group t ms) ss fee = some payments →
    (child, share) ∈ ms.toList → record child ss = none → k ∈ keys child →
    paidTo payments k = 0 := by
  sorry

-- T14: exact canonical ordered record, even when more than the threshold sign.
theorem group_record_exact (t : Nat) (ms : Members) (ss : Signers) (r : SigningRecord) :
    authorize (identity (.group t ms)) (.group t ms) ss = some r →
    ∃ signed, r = .group signed ∧
      signed.toList = ms.toList.filterMap (fun m =>
        (record m.1 ss).map (fun child => (m.2, child))) := by
  sorry

-- T15
theorem recorded_keys_are_signers (expected : Identity) (d : Description)
    (ss : Signers) (r : SigningRecord) : authorize expected d ss = some r →
    ∀ k, k ∈ recordedKeys r → k ∈ ss ∧ k ∈ keys d := by
  sorry

-- T16
theorem record_keys_unique (expected : Identity) (d : Description)
    (ss : Signers) (r : SigningRecord) : authorize expected d ss = some r →
    (recordedKeys r).Nodup := by
  sorry

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
  sorry

-- T18: stronger than the signature-specific reading: a key belongs to at
-- most one direct member, whether or not that member authorizes.
theorem key_contributes_to_at_most_one_member (t : Nat) (ms : Members) (k : Key) :
    valid (.group t ms) = true →
      (ms.toList.filter (fun m => k ∈ keys m.1)).length ≤ 1 := by
  sorry

-- T19: repeated signer entries cannot inflate the distinct signing-key count.
theorem threshold_needs_distinct_signing_keys (t : Nat) (ms : Members) (ss : Signers) :
    Authorizes (.group t ms) ss → t ≤ (signingKeys (.group t ms) ss).length := by
  sorry

-- T20: global duplicate-key rejection, including overlap across nested groups.
theorem repeated_key_invalid (d : Description) (k : Key) :
    1 < (keys d).count k → valid d = false := by
  sorry

-- T21: successful authorization exposes all checks and the actual record.
theorem authorization_inversion (expected : Identity) (d : Description)
    (ss : Signers) (r : SigningRecord) :
    authorize expected d ss = some r ↔
      expected = identity d ∧ valid d = true ∧ record d ss = some r := by
  sorry

-- T22
theorem split_refusal_iff (expected : Identity) (d : Description) (ss : Signers) (fee : Nat) :
    splitFee expected d ss fee = none ↔ authorize expected d ss = none := by
  sorry

-- T23
theorem signer_set_extensional (expected : Identity) (d : Description) (ss tt : Signers) :
    (∀ k, k ∈ ss ↔ k ∈ tt) → authorize expected d ss = authorize expected d tt := by
  sorry

-- T24: a retained record can be replayed at credit time with any natural fee.
theorem recorded_split_replay (expected : Identity) (d : Description) (ss : Signers)
    (r : SigningRecord) (fee : Nat) : authorize expected d ss = some r →
    splitFee expected d ss fee = some (splitRecorded r fee) ∧
      totalPaid (splitRecorded r fee) = fee := by
  sorry

-- T25: raw record fixes the leaf constructor at every recursive call; the
-- public key-oracle result has exactly that same constructor, never a group.
theorem key_record_exact (k : Key) (ss : Signers) :
    record (.key k) ss = (if k ∈ ss then some (.key k) else none) ∧
    authorize (identity (.key k)) (.key k) ss =
      (if k ∈ ss then some (.key k) else none) := by
  sorry

-- T26: any finite path in the original description, not just a direct member.
theorem nonauthorizing_subgroup_at_any_depth_receives_nothing
    (expected : Identity) (root : Description) (ss : Signers) (fee : Nat)
    (payments : List Payment) (path : List Nat) (t : Nat) (members : Members) (k : Key) :
    splitFee expected root ss fee = some payments →
    atPath root path = some (.group t members) →
    authorizingCount members ss < t → k ∈ memberKeys members →
    paidTo payments k = 0 := by
  sorry

end OracleIdentity
