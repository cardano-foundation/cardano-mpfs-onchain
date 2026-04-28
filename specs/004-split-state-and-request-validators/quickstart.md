# Quickstart: Split state and request validators

1. Build the blueprint with `aiken build`.
2. Read the unparameterized `state` validator hash; this is the global state policy id.
3. Boot a cage with `Minting(seedRef)`. The transaction must consume `seedRef` and mint exactly one token under the state policy with asset name `assetName(seedRef)`.
4. Read the cage token asset name from the state UTxO value.
5. Apply the `request` blueprint parameters in order: `statePolicyId`, then `cageToken.assetName`.
6. Submit request UTxOs to the derived request address with `RequestDatum { requestToken = cageToken, ... }`.
7. Process requests with one transaction that spends the state UTxO using `Modify(actions)` and spends each request UTxO using `Contribute(stateRef)`.
8. Retract during phase 2 by spending the request UTxO with `Retract(stateRef)` and the state UTxO as a reference input.
9. Sweep request-address garbage with `Sweep(stateRef)` signed by the current state owner.
10. End a cage by spending the state UTxO with `End` and mint redeemer `Burning(cageToken)`.
