# Development

## Prerequisites

- [Nix](https://nixos.org/) with flakes enabled
- [just](https://github.com/casey/just) (optional, for convenience recipes)

## Building

Build the Plutus blueprint (`plutus.json`) in a reproducible Nix sandbox:

```sh
just build
# or directly:
nix build
```

The output is a symlink `result` pointing to the produced `plutus.json`.

## Development shell

The default shell provides GHC, cabal, Aiken, Lean, fourmolu, and hlint:

```sh
just develop
# or directly:
nix develop
```

An Aiken-only lightweight shell is also available:

```sh
just develop-aiken
# or: nix develop .#aiken
```

## Testing

### Aiken tests

Run the Aiken test suite (unit tests + property tests):

```sh
just test
```

### Haskell tests

Run QuickCheck property tests for PlutusData roundtrips and constructor indices:

```sh
nix run .#cage-tests
```

### Lean proofs

Build the formal proofs (phase exclusivity, token handling):

```sh
cd lean && lake build
```

### Blaster UPLC properties

Build the compiled-code property checks against the Aiken-generated UPLC:

```sh
just blaster-build
# or directly:
nix build -L .#mpfs-cage-blaster
```

See [Blaster UPLC Properties](architecture/blaster.md) for the build graph,
cache checks, and how to add new properties.

## Nix checks and apps

The flake exposes checks (sandboxed derivations) and apps (runnable wrappers):

| Check | What it verifies |
|-------|-----------------|
| `library` | Haskell cage library compiles |
| `cage-tests` | QuickCheck property tests pass |
| `cage-test-vectors` | Test vector generator builds |
| `lint` | fourmolu + hlint pass |
| `vectors-freshness` | Committed `cage_vectors.ak` matches generated output |

```sh
# Build all checks
nix build .#checks.x86_64-linux.library
nix build .#checks.x86_64-linux.cage-tests

# Run tests with stdout visible
nix run .#cage-tests
nix run .#lint
```

## Test vectors

The Haskell cage library includes a test vector generator
(`cage-test-vectors`) that produces deterministic test data in
two formats:

- **Aiken** (`--aiken`): generates `cage_vectors.ak` used by the
  Aiken unit tests for cross-language validation
- **JSON** (default): language-neutral vectors for any backend

```sh
# Regenerate Aiken vectors and format them
just generate-vectors

# Check committed vectors are up to date
just vectors-check
```

CI runs `vectors-freshness` to ensure committed vectors match the
Haskell reference.

## Justfile recipes

| Recipe | Description |
|--------|-------------|
| `just build` | Build `plutus.json` via Nix |
| `just develop` | Enter dev shell (Haskell + Aiken + Lean) |
| `just develop-aiken` | Enter Aiken-only dev shell |
| `just aiken-build` | Build blueprint directly with `aiken` |
| `just test` | Run `aiken check` tests |
| `just generate-vectors` | Regenerate `cage_vectors.ak` from Haskell |
| `just vectors-check` | Verify committed vectors are fresh |
| `just haskell-build` | Build Haskell cage library with cabal |
| `just haskell-e2e` | Run Haskell E2E tests against a devnet |
| `just blaster-generate` | Generate local UPLC files for manual Blaster/Lake work |
| `just blaster-update` | Update pinned Blaster flake inputs |
| `just blaster-build` | Build the Nix-backed Blaster UPLC property package |

## How the Nix build works

The flake pre-fetches the three Aiken dependencies
([stdlib](https://github.com/aiken-lang/stdlib),
[fuzz](https://github.com/aiken-lang/fuzz),
[merkle-patricia-forestry](https://github.com/aiken-lang/merkle-patricia-forestry))
using `fetchFromGitHub` and populates `build/packages/` before
running `aiken build`. This avoids network access inside the Nix
sandbox.

The Haskell cage library is built via
[haskell.nix](https://github.com/input-output-hk/haskell.nix)
with GHC 9.8.4 and dependencies from
[CHaP](https://github.com/intersectmbo/cardano-haskell-packages).

The Blaster bridge is also built by Nix. The flake builds the Aiken blueprint,
extracts the split validator `compiledCode` entries, injects those generated
UPLC files into the `lean-blaster/` package, and then builds
`.#mpfs-cage-blaster` with the pinned Lean-blaster inputs.
