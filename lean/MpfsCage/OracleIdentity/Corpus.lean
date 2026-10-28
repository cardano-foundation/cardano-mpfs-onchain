import MpfsCage.OracleIdentity.Surface
import MpfsCage.OracleIdentity.Witnesses

namespace OracleIdentity.Corpus
open Witnesses

def scenario (id surface : String) (d : Description) (ss : Signers) (fee : Nat := 11) : Scenario :=
  ⟨id, "", surface, d, identity d, ss, fee, "bob"⟩

def witnessCorpus : List Scenario := [
  scenario "W01" "identity" demo signers,
  scenario "W02" "authorize" demo signers,
  { scenario "W02-mismatch" "authorize" demo signers with expected := identity bob },
  scenario "W03" "splitFee" zeroShare ["alice"],
  scenario "W04" "valid" demo signers,
  scenario "W04-empty" "valid" emptyGroup [],
  scenario "W04-high" "valid" highThreshold ["alice"],
  scenario "W05" "authorize" alice ["alice"],
  scenario "W05-absent" "authorize" alice [],
  scenario "W06" "authorize" demo signers,
  scenario "W07-small" "authorize" demo ["alice", "carol"],
  scenario "W07" "authorize" demo signers,
  scenario "W08" "authorize" demo ["carol", "dave"],
  scenario "W09" "splitFee" singleton ["alice"],
  scenario "W10" "splitFee" alice ["alice"],
  scenario "W11" "totalPaid" demo signers,
  scenario "W12" "paidTo" demo signers,
  { scenario "W13" "paidTo" partialGroup ["alice", "carol"] with key := "carol" },
  scenario "W14" "authorize" demo allSigners,
  scenario "W15" "recordedKeys" demo signers,
  scenario "W16" "recordedKeys" demo signers,
  scenario "W17" "splitRecorded" demo signers,
  scenario "W17-leading-unsigned" "splitFee" demo ["bob", "carol"] 9,
  scenario "W18" "valid" demo signers,
  scenario "W19" "authorize" demo ["alice", "alice", "carol"],
  scenario "W20" "authorize" duplicate ["alice"],
  scenario "W21" "authorize" demo signers,
  scenario "W22" "splitFee" demo [],
  scenario "W23" "authorize" alice ["alice", "carol"],
  scenario "W23-reordered" "authorize" alice ["carol", "alice"],
  scenario "W24-zero" "splitRecorded" demo signers 0,
  scenario "W24" "splitRecorded" demo signers 11,
  scenario "W24-later" "splitRecorded" demo signers 17,
  scenario "W25" "authorize" alice ["alice"],
  scenario "W25-absent" "authorize" alice [],
  scenario "W25-nested" "authorize" demo signers,
  { scenario "W26" "paidTo" deepGroup ["alice", "carol"] with key := "carol" },
  { scenario "W27" "paidTo" demo signers with key := "alice" },
  scenario "W28" "totalPaid" demo signers,
  { scenario "W28-carol" "paidTo" demo signers with key := "carol" },
  { scenario "W28-dave" "paidTo" demo signers with key := "dave" },
  scenario "W29" "recordedKeys" alice ["alice"],
  scenario "W29-group" "recordedKeys" demo signers,
  scenario "W30" "recordedKeys" deepGroup ["alice", "carol"],
  scenario "W31" "signingKeys" deepGroup ["alice", "alice", "carol", "outsider"],
  scenario "W31-absent" "signingKeys" alice []]

/-- Each M row names one proposed source-atom edit, not a claimed mutation run.
    The input is replayed unchanged against the baseline and the edited model. -/
def mutant (id edit surface : String) (d : Description) (ss : Signers) : Scenario :=
  { scenario id surface d ss with mutant := edit }

def mutantCorpus : List Scenario := [
  mutant "M01" "identity: replace description by key alice" "identity" demo signers,
  mutant "M01-other" "identity: replace description by key alice" "identity" bob ["bob"],
  { mutant "M02" "authorize: omit identity equality" "authorize" demo signers
    with expected := identity bob },
  mutant "M03" "authorize: omit valid guard" "splitFee" zeroShare ["alice"],
  mutant "M04" "shapeValid: omit positive-threshold guard" "valid" emptyGroup [],
  mutant "M05" "record key: return some without membership" "authorize" alice [],
  mutant "M06" "record group: count shares instead of members" "authorize" demo ["alice"],
  mutant "M07-small" "record group: replace threshold <= count by equality" "authorize" demo ["alice", "carol"],
  mutant "M07" "record group: replace threshold <= count by equality" "authorize" demo signers,
  mutant "M08" "record group: lower threshold by one" "authorize" flat ["alice"],
  mutant "M09" "splitRecorded group: pass fee minus one to portions" "splitFee" singleton ["alice"],
  mutant "M10" "splitRecorded key: pay fee minus one" "splitFee" alice ["alice"],
  mutant "M11" "portions: discard remainder" "totalPaid" demo signers,
  mutant "M12" "signedMembers none: retain a fabricated bob leaf" "paidTo" demo signers,
  { mutant "M13" "splitRecorded group: append a one-unit carol payout" "paidTo"
      partialGroup ["alice", "carol"] with key := "carol" },
  mutant "M14" "record group: return empty record after threshold check" "authorize" demo allSigners,
  mutant "M15" "record key: record attacker instead of signing key" "recordedKeys" alice ["alice"],
  mutant "M16" "signedMembers some: duplicate the retained member" "recordedKeys" demo signers,
  mutant "M17" "portions: divide equally instead of by shares" "splitRecorded" demo signers,
  mutant "M18" "valid: omit global key uniqueness" "valid" duplicate ["alice"],
  mutant "M19" "record group: lower threshold by one" "authorize" demo ["alice"],
  mutant "M20" "valid: omit global key uniqueness" "valid" duplicate ["alice"],
  mutant "M21" "authorize: substitute a fabricated key record on success" "authorize" demo signers,
  mutant "M22" "splitFee: return some empty payments on refused authorization" "splitFee" demo [],
  mutant "M23" "record key: test only the first signer" "authorize" alice ["alice", "carol"],
  mutant "M23-reordered" "record key: test only the first signer" "authorize" alice ["carol", "alice"],
  mutant "M24" "splitFee: replay at fee plus one" "splitFee" demo signers,
  mutant "M25" "record key: replace key record by singleton group of share one" "authorize" alice ["alice"],
  mutant "M25-nested" "record key: replace key record by singleton group of share one" "authorize" demo signers,
  { mutant "M26" "splitRecorded group: append a one-unit carol payout" "paidTo"
      deepGroup ["alice", "carol"] with key := "carol" },
  { mutant "X45-T27" "paidTo: replace key equality by key equality and False" "paidTo" demo signers with key := "alice" },
  { mutant "X45-T28" "paidTo: replace key equality by key equality and False" "paidTo" alice ["alice"] with key := "alice" },
  mutant "X47-T29" "recordedKeys key: return empty list" "recordedKeys" alice ["alice"],
  mutant "X47-T30" "recordedKeys key: return empty list" "recordedKeys" deepGroup ["alice", "carol"],
  mutant "X48-T31" "signingKeys: omit signer filter" "signingKeys" alice []]

end OracleIdentity.Corpus
