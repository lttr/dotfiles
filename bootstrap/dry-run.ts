import { config } from "./config.ts";
import { parse, runConfigurationSet } from "./deps.ts";

const filter = parse(Deno.args).filter;
await runConfigurationSet(config, { verbose: false, dryRun: true, filter });
