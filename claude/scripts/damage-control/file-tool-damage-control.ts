#!/usr/bin/env node
/**
 * Claude Code File Tool Damage Control
 * =====================================
 *
 * Blocks Edit/Write/MultiEdit operations to protected files.
 * Loads protectedPaths from patterns.json.
 *
 * Adapted based on: https://github.com/disler/claude-code-damage-control
 *
 * Exit codes:
 *   0 = Allow operation
 *   2 = Block operation (stderr fed back to Claude)
 */

import { loadConfig, readStdin, checkFilePath } from "./shared.ts";

const SUPPORTED_TOOLS = ["Edit", "Write", "MultiEdit"];

async function main(): Promise<void> {
  const config = loadConfig(import.meta.url);

  let input;
  try {
    input = await readStdin();
  } catch (e) {
    console.error(`Error: Invalid JSON input: ${e}`);
    process.exit(1);
  }

  if (!SUPPORTED_TOOLS.includes(input.tool_name)) {
    process.exit(0);
  }

  const filePath = input.tool_input?.file_path || "";
  if (!filePath) {
    process.exit(0);
  }

  const { blocked, reason } = checkFilePath(filePath, config);
  if (blocked) {
    const toolName = input.tool_name.toLowerCase();
    console.error(`SECURITY: Blocked ${toolName} to ${reason}: ${filePath}`);
    process.exit(2);
  }

  process.exit(0);
}

main().catch((e) => {
  console.error(`Hook error: ${e}`);
  process.exit(0);
});
