---
allowed-tools: Read, Glob, Grep, Bash(git:*), Bash(ls:*), Bash(wc:*), Bash(cat:*), Bash(head:*), Bash(find:*), Bash(fd:*), Bash(du:*), Bash(cloc:*), Task
description: Assess a repository's health and sensible defaults for a Nuxt 4 project
---

## Context

- Current working directory: !`pwd`
- Git repository: !`git rev-parse --show-toplevel 2>/dev/null || echo "Not a git repository"`
- Recent commits: !`git log --oneline -5 2>/dev/null || echo "No git history"`

## Your task

Perform a comprehensive assessment of the current repository. Focus on Nuxt 4
and Vite based project aspects.

## Assessment Questions

### Framework

- Is the project using Nuxt version 4 or newer?
- Is there `vue`, `vue-router`, `typescript`, `vue-tsc` in dependencies?

### Tooling

- Is there a configuration file specifying runtime version? (like `.node-version`, and in CI/CD pipeline config)
- If the project is using NodeJS, is it the current LTS version?
- Is there a `packageManager` field in `package.json`?
- Does the project use `pnpm`?
- Is there a `pnpm-lock.yaml` file?
- Is there config for ignoring cerain files from being formatted? (`.prettierignore` contains `.nuxt` and `.output`)

### Project Structure

- Does the project use Nuxt 4 default directory structure? (like `app` folder)

### Code Formatting

- Is the project using automattic formatting tool? Like having `prettier` as a dev dependency?
- Is there a "script" for formatting code? Like `"format": "prettier --list-different --write ."`
- Is there config for formatting code? (`.prettierrc`, `prettier` field in `package.json`, `.oxfmtrc.json`)

### Linting

- Is the project using automattic linting tool? Like having `eslint` and/or `oxlint` as a dev dependency?
- Is there a "script" for linting code? Like `"lint": "eslint"`
- Is there a "script" for lint-fixing code? Like `"lint:fix": "eslint --fix"`
- Is there config for linting code? (`.eslintrc`, `eslint` field in `package.json`, `.oxlintrc.json`)
- Is there config for ignoring certain files from being linted? (`.eslintignore` contains `.nuxt` and `.output`)
- Is there a "script" for single command verification? (`"verify": "npm run format && npm run lint:fix && npm run typecheck && npm test"`)

### CI/CD

- Is there a CI/CD pipeline configured? (`.github/workflows/ci.yml`, `.gitlab-ci.yml`, `nixpacks.toml`, `netlify.toml`)

### Testing

- Are there tests for the project?

### Typescript

- Is there a "script" for running typechecking? (`"typecheck": "nuxt typecheck"`)
- Does the project use TypeScripts project references (in `tsconfig.json`)?
- Is there TypeScript reset applied? (`@total-typescript/ts-reset` in dev deps,
  `reset.d.ts` with `import "@total-typescript/ts-reset"`)

### Documentation

- Is there a `README.md` file with sections about installation, project
  starting, usage and contributing?
- Is there a license file?

### AI

- Is there `AGENTS.md` or `CLAUDE.md` commited into the repository?
- Are there AI tool specific configuration files? (`.claude/settings.json`)
- Is there a folder for AI-related work? (`.aiwork/`)
