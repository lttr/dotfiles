---
allowed-tools: Read, Glob, Grep, Bash(git:*), Bash(ls:*), Bash(wc:*), Bash(cat:*), Bash(head:*), Bash(find:*), Bash(fd:*), Bash(du:*), Bash(cloc:*), Task
description: Assess a repository's structure, tech stack, and health
argument-hint: [focus-area]
---

## Context

- Current working directory: !`pwd`
- Git repository: !`git rev-parse --show-toplevel 2>/dev/null || echo "Not a git repository"`
- Recent commits: !`git log --oneline -5 2>/dev/null || echo "No git history"`

## Your task

Perform a comprehensive assessment of the current repository. Provide a structured report covering the following areas.

**Optional focus area from `$ARGUMENTS`:**

- `structure` - Focus on project organization and architecture
- `health` - Focus on code quality, tests, and maintenance signals
- `stack` - Focus on technology stack and dependencies
- `security` - Focus on security considerations
- If no argument provided, do a balanced overview of all areas

## Assessment Areas

### 1. Project Overview

- Project name and purpose (from README, package.json, or inferred)
- Primary language(s) and framework(s)
- Repository size (files, lines of code if `cloc` available)
- Age and activity (first commit, last commit, commit frequency)

### 2. Technology Stack

- Languages detected (by file extensions)
- Frameworks and major libraries (from package.json, requirements.txt, go.mod, Cargo.toml, etc.)
- Build tools and task runners
- Testing frameworks
- Development tools (linters, formatters, type checkers)

### 3. Project Structure

- Directory organization pattern (monorepo, standard, custom)
- Key directories and their purposes
- Entry points (main files, index files)
- Configuration files present

### 4. Code Health Signals

- Presence of: tests, CI/CD, documentation, type definitions
- Code quality tools configured (ESLint, Prettier, etc.)
- Git hygiene (branching strategy hints, commit message patterns)
- Dependency management (lock files, outdated check if possible)

### 5. Documentation Status

- README quality (exists, sections covered)
- API documentation
- Code comments density (sample check)
- Contributing guidelines, changelog

### 6. Potential Issues (if focus=health or security)

- Missing common files (LICENSE, .gitignore, etc.)
- Security concerns (exposed secrets patterns, vulnerable patterns)
- Technical debt indicators (TODO/FIXME counts, deprecated usage)
- Missing tests for key areas

## Output Format

Provide a structured report with:

1. **Quick Summary** - 2-3 sentence overview
2. **Key Stats** - Table of important metrics
3. **Detailed Findings** - Organized by assessment area
4. **Recommendations** - Prioritized list of improvements (if applicable)

Keep the report scannable. Use tables and bullet points. Front-load the most important information.

## Exploration Strategy

Use the Explore agent (Task tool with subagent_type=Explore) for:

- Understanding overall codebase structure
- Finding key configuration files
- Identifying patterns and conventions

Use direct tools (Glob, Grep, Read) for:

- Specific file lookups
- Counting and metrics
- Reading specific configuration files
