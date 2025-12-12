// std - using bare specifiers via deno.json imports
import * as fs from "@std/fs";
import * as log from "@std/log";
import * as path from "@std/path";

export { fs };
export { log };
export { path };

export { ensureSymlink } from "@std/fs/ensure-symlink";
export { ensureDir } from "@std/fs/ensure-dir";
export { exists } from "@std/fs/exists";
export { parseArgs as parse } from "@std/cli/parse-args";

// user land

export {
  printConfigurationSet,
  printStatsConfigurationSet,
  resources,
  runConfigurationSet,
  showDepGraph,
} from "@lttr/deno-dsc";
export type { Config } from "@lttr/deno-dsc";
