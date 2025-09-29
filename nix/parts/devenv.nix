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
      # Expose devenv shells via flake outputs (override fmt.nix devShell)
      devShells.default = lib.mkForce config.devenv.shells.default.shell;
      
      devenv.shells.default = {
        devenv.root = toString ./.;

        imports = [
          (inputs.self + "/devenv.nix")
        ];
      };
    };
}
