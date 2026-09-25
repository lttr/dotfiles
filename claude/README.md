# Claude Code config

`settings.json` trims features I rarely use to keep the startup context small
(~7k tokens instead of ~24k with no settings loaded). Each section says how to turn
a feature back on. Use `--settings '{...}'` to enable something for a single session.

Token numbers are from `claude -p "/context"` with one setting changed at a time.

## Context savers

### Auto-compact

- I don't use autocompact anyways, I strive to keep the context window small for all work
- `autoCompactEnabled: false` frees the 33k autocompact buffer (only a 3k compact buffer remains)
- Enable: `autoCompactEnabled: true`

### Auto memory

- I don't like saving things to memory which is hidden somewhere. Better to use CLAUDE.md or skills or rule files.
- `autoMemoryEnabled: false` removes ~0.7k from the system prompt
- Enable: `autoMemoryEnabled: true`

### Workflows

- Workflows are fine, but I only need it from time to time.
- `enableWorkflows: false` removes ~1.9k of tool definitions
- Enable: `enableWorkflows: true`; also `workflowKeywordTriggerEnabled: true` to trigger by keyword
- `skipWorkflowUsageWarning` only silences the usage notice

### claude.ai connectors

- Claude.ai connectors are focused on docs/calendar/email type of work, don't need it in Claude Code usually.
- `disableClaudeAiConnectors: true` removes the Gmail/Calendar/Drive/Docs MCP tools (~0.6k loaded, ~39k deferred)
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

A tool in `permissions.deny` is removed from the tool list, not just blocked.
To enable one, remove it from `deny`, plus the extra steps listed below.

| Tool(s) | Feature | Also needed to enable |
|---|---|---|
| `AskUserQuestion` | Multiple-choice questions | Drop the "Asking Questions" section in `CLAUDE.md` |
| `EnterPlanMode`, `ExitPlanMode` | Plan mode | The `copy-plan-to-aiwork.ts` hook already handles `ExitPlanMode` |
| `CronCreate`, `CronDelete`, `CronList` | Scheduled prompts | `skillOverrides.schedule: "on"` |
| `ScheduleWakeup` (~1.7k) | `/loop` self-pacing | `skillOverrides.loop: "on"` |
| `SendMessage` (~1.7k deferred), `ListAgents` (~0.4k) | Messaging subagents and other sessions | Deny or allow both together |
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
