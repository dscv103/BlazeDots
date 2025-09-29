# Plan.md

---

### Section A: **Spec Digest**
1. **Repository Overview**:
   - Modular Nix-based for NixOS configurations and Home Manager setups.
   - Focus on reproducibility, ease of maintenance, and modularity.

2. **Spec-Driven Workflow**:
   - Maintain `requirements.md`, `design.md`, and `tasks.md` at all times.
   - Follow a 6-phase loop: Analyze, Design, Implement, Validate, Reflect, Handoff.
   - Decision records and action logs must document rationale and results.

3. **Thinking-Beast-Mode Directives**:
   - Operate autonomously with a bias-to-action.
   - Use sequential, multi-perspective, and adversarial analysis.
   - Plan extensively before execution; solve comprehensively.

4. **Performance Focus Areas**:
   - **Boot**: Optimize initrd, kernel parameters, and service dependency graph.
   - **Program Startup**: Triage I/O, dynamic linking, and cache tuning.
   - **Compile**: Enforce parallelism, leverage caches (ccache/sccache), and introduce opt-in ThinLTO/PGO.

5. **CI & Validation**:
   - Ensure green builds with `nix flake check`, `nix build`, and linting tools (`nix fmt`, `statix`, `deadnix`).
   - Automate missing checks or add in `.github/workflows`.

6. **Constraints**:
   - All changes must be reversible or gated behind opt-in flags.
   - Document risks and migration notes for non-backward-compatible changes.

---

### Section B: **Review Plan**

#### **Phase 1: Analyze**
1. **Boot Optimization**:
   - Inspect `nix/modules/nixos` for initrd compression, kernel params, and systemd service graph.
   - Evaluate options for zstd compression and parallel unit loading.

2. **Program Startup**:
   - Identify hot executables and analyze I/O bottlenecks.
   - Check for `LD_PRELOAD` misuse; explore consistent XDG cache usage.

3. **Compile Performance**:
   - Review build parallelism in `nix/packages` and `flake.nix`.
   - Check for unused `ccache`/`sccache` hooks.

#### **Phase 2: Design**
4. Propose safe, minimal-diff changes for each area:
   - Boot: Add `boot.optimizations.enable` Nix option.
   - Compile: Integrate ThinLTO/PGO behind flags.

5. Document in `design.md`:
   - Architecture, error handling, and edge cases.

#### **Phase 3: Implement**
6. Create `perf/phase1-boot-startup-compile` branch.
7. Commit safe changes iteratively:
   - Boot tweaks, CI automation, and build fixes.

#### **Phase 4: Validate**
8. Execute CI steps:
   - `nix flake check`, `nix fmt`, `statix`, `deadnix`.
   - Run representative boot, startup, and compile benchmarks.

#### **Phase 5: Reflect**
9. Refactor for maintainability:
   - Update documentation with risks, rationale, and results.

#### **Phase 6: Handoff**
10. Open tracking issue and two PRs:
    - CI validation.
    - Performance tweaks with opt-in flags.

---

### Section C: **Proposed Changes & Rationale**

#### Boot
- **Kernel Params**:
  - Add `zstd` compression for initrd.
  - Minimize service critical paths with parallel `After=` assignments.

- **Rationale**:
  - Improve decompression speed and boot parallelism.

#### Program Startup
- **Cache Hygiene**:
  - Enforce XDG cache consistency.

- **Rationale**:
  - Reduce redundant I/O on cold starts.

#### Compile
- **Parallelism**:
  - Introduce `-j` flags uniformly.
  - Add `ccache`/`sccache` via Nix.

- **Rationale**:
  - Consistent, scalable builds with caching.

---

### Section D: **Risk & Rollback**
- All changes gated under `boot.optimizations.enable` and other opt-in flags.
- Rollback:
  - Disable flags for immediate reversion.

---

### Section E: **Benchmarks to Run**
1. **Boot**:
   - `systemd-analyze critical-chain`.
   - Expected: ~20% reduction in boot time.

2. **Startup**:
   - `time ./hot-program`.
   - Expected: ~15% improvement in load time.

3. **Compile**:
   - `nix build .#nixosConfigurations.<HOST>.config.system.build.toplevel`.
   - Expected: Linear scaling with cores.

---