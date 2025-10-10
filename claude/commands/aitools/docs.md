---
allowed-tools: Read, Glob, Bash(git:*), Bash(curl:*), Bash(mkdir:*)
description: Generate and store documentation for AI agents
---

## Context

- Repository root: !`git rev-parse --show-toplevel`

## Your task

Generate comprehensive documentation for the top 5 most important dependencies in this project.

### Step 1: Check for package.json

**Required**: This command only supports Node.js/TypeScript projects.

1. Get repository root using git command
2. Check if `package.json` exists at `<repo_root>/package.json`
3. If NOT found: Report "No package.json found. This command only supports Node.js/TypeScript projects." and EXIT

### Step 2: Analyze Dependencies

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

3. Extract MINOR versions only (major.minor):
   - `"^4.1.25"` → `4.1`
   - `"~18.2.0"` → `18.2`
   - `">=3.0.0"` → `3.0`
   - `"next"` or `"latest"` → use `latest` as version

### Step 3: Search Context7 for All Dependencies

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

### Step 4: Analyze Search Results

For each of the 5 libraries:

1. Read the corresponding temporary search results file (`$SEARCH_1`, `$SEARCH_2`, etc.)
2. Analyze available results and select the BEST match:
   - Usually the first result is most relevant
   - Check `trustScore` (prefer 7-10)
   - Check `totalSnippets` (prefer higher documentation coverage)
3. Select the closest VERSION:
   - If exact version exists in `versions` array, use it
   - Otherwise, use the last version BEFORE the current one
   - If no specific version, use the main branch (no version suffix in library ID)
4. Extract the final library ID to use (e.g., `/nuxt/nuxt`)

**Note**: The temporary search files will be automatically cleaned up by the system.

### Step 5: Download Documentation in Parallel

Create and run a bash script to download all docs in parallel with frontmatter headers:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
DOCS_DIR="$REPO_ROOT/.aitools/package-docs"
mkdir -p "$DOCS_DIR"

# Function to download with frontmatter
download_doc() {
  local lib=$1
  local version=$2
  local library_id=$3
  local api_url="https://context7.com/api/v1${library_id}?type=md&tokens=15000"
  local output_file="$DOCS_DIR/${lib}-${version}.md"

  # Download content to temp file
  local temp_content=$(mktemp)
  curl -s "$api_url" > "$temp_content"

  # Write frontmatter + content
  cat > "$output_file" <<FRONTMATTER
---
library: $lib
version: $version
context7_id: $library_id
source_url: $api_url
downloaded: $(date -u +%Y-%m-%dT%H:%M:%SZ)
tokens: 15000
---

FRONTMATTER
  cat "$temp_content" >> "$output_file"
  rm "$temp_content"
}

# Download all 5 docs in parallel
download_doc "<lib1>" "<version1>" "<library_id_1>" &
download_doc "<lib2>" "<version2>" "<library_id_2>" &
download_doc "<lib3>" "<version3>" "<library_id_3>" &
download_doc "<lib4>" "<version4>" "<library_id_4>" &
download_doc "<lib5>" "<version5>" "<library_id_5>" &
wait
```

### Step 6: Report Results

After completion, report:

1. **Selected dependencies** with reasons:

   ```
   Selected top 5 dependencies:
   - <lib1> (<version>) - <reason> [Context7 ID: <library_id>]
   - <lib2> (<version>) - <reason> [Context7 ID: <library_id>]
   ...
   ```

2. **Documentation location**:

   ```
   Documentation saved to: <repo_root>/.aitools/package-docs/
   ```

3. **File list** with file sizes (to verify successful downloads)

**Example**:

```
Selected top 5 dependencies:
- nuxt (3.16) - Core application framework [/nuxt/nuxt]
- vue (3.4) - UI framework [/vuejs/core]
- typescript (5.3) - Primary language [/microsoft/TypeScript]
- tailwindcss (3.4) - Styling framework [/tailwindlabs/tailwindcss]
- prisma (5.7) - Database ORM [/prisma/prisma]

Documentation saved to: /home/user/project/.aitools/package-docs/

Files created:
- nuxt-3.16.md (245 KB)
- vue-3.4.md (198 KB)
- typescript-5.3.md (312 KB)
- tailwindcss-3.4.md (156 KB)
- prisma-5.7.md (221 KB)
```
