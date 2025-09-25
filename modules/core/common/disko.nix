# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ inputs, lib, ... }:
{
  imports = [ (inputs.self + "/hosts/blazar/modules/disko.nix") ];

  boot.supportedFilesystems = lib.mkBefore [ "btrfs" ];
}
