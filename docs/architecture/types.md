# Types & Encodings

All on-chain data structures are defined in
[`types.ak`](https://github.com/cardano-foundation/cardano-mpfs-onchain/blob/main/validators/types.ak)
and compiled to Plutus V3 data encodings.

## Token Identity

```aiken
type TokenId {
    assetName: AssetName
}
```

`TokenId` wraps only the `AssetName`. The `PolicyId` is always
the cage script's own hash (since the minting policy and spending
validator share the same script) and is passed separately where
needed.

The `AssetName` is derived from a consumed UTxO reference via
SHA2-256, guaranteeing global uniqueness.

## Datum

Every UTxO at the script address carries a `CageDatum`:

```aiken
type CageDatum {
    RequestDatum(Request)
    StateDatum(State)
}
```

### State

Attached to the UTxO that holds the MPF token.

```aiken
type State {
    owner: VerificationKeyHash
    root: ByteArray      -- 32-byte MPF root hash
    max_fee: Int         -- max lovelace fee per request
    process_time: Int    -- Phase 1 duration (ms)
    retract_time: Int    -- Phase 2 duration (ms)
}
```

| Field | Encoding | Description |
|---|---|---|
| `owner` | 28 bytes | Ed25519 public key hash of the token owner |
| `root` | 32 bytes | Current MPF root (Blake2b-256). Empty trie has a well-known null hash |
| `max_fee` | integer | Maximum fee (in lovelace) the oracle charges per request. Requesters must agree to this fee |
| `process_time` | integer | Duration (ms) of Phase 1 — oracle-exclusive processing window. Set at mint time; enforced immutable across Modify/Reject |
| `retract_time` | integer | Duration (ms) of Phase 2 — requester-exclusive retract window. Set at mint time; enforced immutable across Modify/Reject |

### Request

Attached to UTxOs representing pending modification requests.

```aiken
type Request {
    requestToken: TokenId
    requestOwner: VerificationKeyHash
    requestKey: ByteArray
    requestValue: Operation
    fee: Int
    submitted_at: Int
}
```

| Field | Encoding | Description |
|---|---|---|
| `requestToken` | `TokenId` | Target MPF token (asset name only; policy ID is implicit) |
| `requestOwner` | 28 bytes | Who can retract this request |
| `requestKey` | variable | Key in the MPF trie |
| `requestValue` | `Operation` | What to do with this key |
| `fee` | integer | Fee (in lovelace) the requester agrees to pay. Must match `state.max_fee` at Modify time |
| `submitted_at` | integer | POSIXTime (ms) when the request was submitted. Determines which time phase the request is in |

## Operations

```aiken
type Operation {
    Insert(ByteArray)               -- new_value
    Delete(ByteArray)               -- old_value
    Update(ByteArray, ByteArray)    -- old_value, new_value
}
```

| Constructor | Index | Fields | Description |
|---|---|---|---|
| `Insert` | 0 | `new_value` | Insert a new key-value pair (key must not exist) |
| `Delete` | 1 | `old_value` | Remove an existing key (must exist with this value) |
| `Update` | 2 | `old_value, new_value` | Change the value of an existing key |

## Redeemers

### Minting Redeemer

```aiken
type Mint {
    asset: OutputReference
}

type Migration {
    oldPolicy: PolicyId
    tokenId: TokenId
}

type MintRedeemer {
    Minting(Mint)
    Migrating(Migration)
    Burning
}
```

| Constructor | Index | Fields | Description |
|---|---|---|---|
| `Minting` | 0 | `Mint { asset: OutputReference }` | Boot a new token. `asset` identifies which UTxO to consume for unique naming |
| `Migrating` | 1 | `Migration { oldPolicy, tokenId }` | Migrate a token from an old validator. The old token must be burned atomically |
| `Burning` | 2 | — | Burn the token (paired with `End` on the spending side) |

### Spending Redeemer

```aiken
type RequestAction {
    Update(List<Proof>)
    Rejected
}

type UpdateRedeemer {
    End
    Contribute(OutputReference)
    Modify(List<RequestAction>)
    Retract(OutputReference)
}
```

Each request in a `Modify` transaction carries a `RequestAction`:

| Constructor | Index | Fields | Description |
|---|---|---|---|
| `Update` | 0 | `List<Proof>` | Apply proofs to update the MPF root |
| `Rejected` | 1 | — | Reject an expired request (Phase 3 or dishonest `submitted_at`) |

The spending redeemer:

| Constructor | Index | Fields | Description |
|---|---|---|---|
| `End` | 0 | — | Destroy the MPF instance |
| `Contribute` | 1 | `OutputReference` | Spend a request during Modify; points to the state UTxO |
| `Modify` | 2 | `List<RequestAction>` | Process requests — each can be updated or rejected in a single transaction |
| `Retract` | 3 | `OutputReference` | Cancel a request and reclaim ADA. Points to the State UTxO (reference input). Phase 2 only |

## Plutus Data Encoding

All types compile to standard Plutus V3 `Data` constructors.
The constructor indices match the order listed above (0-indexed).

**Example — StateDatum on-chain encoding:**

```
Constr(1,           -- CageDatum.StateDatum
  [ Constr(0,       -- State
      [ Bytes(owner_pkh)
      , Bytes(root_hash)
      , Int(max_fee)
      , Int(process_time)
      , Int(retract_time)
      ])
  ])
```

**Example — RequestDatum with Insert:**

```
Constr(0,           -- CageDatum.RequestDatum
  [ Constr(0,       -- Request
      [ Constr(0, [Bytes(asset_name)])  -- TokenId
      , Bytes(owner_pkh)
      , Bytes(key)
      , Constr(0, [Bytes(new_value)])   -- Insert
      , Int(fee)
      , Int(submitted_at)
      ])
  ])
```
