# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ lib, pkgs, ... }:
{
  services = {
    xserver.enable = false;

    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };

  programs.niri.enable = true;

  environment.systemPackages = lib.mkAfter (
    with pkgs;
    [
      foot
      grim
      slurp
      swaybg
      wl-clipboard
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ]
  );

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    jetbrains-mono
  ];

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };

  security.polkit.enable = true;
}
