# Data Model: Mixed Update/Reject On-chain

## Type Changes

### RequestAction (new)

```aiken
pub type RequestAction {
  Update(Proof)   // Constr 0: proof-based MPF operation
  Rejected        // Constr 1: expiry-based rejection
}
```

### UpdateRedeemer (modified)

**Before** (5 variants):
```aiken
pub type UpdateRedeemer {
  End
  Contribute(OutputReference)
  Modify(List<Proof>)
  Retract(OutputReference)
  Reject
}
```

**After** (4 variants):
```aiken
pub type UpdateRedeemer {
  End
  Contribute(OutputReference)
  Modify(List<RequestAction>)
  Retract(OutputReference)
}
```

## Validator Logic Changes

### mkAction (replaces mkUpdate + mkReject)

Per-input fold function. For each matching request, pops one `RequestAction`:

| Action | Phase check | MPF operation | Proof consumed |
|--------|------------|---------------|----------------|
| `Update(proof)` | Phase 1 (in_phase1) | Yes (insert/delete/update) | Yes |
| `Rejected` | Phase 3 (is_rejectable) | No (root passes through) | No |

### validModify (replaces validRootUpdate + validReject)

Single entry point for `Modify` redeemer. Folds all inputs with `mkAction`, verifies root, verifies refunds, verifies address confinement.

## E2E Codec Changes

```typescript
// Before
const reject = new Constr(4, []);
const modify = new Constr(2, [proofList]);

// After
const updateAction = (proof) => new Constr(0, [proof]);
const rejectedAction = new Constr(1, []);
const modify = new Constr(2, [actionList]);
```
