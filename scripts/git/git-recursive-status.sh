#!/bin/bash

# Git recursive status
#
# Finds git repositories in subfolders and prints basic status
# information about each of them.
#
# Originally from https://github.com/fboender/multi-git-status

C_RED="\033[1;31m"
C_YELLOW="\033[1;33m"
C_BLUE="\033[1;34m"
C_CYAN="\033[1;36m"
C_WHITE="\033[1;37m"
C_GREEN="\033[1;32m"
C_RESET="$(tput sgr0)"

C_OK="$C_GREEN"
C_NEEDS_PUSH="$C_YELLOW"
C_NEEDS_PULL="$C_BLUE"
C_NEEDS_COMMIT="$C_RED"
C_UNTRACKED="$C_CYAN"

DEBUG=0

DEFAULT_DIR_DEPTH=4

if [ "$1" = "--help" ]; then
    echo "Usage: $0 [DIR] [DEPTH=2]" >&2
    echo
    echo "Scan for .git dirs under DIR (up to DEPTH dirs deep) and show git status"
    exit 1
fi

if [ -z "$1" ]; then
    ROOT_DIR="."
else
    ROOT_DIR=$1
fi

if [ -z "$2" ]; then
    DEPTH=$DEFAULT_DIR_DEPTH
else
    DEPTH=$2
fi

# Find all .git dirs, up to DEPTH levels deep
for GIT_DIR in $(find $ROOT_DIR -maxdepth $DEPTH -name ".git" -type d); do
    PROJ_DIR=$(dirname $GIT_DIR)

    printf "${PROJ_DIR}: "

    [ $DEBUG -eq 1 ] && echo

    # Find all remote branches that have been checked out and figure out if
    # they need a push or pull. We do this with various tests and put the name
    # of the branches in NEEDS_XXXX, seperated by newlines. After we're done,
    # we remove duplicates from NEEDS_XXX.
    NEEDS_PUSH_BRANCHES="" 
    NEEDS_PULL_BRANCHES=""

    for REF_HEAD in $(ls $GIT_DIR/refs/heads); do
        # Check if this branch is tracking a remote branch
        TRACKING_REMOTE=$(git --git-dir $GIT_DIR rev-parse --abbrev-ref --symbolic-full-name $REF_HEAD@{u} 2>/dev/null)
        if [ $? -eq 0 ]; then
            # Branch is tracking a remote branch. Find out how much behind /
            # ahead it is of that remote branch.
            CNT_AHEAD_BEHIND=$(git --git-dir $GIT_DIR rev-list --left-right --count $REF_HEAD...$TRACKING_REMOTE)
            CNT_AHEAD=$(echo $CNT_AHEAD_BEHIND | awk '{ print $1 }')
            CNT_BEHIND=$(echo $CNT_AHEAD_BEHIND | awk '{ print $2 }')

            [ $DEBUG -eq 1 ] && echo CNT_AHEAD_BEHIND: $CNT_AHEAD_BEHIND
            [ $DEBUG -eq 1 ] && echo CNT_AHEAD: $CNT_AHEAD
            [ $DEBUG -eq 1 ] && echo CNT_BEHIND: $CNT_BEHIND

            if [ $CNT_AHEAD -gt 0 ]; then
                NEEDS_PUSH_BRANCHES="${NEEDS_PUSH_BRANCHES}\n$REF_HEAD"
            fi
            if [ $CNT_BEHIND -gt 0 ]; then
                NEEDS_PULL_BRANCHES="${NEEDS_PULL_BRANCHES}\n$REF_HEAD"
            fi
        else
            # FIXME: Non-tracking branches might need a remote for pushing?
            :
        fi

        REV_LOCAL=$(git --git-dir $GIT_DIR rev-parse --verify $REF_HEAD 2>/dev/null)
        REV_REMOTE=$(git --git-dir $GIT_DIR rev-parse --verify origin/$REF_HEAD 2>/dev/null)
        REV_BASE=$(git --git-dir $GIT_DIR merge-base $REF_HEAD origin/$REF_HEAD 2>/dev/null)

        [ $DEBUG -eq 1 ] && echo REV_LOCAL: $REV_LOCAL
        [ $DEBUG -eq 1 ] && echo REV_REMOTE: $REV_REMOTE
        [ $DEBUG -eq 1 ] && echo REV_BASE: $REV_BASE

        if [ "$REV_LOCAL" = "$REV_REMOTE" ]; then
            : # NOOP
        else
            if [ "$REV_LOCAL" = "$REV_BASE" ]; then
                NEEDS_PULL_BRANCHES="${NEEDS_PULL_BRANCHES}\n$REF_HEAD"
            fi
            if [ "$REV_REMOTE" = "$REV_BASE" ]; then
                NEEDS_PUSH_BRANCHES="${NEEDS_PUSH_BRANCHES}\n$REF_HEAD"
            fi
        fi
    done

    # Remove duplicates from NEEDS_XXXX and make comma-seperated
    NEEDS_PUSH_BRANCHES=$(printf "$NEEDS_PUSH_BRANCHES" | sort | uniq | tr '\n' ',' | sed "s/^,\(.*\),$/\1/")
    NEEDS_PULL_BRANCHES=$(printf "$NEEDS_PULL_BRANCHES" | sort | uniq | tr '\n' ',' | sed "s/^,\(.*\),$/\1/")

    # Find out if there are uncomitted changes
    UNSTAGED=$(git --work-tree $(dirname $GIT_DIR) --git-dir $GIT_DIR diff-index --quiet HEAD --; echo $?)
    UNCOMMITTED=$(git --work-tree $(dirname $GIT_DIR) --git-dir $GIT_DIR diff-files --quiet --ignore-submodules --; echo $?)

    # Find out if there are untracked changes
    UNTRACKED=$(git --work-tree $(dirname $GIT_DIR) --git-dir $GIT_DIR ls-files --exclude-standard --others)

    LAST_COMMIT_DATE=`git --work-tree $(dirname $GIT_DIR) --git-dir $GIT_DIR log -1 --format=%ci 2>/dev/null | awk '{print $1}'`

    # Build up the status string
    STATUS_NEEDS=""
    if [ \! -z "$NEEDS_PUSH_BRANCHES" ]; then
        STATUS_NEEDS="${STATUS_NEEDS}${C_NEEDS_PUSH}Needs push ($NEEDS_PUSH_BRANCHES)${C_RESET} "
    fi
    if [ \! -z "$NEEDS_PULL_BRANCHES" ]; then
        STATUS_NEEDS="${STATUS_NEEDS}${C_NEEDS_PULL}Needs pull ($NEEDS_PULL_BRANCHES)${C_RESET} "
    fi
    if [ "$UNSTAGED" -ne 0 -o "$UNCOMMITTED" -ne 0 ]; then
        STATUS_NEEDS="${STATUS_NEEDS}${C_NEEDS_COMMIT}Uncommitted changes${C_RESET} "
    fi
    if [ "$UNTRACKED" != "" ]; then
        STATUS_NEEDS="${STATUS_NEEDS}${C_UNTRACKED}Untracked files${C_RESET} "
    fi
    if [ "$STATUS_NEEDS" = "" ]; then
        STATUS_NEEDS="${STATUS_NEEDS}${C_OK}ok${C_RESET} "
    fi
    if [ "$LAST_COMMIT_DATE" != "" ]; then
        STATUS_NEEDS="${STATUS_NEEDS}(${LAST_COMMIT_DATE})"
    fi

    # Print the output
    printf "$STATUS_NEEDS\n"
done
