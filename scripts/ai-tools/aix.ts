#!/usr/bin/env -S deno run --allow-net --allow-env --allow-run --allow-read
import $ from "jsr:@david/dax";
import Anthropic from "npm:@anthropic-ai/sdk";

const input = Deno.args.join(" ");
if (!input) {
  console.error("usage: aix <task>");
  Deno.exit(1);
}

const client = new Anthropic({ apiKey: Deno.env.get("ANTHROPIC_API_KEY_FOR_TOOLS") });

const system = `You are a command line expert. Given a task, respond with a oneliner, that can
be executed in Bash shell and would satisfy task instructions. I value readable
output, long variant of arguments. Prefer fd (fd-find) over find for file searching and rg (ripgrep) over grep for text searching.

A script reads your reply: it prints the first line and pastes the second line
into the user's shell, so reply with exactly two plain-text lines and nothing
else (no code fences, notes or blank lines). The first line explains the
command, with each part in brackets followed by what it does, as in the example.
The second line is the command.
<example>
List directory contents [ls -l] a long listing format [ls -t] sort by modification time, newest first
ls -lt
</example>`;

const response = await client.messages.create({
  model: "claude-haiku-5-5",
  max_tokens: 4096,
  output_config: { effort: "low" },
  system,
  messages: [{ role: "user", content: `Task: ${input}` }],
});

const text = response.content
  .filter((b): b is Anthropic.TextBlock => b.type === "text")
  .map((b) => b.text)
  .join("");

const lines = text.split("\n").filter((l) => l.trim());

console.log("");
if (lines.length >= 2) {
  console.log(`\x1b[2;37m${lines[0]}\x1b[0m`);
  const command = lines[1];
  const stream = new Blob([command]).stream();
  await $`wl-copy`.stdin(stream);
  await $`wtype -M ctrl -M shift -k v -m ctrl -m shift`;
} else {
  console.log(text);
}
