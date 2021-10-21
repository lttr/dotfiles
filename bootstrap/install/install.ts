import { config } from "./configuration/config.ts";
import { runConfigurationSet } from "./deps.ts";

await runConfigurationSet(config, { verbose: true, dryRun: false });
