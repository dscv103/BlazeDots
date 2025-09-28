# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ lib, pkgs, ... }:
let
  kernelPackages = {
    latest = pkgs.linuxPackages_latest;
    lts = pkgs.linuxPackages_lts;
    "6_10" = pkgs.linuxKernel.packages.linux_6_10;
  };
  selectedKernel = lib.getAttr "latest" kernelPackages;
in
{
  boot = {
    kernelPackages = lib.mkDefault selectedKernel;
    tmp.cleanOnBoot = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
