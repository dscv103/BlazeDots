# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ pkgs, lib, ... }:
let
  palette = {
    base = "#1e1e2e";
    mantle = "#181825";
    crust = "#11111b";
    text = "#cdd6f4";
    subtext0 = "#a6adc8";
    subtext1 = "#bac2de";
    surface0 = "#313244";
    surface1 = "#45475a";
    surface2 = "#585b70";
    overlay0 = "#6c7086";
    overlay1 = "#7f849c";
    overlay2 = "#9399b2";
    blue = "#89b4fa";
    lavender = "#b4befe";
    sapphire = "#74c7ec";
    sky = "#89dceb";
    teal = "#94e2d5";
    green = "#a6e3a1";
    yellow = "#f9e2af";
    peach = "#fab387";
    maroon = "#eba0ac";
    red = "#f38ba8";
    mauve = "#cba6f7";
    pink = "#f5c2e7";
    flamingo = "#f2cdcd";
    rosewater = "#f5e0dc";
  };

  catppuccinName = "catppuccin-mocha-mauve";

  catppuccinKvantum = pkgs.catppuccin-kvantum.override {
    variant = "mocha";
    accent = "mauve";
  };

  catppuccinGtk = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "mauve" ];
    size = "compact";
  };

  wallpaperImage = pkgs.runCommand "catppuccin-mocha-wallpaper" {
    nativeBuildInputs = [ pkgs.imagemagick ];
  } ''
    mkdir -p $out
    convert -size 5120x2880 gradient:${palette.base}-${palette.mauve} $out/catppuccin-mocha.png
  '';

  rofiTheme = ''
* {
    background:     ${palette.crust}ff;
    background-alt: ${palette.mantle}ff;
    foreground:     ${palette.text}ff;
    selected:       ${palette.blue}ff;
    active:         ${palette.green}ff;
    urgent:         ${palette.red}ff;
}
'';

  rofiConfig = ''configuration {
    theme: "~/.config/rofi/themes/catppuccin.rasi";
    modi: "drun,run,window";
    show-icons: true;
    display-drun: "Apps";
    display-run: "Run";
    display-window: "Windows";
}
'';

  wofiStyle = ''
window {
  border-radius: 16px;
  border: 2px solid ${palette.lavender};
  background-color: ${palette.base};
  color: ${palette.text};
}

#input {
  margin: 16px;
  padding: 12px;
  border-radius: 12px;
  border: 1px solid ${palette.surface2};
  background-color: ${palette.surface0};
  color: ${palette.text};
}

#inner-box {
  margin: 8px 16px 16px 16px;
}

#entry {
  padding: 10px 14px;
  border-radius: 10px;
  background-color: transparent;
  color: ${palette.subtext1};
}

#entry:selected {
  background-color: ${palette.surface1};
  color: ${palette.text};
  border: 1px solid ${palette.mauve};
}

#text {
  font-family: "JetBrainsMono Nerd Font";
  font-size: 14px;
}
'';

  footColors = {
    background = palette.base;
    foreground = palette.text;
    regular0 = palette.surface1;
    regular1 = palette.red;
    regular2 = palette.green;
    regular3 = palette.yellow;
    regular4 = palette.blue;
    regular5 = palette.mauve;
    regular6 = palette.teal;
    regular7 = palette.subtext1;
    bright0 = palette.surface2;
    bright1 = palette.red;
    bright2 = palette.green;
    bright3 = palette.yellow;
    bright4 = palette.blue;
    bright5 = palette.mauve;
    bright6 = palette.teal;
    bright7 = palette.text;
  };
in
{
  home.sessionVariables = {
    GTK_THEME = "catppuccin-mocha-mauve-compact";
    QT_STYLE_OVERRIDE = "kvantum";
    XCURSOR_THEME = "Bibata-Modern-Classic";
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
  };

  gtk = {
    enable = true;
    theme = {
      name = "${catppuccinName}-compact";
      package = catppuccinGtk;
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
    gtk3.extraConfig."gtk-application-prefer-dark-theme" = "1";
    gtk4.extraConfig."gtk-application-prefer-dark-theme" = "1";
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "kvantum";
  };

  home.packages = lib.mkAfter [ catppuccinKvantum catppuccinGtk pkgs.papirus-icon-theme pkgs.bibata-cursors ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "${wallpaperImage}/catppuccin-mocha.png" ];
      wallpaper = [ ",${wallpaperImage}/catppuccin-mocha.png" ];
    };
  };

  programs = {
    foot = {
      enable = true;
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font:size=12";
          dpi-aware = "no";
          pad = "10x10";
        };
        colors = footColors;
        cursor = {
          color = "${palette.base} ${palette.lavender}";
        };
      };
    };

    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      theme = "~/.config/rofi/themes/catppuccin.rasi";
      extraConfig = {
        show-icons = true;
        modi = "drun,run,window";
        drun-use-desktop-cache = true;
        drun-match-fields = "name,generic,exec,categories";
      };
    };

    wofi = {
      enable = true;
      settings = {
        width = "520";
        height = "360";
        prompt = "";
        allow_markup = "true";
        allow_images = "true";
        columns = "1";
      };
      style = wofiStyle;
    };
  };

  xdg.configFile."rofi/themes/catppuccin.rasi".text = rofiTheme;
  xdg.configFile."rofi/config.rasi".text = rofiConfig;
  xdg.configFile."Kvantum/${catppuccinName}".source = "${catppuccinKvantum}/share/Kvantum/${catppuccinName}";
  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=${catppuccinName}
  '';
}
