# Spec: `working-days --list` for datetime-cz

## Problem

`datetime.ts working-days <from> <to>` returns only counts (`working_days`, `weekend_days`, holidays). No enumerated date list. Callers who need the actual workday dates hand-roll a day loop → easy to get a UTC/DST off-by-one bug (observed: a JS `Date` + `getDay()` loop across the 2026-03-29 DST transition emitted Sundays as workdays).

The skill already iterates correctly via `Temporal.PlainDate` internally — just doesn't expose the dates.

## Goal

Add opt-in `--list` flag to `working-days` that appends `dates: string[]` (ISO `YYYY-MM-DD`, ascending) of every working day in range. Count-only output unchanged when flag absent.

## Scope

File: `claude/skills/datetime-cz/datetime.ts`
- `workingDaysCmd(from, to, list = false)` — collect `cur.toString()` for each working day when `list`; spread `...(list ? { dates } : {})` into return.
- Dispatch: `working-days` case passes `args.includes("--list")`.

File: `claude/skills/datetime-cz/SKILL.md`
- Document `--list` under the working-days command.

Out of scope: no change to count fields, no `--list` on other commands, no CSV/JIRA logic (that lives in the `done` repo).

## Testing — MANDATORY, red-green TDD

Tests are required for this fix. Follow strict red-green:

1. **RED** — write `claude/skills/datetime-cz/datetime_test.ts` first. Run `deno test` and confirm it FAILS (flag not implemented yet). Do not write impl before seeing red.
2. **GREEN** — implement minimal `--list`. Run `deno test`, confirm PASS.
3. Refactor only with green bar held.

Required test cases (Deno `std/assert`, invoke via `new Deno.Command("deno", {args:[...]})` against the CLI, or import `workingDaysCmd` directly if exported):

- `dates.length === working_days` for an arbitrary range.
- **DST regression (the reason this exists):** range spanning 2026-03-29 (spring-forward). Assert `2026-03-29` (Sun) NOT in `dates`, `2026-03-30` (Mon) IS in `dates`. This is the test that would have caught the original bug.
- Holiday excluded: range incl. 2026-05-08 (Den vítězství) → not in `dates`.
- Easter-derived holiday excluded: 2026-04-06 (Velikonoční pondělí) not in `dates`.
- No `--list` → response has no `dates` key (count-only contract preserved).
- Dates ascending + ISO `YYYY-MM-DD` format.

Note: `datetime.ts` may need a small export of `workingDaysCmd` for direct unit testing, OR test purely through the CLI subprocess. Prefer CLI subprocess to test the real dispatch path incl. flag parsing.

## Acceptance

- `deno test claude/skills/datetime-cz/` green.
- `deno run --allow-env claude/skills/datetime-cz/datetime.ts working-days 2026-01-01 2026-05-25 --list` → JSON with 98-element `dates` array, first `2026-01-02`, last `2026-05-25`.
- Same command without `--list` → identical to current output (no `dates`).

## Unresolved questions

1. Export `workingDaysCmd` for unit tests, or test only via CLI subprocess? (spec leans CLI subprocess)
2. Keep `dates` opt-in behind `--list`, or always include? (spec assumes opt-in to keep output lean for the common count-only case — confirm)
3. Test file naming: `datetime_test.ts` (Deno default) — OK?
