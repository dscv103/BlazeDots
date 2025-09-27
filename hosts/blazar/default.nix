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
    (self + "/modules/nixos/base.nix")
    (self + "/modules/nixos/cpu.nix")
    (self + "/modules/nixos/kernel.nix")
    (self + "/modules/nixos/caches.nix")
    (self + "/modules/nixos/desktop.nix")
    (self + "/modules/nixos/nvidia.nix")
    (self + "/modules/nixos/sops.nix")
    (self + "/modules/nixos/impermanence.nix")
    (self + "/modules/nixos/disko.nix")
  ];

  services.displayManager.defaultSession = lib.mkDefault "niri";

  environment.systemPackages = lib.mkAfter [ pkgs.disko ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  services.noctalia-shell.enable = true;
}
