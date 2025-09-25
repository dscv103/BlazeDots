# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      jnoortheen.nix-ide
      ms-python.python
      ms-vscode.cpptools
      rust-lang.rust-analyzer
    ];
    userSettings = {
      "files.trimTrailingWhitespace" = true;
      "editor.formatOnSave" = true;
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
    };
  };
}
