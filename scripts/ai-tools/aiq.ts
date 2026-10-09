#!/usr/bin/env -S deno run --allow-net --allow-env --allow-run --allow-read
import $ from "jsr:@david/dax";
import Anthropic from "npm:@anthropic-ai/sdk";

const piped = Deno.stdin.isTerminal() ? "" : (await new Response(Deno.stdin.readable).text()).trim();
const question = [Deno.args.join(" "), piped].filter(Boolean).join("\n\n");
if (!question) {
  console.error("usage: aiq <question>  (or pipe text in: cat file | aiq <question>)");
  Deno.exit(1);
}

const client = new Anthropic({ apiKey: Deno.env.get("ANTHROPIC_API_KEY_FOR_TOOLS") });

const today = new Date().toISOString().slice(0, 10);
const system = `You answer quick questions from a developer in their terminal. The answer is rendered as markdown, so use formatting where it helps (lists, code blocks), but keep it light.

Lead with the answer, then add only the detail that helps. Keep it as short as the question allows. Answer in the language of the question.

Search the web when the answer depends on recent events, current versions or prices, or facts you are unsure about. Today is ${today}.`;

const stream = client.messages.stream({
  model: "claude-haiku-5-5",
  max_tokens: 16000,
  output_config: { effort: "low" },
  system,
  tools: [{ type: "web_search_20260209", name: "web_search", max_uses: 3 }],
  messages: [{ role: "user", content: question }],
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
