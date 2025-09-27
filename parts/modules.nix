# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ self, ... }:
{
  flake.modules = {
    nixos = {
      base = import (self + "/modules/core/common/base.nix");
      cpu = import (self + "/modules/core/common/cpu.nix");
      kernel = import (self + "/modules/core/common/kernel.nix");
      desktop = import (self + "/modules/core/common/desktop.nix");
      nvidia = import (self + "/modules/core/common/nvidia.nix");
      sops = import (self + "/modules/core/common/sops.nix");
      caches = import (self + "/modules/core/common/caches.nix");
      impermanence = import (self + "/modules/core/common/impermanence.nix");
      disko = import (self + "/modules/core/common/disko.nix");
    };
    home = {
      shell = import (self + "/modules/extra/exported/home/shell.nix");
      vscode = import (self + "/modules/extra/exported/home/vscode.nix");
      scm = import (self + "/modules/extra/exported/home/scm.nix");
      starship = import (self + "/modules/extra/exported/home/starship.nix");
      ghostty = import (self + "/modules/extra/exported/home/ghostty.nix");
      theme = import (self + "/modules/extra/exported/home/theme.nix");
    };
  };
}
