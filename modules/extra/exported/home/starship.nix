# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
_: {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$all";
      git_status.disabled = false;
      battery.disabled = true;
      command_timeout = 1000;
    };
  };
}
