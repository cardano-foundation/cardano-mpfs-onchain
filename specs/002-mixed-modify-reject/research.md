# Research: Mixed Update/Reject On-chain

No unknowns. All decisions follow from the upstream cage design.

## Decisions

### 1. Single fold vs. two-pass

**Decision**: Single fold function `mkAction` replaces both `mkUpdate` and `mkReject`.
**Rationale**: The fold accumulator already carries `(MerklePatriciaForestry, List<_>, List<refunds>)`. Replacing `List<Proof>` with `List<RequestAction>` and dispatching per-action is natural. Two passes would require iterating inputs twice.
**Alternatives**: Two-pass (first update, then reject) — rejected because it can't handle interleaved request ordering.

### 2. Phase enforcement per-action

**Decision**: `Update` enforces Phase 1 (oracle processing window). `Rejected` enforces Phase 3 (rejectability).
**Rationale**: Same as current behavior, just dispatched per-action instead of per-transaction.

### 3. Script size impact

**Decision**: Merging reduces code — `mkReject` and `validReject` are deleted, their logic folded into `mkAction`.
**Rationale**: One fold function instead of two. The `RequestAction` pattern match adds minimal overhead per iteration.
