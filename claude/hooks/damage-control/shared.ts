#!/usr/bin/env node
/**
 * Shared utilities for Claude Code damage control hooks
 *
 * Adapted based on: https://github.com/disler/claude-code-damage-control
 */

import { existsSync, readFileSync, writeFileSync, appendFileSync, mkdirSync } from "node:fs";
import { dirname, join, basename } from "node:path";
import { homedir } from "node:os";
import { fileURLToPath } from "node:url";

// =============================================================================
// TYPES
// =============================================================================

export interface Pattern {
  pattern: string;
  reason: string;
  ask?: boolean;
}

export interface Config {
  trustedPackages: string[];
  bashToolPatterns: Pattern[];
  allowedPaths: string[];
  zeroAccessPaths: string[];
  writeAskPaths: string[];
  readOnlyPaths: string[];
  noDeletePaths: string[];
}

export interface HookInput {
  tool_name: string;
  tool_input: {
    command?: string;
    file_path?: string;
    [key: string]: unknown;
  };
}

// =============================================================================
// GLOB UTILITIES
// =============================================================================

export function isGlobPattern(pattern: string): boolean {
  return pattern.includes("*") || pattern.includes("?") || pattern.includes("[");
}

export function globToRegex(globPattern: string): string {
  let result = "";
  for (const char of globPattern) {
    if (char === "*") {
      result += "[^\\s/]*";
    } else if (char === "?") {
      result += "[^\\s/]";
    } else if (".+^${}()|[]\\".includes(char)) {
      result += "\\" + char;
    } else {
      result += char;
    }
  }
  return result;
}

export function matchGlob(str: string, pattern: string): boolean {
  const regexPattern = pattern
    .toLowerCase()
    .replace(/[.+^${}()|[\]\\]/g, "\\$&")
    .replace(/\*/g, ".*")
    .replace(/\?/g, ".");

  try {
    const regex = new RegExp(`^${regexPattern}$`, "i");
    return regex.test(str.toLowerCase());
  } catch {
    return false;
  }
}

export function matchPath(filePath: string, pattern: string): boolean {
  const expandedPattern = pattern.replace(/^~/, homedir());
  const normalized = filePath.replace(/^~/, homedir());

  if (isGlobPattern(pattern)) {
    const fileBasename = basename(normalized);
    if (matchGlob(fileBasename, expandedPattern) || matchGlob(fileBasename, pattern)) {
      return true;
    }
    if (matchGlob(normalized, expandedPattern)) {
      return true;
    }
    return false;
  } else {
    if (normalized.startsWith(expandedPattern) || normalized === expandedPattern.replace(/\/$/, "")) {
      return true;
    }
    return false;
  }
}

// =============================================================================
// CONFIG LOADING
// =============================================================================

export function getConfigPath(callerUrl: string): string {
  const callerDir = dirname(fileURLToPath(callerUrl));

  const projectDir = process.env.CLAUDE_PROJECT_DIR;
  if (projectDir) {
    const projectConfig = join(projectDir, ".claude", "hooks", "damage-control", "patterns.json");
    if (existsSync(projectConfig)) {
      return projectConfig;
    }
  }

  const localConfig = join(callerDir, "patterns.json");
  if (existsSync(localConfig)) {
    return localConfig;
  }

  const skillRoot = join(callerDir, "..", "..", "patterns.json");
  if (existsSync(skillRoot)) {
    return skillRoot;
  }

  return localConfig;
}

export function loadConfig(callerUrl: string): Config {
  const configPath = getConfigPath(callerUrl);

  if (!existsSync(configPath)) {
    console.error(`Warning: Config not found at ${configPath}`);
    return { trustedPackages: [], bashToolPatterns: [], allowedPaths: [], zeroAccessPaths: [], writeAskPaths: [], readOnlyPaths: [], noDeletePaths: [] };
  }

  const content = readFileSync(configPath, "utf-8");
  const config = JSON.parse(content) as Partial<Config>;

  return {
    trustedPackages: config.trustedPackages || [],
    bashToolPatterns: config.bashToolPatterns || [],
    allowedPaths: config.allowedPaths || [],
    zeroAccessPaths: config.zeroAccessPaths || [],
    writeAskPaths: config.writeAskPaths || [],
    readOnlyPaths: config.readOnlyPaths || [],
    noDeletePaths: config.noDeletePaths || [],
  };
}

// =============================================================================
// STDIN READING
// =============================================================================

export async function readStdin(): Promise<HookInput> {
  const chunks: Buffer[] = [];
  for await (const chunk of process.stdin) {
    chunks.push(chunk);
  }
  const inputText = Buffer.concat(chunks).toString("utf-8");
  return JSON.parse(inputText);
}

// =============================================================================
// LOGGING
// =============================================================================

const LOG_FILE = join(homedir(), ".claude", "custom-hook-blocks.log");

export function logBlock(rule: string, detail: string): void {
  const timestamp = new Date().toISOString().replace("T", " ").slice(0, 19);
  const line = `[${timestamp}] BLOCKED rule=${rule} ${detail.slice(0, 120)}\n`;
  try {
    mkdirSync(dirname(LOG_FILE), { recursive: true });
    appendFileSync(LOG_FILE, line);
  } catch {
    // best-effort logging
  }
}

export function logHook(tag: string, detail: string): void {
  const timestamp = new Date().toISOString().replace("T", " ").slice(0, 19);
  const line = `[${timestamp}] ${tag} ${detail.slice(0, 160)}\n`;
  try {
    mkdirSync(dirname(LOG_FILE), { recursive: true });
    appendFileSync(LOG_FILE, line);
  } catch {
    // best-effort logging
  }
}

// =============================================================================
// PACKAGE EXTRACTION + LEARNED ALLOWLIST
// =============================================================================
//
// Package-install / runner commands prompt for verification when they name a
// package that is not yet trusted. Once the user approves an install, the
// PostToolUse hook records its package names here, and the PreToolUse hook
// auto-allows them next time instead of asking again.

const LEARNED_PACKAGES_FILE = join(homedir(), ".claude", "custom-learned-packages.json");

// Package-manager invocations, keyed by their first token.
const RUNNER_HEADS = new Set(["npx", "pnpx", "vpx", "bunx"]);
const DLX_HEADS = new Set(["pnpm", "vp"]); // `pnpm dlx` / `vp dlx` run like npx
const NODE_INSTALL = ["add", "i", "install"];
const INSTALL_SUBCOMMANDS: Record<string, string[]> = {
  npm: NODE_INSTALL,
  pnpm: NODE_INSTALL,
  yarn: NODE_INSTALL,
  bun: NODE_INSTALL,
  vp: ["add", "install"],
  pip: ["install"],
  pip3: ["install"],
  cargo: ["add", "install"],
  gem: ["install"],
  go: ["install", "get"],
  deno: ["add", "install"],
  brew: ["install"],
};

// A valid package name: optional @scope, then alphanumerics plus . _ - /
// (covers npm scoped names, pip names, and go module paths). Rejects tokens
// carrying quotes, commas, brackets etc. - i.e. install strings used as data.
const VALID_PACKAGE_RE = /^@?[a-z0-9][a-z0-9._/-]*$/i;

/**
 * Drop heredoc bodies before parsing. Their contents are data - prose, config,
 * markdown - not commands, and a line like `pnpm install rewrites the root
 * package.json` inside one would otherwise read as an install naming six
 * packages.
 */
function stripHeredocBodies(command: string): string {
  const lines = command.split("\n");
  const out: string[] = [];
  let i = 0;
  while (i < lines.length) {
    const line = lines[i++];
    out.push(line);
    const m = line.match(/<<(-?)\s*(['"]?)([A-Za-z_][A-Za-z0-9_]*)\2/);
    if (!m) continue;
    const [, dash, , delim] = m;
    while (i < lines.length) {
      const body = lines[i++];
      const trimmed = dash ? body.replace(/^\t+/, "") : body;
      if (trimmed.trimEnd() === delim) {
        out.push(body); // keep the terminator so segment counts stay sane
        break;
      }
    }
  }
  return out.join("\n");
}

/**
 * Split a command into top-level segments of tokens, ignoring separators that
 * appear inside quotes (so install strings embedded in script arguments are
 * not mistaken for real commands). Quote characters are kept on their tokens,
 * which is what stops `-m "npx foo"` from reading as an invocation.
 */
function commandSegments(command: string): string[][] {
  const raw: string[] = [];
  command = stripHeredocBodies(command);
  let cur = "";
  let quote: string | null = null;
  for (let i = 0; i < command.length; i++) {
    const c = command[i];
    if (quote) {
      cur += c;
      if (c === quote) quote = null;
      continue;
    }
    if (c === '"' || c === "'" || c === "`") {
      quote = c;
      cur += c;
      continue;
    }
    if (c === ";" || c === "|" || c === "&" || c === "\n") {
      raw.push(cur);
      cur = "";
      if (command[i + 1] === c) i++; // collapse && and ||
      continue;
    }
    cur += c;
  }
  if (cur) raw.push(cur);
  return raw.map((s) => s.trim().split(/\s+/).filter(Boolean)).filter((toks) => toks.length > 0);
}

interface Invocation {
  kind: "runner" | "install";
  /** Index of the first token after the command head. */
  start: number;
}

// Commands that can precede a real invocation without changing what it is.
const WRAPPER_HEADS = new Set([
  "sudo", "doas", "env", "timeout", "nice", "ionice", "xargs",
  "command", "nohup", "setsid", "stdbuf", "time",
]);

/** True once the token is a recognised package-manager head. */
function isHead(tok: string, next: string | undefined): boolean {
  if (RUNNER_HEADS.has(tok)) return true;
  if (!next) return false;
  return (next === "dlx" && DLX_HEADS.has(tok)) || Boolean(INSTALL_SUBCOMMANDS[tok]?.includes(next));
}

/** A token that may sit before the invocation head: wrapper, flag, VAR=x, or a bare number. */
function isSkippablePrefix(tok: string): boolean {
  return (
    WRAPPER_HEADS.has(tok) ||
    tok.startsWith("-") ||
    /^\d+(\.\d+)?[smhd]?$/.test(tok) || // timeout/nice numeric args
    /^[A-Za-z_][A-Za-z0-9_]*=/.test(tok)  // env assignments
  );
}

/**
 * Find a package-manager invocation at the head of a segment.
 *
 * The head may sit behind wrappers - `timeout 300 npx vue-tsc`, `sudo npm
 * install x`, `env FOO=1 vpx y` are all the same invocation as their bare
 * forms - so leading wrapper/flag/assignment tokens are skipped. Anything
 * else before the head means this is not an invocation: that is what stops a
 * prose line such as `the pnpm install rewrites the root package.json` from
 * reading as an install and teaching its words as package names.
 */
function findInvocation(tokens: string[]): Invocation | null {
  let i = 0;
  while (i < tokens.length && !isHead(tokens[i], tokens[i + 1])) {
    if (!isSkippablePrefix(tokens[i])) return null;
    // A wrapper flag may take a value (`sudo -u root`, `timeout -k 5`); skip it too.
    if (tokens[i].startsWith("-") && !tokens[i].includes("=")) i++;
    i++;
  }
  if (i >= tokens.length) return null;
  const tok = tokens[i];
  const next = tokens[i + 1];
  if (RUNNER_HEADS.has(tok)) return { kind: "runner", start: i + 1 };
  if (next === "dlx" && DLX_HEADS.has(tok)) return { kind: "runner", start: i + 2 };
  return { kind: "install", start: i + 2 };
}

/** True if the command installs packages or downloads-and-runs one. */
export function isPackageCommand(command: string): boolean {
  return commandSegments(command).some((toks) => findInvocation(toks) !== null);
}

/** Strip version / range / extras suffix from a package token, scope-aware. */
export function normalizePackageName(token: string): string {
  let name = token.trim();
  name = name.replace(/\[.*$/, ""); // pip extras: pkg[extra] -> pkg
  name = name.split(/[=<>!~]+/)[0]; // version specifiers: pkg==1.0 -> pkg
  if (name.startsWith("@")) {
    // npm scoped: @scope/name@version -> @scope/name
    const slash = name.indexOf("/");
    if (slash !== -1) {
      const at = name.indexOf("@", slash);
      if (at !== -1) name = name.slice(0, at);
    }
  } else {
    // name@version -> name (also go: host/path@version)
    const at = name.indexOf("@");
    if (at > 0) name = name.slice(0, at);
  }
  return name.trim();
}

/**
 * Extract normalized package names from an install/runner command.
 * Runners (npx/dlx) only take a single package; installers take all.
 */
export function extractPackages(command: string): string[] {
  const pkgs: string[] = [];
  for (const tokens of commandSegments(command)) {
    const invocation = findInvocation(tokens);
    if (!invocation) continue;
    for (let i = invocation.start; i < tokens.length; i++) {
      const tok = tokens[i];
      if (/^&?\d*[<>]/.test(tok)) break;   // redirection (>, 2>&1, 1>f, &>) - rest is not packages
      if (tok.startsWith("-")) continue;   // flags (and bare --)
      if (/^[./~]/.test(tok)) continue;    // local paths
      const name = normalizePackageName(tok);
      if (!VALID_PACKAGE_RE.test(name)) continue;
      pkgs.push(name);
      if (invocation.kind === "runner") break;  // runners take a single package
    }
  }
  return pkgs;
}

export function loadLearnedPackages(): Set<string> {
  try {
    if (existsSync(LEARNED_PACKAGES_FILE)) {
      const arr = JSON.parse(readFileSync(LEARNED_PACKAGES_FILE, "utf-8"));
      if (Array.isArray(arr)) return new Set(arr.map(String));
    }
  } catch {
    // ignore corrupt file
  }
  return new Set();
}

/** Append new package names to the learned allowlist. Returns names added. */
export function addLearnedPackages(names: string[]): string[] {
  const current = loadLearnedPackages();
  const added: string[] = [];
  for (const n of names) {
    if (n && !current.has(n)) {
      current.add(n);
      added.push(n);
    }
  }
  if (added.length) {
    try {
      mkdirSync(dirname(LEARNED_PACKAGES_FILE), { recursive: true });
      writeFileSync(LEARNED_PACKAGES_FILE, JSON.stringify([...current].sort(), null, 2) + "\n");
    } catch {
      // best-effort persistence
    }
  }
  return added;
}

/** True if a package name is in config.trustedPackages or the learned allowlist. */
export function isTrustedPackage(name: string, trustedPackages: string[], learned: Set<string>): boolean {
  if (learned.has(name)) return true;
  return trustedPackages.some((tp) => (tp.endsWith("/") ? name.startsWith(tp) : name === tp));
}

// =============================================================================
// PATH CHECKING (for Edit/Write tools)
// =============================================================================

export function checkFilePath(
  filePath: string,
  config: Config,
  isReadOnlyTool = false
): { blocked: boolean; ask: boolean; reason: string } {
  // Check allowlist first - these paths are always permitted
  for (const allowedPath of config.allowedPaths) {
    if (matchPath(filePath, allowedPath)) {
      return { blocked: false, ask: false, reason: "" };
    }
  }

  for (const zeroPath of config.zeroAccessPaths) {
    if (matchPath(filePath, zeroPath)) {
      return { blocked: true, ask: false, reason: `zero-access path ${zeroPath} (no operations allowed)` };
    }
  }

  if (!isReadOnlyTool) {
    for (const askPath of config.writeAskPaths) {
      if (matchPath(filePath, askPath)) {
        return { blocked: false, ask: true, reason: `modifying protected path ${askPath} - confirm with the user` };
      }
    }

    for (const readonlyPath of config.readOnlyPaths) {
      if (matchPath(filePath, readonlyPath)) {
        return { blocked: true, ask: false, reason: `read-only path ${readonlyPath}` };
      }
    }
  }

  return { blocked: false, ask: false, reason: "" };
}
