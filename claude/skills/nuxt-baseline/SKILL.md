---
name: nuxt-baseline
description: Assess a Nuxt repo against the desired tooling baseline (Vite+/pnpm/Nixpacks) and migrate it there, committing each change as it lands. Use when the user wants to bring a Nuxt project up to standard tooling, audit its setup, modernize deps/toolchain, or says "nuxt baseline", "assess nuxt", "migrate to baseline".
allowed-tools: Read, Glob, Grep, Edit, Write, Bash, Task
argument-hint: [assess-only]
---

# Nuxt baseline

Bring a Nuxt repository to the **desired tooling baseline** below. Two phases:

1. **Assess** — gap-analyse the repo against each item in the baseline. Report
   what already conforms, what's missing, and what's outdated.
2. **Migrate** — close every gap, **committing each coherent change on its own**
   as you go (see Strategy). One logical change per commit, verified before the
   next.

If the user passes `assess-only`, stop after phase 1 and produce the gap report
without touching files.

## First, gather context

Before assessing, run these to ground yourself (use Bash):

- `pwd` and `git rev-parse --show-toplevel` — confirm repo root.
- `git status --short` — working tree state. **Refuse to start migrating with a
  dirty tree** — ask the user to commit or stash first, so each migration commit
  is isolated.
- `git log --oneline -10` — recent commits, to match commit granularity/style.

## Desired tooling baseline

This is the target state. For each item, prefer the **latest** of the named
line; pin concrete versions when you write them, but always resolve "latest"
fresh (e.g. `pnpm view <pkg> version`, `pnpm view <pkg> dist-tags`) rather than
trusting a number written here.

### Framework

- **Nuxt** on the latest minor of the v4 line (`nuxt@^4`).
- **Vue** on the latest minor of v3 (`vue@^3`), with `vue-router`.
- `vue-tsc` present for type-checking SFCs.
- Nuxt 4 default directory layout (`app/` dir, `app.vue` under it).

### Runtime

- **Node.js on the latest LTS** (resolve current LTS; Node 24 "Krypton" at time
  of writing). Pin it in **two** places that must agree:
  - `.node-version` with the full version (e.g. `24.15.0`).
  - the deploy config (for Nixpacks: `NIXPACKS_NODE_VERSION = '24'`).

### Package manager

- **pnpm, latest major** (currently v11). Pin via `packageManager` field in
  root `package.json` (e.g. `pnpm@11.x.y`).
- `pnpm-lock.yaml` committed.
- For a workspace: `pnpm-workspace.yaml` with a `packages:` list.
- pnpm 11 hard-errors on unreviewed dependency build scripts
  (`strictDepBuilds`). Every package that runs a postinstall build must be
  listed under `allowBuilds:` in `pnpm-workspace.yaml` with an explicit
  `true`/`false`. Drop any legacy `.npmrc` `enable-pre-post-scripts` /
  `node-linker` cruft that pnpm 11 no longer needs.

### Toolchain — Vite+ (`vp`)

The single dev/build/lint/format/test toolchain is **Vite+** (`vite-plus`,
the `vp` CLI). It replaces standalone prettier and stand-alone vitest runners.

- Root `package.json` has `vite-plus` (via catalog) as a devDep.
- A `vite.config.ts` exporting `defineConfig` from `"vite-plus"` with:
  - `staged` — pre-commit fixers, e.g. `{ "*": "vp check --fix" }`.
  - `run.tasks` — the verify pipeline (see Verify).
  - `lint` — oxc-backed lint plugins, categories, and rules.
  - `fmt` — formatter config (e.g. `semi: false`) + `ignorePatterns`.
- Build runs through `vp run -r build` (recurses workspace → `nuxi build`).
  Note `vp build` alone does NOT work for Nuxt — use `vp run build`.
- When Nuxt/Nitro don't yet know about Vite+, expect `pnpm-workspace.yaml`
  `catalog:` aliasing `vite`/`vitest` to the `@voidzero-dev/vite-plus-*`
  builds, plus `overrides` / `peerDependencyRules` to force transitive deps and
  silence peer-range errors. Tag each workaround with a DELETE-WHEN condition.

### Formatting & Linting

- **No standalone prettier.** Formatting is `vp check` / `vp fmt` driven by the
  `fmt` block in `vite.config.ts`.
- ESLint via `@nuxt/eslint` (flat `eslint.config.*`), kept for Vue/Nuxt-aware
  and type-aware rules that oxc doesn't cover.
- Lint severities are only **`error`** or **`off`** — never `warn`.
- `ignorePatterns` excludes generated dirs (`.nuxt`, `.output`, `dist`, `cache`,
  `node_modules`, minified assets, `pnpm-lock.yaml`).

### Verify gate

A single command runs the whole gate, each step independently cached by Vite+.
Model it as `run.tasks` in `vite.config.ts` with a `verify:all` that
`dependsOn` the steps, and a root `"verify"` script. Typical chain:

1. `verify:check` — format + lint (`vp check`)
2. `verify:lint` — full ESLint (`eslint .`)
3. `verify:typecheck` — `nuxi typecheck`
4. `verify:fallow` — dead-code / unused-export detection (`fallow`)
5. `verify:smoke` — dev-server smoke test
6. `verify:build` — `nuxi build`

Disable script-input caching under CI if it stalls the build
(`scripts: process.env.CI !== "true"`).

### Dead-code detection

- `fallow` as a devDep, configured via `.fallowrc.jsonc` (entries, ignore
  patterns, complexity `health` gates). Wired into the verify chain.

### TypeScript

- `nuxi typecheck` script.
- TypeScript reset: `@total-typescript/ts-reset` in devDeps + a `reset.d.ts`
  doing `import "@total-typescript/ts-reset"`.
- Project references handled by Nuxt's generated `tsconfig` setup.

### Deployment — Coolify + Nixpacks

If the deploy target is **Coolify** (or otherwise Nixpacks-built), commit a
`nixpacks.toml`:

- `providers = ["node"]`.
- `[variables] NIXPACKS_NODE_VERSION = '<lts major>'`.
- For a monorepo, `[phases.install] onlyIncludeFiles = [...]` listing root
  `package.json`, `pnpm-lock.yaml`, `pnpm-workspace.yaml`, and each workspace's
  `package.json`, so install caching keys only on manifest changes.
- pnpm 11 needs a current corepack — Nixpacks pins an old one that can't launch
  pnpm 11 (`ERR_VM_DYNAMIC_IMPORT_CALLBACK_MISSING`). Override the install cmds:
  `cmds = ["npm install -g corepack@latest && corepack enable", "pnpm i --frozen-lockfile"]`.
- A root `start` script (`node web/.output/server/index.mjs` for a `web/`
  workspace) that Nixpacks' start phase picks up.
- Auto-deploy on push to the default branch is configured in Coolify, not in
  the repo — note it but don't try to set it from here.

### Documentation

- `README.md` covering install, dev/start, the verify gate, and deployment.
- A license file if the project warrants one.

### Pre-commit hook

- `vp staged` runs as the pre-commit hook (auto-formats and `--fix`es staged
  files). After any `git commit`, re-Read files still held in context — on-disk
  contents may have changed.

## Migration strategy

Work in small, independently-verifiable commits. Order matters: foundational
changes (runtime, package manager) first, because later steps run under them.

0. **Gate.** Confirm clean working tree and you're on a feature branch (or
   create one). Run the existing verify/build once to capture a baseline.
1. **Plan.** From the gap report, build an ordered checklist of changes. Use
   the task tools to track it. Suggested order:
   1. Runtime — `.node-version` + deploy Node version (keep them equal).
   2. Package manager — `packageManager` field, regenerate `pnpm-lock.yaml`,
      add `allowBuilds`, drop stale `.npmrc`.
   3. Framework/deps — bump `nuxt`, `vue`, `vue-router`, `vue-tsc`,
      `@nuxt/eslint`, etc. to latest in-range; resolve each "latest" live.
   4. Toolchain — adopt/repair Vite+ config (`vite.config.ts`, catalog,
      overrides), scripts, pre-commit `vp staged`.
   5. Lint/format — fold rules into the `lint` block, remove prettier, fix any
      `warn` severities to `error`/`off`.
   6. Verify gate — `run.tasks` chain + root `verify` script.
   7. Dead-code — `fallow` + `.fallowrc.jsonc`.
   8. Deployment — `nixpacks.toml` (only if Coolify/Nixpacks target).
   9. Docs — README/license touch-ups.
2. **Per change, loop:**
   1. Make the one change.
   2. Run the narrowest relevant check (e.g. `pnpm install`, `vp run typecheck`,
      `vp run verify`) to prove it works.
   3. Re-Read any files the pre-commit hook may have rewritten.
   4. Commit it alone with a focused conventional-commit message
      (`chore:`, `build:`, `fix:`, `docs:`). One logical change per commit —
      mirror the granularity in the repo's history
      (e.g. "bump packageManager to pnpm@11", "override corepack version in
      nixpacks", "complete pnpm 11 migration").
   5. If a step can't be verified or breaks something you can't fix, stop and
      report rather than piling on.
3. **Finish.** Run the full `verify` gate once more, summarise what changed
   (commit list), and flag anything left for the user (e.g. enabling
   auto-deploy in Coolify, secrets, manual review of bumped majors).

Never batch unrelated changes into one commit. Never commit with the verify
gate red unless the user accepts a known, documented gap.
