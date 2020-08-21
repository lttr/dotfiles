// std
import * as fs from 'https://deno.land/std/fs/mod.ts@0.65.0'
import * as log from 'https://deno.land/std/log/mod.ts@0.65.0'
import * as path from 'https://deno.land/std/path/mod.ts@0.65.0'

export { fs }
export { log }
export { path }

export { ensureSymlink } from 'https://deno.land/std/fs/ensure_symlink.ts@0.65.0'
export { getFileInfoType } from 'https://deno.land/std/fs/_util.ts@0.65.0'
export { ensureDir } from 'https://deno.land/std/fs/ensure_dir.ts@0.65.0'
export { exists } from 'https://deno.land/std/fs/exists.ts@0.65.0'

// user land

export {
  Config,
  printConfigurationSet,
  runConfigurationSet,
  showDepGraph,
} from 'https://raw.githubusercontent.com/lttr/deno-dsc/master/mod.ts'
// } from '../../../code/deno-dsc/mod.ts'
