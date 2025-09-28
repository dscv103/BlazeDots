# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ lib, pkgs, ... }:
let
  # Copy-once starter settings; VS Code can edit afterwards.
  vscodeStarter = pkgs.writeText "vscode-settings.json" (builtins.toJSON {
    "files.trimTrailingWhitespace" = true;
    "editor.formatOnSave" = true;
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "nil";

    # Optional niceties
    "editor.tabSize" = 2;
    "files.insertFinalNewline" = true;
    "editor.rulers" = [ 100 ];
    "editor.codeActionsOnSave" = { "source.organizeImports" = "explicit"; };
  });
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    # Correct attr name (plural)
    mutableExtensionsDir = true;

    # These live under the profile in recent HM
    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        jnoortheen.nix-ide
        ms-python.python
        ms-vscode.cpptools
        rust-lang.rust-analyzer
      ];
    };
  };

  # Provide the Nix LSP referenced in settings
  home.packages = [ pkgs.nil ];

  # Seed ~/.config/Code/User/settings.json once (then let Code own it)
  home.activation.seedCodeSettings =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      target="$HOME/.config/Code/User/settings.json"
      if [ ! -e "$target" ]; then
        mkdir -p "$(dirname "$target")"
        cp ${vscodeStarter} "$target"
        echo "Seeded VS Code settings.json"
      fi
    '';
}

