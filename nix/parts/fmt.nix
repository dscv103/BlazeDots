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

      # Add proper checks for linting and formatting
      checks = {
        # Nix linting with statix (opinionated lints)
        statix = pkgs.runCommand "statix-check" { buildInputs = [ pkgs.statix ]; } ''
          cd ${./.}/..
          statix check .
          touch $out
        '';

        # Dead code detection with deadnix
        deadnix = pkgs.runCommand "deadnix-check" { buildInputs = [ pkgs.deadnix ]; } ''
          cd ${./.}/..
          deadnix --fail .
          touch $out
        '';
      };

      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          # Nix formatting
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt;
          };

          # Markdown formatting
          prettier = {
            enable = true;
            includes = [
              "*.md"
              "*.json"
              "*.yml"
              "*.yaml"
            ];
            excludes = [ "flake.lock" ];
          };
        };
      };
    };
}
