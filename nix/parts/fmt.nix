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

      # Add proper checks for linting and formatting with parallelization
      checks = {
        # Nix linting with statix (opinionated lints)
        statix =
          pkgs.runCommand "statix-check"
            {
              buildInputs = [ pkgs.statix ];
              preferLocalBuild = true;
              allowSubstitutes = false;
            }
            ''
              cd ${./.}/..
              statix check . --config ${./statix.toml} || statix check .
              touch $out
            '';

        # Dead code detection with deadnix
        deadnix =
          pkgs.runCommand "deadnix-check"
            {
              buildInputs = [ pkgs.deadnix ];
              preferLocalBuild = true;
              allowSubstitutes = false;
            }
            ''
              cd ${./.}/..
              deadnix --fail . --exclude flake.nix
              touch $out
            '';

        # Performance-optimized formatting check
        format =
          pkgs.runCommand "format-check"
            {
              buildInputs = [ config.treefmt.build.wrapper ];
              preferLocalBuild = true;
              allowSubstitutes = false;
            }
            ''
              cd ${./.}/..
              treefmt --fail-on-change
              touch $out
            '';
      };

      treefmt = {
        projectRootFile = "flake.nix";

        # Optimize formatter settings for performance
        settings = {
          global.excludes = [
            "*.lock"
            "*.patch"
            "result*"
            ".git/**"
            ".github/agents/**"
          ];
        };

        programs = {
          # Nix formatting with optimizations
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt-rfc-style; # Use RFC style explicitly
          };

          # Markdown formatting with performance settings
          prettier = {
            enable = true;
            includes = [
              "*.md"
              "*.json"
              "*.yml"
              "*.yaml"
            ];
            excludes = [
              "flake.lock"
              "*.patch"
              ".github/workflows/*.yml" # Preserve exact formatting for actions
            ];
            settings = {
              # Optimize for consistent formatting
              printWidth = 100;
              tabWidth = 2;
              useTabs = false;
              semi = true;
              singleQuote = false;
              quoteProps = "as-needed";
              trailingComma = "es5";
            };
          };

          # Shell script formatting
          shfmt = {
            enable = true;
            indent_size = 2;
          };
        };
      };
    };
}
