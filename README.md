# @managed-by: nixos-config-generator
# Do not edit without understanding overwrite policy.
# BlazeDots NixOS Configuration

This repository contains a flake-parts based NixOS configuration for the host **blazar** with Home Manager integration. The layout keeps reusable modules under `modules/` and exposes them via `flake.modules` so they can be pulled into other flakes if desired.

## Structure Highlights
- `flake.nix` wires flake-parts, imports `./parts` and `./hosts`, and renders `nixosConfigurations.blazar`.
- `parts/` modules supply developer tooling, binary cache settings, and module exports.
- `modules/core/common/` holds system modules (base, CPU, kernel, desktop, NVIDIA, SOPS, impermanence, disko shim).
- `modules/extra/exported/home/` exports shared Home Manager modules (shell, VS Code, SCM, Starship).
- `hosts/blazar/` contains the host profile, hardware stub, and Disko layout scaffold.
- `homes/dscv/home.nix` assembles the exported Home Manager modules for the `dscv` user.

## Hash Placeholders
Whenever you introduce a new remote source, replace any `lib.fakeSha256` with the real hash:
```bash
nix store prefetch-file "<URL>" --json | jq -r '.hash'
```

## Formatting & CI
Use `nix fmt` (via `nix fmt` or `nix fmt .`) to format files. CI is provided under `.github/workflows/nix-ci.yml` to lint the flake on push using the stable channel.

## Validation Workflow
After editing modules:
```bash
nix fmt || true
nix flake metadata
nix eval .#nixosConfigurations."blazar".config.system.build.toplevel.drvPath
```

## Smoke Build
To ensure the system builds without switching:
```bash
sudo nixos-rebuild build --flake .#"blazar"
```

## Hardware Stub
Replace the placeholder hardware configuration before deploying:
```bash
sudo nixos-generate-config --show-hardware-config > hosts/blazar/hardware-configuration.nix
git add hosts/blazar/hardware-configuration.nix
```

## Disko Warning
Disko files are **scaffold-only**. Running Disko against the wrong device is destructive; it repartitions disks and creates fresh filesystems. Review and adjust `hosts/blazar/modules/disko.nix` before using it.

## Impermanence Notes
The system mounts the `@persist` Btrfs subvolume at `/persist` and keeps critical state (logs, SSH keys, NetworkManager profiles) across reboots. Home Manager stores user-level persist data under the same mount.

## Niri + NVIDIA Caveats
Ensure Wayland sessions run with DRM KMS enabled:
```nix
hardware.nvidia.modesetting.enable = true;
services.displayManager.sddm.wayland.enable = true;
boot.kernelParams = [ "nvidia-drm.modeset=1" ];
```
Expect compositor glitches on proprietary drivers; keep firmware and drivers up to date.

## Hash Acquisition Reminder
Any time you add external archives or binary cache sources, compute hashes with `nix store prefetch-file` as shown above before committing changes.
