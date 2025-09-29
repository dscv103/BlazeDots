# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ ... }:
{
  imports = [
    ./fmt.nix
    ./caches.nix
    ./modules.nix
    ./devenv.nix
  ];
}
