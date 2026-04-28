# Data Model: Split state and request validators

## State

Existing shape is retained:

```aiken
pub type State {
  owner: VerificationKeyHash,
  root: ByteArray,
  tip: Int,
  process_time: Int,
  retract_time: Int,
}
```

The state datum lives only at the global state validator address. The cage token is not duplicated in the datum; it is read from the state UTxO value.

## Request

Existing shape is retained:

```aiken
pub type Request {
  requestToken: TokenId,
  requestOwner: VerificationKeyHash,
  requestKey: ByteArray,
  requestValue: Operation,
  tip: Int,
  submitted_at: Int,
}
```

`requestToken` is the cage NFT asset name. The request validator parameter must match this asset name for canonical request submission.

## MintRedeemer

```aiken
pub type MintRedeemer {
  Minting(OutputReference)
  Migrating(Migration)
  Burning(TokenId)
}
```

`Burning(TokenId)` makes the global state policy reject unrelated burn or mint movements.

## UpdateRedeemer

Existing constructor indices are retained:

```aiken
pub type UpdateRedeemer {
  End
  Contribute(OutputReference)
  Modify(List<RequestAction>)
  Retract(OutputReference)
  Sweep(OutputReference)
}
```

The state validator accepts `End` and `Modify`. The request validator accepts `Contribute`, `Retract`, and `Sweep`.

## Validator Identities

- State policy id: hash of `state`.
- State address: payment credential of `state`.
- Request address: hash of `request` after applying `(statePolicyId, cageToken.assetName)`.
