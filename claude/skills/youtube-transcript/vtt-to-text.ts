/**
 * Convert VTT subtitle file to clean plain text.
 * Strips timestamps, metadata, HTML tags, and deduplicates overlapping lines.
 *
 * Usage: deno run vtt-to-text.ts <input.vtt> <output.txt>
 */

const [input, output] = Deno.args;
if (!input || !output) {
  console.error("Usage: deno run vtt-to-text.ts <input.vtt> <output.txt>");
  Deno.exit(1);
}

const raw = await Deno.readTextFile(input);
const seen = new Set<string>();
const lines: string[] = [];

for (const line of raw.split("\n")) {
  const trimmed = line.trim();

  // Skip metadata and timestamp lines
  if (
    !trimmed ||
    trimmed === "WEBVTT" ||
    trimmed.startsWith("Kind:") ||
    trimmed.startsWith("Language:") ||
    trimmed.startsWith("NOTE") ||
    trimmed.includes("-->") ||
    /^\d{2}:\d{2}/.test(trimmed)
  ) continue;

  // Strip HTML tags
  const clean = trimmed.replace(/<[^>]*>/g, "");
  if (!clean) continue;

  // Deduplicate
  if (seen.has(clean)) continue;
  seen.add(clean);
  lines.push(clean);
}

await Deno.writeTextFile(output, lines.join("\n") + "\n");
console.log(`${lines.length} lines written to ${output}`);
