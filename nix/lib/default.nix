# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
#
# Shared library functions for BlazeDots flake
{ lib, ... }:

{
  # Small helper functions shared across flake parts

  # Example: mkEnable option with description
  mkEnableOption = name: lib.mkEnableOption name;

  # Example: mkOption with type and description
  mkStrOption = default: description: lib.mkOption {
    type = lib.types.str;
    inherit default description;
  };

  # Add more shared utilities as needed
}
