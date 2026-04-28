# Feature Specification: Split state and request validators

**Feature Branch**: `feat/feat-split-into-shared-state-and-per-token-request`
**Created**: 2026-04-28
**Status**: Draft
**Input**: Issue [#49](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/49)

## User Scenarios & Testing

### User Story 1 - Globally discover cages (Priority: P1)

MPFS can subscribe to one state policy id and discover every cage boot, modify, and end event without knowing per-cage script parameters beforehand.

**Why this priority**: The split exists to restore global discoverability lost by per-token state script parameterization.

**Independent Test**: Mint two cages under the same unparameterized state validator and verify both state UTxOs share the state policy id while carrying distinct asset names.

**Acceptance Scenarios**:

1. **Given** a boot transaction consumes seed `s1`, **When** the state mint policy runs, **Then** it mints exactly one `(statePolicyId, assetName(s1))` token to the state address with an empty root.
2. **Given** a second boot transaction consumes seed `s2`, **When** the state mint policy runs, **Then** it uses the same policy id and a distinct asset name.
3. **Given** a boot transaction also mints extra assets under the state policy id, **When** the state mint policy runs, **Then** it rejects.

---

### User Story 2 - Isolate pending requests per cage (Priority: P1)

Each cage has a canonical request address derived by applying the request blueprint to the fixed state policy id and the cage NFT asset name. Completeness proofs for pending requests are scoped to that address.

**Why this priority**: Per-token request addressing preserves the MTS completeness property that motivated issue #47.

**Independent Test**: Apply the request validator blueprint to two different cage asset names and verify the derived script hashes differ. Verify request spends authenticate the state UTxO using both state policy id and cage asset name.

**Acceptance Scenarios**:

1. **Given** request validator parameters `(statePolicyId, cageTokenA)` and `(statePolicyId, cageTokenB)`, **When** the blueprint is applied, **Then** the derived request addresses differ.
2. **Given** a request spend references a state UTxO carrying `(statePolicyId, cageToken)`, **When** the phase and signer rules are satisfied, **Then** the request validator accepts.
3. **Given** a request spend references a fake state UTxO with the same asset name under a foreign policy id, **When** the request validator runs, **Then** it rejects.

---

### User Story 3 - Preserve safe request lifecycle semantics (Priority: P1)

Requests remain protected by the same three-phase rules: oracle processing in phase 1, requester retract in phase 2, and owner rejection after expiry or dishonest timestamps.

**Why this priority**: Splitting validators must not weaken refund, phase, or ownership invariants.

**Independent Test**: Run the existing Modify, Contribute, Retract, Reject, refund, and phase tests against the split validators.

**Acceptance Scenarios**:

1. **Given** a canonical request in phase 1, **When** it is consumed with `Contribute` in the same transaction as state `Modify`, **Then** both validators accept and refunds balance.
2. **Given** the same request in phase 2, **When** the requester signs `Retract`, **Then** the request validator accepts and state is not required as a spending input.
3. **Given** an owner tries to process a request with mismatched tip, **When** state `Modify` runs, **Then** it rejects unless the request is removed via the malformed-request cleanup path.

---

### User Story 4 - Clean request-address garbage safely (Priority: P2)

The cage owner can sweep UTxOs at the request address that are not processable legitimate requests, without being able to sweep valid requester submissions.

**Why this priority**: Garbage at the per-token request address inflates MTS completeness proofs. A too-broad "legitimate request" definition would lock malformed matching-token spam forever.

**Independent Test**: Sweep no-datum garbage, wrong-token requests, and matching-token malformed requests; reject sweeping valid matching-token requests.

**Acceptance Scenarios**:

1. **Given** a no-datum UTxO at the request address, **When** the state owner signs `Sweep(stateRef)`, **Then** the request validator accepts.
2. **Given** a `RequestDatum` whose token does not match the request validator parameter, **When** the state owner signs `Sweep(stateRef)`, **Then** the request validator accepts.
3. **Given** a matching-token `RequestDatum` whose tip does not match the current state tip, **When** the state owner signs `Sweep(stateRef)`, **Then** the request validator accepts.
4. **Given** a matching-token `RequestDatum` whose tip matches state tip, **When** the state owner tries `Sweep(stateRef)`, **Then** the request validator rejects.

---

### Edge Cases

- The state address can receive arbitrary ADA or foreign tokens. Protocol participants subscribe to the state policy id and ignore UTxOs not carrying legitimate state-policy tokens.
- `Contribute` must reference the state UTxO as a spending input whose redeemer is `Modify`, not only a reference input or another state spend, so request consumption cannot bypass state `Modify` and its refund equation.
- `Retract` and `Sweep` may use the state UTxO as a reference input because they do not update state.
- A request validator instance must reject any state reference authenticated only by asset name.
- Burning under the state policy must not permit unrelated state-policy assets to be minted or burned in the same transaction.

## Requirements

### Functional Requirements

- **FR-001**: The state validator MUST be unparameterized and MUST provide the state mint policy and state spend handlers.
- **FR-002**: `MintRedeemer.Minting` MUST carry the seed `OutputReference`; the state mint policy MUST derive `TokenId { assetName = assetName(seed) }` from that redeemer field.
- **FR-003**: Fresh mint MUST consume the seed UTxO, mint exactly one expected state-policy asset, send it to the state script address, include a `StateDatum`, and require `root(empty)`.
- **FR-004**: State mint, migration, and burn validation MUST reject extra asset movements under the state policy id.
- **FR-005**: The request validator MUST be parameterized by `statePolicyId` and `cageToken`.
- **FR-006**: Request `Contribute`, `Retract`, and `Sweep` MUST authenticate the referenced state UTxO by checking quantity one of `(statePolicyId, cageToken)`.
- **FR-007**: Request `Contribute` MUST locate the state UTxO in `tx.inputs` and MUST confirm that input is spent with state `Modify`; reference-only state lookup and state `End` MUST reject.
- **FR-008**: Request `Retract` MUST preserve the phase-2 requester-signature semantics from the existing validator.
- **FR-009**: State `Modify` MUST preserve root integrity, refund equation, state address, state token, tip immutability, process time immutability, and retract time immutability.
- **FR-010**: State `Modify` MUST process matching-token `RequestDatum` inputs from any address and MUST NOT check source address.
- **FR-011**: Request `Sweep` MUST reject processable legitimate requests and accept malformed matching-token requests that state `Modify` cannot process.
- **FR-012**: The blueprint MUST contain exactly the state and request validators for this feature.

### Key Entities

- **State validator**: Global unparameterized script that mints and spends cage state UTxOs.
- **Request validator**: Blueprint applied to `(statePolicyId, cageToken)` to derive one request address per cage.
- **State UTxO**: UTxO at the state address carrying exactly one cage NFT under the state policy and a `StateDatum`.
- **Canonical request UTxO**: UTxO at the per-token request address with a processable `RequestDatum` for that cage.
- **Malformed request UTxO**: UTxO at the request address that is not processable by state `Modify` and may be swept by the state owner.

## Success Criteria

- **SC-001**: `aiken check` passes with split validator tests.
- **SC-002**: `aiken build` emits two validator entries: `state` and `request`.
- **SC-003**: Tests cover extra state-policy mint rejection, fake state-policy rejection, reference-only Contribute rejection, state-End Contribute rejection, and malformed matching-token Sweep.
- **SC-004**: Haskell vector types match Aiken redeemer encodings.
- **SC-005**: Lean phase proofs continue to compile or any unrelated Lean blockers are documented.

## Assumptions

- Existing deployed cages are out of scope for this implementation.
- Off-chain MPFS changes are tracked separately, but on-chain blueprint shape must be usable by off-chain code.
- `statePolicyId` is fixed per blueprint version and is applied as the first request-validator parameter.
