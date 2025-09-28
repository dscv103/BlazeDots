#!/usr/bin/env node
const fs = require("fs");
const path = require("path");
const { spawn } = require("child_process");

// Resolve from this file's location (works no matter the CWD)
const root = path.resolve(__dirname, "..", "..");
const mcpDir = path.join(root, "tools", "software-planning-mcp");

// Support either build/ or dist/ layouts
const candidates = [
  process.env.SPMCP_ENTRY,                 // optional override
  path.join(mcpDir, "build", "index.js"),
  path.join(mcpDir, "dist", "index.js"),
].filter(Boolean);

const entry = candidates.find(p => fs.existsSync(p));
if (!entry) {
  console.error("ERROR: software-planning MCP entrypoint not found.");
  console.error("Tried:", candidates);
  process.exit(1);
}

spawn(process.execPath, [entry, ...process.argv.slice(2)], { stdio: "inherit" })
  .on("exit", code => process.exit(code));
