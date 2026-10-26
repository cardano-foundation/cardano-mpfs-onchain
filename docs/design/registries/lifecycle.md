# Request lifecycle

**As a requester, I want to know at every moment which single exit can end
my request, so that no race between parties decides its fate.**

A request lives from its creation until exactly one of three exits consumes
it: the fold, the complete account (settlement), or the owner's withdrawal.
Which exit is possible depends only on the time, measured against the
request's own deadline and window, both chosen by the requester.

## States of a request

```mermaid
stateDiagram-v2
  [*] --> Pending: requester creates it,<br/>spends the seed, mints the tags
  Pending --> Folded: fold, before the deadline,<br/>with an approval from every oracle
  Pending --> Settled: complete account, inside the window,<br/>with a verdict from every oracle
  Pending --> Withdrawn: owner, after the window
  Folded --> [*]: write applied, oracles paid,<br/>remainder to the folder, tags burned
  Settled --> [*]: oracles paid, remainder to the owner,<br/>tags burned
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
  foldw -- "deadline" --> settlew["Deadline to deadline plus window<br/><b>only the complete account</b>"]
  settlew -- "deadline plus window" --> withdraww["After the window<br/><b>only the owner's withdrawal</b>"]
```

| Window | The only exit | What it needs | Who is paid |
|---|---|---|---|
| Before the deadline | Fold | An approval from every oracle of the registry (or the oracle's signature on the fold), and every condition true against the tree at that point of the fold | Every oracle its fee; the folder the remainder |
| From the deadline to the deadline plus the window, both included | Complete account | A verdict from every oracle, approvals and refusals in any mix | Every oracle its fee; the owner the remainder |
| After the window | Owner's withdrawal | The owner's signature | The owner everything |

The windows are disjoint and together cover all time, so exactly one exit is
possible at any moment. Several folders may still compete for the same cage
state, and several parties may submit the same settlement, but the outcome
for the request never depends on who submits first: a settlement pays the
same whichever verdicts it shows.

A refusal is therefore no early exit. It is the signed record of why the
oracle declined, and the evidence a settlement needs; a refused request waits
for its deadline, which its requester chose.

## Creating a request

```mermaid
sequenceDiagram
  participant R as Requester
  participant G as Registry rule (if any)
  participant P as Request script (release-wide)
  participant C as Cage state
  R->>G: mint the request token: the rule checks the write,<br/>conditions and owner of this one request
  R->>P: spend the seed output, mint one tag per oracle, each named after its oracle
  P->>C: read the cage state by reference (the registry exists)
  P-->>R: tags minted only if escrow covers the sum of the oracles' fees
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
  participant C as Cage state
  participant Q as Request outputs
  participant J as Judgment tokens
  F->>Q: spend the chosen requests, in the chosen order
  F->>J: read one approval per oracle per request (by reference),<br/>with each oracle's conditions
  F->>C: for each request: prove the requester's and the oracles' conditions<br/>against the current tree, apply its write
  C-->>F: new root, with oracles and protocol unchanged
  F->>F: pay every oracle its fee, keep the remainders, burn the tags
```

The folder chooses which approved requests to fold and in what order. It
cannot apply an unapproved request, change a write, skip a request it
consumed, or fold the same request twice.

## Settling and withdrawing

```mermaid
sequenceDiagram
  participant A as Anyone
  participant W as Owner
  participant Q as Request output
  participant J as Judgment tokens
  Note over A,J: from the deadline to the deadline plus the window
  A->>Q: spend the request
  A->>J: read one verdict per oracle (approval or refusal)
  A-->>A: pay every oracle its fee, remainder to the owner, burn the tags
  Note over W,Q: after the window
  W->>Q: spend the request with the owner's signature
  W-->>W: take everything, burn the tags
```

After the window the chain cannot tell a silent oracle from an approval the
owner chooses not to show, so the owner takes everything and decides whether
to pay the oracles that answered. A silent oracle loses its fee; that is the
price of not answering.

## Dead judgments

Once a request has been consumed its seed can never occur again, so any
judgment still naming it is worthless. Its holder may burn it at any time,
without the request or the cage taking part.
