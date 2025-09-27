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
    # Use exported modules for cleaner imports
    self.modules.nixos.base
    self.modules.nixos.cpu
    self.modules.nixos.kernel
    self.modules.nixos.caches
    self.modules.nixos.desktop
    self.modules.nixos.nvidia
    self.modules.nixos.sops
    self.modules.nixos.impermanence
    self.modules.nixos.disko
  ];

  services.displayManager.defaultSession = lib.mkDefault "niri";

  environment.systemPackages = lib.mkAfter [ pkgs.disko ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  services.noctalia-shell.enable = true;
}
