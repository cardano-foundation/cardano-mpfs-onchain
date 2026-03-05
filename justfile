# Build plutus.json blueprint via Nix
build:
    nix build

# Enter development shell with aiken
develop:
    nix develop

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

# Start Yaci DevKit for E2E tests
e2e-up:
    docker compose -f e2e/docker-compose.yml up -d yaci-cli

# Stop Yaci DevKit and remove volumes
e2e-down:
    docker compose -f e2e/docker-compose.yml down -v

# Run E2E tests (starts infrastructure, runs tests, stops on exit)
e2e-test:
    docker compose -f e2e/docker-compose.yml up --build --abort-on-container-exit test-runner

# Full E2E cycle: clean start, run tests, clean stop
e2e:
    just e2e-down
    just e2e-test
    just e2e-down
