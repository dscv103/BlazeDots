# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{
  self,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    (self + "/nix/modules/nixos/base.nix")
    (self + "/nix/modules/nixos/cpu.nix")
    (self + "/nix/modules/nixos/kernel.nix")
    (self + "/nix/modules/nixos/caches.nix")
    (self + "/nix/modules/nixos/desktop.nix")
    (self + "/nix/modules/nixos/nvidia.nix")
    (self + "/nix/modules/nixos/sops.nix")
    (self + "/nix/modules/nixos/impermanence.nix")
    (self + "/nix/modules/nixos/disko.nix")
  ];

  services.displayManager.defaultSession = lib.mkDefault "niri";

  environment.systemPackages = lib.mkAfter [ pkgs.disko ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  services.noctalia-shell.enable = true;
}
