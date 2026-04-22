#!/usr/bin/env node
/**
 * PermissionRequest hook: auto-allow edits to Claude's own config files
 * (skills, agents, commands, hooks, plans, memory) so the .claude/ self-edit
 * prompt does not appear for paths the user has explicitly chosen to manage.
 *
 * Damage control (PreToolUse) still runs before this hook, so any Edit/Write
 * blocked there never reaches PermissionRequest. This only suppresses the
 * built-in self-edit prompt for trusted Claude-config paths.
 *
 * Reference: https://github.com/anthropics/claude-code/issues (PermissionRequest
 * hook discussion).
 */

import { homedir } from "node:os";
import { resolve } from "node:path";

interface HookInput {
  tool_name?: string;
  tool_input?: { file_path?: string; [k: string]: unknown };
}

const SUPPORTED_TOOLS = new Set(["Edit", "Write", "MultiEdit", "NotebookEdit"]);

const HOME = homedir();
const ALLOWED_PREFIXES = [
  `${HOME}/.claude/`,
  `${HOME}/dotfiles/claude/`,
  `${HOME}/code/claude-marketplace/`,
];

function pathIsClaudeConfig(filePath: string): boolean {
  if (!filePath) return false;
  const expanded = filePath.startsWith("~/") ? filePath.replace(/^~/, HOME) : filePath;
  const abs = resolve(expanded);
  return ALLOWED_PREFIXES.some((prefix) => abs === prefix.replace(/\/$/, "") || abs.startsWith(prefix));
}

async function readStdin(): Promise<HookInput> {
  const chunks: Buffer[] = [];
  for await (const chunk of process.stdin) chunks.push(chunk);
  const text = Buffer.concat(chunks).toString("utf-8").trim();
  if (!text) return {};
  return JSON.parse(text);
}

async function main(): Promise<void> {
  let input: HookInput = {};
  try {
    input = await readStdin();
  } catch {
    process.exit(0);
  }

  if (!input.tool_name || !SUPPORTED_TOOLS.has(input.tool_name)) {
    process.exit(0);
  }

  const filePath = input.tool_input?.file_path ?? "";
  if (!pathIsClaudeConfig(filePath)) {
    process.exit(0);
  }

  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: "PermissionRequest",
        decision: { behavior: "allow" },
      },
    })
  );
  process.exit(0);
}

main().catch(() => process.exit(0));
