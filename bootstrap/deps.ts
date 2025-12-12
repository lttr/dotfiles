// std - using JSR for Deno 2
import * as fs from "jsr:@std/fs@^1";
import * as log from "jsr:@std/log@^0.224";
import * as path from "jsr:@std/path@^1";

export { fs };
export { log };
export { path };

export { ensureSymlink } from "jsr:@std/fs@^1/ensure-symlink";
export { ensureDir } from "jsr:@std/fs@^1/ensure-dir";
export { exists } from "jsr:@std/fs@^1/exists";
export { parseArgs as parse } from "jsr:@std/cli@^1/parse-args";

// user land

export {
  printConfigurationSet,
  printStatsConfigurationSet,
  resources,
  runConfigurationSet,
  showDepGraph,
} from "jsr:@lttr/deno-dsc@^0.1.0";
export type { Config } from "jsr:@lttr/deno-dsc@^0.1.0";
