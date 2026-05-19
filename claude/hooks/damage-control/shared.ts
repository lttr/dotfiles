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
    return { trustedPackages: [], bashToolPatterns: [], allowedPaths: [], zeroAccessPaths: [], readOnlyPaths: [], noDeletePaths: [] };
  }

  const content = readFileSync(configPath, "utf-8");
  const config = JSON.parse(content) as Partial<Config>;

  return {
    trustedPackages: config.trustedPackages || [],
    bashToolPatterns: config.bashToolPatterns || [],
    allowedPaths: config.allowedPaths || [],
    zeroAccessPaths: config.zeroAccessPaths || [],
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
// Package-install / runner commands match `ask: true` patterns in
// patterns.json (reason "verify name"). Once the user approves an install,
// the PostToolUse hook records its package names here, and the PreToolUse
// hook auto-allows them next time instead of asking again.

const LEARNED_PACKAGES_FILE = join(homedir(), ".claude", "custom-learned-packages.json");

// Matched against the START of a command segment only - so install strings
// embedded in echo/script arguments are not mistaken for real installs.
const INSTALL_HEAD_RE =
  /^(?:(?:npm|pnpm|yarn|bun)\s+(?:add|i|install)|vp\s+(?:add|install)|pip3?\s+install|cargo\s+(?:add|install)|gem\s+install|go\s+(?:install|get)|deno\s+(?:add|install)|brew\s+install)\b/;
const RUNNER_HEAD_RE = /^(?:(?:npx|pnpx|vpx|bunx)|(?:pnpm|vp)\s+dlx)\b/;

const PACKAGE_VERBS = new Set([
  "npm", "pnpm", "yarn", "bun", "vp", "pip", "pip3", "cargo", "gem", "go", "deno", "brew",
  "npx", "pnpx", "vpx", "bunx",
  "add", "i", "install", "dlx", "get",
]);

// A valid package name: optional @scope, then alphanumerics plus . _ - /
// (covers npm scoped names, pip names, and go module paths). Rejects tokens
// carrying quotes, commas, brackets etc. - i.e. install strings used as data.
const VALID_PACKAGE_RE = /^@?[a-z0-9][a-z0-9._/-]*$/i;

/**
 * Split a command into top-level segments, ignoring separators that appear
 * inside quotes (so install strings embedded in script arguments are not
 * mistaken for real commands). Strips leading sudo / VAR=val prefixes.
 */
function commandSegments(command: string): string[] {
  const raw: string[] = [];
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
  return raw
    .map((s) => s.trim().replace(/^(?:(?:sudo|command|\w+=\S*)\s+)*/, "").trim())
    .filter(Boolean);
}

/** True if a segment begins with an install command. */
function isInstallSegment(segment: string): boolean {
  return INSTALL_HEAD_RE.test(segment);
}

/** True if a segment begins with a download-and-run (npx/dlx) command. */
function isRunnerSegment(segment: string): boolean {
  return RUNNER_HEAD_RE.test(segment);
}

/** True if the command installs packages or downloads-and-runs one. */
export function isPackageCommand(command: string): boolean {
  return commandSegments(command).some((s) => isInstallSegment(s) || isRunnerSegment(s));
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
 * Only segments that BEGIN with a package command are parsed.
 */
export function extractPackages(command: string): string[] {
  const pkgs: string[] = [];
  for (const segment of commandSegments(command)) {
    const isRunner = isRunnerSegment(segment);
    if (!isRunner && !isInstallSegment(segment)) continue;
    for (const tok of segment.split(/\s+/)) {
      if (/^&?\d*[<>]/.test(tok)) break;   // redirection (>, 2>&1, 1>f, &>) - rest is not packages
      if (PACKAGE_VERBS.has(tok)) continue;
      if (tok.startsWith("-")) continue;   // flags
      if (/^[./~]/.test(tok)) continue;    // local paths
      const name = normalizePackageName(tok);
      if (!VALID_PACKAGE_RE.test(name)) continue;
      pkgs.push(name);
      if (isRunner) break;                 // runner: only the first token is a package
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
  config: Config
): { blocked: boolean; reason: string } {
  // Check allowlist first - these paths are always permitted
  for (const allowedPath of config.allowedPaths) {
    if (matchPath(filePath, allowedPath)) {
      return { blocked: false, reason: "" };
    }
  }

  for (const zeroPath of config.zeroAccessPaths) {
    if (matchPath(filePath, zeroPath)) {
      return { blocked: true, reason: `zero-access path ${zeroPath} (no operations allowed)` };
    }
  }

  for (const readonlyPath of config.readOnlyPaths) {
    if (matchPath(filePath, readonlyPath)) {
      return { blocked: true, reason: `read-only path ${readonlyPath}` };
    }
  }

  return { blocked: false, reason: "" };
}
