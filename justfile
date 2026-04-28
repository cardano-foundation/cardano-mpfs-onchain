# Build plutus.json blueprint via Nix
build:
    nix build

# Enter Haskell dev shell (default)
develop:
    nix develop

# Enter Aiken-only dev shell
develop-aiken:
    nix develop .#aiken

# Build blueprint directly with aiken (requires aiken in PATH)
aiken-build:
    aiken build

# Generate cage test vectors from Haskell reference
generate-vectors:
    nix build .#test-vectors --quiet
    cp -f result validators/cage_vectors.ak
    aiken fmt validators/cage_vectors.ak

# Check that committed vectors are up to date
vectors-check:
    #!/usr/bin/env bash
    set -euo pipefail
    just generate-vectors
    if ! git diff --exit-code validators/cage_vectors.ak; then
        echo "ERROR: committed vectors are stale — run 'just generate-vectors' and commit"
        exit 1
    fi

# Run aiken tests
test:
    aiken check

# Build Haskell cage library
haskell-build:
    cd haskell && cabal build -O0 all

# Run Haskell E2E tests against a devnet
haskell-e2e:
    cd haskell && MPFS_BLUEPRINT=../plutus.json cabal test e2e-tests -O0

# Generate the hex-encoded UPLC input consumed by the experimental Blaster project
blaster-generate:
    nix develop .#aiken -c aiken build
    bash scripts/extract-blaster-uplc.sh plutus.json lean-blaster/generated

# Update the pinned Blaster flake inputs
blaster-update:
    nix flake lock --update-input leanBlaster --update-input plutusCoreBlaster --update-input cardanoLedgerApiBlaster

# Build the experimental Smartcode Verifier / Blaster bridge
blaster-build:
    nix build -L .#mpfs-cage-blaster
