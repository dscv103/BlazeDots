{ pkgs, lib, ... }:
{
  name = "blazedots";

  # Fix for flake usage
  devcontainer.enable = lib.mkDefault false;

  packages = [
    pkgs.git
    pkgs.jq
    pkgs.fd
    pkgs.ripgrep
    pkgs.nil
    pkgs.sapling
    pkgs.pyrefly
    pkgs.direnv
    pkgs.nix-direnv
    pkgs.nixpkgs-fmt
    pkgs.rustfmt
    pkgs.clippy
  ]
  ++ (with pkgs.python312Packages; [
    ruff
    pytest
    bandit
  ]);

  env = {
    RUST_LOG = lib.mkDefault "info";
  };

  languages = {
    python = {
      enable = true;
      package = pkgs.python312;
      uv.enable = true;
    };

    zig.enable = true;

    nix.enable = true;

    javascript = {
      enable = true;
      package = pkgs.nodejs_20;
      npm.enable = true;
    };
  };

  enterShell = ''
    echo "BlazeDots development shell (Python/Rust/Zig/Nix/Node.js)"
    echo "Available tools: direnv, nix-direnv, nixpkgs-fmt, rustfmt, clippy"
  '';
}
