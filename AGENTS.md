Perfect — here’s a ready-to-commit AGENTS.md tailored for dscv103/blazedots and the MCP servers you provided. Drop this at the repo root.

# AGENTS.md — blazedots (GitHub Copilot Coding Agent)

This document tells the GitHub Copilot **coding agent** exactly how to work in this repo
when assigned an issue or asked to open a PR from GitHub.com.

—

## 0) Operating assumptions

- Stack: **Python 3.13**, Nix **flake** repo, tests via **pytest**.
- Package management: prefer **uv**. If not present, fall back to standard Python tools.
- Source-of-truth process: follow the workspace instruction files in
  `.github/instructions/*.instructions.md` (notably `spec-driven-workflow-v1.instructions.md`)
  and any repo-wide `.github/copilot-instructions.md` if present.
- Always produce **small, reviewable PRs** with tests and docs updated.

—

## 1) Tooling & MCP policy

If MCP tools are available in this run, **use them in the order below**. If a tool is
unavailable, gracefully fall back to built-ins or shell commands.

| Priority | MCP Server (id) | Use it for | Fallback if unavailable |
|———:|-—————————|—————————————————————————————|-————————|
| 1 | `ripgrep` | Fast, precise code search & impact analysis (`rg`-style queries, globs, filters). | Editor search / `git grep` |
| 2 | `github` | Repo info, issues, PR metadata, file trees, commit history, draft/review assistance. | `git` CLI + GitHub REST (read-only) |
| 3 | `software-planning-tool` | Generate/iterate task plans, break down work, produce stepwise checklists. | Write your own step plan here in PR |
| 4 | `nixos` | Evaluate Nix flake outputs, check module options, validate Nix expressions. | `nix flake check`, `nix eval` |
| 5 | `context7` | External lookups/research (APIs, docs). **Cite sources** in PR description. | Minimize external claims; link upstream docs you find manually |

**Credentials/inputs** (provided by the platform configuration):

- `github`: header `Authorization: Bearer ${input:github_token}`
- `context7`: header `CONTEXT7_API_KEY: ${input:context7_api_key}`
- `nixos`: run with `uvx mcp-nixos`
- `ripgrep`: run with `npx -y mcp-ripgrep@latest`
- `software-planning-tool`: `node /absolute/path/to/software-planning-mcp/build/index.js`

> Do **not** hardcode secrets or tokens. Never write them to files or logs.

—

## 2) Environment setup & commands

When executing or validating locally within the agent VM:

1. **Detect repo capabilities**
   - If `flake.nix` exists → treat repo as Nix-first.
   - If `pyproject.toml` exists → prefer `uv` for installs and scripts.

2. **Setup (Nix-first)**
   ```bash
   # Open a dev shell and run tests
   nix develop -c uv pip install -e .
   nix develop -c pytest -q
   ```

If uv is unavailable in the shell:

nix develop -c pip install -e . && nix develop -c pytest -q

    3.	Setup (non-Nix fallback)

uv pip install -e . || pip install -e .
pytest -q || python -m pytest -q

    4.	Static checks (if configured)
    •	Try: ruff check, ruff format —check, mypy, or pytest -q depending on repo config.
    •	Never add global tools without documenting them in the PR.

⸻

3. Branching, commits, and PRs
   • Branch name: copilot/<short-task-slug>
   • Commit style: Conventional Commits
   • feat:, fix:, refactor:, docs:, test:, chore:, build:, ci:
   • PR title: mirror the main commit (≤ 72 chars).
   • PR description must include:
   • Context: brief problem statement with links to issue(s).
   • Plan & changes: bullet list of what changed, by file/area.
   • Test evidence: commands run + results (copy/paste output or summary).
   • Risk & rollback: how to revert or guard if something fails.
   • MCP usage: list MCP tools used and (if research) links/citations.

⸻

4. Safety & scope rules
   • Keep PRs focused (single logical change). If the issue is broad, create a plan and split
   into subtasks; open separate PRs per subtask.
   • Do not:
   • commit secrets, tokens, or machine-specific paths,
   • modify CI secrets, release pipelines, or publishing configs unless explicitly requested,
   • reformat the entire repo; limit formatting to touched lines/files.
   • Do:
   • update or add tests for all code changes,
   • update CHANGELOG.md and docs when user-visible behavior changes,
   • add .env.example entries when new env vars are introduced (never real values).

⸻

5. Standard operating procedures (SOPs)

A) Refactor for speed / structure 1. Use ripgrep to map call sites & hot paths (search by symbols and imports). 2. Produce a plan with software-planning-tool (or inline) covering:
• targets, risks, measurable outcome (e.g., runtime/allocs),
• test strategy & invariants,
• migration/rollback. 3. Apply minimal diffs; keep behavior identical unless stated otherwise. 4. Run tests; include micro-benchmarks if present in repo. 5. PR with before/after numbers (even if approximate), and a risk note.

B) New feature / bug fix 1. Confirm expected behavior from issue; write/adjust tests first if feasible. 2. Implement smallest change that passes tests and linters. 3. Document new flags/config in README or docs site. 4. PR with test output and usage note.

C) Nix / flake changes 1. Validate with nixos MCP or:

nix flake check
nix eval .# # if relevant outputs are defined

    2.	Avoid pin drift unless the task is “update flake.lock”.
    3.	If adding caches or binary substitutes, document keys and rationale in PR.

D) Documentation-only tasks 1. Keep code untouched unless the docs reveal a clear bug. 2. Check all links; prefer permalinks to tagged versions.

⸻

6. Testing & verification checklist (attach to PR)
   • Commands executed:
   • nix develop -c pytest -q or pytest -q
   • Linters/typers (if configured): ruff, mypy, etc.
   • New/updated tests for code changes
   • Docs/CHANGELOG updated (if user-facing)
   • No secrets or machine-specific paths added
   • Scope is minimal and issue is referenced

⸻

7. Planning rubric (for large tasks)

When an issue is broad or ambiguous: 1. Summarize the request in ≤ 5 bullets. 2. Propose 2–3 options (tradeoffs: complexity, risk, time). 3. Select one option and break into atomic steps (each ≤ ~1 hour of work). 4. Create subtasks or checklist in the PR body; execute top-down. 5. If blockers appear, comment in the PR with findings and request guidance.

Use software-planning-tool MCP to draft the plan when possible.

⸻

8. External access & networking
   • If external access is needed (e.g., cache.nixos.org, docs, package registries):
   • Prefer read-only access; do not publish or push artifacts.
   • Record all external domains accessed in the PR “MCP usage” section.
   • If a domain is blocked, note it in the PR and proceed offline with best-effort changes.

⸻

8.5. Formatting & CI
• **Always run treefmt before committing**: `nix develop -c treefmt`
• If CI fails on treefmt-check: 1. Run `nix develop -c treefmt --diff` to see required changes 2. Run `nix develop -c treefmt` to apply fixes 3. Commit formatting changes: `fix: apply treefmt formatting fixes`
• **Which files are formatted**: - Nix files: `nixfmt` (indentation, spacing) - Markdown/JSON/YAML: `prettier` (quotes, trailing whitespace)
• **Troubleshooting**: If `nix build .#checks.x86_64-linux.treefmt` fails, check for: - Mixed quote styles in YAML (prefer double quotes) - Inconsistent indentation in Nix files - Trailing whitespace or newlines

⸻

9. Failure handling
   • If tests cannot be run (infra/tooling gap), still open a PR with:
   • precise failure logs,
   • what you changed,
   • what a human needs to do to unblock (packages, permissions, missing scripts).
   • If scope creep is detected, propose a follow-up issue and keep PR minimal.

⸻

10. Files & areas you may modify
    • Source code, tests, docs, configuration under version control.
    • GitHub workflow files only if the issue requests CI changes or they are required to verify your change (explain why).
    • Do not alter repository protection rules, environments, or secrets.

⸻

11. House style quick notes
    • Prefer explicit over implicit; leave comments for non-obvious choices.
    • Use type hints in Python; keep public APIs documented.
    • Keep imports sorted and unused code removed if it’s in the touched files.

⸻

12. Definition of Done

A task is done when:
• The PR is focused, tests pass (or failures are unrelated and documented), reviews can proceed without guessing intent,
• Risks, rollback, and verification steps are clearly documented,
• MCP/tool usage and any external references are cited.
