# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ inputs, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    {
      # Define packages that might be useful across the flake
      packages = {
        # Convenience package for system management
        blazar-rebuild = pkgs.writeShellScriptBin "blazar-rebuild" ''
          set -euo pipefail
          cd "$(dirname "$(readlink -f "$0")")/../.."
          nix flake update
          sudo nixos-rebuild switch --flake .#blazar "$@"
        '';
        
        # Helper for formatting and checking
        check-all = pkgs.writeShellScriptBin "check-all" ''
          set -euo pipefail
          echo "Running all flake checks..."
          nix fmt
          nix flake check
          echo "✅ All checks passed!"
        '';
      };
    };
}