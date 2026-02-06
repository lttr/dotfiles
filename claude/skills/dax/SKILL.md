---
name: dax
description: This skill should be used when creating shell scripts, CLI tools, automation scripts, or any task that needs to run shell commands programmatically. Trigger when user asks to write a script, automate a task, create a CLI tool, process files in batch, or build any executable that runs shell commands. Also trigger when user mentions "dax", "deno script", or "write me a script". Deno with @david/dax is the default scripting stack on this machine - prefer it over bash scripts for anything beyond trivial one-liners.
---

# Dax - Deno Shell Scripting

Deno + `@david/dax` is the **default scripting stack** on this machine. Use it for all new scripts instead of bash/zsh scripts (unless trivially simple).

## Script Template

```typescript
#!/usr/bin/env -S deno run --allow-run --allow-env
import $ from "jsr:@david/dax";

// script body here
```

Minimal shebang is `--allow-run --allow-env` (both always required by dax). Add `--allow-read`, `--allow-write`, `--allow-net` as needed.

Every script follows these three steps:
1. First line is always the shebang: `#!/usr/bin/env -S deno run <permissions>`
2. Import from JSR: `import $ from "jsr:@david/dax";`
3. After writing, run `chmod +x <file>` via Bash tool

Place scripts in `~/dotfiles/scripts/<category>/` for auto-symlinking to `~/bin`. Use minimal required permissions in the shebang.

### Deno Permissions

`--allow-run` and `--allow-env` are always required - dax reads env internally even for simple commands.

| Flag | When needed |
|------|-------------|
| `--allow-run` | Always (dax executes commands) |
| `--allow-env` | Always (dax reads env internally) |
| `--allow-read` | Reading files/dirs |
| `--allow-write` | Writing files |
| `--allow-net` | HTTP requests via `$.request()` |
| `-A` | All permissions (quick scripts only) |

## Command Execution

```typescript
// Run, output streams to terminal
await $`echo hello`;

// Capture output
const text = await $`echo hello`.text();        // string
const lines = await $`ls`.lines();              // string[]
const json = await $`cat data.json`.json();     // parsed JSON
const bytes = await $`cat img.png`.bytes();     // Uint8Array

// Stderr capture
const err = await $`command`.text("stderr");
const both = await $`command`.text("combined");
```

### Exit Codes

```typescript
// Non-zero throws by default. Suppress with:
const code = await $`command`.noThrow().code();
await $`command`.noThrow(1);   // suppress only exit code 1
```

### Argument Interpolation

```typescript
const name = "my dir";
await $`mkdir ${name}`;           // auto-escaped: mkdir 'my dir'

const files = ["a.txt", "b.txt"];
await $`rm ${files}`;             // expands: rm a.txt b.txt

await $.raw`echo ${raw}`;        // no escaping
await $`echo ${$.rawArg(x)}`;    // selective raw
```

### Piping

```typescript
const out = await $`echo foo`.pipe($`grep foo`).text();
// Shell syntax also works:
await $`echo foo | grep foo`;
```

### Configuration

```typescript
await $`cmd`.env("KEY", "val").cwd("./subdir");
await $`cmd`.quiet();              // suppress output
await $`cmd`.quiet("stdout");      // suppress only stdout
await $`cmd`.timeout("30s");       // kill after timeout
await $`cmd`.printCommand();       // print command before running
```

### Spawn & Abort

```typescript
const child = $`sleep 100`.spawn();
child.kill();                      // SIGTERM

// Pipe between spawned processes
const src = $`echo data`.stdout("piped").spawn();
await $`process`.stdin(src.stdout());
```

### Redirects

```typescript
await $`echo hello > output.txt`;
await $`echo hello`.stdout($.path("out.txt"));
await $`gzip < ${data}`.bytes();
await $`gzip < ${$.path("file.txt")}`.bytes();
```

## Path API

Immutable `Path` via `$.path()` (from `@david/path`):

```typescript
const dir = $.path("output");
await dir.mkdir();                           // mkdir -p
const file = dir.join("data.txt");
await file.writeText("content");
const text = await file.readText();
file.basename();                             // "data.txt"
file.extname();                              // ".txt"
file.resolve().toString();                   // absolute path
file.isFileSync();                           // boolean
dir.isDirSync();                             // boolean

// Works in commands
await $`cat ${file}`;
```

## Interactive Prompts

```typescript
const name = await $.prompt("Your name?");
const name = await $.prompt("Name?", { default: "Dax", mask: true });
const yes = await $.confirm("Continue?");
const idx = await $.select({ message: "Pick:", options: ["A", "B", "C"] });
const idxs = await $.multiSelect({ message: "Pick many:", options: ["A", "B", "C"] });
```

`$.maybePrompt()`, `$.maybeConfirm()`, `$.maybeSelect()` return `undefined` on cancel.

## Logging

All log to stderr (keeps stdout clean for piping):

```typescript
$.log("info");
$.logStep("Done");        // green
$.logError("Failed");     // red
$.logWarn("Warning");     // yellow
$.logLight("Detail");     // gray

// Grouped/indented output
await $.logGroup(async () => {
  $.log("indented");
});
```

## Progress

```typescript
// Indeterminate spinner
await $.progress("Working...").with(async () => { /* ... */ });

// Determinate bar
const pb = $.progress("Processing", { length: items.length });
await pb.with(async () => {
  for (const item of items) {
    await doWork(item);
    pb.increment();
  }
});
```

## HTTP Requests

```typescript
const data = await $.request("https://api.example.com").json();
const html = await $.request("https://example.com").text();

// Download with progress
await $.request("https://example.com/file.zip")
  .showProgress()
  .pipeToPath($.path("file.zip"));

// Headers, timeout
await $.request("https://api.example.com")
  .header("Authorization", "Bearer token")
  .timeout("10s")
  .json();
```

## Helpers

```typescript
await $.sleep("2s");                         // async delay
await $.which("deno");                       // find executable path
await $.commandExists("ffmpeg");             // boolean
await $.withRetries({                        // retry with backoff
  count: 3, delay: "1s",
  action: async () => { /* ... */ },
});
const s = $.dedent`                          // strip leading indent
  multi
    line`;
$.stripAnsi(text);                           // remove ANSI escapes
```

## Built-in Shell Commands

Cross-platform, no external deps: `cd`, `echo`, `exit`, `cp`, `mv`, `rm`, `mkdir` (-p), `pwd`, `sleep`, `test`, `touch`, `cat`, `which`, `true`, `false`, `printenv`, `unset`

## Custom $ Instance

```typescript
const $ = build$({
  commandBuilder: (b) => b.cwd("./subDir").env("VAR", "value"),
  requestBuilder: (b) => b.header("Auth", "token"),
  extras: { myHelper: (a: string) => a.toUpperCase() },
});
```

## Workflow

1. Determine script purpose and required Deno permissions
2. Write script with shebang as first line, JSR import
3. Run `chmod +x <script>` via Bash tool
4. Place in `~/dotfiles/scripts/<category>/` if it should be in PATH

## Notes

- Always import from JSR (`jsr:@david/dax`), never npm
- Prefer `$.path()` over string path manipulation
- Use `$.log*` over `console.log` for CLI output (stderr, clean piping)
- Use `.noThrow()` when non-zero exit codes are expected
- Use `.quiet()` when capturing results without terminal output
- Shell variables work: `await $\`VAR=1 && echo $VAR\``
- For `pipefail`, `nullglob`, `globstar` use `set`/`shopt` in commands
