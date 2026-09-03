# MPFS: A Trustworthy Public Database That No One Has to Take on Faith

## 1. The human problem, in plain words

Imagine a shared list that lots of people care about. It could be a registry of who owns which web domain, a list of approved suppliers, a record of which software versions are certified safe — anything where the entries are "a name points to a fact." In computing we call this kind of list a **key/value database**: a key is the thing you look up (like a name in a phone book), and the value is what you get back (the phone number). It works like a dictionary — you look up a word and find its definition.

Almost every such list in the world today is kept by some organization on its own servers. You have to trust that organization. You trust that when they say "Company X is certified," they really were; that they didn't quietly delete an entry someone paid to make disappear; that they didn't slip in a fake one. Usually that trust is fine. Sometimes it is badly misplaced — records get altered, history gets rewritten, and you have no way to prove it, because you only ever saw what the keeper chose to show you.

The system described here, called **MPFS**, is an attempt to run exactly this kind of shared list *without* anyone having to trust the keeper. The keeper still does the day-to-day work of updating the list. But the design makes it impossible for the keeper to cheat without being caught and publicly proven wrong by anybody who bothers to look. That is the whole point: a public list you don't have to take on faith.

## 2. The cast of characters

There are only a few players, and it helps to meet them up front.

**The blockchain (specifically, Cardano).** A blockchain is a shared record book that the whole world can read, that anyone can write to under fixed rules, and that no single company or person controls. Two properties make it special. First, it is *append-only*: you can add new pages, but rewriting an old one would be visible to everyone and rejected by the network. Second, it is *tamper-evident*: if anyone managed to alter a past page, everyone would be able to tell. Think of it as a giant public notarized logbook kept simultaneously by thousands of independent record-keepers around the world, who constantly check each other's copies. Cardano is one particular blockchain; the details of which one don't matter much for this explanation. Throughout this document, "the ledger," "on-chain," and "on the blockchain" all mean the same thing: written into that public logbook. Anything "off-chain" simply means handed around privately, not written into the logbook.

**The database itself** — the key/value list we described, the thing everyone cares about.

**The operator**, which this system calls the **oracle**. This is the party that actually does the work of applying changes to the database — adding entries, removing them, editing them. Crucially, you do *not* have to trust the oracle to be honest. The system is built so that a dishonest oracle gets caught.

**The users** (sometimes called requesters). These are the people who want changes made — "please add this entry," "please update that value" — and who, along with everyone else, can watch the oracle's work and raise the alarm if something is wrong.

## 3. The core promise: a fingerprint nobody can fake

Here is the central idea, and if you understand only one thing, understand this.

You could imagine putting the entire database onto the public logbook so everyone can see it. But databases can be huge, and blockchains are expensive places to store data. So instead, MPFS stores just a **fingerprint** of the database on the blockchain — a short string of characters that acts like a unique summary of the *entire* contents.

This fingerprint is produced by a process called **hashing**. A hash is a mathematical blender: you pour in data of any size, and out comes a short fixed-length code. Two things make it useful. Change even a single character anywhere in the data, and the resulting code changes completely and unpredictably. And no one can feasibly run the blender backwards, *nor* feasibly hand-craft two different inputs that come out as the same code — and that second part is the one the blender image doesn't show you, so just take it as a known property of good hashing: matching codes mean matching data, full stop. So the fingerprint is, in effect, unforgeable. If two people both have the full database and both compute the fingerprint, they will agree — and if even one entry differs between their copies, their fingerprints will visibly disagree.

The specific kind of fingerprint MPFS uses comes from a structure called a **Merkle tree**. You don't need the mechanics, just the payoff. A Merkle tree is a way of hashing a large dataset in stages — hashing small pieces, then hashing the hashes, and so on up to a single code at the top called the **root hash**. The root hash is the fingerprint of the whole database. The Merkle tree gives you a second gift on top of the unforgeable summary: it lets someone prove a narrow fact — "the entry for key X has value Y" — with a small, checkable proof, instead of having to hand over the entire database. We'll lean on that gift later, and it turns out to be the secret behind the whole system's safety.

So: the database's root hash lives on the blockchain. To make clear *which* database that fingerprint belongs to, MPFS attaches it to a unique **token** on the blockchain. Think of the token as a labeled envelope and the root hash as the note inside it: the token is the holder, the root hash is the fingerprint it carries. A token here is like a numbered seal or a serial-numbered certificate that exists on the ledger and can't be duplicated. One token stands for one particular database, and at any moment it carries that database's current fingerprint. When the database changes, the oracle updates the root hash recorded on that token — it slips a new note into the same envelope.

From this setup, the **core promise** of the system follows directly — and here is exactly how it follows:

- **Anyone can verify the whole thing.** Get a copy of the full database, run the hashing yourself, and check that your computed root hash matches the one sitting on the token on the blockchain. If they match, then — because matching fingerprints mean matching data — you know you're looking at the real, complete, unaltered database. The oracle cannot secretly change an entry or hide one, because doing so would change the fingerprint, and your recomputed fingerprint would no longer match the token. (One caveat in today's base system: you depend on the oracle to hand you that full copy. The upgrade in Section 5 closes this gap by putting the data permanently on-chain where the oracle can't withhold it.)
- **And bad updates cannot get in at all.** Today the blockchain itself checks every single change as it is made (Section 4), so a fingerprint that does not follow from the rules is simply rejected — there is nothing to catch after the fact. The upgrade in Section 5 trades that immediate check for an after-the-fact one, and it is there that the words **challenge** and **bond** acquire meaning; neither exists in the system as it stands today.

Both points are the heart of it. We're not asking you to trust the oracle to be honest: today the rules are checked before a change is accepted, and under the Section 5 upgrade everyone has the evidence and the standing to prove a bad one after the fact.

## 4. How it works today — safe, but expensive

In the current version of MPFS, the blockchain itself is the referee for *every single change*, in real time.

When the oracle wants to apply a change, it submits two things to the blockchain together: the change itself, and a small proof. Here is what that proof does, and why it's possible even though you can't run hashing backwards. Remember the Merkle tree's gift: you can prove a narrow fact cheaply. The proof hands over just the few small pieces of the database that the change actually touches — not the whole thing — along with the steps that hash those pieces up to the root. With those pieces in hand, the blockchain can hash *forward* (the direction that always works): it confirms the pieces match the *old* fingerprint, applies the change to just those pieces, and re-hashes forward to check that the result is exactly the *new* fingerprint the oracle claims. So nobody runs the blender backwards; the proof simply supplies the small amount of original data needed to run it forward and confirm both endpoints. The blockchain only accepts the new fingerprint if that check passes.

This is wonderfully safe — a wrong update simply can't get in, because it would be rejected immediately. But it is expensive, and in *two* separate ways. The first is computation. A blockchain doesn't only charge to *store* data; it also charges to *run* calculations, because every one of those thousands of independent record-keepers has to repeat the same work to check it. Making the blockchain re-do the hashing math on every change means each change is slow and costly, and only a small number of changes can be grouped together before the cost gets too high.

There's a second cost, this one borne by users. Today, just to *ask* for a change, a user has to post their own transaction on the blockchain. A **transaction** is a single recorded action on the ledger — and posting one always costs a fee, plus a refundable **deposit** (money you put down that you get back later if all goes well). So every request a user makes costs them real money and effort, even before the oracle does anything.

In short: the present design is trustworthy but pricey, on both sides.

## 5. The clever idea: act first, check only if challenged

The proposed upgrade is called **optimistic batch updates** — where a **batch** simply means a group of changes handled together, rather than one at a time. (This upgrade is a design proposal, tracked in [epic #64](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/64); everything in Sections 1–4 above already exists.) The word "optimistic" is the key, so let's build the right mental picture before any mechanism.

Picture a sports referee with an unusual rule. Imagine an idealized stadium where every play is recorded on video and *every spectator has the full replay in their hands* — not how real stadiums work, but go with it, because that total public visibility is the whole trick. Now the referee doesn't scrutinize every play as it happens. The referee lets the game run and *only steps in when a spectator files a formal complaint* — and because everyone holds the complete video, a complaint can point to the exact frame and prove the foul beyond dispute. The referee doesn't need to watch anything in real time, because the crowd can, and the evidence is undeniable. That is "optimistic": assume things are fine, but keep complete public evidence so that any wrongdoing can be proven after the fact.

Now apply that to the database. The upgrade has two halves: one that makes things cheaper for the oracle, and one that makes things cheaper for users.

### Part 1 — Cheaper for the oracle: publish now, verify only if someone objects

Today the blockchain re-checks every change the moment it's made. The upgrade removes that immediate re-checking. Instead, the oracle does this:

1. It takes a whole batch of changes and **publishes the full list of them onto the blockchain** — not a summary, but the actual change data, written permanently into the public logbook. This matters enormously: because the real data is on the ledger, it is permanently public and *nobody can hide it*. This is the "video every spectator holds" — it's what makes everything else possible, and it's exactly the thing the base system couldn't fully guarantee.
2. It posts the new fingerprint (the new root hash) claimed to result from those changes.
3. The blockchain does **not** re-do the math right away. It simply accepts the claim for now. That's the optimism.

Then comes the safety net: a waiting period called the **challenge window** — on the order of a day and a half (roughly 36 hours). During this window, *anyone at all* can take the published list of changes, re-do the math themselves on their own computer, and look for a mistake. They don't have to prove the whole batch is wrong. They only need to find **one single step** that doesn't follow the rules.

If someone finds such a step, they submit a tiny proof of *just that one wrong step* to the blockchain. The blockchain checks that one small thing — which is cheap — and if the challenger is right, three things happen: the oracle is **caught**, the oracle **loses a security deposit** (a sum of money it had to lock up in advance, called a **bond**, precisely so it has something to lose), and the **bad change is undone** (and, as we'll see in Section 7, any later changes that were stacked on top of it are undone with it).

If the challenge window passes and nobody has found a problem, the change becomes **final** and permanent.

Now, *why* is this safe, even though the blockchain stops checking up front? This is the single most important claim in the whole document, so here it is in plain words rather than as "trust the math."

A batch isn't one big indivisible leap from the old fingerprint to the new one. It's a chain of small steps: apply change 1 to get an in-between fingerprint, apply change 2 to that, and so on, each step moving from one fingerprint to the next. The oracle has to publish every change in the batch, so the entire chain of steps is laid out in public. Now suppose the oracle wants the chain to *end* on a fingerprint it isn't entitled to — say, one representing a database where it secretly handed itself a domain it doesn't own. The chain still has to *start* from the agreed-upon old fingerprint (that one is already nailed down on the token from before). So somewhere between the honest start and the dishonest end, at least one step must not actually follow from the step before it — because if *every* step followed correctly from the previous one, the chain would have landed on the honest result, not the oracle's desired one. The lie can't be smeared evenly across the batch to hide it: hashing has no "almost correct." Each individual step either follows the rules exactly or it doesn't, and a false ending forces at least one step to visibly not follow. And here's where Section 3's Merkle gift returns: that one broken step can be isolated and disproven with a single small, cheap proof — the same "prove one narrow fact cheaply" tool, now used to prove one narrow *lie*. So a cheating oracle cannot avoid leaving at least one provably broken step sitting in plain view in the public logbook. Its only safe move is to be honest.

The win is cost. The expensive full re-verification now happens only in the rare case of an actual challenge, instead of on every change. So the oracle can process far more changes far more cheaply.

### Part 2 — Cheaper for users: sign a request like signing an email

The second half tackles the cost users bear. Recall that today, to ask for a change, you must post your own blockchain transaction and pay for it every single time.

The upgrade lets you skip that. Instead of posting a transaction, you simply **sign your change request as a message and hand it to the oracle** — no transaction, no per-request fee. This is what "off-chain" means in practice: the request travels privately from you to the oracle without being written into the public logbook (at least not yet).

The contrast worth holding onto is *signing an email versus mailing a certified letter*. A **digital signature** is a mathematical seal you can put on any message using a private secret only you hold; anyone can later verify the seal genuinely came from you and that the message wasn't altered, but no one can forge it. Signing a message is essentially free and instant — like signing an email. Posting a transaction is like mailing a certified letter: it costs money and takes a trip to the post office every time. The upgrade moves users from certified letters to signed emails.

The oracle gathers up many of these signed requests and bundles them into one batch — and, just as with the changes themselves, the signed requests get **published in the batch on the blockchain too**. So anyone can verify that the oracle applied *exactly* what users actually authorized, no more and no less.

To handle the small per-change fee without a transaction each time, a user **pre-loads a small balance once** — a one-time deposit — and each change simply draws a tiny fee from it (the system calls this fee a **tip**). The net effect on a user's costs is dramatic: instead of paying for a full transaction on every request, you pay one upfront deposit, then just a tiny tip per change.

This raises an obvious worry: if you're just handing signed notes to the oracle off to the side, can the oracle abuse that? The design closes the gaps:

- The oracle **cannot invent or alter a request**, because any request it applies must carry your valid signature, which it can't forge.
- The oracle **cannot quietly double-charge you**: because every request it processes is published in the batch for all to see, any attempt to charge you twice for the same change is right there in the public record and can be challenged like any other bad step.
- And if the oracle simply **ignores you** — refuses to include your request — you have an **escape hatch**: you can fall back to the old-fashioned on-chain request (the certified letter), which the oracle cannot quietly suppress. You'd only need this in the specific case where you're actually being censored.

## 6. What a regular user actually experiences, step by step

Putting the two halves together, here's the lived experience under the upgrade.

1. **One-time setup.** You deposit a small balance with the system. This is a single up-front cost, not something you repeat.
2. **Making a request.** When you want a change, you write it down and sign it — like signing an email — and send it to the oracle. No transaction, no fee at this moment; later a tiny tip is drawn from your pre-loaded balance.
3. **The oracle batches.** The oracle collects your request along with many others, applies them all to the database, and publishes onto the blockchain: the full list of changes, the signed requests authorizing them, and the new fingerprint. It does *not* wait for the blockchain to re-verify.
4. **The challenge window opens.** For roughly a day and a half, the new fingerprint is provisional. Anyone in the world can audit the published batch and challenge a bad step. You don't have to do this yourself; it's enough that anyone *can*, and that cheating is guaranteed to be catchable.
5. **Finalization.** If no valid challenge arrives, the change becomes permanent at the end of the window. If someone does prove a bad step, the oracle is punished and the offending changes are rolled back.

Most of the time, from your seat, it feels like: deposit once, fire off cheap signed requests, wait out a settling period, done.

## 7. The honest trade-offs

A fair explanation names the costs, not just the benefits.

- **Finality takes longer.** Under the old design a change was final as soon as the blockchain confirmed it. Under the upgrade you must wait out the challenge window — roughly 36 hours — before a change is truly permanent. You've traded quick certainty for much lower cost.
- **Someone else's fraud can undo your honest change.** Here is what "stacked on top" means concretely. The changes in a batch are applied in order, each one to the database that the previous change left behind — so change 5 is computed from the result of change 4, change 4 from change 3, and so on. They form a chain, not an independent pile. If an early change in that chain is proven fraudulent and undone, every change computed *after* it was built on a starting point that has now vanished, so those later changes have to be unwound too — *even if yours was perfectly legitimate*. The system refunds you, but you have to resubmit. Your money is safe; your change just may not stick on the first try.
- **No more instant cancellation.** Because requests now flow through batches rather than as immediate individual transactions, you can't cancel a request the very instant you change your mind; there's a short delay.
- **Censorship pushes you back to the expensive path.** If the oracle refuses to include your off-chain signed request, your remedy is the on-chain escape hatch — which costs what the old method cost. You only pay that price when you're actually being censored, but the option being there is what keeps the oracle honest about including requests.
- **It isn't built yet.** This is a design proposal. The base MPFS system — fingerprint on a token, a publicly verifiable database, real-time on-chain checking of every change — is the part that exists today. Challenges, bonds and the challenge window do not exist yet; they arrive with this upgrade. The optimistic batch upgrade described here is the proposed evolution, not a shipped feature — its design and implementation plan are tracked in [epic #64](https://github.com/cardano-foundation/cardano-mpfs-onchain/issues/64).

The thread running through every trade-off is the same bargain: by relaxing *when* and *how often* the expensive checking happens — doing it only on complaint, against permanently public evidence — the system becomes far cheaper to run and to use, while preserving the one property that matters most. No one has to trust the operator. Anyone can catch a cheat.

## 8. A separate gap: the oracle can simply stop

Everything above is about the oracle being *dishonest*. There is a second
problem, unrelated to the batching upgrade, and it is about the oracle being
*absent*.

Only the oracle can apply a request or formally discard an expired one. A user
has exactly one window in which to walk away on their own — the retraction
window. Once it closes, the request sits on the ledger and nobody but the
oracle can move it. An oracle that stops answering therefore leaves those
deposits stuck, and it costs the oracle nothing to let that happen. It is also
why a cage cannot yet be a genuinely public registry: someone always holds the
key.

The planned fix lets anyone clear expired requests, and lets a validator — a
rule, not a person — decide what a batch may do. See
[Permissionless Registries](roadmap/permissionless-registries.md). Like the
batching upgrade, none of it has shipped.

## 9. A short glossary

- **Key/value database:** a list where each key (a label you look up) maps to a value (the fact you get back), like a dictionary.
- **Blockchain (also "the ledger," "on-chain"):** a public, shared, append-only record book that anyone can read, no one controls, and no one can secretly rewrite. **Cardano** is the specific one used here.
- **Off-chain:** handed around privately between parties, not written into the blockchain.
- **Hash / fingerprint:** a short code computed from data; any change to the data changes the code completely, and the code can't feasibly be forged or reversed. Matching codes mean matching data.
- **Merkle tree / root hash:** a staged way of hashing a large dataset down to one top-level fingerprint (the root hash), which also lets you prove a single entry's value with a small proof instead of the whole dataset.
- **Token:** a unique, non-duplicable serial-numbered seal on the blockchain. Here, one token represents one database and carries its current fingerprint — the envelope that holds the note.
- **Operator / oracle:** the party that applies changes to the database. Not trusted to be honest — the design makes cheating provable.
- **Transaction:** a single recorded action on the blockchain; posting one costs a fee.
- **Deposit / bond:** money locked up in advance. Users deposit a small balance to pre-pay fees; the oracle posts a bond it forfeits if caught cheating.
- **Tip:** the small per-change fee, drawn from a user's pre-loaded deposit.
- **Digital signature:** an unforgeable mathematical seal you place on a message, proving it came from you and wasn't altered — cheap, like signing an email.
- **Batch:** a group of changes (and the requests authorizing them) handled together as one unit instead of one at a time.
- **Optimistic:** the approach of accepting changes without immediate checking, relying on public evidence and after-the-fact challenges to catch any wrongdoing.
- **Challenge / challenge window:** the period (about 36 hours) during which anyone can prove a published change broke the rules; a successful challenge punishes the oracle and undoes the bad change. Part of the Section 5 proposal, not of the system as it stands.
