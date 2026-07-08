# Tasks — #76 migration provenance

Two slices, one bisect-safe commit each. `T76-S1` = slice 1 tasks, etc.

## Slice 1 — Aiken validator + tests + docs (security fix)

- [X] T76-S1 Parameterize `validator state` with `previousPolicies: List<PolicyId>` and thread it into the `Migrating` dispatch arm (`validators/state.ak`).
- [X] T76-S1 Rewrite `validateMigration` to enforce FR1–FR5: allowlist membership, mint integrity, predecessor state input spent + read, predecessor-owner authorization (`validateOwnership`), output-to-script + holds-token, and full field preservation (`outState == predState`, or field-by-field fallback).
- [X] T76-S1 Update the 3 `state.state.mint` / `state.state.spend` call sites in `cage.tests.ak` to pass `previousPolicies`.
- [X] T76-S1 Rework migration fixtures: allowlisted `old_policy`, a spent predecessor state input with a signing owner, field-preserving `migrate_output`; happy path `canMigrate` passes.
- [X] T76-S1 Add negative tests: not-allowlisted, no-predecessor-input, missing-owner-signature, changed-owner, changed-tip.
- [X] T76-S1 Add `migrate_forged_token_cannot_sweep` regression reproducing the issue's exploit chain and asserting it fails.
- [X] T76-S1 Keep existing intent tests passing under the new signature (`migrate_no_burn`, `migrate_to_wallet`, `migrate_wrong_old_policy`, `migrate_extra_state_policy_asset`, `migrate_output_must_hold_token`).
- [X] T76-S1 Update `docs/architecture/properties.md` §1/§2 and add a Migration Provenance property.
- [X] T76-S1 Strengthen `spec/CageDatum.lean` `ValidMigration` (allowlist + owner auth + field preservation); no new `sorry`.
- [X] T76-S1 Regenerate test vectors if the blueprint hash moved, so `vectors-freshness` is green.
- [X] T76-S1 Gate green: `aiken-check`, `aiken-build`, `cage-test-vectors`, `vectors-freshness`.
- [X] T76-S1 One commit `fix(76): authenticate migration provenance in state validator` with `Tasks: T76-S1`.

## Slice 2 — Haskell off-chain applies the new state parameter

- [X] T76-S2 Add + export `applyPreviousPolicies :: [ByteString] -> ShortByteString -> ShortByteString` in `Blueprint.hs` (builds `List [B pid, …]`, calls `applyDataParam`).
- [X] T76-S2 Apply the (empty) allowlist to state bytes at config construction so `cageScriptBytes` / `cfgScriptHash` reflect the parameterized script; optionally record `cfgPreviousPolicies` in `Config.hs`.
- [X] T76-S2 Update `CageSpec.hs` (`cageCfg` / `withE2E`) to apply `applyPreviousPolicies []` before hashing/storing state bytes.
- [X] T76-S2 Grep and fix any other `computeScriptHash`/`cageScriptBytes`/`extractCompiledCode "state"` site with the same pattern (lib/app).
- [X] T76-S2 Gate green: `library`, `cage-tests`, `lint`, `nix run .#cage-tests`, and `nix run .#cage-tests-e2e` (devnet boot/modify/end still valid with the applied state hash).
- [X] T76-S2 One commit `fix(76): apply predecessor-allowlist parameter to state script off-chain` with `Tasks: T76-S2`.

## Finalization

- [ ] Audit PR #96 body matches delivered behavior; update if drifted.
- [ ] Drop `gate.sh` if bootstrapped; `gh pr ready 96`.
- [ ] CI green on all jobs (build, tests, e2e, lint, lean).
