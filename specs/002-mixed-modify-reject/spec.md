# Feature Specification: Mixed Update/Reject in Modify Redeemer (On-chain)

**Feature Branch**: `002-mixed-modify-reject`
**Created**: 2026-04-13
**Status**: Draft
**Input**: User description: "Support mixed update/reject in Modify redeemer — on-chain Aiken validator"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Validator handles RequestAction (Priority: P1)

The Aiken validator accepts a `Modify` redeemer carrying a list of `RequestAction` values instead of a flat `List<Proof>`. Each action is either `Update(Proof)` (verify proof and apply operation) or `Rejected` (verify rejectability and skip proof verification). This enables a single transaction to process and reject requests atomically.

**Why this priority**: This is the core validator logic change — everything else depends on it.

**Independent Test**: Construct a Modify transaction with mixed `Update` and `Rejected` actions, verify the root updates only for `Update` entries and stays unchanged for `Rejected` entries, and that fees are correctly enforced for both.

**Acceptance Scenarios**:

1. **Given** a Modify redeemer with `[Update(proof1), Rejected, Update(proof2)]` and three matching request inputs, **When** submitted, **Then** the MPF root reflects only the two updated operations; the rejected request's fee is collected and its lovelace refunded.
2. **Given** a Modify redeemer with `[Rejected, Rejected]` and two expired request inputs, **When** submitted, **Then** the MPF root is unchanged and both requests are cleaned up with fee collection.
3. **Given** a `Rejected` action paired with a request that is NOT rejectable (still in Phase 1), **When** submitted, **Then** the transaction fails.

---

### User Story 2 - Remove standalone Reject redeemer (Priority: P1)

The `Reject` constructor is removed from `UpdateRedeemer`. Old transactions using `Reject` (Constr 4) will fail validation. All existing Reject tests are migrated to use `Modify` with `Rejected` actions.

**Why this priority**: Breaking change that must ship with US1.

**Independent Test**: Verify that a transaction using Constr 4 as the redeemer fails. Verify all existing reject test scenarios pass when expressed as `Modify [Rejected, ...]`.

**Acceptance Scenarios**:

1. **Given** the updated validator, **When** a transaction uses the old Reject encoding (Constr 4), **Then** it fails.
2. **Given** existing reject test fixtures, **When** rewritten as `Modify([Rejected, ...])`, **Then** they pass with identical behavior.

---

### User Story 3 - E2E codec updated (Priority: P2)

The TypeScript E2E codec in `e2e/src/codec.ts` is updated to produce the new `RequestAction` encoding and remove the Reject constructor. E2E tests continue to pass.

**Why this priority**: E2E tests validate the full transaction lifecycle but are secondary to on-chain correctness.

**Independent Test**: E2E tests pass with `just e2e`.

**Acceptance Scenarios**:

1. **Given** the updated codec, **When** E2E tests build transactions with mixed Modify, **Then** they submit and validate successfully against the updated validator.

---

### User Story 4 - Lean specification updated (Priority: P2)

The Lean spec in `spec/CageDatum.lean` is updated to reflect the new `RequestAction` type and removal of `Reject` from `SpendRedeemer`.

**Why this priority**: Formal properties must stay in sync but are documentation/verification, not runtime.

**Independent Test**: `lake build` compiles.

**Acceptance Scenarios**:

1. **Given** the updated Lean spec, **When** `lake build` runs, **Then** it completes with no errors.

### Edge Cases

- What if a `Modify` contains only `Rejected` actions? The root must not change — same as old `Reject` behavior.
- What if a `Modify` contains zero actions (`Modify([])`)? No requests processed, root unchanged.
- What if an `Update` action's proof is invalid? Transaction fails (MPF library rejects).
- What about the cage test vectors? They are auto-generated from the upstream Haskell cage — `just generate-vectors` will pick up the new `RequestAction` encoding automatically since the flake input already points to the updated cage branch.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A new `RequestAction` Aiken type MUST be introduced with variants `Update(Proof)` and `Rejected`.
- **FR-002**: `UpdateRedeemer::Modify` MUST carry `List<RequestAction>` instead of `List<Proof>`.
- **FR-003**: `UpdateRedeemer::Reject` MUST be removed.
- **FR-004**: The validator MUST verify proofs only for `Update` actions; for `Rejected` actions it MUST verify rejectability (phase 3 or dishonest timestamp).
- **FR-005**: For `Rejected` actions, the MPF root MUST NOT change (no proof applied).
- **FR-006**: Fee enforcement MUST apply to both `Update` and `Rejected` actions equally.
- **FR-007**: Refund logic (requester receives inputLovelace - fee) MUST apply to both action types.
- **FR-008**: All existing Reject tests MUST be migrated to `Modify([Rejected, ...])` equivalents.
- **FR-009**: The E2E TypeScript codec MUST encode `RequestAction` as `Constr(0, [proof])` for `Update` and `Constr(1, [])` for `Rejected`.
- **FR-010**: `just generate-vectors` MUST produce updated vectors reflecting the new encoding.
- **FR-011**: The Lean spec MUST add `RequestAction` and remove `Reject` from `SpendRedeemer`.

### Key Entities

- **RequestAction**: Per-request action — `Update(Proof)` or `Rejected`. New Aiken type.
- **UpdateRedeemer**: Spending redeemer — `End | Contribute | Modify | Retract` (4 variants, down from 5). Modified.
- **Proof**: MPF Merkle proof — unchanged, now wrapped inside `RequestAction::Update`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `just test` passes (all Aiken tests).
- **SC-002**: `just vectors-check` passes (cage vectors up to date).
- **SC-003**: `lake build` compiles the updated Lean spec.
- **SC-004**: E2E tests pass (if infrastructure available).

## Assumptions

- The upstream cage types (cardano-mpfs-cage) are already updated and pinned via flake input.
- The cage test vector generator produces the new encoding — `just generate-vectors` picks it up.
- The off-chain service will be updated separately to produce the new redeemer format.
