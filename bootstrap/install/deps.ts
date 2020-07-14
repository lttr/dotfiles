// std
import * as fs from 'https://deno.land/std/fs/mod.ts'
import * as log from 'https://deno.land/std/log/mod.ts'
import * as path from 'https://deno.land/std/path/mod.ts'

export { fs }
export { log }
export { path }

export { ensureSymlink } from 'https://deno.land/std/fs/ensure_symlink.ts'
export { getFileInfoType } from 'https://deno.land/std/fs/_util.ts'
export { ensureDir } from 'https://deno.land/std/fs/ensure_dir.ts'
export { exists } from 'https://deno.land/std/fs/exists.ts'

// user land

export {
  Configuration,
  Directory,
  DirectoryConfiguration,
  LoginShell,
  LoginShellConfiguration,
  Symlink,
  SymlinkConfiguration,
  printConfigurationSet,
  runConfigurationSet,
  showDepGraph,
} from '../../../code/deno-dsc/mod.ts'
// } from 'https://raw.githubusercontent.com/lttr/deno-dsc/master/mod.ts'
