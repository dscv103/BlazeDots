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

## Developer Environment

Follow these steps to activate the project shell defined in `devenv.nix`.

1. Install the prerequisites (once per machine):
   ```bash
   nix profile install nixpkgs#direnv
   nix profile install github:cachix/devenv/latest
   ```
   Add `eval "$(direnv hook bash)"` (or `... zsh`) to your shell rc if you have not already.
2. Create an `.envrc` in the repository root with the single line `use devenv` and allow it:
   ```bash
   echo 'use devenv' > .envrc
   direnv allow
   ```
   Direnv now auto-loads the shell whenever you enter the directory.
3. To launch manually without Direnv, run `devenv shell` from the repo root.
4. Verify the bundled tooling the first time you enter the shell:
   ```bash
   sapling --version
   ruff --version
   pytest --version
   bandit --version
   pyrefly --help | head -n 1
   ```
   The environment also exposes Rust (stable toolchain with rustfmt and clippy), Zig, Node.js 20 with npm, Nix with flakes enabled, and the VS Code extensions listed in `devenv.nix`.

## Installation Runbook

### Pre-installation Checklist
- Download the latest x86_64 NixOS installer ISO and write it to a USB drive or other boot medium.
- Back up any data on the target disk before proceeding; the Disko profile at `hosts/blazar/modules/disko.nix` will repartition `disk.main.device` (defaults to `/dev/nvme0n1`).
- Review `hosts/blazar/modules/disko.nix` and adjust the `device`, partition sizes, or subvolume list so it matches the hardware you intend to install on.
- Decide on a strong LUKS passphrase—the root Btrfs volume is wrapped in LUKS2 and the installer will prompt twice when provisioning.
- Ensure you can reach the network from the installer environment (wired is automatic; for Wi-Fi you will need the SSID and password for `nmtui`/`nmcli`).
- If you rely on SOPS-encrypted secrets, have the AGE private key available so you can place it at `/var/lib/sops-nix/key.txt` during the installation.

### During Installation
1. Boot the NixOS installer, log in as `root`, and enable Git in the live environment: `nix-shell -p git`.
2. Clone this repository into the live environment (for example `git clone <repo-url> /tmp/BlazeDots`) and review any host-specific adjustments you need.
3. Enable Flakes with `export NIX_CONFIG="experimental-features = nix-command flakes"`.
4. Provision and mount the target disk using the Disko profile (this is destructive): `nix run github:nix-community/disko -- --mode disko /tmp/BlazeDots/hosts/blazar/modules/disko.nix`. Disko will prompt for the new LUKS2 passphrase and confirmation—store it securely.
5. Verify that `/mnt` now contains the mounted subvolumes (`@root`, `@home`, `@nix`, `@persist`, `@swap`). If not, mount them manually before continuing.
6. Move the repository into the target system so `nixos-install` can see the flake: `mkdir -p /mnt/etc && mv /tmp/BlazeDots /mnt/etc/nixos` and `cd /mnt/etc/nixos`.
7. Generate a hardware profile tied to the freshly provisioned system (it will include `boot.initrd.luks.devices.cryptroot` for the encrypted root volume): `nixos-generate-config --root /mnt --show-hardware-config > hosts/blazar/hardware-configuration.nix`.
8. Deceide if Disko or Hardware-Configuration will manage the filesystem, swap, and cyrptroot.
9. If you use SOPS secrets, place the AGE key inside the target root: `install -Dvm600 <path-to-key> /mnt/var/lib/sops-nix/key.txt`.
10. Install the system: `nixos-install --flake .#blazar` (set the root password when prompted).
11. Create a password for the normal user defined in `modules/core/common/base.nix`: `passwd dscv` (run inside `nixos-enter --root /mnt` if you exited the chroot).

### Post-installation Tasks
- Reboot into the new system (`reboot`) and remove the installation media when prompted.
- Log in as `dscv`, run `sudo nixos-rebuild switch --flake /etc/nixos#blazar`, and confirm the generation completes without errors.
- Restore SOPS material if required (e.g., re-copy the AGE key to `/var/lib/sops-nix/key.txt` once the system is up).
- Verify the LUKS unlock prompt appears at boot and accepts the passphrase before enabling automatic rebuilds.
- Verify networking, GPU, and Wayland session start-up, then review `journalctl -b` for boot-time warnings.
- Commit the generated `hosts/blazar/hardware-configuration.nix` (and any Disko edits) back to version control so future rebuilds use the correct hardware definition.

## SOPS-nix Setup

Follow the step-by-step guide in [`docs/sops-nix-setup.md`](docs/sops-nix-setup.md) to generate keys, define `.sops.yaml`,
encrypt secrets, and integrate them with the existing `blazar` host configuration.

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
Disko files are **scaffold-only**. Running Disko against the wrong device is destructive; it repartitions disks, (re-)creates the LUKS2 container, and lays down fresh filesystems. Review and adjust `hosts/blazar/modules/disko.nix` before using it.

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
