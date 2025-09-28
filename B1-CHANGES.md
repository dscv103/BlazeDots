# BlazeDots Low-Risk Optimizations - Phase B

## Changes Made

### 1. Enhanced perSystem Checks (`parts/fmt.nix`)

**What**: Added proper flake checks for linting and static analysis

- Added `statix` check for Nix code linting
- Added `deadnix` check for dead code detection
- Extended treefmt to include Markdown/JSON/YAML formatting

**Why**:

- Provides automated code quality validation via `nix flake check`
- Catches potential issues before they reach production
- Standardizes formatting across all file types in repo

**Impact**:

- ✅ Better code quality enforcement
- ✅ Automated CI validation
- ✅ Consistent formatting across languages

**Rollback**: Remove the `checks` section and extra treefmt programs

### 2. Automated Garbage Collection (`modules/core/common/base.nix`)

**What**: Added nix.gc configuration for automated cleanup

```nix
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 14d";
};
```

**Why**:

- Prevents disk space issues on development/build systems
- Automatically cleans up old generations and store paths
- Reduces manual maintenance overhead

**Impact**:

- ✅ Automated disk space management
- ✅ Keeps system performant over time
- ⚠️ May increase rebuild times if commonly used derivations are collected

**Rollback**: Remove the `nix.gc` section

### 3. Enhanced CI Pipeline (`.github/workflows/nix-ci.yml`)

**What**: Improved CI with proper checks, caching, and strict formatting

- Added Nix store caching for faster builds
- Replaced `nix fmt || true` with strict formatting check
- Added comprehensive `nix flake check` validation

**Why**:

- Reduces CI build times through intelligent caching
- Prevents unformatted code from being merged
- Validates all checks (linting, formatting, builds) in CI

**Impact**:

- ✅ Faster CI builds (cache hit rate dependent)
- ✅ Strict formatting enforcement
- ✅ Comprehensive validation before merge

**Rollback**: Revert to original nix-ci.yml with `|| true` format check

### 4. Fixed Input Configuration (`flake.nix`)

**What**: Removed problematic nixpkgs follow for impermanence input
**Why**: The impermanence flake doesn't export a nixpkgs input, causing warning
**Impact**: ✅ Cleaner flake evaluation without warnings
**Rollback**: Re-add the `inputs.nixpkgs.follows = "nixpkgs";` line

## Verification

### Current Flake Outputs

```
├── checks.x86_64-linux
│   ├── deadnix: derivation 'deadnix-check'
│   ├── statix: derivation 'statix-check'
│   └── treefmt: derivation 'treefmt-check'
├── devShells.x86_64-linux
│   └── default: development environment 'nixos-dev'
├── formatter.x86_64-linux: package 'treefmt'
├── modules: unknown
├── nixConfig: unknown
└── nixosConfigurations
    └── blazar: NixOS configuration
```

### Testing Commands

```bash
# Validate all changes
nix flake check --impure

# Test formatting
nix fmt

# Test individual checks
nix build .#checks.x86_64-linux.statix
nix build .#checks.x86_64-linux.deadnix

# Test CI-like workflow
nix flake metadata
nix eval .#nixosConfigurations.blazar.config.system.build.toplevel.drvPath
```

## Context7 Documentation References

- treefmt-nix: Multi-language formatting tool integration for Nix flakes
- flake-parts perSystem: Pattern for system-specific outputs and checks
- Nix garbage collection: Automated cleanup configuration best practices

## NixOS Option Verification Needed

- `nix.gc.automatic`: ✓ Valid boolean option for automated cleanup
- `nix.gc.dates`: ✓ Valid systemd timer format
- `nix.gc.options`: ✓ Valid nix-store options string

## Next Phase Recommendations

1. Add cross-platform checks (Phase C)
2. Consider binary cache setup for faster builds
3. Explore flake-parts modules for better organization
