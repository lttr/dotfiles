#!/usr/bin/env node

import { readFileSync, existsSync } from "fs";
import { execSync } from "child_process";
import { basename } from "path";

function execGit(command) {
  try {
    return execSync(command, {
      encoding: "utf8",
      timeout: 2000,
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();
  } catch {
    return null;
  }
}

function getGitInfo() {
  const branch = execGit("git rev-parse --abbrev-ref HEAD");
  if (!branch) return null;

  const changes = execGit("git status --porcelain");
  const changeCount = changes ? changes.split("\n").length : 0;
  
  return {
    branch,
    status: changeCount > 0 ? `±${changeCount}` : ""
  };
}

function createProgressBar(percentage) {
  const filledChars = Math.round((percentage / 100) * 5);
  const emptyChars = 5 - filledChars;
  return "█".repeat(filledChars) + "░".repeat(emptyChars);
}

function getContextWindowPercentage(inputData) {
  try {
    const { context, transcript_path } = inputData;
    
    // Use actual context data if available
    if (context?.used_tokens && context?.max_tokens) {
      const percentage = Math.round((context.used_tokens / context.max_tokens) * 100);
      return { bar: createProgressBar(percentage), percentage };
    }

    // HACK: Parse transcript for actual token usage data
    // This is not using a documented API - we're parsing Claude Code's internal
    // transcript file format to extract token usage from API responses.
    // This may break if the internal format changes.
    if (transcript_path && existsSync(transcript_path)) {
      const content = readFileSync(transcript_path, "utf8");
      const lines = content.trim().split("\n");
      
      // Find the most recent usage data by looking through recent lines
      for (let i = lines.length - 1; i >= Math.max(0, lines.length - 10); i--) {
        try {
          const entry = JSON.parse(lines[i]);
          if (entry.message?.usage) {
            const usage = entry.message.usage;
            const inputTokens = (usage.cache_read_input_tokens || 0) + 
                              (usage.cache_creation_input_tokens || 0) + 
                              (usage.input_tokens || 0);
            
            // For Sonnet 4, assume 200k input context limit
            const maxTokens = 200000;
            const percentage = Math.round((inputTokens / maxTokens) * 100);
            return { bar: createProgressBar(percentage), percentage };
          }
        } catch {
          continue;
        }
      }
    }

    // Final fallback to file size estimation
    if (transcript_path && existsSync(transcript_path)) {
      const contentLength = readFileSync(transcript_path, "utf8").length;
      const percentage = Math.min(Math.round((contentLength / 800000) * 100), 99);
      return { bar: createProgressBar(percentage), percentage };
    }

    return null;
  } catch {
    return null;
  }
}

function colorize(text, color) {
  return `${color}${text}\x1b[0m`;
}

function generateStatusLine(inputData) {
  const parts = [];
  const { workspace = {}, model = {}, output_style, version } = inputData;

  // Current directory
  if (workspace.current_dir) {
    parts.push(colorize(`/ ${basename(workspace.current_dir)}`, "\x1b[1;38;5;248m"));
  }

  // Git info
  const gitInfo = getGitInfo();
  if (gitInfo) {
    const gitText = `⌥ ${gitInfo.branch}${gitInfo.status ? ` ${gitInfo.status}` : ""}`;
    parts.push(colorize(gitText, "\x1b[38;5;242m"));
  }

  // Version
  if (version) {
    parts.push(colorize(`∇ ${version}`, "\x1b[90m"));
  }

  // Model
  parts.push(colorize(`※ ${model.display_name || "Claude"}`, "\x1b[90m"));

  // Output style
  if (output_style?.name) {
    parts.push(colorize(`◈ ${output_style.name}`, "\x1b[90m"));
  }

  // Context window
  const contextResult = getContextWindowPercentage(inputData);
  if (contextResult) {
    const color = contextResult.percentage > 75 ? "\x1b[38;5;208m" : "\x1b[90m";
    parts.push(colorize(contextResult.bar, color));
  }

  return parts.join(colorize(" | ", "\x1b[90m"));
}

function main() {
  if (process.stdin.isTTY) {
    console.log(colorize("❯ [Claude] No Input", "\x1b[31m"));
    return;
  }

  let input = "";
  process.stdin.setEncoding("utf8");

  process.stdin.on("readable", () => {
    let chunk;
    while ((chunk = process.stdin.read()) !== null) {
      input += chunk;
    }
  });

  process.stdin.on("end", () => {
    try {
      const inputData = JSON.parse(input);
      console.log(generateStatusLine(inputData));
    } catch {
      console.log(colorize("❯ [Claude] Unknown", "\x1b[31m"));
    }
  });
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
