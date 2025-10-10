---
allowed-tools: Read, Write, Bash(mkdir:*)
description: Create a new custom Claude Code command
argument-hint: [command-name] [scope] [description] [allowed-tools]
---

## Context

Create a new custom Claude Code command file with proper frontmatter and structure.

## Your task

Create a new Claude Code command based on the arguments provided or by asking the user for details.

### Step 1: Parse Arguments and Gather Information

**Arguments format:** `$ARGUMENTS` may contain:

- Command name (required): The name of the command (e.g., `test`, `deploy`, `command/edit`)
- Scope (optional): Either `project` (default) or `global`
- Description (optional): Brief description of what the command does
- Allowed tools (optional): Comma-separated list of tools

**If any required information is missing from `$ARGUMENTS`, ask the user:**

1. **Command name** (required):
   - Ask: "What should the command be named?"
   - Format: Use lowercase, hyphens for spaces
   - Support subdirectories with `/` (e.g., `command/create`, `git/cleanup`)
   - Example: `deploy`, `test-e2e`, `command/edit`

2. **Scope** (optional, default: `project`):
   - Ask: "Should this be a project or global command? (project/global)"
   - `project` -> `.claude/commands/` in current git repository
   - `global` -> `~/.claude/commands/` for all projects
   - Default to `project` if not specified

3. **Description** (required):
   - Ask: "Provide a brief description (shown in /command:list):"
   - Should be concise, one line
   - Example: "Run end-to-end tests with Playwright"

4. **Allowed tools** (optional):
   - Ask: "Which tools should Claude be allowed to use? (comma-separated, or 'all')"
   - Examples: `Bash, Read, Write`, `Bash(npm:*), Bash(node:*)`, `all`
   - If not specified, omit the `allowed-tools` frontmatter field

5. **Additional prompts** (optional):
   - Ask: "Should this command accept arguments? (yes/no)"
   - If yes, ask: "Provide an argument hint (e.g., '[file-path] [options]'):"

### Step 2: Determine Target Path

**For project scope:**

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
TARGET_DIR="$REPO_ROOT/.claude/commands"
```

**For global scope:**

```bash
TARGET_DIR="$HOME/.claude/commands"
```

**Handle subdirectories:**

- If command name contains `/` (e.g., `command/create`), create subdirectories
- Example: `command/create` -> `$TARGET_DIR/command/create.md`

### Step 3: Check for Existing Command

Check if the command file already exists:

```bash
if [[ -f "$TARGET_FILE" ]]; then
  echo "WARNING: Command already exists: $TARGET_FILE"
  exit 1
fi
```

If it exists, inform the user and ask if they want to overwrite it.

### Step 4: Create Command File

**Create directory structure:**

```bash
mkdir -p "$(dirname "$TARGET_FILE")"
```

**Generate file content with frontmatter:**

```markdown
---
description: <description>
allowed-tools: <allowed-tools>
argument-hint: <argument-hint>
---

## Context

<Provide any context Claude needs to understand the task>

## Your task

<Clear instructions for what Claude should do when this command is invoked>

<If the command accepts arguments, explain how to use $ARGUMENTS>
```

**Frontmatter rules:**

- Always include `description`
- Include `allowed-tools` only if specified
- Include `argument-hint` only if command accepts arguments
- Use proper YAML syntax

### Step 5: Write the File

Use the Write tool to create the command file with the generated content.

### Step 6: Confirm Creation

Report success to the user:

```
SUCCESS: Created <scope> command: /<command-name>

Location: <full-path>
Description: <description>

Try it: /<command-name>
```

**Example output:**

```
SUCCESS: Created project command: /test-e2e

Location: /home/user/project/.claude/commands/test-e2e.md
Description: Run end-to-end tests with Playwright

Try it: /test-e2e
```

### Error Handling

- If not in a git repository and scope is `project`: Report error and suggest using `global` scope
- If command name contains invalid characters: Report error and suggest valid format
- If file already exists: Ask user to confirm overwrite
- If directory creation fails: Report error with details

### Examples

**Creating a simple project command:**

```
/command:create deploy project "Deploy application to production" "Bash"
```

**Creating a global command with subdirectory:**

```
/command:create command/edit global "Edit an existing command" "Read, Write, Glob"
```

**Interactive creation (no arguments):**

```
/command:create
-  Asks for command name
-  Asks for scope
-  Asks for description
-  Asks for allowed tools
-  Creates the command
```
