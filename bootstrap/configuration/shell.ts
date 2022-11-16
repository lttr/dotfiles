import { Config } from "../deps.ts";
import { zsh } from "./apt.ts";

export const shell: Config[] = [
  {
    loginShell: {
      shell: "zsh",
      dependsOn: zsh,
    },
  },
];
