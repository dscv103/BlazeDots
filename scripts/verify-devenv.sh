#!/usr/bin/env bash
# Verification script for devenv pinned setup
# This script tests that devenv works without lock file churn

set -euo pipefail

echo "=== Devenv Verification Script ==="

echo "1. Checking flake metadata..."
nix flake metadata

echo -e "\n2. Checking if flake can be evaluated..."
nix flake check --no-build

echo -e "\n3. Testing devShells are available..."
nix eval .#devShells.x86_64-linux.default.name || echo "DevShell not available via flake"

echo -e "\n4. Creating test .envrc..."
echo "use devenv" > .envrc.test

echo -e "\n5. Testing devenv shell without lock writes..."
# This should NOT try to write any lock files for github:cachix/devenv/latest
devenv shell --envrc .envrc.test --command "echo 'DevEnv shell works!'" || echo "Direct devenv test failed"

echo -e "\n6. Testing nix develop..."
nix develop --command echo "Nix develop works!"

echo -e "\n7. Cleaning up..."
rm -f .envrc.test

echo -e "\n=== Verification complete ==="
echo "If no errors above, the devenv pinning is working correctly."
echo "The key success criteria:"
echo "- No 'cannot write modified lock file' errors"
echo "- Both 'devenv shell' and 'nix develop' work"
echo "- Flake evaluation succeeds"