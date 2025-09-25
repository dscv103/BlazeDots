# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{
  inputs,
  pkgs,
  username ? "dscv",
  gitUseSshSigning ? true,
  ...
}:
let
  homeModules = inputs.self + "/modules/extra/exported/home";
in
{
  imports = [
    (homeModules + "/shell.nix")
    (homeModules + "/vscode.nix")
    (homeModules + "/scm.nix")
    (homeModules + "/starship.nix")
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.05";
    sessionPath = [ "$HOME/.local/bin" ];
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    LANG = "en_US.UTF-8";
  };

  xdg.configFile."niri/config.kdl".text = ''
    enable = true
    # Example niri config. Adjust workspaces and keybinds as needed.
    layout {
      default-column-width = 120
    }
    binds {
      Mod+Return = spawn "foot"
      Mod+Q = close-window
      Mod+Shift+Q = quit
      Mod+D = spawn "wofi --show drun"
      Mod+Shift+F = fullscreen
      Mod+J = focus-down
      Mod+K = focus-up
      Mod+H = focus-left
      Mod+L = focus-right
    }
  '';

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = gitUseSshSigning;
  };

  home.packages = with pkgs; [
    wofi
    wl-clipboard
    cliphist
  ];
}
