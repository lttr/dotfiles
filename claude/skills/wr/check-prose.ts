#!/usr/bin/env node
/**
 * check-prose — heuristic prose linter for markdown.
 *
 * Reports findings at three levels so an agent (or human) can act on them:
 *   ERROR — mechanical violations, always fix (blacklist phrases, em-dash
 *           splices, emoji, exclamation marks)
 *   WARN  — readability heuristics and LLM tells, judge each (long sentences,
 *           oversized paragraphs, semicolon splices, negative parallelism,
 *           participle tails, staged reveals, echo runs, anaphora)
 *   INFO  — stats and weak hints (sentence-length distribution, passive voice,
 *           colon triples)
 *
 * Usage: check-prose.ts <file.md> [--json]
 *        ... | check-prose.ts [-] [--json]     (read from stdin)
 * Always exits 0 (except usage/io errors: 64) so agent harnesses don't render
 * findings as a command failure. Read the report to see the result.
 * Code blocks, inline code, URLs, and frontmatter are ignored.
 */

import { readFileSync, realpathSync } from "node:fs";
import { stdin } from "node:process";
import { fileURLToPath } from "node:url";

const BLACKLIST = [
  "load-bearing",
  "worth stating plainly",
  "the real tension",
  "here's the honest truth",
  "game-changer",
  "game changer",
  "seamless",
];

// Phrasal LLM tells. Reported as WARN, not ERROR: each has legitimate uses, so
// the agent judges rather than deletes on sight. Adapted from
// https://tools.simonwillison.net/llm-cliche-highlighter
const CLICHE_RES: { rule: string; re: RegExp; message: string }[] = [
  {
    rule: "negative-parallelism",
    re: /\bnot\s+(?:just|only|merely|simply)\s+[^.!?\n;]*?\bbut(?:\s+also)?\b|\b(?:it|this|that)(?:(?:['\u2019]s|\s+(?:is|was))\s+not|\s+(?:is|was)n['\u2019]t)\s+[^.!?\n,;\u2013\u2014]{1,60}[,;\u2013\u2014]\s*(?:it|this|that)(?:['\u2019]s|\s+(?:is|was))\b/gi,
    message: "negative parallelism: state what it is, without the foil",
  },
  {
    rule: "participle-tail",
    re: /,\s+(?:highlighting|underscoring|emphasizing|showcasing|reflecting|demonstrating|illustrating|signaling|solidifying|cementing|reinforcing|underlining)\s+(?:its|his|her|their|our|the|a|an|how|that|what|both)\b/gi,
    message: "participle tail: analysis bolted onto the sentence end",
  },
  {
    rule: "staged-reveal",
    re: /\bhere(?:['\u2019]s|\s+is)\s+(?:the|a|my|one)\s+(?:twist|thing|catch|kicker|rub|problem|first|second|third|next|real|best|worst|surprising|interesting|key|important)\b|(?:^|[.!?]\s+)Turns\s+out\b|\bit\s+turns\s+out\s+that\b|\bthe\s+punchline(?:\s+(?:is|was)\b|\s*[:?])/gi,
    message: "staged reveal: make the point instead of announcing it",
  },
];

// Structural tells, visible only across neighbouring sentences.
const COLON_TRIPLE_RE = /:\s+[^.!?;:\n]{2,40},\s+[^.!?;:\n]{2,40},\s+(?:and\s+|or\s+)?[^.!?;:\n]{2,40}(?=[.!?]|$)/g;
// Repeating a pronoun or article across sentences is ordinary prose, not anaphora.
const ANAPHORA_SKIP =
  /^(?:i|it|the|a|an|this|that|we|you|they|he|she|there|but|and|so|in|as|if|my|his|her|their|its|these|those|for|at|on|of|to|is|was)$/i;
const ECHO_GRAM_WORDS = 4;
const MIN_ECHO_SENTENCE_WORDS = 4;
const MIN_ANAPHORA_RUN = 3;

const MAX_SENTENCE_WORDS = 30;
const MAX_PARAGRAPH_SENTENCES = 6;
const MAX_PARAGRAPH_WORDS = 130;

// Flat prose reads monotone; the ratio floor sits below what ordinary varied
// prose produces, so only genuinely uniform drafts trip it.
const MIN_SENTENCES_FOR_SPREAD = 12;
const MIN_SPREAD_RATIO = 1.45;

// Abbreviation periods that must not end a sentence.
const ABBR_RE = /\b(e\.g|i\.e|etc|vs|cf|et al|approx|Mr|Mrs|Ms|Dr|St)\./g;

export type Level = "ERROR" | "WARN" | "INFO";
export interface Finding {
  level: Level;
  line: number;
  rule: string;
  message: string;
}

export function analyze(source: string): Finding[] {
  const findings: Finding[] = [];
  const lines = source.split("\n");

  // Build a per-line "prose" version with non-prose content masked out.
  let inFence = false;
  let inFrontmatter = false;
  const prose: string[] = lines.map((line, i) => {
    if (i === 0 && line.trim() === "---") {
      inFrontmatter = true;
      return "";
    }
    if (inFrontmatter) {
      if (line.trim() === "---") inFrontmatter = false;
      return "";
    }
    if (/^\s*(```|~~~)/.test(line)) {
      inFence = !inFence;
      return "";
    }
    if (inFence) return "";
    return line
      .replace(/`[^`]*`/g, " ")            // inline code
      .replace(/\]\([^)]*\)/g, "]( )")     // link targets
      .replace(/https?:\/\/\S+/g, " ");    // bare URLs
  });

  // Line-scoped checks
  prose.forEach((text, i) => {
    if (!text.trim()) return;
    const line = i + 1;
    const lower = text.toLowerCase();

    for (const phrase of BLACKLIST) {
      if (lower.includes(phrase)) {
        findings.push({ level: "ERROR", line, rule: "blacklist", message: `banned phrase "${phrase}"` });
      }
    }

    for (const { rule, re, message } of CLICHE_RES) {
      for (const m of text.matchAll(re)) {
        findings.push({ level: "WARN", line, rule, message: `${message}: "${snippet(m[0])}"` });
      }
    }

    for (const m of text.matchAll(/\w[^—]{0,30}—[^—]{0,30}\w|—/g)) {
      findings.push({
        level: "ERROR", line, rule: "em-dash",
        message: `em-dash splice: "${snippet(m[0])}" (use two sentences, a colon, or parentheses)`,
      });
    }
    if (/ -- /.test(text)) {
      findings.push({ level: "ERROR", line, rule: "em-dash", message: "double-hyphen splice ( -- )" });
    }

    if (/[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}]/u.test(text)) {
      findings.push({ level: "ERROR", line, rule: "emoji", message: "emoji in prose" });
    }

    if (/!(?!\[)/.test(text)) {
      findings.push({ level: "ERROR", line, rule: "exclamation", message: "exclamation mark" });
    }

    if (/;/.test(text)) {
      findings.push({ level: "WARN", line, rule: "semicolon", message: "semicolon splice: consider two sentences" });
    }

    for (const m of text.matchAll(/\b(is|are|was|were|been|being|be)\s+\w+ed\b/gi)) {
      findings.push({ level: "INFO", line, rule: "passive", message: `possible passive voice: "${m[0]}"` });
    }
  });

  // Paragraph- and sentence-scoped checks
  const paragraphs = collectParagraphs(prose);
  // Stats cover prose sentences only: list-item fragments would skew them.
  const proseLengths: number[] = [];

  for (const p of paragraphs) {
    const sentences = splitSentences(p.text);
    const pWords = wordCount(p.text);

    for (const s of sentences) {
      const w = wordCount(s);
      if (!p.isListItem) proseLengths.push(w);
      if (w > MAX_SENTENCE_WORDS) {
        findings.push({
          level: "WARN", line: p.line, rule: "long-sentence",
          message: `${w}-word sentence: "${snippet(s)}"`,
        });
      }
    }

    if (!p.isListItem) findings.push(...structuralFindings(p, sentences));

    if (!p.isListItem && (sentences.length > MAX_PARAGRAPH_SENTENCES || pWords > MAX_PARAGRAPH_WORDS)) {
      findings.push({
        level: "WARN", line: p.line, rule: "long-paragraph",
        message: `paragraph with ${sentences.length} sentences / ${pWords} words: consider splitting by topic`,
      });
    }
  }

  if (proseLengths.length > 0) {
    // Sentence length is right-skewed, so median and the p25-p75 range
    // describe a draft better than mean and max (both dominated by the tail).
    // q picks the value at fraction p of the sorted array, no interpolation.
    const a = [...proseLengths].sort((x, y) => x - y);
    const q = (p: number) => a[Math.floor(p * (a.length - 1))];
    const p25 = q(0.25), p75 = q(0.75);
    // spread = p75/p25 measures rhythm: ~1 means every sentence is the same
    // length. Guard against p25 = 0 (sentences of only non-word tokens).
    const spread = p25 > 0 ? p75 / p25 : 1;
    findings.push({
      level: "INFO", line: 0, rule: "stats",
      message: `${a.length} prose sentences, median ${q(0.5)}w, p25-p75 ${p25}-${p75}, longest ${a[a.length - 1]}`,
    });
    if (a.length >= MIN_SENTENCES_FOR_SPREAD && spread < MIN_SPREAD_RATIO) {
      findings.push({
        level: "WARN", line: 0, rule: "flat-rhythm",
        message: `sentence lengths are uniform (p75/p25 = ${spread.toFixed(2)}, want >= ${MIN_SPREAD_RATIO}): ` +
          `vary them, and check whether split sentences dropped their connectives`,
      });
    }
  }

  return findings.sort((a, b) => a.line - b.line);
}

interface Paragraph { line: number; text: string; isListItem: boolean }

// Tells that live in the shape of a run of sentences rather than in any single
// phrase: neighbours built on the same skeleton, neighbours opening on the same
// word, or a colon opening onto a tidy triple.
function structuralFindings(p: Paragraph, sentences: string[]): Finding[] {
  const out: Finding[] = [];

  // INFO, not WARN: in documentation most colon-triples are ordinary
  // enumerations, so this one is a hint rather than something to act on.
  for (const m of p.text.matchAll(COLON_TRIPLE_RE)) {
    out.push({
      level: "INFO", line: p.line, rule: "colon-triple",
      message: `colon into a triple: "${snippet(m[0])}"`,
    });
  }

  for (let i = 0; i + 1 < sentences.length; i++) {
    const shared = sharedGram(sentences[i], sentences[i + 1]);
    if (shared) {
      out.push({
        level: "WARN", line: p.line, rule: "echo-run",
        message: `consecutive sentences echo "${shared}": vary the shape`,
      });
      i += 1; // the pair is reported once, so don't re-report on the overlap
    }
  }

  const heads = sentences.map((s) => (s.match(/[A-Za-z'\u2019-]+/) ?? [""])[0].toLowerCase());
  let i = 0;
  while (i < heads.length) {
    let j = i;
    while (j + 1 < heads.length && heads[j + 1] === heads[i]) j += 1;
    const run = j - i + 1;
    if (run >= MIN_ANAPHORA_RUN && heads[i] && !ANAPHORA_SKIP.test(heads[i])) {
      out.push({
        level: "WARN", line: p.line, rule: "anaphora",
        message: `${run} sentences in a row open on "${heads[i]}"`,
      });
    }
    i = j + 1;
  }

  return out;
}

// The longest shared n-gram of two sentences, or null when they share none.
// Short sentences are skipped: two four-word fragments can match by accident.
function sharedGram(a: string, b: string): string | null {
  if (wordCount(a) < MIN_ECHO_SENTENCE_WORDS || wordCount(b) < MIN_ECHO_SENTENCE_WORDS) return null;
  const grams = (s: string): Set<string> => {
    const w = s.toLowerCase().match(/[a-z0-9'\u2019-]+/g) ?? [];
    const out = new Set<string>();
    for (let i = 0; i + ECHO_GRAM_WORDS <= w.length; i++) out.add(w.slice(i, i + ECHO_GRAM_WORDS).join(" "));
    return out;
  };
  const bg = grams(b);
  const common = [...grams(a)].filter((g) => bg.has(g));
  return common.sort((x, y) => y.length - x.length)[0] ?? null;
}

function collectParagraphs(prose: string[]): Paragraph[] {
  const out: Paragraph[] = [];
  let current: Paragraph | null = null;

  prose.forEach((raw, i) => {
    const text = raw.trim();
    const isBreak = text === "" || /^#{1,6}\s/.test(text) || /^([-*_]\s*){3,}$/.test(text) || /^\|/.test(text) || /^>/.test(text);
    const isListItem = /^([-*+]|\d+[.)])\s/.test(text);

    if (isBreak) {
      if (current) out.push(current);
      current = null;
    } else if (isListItem) {
      if (current) out.push(current);
      out.push({ line: i + 1, text: text.replace(/^([-*+]|\d+[.)])\s/, ""), isListItem: true });
      current = null;
    } else if (current) {
      current.text += " " + text;
    } else {
      current = { line: i + 1, text, isListItem: false };
    }
  });
  if (current) out.push(current);
  return out;
}

// Split text into sentences at ., !, or ? followed by whitespace. Splitting
// naively would cut "e.g. foo" in two, inflating the sentence count and
// deflating every length stat. So first swap abbreviation periods for a NUL
// sentinel (a character that never occurs in prose), split, then swap back.
export function splitSentences(text: string): string[] {
  return text
    .replace(ABBR_RE, (m) => m.replace(/\./g, "\u0000"))
    .split(/(?<=[.!?])\s+/)
    .map((s) => s.replaceAll("\u0000", ".").trim())
    .filter((s) => wordCount(s) > 0);
}

function wordCount(s: string): number {
  return s.split(/\s+/).filter((w) => /\w/.test(w)).length;
}

function snippet(s: string, max = 60): string {
  const t = s.trim().replace(/\s+/g, " ");
  return t.length > max ? t.slice(0, max) + "…" : t;
}

async function readStdin(): Promise<string> {
  const chunks: Buffer[] = [];
  for await (const chunk of stdin) chunks.push(chunk as Buffer);
  return Buffer.concat(chunks).toString("utf8");
}

async function main() {
  const args = process.argv.slice(2);
  const json = args.includes("--json");
  const file = args.find((a) => !a.startsWith("--")) ?? "-";

  let source: string;
  if (file === "-") {
    if (stdin.isTTY) {
      console.error("usage: check-prose.ts <file.md> [--json], or pipe text on stdin");
      process.exit(64);
    }
    source = await readStdin();
  } else {
    try {
      source = readFileSync(file, "utf8");
    } catch (e) {
      console.error(`cannot read ${file}: ${e instanceof Error ? e.message : e}`);
      process.exit(64);
    }
  }

  const findings = analyze(source!);
  const errors = findings.filter((f) => f.level === "ERROR");
  const warns = findings.filter((f) => f.level === "WARN");
  const infos = findings.filter((f) => f.level === "INFO");

  if (json) {
    console.log(JSON.stringify({ file, errors, warns, infos }, null, 2));
  } else {
    for (const f of findings) {
      console.log(`${f.level.padEnd(5)} ${f.line ? `L${f.line}` : "-"} [${f.rule}] ${f.message}`);
    }
    if (findings.length === 0) console.log("clean");
    else console.log(`\n${errors.length} error(s) — always fix. ${warns.length} warning(s) — fix if genuinely hard to read. ${infos.length} info.`);
  }

  process.exit(0);
}

// Run main() only when this file is executed as a script, not when imported.
// Compare fully resolved paths: a basename match would break under symlinks
// or after a rename, and the script would then silently exit without checking
// anything.
function invokedDirectly(): boolean {
  if (!process.argv[1]) return false;
  try {
    return realpathSync(fileURLToPath(import.meta.url)) === realpathSync(process.argv[1]);
  } catch {
    return false;
  }
}
if (invokedDirectly()) main();
