#!/usr/bin/env node
/**
 * Claude Code Security Firewall - Bash Tool
 * ==========================================
 *
 * Blocks dangerous commands before execution via PreToolUse hook.
 * Loads patterns from patterns.json for easy customization.
 *
 * Adapted based on: https://github.com/disler/claude-code-damage-control
 *
 * Exit codes:
 *   0 = Allow command (or JSON output with permissionDecision)
 *   2 = Block command (stderr fed back to Claude)
 *
 * JSON output for ask patterns:
 *   {"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "ask", "permissionDecisionReason": "..."}}
 */

import { homedir } from "node:os";
import {
  type Config,
  isGlobPattern,
  globToRegex,
  matchGlob,
  loadConfig,
  readStdin,
} from "./shared.ts";

// =============================================================================
// OPERATION PATTERNS - Edit these to customize what operations are blocked
// =============================================================================

type PatternTuple = [string, string];

const WRITE_PATTERNS: PatternTuple[] = [
  [">\\s*{path}", "write"],
  ["\\btee\\s+(?!.*-a).*{path}", "write"],
];

const APPEND_PATTERNS: PatternTuple[] = [
  [">>\\s*{path}", "append"],
  ["\\btee\\s+-a\\s+.*{path}", "append"],
  ["\\btee\\s+.*-a.*{path}", "append"],
];

const EDIT_PATTERNS: PatternTuple[] = [
  ["\\bsed\\s+-i.*{path}", "edit"],
  ["\\bperl\\s+-[^\\s]*i.*{path}", "edit"],
  ["\\bawk\\s+-i\\s+inplace.*{path}", "edit"],
];

const MOVE_COPY_PATTERNS: PatternTuple[] = [
  ["\\bmv\\s+.*\\s+{path}", "move"],
  ["\\bcp\\s+.*\\s+{path}", "copy"],
];

const DELETE_PATTERNS: PatternTuple[] = [
  ["\\brm\\s+.*{path}", "delete"],
  ["\\bunlink\\s+.*{path}", "delete"],
  ["\\brmdir\\s+.*{path}", "delete"],
  ["\\bshred\\s+.*{path}", "delete"],
];

const PERMISSION_PATTERNS: PatternTuple[] = [
  ["\\bchmod\\s+.*{path}", "chmod"],
  ["\\bchown\\s+.*{path}", "chown"],
  ["\\bchgrp\\s+.*{path}", "chgrp"],
];

const TRUNCATE_PATTERNS: PatternTuple[] = [
  ["\\btruncate\\s+.*{path}", "truncate"],
  [":\\s*>\\s*{path}", "truncate"],
];

const READ_ONLY_BLOCKED: PatternTuple[] = [
  ...WRITE_PATTERNS,
  ...APPEND_PATTERNS,
  ...EDIT_PATTERNS,
  ...MOVE_COPY_PATTERNS,
  ...DELETE_PATTERNS,
  ...PERMISSION_PATTERNS,
  ...TRUNCATE_PATTERNS,
];

const NO_DELETE_BLOCKED: PatternTuple[] = DELETE_PATTERNS;

// =============================================================================
// PATH CHECKING
// =============================================================================

function checkPathPatterns(
  command: string,
  path: string,
  patterns: PatternTuple[],
  pathType: string
): { blocked: boolean; reason: string } {
  if (isGlobPattern(path)) {
    const globRegex = globToRegex(path);
    for (const [patternTemplate, operation] of patterns) {
      try {
        const cmdPrefix = patternTemplate.replace("{path}", "");
        if (cmdPrefix) {
          const regex = new RegExp(cmdPrefix + globRegex, "i");
          if (regex.test(command)) {
            return {
              blocked: true,
              reason: `Blocked: ${operation} operation on ${pathType} ${path}`,
            };
          }
        }
      } catch {
        continue;
      }
    }
  } else {
    const expanded = path.replace(/^~/, homedir());
    const escapedExpanded = expanded.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    const escapedOriginal = path.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

    for (const [patternTemplate, operation] of patterns) {
      const patternExpanded = patternTemplate.replace("{path}", escapedExpanded);
      const patternOriginal = patternTemplate.replace("{path}", escapedOriginal);
      try {
        const regexExpanded = new RegExp(patternExpanded);
        const regexOriginal = new RegExp(patternOriginal);
        if (regexExpanded.test(command) || regexOriginal.test(command)) {
          return {
            blocked: true,
            reason: `Blocked: ${operation} operation on ${pathType} ${path}`,
          };
        }
      } catch {
        continue;
      }
    }
  }

  return { blocked: false, reason: "" };
}

function checkCommand(
  command: string,
  config: Config
): { blocked: boolean; ask: boolean; reason: string } {
  // 1. Check against patterns from JSON (may block or ask)
  for (const { pattern, reason, ask: shouldAsk } of config.bashToolPatterns) {
    try {
      const regex = new RegExp(pattern, "i");
      if (regex.test(command)) {
        if (shouldAsk) {
          return { blocked: false, ask: true, reason };
        } else {
          return { blocked: true, ask: false, reason: `Blocked: ${reason}` };
        }
      }
    } catch {
      continue;
    }
  }

  // 2. Check for ANY access to zero-access paths (including reads)
  // Extract path-like tokens from command to check against allowlist
  const commandTokens = command.match(/[^\s;|&"'`]+/g) || [];
  const isAllowed = (token: string): boolean =>
    config.allowedPaths.some((ap) =>
      isGlobPattern(ap) ? matchGlob(token, ap) || matchGlob(token.split("/").pop() || "", ap) : token.endsWith(ap)
    );

  for (const zeroPath of config.zeroAccessPaths) {
    if (isGlobPattern(zeroPath)) {
      const globRegex = globToRegex(zeroPath);
      try {
        // Anchor to path-like context: preceded by whitespace, /, =, or start of string
        // This prevents matching code like "Object.keys()" against "*.key"
        const regex = new RegExp(`(?:^|[\\s/=])${globRegex}(?:\\s|$|[;|&"'\`])`, "i");
        if (regex.test(command)) {
          // Skip if all matching tokens are in the allowlist
          if (commandTokens.some((t) => matchGlob(t, zeroPath) || matchGlob(t.split("/").pop() || "", zeroPath)) &&
              commandTokens.filter((t) => matchGlob(t, zeroPath) || matchGlob(t.split("/").pop() || "", zeroPath)).every(isAllowed)) {
            continue;
          }
          return {
            blocked: true,
            ask: false,
            reason: `Blocked: zero-access pattern ${zeroPath} (no operations allowed)`,
          };
        }
      } catch {
        continue;
      }
    } else {
      const expanded = zeroPath.replace(/^~/, homedir());
      if (command.includes(expanded) || command.includes(zeroPath)) {
        // Skip if all matching tokens are in the allowlist
        if (commandTokens.some((t) => t.includes(expanded) || t.includes(zeroPath)) &&
            commandTokens.filter((t) => t.includes(expanded) || t.includes(zeroPath)).every(isAllowed)) {
          continue;
        }
        return {
          blocked: true,
          ask: false,
          reason: `Blocked: zero-access path ${zeroPath} (no operations allowed)`,
        };
      }
    }
  }

  // 3. Check for modifications to read-only paths (reads allowed)
  for (const readonlyPath of config.readOnlyPaths) {
    const result = checkPathPatterns(command, readonlyPath, READ_ONLY_BLOCKED, "read-only path");
    if (result.blocked) {
      return { ...result, ask: false };
    }
  }

  // 4. Check for deletions on no-delete paths (read/write/edit allowed)
  for (const noDeletePath of config.noDeletePaths) {
    const result = checkPathPatterns(command, noDeletePath, NO_DELETE_BLOCKED, "no-delete path");
    if (result.blocked) {
      return { ...result, ask: false };
    }
  }

  return { blocked: false, ask: false, reason: "" };
}

// =============================================================================
// MAIN
// =============================================================================

async function main(): Promise<void> {
  const config = loadConfig(import.meta.url);

  let input;
  try {
    input = await readStdin();
  } catch (e) {
    console.error(`Error: Invalid JSON input: ${e}`);
    process.exit(1);
  }

  if (input.tool_name !== "Bash") {
    process.exit(0);
  }

  const command = input.tool_input?.command || "";
  if (!command) {
    process.exit(0);
  }

  const { blocked, ask, reason } = checkCommand(command, config);

  if (blocked) {
    console.error(`SECURITY: ${reason}`);
    console.error(`Command: ${command.slice(0, 100)}${command.length > 100 ? "..." : ""}`);
    process.exit(2);
  } else if (ask) {
    const output = {
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "ask",
        permissionDecisionReason: reason,
      },
    };
    console.log(JSON.stringify(output));
    process.exit(0);
  } else {
    process.exit(0);
  }
}

main().catch((e) => {
  console.error(`Hook error: ${e}`);
  process.exit(0);
});
