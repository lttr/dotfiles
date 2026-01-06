#!/usr/bin/env node
/**
 * Shared utilities for Claude Code damage control hooks
 *
 * Adapted based on: https://github.com/disler/claude-code-damage-control
 */

import { existsSync, readFileSync } from "node:fs";
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
  bashToolPatterns: Pattern[];
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
    return { bashToolPatterns: [], zeroAccessPaths: [], readOnlyPaths: [], noDeletePaths: [] };
  }

  const content = readFileSync(configPath, "utf-8");
  const config = JSON.parse(content) as Partial<Config>;

  return {
    bashToolPatterns: config.bashToolPatterns || [],
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
// PATH CHECKING (for Edit/Write tools)
// =============================================================================

export function checkFilePath(
  filePath: string,
  config: Config
): { blocked: boolean; reason: string } {
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
