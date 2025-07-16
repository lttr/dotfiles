#!/bin/bash
set -e

# Check if project name is provided
if [ -z "$1" ]; then
    echo "Usage: ./nuxt-setup.sh <project-name> [--puleo]"
    exit 1
fi

PROJECT_NAME=$1
USE_PULEO=false

# Parse arguments
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --puleo)
            USE_PULEO=true
            shift
            ;;
        *)
            echo "Unknown option $1"
            echo "Usage: ./nuxt-setup.sh <project-name> [--puleo]"
            exit 1
            ;;
    esac
done

# Initialize Nuxt project
echo "Initializing Nuxt project using nuxi cli"
MODULES="@nuxt/eslint,@nuxt/fonts,@nuxt/icon,@nuxt/image,@nuxtjs/plausible,@nuxtjs/seo,@vueuse/nuxt"
pnpm dlx nuxi@latest init $PROJECT_NAME --template v4 --packageManager=pnpm --gitInit=true --modules="$MODULES"
cd $PROJECT_NAME

git add .
git commit -m "Nuxi init"

# Setup Node version
fnm use lts-latest
node --version > .node-version

# Pin pnpm version
echo "pnpm version"
pnpm --version
pnpm pkg set packageManager="pnpm@$(pnpm --version)"

# Update dependencies
pnpm dlx taze -w


# Set up dependencies configuration
# Some functionalities of Nuxt does not work without this or explicit
# installation of more dependencies. (e.g. unplugin-vue-router for typedPages: true)
echo "shamefully-hoist=true" > .npmrc

# Add ESLint
pnpm add -D \
    eslint \
    @lttr/nuxt-config-eslint

cat > eslint.config.js << 'EOL'
import withNuxt from "./.nuxt/eslint.config.mjs"
import customConfig from "@lttr/nuxt-config-eslint"

export default withNuxt(customConfig)
EOL

# Install deps
# I had issues with corepack being initiated from nuxi init, therefore I'm using
# pnpm directly here.
echo "Installing dependencies with pnpm"
pnpm install

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
pnpm dlx add-npm-scripts 'test' 'exit 0'
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

# Create CSS files conditionally
mkdir -p app/assets/css
if [ "$USE_PULEO" = true ]; then
    cat > app/assets/css/main.css << 'EOL'
:root {
  --font-family-body: "Poppins", sans-serif;
}

body {
  /* For Nuxt Fonts module to pick up the font automatically */
  font-family: "Poppins";
}
EOL
else
    cat > app/assets/css/main.css << 'EOL'
/* Add your custom styles here */
EOL
fi


# Functions to generate Nuxt config sections
generate_modules() {
    local modules='"@nuxt/eslint",
    "@nuxt/fonts",
    "@nuxt/icon",
    "@nuxt/image",
    "@nuxtjs/plausible",
    "@nuxtjs/seo",
    "@vueuse/nuxt"'
    
    if [ "$USE_PULEO" = true ]; then
        modules='"@lttr/nuxt-config-postcss",
    '"$modules"
    fi
    
    echo "  modules: [
    $modules,
  ],"
}

generate_css() {
    if [ "$USE_PULEO" = true ]; then
        echo '  css: ["@lttr/puleo", "~~/app/assets/css/main.css"],'
    else
        echo '  css: ["~~/app/assets/css/main.css"],'
    fi
}

generate_puleo_config() {
    if [ "$USE_PULEO" = true ]; then
        echo '  lttrConfigPostcss: {
    filesWithGlobals: ["./node_modules/@lttr/puleo/output/media.css"],
  },'
    fi
}

generate_common_config() {
    echo '  components: [
    {
      path: "~/components",
      pathPrefix: false,
    },
  ],
  devtools: { enabled: true },
  site: { // TODO Configure site
    url: "https://example.com",
    name: "Website name",
    description: "Website description",
    defaultLocale: "en",
    indexable: false,
  },
  experimental: {
    typedPages: true,
  },
  compatibilityDate: "2025-07-01",
  eslint: {
    config: {
      nuxt: {
        sortConfigKeys: true,
      },
    },
  },
  plausible: {
    ignoredHostnames: ["localhost"],
    apiHost: "https://plausible.lttr.cz",
  },'
}

# Generate nuxt.config.ts
cat > nuxt.config.ts << EOL
export default defineNuxtConfig({
$(generate_modules)
$(generate_common_config)
  // Custom styles
$(generate_css)
$(generate_puleo_config)
})
EOL

# Prepare robots.txt
rm -f 'public/robots.txt'
cat > 'public/_robots.txt' << 'EOL'
User-agent: *
Disallow: /
# TODO Add rules for crawlers
# Allow: /
EOL

# Add some icons
pnpm add -D @iconify-json/uil

if [ "$USE_PULEO" = true ]; then
    pnpm dlx nuxi@latest add module @lttr/nuxt-config-postcss
    pnpm add -D @lttr/puleo
fi

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
