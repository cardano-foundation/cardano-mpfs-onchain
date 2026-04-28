# Types & Encodings

All on-chain data structures are defined in
[`types.ak`](https://github.com/cardano-foundation/cardano-mpfs-onchain/blob/main/validators/types.ak)
and compile to Plutus V3 `Data`.

## Token Identity

```aiken
type TokenId {
  assetName: AssetName,
}
```

`TokenId` stores the cage token asset name. The policy ID is supplied by
context:

- state UTxOs use the global state validator policy ID;
- request validators receive `statePolicyId` as a parameter.

The asset name is `SHA2-256(tx_id ++ output_index)` of the seed
`OutputReference` carried by `Minting(seed)`.

## Datum

```aiken
type CageDatum {
  RequestDatum(Request)
  StateDatum(State)
}
```

### State

Attached to the UTxO that holds the cage token.

```aiken
type State {
  owner: VerificationKeyHash
  root: ByteArray
  tip: Int
  process_time: Int
  retract_time: Int
}
```

| Field | Encoding | Description |
|---|---|---|
| `owner` | 28 bytes | Verification key hash that controls state `Modify` and `End` |
| `root` | bytes | Current MPF root; boot starts at `root(empty)` |
| `tip` | integer | Oracle tip per processed request |
| `process_time` | integer | Phase 1 duration; immutable across `Modify` |
| `retract_time` | integer | Phase 2 duration; immutable across `Modify` |

### Request

Attached to request UTxOs.

```aiken
type Request {
  requestToken: TokenId
  requestOwner: VerificationKeyHash
  requestKey: ByteArray
  requestValue: Operation
  tip: Int
  submitted_at: Int
}
```

| Field | Encoding | Description |
|---|---|---|
| `requestToken` | `TokenId` | Target cage token asset name |
| `requestOwner` | 28 bytes | Key allowed to retract the request |
| `requestKey` | bytes | MPF key |
| `requestValue` | `Operation` | Insert, delete, or update payload |
| `tip` | integer | Tip the requester agrees to pay the oracle |
| `submitted_at` | integer | POSIX time used for phase checks |

## Operations

```aiken
type Operation {
  Insert(ByteArray)
  Delete(ByteArray)
  Update(ByteArray, ByteArray)
}
```

| Constructor | Index | Fields |
|---|---|---|
| `Insert` | 0 | `new_value` |
| `Delete` | 1 | `old_value` |
| `Update` | 2 | `old_value`, `new_value` |

## Minting Redeemer

```aiken
type Migration {
  oldPolicy: PolicyId,
  tokenId: TokenId,
}

type MintRedeemer {
  Minting(OutputReference)
  Migrating(Migration)
  Burning(TokenId)
}
```

| Constructor | Index | Fields | Description |
|---|---|---|---|
| `Minting` | 0 | `OutputReference` | Seed consumed by boot and used to derive the asset name |
| `Migrating` | 1 | `Migration` | Burn old policy token and mint same asset under state policy |
| `Burning` | 2 | `TokenId` | Burn the selected cage token under the state policy |

`Burning(TokenId)` is intentionally explicit. The state policy is global, so
the redeemer tells the policy which asset must be burned and lets
`exactQuantity` reject unrelated movement under the same policy ID.

## Spending Redeemers

### RequestAction

```aiken
type RequestAction {
  UpdateAction(Proof)
  Rejected
}
```

| Constructor | Index | Fields | Description |
|---|---|---|---|
| `UpdateAction` | 0 | `Proof` | Apply one MPF proof in Phase 1 |
| `Rejected` | 1 | none | Skip root update for a rejectable request |

`Modify(List<RequestAction>)` consumes one action for each matching request
input in transaction input order.

### UpdateRedeemer

```aiken
type UpdateRedeemer {
  End
  Contribute(OutputReference)
  Modify(List<RequestAction>)
  Retract(OutputReference)
  Sweep(OutputReference)
}
```

| Constructor | Index | State validator | Request validator |
|---|---|---|---|
| `End` | 0 | accepted | rejected |
| `Contribute` | 1 | rejected | accepted |
| `Modify` | 2 | accepted | rejected |
| `Retract` | 3 | rejected | accepted |
| `Sweep` | 4 | rejected | accepted |

`Contribute`, `Retract`, and `Sweep` carry the referenced state UTxO. The
request validator authenticates that UTxO by `(statePolicyId, cageToken)`.
`Contribute` requires the state UTxO as a regular input spent with `Modify`;
`Retract` and `Sweep` may use a reference input.

## Plutus Data Encoding

Constructor indices match the order listed above.

Example `StateDatum`:

```text
Constr(1,
  [ Constr(0,
      [ Bytes(owner_pkh)
      , Bytes(root_hash)
      , Int(tip)
      , Int(process_time)
      , Int(retract_time)
      ])
  ])
```

Example `RequestDatum` with `Insert`:

```text
Constr(0,
  [ Constr(0,
      [ Constr(0, [Bytes(asset_name)])
      , Bytes(owner_pkh)
      , Bytes(key)
      , Constr(0, [Bytes(new_value)])
      , Int(tip)
      , Int(submitted_at)
      ])
  ])
```
