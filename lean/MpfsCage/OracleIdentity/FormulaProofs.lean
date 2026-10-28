import MpfsCage.OracleIdentity.FeeProofs
namespace OracleIdentity

theorem split_indexed (ms : SignedMembers) (f : Nat → Nat) (extra i : Nat) :
    splitMembers ms ((ms.toList.zipIdx i).map (fun (m,j) => f m.1 + if j = 0 then extra else 0)) =
    (ms.toList.zipIdx i).flatMap (fun (m,j) => splitRecorded m.2 (f m.1 + if j = 0 then extra else 0)) := by
  cases ms with
  | nil => simp [SignedMembers.toList, splitMembers]
  | cons s r rest =>
    simp only [SignedMembers.toList, List.zipIdx_cons, List.map_cons, List.flatMap_cons, splitMembers]
    rw [split_indexed rest f extra (i+1)]

theorem indexed_positive (xs : List (Nat × SigningRecord)) (f : Nat → Nat) (extra i : Nat)
    (hi : 0 < i) :
    (xs.zipIdx i).map (fun (m,j) => f m.1 + if j = 0 then extra else 0) = xs.map (fun m => f m.1) := by
  induction xs generalizing i with
  | nil => rfl
  | cons m xs ih =>
    have hn : i ≠ 0 := by omega
    simp [hn, ih (i+1) (by omega)]

theorem portions_indexed (xs : List (Nat × SigningRecord)) (fee : Nat) :
    portions fee (xs.map Prod.fst) =
    (xs.zipIdx).map (fun (m,j) => fee * m.1 / (xs.map Prod.fst).sum +
      if j = 0 then fee - (xs.map (fun m => fee * m.1 / (xs.map Prod.fst).sum)).sum else 0) := by
  cases xs with
  | nil => rfl
  | cons m xs =>
    simp only [portions, List.map_map, List.map_cons, List.zipIdx_cons, List.sum_cons]
    rw [indexed_positive xs (fun s => fee * s / (m.1 + (xs.map Prod.fst).sum)) _ 1 (by decide)]
    rfl

theorem exact_split_formula (signed : SignedMembers) (fee : Nat) :
    splitRecorded (.group signed) fee =
      (signed.toList.zipIdx).flatMap (fun (member, i) =>
        splitRecorded member.2
          (fee * member.1 / (signed.toList.map Prod.fst).sum +
            if i = 0 then fee -
              (signed.toList.map (fun m => fee * m.1 / (signed.toList.map Prod.fst).sum)).sum
            else 0)) := by
  rw [splitRecorded, portions_indexed]
  exact split_indexed signed (fun s => fee * s / (signed.toList.map Prod.fst).sum)
    (fee - (signed.toList.map (fun m => fee * m.1 / (signed.toList.map Prod.fst).sum)).sum) 0

end OracleIdentity
