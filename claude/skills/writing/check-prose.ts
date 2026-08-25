#!/usr/bin/env node
/**
 * check-prose — heuristic prose linter for markdown.
 *
 * Reports findings at three levels so an agent (or human) can act on them:
 *   ERROR — mechanical violations, always fix (blacklist phrases, em-dash
 *           splices, emoji, exclamation marks)
 *   WARN  — readability heuristics, judge each (long sentences, oversized
 *           paragraphs, semicolon splices)
 *   INFO  — stats and weak hints (avg sentence length, passive voice)
 *
 * Usage: check-prose.ts <file.md> [--json]
 *        ... | check-prose.ts [-] [--json]     (read from stdin)
 * Always exits 0 (except usage/io errors: 64) so agent harnesses don't render
 * findings as a command failure. Read the report to see the result.
 * Code blocks, inline code, URLs, and frontmatter are ignored.
 */

import { readFileSync } from "node:fs";
import { stdin } from "node:process";

const BLACKLIST = [
  "load-bearing",
  "worth stating plainly",
  "the real tension",
  "here's the honest truth",
  "game-changer",
  "game changer",
  "seamless",
];

const MAX_SENTENCE_WORDS = 35;
const MAX_PARAGRAPH_SENTENCES = 6;
const MAX_PARAGRAPH_WORDS = 130;

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
  const sentenceLengths: number[] = [];

  for (const p of paragraphs) {
    const sentences = p.text.split(/(?<=[.!?])\s+/).filter((s) => wordCount(s) > 0);
    const pWords = wordCount(p.text);

    for (const s of sentences) {
      const w = wordCount(s);
      sentenceLengths.push(w);
      if (w > MAX_SENTENCE_WORDS) {
        findings.push({
          level: "WARN", line: p.line, rule: "long-sentence",
          message: `${w}-word sentence: "${snippet(s)}"`,
        });
      }
    }

    if (!p.isListItem && (sentences.length > MAX_PARAGRAPH_SENTENCES || pWords > MAX_PARAGRAPH_WORDS)) {
      findings.push({
        level: "WARN", line: p.line, rule: "long-paragraph",
        message: `paragraph with ${sentences.length} sentences / ${pWords} words: consider splitting by topic`,
      });
    }
  }

  if (sentenceLengths.length > 0) {
    const avg = sentenceLengths.reduce((a, b) => a + b, 0) / sentenceLengths.length;
    const max = Math.max(...sentenceLengths);
    findings.push({
      level: "INFO", line: 0, rule: "stats",
      message: `${sentenceLengths.length} sentences, avg ${avg.toFixed(1)} words, longest ${max}`,
    });
  }

  return findings.sort((a, b) => a.line - b.line);
}

interface Paragraph { line: number; text: string; isListItem: boolean }

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

const invokedDirectly = process.argv[1] && import.meta.url.endsWith(process.argv[1].split("/").pop()!);
if (invokedDirectly) main();
