# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ lib, ... }:
let
  palette = {
    base = "#1e1e2e";
    text = "#cdd6f4";
    cursor = "#cba6f7";
    selection = "#45475a";
    selection_text = "#cdd6f4";
    black = "#45475a";
    red = "#f38ba8";
    green = "#a6e3a1";
    yellow = "#f9e2af";
    blue = "#89b4fa";
    magenta = "#cba6f7";
    cyan = "#94e2d5";
    white = "#bac2de";
    bright_black = "#585b70";
    bright_red = "#f38ba8";
    bright_green = "#a6e3a1";
    bright_yellow = "#f9e2af";
    bright_blue = "#89b4fa";
    bright_magenta = "#cba6f7";
    bright_cyan = "#94e2d5";
    bright_white = "#cdd6f4";
  };

  renderPalette =
    colors:
    lib.concatStringsSep "\n" (
      lib.imap1 (idx: color: "palette = ${toString (idx - 1)}:${color}") colors
    );

  paletteList = [
    palette.black
    palette.red
    palette.green
    palette.yellow
    palette.blue
    palette.magenta
    palette.cyan
    palette.white
    palette.bright_black
    palette.bright_red
    palette.bright_green
    palette.bright_yellow
    palette.bright_blue
    palette.bright_magenta
    palette.bright_cyan
    palette.bright_white
  ];

  ghosttyConfig = ''
    window-decoration = false
    background = ${palette.base}
    foreground = ${palette.text}
    cursor-color = ${palette.cursor}
    selection-background = ${palette.selection}
    selection-foreground = ${palette.selection_text}
    font-family = "JetBrainsMono Nerd Font"
    font-size = 12
    line-height = 1.1
    padding-x = 10
    padding-y = 10
    cursor-style = beam
    ${renderPalette paletteList}
  '';

in
{
  xdg.configFile."ghostty/config".text = ghosttyConfig;
}
