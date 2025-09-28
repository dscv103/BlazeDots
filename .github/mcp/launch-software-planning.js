#!/usr/bin/env node
const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");

// Prefer the real workspace path if provided by GitHub Actions.
// Fallback to path relative to this file.
const workspace = process.env.GITHUB_WORKSPACE;
const root = workspace ? path.resolve(workspace)
                       : path.resolve(__dirname, "..", "..");

const mcpDir = path.join(root, "tools", "software-planning-mcp");

const candidates = [
  process.env.SPMCP_ENTRY,                      // optional override
  path.join(mcpDir, "build", "index.js"),
  path.join(mcpDir, "dist", "index.js"),
].filter(Boolean);

const entry = candidates.find(p => p && fs.existsSync(p));
if (!entry) {
  console.error("ERROR: software-planning MCP entrypoint not found.");
  console.error("Tried:", candidates);
  process.exit(1);
}

spawn(process.execPath, [entry, ...process.argv.slice(2)], { stdio: "inherit" })
  .on("exit", code => process.exit(code));
