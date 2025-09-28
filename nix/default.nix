# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
#
# Main index for BlazeDots nix/ directory structure
{
  # Organized flake-parts modular tree for BlazeDots

  # Directory structure:
  # - lib/        : Shared utility functions
  # - overlays/   : Nixpkgs overlays and patches
  # - modules/    : NixOS, Home Manager, and profile modules
  #   - nixos/    : System-level NixOS modules
  #   - home/     : User-level Home Manager modules
  #   - profiles/ : Optional combined feature profiles
  # - packages/   : Custom package definitions
  # - parts/      : Flake-parts modules (devShells, checks, etc.)

  lib = import ./lib;
  overlays = import ./overlays;
  modules = {
    nixos = import ./modules/nixos;
    home = import ./modules/home;
    profiles = import ./modules/profiles;
  };
  packages = import ./packages;
}
