# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
#
# NixOS modules index for BlazeDots flake
{
  # System-level NixOS modules

  base = ./base.nix;
  caches = ./caches.nix;
  cpu = ./cpu.nix;
  desktop = ./desktop.nix;
  disko = ./disko.nix;
  impermanence = ./impermanence.nix;
  kernel = ./kernel.nix;
  nvidia = ./nvidia.nix;
  sops = ./sops.nix;
}
