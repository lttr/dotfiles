#!/usr/bin/env node
/**
 * Tests for package-command detection and the ask/block precedence rules.
 *
 * Run: node --test claude/hooks/damage-control/shared.test.ts
 */

import { test } from "node:test";
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

import { isPackageCommand, extractPackages, normalizePackageName } from "./shared.ts";

const HOOK = join(dirname(fileURLToPath(import.meta.url)), "bash-tool-damage-control.ts");

// The command that started all this: a trusted runner behind `timeout`, in a
// chain of unrelated segments.
const REAL_WORLD =
  'cd layers/experiments && pnpm run dev:prepare >/dev/null 2>&1 && cd playground ' +
  '&& timeout 300 npx vue-tsc -b --noEmit 2>&1 | grep -v "^npm warn" | head -20; ' +
  'echo "exit: ${PIPESTATUS[0]}"';

test("finds invocations behind wrappers", () => {
  const cases: [string, string[]][] = [
    ["npx vue-tsc -b", ["vue-tsc"]],
    ["timeout 300 npx vue-tsc -b --noEmit", ["vue-tsc"]],
    ["timeout -k 5 300 npx vue-tsc", ["vue-tsc"]],
    ["nice -n 10 npx vue-tsc", ["vue-tsc"]],
    ["env FOO=1 npx vue-tsc", ["vue-tsc"]],
    ["sudo -u root npx vue-tsc", ["vue-tsc"]],
    ["npx vue-tsc 2>&1 | grep -v warn", ["vue-tsc"]],
    ["xargs npx vue-tsc", ["vue-tsc"]],
    [REAL_WORLD, ["vue-tsc"]],
  ];
  for (const [cmd, expected] of cases) {
    assert.equal(isPackageCommand(cmd), true, cmd);
    assert.deepEqual(extractPackages(cmd), expected, cmd);
  }
});

test("finds installers", () => {
  const cases: [string, string[]][] = [
    ["npm install lodash", ["lodash"]],
    ["sudo npm i -D vitest", ["vitest"]],
    ["pnpm add @scope/pkg@1.2.3", ["@scope/pkg"]],
    ["pnpm add -D vitest happy-dom", ["vitest", "happy-dom"]],
    ["pnpm dlx prettier --write .", ["prettier"]],
    ["vp dlx nuxi init", ["nuxi"]],
    ["pip3 install requests==2.31.0", ["requests"]],
    ["go install golang.org/x/tools/gopls@latest", ["golang.org/x/tools/gopls"]],
  ];
  for (const [cmd, expected] of cases) {
    assert.equal(isPackageCommand(cmd), true, cmd);
    assert.deepEqual(extractPackages(cmd), expected, cmd);
  }
});

test("bare installs name no packages", () => {
  for (const cmd of ["vp install", "pnpm install --frozen-lockfile", "npm install"]) {
    assert.equal(isPackageCommand(cmd), true, cmd);
    assert.deepEqual(extractPackages(cmd), [], cmd);
  }
});

test("prose mentioning a runner reads as an invocation, which is harmless", () => {
  // Splitting is only quote-aware at token boundaries, so a mention in the
  // middle of a message still matches. Documented rather than fixed: the
  // result only decides whether a package-name prompt is raised, never a
  // block, and tokens carrying quotes are rejected as names anyway.
  assert.equal(isPackageCommand('git commit -m "ran npx foo"'), true);
  // `foo"` carries a quote, so it is rejected as a package name.
  assert.deepEqual(extractPackages('git commit -m "ran npx foo"'), []);

  // A quote sitting against the token does hide it.
  assert.equal(isPackageCommand("grep -r 'npm install evil' ."), false);
});

test("non-package commands are left alone", () => {
  for (const cmd of ["pnpm run dev:prepare", "npm run build && npm test", "ls -la"]) {
    assert.equal(isPackageCommand(cmd), false, cmd);
  }
});

test("normalizePackageName strips versions and extras", () => {
  assert.equal(normalizePackageName("lodash@4.17.21"), "lodash");
  assert.equal(normalizePackageName("@nuxt/kit@3.0.0"), "@nuxt/kit");
  assert.equal(normalizePackageName("requests[security]"), "requests");
});

// ---------------------------------------------------------------------------
// End to end, against the real patterns.json
// ---------------------------------------------------------------------------

function runHook(command: string): "allow" | "ask" | "block" {
  try {
    const out = execFileSync("node", [HOOK], {
      input: JSON.stringify({ tool_name: "Bash", tool_input: { command } }),
      encoding: "utf-8",
    });
    return out.includes('"ask"') ? "ask" : "allow";
  } catch {
    return "block";
  }
}

test("e2e: trusted packages do not prompt", () => {
  assert.equal(runHook(REAL_WORLD), "allow");
  assert.equal(runHook("timeout 300 npx vue-tsc -b --noEmit"), "allow");
  assert.equal(runHook("npx prettier --write ."), "allow");
  assert.equal(runHook("npm install eslint"), "allow");
});

test("e2e: unknown packages still prompt", () => {
  assert.equal(runHook("npx some-unknown-package-xyz"), "ask");
  assert.equal(runHook("timeout 300 npx some-unknown-package-xyz"), "ask");
  assert.equal(runHook("pnpm add -D vitest"), "ask");
  assert.equal(runHook("yarn install left-pad"), "ask");
});

test("e2e: quoted prose about installs does not prompt", () => {
  assert.equal(runHook("grep -r 'npm install evil' ."), "allow");
  assert.equal(runHook('git commit -m "ran npx foo"'), "allow");
});

test("e2e: a trusted package cannot smuggle a blocked command past the firewall", () => {
  // Regression: the trusted-package check used to return early, skipping every
  // block pattern and path check that followed it.
  assert.equal(runHook("npm install eslint && rm -rf /home/lukas/notes"), "block");
  assert.equal(runHook("npx vue-tsc; sudo rm -rf /"), "block");
  assert.equal(runHook("npm install eslint && cat .env"), "block");
  assert.equal(runHook("npx vue-tsc && cat ~/.ssh/id_rsa"), "block");
});

test("e2e: a suppressed package ask does not suppress unrelated asks", () => {
  assert.equal(runHook("npx vue-tsc && git push --force-with-lease"), "ask");
  assert.equal(runHook("npm install eslint && git stash drop"), "ask");
});

test("e2e: blocks win over asks whatever the pattern order", () => {
  assert.equal(runHook("git stash drop && rm -rf /home/lukas/notes"), "block");
  assert.equal(runHook("chmod 777 x && sudo rm -rf /"), "block");
});
