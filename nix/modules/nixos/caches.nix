# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
{ lib, ... }:
{
 nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      # cache.nixos.org
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16EGsB+7Ra0/Rdk8="
      # nix-community.cachix.org
      "nix-community.cachix.org-1:mNR2m8n0U6L0tJcHkJik4C59gz1+9a089/MefZP4V8g="
    ];
  };  
}
