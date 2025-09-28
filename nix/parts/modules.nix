# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ self, ... }:
{
  flake.modules = {
    nixos = {
      base = import (self + "/nix/modules/nixos/base.nix");
      cpu = import (self + "/nix/modules/nixos/cpu.nix");
      kernel = import (self + "/nix/modules/nixos/kernel.nix");
      desktop = import (self + "/nix/modules/nixos/desktop.nix");
      nvidia = import (self + "/nix/modules/nixos/nvidia.nix");
      sops = import (self + "/nix/modules/nixos/sops.nix");
      caches = import (self + "/nix/modules/nixos/caches.nix");
      impermanence = import (self + "/nix/modules/nixos/impermanence.nix");
      disko = import (self + "/nix/modules/nixos/disko.nix");
    };
    home = {
      shell = import (self + "/nix/modules/home/shell.nix");
      vscode = import (self + "/nix/modules/home/vscode.nix");
      scm = import (self + "/nix/modules/home/scm.nix");
      starship = import (self + "/nix/modules/home/starship.nix");
      ghostty = import (self + "/nix/modules/home/ghostty.nix");
      theme = import (self + "/nix/modules/home/theme.nix");
    };
  };
}
