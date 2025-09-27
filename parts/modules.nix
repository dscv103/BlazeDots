# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ self, ... }:
{
  flake.modules = {
    nixos = {
      base = import (self + "/modules/nixos/base.nix");
      cpu = import (self + "/modules/nixos/cpu.nix");
      kernel = import (self + "/modules/nixos/kernel.nix");
      desktop = import (self + "/modules/nixos/desktop.nix");
      nvidia = import (self + "/modules/nixos/nvidia.nix");
      sops = import (self + "/modules/nixos/sops.nix");
      caches = import (self + "/modules/nixos/caches.nix");
      impermanence = import (self + "/modules/nixos/impermanence.nix");
      disko = import (self + "/modules/nixos/disko.nix");
    };
    home = {
      shell = import (self + "/modules/home/shell.nix");
      vscode = import (self + "/modules/home/vscode.nix");
      scm = import (self + "/modules/home/scm.nix");
      starship = import (self + "/modules/home/starship.nix");
      ghostty = import (self + "/modules/home/ghostty.nix");
      theme = import (self + "/modules/home/theme.nix");
    };
  };
}
