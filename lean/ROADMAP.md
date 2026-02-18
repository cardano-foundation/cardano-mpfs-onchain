# Caging Proof Roadmap

## Goal

Prove that **caging works**: funds locked in the cage can only move through legitimate phase transitions, and no actor can steal or bypass the protocol.

## Current State

**Category 13 (Phase Exclusivity)** is fully proven in `MpfsCage/Phases.lean`:
- 6 theorems, zero `sorry`, verified by `omega`
- Corresponding Aiken fuzz tests in `validators/cage.ak`

## Ledger Assumptions (Axioms)

The following must be stated as axioms — they are guarantees the Cardano ledger provides:

1. **Signature integrity** — `extra_signatories` contains only keys that actually signed
2. **UTxO uniqueness** — an `OutputReference` can only be consumed once
3. **Validity range honesty** — tx is only valid if current slot falls within its validity range
4. **Minting policy execution** — minting policy runs whenever tokens with that policy appear in mint field
5. **Script execution for spending** — any UTxO at a script address requires the script to run
6. **Input ordering stability** — `tx.inputs` has deterministic ordering (lexicographic by OutputReference)
7. **Value conservation** — total inputs = total outputs + fee (plus minting/burning)
8. **Inline datum delivery** — inline datums attached to UTxOs are faithfully delivered in script context
9. **Min-ADA enforcement** — ledger enforces minimum ADA requirements on outputs

## Remaining Property Categories

From `spec/CageDatum.lean` (16 categories total):

| # | Category | Status | Difficulty |
|---|----------|--------|------------|
| 1 | Token uniqueness (`assetName` determinism + injectivity) | Trivial + axiom (SHA2-256) | Low |
| 2 | Minting integrity (`ValidMint`) | `sorry` in spec | Medium |
| 3 | Ownership & authorization | Definitions only | Low |
| 4 | Token confinement | Definition only | Low |
| 5 | Ownership transfer (intentionally unchecked) | `True` | Done (trivial) |
| 6 | State integrity (MPF root fold) | `sorry` in spec | High — needs MPF axioms |
| 7 | Proof consumption | Definition only | Low |
| 8 | Request binding | Definition only | Low |
| 9 | Datum-redeemer type safety | Truth table | Low |
| 10 | Datum presence | Definition only | Low |
| 11 | End / burn integrity | Definition only | Low |
| 12 | Token extraction | Abstract (modeled via field) | Low |
| 13 | **Phase exclusivity** | **Done** (Phases.lean) | — |
| 14 | Reject / DDoS protection (`ValidReject`) | `sorry` in spec | Medium |
| 15 | Fee enforcement | `sorry` in spec | Medium |
| 16 | Migration (`ValidMigration`) | `sorry` in spec | Medium |

## Suggested Order

1. **Categories 3, 4, 7-12** — low-hanging fruit, mostly definitions and simple propositions
2. **Category 14 (ValidReject)** — builds on Phase 3 (already proven exclusive)
3. **Categories 2, 15, 16** — minting, fees, migration (medium complexity)
4. **Category 6 (MPF root integrity)** — hardest, needs `mpfApply` axiomatized

## The Big Theorem

The ultimate goal:

> **Given the 9 ledger axioms, the cage validator ensures that for any transaction consuming a cage UTxO, exactly one of {Modify, Reject, Retract, End} succeeds, the token stays confined, the MPF root is correctly updated (or preserved), and refunds are correctly paid.**

This is `validSpend` in the spec — currently a definition with elided proofs. Filling all 16 categories would complete it.

## Trust Layers

| Layer | What it proves | Gap |
|-------|---------------|-----|
| Lean proofs | Properties hold for the *model* | Model must match Aiken code |
| Aiken fuzz tests | Properties hold for the *actual code* (empirically) | Not exhaustive |
| IOG Aiken→Lean transpiler (future) | Model is *extracted from* actual code | Trusts Aiken compiler |
| Plutus Core verification (future) | Properties hold for *deployed bytecode* | Full chain of trust |
