#!/usr/bin/env -S deno run --allow-net --allow-env --allow-run --allow-read
import $ from "jsr:@david/dax";
import Anthropic from "npm:@anthropic-ai/sdk";

const home = Deno.env.get("HOME");
const gstMd = await Deno.readTextFile(`${home}/dotfiles/claude/commands/gst.md`);
const status = await $`git status`.text();
const diff = await $`git diff`.text();

const system = `${gstMd}

Do not use markdown formatting in your response. Use plain text only.

Wrap parts of the output in these tags so the renderer can color them:
- [branch]...[/branch] for the branch name
- [section]...[/section] for section headers like "Modified:", "Untracked:"
- [count]...[/count] for the final count line

Do not output any other tags or escape sequences.`;

const userMsg = `Current git status:
${status}

Current git diff:
${diff}`;

const client = new Anthropic({ apiKey: Deno.env.get("ANTHROPIC_API_KEY_FOR_TOOLS") });

const response = await client.messages.create({
  model: "claude-sonnet-4-6",
  max_tokens: 4096,
  system,
  messages: [{ role: "user", content: userMsg }],
});

const text = response.content
  .filter((b): b is { type: "text"; text: string } => b.type === "text")
  .map((b) => b.text)
  .join("");

const colors = { branch: "\x1b[32m", section: "\x1b[34m", count: "\x1b[33m" };
const reset = "\x1b[0m";

const out = text.replace(
  /\[(branch|section|count)\](.*?)\[\/\1\]/gs,
  (_, tag: keyof typeof colors, body) => `${colors[tag]}${body}${reset}`,
);

console.log(out);
