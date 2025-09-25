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
    (self + "/modules/core/common/base.nix")
    (self + "/modules/core/common/cpu.nix")
    (self + "/modules/core/common/kernel.nix")
    (self + "/modules/core/common/caches.nix")
    (self + "/modules/core/common/desktop.nix")
    (self + "/modules/core/common/nvidia.nix")
    (self + "/modules/core/common/sops.nix")
    (self + "/modules/core/common/impermanence.nix")
    (self + "/modules/core/common/disko.nix")
  ];

  services.displayManager.defaultSession = lib.mkDefault "niri";

  environment.systemPackages = lib.mkAfter [ pkgs.disko ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
