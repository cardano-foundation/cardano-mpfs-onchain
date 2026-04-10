# Research: Fair Fee Model

## R1: Plutus V3 Transaction Fee Availability

**Decision**: Use `Transaction.fee` field from Plutus V3 script context.

**Rationale**: The project already uses `plutus = "v3"` (aiken.toml). The Aiken stdlib `Transaction` type includes `fee: Lovelace`. Verified in the stdlib source: `fee: Lovelace` is present and `transaction.placeholder` defaults it to `0`.

**Alternatives considered**:
- Inferring fee from `sum(inputs) - sum(outputs)`: Complex, error-prone, would need to account for minting. Rejected.
- Keeping fixed fee with lower value: Doesn't solve the batching overcharge. Rejected.

## R2: Conservation Equation Design

**Decision**: Global equality check: `sum(refunds) == sum(request_inputs) - tx.fee - N * tip`

**Rationale**: A single global check is simpler and cheaper (in execution units) than per-request checks with division and rounding. The oracle chooses how to distribute the fee across refund outputs — the validator only enforces the total.

**Alternatives considered**:
- Per-request equality `refund_i == input_i - tx.fee/N - tip`: Requires integer division rounding logic. One requester must absorb the remainder. More complex on-chain. Rejected.
- Inequality `sum(refunds) >= sum(inputs) - tx.fee - N * tip`: Would allow oracle to pocket less than declared. The user explicitly requested equality. Rejected.

## R3: Reject Fee Model

**Decision**: Reject uses the same conservation law as Modify.

**Rationale**: Consistency. The oracle initiates Reject transactions for expired/dishonest requests. The requester still pays their share of the tx fee plus tip, same as Modify.

**Alternatives considered**:
- Oracle absorbs Reject tx fee (requester only loses tip): More favorable to requester but inconsistent with Modify. The requester caused the situation (expired or dishonest). Rejected.

## R4: Accumulator Redesign

**Decision**: The fold accumulator tracks `(owner, inputLovelace)` pairs and a running total. Refund amounts are computed after the fold using the conservation equation.

**Rationale**: The per-request refund depends on `tx.fee` and `N`, neither of which is known during the fold. Accumulating raw data and computing refunds post-fold is the natural fit.

**Alternatives considered**:
- Two-pass fold (count N first, then compute): Would iterate inputs twice. More expensive. Rejected.

## R5: Zero-Lovelace Request Edge Case

**Decision**: Skip adding to the owners list when `inputLovelace == 0`. No refund output is required for zero-lovelace requests.

**Rationale**: Preserves backward compatibility with existing tests that use `from_lovelace(0)` for simplicity. In practice, every Cardano UTxO must hold min ADA (~1 ADA), so this case only occurs in tests.
