# Optimistic off-chain batch updates with on-chain challenge

**Status:** Proposal / RFC — not yet implemented.
**Scope:** an additive extension to the cage protocol. The synchronous `Modify`
path is unchanged and remains available; everything here is opt-in.

## Summary

Today every MPFS update is an on-chain, validator-checked MPF root transition: each
`Insert/Delete/Update` carries an MPF proof and is folded on-chain over a running root
(`validModify`, `cage.ak`). That is sound but pays the heaviest ExUnits per operation,
which is why batches are capped (`signingful.md`: "do not batch more than 4 requests").

This proposal adds **optimistic batching** in two phases:

- **Part 1 — execution rollup.** The oracle commits a batch by publishing the full
  operation log on-chain but *without* re-running the MPF fold; the pure tree transition
  is verified only if challenged. This cuts the **oracle's** per-op cost.
- **Part 2 — signed-intent submission rollup.** Requesters submit changes as off-chain
  signatures (no per-request transaction); only the aggregated batch hits L1. This cuts
  the **requester's** dominant cost — the per-request transaction itself.

Both phases preserve the protocol's defining invariant.

## The invariant (must not weaken)

> **The Merkle tree is always completely known, and the full database content is
> completely known to — and independently reconstructable by — any user, so that any
> user can challenge (prove on-chain) that a token's root was updated without following
> the rules.**

Today this holds because every modification is an on-chain, validator-checked
transition, making the full history reconstructable from chain history (`intro.md`,
`architecture.md`, `properties.md`). The naïve batch — commit a `newRoot`, drop the
on-chain fold — breaks it: a malicious oracle could commit a root that does not follow
the rules. The mechanisms below restore the invariant via *ledger-forced data
availability* + *single-step fraud proofs*.

---

# Part 1 — Execution rollup (cheap for the oracle)

## 1.1 On-chain state & redeemers

**Cage `State` datum** — add to the existing `owner, root (= last finalized), tip,
process_time, retract_time`:

- `max_depth: Int` — immutable, set at mint. Bounds pipeline depth ⇒ bounds cascade
  size, live compensation UTxOs, and worst-case user exposure.
- `invalid_from: Option<BatchIndex>` — fraud watermark (§1.6).
- `open_depth: Int` — committed-but-unfinalized batch count.

**Pending batches** are a **linked chain of per-batch commitment UTxOs** (not a list in
the hot `State` datum — that would exceed the datum size at depth). Each carries
`{ index, old_root, candidate_root, trace_root, step_count, deadline, bond, manifest_ref,
predecessor_ref }`.

**Redeemers** — additive; the synchronous path stays: keep `Modify / End / Contribute /
Retract`; add `CommitBatch`, `FinalizeBatch`, `ChallengeBatch(BadStepResult |
BadPrecondition)`, `SweepOrphan`, `DepositBond / WithdrawBond`.

## 1.2 Data availability — what *forces* publication

A Merkle root is a *binding commitment*, not data availability. The forcing mechanism:

- The operation log is published as **inline `BatchChunkDatum`s** in real tx outputs at a
  DA validator. An inline datum is stored in the **block body** that created its output —
  permanent in chain history whether or not the UTxO is later spent.
- Each `Step = { index, request_ref, action(Applied|Rejected), request_key, operation,
  claimed_post_root }` is **self-contained** (key + operation + values in the clear, not a
  hash) so a challenger can rebuild the trie at any intermediate root by folding from the
  last finalized root — no join against request-creation txs, no indexer dependency.
- The manifest validator folds `trace_root` **only over bytes it observed as inline
  datums on real outputs** — never a bare hash. Seal exposes `trace_root, step_count,
  final_root`.
- Therefore a sealed `trace_root` is a commitment whose **every preimage is provably in a
  historical block**. This upgrades the documented data-availability gap — the server
  "cannot lie about what it serves, but is not forced to serve everything" — to "the
  ledger already recorded everything the commitment covers." Parity with the strongest
  property the docs already claim (reconstructable from chain history).
- **Chunk UTxOs are spent/cleaned immediately after `CommitBatch`** ("calldata, not
  state"); the durable anchor is `trace_root` in the per-batch commitment UTxO.

## 1.3 Commit-time checks (ephemeral — never deferred)

Anything depending on transient state (the request UTxOs and their context) is gone from
the tip once consumed, so it cannot be re-litigated later. `CommitBatch` verifies
on-chain, reusing the non-MPF half of today's `validModify`:

- token match;
- **per-step ↔ consumed-request bijection**: each step's `(request_key, operation)`
  equals the consumed `RequestDatum`'s `(requestKey, requestValue)`;
- **exact count** — `expect actionsTail == []`. *(Today's fold discards the tail via `_`
  in `cage.ak`, despite `types.ak` declaring the action list exact; under batching this
  must be tightened or a fabricated step backing no request leaks. See Appendix A.)*
- `tip == state.tip`; phase legality (`in_phase1` / `is_rejectable`); refund conservation
  (as in `cage.ak`);
- `candidate_root == manifest.final_root` (this is the old "EndpointFraud" — a *commit*
  check, not a challenge);
- `old_root == predecessor.candidate_root` (inter-batch linkage ⇒ the whole pipeline is
  one derived root-chain);
- `open_depth < max_depth`;
- preserve `owner / process_time / retract_time / tip / max_depth`.

Only the **pure MPF transition** is optimistic.

## 1.4 The challenge surface — exactly two single-step proofs

`pre_root[i]` is **derived, never stored**: `old_root` for `i = 0`, else
`claimed_post_root[i-1]`. This *eliminates* a "LinkFraud" type and moves "EndpointFraud"
to the commit check above. What remains is two pure-MPF, single-step proofs — each ≈ the
one MPF mutation the validator already does per request:

- **`BadStepResult`** (precondition holds, result wrong). Carries: the disputed `Step`;
  a Merkle inclusion of step *j* into `trace_root`; `pre_root[j]` (derived; `old_root`
  from the commitment UTxO for *j*=0, else `claimed[j-1]` + its inclusion); and the MPF
  `Proof` against `pre_root[j]`. Validator verifies inclusion, derives `pre_root`, runs
  the existing **aborting** `mpf.insert/delete/update`, and `expect result != claimed[j]`.
- **`BadPrecondition`** (Insert on a present key; Delete/Update on an absent key or wrong
  old-value). Uses **non-aborting** predicates: `has` is already value-bearing
  (`including(key,value,proof)==root`) and covers present / wrong-value; the **only new
  primitive** is `missing(root,key,proof) = excluding(key,proof)==root` (wrapping the
  private `excluding`) for the key-absent case.

The challenger **generates the proof locally** by replaying the op log to `pre_root[j]`
(why full DA is load-bearing). The on-chain check is one MPF mutation + two Merkle paths.

## 1.5 Soundness (completeness theorem)

Honest semantics = `validModify`'s fold with MPF deferred. Every cheat maps to a
detection: endpoint lie → commit; root-chain break → eliminated (derived `pre_root`);
result wrong → `BadStepResult`; precondition violated → `BadPrecondition`; fabricated
step / uncovered request → commit bijection + `actionsTail==[]`; reordering → fold is
over canonically-ordered ledger `inputs`, `uncons` binds step *i* to the *i*-th matching
input; omission/censorship → not validity fraud, handled by the existing phase/`Retract`
model; double-spend a request → ledger (consumed once).

**Induction (first divergence).** If commit passed, the oracle's only residual freedom is
the `claimed_post_root` values. If the batch is invalid, the last claim ≠ the honest fold,
so there is a *first* `j` where `claimed[j]` diverges and `claimed[i]=h_i` ∀ `i<j`; hence
`pre_root[j] = claimed[j-1] = h_{j-1}` is honest. At *j*, either the precondition fails on
`h_{j-1}` (⇒ `BadPrecondition`) or it holds and `apply(op_j, h_{j-1}) ≠ claimed[j]` (⇒
`BadStepResult`). A **single-step** proof at the first divergence — no on-chain
re-execution. Dual (no false slashing): an honest step admits no valid challenge; a bogus
challenge fails its own `expect`.

## 1.6 Pipelining & cascade reversion

A single pending slot with a full window per batch serializes throughput behind the
window (worse than today's immediately-final `Modify`). So batches **pipeline**:

- Commit at tx rate; finalize one window later, **in order**: `FinalizeBatch(k)` requires
  `finalized(k-1)` ∧ `deadline` passed ∧ `k < invalid_from`. Finalized ⇒ unchallengeable.
- **`invalid_from` is monotone-down**: `ChallengeBatch(j)` accepted only if `j <
  (invalid_from ?? +∞)` ∧ `¬finalized(j)`; on success `invalid_from := some(j)`. Batches
  `index < invalid_from` finalize normally.
- **Load-bearing lemma:** because finalization is in-order *and* finalized batches are
  unchallengeable, the challengeable set is always a contiguous un-finalized suffix — a
  later challenge to an earlier batch can never retroactively invalidate an already-
  finalized one.
- A challenge rolls `State.root` back to *j*'s `old_root`, sets the watermark, slashes
  *j*'s bond. The suffix `k > invalid_from` self-invalidates; `SweepOrphan(k)`
  permissionlessly returns *k*'s bond to compensation. No unbounded on-chain spends.

## 1.7 Bonds, compensation, incentives

- **Per-batch bond** ≥ `challenger_reward + step_count·per_request_comp + fragment_min_ada
  + fees`, locked for the whole window (`WithdrawBond` only after clean finalize).
- **Oracle working capital = `bond × open_depth`** (≤ `max_depth`) — the real throughput
  governor, not the window.
- **Reverted requesters are compensated, not restored** (consumed request UTxOs can't be
  un-spent). Compensation is **requester-pull**: per-request `CompensationDatum` UTxOs
  keyed by `(batch_id, request_ref)`, owned by the requester ⇒ one UTxO per request, no
  races, no stranded funds. (Eager-at-commit or lazy-from-slashed-bond — both safe.)
- **No challenger bond needed:** a spurious challenge fails its own `expect` and burns the
  challenger's collateral — built-in anti-grief.

---

# Part 2 — Signed-intent submission rollup (cheap for the requester)

Part 1 rolls up *execution*; the requester still pays a full L1 transaction per request
(fee + min-ADA request UTxO + tip), and the optimistic path adds window latency and
revert risk. Part 2 makes the *normal* request path off-chain.

## 2.1 Off-chain signed intents

The requester signs a domain-separated message and sends it to the oracle off-chain (no
tx, no UTxO):

```
MPFS_INTENT_V2( cage_version, request_token, owner_vkh, deposit_account,
                request_key, operation, max_tip, nonce, deadline_slot )
```

Each batch `Step` becomes **self-authorizing DA**, carried in full in the inline-datum
chunk: `{ index, source: OffchainIntent | ForcedRequestRef, owner_vkh, owner_pubkey,
request_token, request_key, operation, max_tip, nonce, deadline_slot, deposit_account,
signature, claimed_post_root }`. This **replaces** Part 1's "step ↔ consumed
`RequestDatum` bijection" with commit-time checks (§2.2). The full intent preimage is
on-chain, so anyone replaying history sees the exact authorized operation stream;
fabricated, altered, expired, or replayed intents are validator failures, not missing
data — the invariant is preserved.

## 2.2 Fee settlement: per-requester deposit UTxOs

One on-chain deposit amortizes many off-chain intents.

```
DepositDatum { token_id, owner_vkh, next_nonce, locked_until }   -- NO `balance` field
```

The UTxO's **lovelace value is the balance** (ledger forbids overspend — no on-chain
underflow check needed). `CommitBatch`: consumes each touched deposit once; requires that
requester's intents use **consecutive nonces** from `next_nonce` (replay/double-spend
blocked by UTxO linearity + nonce monotonicity); debits exactly `state.tip` per accepted
intent into a per-batch **`TipEscrow`**; outputs the deposit with `next_nonce + count`.

Tips sit in **one `TipEscrow` UTxO per batch**. On clean `FinalizeBatch` the oracle
withdraws them; on challenge/orphan, `SweepOrphan` splits escrow + slashed bond into
refund credits (§2.5).

**New commit-time-only obligations** (all non-MPF, none optimistic):

- **deposit→escrow conservation:** `Σ(deposit_in − deposit_out) + Σ(refund_credits_in) ==
  tips_moved_to_escrow` (a *different* value flow than Part 1's refund conservation, so
  not inherited; with `state.tip ≤ max_tip` this closes the wrong-tip gap);
- **no underflow:** free — `balance` dropped from the datum, ledger-enforced;
- **account binding:** `consumed_deposit.owner_vkh == hash(intent.owner_pubkey)`.

## 2.3 Why funds-touching auth cannot be optimistic

The deposit UTxO **never reverts** (a confirmed L1 spend). A forged-but-later-challenged
intent would permanently advance the requester's `next_nonce`; even after escrow refunds
the lovelace, the requester's real nonce-N intent is dead. *The amount is recoverable;
the sequence state is not.* So every deposit mutation (signature, nonce, debit) is
**commit-time**. Commit now does one Ed25519 verify per intent; this is the binding,
non-chunkable batch-size cap. Net it stays far above today's "≤4": deferring the MPF fold
frees the budget the heavy MPF mutation used to consume (one Ed25519 ≪ one MPF mutation
over a log₁₆(N) trie). **Ed25519 throughput must be measured to set the max batch size.**

## 2.4 The deposit DoS and its fix (load-bearing)

A naïve "owner can cancel/spend the deposit anytime" gives the requester a spend path on
a UTxO the oracle's in-flight, mempool-chained batches depend on. The requester spends
their deposit first → the chained batch suffix dies → one requester griefs everyone. Fix
— port the Phase-1 time-lock to the deposit:

- Deposit datum carries `locked_until: Slot`.
- A `CommitBatch` debit sets `locked_until' = max(old, tx.validity_upper + Δ)`; the
  **oracle's debit has no lock precondition** but can only extend the lock by consuming a
  **fresh, valid signed intent** (so the lock lapses within Δ once the requester stops
  signing).
- The requester's `Withdraw`/`Cancel` requires `tx.validity_lower > locked_until`.
- `Δ = deposit_lock_delta_slots`, an **immutable cage parameter set at mint** alongside
  `max_depth`: `deposit_lock_delta_slots = max_depth · commit_confirm_bound +
  safety_margin`.

Cost: instant unilateral cancel is gone; cancellation latency = `max(deadline_slot, Δ)`
— exactly the discipline the requester already has under v1 (no instant retract), so no
new trust assumption.

## 2.5 The revert path stays cheap

Refunds must **never** roll back into the chained deposit (that re-creates a moving
serialization point) and **nonces never roll back**. A challenge/sweep pays refunds +
compensation into loose, **auto-recreditable** credits:

```
RefundCreditDatum { token_id, owner_vkh, batch_index, amount, fold_until }
```

The **next** `CommitBatch` touching that requester consumes any still-foldable credits
for `owner_vkh` **in the same tx that already serializes on that deposit**, folding them
back at no extra requester tx and no new serialization point. Owner withdrawal of a
credit is delayed until after `fold_until` (avoids a first-spend race); the oracle fold
requires the tx range before `fold_until`.

**Requester worst-case cost under repeated reverts = zero required L1 transactions** while
they keep using MPFS: credits accumulate as claimable loose ADA and fold on the next
successful oracle commit touching them. They pay a tx only to **exit** (withdraw).

## 2.6 Anti-censorship: liveness-via-escape-hatch (honest scope)

A pure off-chain intent leaves **no on-chain artifact**, so an oracle silently dropping it
is **undetectable and unpunishable**. The real guarantee: the on-chain `RequestDatum` path
survives as a `ForcedRequest`. An un-consumed live request UTxO past `submitted_at +
process_time` is **proof of non-inclusion** → the requester `Retract`s or files
`CensorshipClaim` against the oracle bond. So the v2 guarantee is **liveness via escape
hatch** (force inclusion at L1; that path slashes a silent oracle), *not* punish-the-censor
for off-chain drops. Under censorship the requester degrades to exactly v1 per-request
cost — paid only when actually censored. The forced path's deadline + penalty is
load-bearing.

## 2.7 Soundness extends unchanged

Commit-time auth makes every committed step a validly-authorized op, so the Part 1
completeness theorem carries over verbatim: the MPF **challenge surface stays exactly two**
(`BadStepResult`, `BadPrecondition`). The v2 auth classes (`BadSignatureStep`,
`DepositDebitWithoutIntent`, `ReplayedNonce`, `ExpiredIntent`, account-binding,
deposit→escrow conservation) are **commit preconditions** — they make a bad commit tx
invalid; they never land — not new optimistic challenges.

## 2.8 Requester cost: v1 vs v2

| | v1 (execution rollup) | v2 (signed-intent rollup) |
|---|---|---|
| Submit a change | full L1 tx (fee + min-ADA UTxO + tip) | off-chain signature; **no tx** |
| Steady-state L1 txs | 1 per request | ~0 (one deposit funds many; refold is the oracle's tx) |
| On revert | resubmit = another full tx | re-sign off-chain; credits auto-fold → **0 required txs** |
| Cancellation | Phase-2 `Retract` (a tx) | off-chain expiry, or wait `max(deadline, Δ)` |
| Exit (withdraw funds) | — | 1 tx, by choice, amortized over all activity |
| Under censorship | n/a | degrade to v1 per-request cost (only when censored) |

v2 unconditionally removes the requester's per-request submission cost; the oracle's
commit footprint amortizes only when many of a requester's intents cluster in one batch —
that trade-off is the oracle's, not the requester's.

---

# Formal-proof obligations (Lean)

Following the project's design-first discipline (invariants modeled as a state machine,
preservation theorems mapped to QuickCheck), the new obligations are:

- **MPF library:** `missing` predicate + `has`/`missing` soundness vs the abstract lookup
  model.
- **Cage validator (Part 1):** `tail_empty_exact_actions`,
  `commit_bijection_no_fabricated_steps`, `bad_step_result_sound`,
  `bad_precondition_sound`, `first_divergence_complete`, `honest_trace_no_false_slashing`,
  `candidate_pinned`, `interbatch_chain_linked`, `invalid_from_monotone`,
  `finalize_below_watermark_no_retroactive_invalidation`.
- **Cage validator (Part 2):** deposit→escrow conservation, account binding,
  nonce-consecutiveness, lock monotonicity, expiry.

# Open measurement items

- **Ed25519 max batch size** — measure verifies-per-commit within the ExUnits budget; this
  sets the binding (non-chunkable) batch cap in v2.
- **`Δ` (`deposit_lock_delta_slots`)** — calibrate `max_depth · commit_confirm_bound +
  safety_margin` against worst-case commit→confirmation latency under degraded chain
  quality.
- **Eager vs lazy compensation fragmentation** (Part 1) — both safe; pick on cost.

# Appendix A — a latent bug this work must fix

The current `validModify` fold discards the trailing action list with `_`, even though
`types.ak` documents the `Modify(List<RequestAction>)` list as *exact* ("must contain
exactly one action per request"). Under batching this tolerance becomes a fabricated-step
vector. The fix is the commit-time `expect actionsTail == []` already required in §1.3,
and it is worth applying to the synchronous `Modify` path independently.

# Provenance

This design was produced through an adversarial two-party design discussion (proposal →
red-team → convergence), grounded throughout in the actual validator, MPF library, and
off-chain verifier sources. It is a proposal for team review, not an accepted design.
