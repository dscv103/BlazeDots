# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{
  lib,
  gitName ? "dscv103",
  gitEmail ? "dvitrano@me.com",
  gitUseSshSigning ? true,
  ...
}:
{
  programs = {
    git = {
      enable = true;
      userName = gitName;
      userEmail = gitEmail;
      signing = lib.mkIf gitUseSshSigning {
        key = "~/.ssh/id_ed25519.pub";
        signByDefault = true;
      };
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
      }
      // lib.optionalAttrs gitUseSshSigning {
        gpg.format = "ssh";
        user.signingkey = "ssh-ed25519 ~/.ssh/id_ed25519.pub";
      };
    };

    gh = {
      enable = true;
      settings.git_protocol = "ssh";
      extensions = [ ];
    };

    sapling = {
      enable = true;
      userName = gitName;
      userEmail = gitEmail;
    };
  };
}
