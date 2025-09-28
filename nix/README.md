# BlazeDots Modular Nix Structure

This directory contains the refactored, modular structure for the BlazeDots flake, organized for easy maintenance and discovery.

## Directory Structure

```
nix/
├── default.nix            # Main index with structure documentation
├── lib/                   # Shared utility functions
│   └── default.nix        # Helper functions for use across modules
├── modules/               # All flake modules organized by type
│   ├── nixos/            # System-level NixOS modules (10 modules)
│   │   ├── default.nix   # Index of all NixOS modules
│   │   ├── base.nix      # Core system configuration
│   │   ├── desktop.nix   # Desktop environment setup
│   │   ├── nvidia.nix    # NVIDIA graphics configuration
│   │   └── ...           # Additional system modules
│   ├── home/             # Home Manager modules (6 modules)  
│   │   ├── default.nix   # Index of all Home Manager modules
│   │   ├── shell.nix     # Shell configuration
│   │   ├── vscode.nix    # VS Code setup
│   │   └── ...           # Additional user modules
│   └── profiles/         # Combined feature profiles
│       └── default.nix   # Index for optional profile combinations
├── overlays/             # Nixpkgs overlays and patches
│   └── default.nix       # Overlay index
├── packages/             # Custom package definitions
│   └── default.nix       # Package index
└── parts/                # Flake-parts modules
    ├── default.nix       # Parts index
    ├── modules.nix       # Module exports configuration
    ├── fmt.nix           # Formatter and checks
    └── caches.nix        # Binary cache configuration
```

## Key Features

### 🎯 **Discoverable Structure**
- Clear directory hierarchy with logical groupings
- Index files (`default.nix`) in each directory for easy navigation
- Self-documenting structure with consistent naming

### 🔧 **Easy Maintenance** 
- Modules organized by purpose (nixos/home/profiles)
- Index files make adding new modules straightforward
- Clear separation between different types of functionality

### 📦 **Flake-parts Integration**
- Proper flake-parts modular design
- perSystem outputs organized in `parts/`
- Module exports cleanly handled via `parts/modules.nix`

### 🔄 **Behavior Preservation**
- All original functionality maintained
- Only path changes, no module content modifications
- Backward-compatible module export structure

## Usage

### Finding Modules
- **NixOS modules**: Look in `nix/modules/nixos/default.nix`
- **Home Manager modules**: Look in `nix/modules/home/default.nix`
- **Custom packages**: Look in `nix/packages/default.nix`
- **Overlays**: Look in `nix/overlays/default.nix`

### Adding New Modules
1. Create your module file in the appropriate directory
2. Add an entry to the relevant `default.nix` index file
3. Update `nix/parts/modules.nix` if it should be exported via `flake.modules`

### Module Exports
All modules are exported via `flake.modules.*` for use in other flakes:
- `flake.modules.nixos.*` - System modules
- `flake.modules.home.*` - Home Manager modules

## Migration Complete ✅

This structure represents a complete refactoring of the original BlazeDots layout:
- **Old**: `parts/`, `modules/core/common/`, `modules/extra/exported/home/`
- **New**: `nix/parts/`, `nix/modules/nixos/`, `nix/modules/home/`

All functionality has been preserved while improving maintainability and discoverability.
