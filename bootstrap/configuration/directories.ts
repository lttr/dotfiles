import { HOME } from "../constants.ts";
import { Config, path } from "../deps.ts";

export const binDirectory = {
  directory: { path: path.join(HOME, "bin") },
};

export const directories: Config[] = [
  // Make useful directories inside home
  binDirectory,
  { directory: { path: path.join(HOME, "code") } },
  { directory: { path: path.join(HOME, "work") } },
  { directory: { path: path.join(HOME, "sandbox") } },
  { directory: { path: path.join(HOME, "opt") } },
  { directory: { path: path.join(HOME, "Photos") } },
  // Prepare dirs for zsh
  { directory: { path: path.join(HOME, ".zsh/completion") } },
];
