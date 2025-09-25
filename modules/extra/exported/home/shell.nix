# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -alF";
      gs = "git status";
      v = "nvim";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    eza
    fd
    bat
    ripgrep
    jq
    nil
  ];
}
