# Claude Code config

`settings.json` trims features I rarely use to keep the startup context small
(Opus ~8k tokens instead of ~12k with no settings loaded, Sonnet ~17k instead of ~24k). Each section says how to turn a feature back on.

Token numbers are from `claude -p "/context"` with one setting changed at a time.

## Enable for one session

`claude --settings '{...}'`. If a user-settings `false` can't be overridden (e.g. `enableArtifact`),
add `--setting-sources ""` (drops the whole config).

## Context savers

### Auto-compact

- I don't use autocompact anyways, I strive to keep the context window small for all work
- `autoCompactEnabled: false` frees the 33k autocompact buffer (only a 3k compact buffer remains)
- Enable: `autoCompactEnabled: true`

### Auto memory

- I don't like saving things to memory which is hidden somewhere. Better to use CLAUDE.md or skills or rule files.
- `autoMemoryEnabled: false` removes ~0.7k from the system prompt (~4k on Sonnet)
- Enable: `autoMemoryEnabled: true`

### Workflows

- Workflows are fine, but I only need it from time to time.
- `enableWorkflows: false` removes ~1.9k of tool definitions
- Enable: `enableWorkflows: true`; also `workflowKeywordTriggerEnabled: true` to trigger by keyword
- `skipWorkflowUsageWarning` only silences the usage notice

### claude.ai connectors

- Claude.ai connectors are focused on docs/calendar/email type of work, don't need it in Claude Code usually.
- `disableClaudeAiConnectors: true` removes the Gmail/Calendar/Drive/Docs MCP tools (all deferred, so no startup context saved)
- Enable: `disableClaudeAiConnectors: false`

### claude.ai sync

- `syncClaudeAiSkills` / `syncClaudeAiPlugins: false` keep skills and plugins from claude.ai out
- Enable: set either one to `true`

### Skill listing

- `skillOverrides`: `on` / `name-only` / `user-invocable-only` / `off` per skill (does not apply to plugin skills)
- Own skills: `disable-model-invocation: true` in the frontmatter makes them slash-only
- No `skillListing*` caps: truncated descriptions hurt auto-invocation, and trimmed tokens
  move into the Skill tool description anyway, so the net savings are small

## Denied tools

- I don't see a big benefit in using AskUserQuestion tool. Longer questions are
  clunky. I'm fine with simple convention in CLAUDE.md for prefixing the agent's
  questions with "? ".
- Loop is very fun feature, but in practice I rarely use it.

A tool in `permissions.deny` is removed from the tool list, not just blocked.
To enable one, remove it from `deny`, plus the extra steps listed below.

| Tool(s) | Feature | Also needed to enable |
|---|---|---|
| `AskUserQuestion` | Multiple-choice questions | Drop the "Asking Questions" section in `CLAUDE.md` |
| `EnterPlanMode`, `ExitPlanMode` | Plan mode | — |
| `CronCreate`, `CronDelete`, `CronList` | Scheduled prompts | `skillOverrides.schedule: "on"` |
| `ScheduleWakeup` (~1.7k) | `/loop` self-pacing | `skillOverrides.loop: "on"` |
| `ReportFindings` (~0.8k) | Structured `/code-review` output | Without it, findings come back as text |
| `NotebookEdit` | Jupyter editing | — |
| `PushNotification` | Push notifications | `preferredNotifChannel` (currently `notifications_disabled`) |

## Other opt-outs

| Setting | Enable with |
|---|---|
| `enableArtifact: false` | `true` |
| `disableRemoteControl: true` | `false`; `remoteControlAtStartup: true` to start it automatically |
| `promptSuggestionEnabled: false` | `true` |
| `awaySummaryEnabled: false` | `true` |
| `spinnerTipsEnabled: false` | `true` |
| `showTurnDuration: false` | `true` |
| `terminalProgressBarEnabled: false` | `true` |
| `feedbackDrafts: "off"` | remove the key |

## Measure

```sh
claude -p "/context"                                    # current config
claude -p "/context" --setting-sources ""               # no settings files
claude -p "/context" --settings '{"enableWorkflows":true}'  # one change
```

Print mode doesn't load interactive-only tools (`AskUserQuestion`, plan mode), so an
interactive `/context` shows higher numbers.
