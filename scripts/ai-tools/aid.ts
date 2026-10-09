#!/usr/bin/env -S deno run --allow-net --allow-env --allow-run --allow-read
import $ from "jsr:@david/dax";
import Anthropic from "npm:@anthropic-ai/sdk";

const input = Deno.args.join(" ");
if (!input) {
  console.error("usage: aid <text>");
  Deno.exit(1);
}

const client = new Anthropic({ apiKey: Deno.env.get("ANTHROPIC_API_KEY_FOR_TOOLS") });

const system = `Explain the word like a dictionary, no more than 3 sentences or bullet points. Use the same language as the input is, english is the default.`;

const stream = client.messages.stream({
  model: "claude-haiku-5-5",
  max_tokens: 4096,
  output_config: { effort: "low" },
  system,
  messages: [{ role: "user", content: `<input>${input}</input>` }],
});

const encoder = new TextEncoder();
const body = new ReadableStream<Uint8Array>({
  async start(controller) {
    for await (const event of stream) {
      if (event.type === "content_block_delta" && event.delta.type === "text_delta") {
        controller.enqueue(encoder.encode(event.delta.text));
      }
    }
    const { stop_reason } = await stream.finalMessage();
    if (stop_reason === "refusal" || stop_reason === "max_tokens") {
      controller.enqueue(encoder.encode(`\n\n*(stopped: ${stop_reason})*\n`));
    }
    controller.close();
  },
});

const result = await $`glow`.stdin(body).noThrow();
Deno.exit(result.code);
