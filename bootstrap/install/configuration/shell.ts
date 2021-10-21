import { Config } from "../deps.ts";
import { antibody } from "./customInstalls.ts";
import { zsh } from "./apt.ts";

function antibodyPackage(packageName: string) {
  return {
    antibody: {
      packageName,
      dependsOn: antibody,
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
  antibodyPackage("zsh-users/zsh-syntax-highlighting"),
  antibodyPackage("zsh-users/zsh-completions"),
  antibodyPackage("zsh-users/zsh-history-substring-search"),
  antibodyPackage("MichaelAquilina/zsh-you-should-use"),
  antibodyPackage("akoenig/npm-run.plugin.zsh"),
  antibodyPackage("supercrabtree/k"),
  antibodyPackage("Tarrasch/zsh-bd"),
  antibodyPackage("mafredri/zsh-async"),
  antibodyPackage("sindresorhus/pure"),
];
