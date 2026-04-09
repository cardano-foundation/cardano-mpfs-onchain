# Feature Specification: Fair Fee Model

**Feature Branch**: `001-fair-fee-model`
**Created**: 2026-04-08
**Status**: Draft
**Input**: User description: "Replace the fixed-fee model with a fair fee model where requesters pay their share of the actual transaction fee plus an oracle tip"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Fair cost sharing on batch updates (Priority: P1)

A requester submits a modification request to a caged token. When the oracle processes multiple requests in a single Modify transaction, each requester pays only their proportional share of the actual Cardano transaction fee plus the oracle's declared tip. The requester receives back everything they locked minus their fair share.

**Why this priority**: This is the core value proposition. The current model overcharges requesters by charging a fixed maximum fee regardless of actual costs or batch size. With N requests batched, requesters currently pay N times the max fee while the oracle pays one tx fee.

**Independent Test**: Can be fully tested by constructing a Modify transaction with known tx fee, multiple requests, and verifying refund amounts match the conservation equation.

**Acceptance Scenarios**:

1. **Given** a cage with tip = 500,000 lovelace and two requests each locking 3,000,000 lovelace, **When** the oracle submits a Modify transaction with actual tx fee = 400,000, **Then** total refunded = 6,000,000 - 400,000 - 2 * 500,000 = 4,600,000 lovelace
2. **Given** a cage with tip = 0, **When** the oracle processes one request with tx fee = 600,000, **Then** the requester is refunded input_lovelace - 600,000
3. **Given** a request with tip different from the cage state's tip, **When** the oracle attempts to Modify, **Then** the transaction is rejected

---

### User Story 2 - Requester agrees to oracle terms (Priority: P1)

A requester creating a modification request must record the oracle's current tip in their request datum. This signals agreement to the oracle's pricing terms. If the oracle changes its tip, old requests with the previous tip value are rejected during processing.

**Why this priority**: Without explicit agreement, the oracle could change terms after the requester locked funds.

**Independent Test**: Can be tested by creating requests with matching and mismatching tip values and verifying acceptance/rejection.

**Acceptance Scenarios**:

1. **Given** a cage with tip = 500,000, **When** a request is submitted with tip = 500,000, **Then** it is accepted during Modify
2. **Given** a cage with tip = 500,000, **When** a request is submitted with tip = 100,000, **Then** the Modify transaction fails

---

### User Story 3 - Fair cost sharing on reject (Priority: P2)

When the oracle rejects expired or dishonest requests, the same conservation law applies: requesters pay their share of the tx fee plus the tip.

**Why this priority**: Reject uses the same fee logic as Modify for consistency, but is exercised less frequently.

**Independent Test**: Can be tested by constructing a Reject transaction in Phase 3 and verifying refund amounts.

**Acceptance Scenarios**:

1. **Given** an expired request (Phase 3) with tip = 500,000, **When** the oracle rejects it with tx fee = 300,000, **Then** the requester is refunded input_lovelace - 300,000 - 500,000

---

### Edge Cases

- What happens when the total locked lovelace is less than tx fee + tips? The conservation check would require negative refunds, which is impossible. The transaction fails.
- What happens with a single request? The single requester pays the entire tx fee plus tip.
- What happens when all request inputs have zero lovelace? No refund outputs are required, and conservation trivially holds (0 = 0 - 0 - 0 with tip = 0).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The cage state datum MUST declare a `tip` field (replacing `max_fee`) representing the oracle's per-request margin in lovelace
- **FR-002**: The request datum MUST declare a `tip` field (replacing `fee`) representing the requester's agreed tip
- **FR-003**: During Modify, the validator MUST check that each request's tip equals the cage state's tip
- **FR-004**: During Modify, the validator MUST enforce conservation: `sum(refunds) == sum(request_input_lovelace) - tx_fee - N * tip`, using the actual transaction fee from Plutus V3's `Transaction.fee`
- **FR-005**: During Reject, the same conservation law (FR-004) MUST apply
- **FR-006**: Refund outputs MUST be sent to the correct request owner addresses
- **FR-007**: This is a datum-breaking change requiring a new validator version (migration via existing `Migrating` redeemer)

### Key Entities

- **State datum**: Cage configuration including `tip` (oracle margin), `process_time`, `retract_time`, `owner`, `root`
- **Request datum**: Modification request including `tip` (agreed oracle margin), `requestToken`, `requestOwner`, operation details
- **Transaction fee**: The actual Cardano tx fee, available on-chain via Plutus V3's `Transaction.fee` field

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For a batch of N requests, the total cost to requesters equals exactly the actual transaction fee plus N times the tip (zero oracle overcharge)
- **SC-002**: The formal Lean specification compiles with no `sorry` for the new fee conservation property
- **SC-003**: All existing Aiken tests pass after adaptation, plus new tests covering nonzero tx fee scenarios
- **SC-004**: On preprod, a single-request update with ~600,000 lovelace tx fee charges the requester ~600,000 + tip (vs the current ~2,000,000 fixed fee)

## Assumptions

- Plutus V3 `Transaction.fee` field accurately reflects the actual transaction fee (this is guaranteed by the Cardano ledger)
- The oracle is trusted to build transactions fairly — the validator enforces the total conservation but not per-request distribution within the total
- Existing cages will need migration to the new validator version (breaking datum change)
- The `tip` field is not enforced immutable — the owner can change it during Modify (same as the old `max_fee`)
