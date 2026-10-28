# Oracle slots and check protocols: draft

As someone creating a registry, I want to say which oracle judges which part
of my keys, and under which published check, so that I can combine
independent providers, keep parts of the registry gated by my rule alone, and
compare the providers of one check by price.

This is a draft written on 27 October 2026, while working through the moog
registry as an example (`docs/design/registries/slots.md`). It extends
`specs/request-approval-fold/decisions.md` and `specs/oracle-identity/decisions.md`.
Nothing here is decided until its open points are settled.

## Where each check belongs

- **An oracle is needed only where the chain cannot see the data.** A check
  of a signature belongs to the rule, which runs when the request is created.
  A check of the tree belongs to a condition, which the fold proves. An
  oracle is for the outside world: files on GitHub, a commit, a build.
- **The `equals` condition ties a signer to the tree.** A rule can demand the
  condition "the user's registered key equals the key that signed", so a
  registration made earlier in the tree authorizes a later request without an
  oracle.
- **A service that only reports its own work is a key in the rule, not an
  oracle.** The moog agent's acceptances and results are trusted because the
  agent signed them; the chain checks only its signature and the previous
  state. Scoping its key to its own prefix, and requiring that a result is not
  overwritten, are what the registry adds.

## Slots (leaning)

- **A registry names its oracles in slots.** A slot is an oracle identity, the
  hash of a check protocol, a key prefix and parameters. Keys are bytes, and a
  prefix is a plain byte comparison.
- **A write needs approval only from the slots whose prefix matches its key.**
  Writes to keys under no slot are gated by the rule alone. This replaces
  "every oracle approves every request".
- **A registry without a rule refuses writes to keys under no slot**,
  otherwise anyone could write them.
- **When several slots match a key, all of them must approve.**

## Check protocols (leaning)

- **A check protocol is a document named by hash**, published by whoever
  writes the checking software. It defines, in CDDL, the parameters, the part
  of the key after the slot's prefix, the value, and when a set or an unset is
  approved. The chain never reads it.
- **An oracle reads slots, not registry documents.** The checks it implements
  are its own code; it engages a slot when it implements its check, accepts
  its parameters and the request pays its price. Engaging needs no
  transaction: an oracle that does not want a slot never answers it.
- **A key or value that does not parse under the check is refused**, and the
  refusal is paid like any judgment.
- **A new version of a check is a new hash**, and therefore a new registry.
- **Under a slot's prefix the registry imports the check's shapes.** The
  registry protocol does not define keys or values under a slot prefix; it
  uses the check's `suffix` and `value`, so the two cannot disagree. The rule
  may only narrow them, and a field that names a key under another slot uses
  that slot's suffix type.
- **A registry protocol ships a request zoo**: one sample request of every
  kind it expects. Before creation, a tool validates each sample against the
  check of the slot it falls under, the slot's parameters against the
  check's `params`, and the rule's shapes and demanded conditions; a provider
  may offer a free dry run of its check. A zoo that passes means the registry
  engages its checks correctly; the probe after creation only confirms that
  the providers are live and the fees are right.

## Liveness (decided)

- **Liveness is incentivized, not enforced.** An oracle that stops answering
  stalls every write under its slots, and nothing on chain replaces it: a
  fallback judge would reintroduce an owner. Oracles are paid for every
  judgment, approving or refusing, so answering is what earns. A creator
  protects a registry by choosing providers, and by naming a group of
  competing providers of the same check, whose threshold trades liveness
  against how many must agree. A registry whose oracles are gone is dead; its
  users create a new one.
- **Creating a registry is a challenge to its oracles.** Nothing is negotiated
  before creation: the creator names providers, checks and parameters, and
  the providers answer or stay silent. Whether a slot is served is known only
  when its kinds of request have been judged, so a creator probes each slot
  with one request of each kind it expects, and abandons the registry, at the
  cost of its creation, if a slot stays silent.

## Open

- Whether prices are announced per check protocol (an offer token named after
  the check, listing every provider of it in one query) instead of per oracle.
- Whether the request fee is declared per matching slot, and whether a
  judgment's name binds the slot, for an oracle that sits in two slots
  matching the same key.
- The cost of the prefix comparisons in the fold, and the Lean model's change
  from a fixed oracle set to slots.
