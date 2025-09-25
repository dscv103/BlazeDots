# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{
  lib,
  config,
  pkgs,
  ...
}:
{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      open = lib.mkDefault true;
    };
  };

  boot.blacklistedKernelModules = lib.mkBefore [ "nouveau" ];
  boot.kernelParams = lib.mkBefore [ "nvidia-drm.modeset=1" ];

  services.desktopManager.plasma6.enable = lib.mkForce false;

  environment.systemPackages = lib.mkAfter [ pkgs.nvidia-vaapi-driver ];
}
