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
output, long variant of arguments. DO output 2 lines: first line with short
explanation of its arguments and second line with the oneliner command. Never
output markdown. Prefer fd (fd-find) over find for file searching and rg (ripgrep) over grep for text searching.
<example>
List directory contents [ls -l] a long listing format [ls -t] sort by modification time, newest first
ls -lt
</example>`;

const response = await client.messages.create({
  model: "claude-sonnet-4-6",
  max_tokens: 1024,
  system,
  messages: [{ role: "user", content: `Task: ${input}` }],
});

const text = response.content
  .filter((b): b is { type: "text"; text: string } => b.type === "text")
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
