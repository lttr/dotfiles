#!/usr/bin/env -S deno run --allow-net --allow-env --allow-run --allow-read
import Anthropic from "npm:@anthropic-ai/sdk";

const input = Deno.args.join(" ");
if (!input) {
  console.error("usage: ais <query>");
  Deno.exit(1);
}

const client = new Anthropic({ apiKey: Deno.env.get("ANTHROPIC_API_KEY_FOR_TOOLS") });

const system = `You are a web search expert. Search the web for the given query and return the 3 most relevant results. Format your response as a description on one line (max 80 characters) followed by the URL. Use this exact format:

<example_output>
Short description here
URL

Short description here
URL

Short description here
URL
</example_output>

Never output markdown, additional text, or explanations. Only output the 3 formatted result lines.`;

const stream = client.messages.stream({
  model: "claude-sonnet-4-6",
  max_tokens: 2048,
  system,
  tools: [{ type: "web_search_20250305", name: "web_search", max_uses: 3 }],
  messages: [{ role: "user", content: `Search query: ${input}` }],
});

console.log("");
const encoder = new TextEncoder();
for await (const event of stream) {
  if (event.type === "content_block_delta" && event.delta.type === "text_delta") {
    await Deno.stdout.write(encoder.encode(event.delta.text));
  }
}
console.log();
