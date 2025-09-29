{ pkgs, lib, ... }:
{
  name = "blazedots";

  # Direnv integration is handled externally via nix-direnv (`use flake . --no-pure-eval`)
  # so no devenv-specific direnv options are defined here. This keeps the module
  # compatible with devenv v1.9+, which dropped the `direnv` attribute.

  packages = [
    pkgs.git
    pkgs.jq
    pkgs.fd
    pkgs.ripgrep
    pkgs.nil
    pkgs.sapling
    pkgs.pyrefly
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

    rust = {
      enable = true;
      channel = "stable";
      rustfmt.enable = true;
      clippy.enable = true;
    };

    zig.enable = true;

    nix = {
      enable = true;
      package = pkgs.nix;
      formatter = pkgs.nixpkgs-fmt;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

    javascript = {
      enable = true;
      package = pkgs.nodejs_20;
      npm.enable = true;
    };
  };

  vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
      rust-lang.rust-analyzer
      ziglang.vscode-zig
      jnoortheen.nix-ide
      dbaeumer.vscode-eslint
      esbenp.prettier-vscode
    ];
    settings = {
      "python.defaultInterpreterPath" = "${pkgs.python312}/bin/python3";
      "zig.zls.path" = "${pkgs.zls}/bin/zls";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
    };
  };

  enterShell = ''
    echo "BlazeDots development shell (Python/Rust/Zig/Nix/Node.js)"
  '';
}
