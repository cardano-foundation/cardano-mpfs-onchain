# Plan — #76 migration provenance

Spec: `spec.md`. Two bisect-safe slices. Slice 1 is the security fix and is
self-contained (Aiken + Aiken tests + docs). Slice 2 keeps the off-chain layer
producing a correct state policy id after the validator gains a parameter.

## Architecture decision

The state validator becomes parameterized by an **immutable predecessor
allowlist**:

```
validator state(previousPolicies: List<PolicyId>) { mint(..) spend(..) }
```

Why a parameter and not a datum: it is immutable, binds into the state script
hash (= state policy id), and makes the policy id a transitive proof of the
whole migration chain back to a seed-derived genesis. A genesis cage is
deployed with `previousPolicies = []`, so migration into it is impossible and
its tokens exist only via the seed `Minting` path.

The allowlist is the load-bearing defense. Without it, provenance-by-spend +
owner-sig + field-preservation are all trivially satisfiable by an attacker
who authored the fake predecessor datum himself (he controls an always-true
`oldPolicy`). Requiring `oldPolicy ∈ previousPolicies` forces the burned token
to be a genuine audited predecessor whose asset name was seed-derived under a
policy the attacker does not control — so he cannot manufacture
`(predecessor_policy, victim_name)`.

## Target `validateMigration` shape (slice 1)

```
pub fn validateMigration(previousPolicies, migration, policyId, tx) {
  let Migration { oldPolicy, tokenId } = migration
  let Transaction { outputs, mint, inputs, .. } = tx
  // FR1: allowlist
  expect list.has(previousPolicies, oldPolicy)
  // FR5: mint integrity (unchanged)
  expect exactQuantity(oldPolicy, mint, tokenId, -1)
  expect exactQuantity(policyId, mint, tokenId, 1)
  // FR2: predecessor state UTxO carrying (oldPolicy, tokenId) is SPENT
  expect Some(predIn) =
    find(inputs, fn(i) { exactQuantity(oldPolicy, i.output.value, tokenId, 1) })
  let predState = readState(predIn)          // shared.readState
  // FR3: predecessor owner authorizes (owner sig + stake-script withdrawal)
  expect validateOwnership(predState, tx)
  // FR5: output[0] to state script, holds the new token, StateDatum
  expect Some(output) = head(outputs)
  expect address.Script(target) = output.address.payment_credential
  expect target == policyId
  expect exactQuantity(policyId, output.value, tokenId, 1)
  expect InlineDatum(outDatum) = output.datum
  expect StateDatum(outState) = outDatum
  // FR4: full field preservation — output State == predecessor State
  expect outState == predState
  True
}
```

Notes:
- `readState`, `validateOwnership` already exist in `shared.ak`.
- `outState == predState` requires `State` to support `==`; Aiken derives
  structural equality for records, so this compares all six fields at once. If
  the compiler rejects `==` on the record, fall back to field-by-field
  `expect`s (owner, stake_script, root, tip, process_time, retract_time).
- The `mint` dispatch arm in `validator state` passes `previousPolicies`
  through: `Migrating(m) -> validateMigration(previousPolicies, m, policyId, tx)`.
  `Minting`/`Burning` ignore the parameter.

## Slice 1 — Aiken validator + tests + docs (security fix)

Files:
- `validators/state.ak` — add `previousPolicies` param to `validator state`;
  thread it into the `Migrating` arm; rewrite `validateMigration` per above.
  Add `list.has` / `find` / `readState` / `validateOwnership` imports as needed.
- `validators/cage.tests.ak` — update the 3 call sites (`state.state.mint`,
  `state.state.spend` ×2) to pass a `previousPolicies` argument. Rework the
  migration fixtures (`old_policy`, `migrate_*`) so:
  - `old_policy` is an allowlisted predecessor (passed in the param list);
  - the tx spends a predecessor state input carrying `(old_policy, token)` with
    a `StateDatum` owner that signs (`extra_signatories`);
  - `migrate_output`'s `State` equals the predecessor `State` in all fields.
  Add negative tests:
  - `migrate_old_policy_not_allowlisted() fail`
  - `migrate_no_predecessor_input() fail`
  - `migrate_missing_owner_signature() fail`
  - `migrate_changes_owner() fail`, `migrate_changes_tip() fail`
  - `migrate_forged_token_cannot_sweep() fail` — reconstruct the issue's
    exploit chain (forge via unauthenticated migration, then Sweep a victim
    request) and assert it no longer validates.
  Keep the existing intent tests (`migrate_no_burn`, `migrate_to_wallet`,
  `migrate_wrong_old_policy`, `migrate_extra_state_policy_asset`,
  `migrate_output_must_hold_token`) passing under the new signature.
- `docs/architecture/properties.md` — update §1/§2 wording and add a
  "Migration Provenance" property: `oldPolicy` must be allowlisted, predecessor
  state spent + owner-authorized, fields preserved.
- `spec/CageDatum.lean` — strengthen `ValidMigration` to require allowlist
  membership, predecessor-owner authorization, and field preservation. (Not
  compiled by CI — the lean gate builds only `lean/MpfsCage/*`; this keeps the
  model doc honest. No `sorry` regressions.)

Gate (slice 1):
```
nix build --quiet \
  .#checks.x86_64-linux.aiken-check \
  .#checks.x86_64-linux.aiken-build \
  .#checks.x86_64-linux.cage-test-vectors \
  .#checks.x86_64-linux.vectors-freshness
```
`aiken check` is the primary proof. If `cage-test-vectors` / `vectors-freshness`
depend on the blueprint hash, regenerate vectors as part of this slice.

## Slice 2 — Haskell off-chain applies the new state parameter

The state script now expects one parameter before it is a complete script.
Every site that derives the state bytes/hash from `extractCompiledCode "state"`
must apply `previousPolicies` (empty list for a genesis cage) first, else
`cfgScriptHash` / the boot address are wrong and the E2E devnet boot fails.

Files:
- `haskell/lib/Cardano/MPFS/Cage/Blueprint.hs` — add
  `applyPreviousPolicies :: [ByteString] -> ShortByteString -> ShortByteString`
  building the `Data` argument `List [B pid, ...]` and calling `applyDataParam`.
  Export it.
- `haskell/lib/Cardano/MPFS/Cage/Config.hs` — decide carriage: simplest is to
  store already-applied `cageScriptBytes` (apply at config construction) so
  downstream `mkCageScript` / `computeScriptHash (cageScriptBytes cfg)` stay
  unchanged. Optionally add a `cfgPreviousPolicies :: [PolicyId]` field for
  provenance/record-keeping; genesis default `[]`.
- `haskell/e2e-test/Cardano/MPFS/Cage/E2E/CageSpec.hs` — in `cageCfg` /
  `withE2E`, apply `applyPreviousPolicies []` to `stateBytes` before storing in
  the config (and before `computeScriptHash`), matching the runtime blueprint.
- Any lib/app config constructor with the same pattern (driver greps for
  `computeScriptHash`, `cageScriptBytes`, `extractCompiledCode "state"`).

Gate (slice 2):
```
nix build --quiet .#checks.x86_64-linux.library .#checks.x86_64-linux.cage-tests \
  .#checks.x86_64-linux.lint
nix run .#cage-tests            # haskell QuickCheck
nix run .#cage-tests-e2e        # devnet boot/modify/end must still pass
```
The E2E job is the real proof that the applied state hash matches the on-chain
script. It is slow (spins a devnet) but runnable locally via `nix run`.

## Out of scope

- A migration transaction *builder* in Haskell (no `TxBuilder/Migrate.hs`
  exists; not required by this fix). Only hash/param correctness is in scope.
- Redesigning `Minting` (sound).

## Risks

- `State` structural `==` in Aiken — fall back to field-by-field if the
  compiler rejects it (see note above).
- If `cage-test-vectors` pins a blueprint/script hash, slice 1 must regenerate
  vectors so `vectors-freshness` stays green.
- E2E is the only cross-language check that the applied parameter is correct;
  do not skip it for slice 2.
