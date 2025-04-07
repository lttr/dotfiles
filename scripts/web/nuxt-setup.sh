#!/bin/bash
set -e

# Check if project name is provided
if [ -z "$1" ]; then
    echo "Usage: ./nuxt-setup.sh <project-name>"
    exit 1
fi

PROJECT_NAME=$1

# Initialize Nuxt project
echo "Initializing Nuxt project using nuxi cli"
pnpm dlx nuxi@latest init $PROJECT_NAME --template v4-compat --package-manager=pnpm --git-init=true --no-install
cd $PROJECT_NAME

git add .
git commit -m "Nuxi init"

# Pin pnpm version
echo "pnpm version"
pnpm --version
pnpm pkg set packageManager="pnpm@$(pnpm --version)"

# Update dependencies
pnpm dlx taze -w

# Install deps
# I had issues with corepack being initiated from nuxi init, therefore I'm using
# pnpm directly here.
pnpm install

# Setup Node version
fnm use lts-latest
node --version > .node-version

# Add MIT license
pnpm dlx mit-license --name "Lukas Trumm"

# Setup Prettier
pnpm add -D prettier
echo '{"semi": false}' > .prettierrc
echo 'pnpm-lock.yaml' > .prettierignore

# Setup TypeScript
pnpm add -D typescript @total-typescript/ts-reset
cat > reset.d.ts << 'EOL'
// Do not add any other lines of code to this file!
import "@total-typescript/ts-reset";
EOL

# Add type checking
pnpm add -D vue-tsc
pnpm dlx add-npm-scripts 'typecheck' 'nuxi typecheck'

# Configure package.json scripts
pnpm dlx add-npm-scripts 'format' 'prettier  --list-different --write .'
pnpm dlx add-npm-scripts 'lint' 'eslint'
pnpm dlx add-npm-scripts 'lint:fix' 'eslint --fix'
pnpm dlx add-npm-scripts 'start' 'node .output/server/index.mjs'
pnpm dlx add-npm-scripts 'validate' 'npm run format && npm run lint:fix && npm run typecheck && npm test'

# Create basic App.vue
mkdir -p app
cat > app/app.vue << 'EOL'
<template>
  <NuxtLayout>
    <NuxtPage />
  </NuxtLayout>
</template>
EOL

mkdir -p app/assets/css
cat > app/assets/css/main.css << 'EOL'
:root {
  --font-family-body: "Poppins", sans-serif;
}

body {
  /* For Nuxt Fonts module to pick up the font automatically */
  font-family: "Poppins";
}
EOL


# Update nuxt.config.ts with essential configs
cat > nuxt.config.ts << 'EOL'
export default defineNuxtConfig({
  modules: [
    "@lttr/nuxt-config-postcss",
    "@nuxt/eslint",
    "@nuxt/fonts",
    "@nuxt/icon",
    "@nuxt/image",
    "@nuxtjs/plausible",
    "@nuxtjs/seo",
    "@vueuse/nuxt",
  ],
  devtools: { enabled: true },
  components: [
    {
      path: "~/components",
      pathPrefix: false,
    },
  ],
  css: ["@lttr/puleo", "~/assets/css/main.css"],
  eslint: {
    config: {
      nuxt: {
        sortConfigKeys: true,
      },
    },
  },
  site: {
    url: "https://example.com",
    name: "Website name",
    description: "Website description",
    defaultLocale: "en",
  },
  future: {
    compatibilityVersion: 4,
  },
  experimental: {
    typedPages: true,
  },
  compatibilityDate: "2025-02-01",
  lttrConfigPostcss: {
    filesWithGlobals: ["./node_modules/@lttr/puleo/output/media.css"],
  },
  plausible: {
    ignoredHostnames: ["localhost"],
    apiHost: "https://plausible.lttr.cz",
  },
})
EOL


# Add ESLint
pnpm add -D \
    eslint \
    @nuxt/eslint \
    @lttr/nuxt-config-eslint

cat > eslint.config.js << 'EOL'
import withNuxt from "./.nuxt/eslint.config.mjs"
import customConfig from "@lttr/nuxt-config-eslint"

export default withNuxt(customConfig)
EOL

# Add essential modules
pnpm add -D \
    @lttr/nuxt-config-postcss \
    @nuxt/eslint \
    @nuxt/fonts \
    @nuxt/icon \
    @nuxt/image \
    @nuxtjs/plausible \
    @nuxtjs/seo \
    @iconify-json/uil \
    @vueuse/nuxt \
    @vueuse/core

# Base styling layer
pnpm add @lttr/puleo

# Create Nixpacks config
cat > nixpacks.toml << 'EOL'
providers = ["node"]

[variables]
NIXPACKS_NODE_VERSION = '22'
EOL

# Format code
pnpm dlx format-package --write
pnpm exec prettier --write .

# Initialize git repository and commit
git add .
git commit -m "Nuxt project initialized with complete setup"

echo ""
echo "Nuxt project setup complete!"
echo "cd $PROJECT_NAME"
