# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{
  inputs,
  pkgs,
  lib,
  username ? "dscv",
  gitUseSshSigning ? true,
  ...
}:
let
  homeModules = inputs.self + "/modules/extra/exported/home";
  palette = {
    base = "#1e1e2e";
    surface0 = "#313244";
    surface1 = "#45475a";
    overlay0 = "#6c7086";
    overlay1 = "#7f849c";
    text = "#cdd6f4";
    mauve = "#cba6f7";
    blue = "#89b4fa";
    red = "#f38ba8";
  };
in
{
  imports = [
    (homeModules + "/shell.nix")
    (homeModules + "/vscode.nix")
    (homeModules + "/scm.nix")
    (homeModules + "/starship.nix")
    (homeModules + "/ghostty.nix")
    (homeModules + "/theme.nix")
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
    # Catppuccin Mocha accents
    layout {
      default-column-width = 120
      gaps {
        inner = 12
        outer = 24
      }
    }

    border {
      width = 3
      active-color = "${palette.mauve}"
      inactive-color = "${palette.overlay1}"
    }

    background {
      color = "${palette.base}"
    }

    focus {
      new-window = "latest"
    }

    binds {
      Mod+Shift+Escape { show-hotkey-overlay; }

      // ─── Applications ───
      Mod+Return hotkey-overlay-title="Open Terminal: Ghostty" { spawn "ghostty"; }
      Mod+Ctrl+Return hotkey-overlay-title="Open App Launcher: QS" { spawn "qs" "ipc" "call" "globalIPC" "toggleLauncher"; }
      Mod+B hotkey-overlay-title="Open Browser: firefox" { spawn "firefox"; }
      Mod+Alt+L hotkey-overlay-title="Lock Screen: swaylock" { spawn "swaylock"; }
      Mod+E hotkey-overlay-title="File Manager: Nautilus" { spawn "nautilus"; }
      Mod+Shift+V hotkey-overlay-title="Open Editor: VS Code" { spawn "code"; }

      // ─── Window Movement and Focus ───
      Mod+Q { close-window; }
      Mod+Left { focus-column-left; }
      Mod+H { focus-column-left; }
      Mod+Right { focus-column-right; }
      Mod+L { focus-column-right; }
      Mod+Up { focus-window-up; }
      Mod+K { focus-window-up; }
      Mod+Down { focus-window-down; }
      Mod+J { focus-window-down; }

      Mod+Ctrl+Left { move-column-left; }
      Mod+Ctrl+H { move-column-left; }
      Mod+Ctrl+Right { move-column-right; }
      Mod+Ctrl+L { move-column-right; }
      Mod+Ctrl+Up { move-window-up; }
      Mod+Ctrl+K { move-window-up; }
      Mod+Ctrl+Down { move-window-down; }
      Mod+Ctrl+J { move-window-down; }

      Mod+Home { focus-column-first; }
      Mod+End { focus-column-last; }
      Mod+Ctrl+Home { move-column-to-first; }
      Mod+Ctrl+End { move-column-to-last; }

      Mod+Shift+Left { focus-monitor-left; }
      Mod+Shift+Right { focus-monitor-right; }
      Mod+Shift+Up { focus-monitor-up; }
      Mod+Shift+Down { focus-monitor-down; }

      Mod+Shift+Ctrl+Left { move-column-to-monitor-left; }
      Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
      Mod+Shift+Ctrl+Up { move-column-to-monitor-up; }
      Mod+Shift+Ctrl+Down { move-column-to-monitor-down; }

      // ─── Workspace Switching ───
      Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
      Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
      Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
      Mod+Ctrl+WheelScrollUp cooldown-ms=150 { move-column-to-workspace-up; }

      Mod+WheelScrollRight { focus-column-right; }
      Mod+WheelScrollLeft { focus-column-left; }
      Mod+Ctrl+WheelScrollRight { move-column-right; }
      Mod+Ctrl+WheelScrollLeft { move-column-left; }

      Mod+Shift+WheelScrollDown { focus-column-right; }
      Mod+Shift+WheelScrollUp { focus-column-left; }
      Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
      Mod+Ctrl+Shift+WheelScrollUp { move-column-left; }

      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }

      Mod+Ctrl+1 { move-column-to-workspace 1; }
      Mod+Ctrl+2 { move-column-to-workspace 2; }
      Mod+Ctrl+3 { move-column-to-workspace 3; }
      Mod+Ctrl+4 { move-column-to-workspace 4; }
      Mod+Ctrl+5 { move-column-to-workspace 5; }
      Mod+Ctrl+6 { move-column-to-workspace 6; }
      Mod+Ctrl+7 { move-column-to-workspace 7; }
      Mod+Ctrl+8 { move-column-to-workspace 8; }
      Mod+Ctrl+9 { move-column-to-workspace 9; }

      Mod+Tab { focus-workspace-previous; }

      // ─── Layout Controls ───
      Mod+Ctrl+F { expand-column-to-available-width; }
      Mod+C { center-column; }
      Mod+Ctrl+C { center-visible-columns; }
      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }
      Mod+Shift+Minus { set-window-height "-10%"; }
      Mod+Shift+Equal { set-window-height "+10%"; }

      // ─── Modes ───
      Mod+T { toggle-window-floating; }
      Mod+F { fullscreen-window; }
      Mod+W { toggle-column-tabbed-display; }

      // ─── Emergency Escape Key ───
      Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

      // ─── Exit / Power ───
      Mod+Shift+P { power-off-monitors; }
      Mod+O repeat=false { toggle-overview; }

      // ─── Maintenance ───
      Mod+Shift+U hotkey-overlay-title="Update NixOS" { spawn "bash" "-lc" "cd ~/Developer/BlazeDots && nix flake update && sudo nixos-rebuild switch --flake .#$(hostname)"; }
    }

    indicators {
      border {
        focused = "${palette.mauve}"
        idle = "${palette.overlay0}"
        urgent = "${palette.blue}"
      }
    }
  '';

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = gitUseSshSigning;
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    profiles.default = {
      id = 0;
      name = "default";
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.theme.content-theme" = 0;
        "browser.theme.toolbar-theme" = 0;
        "browser.uidensity" = 1;
      };
      userChrome = ''
        :root {
          --bd-base: ${palette.base};
          --bd-surface0: ${palette.surface0};
          --bd-surface1: ${palette.surface1};
          --bd-mauve: ${palette.mauve};
          --bd-text: ${palette.text};
        }

        #navigator-toolbox,
        #nav-bar,
        #TabsToolbar,
        #PersonalToolbar {
          background-color: var(--bd-surface0) !important;
          color: var(--bd-text) !important;
        }

        .tab-background[selected="true"] {
          background-color: var(--bd-surface1) !important;
          border-bottom: 2px solid var(--bd-mauve) !important;
        }

        .tab-label[selected="true"] {
          color: var(--bd-text) !important;
        }

        .tab-background {
          background-color: var(--bd-base) !important;
        }

        #urlbar {
          background-color: var(--bd-surface1) !important;
          color: var(--bd-text) !important;
        }

        #urlbar-background {
          background-color: transparent !important;
          border: 1px solid var(--bd-mauve) !important;
        }

        #urlbar-input,
        #urlbar-input::-moz-placeholder {
          color: var(--bd-text) !important;
        }

        toolbarbutton {
          color: var(--bd-text) !important;
        }

        toolbarbutton:hover {
          background-color: var(--bd-surface1) !important;
        }
      '';
      userContent = ''
        @-moz-document url("about:home"), url("about:newtab") {
          body {
            background-color: ${palette.base} !important;
            color: ${palette.text} !important;
          }

          .search-wrapper .logo-and-wordmark .wordmark {
            fill: ${palette.text} !important;
          }

          .top-sites-list .top-site-outer .tile {
            background: ${palette.surface0} !important;
            color: ${palette.text} !important;
          }
        }
      '';
    };
  };

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      "indicator" = true;
      "indicator-radius" = 140;
      "indicator-thickness" = 12;
      "line-uses-ring" = true;
      "screenshots" = true;
      "effect-blur" = "7x5";
      "fade-in" = "0.2";
      "color" = lib.removePrefix "#" palette.base;
      "inside-color" = lib.removePrefix "#" palette.surface0;
      "ring-color" = lib.removePrefix "#" palette.mauve;
      "separator-color" = "00000000";
      "text-color" = lib.removePrefix "#" palette.text;
      "key-hl-color" = lib.removePrefix "#" palette.blue;
      "bs-hl-color" = lib.removePrefix "#" palette.red;
      "grace" = 3;
      "font" = "JetBrainsMono Nerd Font";
      "clock" = true;
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    gtk-theme = "catppuccin-mocha-mauve-compact";
    icon-theme = "Papirus-Dark";
    cursor-theme = "Bibata-Modern-Classic";
  };

  dconf.settings."org/gnome/nautilus/preferences" = {
    default-folder-viewer = "list-view";
    show-hidden-files = true;
  };

  home.packages = lib.mkAfter (
    with pkgs;
    [
      ghostty
      firefox
      nautilus
      wl-clipboard
      cliphist
    ]
  );
}
