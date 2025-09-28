# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -alF";
      gs = "git status";
      v = "nvim";

      # quick "up" aliases
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";

      # handy jumps
      "-" = "cd -";
      "~" = "cd ~";
      pd = "pushd";
      po = "popd";
    };

    # put functions here (needs escaping of ${...})
    initContent = ''
      up() {
        local n=''${1:-1}
        (( n >= 1 )) || { echo "usage: up [levels>=1]"; return 1; }
        local p=""
        for ((i=0; i<n; i++)); do p+="../"; done
        cd "$p"
      }
      # completion like `cd`
      compdef _cd up
    '';
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
