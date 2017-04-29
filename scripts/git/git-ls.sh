#!/bin/bash

# Git ls
#
# Lists files and folders in current directory (like ls -1)
# that are tracked by git

ls -1d $(git ls-tree --name-only `git rev-parse --abbrev-ref HEAD`)
