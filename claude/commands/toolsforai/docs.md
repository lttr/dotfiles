---
allowed-tools: Read, Glob, Bash(git:*), Bash(curl:*), Bash(mkdir:*), WebFetch, WebSearch
description: Generate and store documentation for AI agents
---

## Context

- Repository root: !`git rev-parse --show-toplevel`

## Your task

Generate comprehensive documentation for the top 5 most important dependencies in this project.

### Check for package.json

**Required**: This command only supports Node.js/TypeScript projects.

1. Get repository root using git command
2. Check if `package.json` exists at `<repo_root>/package.json`
3. If NOT found: Report "No package.json found. This command only supports Node.js/TypeScript projects." and EXIT

### Analyze Dependencies

Read `package.json` and:

1. Combine all dependencies from:
   - `dependencies`
   - `devDependencies`
   - `peerDependencies`

2. Select the 5 MOST IMPORTANT libraries based on priority:
   - **Tier 1**: Major frameworks (react, vue, next, nuxt, angular, svelte, solid)
   - **Tier 2**: Core build tools (vite, webpack, rollup, esbuild, typescript)
   - **Tier 3**: Backend frameworks (express, fastify, nestjs, hono, koa)
   - **Tier 4**: Essential utilities central to the project (tailwind, prisma, drizzle, etc.)

3. Extract FULL versions (major.minor.patch) for matching:
   - `"^4.1.25"` → `4.1.25`
   - `"~18.2.0"` → `18.2.0`
   - `">=3.0.0"` → `3.0.0`
   - `"next"` or `"latest"` → use `latest` as version

### Search Context7 for All Dependencies

Create and run a bash script to search Context7 API in parallel:

```bash
# Create temporary files for search results
SEARCH_1=$(mktemp)
SEARCH_2=$(mktemp)
SEARCH_3=$(mktemp)
SEARCH_4=$(mktemp)
SEARCH_5=$(mktemp)

# Search all 5 deps in parallel
curl -s "https://context7.com/api/v1/search?query=<lib1>" > "$SEARCH_1" &
curl -s "https://context7.com/api/v1/search?query=<lib2>" > "$SEARCH_2" &
curl -s "https://context7.com/api/v1/search?query=<lib3>" > "$SEARCH_3" &
curl -s "https://context7.com/api/v1/search?query=<lib4>" > "$SEARCH_4" &
curl -s "https://context7.com/api/v1/search?query=<lib5>" > "$SEARCH_5" &
wait
```

### Evaluate Context7 Version Match

For each library, check Context7 search results:

1. Look at the `versions` array in the search result
2. **EXACT MATCH REQUIRED**: Only use Context7 if:
   - The exact minor version (e.g., `3.16`) exists in `versions`, OR
   - The exact patch version (e.g., `3.16.2`) exists in `versions`
3. If NO exact match found → mark library for **fallback sources**

**Example decision logic:**
- Project uses `nuxt@3.16.2`, Context7 has `versions: ["3.14", "3.15"]` → NO MATCH, use fallback
- Project uses `vue@3.4.0`, Context7 has `versions: ["3.4", "3.5"]` → MATCH, use Context7

### Fallback Sources (when Context7 lacks version)

For libraries without exact Context7 version match, try these sources in order:

**Priority 1: llms.txt files**

Many modern libraries provide AI-optimized docs at `/llms.txt`. Known locations:

| Library | llms.txt URL |
|---------|-------------|
| Nuxt | https://nuxt.com/llms.txt |
| Nuxt UI | https://ui.nuxt.com/llms.txt |
| Drizzle ORM | https://orm.drizzle.team/llms.txt |
| shadcn/ui | https://ui.shadcn.com/llms.txt |

Try: `curl -s --fail "https://<library-domain>/llms.txt"`

If successful (HTTP 200), download and use this content.

**Priority 2: WebSearch for llms.txt**

If not in known list, search: `"<library-name> llms.txt"`

**Priority 3: Official Documentation**

Use WebFetch to get content from official docs:
- Check library's GitHub README for docs URL
- Common patterns: `https://<lib>.dev/docs`, `https://docs.<lib>.com`

### Download Documentation

For each library, download from the appropriate source:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
DOCS_DIR="$REPO_ROOT/.aiwork/package-docs"
mkdir -p "$DOCS_DIR"

# Function to download with frontmatter
download_doc() {
  local lib=$1
  local version=$2
  local source_url=$3
  local source_type=$4  # "context7" | "llms-txt" | "official-docs"
  local output_file="$DOCS_DIR/${lib}-${version}.md"

  # Download content to temp file
  local temp_content=$(mktemp)
  curl -s "$source_url" > "$temp_content"

  # Write frontmatter + content
  cat > "$output_file" <<FRONTMATTER
---
library: $lib
version: $version
source_type: $source_type
source_url: $source_url
downloaded: $(date -u +%Y-%m-%dT%H:%M:%SZ)
---

FRONTMATTER
  cat "$temp_content" >> "$output_file"
  rm "$temp_content"
}
```

### Report Results

After completion, report:

1. **Selected dependencies** with source info:

   ```
   Selected top 5 dependencies:
   - <lib1> (<version>) - <reason> [Source: <source_type>]
   - <lib2> (<version>) - <reason> [Source: <source_type>]
   ...
   ```

2. **Source breakdown**:
   - Context7 (exact version match): X libraries
   - llms.txt: X libraries
   - Official docs: X libraries

3. **Documentation location**:

   ```
   Documentation saved to: <repo_root>/.aiwork/package-docs/
   ```

4. **File list** with file sizes (to verify successful downloads)

**Example**:

```
Selected top 5 dependencies:
- nuxt (3.16) - Core framework [Source: llms.txt - https://nuxt.com/llms.txt]
- vue (3.4) - UI framework [Source: context7 - /vuejs/core]
- typescript (5.3) - Primary language [Source: context7 - /microsoft/TypeScript]
- @nuxt/ui (3.0) - Component library [Source: llms.txt - https://ui.nuxt.com/llms.txt]
- drizzle-orm (0.38) - Database ORM [Source: llms.txt - https://orm.drizzle.team/llms.txt]

Source breakdown:
- Context7 (exact version): 2 libraries
- llms.txt: 3 libraries

Documentation saved to: /home/user/project/.aiwork/package-docs/

Files created:
- nuxt-3.16.md (245 KB)
- vue-3.4.md (198 KB)
- typescript-5.3.md (312 KB)
- nuxt-ui-3.0.md (156 KB)
- drizzle-orm-0.38.md (221 KB)
```
