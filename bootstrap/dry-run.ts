import { config } from "./config.ts";
import { runConfigurationSet } from "./deps.ts";

await runConfigurationSet(config, { verbose: true, dryRun: true });
