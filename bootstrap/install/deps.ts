// std
import * as fs from "https://deno.land/std@0.65.0/fs/mod.ts";
import * as log from "https://deno.land/std@0.65.0/log/mod.ts";
import * as path from "https://deno.land/std@0.65.0/path/mod.ts";

export { fs };
export { log };
export { path };

export { ensureSymlink } from "https://deno.land/std@0.65.0/fs/ensure_symlink.ts";
export { getFileInfoType } from "https://deno.land/std@0.65.0/fs/_util.ts";
export { ensureDir } from "https://deno.land/std@0.65.0/fs/ensure_dir.ts";
export { exists } from "https://deno.land/std@0.65.0/fs/exists.ts";

// user land

export {
  Config,
  printConfigurationSet,
  runConfigurationSet,
  showDepGraph,
} from "https://raw.githubusercontent.com/lttr/deno-dsc/master/mod.ts";
// } from '../../../code/deno-dsc/mod.ts'
