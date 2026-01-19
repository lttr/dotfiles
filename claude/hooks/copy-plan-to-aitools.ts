#!/usr/bin/env node
/**
 * PostToolUse hook for ExitPlanMode
 * Copies plans to .aitools/plans/ with AITOOLS frontmatter.
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

  const plansDir = join(cwd, ".aitools", "plans");
  if (!existsSync(plansDir)) mkdirSync(plansDir, { recursive: true });

  // Use Claude's generated filename as slug
  const slug = filePath.split("/").pop().replace(".md", "");
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

main().catch(() => process.exit(0));
