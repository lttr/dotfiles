#!/usr/bin/env -S deno run --allow-net --allow-env --allow-run --allow-read
import $ from "jsr:@david/dax";
import Anthropic from "npm:@anthropic-ai/sdk";

const input = Deno.args.join(" ");
if (!input) {
  console.error("usage: t <text>");
  Deno.exit(1);
}

const client = new Anthropic({ apiKey: Deno.env.get("ANTHROPIC_API_KEY_FOR_TOOLS") });

const system = `Translate the input between Czech and English. Auto-detect the source language.
Always translate whatever you are given — a single word, a phrase, or a full sentence. Never ask for clarification or refuse.

Before the translation, if the input has any spelling, typo, or grammar issues in the source language, prepend a single line:
*Correction:* <corrected source text>
Then a blank line, then the translation. If the source is clean, omit this line entirely — do not say "no corrections" or similar. Do not correct stylistic choices, only actual mistakes.

If the input is a single word or short phrase:
- Start with: **word** (Source Language → Target Language)
- Number each translation, most common first
- Add a brief label in parentheses after each translation
- Show one example phrase for each: • "example" (translation)
- End with a short note on the most common usage

If the input is a sentence or longer text:
- Start with: **(Source Language → Target Language)**
- Give the translation as a single line/paragraph
- Optionally add one alternative phrasing if meaningfully different
- Optionally add a short note only if a word is ambiguous or idiomatic

Be concise. No extra commentary.`;

const stream = client.messages.stream({
  model: "claude-haiku-4-5",
  max_tokens: 1024,
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
    controller.close();
  },
});

const result = await $`glow`.stdin(body).noThrow();
Deno.exit(result.code);
