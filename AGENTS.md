# AGENTS.md

> **Purpose**: Explain how this workspace uses **gpt5‑codex** with auto‑started **MCP servers** to author **NixOS (flake‑parts + Home Manager)** configurations **safely, deterministically, and with zero side‑effects by default**.

---

## Quickstart

**Workspace layout**
```
repo-root/
  .codex/
    config.toml          # workspace-scoped (autostart MCP)
```

**Run (CLI)**

```bash
# Prefer the workspace config:
gpt5-codex --config .codex/config.toml "Plan a NixOS flake for host 'blazar' with Home Manager."
```

**VS Code (optional)**
```jsonc
// .vscode/settings.json
{
  "terminal.integrated.env.linux": {
    "GPT5_CODEX_CONFIG": "${workspaceFolder}/.codex/config.toml"
  }
}
```

**Write protection**  
All file writes are gated by the confirmation token **`CONFIRM_SCAFFOLD`**. Until then, agents **only propose** changes and print commands (e.g., `nix store prefetch-*`).

---

## Architecture

### High-level flow

```
User prompt
   │
   ▼
[gpt5-codex (planner/driver)]
   │
   ├─► sequential-thinking (plan.make → plan)
   │        │
   │        └─► context7 (pin plan + doc hits)
   │
   ├─► docsearch (NixOS/Nixpkgs/Home Manager/flake-parts/impermanence/sops-nix/disko)
   │
   ├─► schema-guard (validate generated Nix against schemas)
   │
   ├─► nix-hash-helper (lib.fakeSha256 + prefetch commands; never invent hashes)
   │
   ├─► nix-lint-format (print-only: treefmt, nixfmt, statix, deadnix)
   │
   └─► nix-eval-safe (print-only: flake metadata/check, dry builds)
```

### Agents & MCP servers

| Agent / MCP            | Role (Single Source of Truth)                                                                 | Key Tools (print-only unless stated)                                     | Autostart |
|---|---|---|---|
| **gpt5-codex**         | Orchestrator. Enforces guardrails, pipelines, and token-gated writes.                         | Pipelines: `nixos_authoring_default`, `hash_helper`, `lint_and_format`, `safe_eval` | – |
| **sequential-thinking**| Structured planning without chain-of-thought leakage; emits explicit, auditable plans.       | `plan.make`, `plan.refine`                                               | ✅ |
| **context7**           | Keeps 7 high-value context notes (plan, options table, current files, doc hits).             | `c7.pin`, `c7.get`, `c7.search`                                          | ✅ |
| **docsearch**          | Documentation search with inline citations to official sources.                               | `docs.search`, `docs.get`                                                | ✅ |
| **schema-guard**       | Validates generated Nix files against known schemas (nixos, flake-parts, HM, treefmt, CI).    | `schema.validate`                                                         | ✅ |
| **nix-hash-helper**    | Emits `lib.fakeSha256` placeholders and exact `nix store prefetch-*` commands.               | `hash.libfake`, `hash.prefetch_cmd`, `hash.prefetch_git_cmd`             | ✅ |
| **nix-lint-format**    | Prints lint/format command plan (treefmt, nixfmt, statix, deadnix).                           | `fmt.plan`, `lint.plan`                                                  | ✅ |
| **nix-eval-safe**      | Prints safe evaluation/check steps: `flake metadata`, `flake check`, dry builds.              | `nix.print_checks`, `nix.print_smoke_build`                              | ✅ |
| **nix-manual-index**   | (Optional) Ultra-fast local grep over cloned manuals.                                         | `nixdocs.grep`, `nixdocs.show`                                           | ⬜ |

> Autostart behavior is configured in `.codex/config.toml` under `[mcp.servers.*]`.

---

## Guardrails & Policies

- **No invented hashes**: Always output `lib.fakeSha256` + **exact** `nix store prefetch-*` commands next to any new sources.
- **Print-only by default**: No shell commands or `nix build` are executed automatically.
- **Write gating**: File writes require explicit token: **`CONFIRM_SCAFFOLD`**.
- **Risky ops warning**: If `impermanence = true` or `disko != "none"`, agents **only scaffold** and display a **bold red warning** (no destructive actions).
- **Stable attr order**: Generators keep attribute ordering stable to minimize diffs.
- **Doc-grounded**: Changes referencing options should carry a doc citation (URL + section) in the proposal.

---

## Pipelines

### `nixos_authoring_default` (auto-routed)

1. **Plan** with `sequential-thinking:plan.make` (constraints from guardrails + Nix defaults).  
2. **Pin** plan in `context7` for later refinement.  
3. **Doc search** via `docsearch:docs.search(q, k=5)` and pin results.  
4. **Schema validate** proposed files via `schema-guard:schema.validate(kind="nixos")`.  
5. **Hash hints** using `nix-hash-helper` (lib.fakeSha256 + prefetch commands).  
6. **Lint/format plan** via `nix-lint-format` (print-only).  
7. **Safe eval plan** via `nix-eval-safe` (print-only).  
8. **(Optional) Write** only after receiving `CONFIRM_SCAFFOLD` from the user.

### `hash_helper`

- Emits `lib.fakeSha256` and prints `prefetch` commands for any URLs or git sources detected.

### `lint_and_format`

- Prints what will be run for **treefmt**, **nixfmt**, **statix**, **deadnix**.

### `safe_eval`

- Prints `flake metadata`, `flake check`, and an optional **smoke build** command (dry where possible).

---

## Day‑to‑day Playbooks

### A) Add a new NixOS host (flake‑parts + HM)

- Prompt:  
  > “Create host `blazar` (Ryzen 7/GTX970), Wayland (Niri), Home Manager user `derek`, sops‑nix enabled, impermanence **off**, disko **none**.”
- Expected agent behavior: plan → doc hits → schema validate → hash hints → fmt/lint plan → eval plan.  
- To write files: reply with **`CONFIRM_SCAFFOLD`** when ready.

### B) Add a new source with a hash

- Prompt:  
  > “Add overlay pulling `foo` from `https://example.com/foo.tar.gz` rev `v1.2.3`.”
- Agent outputs: `lib.fakeSha256` + **exact** `nix store prefetch-file https://...` command.  
- You run the printed command, paste the real hash in a follow‑up, then confirm scaffold to write.

### C) Enable impermanence or disko (scaffold‑only)

- Prompt:  
  > “Enable impermanence with `/persist` and btrfs disko layout (no execution).”
- Agent displays **bold red warning**, generates **scaffold only**, includes commands to run manually.

### D) Tighten NVIDIA/Wayland (Niri) settings

- Prompt:  
  > “Propose stable NVIDIA (GTX 970) + Wayland/Niri module settings for Plasma‑free setup; print-only.”
- Agent will cite docs, propose a module, schema‑validate, and print fmt/eval plans.

---

## Style Guide (Nix)

- **flake‑parts** layout with small, composable modules (`modules/hosts/<host>`, `modules/users/<user>`, `overlays/`, `parts/`).  
- **Hash policy**: `lib.fakeSha256` until the user supplies the real hash via printed `prefetch` commands.  
- **Formatting**: treefmt orchestrates `nixfmt`, `statix`, `deadnix`.  
- **CI**: GitHub Actions running `nix fmt`, `statix`, `deadnix`, and `nix flake check` (print-only plans provided).

---

## Extending Agents (MCP Add‑ons)

You can add more MCP servers by editing `.codex/config.toml` under `[mcp.servers.*]`, then wire them into `[[automation.routing]]` and/or `pipelines.*`:

- **nixpkgs‑search MCP**: query package attrs/versions (avoids web browsing).  
- **nixos‑options MCP**: local index of `nixos-option` output for fast option lookup.  
- **hardware‑hints MCP**: parse `lspci`, `lsmod`, `journalctl` snippets to propose kernel params.  
- **doc‑index‑local MCP**: ripgrep on a local docs/ directory (if you prefer local-only).

Each new server should adhere to **print‑only** and **no‑invented‑hashes** policies.

---

## Troubleshooting

- **A server didn’t start**: check the binary/entrypoint in `[mcp.servers.<name>].command`.  
- **Pipelines not triggering**: confirm `automation.auto_use_mcp = true`, `autostart_mcp = true`, and routing rules match your prompt.  
- **Writes not happening**: remember to include **`CONFIRM_SCAFFOLD`** in your message.  
- **Doc cache stale**: set `toggles.docsearch_refresh_ok = true` or delete the cache dir shown in config.  
- **Local manual index empty**: set `nix_manual_index.autostart = true` and point `--root` to your clones.

---

## Environment & Precedence

Resolution order (recommended):
1. `--config <path>`  
2. `$GPT5_CODEX_CONFIG`  
3. `<cwd>/.codex/config.toml`  
4. `<repo root>/.codex/config.toml` (walk up to `.git`/`flake.nix`)  
5. `~/.config/gpt5-codex/config.toml`

Opt‑out global: `GPT5_CODEX_DISABLE_GLOBAL=1`.

---

## Security & Privacy

- No credentials should be stored in `config.toml`. Put secrets in `config.local.toml` (git‑ignored).  
- Docsearch respects local caches; clear them before sharing a machine.  
- Printed commands are for **manual** execution—review before running.

---

## Confirmation Token

- **Token**: `CONFIRM_SCAFFOLD`  
- **Effect**: Allows the agent to write proposed files (scaffold only; destructive ops are never run automatically).  
- **Scope**: Per request—include the token in the message where you want files written.

---

*This document is authoritative for agent behavior in this repository. Keep it in sync with `.codex/config.toml`.*
