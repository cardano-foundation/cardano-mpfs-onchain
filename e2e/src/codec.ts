import { Constr, Data, type UTxO } from "@lucid-evolution/lucid";

// CageDatum = RequestDatum(Request) | StateDatum(State)
// StateDatum is constructor index 1, State has fields { owner, root, max_fee, process_time, retract_time }
export function encodeStateDatum(
  owner: string,
  root: string,
  maxFee: bigint = 0n,
  processTime: bigint = 60_000n,
  retractTime: bigint = 60_000n,
): string {
  return Data.to(
    new Constr(1, [new Constr(0, [owner, root, maxFee, processTime, retractTime])]),
  );
}

// MintRedeemer = Minting(Mint) | Migrating(Migration) | Burning
// Minting is index 0, Mint has { asset: OutputReference }
// OutputReference = { transaction_id, output_index }
export function encodeMintRedeemer(utxo: UTxO): string {
  const outputRef = new Constr(0, [utxo.txHash, BigInt(utxo.outputIndex)]);
  const mint = new Constr(0, [outputRef]);
  return Data.to(new Constr(0, [mint]));
}

// Migrating is index 1, Migration has { oldPolicy, tokenId }
// TokenId has { assetName }
export function encodeMigratingRedeemer(
  oldPolicyId: string,
  assetName: string,
): string {
  const tokenId = new Constr(0, [assetName]);
  const migration = new Constr(0, [oldPolicyId, tokenId]);
  return Data.to(new Constr(1, [migration]));
}

// Burning is index 2 (no fields)
export function encodeBurningRedeemer(): string {
  return Data.to(new Constr(2, []));
}

// UpdateRedeemer = End(0) | Contribute(OutputReference)(1) | Modify(List<RequestAction>)(2) | Retract(OutputReference)(3)
// RequestAction = UpdateAction(Proof)(0) | Rejected(1)

// End is index 0
export function encodeEndRedeemer(): string {
  return Data.to(new Constr(0, []));
}

// Contribute is index 1, takes an OutputReference pointing to the State UTxO
export function encodeContributeRedeemer(stateUtxo: UTxO): string {
  const outputRef = new Constr(0, [
    stateUtxo.txHash,
    BigInt(stateUtxo.outputIndex),
  ]);
  return Data.to(new Constr(1, [outputRef]));
}

// Modify is index 2, takes List<RequestAction>
// RequestAction = UpdateAction(Proof)(0) | Rejected(1)
// For inserting into an empty MPF, proof is [] (empty list)
// So one update: actions = [UpdateAction([])]
export function encodeModifyRedeemer(actions: Data[]): string {
  return Data.to(new Constr(2, [actions]));
}

// Helper: wrap a proof as an UpdateAction (Constr 0)
export function encodeUpdateAction(proof: Data[]): Data {
  return new Constr(0, [proof]);
}

// Helper: encode a Rejected action (Constr 1)
export function encodeRejectedAction(): Data {
  return new Constr(1, []);
}

// CageDatum = RequestDatum(Request)(0) | StateDatum(State)(1)
// Request { requestToken: TokenId, requestOwner: VerificationKeyHash,
//           requestKey: ByteArray, requestValue: Operation }
// TokenId { assetName: AssetName } = Constr(0, [assetName])
// Operation = Insert(ByteArray)(0) | Delete(ByteArray)(1) | Update(ByteArray, ByteArray)(2)
export function encodeRequestDatum(
  assetName: string,
  ownerHash: string,
  key: string,
  value: string,
  fee: bigint = 0n,
  submittedAt: bigint = 0n,
): string {
  const tokenId = new Constr(0, [assetName]);
  const operation = new Constr(0, [value]); // Insert
  const request = new Constr(0, [
    tokenId,
    ownerHash,
    key,
    operation,
    fee,
    submittedAt,
  ]);
  return Data.to(new Constr(0, [request]));
}

// Delete(ByteArray) is Operation index 1
export function encodeDeleteRequestDatum(
  assetName: string,
  ownerHash: string,
  key: string,
  value: string,
  fee: bigint = 0n,
  submittedAt: bigint = 0n,
): string {
  const tokenId = new Constr(0, [assetName]);
  const operation = new Constr(1, [value]); // Delete
  const request = new Constr(0, [
    tokenId,
    ownerHash,
    key,
    operation,
    fee,
    submittedAt,
  ]);
  return Data.to(new Constr(0, [request]));
}

// Retract is index 3, takes an OutputReference pointing to the State UTxO (reference input)
export function encodeRetractRedeemer(stateUtxo: UTxO): string {
  const outputRef = new Constr(0, [
    stateUtxo.txHash,
    BigInt(stateUtxo.outputIndex),
  ]);
  return Data.to(new Constr(3, [outputRef]));
}

// Reject is now Modify([Rejected]) — use encodeModifyRedeemer([encodeRejectedAction()])
