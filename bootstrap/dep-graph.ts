import { config } from "./config.ts";
import { parse, showDepGraph } from "./deps.ts";

const filter = parse(Deno.args).filter;
showDepGraph(config, { filter });
