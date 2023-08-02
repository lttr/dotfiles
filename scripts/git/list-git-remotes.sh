#!/usr/bin/env sh

for x in *; do
 git --git-dir="$x/.git" remote -v | head -n 1 | awk '{print $2}'
done
