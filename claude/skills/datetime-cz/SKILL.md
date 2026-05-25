---
name: datetime-cz
description: Compute exact dates, times, weekdays, working days, Czech state holidays, DST transitions, and duration sums via the bundled `datetime.ts` Deno CLI. Use whenever the answer depends on a real calendar fact (today's date/weekday in Europe/Prague, holiday lookup, working-day count, Easter-derived dates, DST direction) OR on summing a list of hours/minutes (worklog totals, time tallies). Trigger when the user asks "what day is X", "is X a working day", "how many working days in May", "when is Velikonoce / Velký pátek", "next Tuesday", "month-end date", "DST switch", any worklog/vacation calculation, or any sum of hour/minute values. Do NOT guess or do mental math — Easter shifts every year, weekday/holiday combos are easy to misremember, and even trivial sums (1+1+1+5+1) fail silently in head.
---

# datetime-cz

Deterministic date/time + Czech state holidays. Wraps Temporal API.

Default timezone `Europe/Prague`. Default locale `cs-CZ`. Holiday list = zákon č. 245/2000 Sb. (fixed days + Easter-derived: Velký pátek, Velikonoční pondělí).

## When to use

- Anything requiring today's wall-clock date/weekday → `now`.
- "Is X a working day?", "how many working days in <range>?" → `is-working-day` / `working-days`. Never count by hand.
- Czech state holidays in any year/range → `holidays-year` / `holidays`. Easter must be computed.
- "Next Friday", "first Monday after X" → `next-weekday`.
- Month/week/year start or end → `period`.
- Date arithmetic (`+ N days`, `- 3 weeks`, etc.) → `add`.
- Difference between two dates/datetimes → `diff`.
- DST / 23h or 25h day questions → `dst`.
- Summing a list of hour/minute durations (worklog totals, "does this add to Xh?") → `sum`. Never mental-math, even trivial sums.

If the answer depends on a fact this CLI returns, **call it**. Do not estimate, do not pattern-match from training data; Czech holiday law and DST rules are precise.

## CLI

Run: `$CLAUDE_SKILL_DIR/datetime.ts <command> [args...]` (executable).

All output JSON on stdout. Errors → stderr, exit 1.

```
$CLAUDE_SKILL_DIR/datetime.ts now [tz]
$CLAUDE_SKILL_DIR/datetime.ts add <iso-date|datetime> '<json-duration>'
$CLAUDE_SKILL_DIR/datetime.ts diff <from> <to> [largest-unit]
$CLAUDE_SKILL_DIR/datetime.ts period <iso> <day|week|month|year> <start|end>
$CLAUDE_SKILL_DIR/datetime.ts next-weekday <1-7|cs-name> [from-iso] [inclusive]
$CLAUDE_SKILL_DIR/datetime.ts dst <year> [tz]
$CLAUDE_SKILL_DIR/datetime.ts is-working-day <yyyy-mm-dd>
$CLAUDE_SKILL_DIR/datetime.ts working-days <from> <to> [--list]
$CLAUDE_SKILL_DIR/datetime.ts holidays <from> <to>
$CLAUDE_SKILL_DIR/datetime.ts holidays-year <year>
$CLAUDE_SKILL_DIR/datetime.ts sum <duration> [<duration> ...]
```

`largest-unit` is one of `years|months|weeks|days|hours|minutes|seconds` (default `days`).
ISO weekday: 1=po, 7=ne. Czech names accepted: `pondělí úterý středa čtvrtek pátek sobota neděle`.
Duration JSON: any subset of `{years, months, weeks, days, hours, minutes, seconds}`, may be negative.
`sum` duration tokens: bare number = hours (e.g. `1`, `0.5`), or unit-suffixed (`1h`, `30m`, `45s`, `1h30m`, `2h15m30s`). Negatives allowed.
`working-days --list` appends `dates: string[]` (ISO `YYYY-MM-DD`, ascending) of every working day in range. Omit for count-only output. Use when you need the actual workday dates, not just totals — never hand-roll a day loop (DST off-by-one risk).

## Examples

```bash
# Today in Prague
$CLAUDE_SKILL_DIR/datetime.ts now

# Working days in May 2026
$CLAUDE_SKILL_DIR/datetime.ts working-days 2026-05-01 2026-05-31

# Is Good Friday a working day?
$CLAUDE_SKILL_DIR/datetime.ts is-working-day 2026-04-03

# All CZ holidays in 2026
$CLAUDE_SKILL_DIR/datetime.ts holidays-year 2026

# Next Friday after today
$CLAUDE_SKILL_DIR/datetime.ts next-weekday pátek

# 90 days from a date
$CLAUDE_SKILL_DIR/datetime.ts add 2026-05-04 '{"days":90}'

# Hours/minutes between two timestamps
$CLAUDE_SKILL_DIR/datetime.ts diff 2026-05-04T09:00:00 2026-05-04T17:30:00 hours

# Last day of current month
$CLAUDE_SKILL_DIR/datetime.ts period 2026-05-04 month end

# DST transitions in 2026
$CLAUDE_SKILL_DIR/datetime.ts dst 2026

# Sum a list of worklog hours
$CLAUDE_SKILL_DIR/datetime.ts sum 1 1 1 5 1
# → total_hours: 9, formatted: "9h 0m"

# Sum mixed unit-suffixed durations
$CLAUDE_SKILL_DIR/datetime.ts sum 1h30m 45m 2h 15m
# → total_hours: 4.5, formatted: "4h 30m"
```

## Notes

- Script uses `npm:temporal-polyfill`. First run downloads to Deno cache (auto, no flags needed for module loading). Runtime perms: `--allow-env` only.
- For "letošní/tento měsíc/zbytek měsíce" type questions: call `now` first, then derive bounds with `period`, then call `working-days`.
- For "kdy bude volno": call `holidays` from today forward and `next-weekday sobota` — return whichever is sooner.
- Velký pátek IS a state holiday (since 2016). Always treat as non-working day.
