# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { pkgs, config, lib, ... }:
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

      # Add comprehensive checks for CI and local validation
      checks = {
        # Format check using treefmt
        formatting = treefmt.check config.treefmt.build.configFile;
        
        # Static analysis with statix
        statix-check = pkgs.runCommand "statix-check" { 
          buildInputs = [ pkgs.statix ]; 
        } ''
          cd ${inputs.self}
          statix check --format errfmt .
          touch $out
        '';
        
        # Dead code detection with deadnix
        deadnix-check = pkgs.runCommand "deadnix-check" { 
          buildInputs = [ pkgs.deadnix ]; 
        } ''
          cd ${inputs.self}
          deadnix --fail .
          touch $out
        '';
        
        # Flake validation
        flake-check = pkgs.runCommand "flake-check" { 
          buildInputs = [ pkgs.nixFlakes ]; 
        } ''
          cd ${inputs.self}
          nix flake check --no-build
          touch $out
        '';
      };

      treefmt = {
        projectRootFile = "flake.nix";
        programs.nixfmt = {
          enable = true;
          package = pkgs.nixfmt;
        };
        programs.statix = {
          enable = true;
        };
        programs.deadnix = {
          enable = true;
        };
      };
    };
}
