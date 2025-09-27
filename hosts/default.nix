# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ inputs, ... }:
{
  # Move nixosConfigurations into flake-parts structure
  flake.nixosConfigurations.blazar = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      inherit (inputs) self;
    };
    modules = [
      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.sops
      inputs.disko.nixosModules.disko
      inputs.impermanence.nixosModules.impermanence
      inputs.noctalia.nixosModules.default
      ./blazar/default.nix
    ];
  };
}
