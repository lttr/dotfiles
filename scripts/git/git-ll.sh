#!/bin/bash

# Git ll
#
# Lists files and folders in current directory (like colored ll)
# that are tracked by git

ls -dlhF --color $(git ls-tree --name-only `git rev-parse --abbrev-ref HEAD`)
