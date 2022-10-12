import { Config } from "../deps.ts";
import { antidote } from "./customInstalls.ts";
import { zsh } from "./apt.ts";

function antidotePackage(packageName: string) {
  return {
    antidote: {
      packageName,
      dependsOn: antidote,
    },
  };
}

export const shell: Config[] = [
  {
    loginShell: {
      shell: "zsh",
      dependsOn: zsh,
    },
  },
  antidotePackage("zsh-users/zsh-syntax-highlighting"),
  antidotePackage("zsh-users/zsh-completions"),
  antidotePackage("zsh-users/zsh-history-substring-search"),
  antidotePackage("MichaelAquilina/zsh-you-should-use"),
  antidotePackage("wfxr/forgit"),
  antidotePackage("supercrabtree/k"),
  antidotePackage("Tarrasch/zsh-bd"),
  antidotePackage("mafredri/zsh-async"),
  antidotePackage("sindresorhus/pure"),
];
