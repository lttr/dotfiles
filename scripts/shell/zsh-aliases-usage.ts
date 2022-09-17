#!/usr/bin/env -S deno run --allow-env --allow-read --allow-run

// zsh-aliases-usage
// Prints all zsh aliases sorted by last date of use.
// Every line that starts with 'never' indicates, that such alias has never been
// recorded in available zsh history.

import {
  HistoryRecord,
  zshHistory,
} from "https://deno.land/x/zsh_history@1.0.1/mod.ts";
import {
  Alias,
  evaluatedAliases,
} from "https://deno.land/x/shell_aliases@1.0.3/mod.ts";

// Extract zsh history from file
const history = await zshHistory();

// Extract zsh aliases
const aliases = await evaluatedAliases();

// Find used aliases
const usage = findUseOfAliases(aliases, history);

console.log(formatUsage(usage));

// Functions

function formatUsage(usage: AliasesUsage[]): string {
  return usage
    .map((record) => {
      const datetime = record.data.lastUsed
        ? record.data.lastUsed.toISOString().substr(0, 10)
        : "--never-->";
      return `${datetime}  ${record.alias.padEnd(
        12,
        " "
      )} ${record.data.command.substr(0, 30)}${
        record.data.command.length > 30 ? "..." : ""
      }`;
    })
    .join("\n");
}

function findUseOfAliases(
  aliases: Alias[],
  history: HistoryRecord[]
): AliasesUsage[] {
  if (!aliases || !history || aliases?.length < 0 || history.length < 0) {
    console.warn("There is not enough data to compute usage of aliases");
    return [];
  }
  const aliasesMap = new Map<string, AliasData>(
    aliases.map((alias) => [
      alias.key,
      { lastUsed: null, command: alias.value },
    ])
  );
  for (const historyRecord of history) {
    if (aliasesMap.has(historyRecord.command)) {
      const alias = aliasesMap.get(historyRecord.command);
      aliasesMap.set(historyRecord.command, {
        lastUsed: historyRecord.time,
        command: alias?.command ?? "",
      });
    }
  }
  const aliasesUsage: AliasesUsage[] = [...aliasesMap.entries()].map(
    ([alias, data]) => ({ alias, data })
  );
  aliasesUsage.sort((a, b) => {
    if (!a.data.lastUsed && !b.data.lastUsed) {
      return 0;
    }
    if (!b.data.lastUsed) {
      return -1;
    }
    if (!a.data.lastUsed) {
      return 1;
    }
    return b.data.lastUsed.getTime() - a.data.lastUsed.getTime();
  });
  return aliasesUsage;
}

// Types

interface AliasesUsage {
  alias: string;
  data: AliasData;
}
interface AliasData {
  lastUsed: Date | null;
  command: string;
}
