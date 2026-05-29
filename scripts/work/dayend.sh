#!/usr/bin/env bash

# cd to ~/code/done and launch Claude in auto permission mode with /day-end.
set -euo pipefail

cd "${HOME}/code/done"
exec claude --permission-mode auto "/day-end" "$@"
