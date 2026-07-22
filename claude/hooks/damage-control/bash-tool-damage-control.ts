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
  logBlock,
  extractPackages,
  loadLearnedPackages,
  isTrustedPackage,
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

// Note: trash-put is intentionally NOT blocked - it is recoverable, so it
// acts as the safety net rather than a hazard.
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
  // Prevent substring matches like `/bin/` inside `/home/x/.local/bin/`:
  // require the path's first char to not be preceded by a path-name char.
  const boundary = (p: string) => (p.startsWith("/") ? "(?<![A-Za-z0-9._\\-])" : "");

  // For irreversible deletes, point the agent at the recoverable alternative.
  const hint = (operation: string) =>
    operation === "delete" ? ". If this deletion is intended and safe, use 'trash-put' instead (recoverable)" : "";

  if (isGlobPattern(path)) {
    const globRegex = globToRegex(path);
    const lb = boundary(path);
    for (const [patternTemplate, operation] of patterns) {
      try {
        const cmdPrefix = patternTemplate.replace("{path}", "");
        if (cmdPrefix) {
          const regex = new RegExp(cmdPrefix + lb + globRegex, "i");
          if (regex.test(command)) {
            return {
              blocked: true,
              reason: `Blocked: ${operation} operation on ${pathType} ${path}${hint(operation)}`,
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
    const lbExpanded = boundary(expanded);
    const lbOriginal = boundary(path);

    for (const [patternTemplate, operation] of patterns) {
      const patternExpanded = patternTemplate.replace("{path}", lbExpanded + escapedExpanded);
      const patternOriginal = patternTemplate.replace("{path}", lbOriginal + escapedOriginal);
      try {
        const regexExpanded = new RegExp(patternExpanded);
        const regexOriginal = new RegExp(patternOriginal);
        if (regexExpanded.test(command) || regexOriginal.test(command)) {
          return {
            blocked: true,
            reason: `Blocked: ${operation} operation on ${pathType} ${path}${hint(operation)}`,
          };
        }
      } catch {
        continue;
      }
    }
  }

  return { blocked: false, reason: "" };
}

/**
 * Blank the contents of multi-word quoted strings so message/data text is not
 * scanned for path patterns. Fixes false positives like `git commit -m "...env
 * stuff..."`, `echo "the .env file"`, and `python3 -c "import os; os.environ"`.
 * Single-token quoted operands (e.g. `cat ".env"`) and unquoted redirect targets
 * (`echo x > .env`) are preserved, so real secret access is still caught. Only
 * the path-access scans use this; the dangerous-command scan sees the raw command.
 */
function stripQuotedText(command: string): string {
  return command.replace(
    /(['"`])((?:\\.|(?!\1).)*)\1/gs,
    (match, quote, body) => (/\s/.test(body) ? `${quote}${quote}` : match)
  );
}

/**
 * Packages named by the command that are neither trusted (patterns.json) nor
 * learned (previously approved) - the names left to verify. Bare installs
 * from a manifest (`vp install`, `npm install`) name no packages.
 */
function unverifiedPackages(command: string, config: Config): string[] {
  const pkgs = extractPackages(command);
  if (pkgs.length === 0) return [];
  const learned = loadLearnedPackages();
  return pkgs.filter((p) => !isTrustedPackage(p, config.trustedPackages, learned));
}

function checkCommand(
  command: string,
  config: Config
): { blocked: boolean; ask: boolean; reason: string } {
  // 1. Check against patterns from JSON. Blocks win over asks regardless of
  // where they sit in the list, so the first ask is held until every block
  // pattern and every path check below has had its say.
  let pendingAsk = "";
  for (const { pattern, reason, ask: shouldAsk } of config.bashToolPatterns) {
    if (shouldAsk && pendingAsk) continue; // only the first ask reason is used
    try {
      if (!new RegExp(pattern, "i").test(command)) continue;
    } catch {
      continue;
    }
    if (!shouldAsk) {
      return { blocked: true, ask: false, reason: `Blocked: ${reason}` };
    }
    pendingAsk = reason;
  }

  // 2. Check for ANY access to zero-access paths (including reads)
  // Scan a copy with multi-word quoted text blanked, so commit messages / echoed
  // prose / inline code are not mistaken for path access (real operands survive).
  const scanCommand = stripQuotedText(command);
  // Extract path-like tokens from command to check against allowlist
  const commandTokens = scanCommand.match(/[^\s;|&"'`]+/g) || [];
  const escapeRe = (s: string): string => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
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
        if (regex.test(scanCommand)) {
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
      // Non-glob literal. Match only at path boundaries within a token (start,
      // or after / = :) so e.g. ".env" does not match the ".env" substring
      // inside "os.environ". Directory patterns (trailing /) match any suffix;
      // file patterns must end at a token / path boundary.
      const endsSlash = zeroPath.endsWith("/");
      const suffix = endsSlash ? "" : "(?:$|[/:])";
      const res = [zeroPath.replace(/^~/, homedir()), zeroPath].map(
        (lit) => new RegExp(`(?:^|[/=:])${escapeRe(lit)}${suffix}`)
      );
      const hits = commandTokens.filter((t) => res.some((re) => re.test(t)));
      if (hits.length > 0) {
        // Skip if all matching tokens are in the allowlist
        if (hits.every(isAllowed)) continue;
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
    const result = checkPathPatterns(scanCommand, readonlyPath, READ_ONLY_BLOCKED, "read-only path");
    if (result.blocked) {
      return { ...result, ask: false };
    }
  }

  // 4. Check for deletions on no-delete paths (read/write/edit allowed)
  for (const noDeletePath of config.noDeletePaths) {
    const result = checkPathPatterns(scanCommand, noDeletePath, NO_DELETE_BLOCKED, "no-delete path");
    if (result.blocked) {
      return { ...result, ask: false };
    }
  }

  // 5. Package install / runner naming an untrusted package. Derived from the
  // quote-aware detector in shared.ts (the single source of truth for what
  // counts as a package command), and only checked after every block above:
  // a trusted install must never carry a blocked command along with it
  // (`npm install eslint && rm -rf ~/notes`).
  if (!pendingAsk) {
    const unverified = unverifiedPackages(command, config);
    if (unverified.length > 0) {
      pendingAsk = `package install/runner: verify package name(s): ${unverified.join(", ")}`;
    }
  }

  // Nothing blocked - now a held-back ask can be raised.
  if (pendingAsk) {
    return { blocked: false, ask: true, reason: pendingAsk };
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
    logBlock("bash-damage-control", `reason=${reason} cmd=${command}`);
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
