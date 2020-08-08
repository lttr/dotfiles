import { Config } from '../deps.ts'

const webiConfig = {
  webi: {},
}

export const webInstallConfig: Config[] = [
  webiConfig,
  {
    webInstall: {
      name: 'rg',
      dependsOn: webiConfig,
    },
  },
]
