#!/usr/bin/env -S deno run --allow-net --allow-env --allow-run --allow-read
import $ from "jsr:@david/dax";
import Anthropic from "npm:@anthropic-ai/sdk";

const status = await $`git status`.text();
const diff = await $`git diff`.text();

const system = `Display a clean, scannable git status.

Parse the git status output and format it as:

master (up to date with origin/master)

Modified:
  bootstrap/configuration/symlinks.ts :: <one-line summary of the changes in this file>
  claude/settings.json :: <one-line summary of the changes in this file>

Untracked:
  claude/commands/ :: <one-line summary of what this directory contains>

2 modified, 1 untracked

Keep output compact and easy to scan at a glance.

Your output is printed raw to a terminal, so use plain text with no markdown.
The only markup is these tags, which the renderer turns into colors:
- [branch]...[/branch] for the branch name
- [section]...[/section] for section headers like "Modified:", "Untracked:"
- [count]...[/count] for the final count line`;

const userMsg = `Current git status:
${status}

Current git diff:
${diff}`;

const client = new Anthropic({ apiKey: Deno.env.get("ANTHROPIC_API_KEY_FOR_TOOLS") });

const response = await client.messages.create({
  model: "claude-haiku-5-5",
  max_tokens: 8192,
  output_config: { effort: "low" },
  system,
  messages: [{ role: "user", content: userMsg }],
});

const text = response.content
  .filter((b): b is Anthropic.TextBlock => b.type === "text")
  .map((b) => b.text)
  .join("");

const colors = { branch: "\x1b[32m", section: "\x1b[34m", count: "\x1b[33m" };
const reset = "\x1b[0m";

const out = text.replace(
  /\[(branch|section|count)\](.*?)\[\/\1\]/gs,
  (_, tag: keyof typeof colors, body) => `${colors[tag]}${body}${reset}`,
);

console.log(out);
if (response.stop_reason === "refusal" || response.stop_reason === "max_tokens") {
  console.log(`(stopped: ${response.stop_reason})`);
}
