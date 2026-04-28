# Security Properties

This page documents the security properties enforced by the MPF Cage
validators. The properties are covered by the Aiken test suite, Haskell
encoding tests, and the Lean models in `lean/MpfsCage`.

Run `aiken check` (or `just test`) for validator tests. Run `lake build` in
`lean/` for the formal phase, token, and split-validator proofs.

## Roles

- **Oracle**: the state owner. Can modify state, reject expired or dishonest
  requests through `Modify(Rejected)`, sweep malformed request-address UTxOs,
  and end the cage.
- **Requester**: the request owner. Can submit requests and retract them during
  Phase 2.
- **Observer**: reconstructs MPF state from chain history.

## On-chain vs Off-chain Guarantees

| Guarantee | Enforced by |
|---|---|
| Token identity is unique | State mint policy consumes the seed UTxO |
| State policy moves exactly one state-policy asset | `exactQuantity` |
| State UTxO references are authentic | `(statePolicyId, cageToken)` check |
| Only the oracle updates or ends state | `State.owner` signature |
| Only the requester retracts a request | `Request.requestOwner` signature |
| Request updates carry valid MPF proofs | On-chain MPF proof verification |
| Output root matches proof computation | State `Modify` fold |
| Requesters can reclaim Phase 2 requests | Request `Retract` |
| Expired or dishonest requests can be rejected | `Modify(Rejected)` |
| Malformed request-address UTxOs can be cleaned up | Request `Sweep` |
| Processable requests cannot be swept | `processableRequest` guard |
| Phase windows are exclusive | Validity-range checks and Lean proofs |
| Oracle honestly chooses which valid requests to process | Off-chain behavior |
| Proofs are generated against the intended trie state | Off-chain behavior |
| History is reconstructable | Ledger property |

## 1. Token Uniqueness

**Invariant:** a cage token asset name is derived from a consumed
`OutputReference`.

The asset name is `SHA2-256(tx_id ++ output_index)`. Since the seed UTxO can
be consumed only once, the ledger gives uniqueness.

Representative tests: `assetName_deterministic`,
`assetName_different_txid`, `assetName_different_index`,
`prop_assetName_deterministic`.

## 2. State-Policy Mint and Burn Integrity

**Invariant:** every mint, migration, and burn under the global state policy
moves exactly one asset under that policy.

`Minting(seed)` requires exactly `+1` of `assetName(seed)`.
`Migrating` requires exactly `-1` under the old policy and `+1` under the
state policy. `Burning(tokenId)` requires exactly `-1` of that token. Extra
assets under the state policy are rejected.

Representative tests: `canMint`, `mint_missing_input`,
`mint_quantity_two`, `mint_extra_state_policy_asset`, `canMigrate`,
`end_happy`, `end_with_extra_state_policy_asset`.

Lean theorem: `exactQuantity_rejects_extra_same_policy_asset`.

## 3. Split Validator Authentication

**Invariant:** request spends authenticate the referenced state UTxO by both
policy ID and asset name.

The request validator is parameterized by `(statePolicyId, cageTokenName)`.
It rejects fake state UTxOs that carry the same asset name under a foreign
policy.

Representative tests: `contribute_rejects_foreign_policy_state_same_asset`,
`wrong_request_parameter_rejects_this_cage_token`.

Lean theorems: `contribute_rejects_foreign_policy_state_same_asset`,
`wrong_request_parameter_rejects_cage_token`.

## 4. Contribute Cannot Bypass State Modify

**Invariant:** `Contribute(stateRef)` requires `stateRef` in regular
transaction inputs, not only reference inputs, and the state input must be
spent with `Modify`.

This prevents a request UTxO from being consumed without state `Modify`
running the root and refund checks.

Representative tests: `contribute_missing_ref`,
`contribute_reference_only_state_rejected`,
`contribute_with_state_end_rejected`.

Lean theorems: `contribute_rejects_reference_only_state`,
`contribute_rejects_state_spent_without_modify`.

## 5. Ownership and Authorization

**Invariant:** privileged operations require the relevant owner signature.

| Operation | Required signer |
|---|---|
| State `Modify` | `State.owner` |
| State `End` | `State.owner` |
| Request `Sweep` | current `State.owner` |
| Request `Retract` | `Request.requestOwner` |
| Request `Contribute` | permissionless, but authenticated against state |

Representative tests: `modify_missing_signature`, `end_missing_signature`,
`sweep_missing_signature`, `retract_wrong_signer`,
`prop_retract_requires_owner`, `prop_modify_requires_owner`.

## 6. State Confinement and Immutability

**Invariant:** after `Modify`, the state output remains at the state script,
carries the same cage token, and preserves `tip`, `process_time`, and
`retract_time`.

The owner field is intentionally mutable, allowing oracle rotation through a
normal `Modify`.

Representative tests: `modify_wrong_address`, `modify_owner_transfer`,
`modify_wrong_token_in_output`, `modify_tip_changes`,
`modify_process_time_changes`, `modify_retract_time_changes`.

## 7. MPF Root Integrity

**Invariant:** the output root equals the result of folding matching request
actions over the input root.

`UpdateAction(proof)` applies an MPF insert, delete, or update proof.
`Rejected` leaves the root unchanged for that request.

Representative tests: `canCage`, `modify_wrong_root`,
`modify_no_requests`, `modify_skip_other_token`, `modify_too_few_proofs`,
`modify_extra_proofs`.

## 8. Refund and Tip Accounting

**Invariant:** processed request owners are refunded according to the state
validator's equation:

```text
total request input lovelace - transaction fee - number_of_requests * state.tip
```

The request tip must match `state.tip` for processable requests.

Representative tests: `modify_with_refund`, `modify_missing_refund`,
`modify_insufficient_refund`, `modify_wrong_refund_address`,
`modify_zero_fee`, `modify_fee_mismatch`.

## 9. Datum-Redeemer Type Safety

**Invariant:** each validator path accepts only the datum and redeemer shapes
it owns.

| Validator | Accepted redeemers |
|---|---|
| state | `Modify`, `End` |
| request | `Contribute`, `Retract`, `Sweep` |

Representative tests: `retract_on_state_datum`, `contribute_on_state_datum`,
`modify_on_request_datum`, `end_on_request_datum`, `state_sweep_rejected`.

## 10. Time-Gated Phases

**Invariant:** each request is in exactly one lifecycle phase for point
validity ranges, and straddling ranges are rejected by the validators.

```text
submitted_at          + process_time       + process_time + retract_time
    |                        |                        |
    |   Phase 1: Modify      |   Phase 2: Retract     |   Phase 3: Rejected
```

Representative tests: `retract_in_phase1`, `retract_happy`,
`retract_in_phase3`, `contribute_in_phase2`, `contribute_in_phase3`,
`modify_in_phase2`.

Lean theorems: `phase1_phase2_exclusive`,
`phase1_honest_not_rejectable`, `phase2_honest_not_rejectable`,
`phase_coverage_point`.

## 11. Request Sweep

**Invariant:** the state owner can sweep request-address garbage, but cannot
sweep a request that state `Modify` can process.

Protected requests must have matching token, matching tip, and enough lovelace
to cover `state.tip`. Wrong-token, no-datum, mismatched-tip, and underfunded
matching-token UTxOs are sweepable.

Representative tests: `sweep_no_datum`, `sweep_wrong_token_request`,
`sweep_mismatched_tip_request`, `sweep_underfunded_matching_request`,
`sweep_legitimate_request_rejected`.

Lean theorems: `sweep_mismatched_tip_request_allowed`,
`sweep_underfunded_matching_request_allowed`,
`protected_request_not_sweepable`.

## 12. Token Extraction

**Invariant:** token extraction is unambiguous.

`tokenFromValue` returns a token only when the value has exactly one non-ADA
policy with exactly one asset name. `tokenFromPolicy` scopes extraction to a
specific policy and rejects zero or multiple assets under that policy.

Representative tests: `tokenFromValue_single_nft`, `tokenFromValue_ada_only`,
`tokenFromValue_multi_policy`, `tokenFromValue_multi_asset`,
`tokenFromValue_roundtrip`.

Lean theorems: `valueFromToken_roundtrip`, `tokenFromValue_ada_only`,
`tokenFromValue_multi_policy`, `tokenFromValue_multi_asset`.
