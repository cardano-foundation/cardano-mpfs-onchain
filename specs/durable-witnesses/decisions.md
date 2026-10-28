# Durable witnesses: decisions

As a contract consuming a registry, I want durable evidence of one fact about
one key, so that writes to other keys do not keep invalidating the check I am
preparing.

This records the decision taken on 27 October 2026, while designing
permissionless multi-oracle registries
(`specs/request-approval-fold/decisions.md`). It follows Singular's second
product milestone, whose presence, absent and terminal witnesses introduced
proof durability (https://github.com/lambdasistemi/singular/milestone/5).

## The problem

- **A proof against the root is invalidated by any write.** A consumer proves
  a fact about one key against the registry's root and references the
  registry state that carries it. A fold writing a different key spends that
  output and changes the root; the fact still holds, but the prepared
  transaction can no longer use the reference and must be rebuilt against the
  new root.

## Decided

- **Open MPFS includes durable witnesses** of three facts about one key in
  one registry: the key is absent, the key is present, the key holds an exact
  value.
- **Anyone can extract a witness by funding its deposit.** The extractor is
  the witness's issuer and is owed the deposit when the witness is consumed.
- **A witness stays usable until the next change to its key.** Writes to
  other keys move the root without making it unusable, and leave its deposit
  in place.
- **The registry tracks the witness obligation per key, and every fold must
  comply.** The next change to a tracked key consumes its witness and returns
  the deposit to its issuer in the same fold. A fold that leaves the old
  witness usable, omits the refund or diverts it is invalid.
- **A value change consumes a presence witness** even when the key stays
  present. Insertion consumes an absence witness; update or deletion consumes
  presence and exact-value witnesses.
- **A key has at most one witness.** Its next change therefore carries at
  most one consumption and one refund.
- **A key's entry is unwitnessed or witnessed.** An unwitnessed key holds
  its value, or has no entry at all when it is absent. A witnessed key's entry
  is the witness: the value it attests, or the absence it attests, and the
  refund address. No tracking lives outside the tree, and the fold proves the
  obligation with the tree proofs it already builds.
- **A witnessed absence reads as absent.** For conditions and readers, a key
  whose entry is an absence witness is absent, exactly like a key with no
  entry.
- **Extraction is a request.** It is folded like a write, and changes the
  key's entry from unwitnessed to witnessed without changing its value or
  absence. A key already witnessed cannot be witnessed again until its next
  change.
- **A `set` request can include the witnessing.** The request writes the
  value and asks for it to be witnessed, funding the deposit and naming the
  refund address; the key's new entry is the witness of the value written. On
  a key already witnessed, the same fold consumes the old witness and refunds
  its issuer, then writes the new one.
- **The next change consumes the witness.** A `set` or `unset` on a witnessed
  key must prove its entry against the root, burns the witness, and pays the
  deposit to the refund address in the entry. The key is then unwitnessed:
  its new value, or no entry. The proof of the entry is what makes the
  obligation impossible to skip.
- **The deposit is a separate obligation** from the request's oracle fees,
  the folder's remainder and any refund to the request owner.
- **A witness attests what the registry records.** Its meaning in the outside
  world still rests on the registry's rule and oracles. It is not a reusable
  oracle attestation shared across registries, which remains an open
  question of its own.

## Not decided

- Whether an extraction request passes through the registry's rule and
  required judges, or needs only its deposit.
- Where the witness token is held and how a consumer references it.
