# Rollback Procedure for DevEnv Pinning

If you need to rollback the devenv pinning changes:

## Files to Revert

1. **flake.nix**: Remove the devenv input and flakeModule import
   - Remove the entire `devenv = { ... }` block from inputs
   - Remove `inputs.devenv.flakeModule` from imports

2. **nix/parts/devenv.nix**: Delete this file entirely

3. **nix/parts/default.nix**: Remove `./devenv.nix` from imports

4. **README.md**: Revert installation instructions
   - Change `github:cachix/devenv/v1.9` back to `github:cachix/devenv/latest`
   - Remove the note about lock file churn

5. **scripts/verify-devenv.sh**: Delete this file (optional)

## Commands to Rollback

```bash
# Remove devenv from flake inputs
git checkout HEAD~2 -- flake.nix nix/parts/default.nix README.md
git rm nix/parts/devenv.nix scripts/verify-devenv.sh

# Clean up local state if needed
rm -f .envrc  # Remove local .envrc if present
nix flake lock  # Regenerate lock without devenv input
```

## Alternative: Use nixpkgs#devenv if available

If devenv becomes available in nixpkgs in the future, you can:

1. Remove the flake input approach entirely
2. Update README to use `nix profile install nixpkgs#devenv`
3. Remove the flake-parts devenv integration
4. Keep the existing devenv.nix file as-is