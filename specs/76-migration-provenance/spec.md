# Spec — Fix migration mint path forging cage tokens (#76)

Issue: https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/76
Severity: fund theft (critical)

## Problem

`validateMigration` (`validators/state.ak:231-247`) accepts an
attacker-controlled `oldPolicy` from the `Migration` redeemer and enforces
only a `-1` burn under that arbitrary policy, a `+1` mint under the state
policy, and that the output goes to the state script holding a `StateDatum`
with *any* `State { .. }`. There is:

- no allowlist constraining `oldPolicy` to an audited predecessor,
- no owner authorization,
- no constraint on the migrated `State` fields (attacker freely picks
  `owner` and `tip`).

Because `Minting` derives the asset name from a consumed seed
(`assetName(seed)`) but `Migrating` copies the name from the burned token,
an attacker can:

1. Deploy a trivial always-true policy `P_atk`, mint `(P_atk, N)` where `N`
   is a victim cage's asset name.
2. `Migrating`-burn `(P_atk, N)`, mint `(statePolicyId, N)` into a state
   output whose `owner = attacker`, `tip = t'` (≠ victim tip). Passes today.
3. The forged UTxO now carries a genuine `(statePolicyId, N)` token, so it
   satisfies every `carriesStateToken` authentication in `request.ak`.
4. `Sweep(forgedState)` against the victim's pending Request UTxOs:
   `processableRequest` returns `False` (tip mismatch), so `expect !protected`
   passes, and `validateSweep` imposes no output constraints — the attacker
   drains every contributor deposit at the victim cage.

`properties.md §3` only defends against *foreign-policy* same-name fakes; the
migration hole produces a *same-policy* fake that §3 does not catch.

## Root cause

Token identity under the state policy (`properties.md §1`) is only guaranteed
by the seed-derived `Minting` path. `Migrating` bypasses seed derivation and
accepts arbitrary provenance, so it can manufacture a genuine state-policy
token for any asset name with no authorization.

## P1 user story

As a cage contributor, my deposit at a cage's request address must be
reclaimable only by that cage's legitimate oracle (or by me via Retract), so
that no third party can forge a state token and sweep my funds.

## User stories

- As a cage operator migrating my cage to an audited new validator version, I
  can burn my old state token and mint the new one, preserving my cage's
  identity and state, only with my own signature.
- As a contributor, an attacker cannot mint a genuine state-policy token for
  my cage's asset name without spending an audited predecessor state UTxO that
  its own owner authorized.
- As an auditor, a cage's state policy id transitively proves the whole
  migration chain back to a seed-derived genesis token.

## Functional requirements

- **FR1 — Predecessor allowlist.** The `state` validator is parameterized by
  an immutable allowlist of predecessor state-policy ids
  (`previousPolicies: List<PolicyId>`). `validateMigration` must reject any
  `oldPolicy` not in that list. A genesis cage is deployed with an empty
  allowlist, making migration impossible into it — tokens there exist only via
  the seed `Minting` path.
- **FR2 — Provenance by spend.** Migration must spend the predecessor state
  UTxO that actually carries `(oldPolicy, tokenId)` (not merely reference the
  burn quantity). The migrated `State` is read from that predecessor input.
- **FR3 — Owner authorization.** The predecessor `State`'s owner must
  authorize the migration, reusing the existing ownership rule
  (`validateOwnership`: `owner` signature, plus the staking-script withdrawal
  when `stake_script` is set).
- **FR4 — Full field preservation.** The migrated output `State` must equal
  the predecessor `State` in every field: `owner`, `stake_script`, `root`,
  `tip`, `process_time`, `retract_time`. Migration is purely a re-policy
  operation; it cannot introduce an owner/tip mismatch. (Ownership transfer
  and parameter changes remain available through the existing `Modify` path,
  not through migration.)
- **FR5 — Existing invariants retained.** Migration still enforces exactly
  `-1` of `(oldPolicy, tokenId)` and `+1` of `(statePolicyId, tokenId)` in the
  mint field, output[0] at the state script address, and output[0] holding the
  minted token, with no extra state-policy assets.
- **FR6 — Identity origin.** Asset-name identity under the state policy is
  creatable only via seed derivation (`Minting`) or via authenticated
  provenance from an allowlisted predecessor (`Migrating`); no path accepts an
  arbitrary `oldPolicy`.

## Negative tests (acceptance)

- Migration with an `oldPolicy` not in `previousPolicies` fails.
- Migration without the predecessor state input spent fails.
- Migration without the predecessor owner's signature fails.
- Migration whose output `State` differs from the predecessor in `owner`,
  `tip`, `root`, `stake_script`, `process_time`, or `retract_time` fails.
- A forged same-policy token produced by an unauthenticated migration cannot
  pass `Sweep` / `Retract` / `Modify` against a victim cage (regression of the
  exploit chain).
- `cage.tests.ak` migration tests use a constrained, allowlisted predecessor
  rather than the arbitrary constant `"old_policy_id"`
  (`cage.tests.ak:1462`), and the happy path preserves predecessor fields.

## Success criteria

- [ ] `aiken check` passes with the new negative tests and the corrected happy
      path.
- [ ] The exploit sequence from the issue no longer type-checks / validates:
      an unauthenticated `oldPolicy` cannot mint a genuine state token.
- [ ] `docs/architecture/properties.md` §1/§2 (and a new migration-provenance
      note) reflect that migration proves provenance from an audited
      predecessor.
- [ ] Haskell blueprint/config/boot apply the new `state` validator parameter
      so the off-chain builders still produce a valid script hash / policy id.
- [ ] Lean `ValidMigration` is strengthened to require allowlist membership,
      predecessor-owner authorization, and field preservation, keeping the
      formal model aligned with the Aiken validator.

## Non-goals

- Redesigning the seed-based `Minting` path (sound).
- A full off-chain migration transaction builder / operator ergonomics
  (tracked separately). This ticket only ensures the off-chain layer still
  applies the new parameter and hashes the state script correctly.

## Design decisions (locked with operator)

- **Allowlist AND owner signature AND full-field preservation** — all three,
  not either/or. Belt-and-suspenders: the allowlist alone already forces the
  attacker to spend a genuine predecessor (whose own `End`/spend path demands
  the predecessor owner's signature), but the new validator independently
  re-checks owner authorization and field preservation so it does not depend
  on any predecessor generation's burn-path strength.
- **Allowlist carried as a validator parameter** (not datum): immutable, binds
  to the state policy id, and makes the policy id a transitive proof of the
  migration chain.
