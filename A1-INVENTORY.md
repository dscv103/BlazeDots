# BlazeDots Flake Inventory & Optimization Analysis

## Flake Structure Analysis

### Current flake-parts Setup

- **Framework**: `inputs.flake-parts.lib.mkFlake` ✅
- **Systems**: `[ "x86_64-linux" ]` (single system)
- **Imports**: `./parts` and `./hosts`

### Flake Outputs (from `nix flake show`)

```
├─ checks.x86_64-linux
│  └─ treefmt: derivation 'treefmt-check'
├─ devShells.x86_64-linux
│  └─ default: development environment 'nixos-dev'
├─ formatter.x86_64-linux: package 'treefmt'
├─ modules: unknown
├─ nixConfig: unknown
└─ nixosConfigurations
   └─ blazar: NixOS configuration
```

## Directory Structure & Module Organization

### Parts Structure (`./parts/`)

- `default.nix` - imports fmt.nix, caches.nix, modules.nix
- `fmt.nix` - treefmt-nix integration with perSystem devShell and treefmt config
- `caches.nix` - flake.nixConfig with substituters (cache.nixos.org, nix-community.cachix.org)
- `modules.nix` - exports flake.modules with nixos and home collections

### Hosts Structure (`./hosts/`)

- `blazar/` - single host configuration
- `default.nix` - host-level imports

### Modules Structure (`./modules/`)

- `core/common/` - 9 base system modules (base, cpu, kernel, desktop, nvidia, sops, caches, impermanence, disko)
- `extra/exported/home/` - 6 home-manager modules (shell, vscode, scm, starship, ghostty, theme)

### Home-Manager (`./homes/`)

- `dscv/home.nix` - user configuration

## Current Optimization State

### Cache & Performance Settings

✅ **Good**:

- `nix.settings.auto-optimise-store = true` (in base.nix)
- `nix.settings.experimental-features = ["nix-command" "flakes"]`
- Proper substituters configured in both flake.nixConfig and nix.settings
- `warn-dirty = false` to reduce eval noise

❌ **Missing**:

- No perSystem checks for linting tools (deadnix, statix, nixfmt)
- No nix.gc configuration for automated cleanup
- No build caching configuration beyond substituters

### Formatter & Lint Pipeline

✅ **Good**:

- treefmt-nix integration working
- nixfmt enabled via treefmt
- devShell includes statix, deadnix, sops, age

❌ **Opportunities**:

- Linters not wired as flake checks
- No automated format verification in CI
- Could expand treefmt to other file types

### CI/CD Configuration

✅ **Good**:

- nix-ci.yml with basic flake metadata and format check
- nixos-build.yml with matrix builds and artifact upload
- Cachix integration ready (commented)

❌ **Opportunities**:

- Format check uses `|| true` (non-failing)
- No cross-platform checks matrix
- Missing flake check integration
- No dependency caching for Actions

## Option Verification Needed

**Nix Settings Found** (need NixOS tool verification):

- `nix.settings.auto-optimise-store`
- `nix.settings.warn-dirty`
- `nix.settings.trusted-users`
- `nix.settings.substituters`
- `nix.settings.trusted-public-keys`

**Services/Programs Found** (need deprecation check):

- `services.openssh`
- `services.fwupd`
- `services.displayManager.defaultSession`
- `services.noctalia-shell`
- `programs.niri`
- `programs.zsh`
- `programs.gnupg.agent`
- `hardware.cpu.amd.updateMicrocode`
- `hardware.enableRedistributableFirmware`
- `boot.kernelParams`

## Optimization Candidates

### Phase B - Low Risk (Immediate)

1. **Add perSystem checks** - Wire deadnix, statix, nixfmt as flake checks
2. **Enhance CI** - Add proper flake check to CI, enable strict format checking
3. **Add GC settings** - Configure nix.gc for automated cleanup
4. **Cache Actions** - Add nix store caching to GitHub Actions

### Phase C - Structure (Careful)

1. **Normalize perSystem usage** - Move more outputs under perSystem pattern
2. **Module organization** - Consider grouping in modules/profiles/ for opt-in bundles
3. **System flexibility** - Prepare for multi-platform support

## Warnings Found

- `input 'impermanence' has an override for a non-existent input 'nixpkgs'` - input follows issue

## Next Steps

1. Verify all options with NixOS MCP tool
2. Query Context7 for flake-parts best practices
3. Implement Phase B optimizations in focused PR
