# Implementation notes: `working-days --list`

Spec: `.aiwork/2026-05-25_datetime-cz-working-days-list/spec.md` · Status: **done, 6/6 tests green**

## Summary

Added opt-in `--list` flag to `working-days`. Appends `dates: string[]` (ISO, ascending) of working days. Count-only output byte-identical when flag absent. All acceptance criteria verified.

## Design decisions (spec ambiguous)

- **Tested via CLI subprocess, not direct import.** Spec unresolved Q1/Q3 leaned this way. `workingDaysCmd` left *unexported* — exercises the real dispatch path including flag parsing, which is where the contract lives. No source change needed just to enable testing.
- **Kept `--list` opt-in** (Q2). `...(list ? { dates } : {})` spread keeps the key absent entirely, so the count-only contract is preserved exactly — confirmed by the `"dates" in r === false` test.
- **Test file named `datetime_test.ts`** (Deno default, Q3). Added a 6th test beyond the 5 required cases: explicit `length === 98 / first / last` assertion mirroring the acceptance command, so acceptance is regression-guarded too.

## Deviations

- **None functional.** Implementation matches spec scope exactly: only `workingDaysCmd` signature + the `working-days` dispatch line changed in `datetime.ts`.
- SKILL.md: documented the flag in the CLI block (`[--list]`) and added a one-line semantics note. Spec only said "document under the command" — added the DST-bug rationale so future callers know *why* to prefer it over a hand-rolled loop.

## Tradeoffs

- **Subprocess tests are slower** (~30ms each, spawn `deno run` per case) than importing the function. Chose them anyway: they cover flag parsing and JSON shape, which a direct unit call would skip. Total suite still <250ms.
- Tests require `--allow-run --allow-read` (to spawn the subprocess). The script itself still only needs `--allow-env` at runtime — unchanged.

## Open questions

None blocking. All three spec "unresolved questions" resolved as spec leaned. Flag the rest only if you want them revisited:

- Should `--list` also be wired into the deno permissions comment in SKILL.md notes? Left as-is (runtime perms unchanged).
- No `deno.json` task added for `deno test`; run with `deno test --no-lock --allow-run --allow-env --allow-read claude/skills/datetime-cz/`. Add a task if you want it in `/verify`.
