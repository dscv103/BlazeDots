# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ lib, config, ... }:
{
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "schedutil";
  };

  boot.kernelParams = lib.mkBefore [ "amd_pstate=active" ];
}
