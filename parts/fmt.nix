# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { pkgs, config, ... }:
    let
      treefmt = config.treefmt.build;
    in
    {
      devShells.default = pkgs.mkShell {
        name = "nixos-dev";
        inputsFrom = [ treefmt.devShell ];
        packages = with pkgs; [
          statix
          deadnix
          sops
          age
        ];
      };

      treefmt = {
        projectRootFile = "flake.nix";
        programs.nixfmt = {
          enable = true;
          package = pkgs.nixfmt;
        };
      };
    };
}
