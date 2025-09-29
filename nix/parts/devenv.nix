# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ inputs, ... }:
{
  perSystem =
    {
      config,
      pkgs,
      lib,
      system,
      ...
    }:
    {
      # Expose devenv shells via flake outputs
      devenv.shells.default = {
        imports = [
          (inputs.self + "/devenv.nix")
        ];
      };
    };
}
