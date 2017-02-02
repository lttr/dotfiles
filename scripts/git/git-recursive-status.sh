#!/bin/bash

# Git recursive status
#
# Finds git repositories in subfolders and prints basic status
# information about each of them.
#
# Sort by date newer to older? Just pipe: | sort -k3 -r

find -maxdepth 4 -type d | while read dir; do
	if [ -d "$dir/.git" ]
	then
		repo="--git-dir=${dir}/.git --work-tree=${dir}"

        branch=`git $repo symbolic-ref HEAD 2>/dev/null` || branch="(unnamed)"
        branch=${branch##refs/heads/}

        staged=`git $repo diff --cached --numstat 2>/dev/null | wc -l`
        changed=`git $repo diff --numstat 2>/dev/null | wc -l`
        untracked=`git $repo ls-files --others --exclude-standard 2>/dev/null | wc -l`

        last_commit_date=`git $repo log -1 --format=%ci 2>/dev/null | awk '{print $1}'`
        last_commit_date=${last_commit_date:="no-commits"}

        dirty="clean"

        if [[ $staged > 0 ]] || [[ $changed > 0 ]]; then
            dirty="uncommited"
        fi

        if [[ $untracked > 0 ]]; then
            dirty="${dirty}, untracked"
        fi

        # Align path at 40 characters
        if [[ ${#dir} > 40 ]]; then
            dir="...${dir: -37:37}"
        fi

        printf "%-40s %-10s %s %s\n" "$dir" "$branch" "$last_commit_date" "$dirty"
	fi
done
