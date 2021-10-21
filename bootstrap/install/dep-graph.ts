import { config } from "./configuration/config.ts";
import { showDepGraph } from "./deps.ts";

await showDepGraph(config);
