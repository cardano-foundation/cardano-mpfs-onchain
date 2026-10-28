# Request lifecycle

**As a requester, I want to know at every moment which single exit can end
my request, so that no race between parties decides its fate.**

A request lives from its creation until exactly one of three exits consumes
it: a fold applying it, a fold settling it by complete account, or the
owner's withdrawal. Which exit is possible depends only on the time, measured
against the request's own deadline and window, both chosen by the requester.

## States of a request

```mermaid
stateDiagram-v2
  [*] --> Pending: requester creates it,<br/>spends the seed, mints the tags
  Pending --> Folded: fold, before the deadline,<br/>with an approval from every oracle
  Pending --> Settled: fold item in the window: complete account,<br/>with a verdict from every oracle
  Pending --> Withdrawn: owner, after the window
  Folded --> [*]: write applied, fees credited,<br/>remainder to the folder, tags burned
  Settled --> [*]: fees credited, remainder to the owner,<br/>tags burned
  Withdrawn --> [*]: everything to the owner,<br/>tags burned
  note left of Pending
    Oracles mint approvals and refusals
    by reference: the request does not move
  end note
```

Judging never moves the request: each oracle mints its verdict into its own
wallet with the request output as a reference input. A request with several
oracles therefore has no contention while it is being judged.

## One exit per window

```mermaid
flowchart LR
  create([Creation]) --> foldw["Before the deadline<br/><b>only the fold</b><br/>judgments allowed"]
  foldw -- "deadline" --> settlew["Deadline to deadline plus window<br/><b>only a fold settling it</b><br/>by complete account"]
  settlew -- "deadline plus window" --> withdraww["After the window<br/><b>only the owner's withdrawal</b>"]
```

| Window | The only exit | What it needs | Who is paid |
|---|---|---|---|
| Before the deadline | Fold | An approval from every oracle of the registry (or the oracle's signature on the fold), and every condition true against the tree at that point of the fold | Every oracle's fee credited to its balance; the folder the remainder |
| From the deadline to the deadline plus the window, both included | Complete account, as an item of a fold | A verdict from every oracle, approvals and refusals in any mix | Every oracle's fee credited to its balance; the owner the remainder |
| After the window | Owner's withdrawal | The owner's signature | The owner everything |

The windows are disjoint and together cover all time, so exactly one exit is
possible at any moment. Several folders may still compete for the same registry
state, but the outcome for the request never depends on who submits first: a
complete account pays the same whichever verdicts it shows.

A refusal is therefore no early exit. It is the signed record of why the
oracle declined, and the evidence a complete account needs; a refused request
waits for its deadline, which its requester chose.

## Creating a request

```mermaid
sequenceDiagram
  participant R as Requester
  participant G as Registry rule (if any)
  participant P as Request script (release-wide)
  participant C as Registry state
  R->>G: mint the request token: the rule checks the write,<br/>conditions and owner of this one request
  R->>P: spend the seed output, mint one tag per oracle, each named after its oracle
  P->>C: read the registry state by reference (the registry exists)
  P-->>R: tags minted only if escrow covers the oracles' fees<br/>plus the minimum for a refund output
  R->>P: request output: registry, owner, seed, one write,<br/>conditions, fee per oracle, deadline, window, evidence
```

The seed is an output reference spent by the creating transaction. No two
requests in history can carry the same seed, so no judgment can ever be
replayed onto a copied request.

## Judging

```mermaid
sequenceDiagram
  participant O as Oracle
  participant P as Request script (minting policy)
  participant Q as Request output
  O->>O: judge the request off chain under the registry's protocol
  O->>P: mint approval or refusal, signed by the oracle
  P->>Q: read the request by reference (it is live, before its deadline)
  P-->>O: token named after registry, request with seed, oracle and verdict
```

An oracle may also skip the separate judgment and sign the fold itself; its
signature counts as its approval of every request in that fold. A registry
with one oracle that folds its own requests therefore needs one transaction
per batch, as the shipped cage does.

## Folding

```mermaid
sequenceDiagram
  participant F as Folder
  participant C as Registry state
  participant Q as Request outputs
  participant J as Judgment tokens
  F->>Q: spend the chosen requests, in the chosen order
  F->>J: read one approval per oracle per request (by reference),<br/>with each oracle's conditions
  F->>C: for each request: prove the requester's and the oracles' conditions<br/>against the current tree, apply its write
  C-->>F: new root, with oracles and protocol unchanged
  C-->>F: every oracle's fee credited to its keys' balances in the registry state
  F->>F: keep the remainders, burn the tags
```

The folder chooses which approved requests to fold and in what order. It
cannot apply an unapproved request, change a write, skip a request it
consumed, or fold the same request twice.

## Settling and withdrawing

```mermaid
sequenceDiagram
  participant F as Any folder
  participant W as Owner
  participant C as Registry state
  participant Q as Request output
  participant J as Judgment tokens
  Note over F,J: from the deadline to the deadline plus the window
  F->>Q: spend the request as an item of a fold
  F->>J: read one verdict per oracle (approval or refusal)
  F->>C: credit every oracle's fee to its keys' balances
  F-->>W: the remainder, in one refund output
  Note over W,Q: after the window
  W->>Q: spend the request with the owner's signature
  W-->>W: take everything, burn the tags
```

The complete account is an item of a fold because it credits fees, and only
a fold changes the registry state. It earns the folder nothing, so the parties that want
it folded are the owner, waiting for its refund, and the oracles, waiting for
their fees; folding is permissionless, so either can fold it. A fold may mix
complete accounts with writes and claims as long as its validity interval
fits every item's window.

After the window the chain cannot tell a silent oracle from an approval the
owner chooses not to show, so the owner takes everything and decides whether
to pay the oracles that answered. A silent oracle loses its fee; that is the
price of not answering. The withdrawal does not touch the registry state.

## Claiming fees

```mermaid
sequenceDiagram
  participant K as Key oracle
  participant P as Request script (release-wide)
  participant F as Any folder
  participant C as Registry state
  K->>P: create a claim: mint the claim token with the key's signature,<br/>name the payout address and datum, add a tip
  F->>C: fold the claim at its turn
  C-->>K: the key's whole balance, to exactly that address and datum
  F-->>F: keep the tip, burn the claim token
```

A claim is a request without a write. The oracle chooses when to claim, so it
pays the ledger's minimum for an output once per claim, out of fees that have
grown large enough, instead of once per oracle per request. A folder may leave
a claim out; the oracle can then fold it itself. A claim not folded by its
deadline goes back to the oracle.

## Dead judgments

Once a request has been consumed its seed can never occur again, so any
judgment still naming it is worthless. Its holder may burn it at any time,
without the request or the registry state taking part.
