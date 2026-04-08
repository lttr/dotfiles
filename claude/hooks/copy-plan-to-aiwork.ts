#!/usr/bin/env node
/**
 * PostToolUse hook for ExitPlanMode
 * Copies plans to .aiwork/{date}_{slug}/plan.md following aiwork protocol.
 * Reuses existing task folder if one matches today's date and slug keywords.
 */

import { existsSync, mkdirSync, readdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";

async function main() {
  const chunks = [];
  for await (const chunk of process.stdin) chunks.push(chunk);
  const input = JSON.parse(Buffer.concat(chunks).toString());

  const { filePath, plan } = input.tool_response ?? {};
  const { cwd } = input;
  if (!filePath || !plan || !cwd) process.exit(0);

  const aiworkDir = join(cwd, ".aiwork");
  const date = new Date().toISOString().slice(0, 10);
  const slug = slugFromHeading(plan) ?? slugFromPath(filePath);

  // Find existing task folder or create new one
  const taskDir = findTaskFolder(aiworkDir, date, slug) ?? join(aiworkDir, `${date}_${slug}`);
  if (!existsSync(taskDir)) mkdirSync(taskDir, { recursive: true });

  // Determine filename: plan.md, plan_2.md, plan_3.md, ...
  const planFile = nextPlanFilename(taskDir);
  const targetPath = join(taskDir, planFile);

  const content = plan.startsWith("---\n") ? ensureFrontmatter(plan, date) : addFrontmatter(plan, date);
  writeFileSync(targetPath, content);
}

/** Find an existing .aiwork/{date}_{slug}/ folder that matches */
function findTaskFolder(aiworkDir: string, date: string, slug: string): string | null {
  if (!existsSync(aiworkDir)) return null;

  const slugWords = slug.split("-").filter(w => w.length > 2);
  const entries = readdirSync(aiworkDir, { withFileTypes: true })
    .filter(e => e.isDirectory() && e.name.startsWith(date));

  // Prefer exact match, then keyword overlap
  for (const entry of entries) {
    const folderSlug = entry.name.replace(/^\d{4}-\d{2}-\d{2}_/, "");
    if (folderSlug === slug) return join(aiworkDir, entry.name);
  }

  for (const entry of entries) {
    const folderSlug = entry.name.replace(/^\d{4}-\d{2}-\d{2}_/, "");
    const folderWords = folderSlug.split("-");
    const overlap = slugWords.filter(w => folderWords.includes(w)).length;
    if (overlap >= Math.min(2, slugWords.length)) return join(aiworkDir, entry.name);
  }

  return null;
}

/** Find next available plan filename: plan.md, plan_2.md, plan_3.md, ... */
function nextPlanFilename(taskDir: string): string {
  if (!existsSync(join(taskDir, "plan.md"))) return "plan.md";
  let n = 2;
  while (existsSync(join(taskDir, `plan_${n}.md`))) n++;
  return `plan_${n}.md`;
}

function addFrontmatter(plan: string, date: string): string {
  return `---
created: ${date}
type: plan
status: active
---

${plan}`;
}

function ensureFrontmatter(plan: string, date: string): string {
  const endIdx = plan.indexOf("\n---\n", 4);
  if (endIdx === -1) return addFrontmatter(plan, date);

  let fm = plan.slice(4, endIdx);
  if (!fm.includes("created:")) fm = `created: ${date}\n${fm}`;
  if (!fm.includes("type:")) fm += "\ntype: plan";
  if (!fm.includes("status:")) fm += "\nstatus: active";

  return `---\n${fm}\n---\n${plan.slice(endIdx + 5)}`;
}

/** Extract slug from first # heading */
function slugFromHeading(plan: string): string | undefined {
  let text = plan;
  if (text.startsWith("---\n")) {
    const end = text.indexOf("\n---\n", 4);
    if (end !== -1) text = text.slice(end + 5);
  }
  const match = text.match(/^#\s+(.+)/m);
  if (!match) return undefined;
  return match[1]
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "")
    .slice(0, 40);
}

/** Fallback: use Claude's generated plan filename */
function slugFromPath(filePath: string): string {
  return filePath.split("/").pop()!.replace(".md", "");
}

main().catch(() => process.exit(0));
