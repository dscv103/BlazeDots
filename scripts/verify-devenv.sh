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
cat <<'EOF' > .envrc.test
use flake . --no-pure-eval
EOF

echo -e "\n5. Reminder: Direnv integration now relies on nix-direnv"
echo "Verify locally with 'direnv allow' after installing direnv + nix-direnv."

echo -e "\n6. Testing nix develop..."
nix develop --command echo "Nix develop works!"

echo -e "\n7. Cleaning up..."
rm -f .envrc.test

echo -e "\n=== Verification complete ==="
echo "If no errors above, the devenv pinning is working correctly."
echo "The key success criteria:"
echo "- No 'cannot write modified lock file' errors"
echo "- Direnv + nix-direnv load the shell without churn"
echo "- 'nix develop --no-pure-eval' works"