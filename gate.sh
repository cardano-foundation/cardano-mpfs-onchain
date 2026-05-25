#!/usr/bin/env bash
# Mechanical gate for fix/55-cage-ledger-1-21-pins.
# Removed in the final commit before the PR is marked ready.
set -euo pipefail

git diff --check

# Haskell library must build under the target ledger pins.
nix build --quiet .#checks.x86_64-linux.library

# Cage Haskell unit/property tests must pass.
nix build --quiet .#checks.x86_64-linux.cage-tests

# Generated cage vectors must still match the haskell reference.
nix build --quiet .#checks.x86_64-linux.cage-test-vectors

# HLint must stay clean.
nix build --quiet .#checks.x86_64-linux.lint

# Vectors-freshness must hold (haskell <-> aiken cross-check).
nix build --quiet .#checks.x86_64-linux.vectors-freshness

# Aiken side untouched — sanity check that the bumped flake inputs did
# not break the on-chain build.
nix build --quiet .#checks.x86_64-linux.aiken-check
nix build --quiet .#checks.x86_64-linux.aiken-build
