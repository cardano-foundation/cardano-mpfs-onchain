# Research: Split state and request validators

## Existing baseline

- `validators/cage.ak` currently combines minting and spending in `mpfCage(seed: OutputReference)`.
- Issue #47 added per-token state script hashes, `Sweep`, zero-request `Modify`, and policy-aware fake-state rejection.
- Request, state, mint, and update data types live in `validators/types.ak`.
- Haskell vector types live in `haskell/lib/Cardano/MPFS/Cage/Types.hs`.

## Decisions

### Request validator parameters

Decision: parameterize request by both `statePolicyId` and `cageTokenName`.

Rationale: `cageTokenName` alone cannot authenticate the referenced state UTxO. A fake state token under a foreign policy with the same asset name would pass asset-name-only checks. Applying `statePolicyId` as a global parameter keeps one audit unit while giving request spends a real state-policy trust anchor.

### State mint uniqueness

Decision: state `Minting(seed)` derives the asset name from the redeemer seed and requires the seed input be consumed.

Rationale: the state validator is unparameterized, so mint authorization must move from validator parameter to redeemer payload.

### State-policy singleton checks

Decision: state mint, migration, and burn paths check the whole state-policy token map for the expected singleton movement.

Rationale: with a global policy id, checking one asset quantity is insufficient. Extra state-policy asset names would become false discovery signals.

### Contribute input mode

Decision: `Contribute(stateRef)` must find `stateRef` in `tx.inputs` and the redeemer for `Spend(stateRef)` must decode to `Modify`.

Rationale: `Contribute` consumes the request. If the state UTxO were only a reference input, or if it were spent with `End`, a request could be spent without state `Modify` running the refund equation.

### Sweep malformed matching-token requests

Decision: a matching-token request is protected from sweep only if it is processable against the referenced state. Initially this means `request.tip == state.tip`.

Rationale: state `Modify` rejects mismatched tips before refund processing. If request `Sweep` also rejects all matching-token requests, mismatched-tip spam is permanently locked at the canonical request address.

## Alternatives Rejected

### Request parameterized only by cage token

Rejected because it cannot verify `(statePolicyId, cageToken)`.

### State address sweep

Rejected as unnecessary. Protocol discovery follows the state policy id, not all UTxOs at the state address.

### On-chain request script hash in StateDatum

Rejected because it reintroduces a trust-the-published-hash path. Wallets should derive the request address from the audited blueprint and observable cage token.
