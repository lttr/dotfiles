#!/usr/bin/env node
/**
 * PostToolUse hook for ExitPlanMode
 * Copies plans to .aiwork/plans/ with frontmatter.
 */

import { existsSync, mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";

async function main() {
  const chunks = [];
  for await (const chunk of process.stdin) chunks.push(chunk);
  const input = JSON.parse(Buffer.concat(chunks).toString());

  const { filePath, plan } = input.tool_response ?? {};
  const { cwd } = input;
  if (!filePath || !plan || !cwd) process.exit(0);

  const plansDir = join(cwd, ".aiwork", "plans");
  if (!existsSync(plansDir)) mkdirSync(plansDir, { recursive: true });

  const slug = slugFromHeading(plan) ?? slugFromPath(filePath);
  const date = new Date().toISOString().slice(0, 10);
  const targetPath = join(plansDir, `${date}_${slug}.md`);

  // Add frontmatter if missing, preserve if exists
  const content = plan.startsWith("---\n") ? ensureFrontmatter(plan, date) : addFrontmatter(plan, date);
  writeFileSync(targetPath, content);
}

function addFrontmatter(plan, date) {
  return `---
created: ${date}
type: plan
status: active
---

${plan}`;
}

function ensureFrontmatter(plan, date) {
  const endIdx = plan.indexOf("\n---\n", 4);
  if (endIdx === -1) return addFrontmatter(plan, date);

  let fm = plan.slice(4, endIdx);
  if (!fm.includes("created:")) fm = `created: ${date}\n${fm}`;
  if (!fm.includes("type:")) fm += "\ntype: plan";
  if (!fm.includes("status:")) fm += "\nstatus: active";

  return `---\n${fm}\n---\n${plan.slice(endIdx + 5)}`;
}

/** Extract slug from first # heading, e.g. "# My Plan Title" → "my-plan-title" */
function slugFromHeading(plan: string): string | undefined {
  // Skip frontmatter if present
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
