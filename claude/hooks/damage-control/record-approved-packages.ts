#!/usr/bin/env node
/**
 * Claude Code Damage Control - Record Approved Packages
 * =====================================================
 *
 * PostToolUse hook for the Bash tool. When a package install/runner command
 * has actually run, the user must have approved the `ask` verification prompt
 * (PostToolUse only fires for tools that executed). This records the package
 * names into the learned allowlist so bash-tool-damage-control.ts stops asking
 * to verify them next time.
 *
 * Learned allowlist: ~/.claude/damage-control/learned-packages.json
 *
 * Exit code: always 0 (best-effort, never blocks).
 */

import {
  type HookInput,
  readStdin,
  isPackageCommand,
  extractPackages,
  addLearnedPackages,
  logHook,
} from "./shared.ts";

interface PostHookInput extends HookInput {
  tool_response?: { interrupted?: boolean };
}

async function main(): Promise<void> {
  let input: PostHookInput;
  try {
    input = (await readStdin()) as PostHookInput;
  } catch {
    process.exit(0);
  }

  if (input.tool_name !== "Bash") {
    process.exit(0);
  }

  const command = input.tool_input?.command || "";
  if (!command || !isPackageCommand(command)) {
    process.exit(0);
  }

  // Skip interrupted runs - the install may not have completed.
  if (input.tool_response?.interrupted) {
    process.exit(0);
  }

  const pkgs = extractPackages(command);
  if (pkgs.length === 0) {
    process.exit(0);
  }

  const added = addLearnedPackages(pkgs);
  if (added.length) {
    logHook("LEARNED-PKG", `added=${added.join(",")}`);
  }

  process.exit(0);
}

main().catch(() => process.exit(0));
