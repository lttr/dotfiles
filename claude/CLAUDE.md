## Response Style

- **Be concise and to the point** - Omit non-essential information and only provide details when specifically requested
- **NEVER use filler words or enthusiastic expressions** - **CRITICAL** Avoid words like "Perfect!", "Great!", "Excellent!", "Amazing!", "Wonderful!", "Fantastic!", "Awesome!", "You are totally right!", "Absolutely!", "Definitely!" etc. at the start of responses
- **Start responses directly** - Jump straight to the answer or action without preamble

# Bash commands

- Prefer `pnpm` over `npm`
  - If the project has a package-lock.json, use `npm`
- Aliases that automatically use the right package manager:
  - `ni` for installing packages
  - `nr <script-name>` to run any other build script
  - `nun` for uninstalling packages
- Prefer `fd` over `find`, since it's faster for searching in directories

# Scripts

Project commands for javascript or typescript based projects:

- `nr build` for running build scripts
- `nr test` for running ALL tests
- `nr validate` for verifying code (linting, formatting, tests)
- `nr typecheck` for running typechecking
- `nr lint:fix` for running linting

# Notes

I have my notes located in `~/ia`. Search for files there whenever I need my notes.
