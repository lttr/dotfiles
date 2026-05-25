import { assert, assertEquals, assertMatch } from "jsr:@std/assert@1";

const SCRIPT = new URL("./datetime.ts", import.meta.url).pathname;

type Json = Record<string, unknown>;

async function raw(
  args: string[],
): Promise<{ code: number; stdout: string; stderr: string }> {
  const { code, stdout, stderr } = await new Deno.Command("deno", {
    args: ["run", "--no-lock", "--allow-env", SCRIPT, ...args],
    stdout: "piped",
    stderr: "piped",
  }).output();
  const dec = new TextDecoder();
  return { code, stdout: dec.decode(stdout), stderr: dec.decode(stderr) };
}

async function run(args: string[]): Promise<Json> {
  const { code, stdout, stderr } = await raw(args);
  if (code !== 0) throw new Error(`exit ${code}: ${stderr}`);
  return JSON.parse(stdout);
}

const WEEKDAYS_CZ = [
  "pondělí", "úterý", "středa", "čtvrtek", "pátek", "sobota", "neděle",
];

// ── now ────────────────────────────────────────────────────────────
Deno.test("now: shape, ISO date, weekday consistency", async () => {
  const r = await run(["now"]);
  assertMatch(r.date as string, /^\d{4}-\d{2}-\d{2}$/);
  assertMatch(r.time as string, /^\d{2}:\d{2}:\d{2}$/);
  assertEquals(r.timezone, "Europe/Prague");
  const dow = r.day_of_week as number;
  assert(dow >= 1 && dow <= 7);
  assertEquals(r.weekday_cz, WEEKDAYS_CZ[dow - 1]);
});

Deno.test("now: honors explicit timezone arg", async () => {
  const r = await run(["now", "America/New_York"]);
  assertEquals(r.timezone, "America/New_York");
});

// ── add ────────────────────────────────────────────────────────────
Deno.test("add: plain date + days", async () => {
  const r = await run(["add", "2026-05-04", '{"days":90}']);
  assertEquals(r.result, "2026-08-02");
});

Deno.test("add: datetime + hours/minutes keeps time", async () => {
  const r = await run(["add", "2026-05-04T09:00:00", '{"hours":5,"minutes":30}']);
  assertEquals(r.result, "2026-05-04T14:30:00");
});

Deno.test("add: time component promotes plain date to datetime", async () => {
  const r = await run(["add", "2026-05-04", '{"hours":2}']);
  assertEquals(r.result, "2026-05-04T02:00:00");
});

Deno.test("add: negative duration", async () => {
  const r = await run(["add", "2026-05-04", '{"days":-4}']);
  assertEquals(r.result, "2026-04-30");
});

// ── diff ───────────────────────────────────────────────────────────
Deno.test("diff: default days, full year", async () => {
  const r = await run(["diff", "2026-01-01", "2026-12-31"]);
  assertEquals(r.days, 364);
  assertEquals(r.sign, 1);
  assertEquals(r.iso, "P364D");
});

Deno.test("diff: hours largest unit", async () => {
  const r = await run(["diff", "2026-05-04T09:00:00", "2026-05-04T17:30:00", "hours"]);
  assertEquals(r.hours, 8);
  assertEquals(r.minutes, 30);
  assertEquals(r.iso, "PT8H30M");
});

Deno.test("diff: months largest unit", async () => {
  const r = await run(["diff", "2026-01-15", "2026-05-25", "months"]);
  assertEquals(r.months, 4);
  assertEquals(r.days, 10);
});

Deno.test("diff: reversed range yields negative sign", async () => {
  const r = await run(["diff", "2026-05-10", "2026-05-01"]);
  assertEquals(r.days, -9);
  assertEquals(r.sign, -1);
});

Deno.test("diff: bad largest-unit errors", async () => {
  const { code, stderr } = await raw(["diff", "2026-01-01", "2026-02-01", "fortnights"]);
  assertEquals(code, 1);
  assertMatch(stderr, /bad largest-unit/);
});

// ── period ─────────────────────────────────────────────────────────
Deno.test("period: month end (Feb non-leap)", async () => {
  const r = await run(["period", "2026-02-15", "month", "end"]);
  assertEquals(r.result, "2026-02-28");
});

Deno.test("period: week start is Monday", async () => {
  const r = await run(["period", "2026-05-04", "week", "start"]);
  assertEquals(r.result, "2026-05-04"); // already Monday
});

Deno.test("period: week end is Sunday", async () => {
  const r = await run(["period", "2026-05-04", "week", "end"]);
  assertEquals(r.result, "2026-05-10");
});

Deno.test("period: year end", async () => {
  const r = await run(["period", "2026-06-15", "year", "end"]);
  assertEquals(r.result, "2026-12-31");
});

Deno.test("period: day with time gets end-of-day clock", async () => {
  const r = await run(["period", "2026-05-04T12:00:00", "day", "end"]);
  assertEquals(r.result, "2026-05-04T23:59:59");
});

Deno.test("period: bad period errors", async () => {
  const { code, stderr } = await raw(["period", "2026-05-04", "decade", "start"]);
  assertEquals(code, 1);
  assertMatch(stderr, /bad period/);
});

// ── next-weekday ───────────────────────────────────────────────────
Deno.test("next-weekday: czech name", async () => {
  const r = await run(["next-weekday", "pátek", "2026-05-25"]);
  assertEquals(r.date, "2026-05-29");
  assertEquals(r.days_from_start, 4);
  assertEquals(r.target_weekday, 5);
});

Deno.test("next-weekday: numeric weekday", async () => {
  const r = await run(["next-weekday", "3", "2026-05-25"]);
  assertEquals(r.date, "2026-05-27");
  assertEquals(r.target_weekday_cz, "středa");
});

Deno.test("next-weekday: same weekday non-inclusive jumps 7 days", async () => {
  const r = await run(["next-weekday", "1", "2026-05-25"]); // Mon
  assertEquals(r.date, "2026-06-01");
  assertEquals(r.days_from_start, 7);
});

Deno.test("next-weekday: same weekday inclusive returns start", async () => {
  const r = await run(["next-weekday", "1", "2026-05-25", "true"]);
  assertEquals(r.date, "2026-05-25");
  assertEquals(r.days_from_start, 0);
});

Deno.test("next-weekday: bad weekday errors", async () => {
  const { code, stderr } = await raw(["next-weekday", "8", "2026-05-25"]);
  assertEquals(code, 1);
  assertMatch(stderr, /bad weekday/);
});

// ── dst ────────────────────────────────────────────────────────────
Deno.test("dst: 2026 has spring-forward and fall-back", async () => {
  const r = await run(["dst", "2026"]);
  const t = r.transitions as Json[];
  assertEquals(t.length, 2);
  assertEquals(t[0].date, "2026-03-29");
  assertEquals(t[0].type, "spring_forward");
  assertEquals(t[0].hours_in_day, 23);
  assertEquals(t[1].date, "2026-10-25");
  assertEquals(t[1].type, "fall_back");
  assertEquals(t[1].hours_in_day, 25);
});

// ── is-working-day ─────────────────────────────────────────────────
Deno.test("is-working-day: ordinary weekday", async () => {
  const r = await run(["is-working-day", "2026-05-25"]); // Mon
  assertEquals(r.is_working_day, true);
  assertEquals(r.is_weekend, false);
  assertEquals(r.is_holiday, false);
});

Deno.test("is-working-day: Saturday is weekend", async () => {
  const r = await run(["is-working-day", "2026-05-23"]);
  assertEquals(r.is_weekend, true);
  assertEquals(r.is_working_day, false);
});

Deno.test("is-working-day: Velký pátek is a holiday, not working", async () => {
  const r = await run(["is-working-day", "2026-04-03"]);
  assertEquals(r.is_holiday, true);
  assertEquals(r.holiday_name, "Velký pátek");
  assertEquals(r.is_working_day, false);
});

// ── working-days (counts) ──────────────────────────────────────────
Deno.test("working-days: counts add up to total", async () => {
  const r = await run(["working-days", "2026-05-01", "2026-05-31"]);
  const sum = (r.working_days as number) + (r.weekend_days as number) +
    (r.holiday_days_on_weekday as number);
  assertEquals(sum, r.total_days);
  assertEquals(r.inclusive, true);
});

Deno.test("working-days: reversed range is normalized", async () => {
  const r = await run(["working-days", "2026-05-31", "2026-05-01"]);
  assertEquals(r.from, "2026-05-01");
  assertEquals(r.to, "2026-05-31");
});

// ── working-days --list (the feature this suite was created for) ────
Deno.test("--list: dates.length === working_days", async () => {
  const r = await run(["working-days", "2026-05-01", "2026-05-31", "--list"]);
  assertEquals((r.dates as string[]).length, r.working_days);
});

Deno.test("--list: DST spring-forward 2026-03-29 excluded, Mon 2026-03-30 included", async () => {
  const r = await run(["working-days", "2026-03-27", "2026-03-31", "--list"]);
  const dates = r.dates as string[];
  assert(!dates.includes("2026-03-29"), "Sunday 2026-03-29 must NOT be a working day");
  assert(dates.includes("2026-03-30"), "Monday 2026-03-30 must be a working day");
});

Deno.test("--list: fixed holiday 2026-05-08 (Den vítězství) excluded", async () => {
  const r = await run(["working-days", "2026-05-04", "2026-05-12", "--list"]);
  assert(!(r.dates as string[]).includes("2026-05-08"));
});

Deno.test("--list: Easter-derived 2026-04-06 (Velikonoční pondělí) excluded", async () => {
  const r = await run(["working-days", "2026-04-01", "2026-04-10", "--list"]);
  assert(!(r.dates as string[]).includes("2026-04-06"));
});

Deno.test("no --list: response has no dates key", async () => {
  const r = await run(["working-days", "2026-05-01", "2026-05-31"]);
  assert(!("dates" in r), "count-only contract: no dates key without --list");
});

Deno.test("--list: dates ascending, ISO format, acceptance range", async () => {
  const r = await run(["working-days", "2026-01-01", "2026-05-25", "--list"]);
  const dates = r.dates as string[];
  for (const d of dates) assertMatch(d, /^\d{4}-\d{2}-\d{2}$/);
  for (let i = 1; i < dates.length; i++) {
    assert(dates[i - 1] < dates[i], `not ascending at ${dates[i]}`);
  }
  assertEquals(dates.length, 98);
  assertEquals(dates[0], "2026-01-02");
  assertEquals(dates.at(-1), "2026-05-25");
});

// ── holidays (range) ───────────────────────────────────────────────
Deno.test("holidays: range includes fixed + Easter-derived, ascending", async () => {
  const r = await run(["holidays", "2026-04-01", "2026-05-10"]);
  const dates = (r.holidays as Json[]).map((h) => h.date as string);
  assertEquals(dates, ["2026-04-03", "2026-04-06", "2026-05-01", "2026-05-08"]);
});

Deno.test("holidays: spans year boundary", async () => {
  const r = await run(["holidays", "2025-12-24", "2026-01-01"]);
  const dates = (r.holidays as Json[]).map((h) => h.date as string);
  assert(dates.includes("2025-12-24"));
  assert(dates.includes("2026-01-01"));
});

// ── holidays-year ──────────────────────────────────────────────────
Deno.test("holidays-year: 2026 has 13 holidays incl. Easter pair", async () => {
  const r = await run(["holidays-year", "2026"]);
  const list = r.holidays as Json[];
  assertEquals(list.length, 13);
  const byName = Object.fromEntries(list.map((h) => [h.name, h.date]));
  assertEquals(byName["Velký pátek"], "2026-04-03");
  assertEquals(byName["Velikonoční pondělí"], "2026-04-06");
});

Deno.test("holidays-year: Easter shifts year to year", async () => {
  const a = await run(["holidays-year", "2026"]);
  const b = await run(["holidays-year", "2027"]);
  const ep = (j: Json) =>
    (j.holidays as Json[]).find((h) => h.name === "Velikonoční pondělí")!.date;
  assert(ep(a) !== ep(b), "Easter Monday should differ across years");
});

// ── sum ────────────────────────────────────────────────────────────
Deno.test("sum: bare numbers are hours", async () => {
  const r = await run(["sum", "1", "1", "1", "5", "1"]);
  assertEquals(r.total_hours, 9);
  assertEquals(r.formatted, "9h 0m");
});

Deno.test("sum: mixed unit-suffixed tokens", async () => {
  const r = await run(["sum", "1h30m", "45m", "2h", "15m"]);
  assertEquals(r.total_hours, 4.5);
  assertEquals(r.formatted, "4h 30m");
});

Deno.test("sum: negatives subtract", async () => {
  const r = await run(["sum", "2h", "-30m"]);
  assertEquals(r.total_seconds, 5400);
  assertEquals(r.formatted, "1h 30m");
});

Deno.test("sum: seconds render in formatted output", async () => {
  const r = await run(["sum", "1h", "1m", "1s"]);
  assertEquals(r.formatted, "1h 1m 1s");
});

Deno.test("sum: bad token errors", async () => {
  const { code, stderr } = await raw(["sum", "abc"]);
  assertEquals(code, 1);
  assertMatch(stderr, /bad duration/);
});

// ── dispatch ───────────────────────────────────────────────────────
Deno.test("unknown command exits 1", async () => {
  const { code, stderr } = await raw(["bogus"]);
  assertEquals(code, 1);
  assertMatch(stderr, /unknown command/);
});
