# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  username = "dscv";
  userFullName = "dscv103";
  gitName = "dscv103";
  gitEmail = "dvitrano@me.com";
  gitUseSshSigning = true;
  timezone = "America/Chicago";
  locale = "en_US.UTF-8";
  keyboardLayout = "us";
  stateVersion = "24.05";
in
{
  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config.allowUnfree = true;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    warn-dirty = false;
    trusted-users = [
      "root"
      username
    ];
  };

  time.timeZone = timezone;

  i18n = {
    defaultLocale = locale;
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  console.keyMap = keyboardLayout;

  networking.hostName = "blazar";
  networking.networkmanager.enable = true;

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    fwupd.enable = true;
    printing.enable = lib.mkDefault false;
  };

  security = {
    sudo.wheelNeedsPassword = lib.mkDefault true;
  };

  hardware.enableRedistributableFirmware = true;

  environment = {
    shells = [
      pkgs.zsh
      pkgs.bashInteractive
    ];
    loginShellInit = ''
      export EDITOR="nvim"
    '';
    systemPackages = with pkgs; [
      btrfs-progs
      curl
      dig
      git
      gnupg
      htop
      neovim
      pciutils
      usbutils
      wget
    ];
  };

  programs = {
    zsh.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  users.users.${username} = {
    isNormalUser = true;
    description = userFullName;
    home = "/home/${username}";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    shell = pkgs.zsh;
  };

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${username} = import (inputs.self + "/homes/${username}/home.nix");
    extraSpecialArgs = {
      inherit
        gitName
        gitEmail
        gitUseSshSigning
        username
        inputs
        ;
    };
  };

  system.stateVersion = stateVersion;
}
