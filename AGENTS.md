# AGENTS.md (Verified)

> **Scope**: Workspace agents for authoring **NixOS (flake‑parts + Home Manager)** configs using **real, publicly-available MCP servers** only.

---

## What’s in this workspace

- **gpt5‑codex** (orchestrator): Plans, grounds answers in docs, and queries Nix resources through MCP servers.  
- **MCP servers (autostart)**:
  - **Sequential Thinking** — structured plan steps. (npm: `@modelcontextprotocol/server-sequential-thinking`)
  - **Context7** — pulls up‑to‑date docs/snippets for code libs on demand. (npm: `@upstash/context7-mcp`)
  - **Docs MCP Server** — personal, version‑aware docs indexer (local/HTTP). (npm: `@arabold/docs-mcp-server`)
  - **MCP‑NixOS** — NixOS/Home‑Manager/nix‑darwin search & info (packages/options/versions). (PyPI: `mcp-nixos`)

> Removed hypothetical servers from previous drafts: `nix-manual-index-mcp`, `nix-hash-helper-mcp`, `nix-lint-format-mcp`, `schema-guard-mcp`, `nix-eval-safe-mcp` (no public packages found).

---

## Quickstart

**CLI (workspace‑scoped config)**
```bash
gpt5-codex --config .gpt5-codex/config.toml "Plan a NixOS flake for host 'blazar' with HM."
```

**VS Code**
```jsonc
// .vscode/settings.json
{
  "terminal.integrated.env.linux": {
    "GPT5_CODEX_CONFIG": "${workspaceFolder}/.gpt5-codex/config.toml"
  }
}
```

**Write protection**: File writes require token **`CONFIRM_SCAFFOLD`**. Until then, agents only propose changes and print commands for you to run manually.

---

## Verified MCP servers in use

| Server | How we start it | Useful tools |
|---|---|---|
| **Sequential Thinking** (`@modelcontextprotocol/server-sequential-thinking`) | `npx -y @modelcontextprotocol/server-sequential-thinking` | `plan.make`, `plan.refine` |
| **Context7** (`@upstash/context7-mcp`) | `npx -y @upstash/context7-mcp` (API key optional) | Up‑to‑date library docs/snippets; prompt: “use context7” |
| **Docs MCP Server** (`@arabold/docs-mcp-server`) | `npx @arabold/docs-mcp-server@latest` (or HTTP/SSE) | `search`, `scrape_docs` (index external docs) |
| **MCP‑NixOS** (`mcp-nixos`) | `uvx mcp-nixos` (or `nix run github:utensils/mcp-nixos --`, or Docker) | `nixos_search`, `nixos_info`, `home_manager_*`, `darwin_*`, `nixhub_*` |

---

## Typical authoring flow

```
Prompt → Sequential Thinking (plan) → Context7/Docs (grounding) → MCP‑NixOS (packages/options/versions) → propose Nix modules (print-only) → (optional) write with CONFIRM_SCAFFOLD
```

### Example prompts
- “Find the correct HM option for Firefox policies and show the official doc. Then propose a module.”  
- “Compare `services.nginx.*` options across stable vs unstable and cite source sections.”  
- “Which channel contains `nvidia-vaapi-driver` compatible with GTX 970?”

---

## Guardrails

- **No invented hashes**: proposals must show a `nix store prefetch-file/…` command when a real hash is needed.  
- **Print‑only** by default; **no destructive actions** (Disko/impermanence scaffolds only).  
- **Doc‑grounded** answers (include links/sections).  
- **Write token**: `CONFIRM_SCAFFOLD`.

---

## Troubleshooting

- Server won’t start → ensure Node 18+/uv/uvx/nix/docker available as needed.  
- Context7 rate‑limits → set `CONTEXT7_API_KEY`.  
- Docs MCP not reachable → use local `npx @arabold/docs-mcp-server@latest` instead of HTTP.  
- Claude/Cursor can’t find commands on NixOS → ensure `/run/current-system/sw/bin` is on PATH.

---

*Keep this doc in sync with `.gpt5-codex/config.toml`.*
