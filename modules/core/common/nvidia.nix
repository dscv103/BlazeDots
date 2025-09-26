# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{
  lib,
  config,
  pkgs,
  ...
}:
{
  services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];

  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [ nvidia-vaapi-driver ];
      extraPackages32 = with pkgs.pkgsi686Linux; [ nvidia-vaapi-driver ];
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = lib.mkDefault true;
      };
      nvidiaPersistenced = lib.mkDefault true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      open = lib.mkDefault true;
    };
  };

  boot.blacklistedKernelModules = lib.mkBefore [ "nouveau" ];
  boot.kernelParams = lib.mkBefore [ "nvidia-drm.modeset=1" ];

  services.desktopManager.plasma6.enable = lib.mkForce false;

  environment.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  environment.systemPackages = lib.mkAfter [
    pkgs.nvidia-vaapi-driver
    pkgs.nvtopPackages.nvidia
  ];
}
