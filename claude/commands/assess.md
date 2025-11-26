---
allowed-tools: Bash(ls:*), Bash(find:*), Bash(wc:*), Bash(git:*), Bash(head:*), Bash(tail:*), Read, Glob, Grep
description: Comprehensive repository assessment and documentation
argument-hint: [focus-area]
---

## Context

- Current directory: !`pwd`
- Git repo check: !`git rev-parse --is-inside-work-tree 2>/dev/null && echo "Yes" || echo "No"`
- Top-level contents: !`ls -la 2>/dev/null | head -30`

## Your Task

Perform a comprehensive assessment of this repository. If an argument is provided, focus on that area (e.g., "security", "architecture", "testing").

### Phase 1: Repository Overview

**Identify project type and stack:**
- Check for package.json, Cargo.toml, go.mod, pyproject.toml, composer.json, etc.
- Identify primary language(s) and framework(s)
- Note dependency management approach

**Assess structure:**
- Map key directories and their purposes
- Identify entry points (main files, index files)
- Note any unconventional organization

### Phase 2: Documentation Quality

**Check for:**
- README.md quality and completeness
- CLAUDE.md or AI-assistant instructions
- API documentation
- Contributing guidelines
- Changelog/release notes

**Evaluate:**
- Are setup instructions clear?
- Is the architecture documented?
- Are there examples/tutorials?

### Phase 3: Code Quality Indicators

**Look for:**
- Linting configuration (.eslintrc, .prettierrc, ruff.toml, etc.)
- Type checking (tsconfig.json, mypy.ini, etc.)
- Test coverage (test directories, coverage config)
- CI/CD configuration (.github/workflows, .gitlab-ci.yml, etc.)

**Assess:**
- Code organization patterns
- Separation of concerns
- Consistency in naming/style

### Phase 4: Development Experience

**Evaluate:**
- Build/dev scripts available
- Environment setup complexity
- Local development ease
- Debugging support

### Phase 5: Health Metrics

**Gather (if git repo):**
- Recent commit activity
- Number of contributors
- Branch strategy indicators
- Issue/PR patterns (if visible)

## Output Format

Present findings as a structured report:

```
# Repository Assessment: [repo-name]

## Quick Summary
- **Type**: [project type]
- **Stack**: [primary technologies]
- **Health**: [Good/Fair/Needs Work]
- **Documentation**: [Complete/Partial/Minimal]

## Strengths
- [bullet points]

## Areas for Improvement
- [bullet points with specific suggestions]

## Key Files to Know
- [important files and their purposes]

## Recommended Next Steps
1. [prioritized actionable items]
```

Keep the report concise but actionable. Focus on insights that would help a new developer or AI assistant work effectively in this codebase.
