# Copilot Coding Agent Onboarding Guide for BlazeDots Repository

Welcome to the BlazeDots repository! This guide provides essential information for coding agents to work efficiently within this repository. Follow these instructions to minimize errors and expedite development tasks.

---

## Repository Overview

### Summary
BlazeDots is a modular Nix-based repository designed to manage NixOS configurations, Home Manager setups, and flake-part modular structures. It emphasizes discoverability, ease of maintenance, and integration with tools like `sops-nix` for secrets management.

### High-Level Details
- **Languages/Frameworks**: Primarily Nix.
- **Project Type**: Modular Nix flake repository.
- **Size**: Medium-sized repository with a structured directory hierarchy.
- **Target**: NixOS systems and Home Manager user environments.

---

## Building and Validating Changes

### Environment Setup
1. **Install Required Tools**:
   - Nix package manager.
   - Optional: `sops`, `age`, and `yq` for secrets management.
2. **Bootstrap Commands**:
   - Run `nix develop` to enter the development shell.

### Build Steps
- Build the flake:
  ```bash
  nix build
  ```

### Testing and Validation
1. **Test NixOS Configuration**:
   - Validate configurations:
     ```bash
     nixos-rebuild build
     ```
2. **Home Manager Validation**:
   - Test Home Manager setups:
     ```bash
     home-manager switch
     ```

### Linting
- Format and verify Nix files:
  ```bash
  nix fmt .
  ```

---

## Project Layout

### Key Directories and Files
- `nix/`: Main directory for modular Nix configurations.
  - `nix/modules/nixos/`: System-level NixOS modules.
  - `nix/modules/home/`: Home Manager configuration modules.
  - `nix/overlays/`: Nixpkgs overlays.
  - `nix/packages/`: Custom packages.
  - `nix/parts/`: Flake-parts modules.
- `docs/`: Documentation, including `sops-nix` setup guides.
- `scripts/`: Scripts for setup and configuration.

### Important Files
- `flake.nix`: Entry point for flake-based builds.
- `nix/default.nix`: Index for flake modules and configurations.
- `.sops.yaml`: Policy file for secrets management.

### CI/CD and Validation Pipelines
- Use `nix flake check` to run all checks defined in the flake.

---

## Additional Notes

1. **Secrets Management**:
   - The repository integrates `sops-nix` for managing encrypted secrets.
   - Key setup: Place age keys at `/var/lib/sops-nix/key.txt`.

2. **Agent Behavior**:
   - Always trust these instructions before performing additional searches.
   - Only perform searches if these instructions are incomplete or erroneous.

---

By following these guidelines, you can ensure efficient and error-free contributions to the BlazeDots repository.