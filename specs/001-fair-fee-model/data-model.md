# Data Model: Fair Fee Model

## Entity Changes

### State (datum)

| Field | Before | After | Notes |
|-------|--------|-------|-------|
| owner | VerificationKeyHash | unchanged | |
| root | ByteArray | unchanged | |
| max_fee | Int | **renamed to `tip`** | Oracle's per-request margin (lovelace) |
| process_time | Int | unchanged | |
| retract_time | Int | unchanged | |

### Request (datum)

| Field | Before | After | Notes |
|-------|--------|-------|-------|
| requestToken | TokenId | unchanged | |
| requestOwner | VerificationKeyHash | unchanged | |
| requestKey | ByteArray | unchanged | |
| requestValue | Operation | unchanged | |
| fee | Int | **renamed to `tip`** | Requester's agreed tip (must match State.tip) |
| submitted_at | Int | unchanged | |

### Transaction (script context — read-only)

| Field | Usage | Notes |
|-------|-------|-------|
| fee | Lovelace | **NEW usage** — actual tx fee, used in conservation equation |
| inputs | List\<Input\> | Existing — request inputs provide lovelace amounts |
| outputs | List\<Output\> | Existing — refund outputs verified against conservation |

## Validation Rules

### Conservation Equation (Modify and Reject)

```
sum(refund_output_lovelace) == sum(request_input_lovelace) - tx.fee - N * state.tip
```

Where:
- `N` = number of matching requests processed
- `tx.fee` = actual Cardano transaction fee from script context
- `state.tip` = oracle's declared per-request margin

### Tip Agreement

```
request.tip == state.tip
```

Checked per-request during the fold. Fails the transaction if any request disagrees.

### Tip Field (not enforced immutable)

The `tip` field (formerly `max_fee`) is not checked for immutability across Modify/Reject — same as before. The owner can change it in the output datum.

## State Transitions

No change to the state machine. The three-phase lifecycle (Phase 1: oracle processes, Phase 2: requester retracts, Phase 3: oracle rejects) is unchanged. Only the fee computation within Modify and Reject transitions changes.
