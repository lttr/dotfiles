#!/usr/bin/env -S deno run --no-lock --allow-env

import { Temporal } from "npm:temporal-polyfill@0.2.5";

const DEFAULT_TZ = "Europe/Prague";
const WEEKDAYS_CZ = [
  "pondělí", "úterý", "středa", "čtvrtek", "pátek", "sobota", "neděle",
] as const;
const WD_NUM: Record<string, number> = Object.fromEntries(
  WEEKDAYS_CZ.map((w, i) => [w, i + 1]),
);

const FIXED_HOLIDAYS = [
  { m: 1, d: 1, name: "Nový rok / Den obnovy samostatného českého státu" },
  { m: 5, d: 1, name: "Svátek práce" },
  { m: 5, d: 8, name: "Den vítězství" },
  { m: 7, d: 5, name: "Den slovanských věrozvěstů Cyrila a Metoděje" },
  { m: 7, d: 6, name: "Den upálení mistra Jana Husa" },
  { m: 9, d: 28, name: "Den české státnosti" },
  { m: 10, d: 28, name: "Den vzniku samostatného československého státu" },
  { m: 11, d: 17, name: "Den boje za svobodu a demokracii" },
  { m: 12, d: 24, name: "Štědrý den" },
  { m: 12, d: 25, name: "1. svátek vánoční" },
  { m: 12, d: 26, name: "2. svátek vánoční" },
];

function easterSunday(year: number): Temporal.PlainDate {
  const f = Math.floor;
  const G = year % 19;
  const C = f(year / 100);
  const H = (C - f(C / 4) - f((8 * C + 13) / 25) + 19 * G + 15) % 30;
  const I = H - f(H / 28) * (1 - f(29 / (H + 1)) * f((21 - G) / 11));
  const J = (year + f(year / 4) + I + 2 - C + f(C / 4)) % 7;
  const L = I - J;
  const month = 3 + f((L + 40) / 44);
  const day = L + 28 - 31 * f(month / 4);
  return Temporal.PlainDate.from({ year, month, day });
}

type Holiday = { date: Temporal.PlainDate; name: string };
const HOLIDAY_CACHE = new Map<number, Holiday[]>();

function czechHolidays(year: number): Holiday[] {
  const cached = HOLIDAY_CACHE.get(year);
  if (cached) return cached;
  const easter = easterSunday(year);
  const list = [
    { date: easter.subtract({ days: 2 }), name: "Velký pátek" },
    { date: easter.add({ days: 1 }), name: "Velikonoční pondělí" },
    ...FIXED_HOLIDAYS.map(({ m, d, name }) => ({
      date: Temporal.PlainDate.from({ year, month: m, day: d }),
      name,
    })),
  ].sort((a, b) => Temporal.PlainDate.compare(a.date, b.date));
  HOLIDAY_CACHE.set(year, list);
  return list;
}

function findHoliday(date: Temporal.PlainDate) {
  return czechHolidays(date.year).find((h) => h.date.equals(date));
}

const hasTime = (s: string) => /T\d/.test(s);

function durObj(d: Temporal.Duration) {
  return {
    years: d.years, months: d.months, weeks: d.weeks, days: d.days,
    hours: d.hours, minutes: d.minutes, seconds: d.seconds,
    sign: d.sign, iso: d.toString(),
  };
}

function nowCmd(tz = DEFAULT_TZ) {
  const z = Temporal.Now.zonedDateTimeISO(tz);
  return {
    iso: z.toString(),
    date: z.toPlainDate().toString(),
    time: z.toPlainTime().toString({ smallestUnit: "second" }),
    datetime: z.toPlainDateTime().toString({ smallestUnit: "second" }),
    day_of_week: z.dayOfWeek,
    weekday_cz: WEEKDAYS_CZ[z.dayOfWeek - 1],
    year: z.year, month: z.month, day: z.day,
    hour: z.hour, minute: z.minute, second: z.second,
    timezone: tz,
  };
}

function addCmd(date: string, durationJson: string) {
  const dur = JSON.parse(durationJson);
  const wantTime = hasTime(date) || dur.hours || dur.minutes || dur.seconds;
  if (wantTime) {
    const dt = hasTime(date)
      ? Temporal.PlainDateTime.from(date)
      : Temporal.PlainDate.from(date).toPlainDateTime();
    return { result: dt.add(dur).toString({ smallestUnit: "second" }) };
  }
  return { result: Temporal.PlainDate.from(date).add(dur).toString() };
}

const LARGEST_UNITS = ["years", "months", "weeks", "days", "hours", "minutes", "seconds"] as const;
type LargestUnit = typeof LARGEST_UNITS[number];
const TIME_UNITS = new Set<LargestUnit>(["hours", "minutes", "seconds"]);

function parseLargest(arg: string | undefined): LargestUnit {
  const v = (arg ?? "days") as LargestUnit;
  if (!LARGEST_UNITS.includes(v)) throw new Error(`bad largest-unit: ${arg}`);
  return v;
}

function diffCmd(from: string, to: string, largestArg?: string) {
  const largest = parseLargest(largestArg);
  const needsTime = TIME_UNITS.has(largest) || hasTime(from) || hasTime(to);
  if (needsTime) {
    const a = hasTime(from)
      ? Temporal.PlainDateTime.from(from)
      : Temporal.PlainDate.from(from).toPlainDateTime();
    const b = hasTime(to)
      ? Temporal.PlainDateTime.from(to)
      : Temporal.PlainDate.from(to).toPlainDateTime();
    return durObj(a.until(b, { largestUnit: largest as Temporal.DateTimeUnit }));
  }
  const a = Temporal.PlainDate.from(from);
  const b = Temporal.PlainDate.from(to);
  return durObj(a.until(b, { largestUnit: largest as Temporal.DateUnit }));
}

function periodCmd(date: string, period: string, position: string) {
  const wantTime = hasTime(date) || period === "day";
  const base = hasTime(date)
    ? Temporal.PlainDateTime.from(date).toPlainDate()
    : Temporal.PlainDate.from(date);
  let result: Temporal.PlainDate;
  switch (period) {
    case "day": result = base; break;
    case "week": {
      const off = base.dayOfWeek - 1;
      result = position === "start"
        ? base.subtract({ days: off })
        : base.add({ days: 6 - off });
      break;
    }
    case "month":
      result = position === "start"
        ? base.with({ day: 1 })
        : base.with({ day: base.daysInMonth });
      break;
    case "year":
      result = position === "start"
        ? base.with({ month: 1, day: 1 })
        : base.with({ month: 12, day: 31 });
      break;
    default: throw new Error(`bad period: ${period}`);
  }
  if (wantTime) {
    return { result: result.toString() + (position === "start" ? "T00:00:00" : "T23:59:59") };
  }
  return { result: result.toString() };
}

function nextWeekdayCmd(weekdayArg: string, fromArg?: string, inclusiveArg?: string) {
  const target = /^\d+$/.test(weekdayArg)
    ? parseInt(weekdayArg, 10)
    : WD_NUM[weekdayArg];
  if (!target || target < 1 || target > 7) {
    throw new Error(`bad weekday: ${weekdayArg}`);
  }
  const start = fromArg
    ? Temporal.PlainDate.from(fromArg)
    : Temporal.Now.plainDateISO(DEFAULT_TZ);
  const inclusive = inclusiveArg === "true" || inclusiveArg === "1";
  let diff = (target - start.dayOfWeek + 7) % 7;
  if (diff === 0 && !inclusive) diff = 7;
  const date = start.add({ days: diff });
  return {
    date: date.toString(),
    days_from_start: diff,
    target_weekday: target,
    target_weekday_cz: WEEKDAYS_CZ[target - 1],
  };
}

function dstCmd(year: number, tz = DEFAULT_TZ) {
  const transitions: unknown[] = [];
  for (let m = 1; m <= 12; m++) {
    const ym = Temporal.PlainYearMonth.from({ year, month: m });
    for (let d = 1; d <= ym.daysInMonth; d++) {
      const day = Temporal.PlainDate.from({ year, month: m, day: d });
      const t0 = day.toZonedDateTime({ timeZone: tz }).startOfDay().epochMilliseconds;
      const t1 = day.add({ days: 1 }).toZonedDateTime({ timeZone: tz }).startOfDay().epochMilliseconds;
      const hours = (t1 - t0) / 3_600_000;
      if (hours === 24) continue;
      transitions.push({
        date: day.toString(),
        type: hours < 24 ? "spring_forward" : "fall_back",
        hours_in_day: hours,
        offset_before: day.toZonedDateTime({ timeZone: tz }).startOfDay().offset,
        offset_after: day.add({ days: 1 }).toZonedDateTime({ timeZone: tz }).startOfDay().offset,
      });
    }
  }
  return { year, timezone: tz, transitions };
}

function isWorkingDayCmd(date: string) {
  const d = Temporal.PlainDate.from(date);
  const h = findHoliday(d);
  return {
    date,
    day_of_week: d.dayOfWeek,
    weekday_cz: WEEKDAYS_CZ[d.dayOfWeek - 1],
    is_weekend: d.dayOfWeek >= 6,
    is_holiday: !!h,
    holiday_name: h?.name ?? null,
    is_working_day: d.dayOfWeek < 6 && !h,
  };
}

function workingDaysCmd(from: string, to: string, list = false) {
  const a = Temporal.PlainDate.from(from);
  const b = Temporal.PlainDate.from(to);
  const [start, end] = Temporal.PlainDate.compare(a, b) <= 0 ? [a, b] : [b, a];
  let total = 0, working = 0, weekend = 0;
  const holidays: { date: string; name: string }[] = [];
  const dates: string[] = [];
  for (let cur = start; Temporal.PlainDate.compare(cur, end) <= 0; cur = cur.add({ days: 1 })) {
    total++;
    const isWE = cur.dayOfWeek >= 6;
    const h = findHoliday(cur);
    if (isWE) weekend++;
    if (h && !isWE) holidays.push({ date: cur.toString(), name: h.name });
    if (!isWE && !h) {
      working++;
      if (list) dates.push(cur.toString());
    }
  }
  return {
    from: start.toString(), to: end.toString(), inclusive: true,
    total_days: total, working_days: working, weekend_days: weekend,
    holiday_days_on_weekday: holidays.length, holidays,
    ...(list ? { dates } : {}),
  };
}

function holidaysRangeCmd(from: string, to: string) {
  const a = Temporal.PlainDate.from(from);
  const b = Temporal.PlainDate.from(to);
  const [start, end] = Temporal.PlainDate.compare(a, b) <= 0 ? [a, b] : [b, a];
  const out: { date: string; name: string }[] = [];
  for (let y = start.year; y <= end.year; y++) {
    for (const h of czechHolidays(y)) {
      if (
        Temporal.PlainDate.compare(h.date, start) >= 0 &&
        Temporal.PlainDate.compare(h.date, end) <= 0
      ) {
        out.push({ date: h.date.toString(), name: h.name });
      }
    }
  }
  return { from: start.toString(), to: end.toString(), holidays: out };
}

function parseDurationToSeconds(s: string): number {
  const trimmed = s.trim();
  if (!trimmed) throw new Error("empty duration");
  if (/^-?\d+(\.\d+)?$/.test(trimmed)) {
    return Math.round(parseFloat(trimmed) * 3600);
  }
  let secs = 0;
  let matched = false;
  const re = /(-?\d+(?:\.\d+)?)\s*(hours|hour|hrs|hr|h|minutes|minute|mins|min|m|seconds|second|secs|sec|s)/gi;
  let m: RegExpExecArray | null;
  while ((m = re.exec(trimmed)) !== null) {
    matched = true;
    const n = parseFloat(m[1]);
    const u = m[2].toLowerCase();
    if (u.startsWith("h")) secs += n * 3600;
    else if (u.startsWith("m")) secs += n * 60;
    else secs += n;
  }
  if (!matched) throw new Error(`bad duration: ${s}`);
  return Math.round(secs);
}

function sumCmd(args: string[]) {
  if (args.length === 0) throw new Error("sum requires at least one duration");
  const parsed = args.map((a) => ({ input: a, seconds: parseDurationToSeconds(a) }));
  const total = parsed.reduce((acc, p) => acc + p.seconds, 0);
  const sign = total < 0 ? "-" : "";
  const abs = Math.abs(total);
  const h = Math.floor(abs / 3600);
  const m = Math.floor((abs % 3600) / 60);
  const s = abs % 60;
  const formatted = `${sign}${h}h ${m}m${s ? ` ${s}s` : ""}`;
  return {
    inputs: parsed,
    total_seconds: total,
    total_hours: total / 3600,
    formatted,
  };
}

function holidaysYearCmd(year: number) {
  return {
    year,
    holidays: czechHolidays(year).map((h) => ({ date: h.date.toString(), name: h.name })),
  };
}

function main() {
  const [cmd, ...args] = Deno.args;
  let out: unknown;
  switch (cmd) {
    case "now": out = nowCmd(args[0]); break;
    case "add": out = addCmd(args[0], args[1]); break;
    case "diff": out = diffCmd(args[0], args[1], args[2]); break;
    case "period": out = periodCmd(args[0], args[1], args[2]); break;
    case "next-weekday": out = nextWeekdayCmd(args[0], args[1], args[2]); break;
    case "dst": out = dstCmd(parseInt(args[0], 10), args[1]); break;
    case "is-working-day": out = isWorkingDayCmd(args[0]); break;
    case "working-days": out = workingDaysCmd(args[0], args[1], args.includes("--list")); break;
    case "holidays": out = holidaysRangeCmd(args[0], args[1]); break;
    case "holidays-year": out = holidaysYearCmd(parseInt(args[0], 10)); break;
    case "sum": out = sumCmd(args); break;
    default:
      console.error(`unknown command: ${cmd}\nrun without args for usage`);
      Deno.exit(1);
  }
  console.log(JSON.stringify(out, null, 2));
}

try {
  main();
} catch (e) {
  console.error((e as Error).message);
  Deno.exit(1);
}
