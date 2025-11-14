#!/usr/bin/env zsh

# Requires GitHub CLI (gh) to be authenticated
# Run 'gh auth login' if not already authenticated

echo '[Public repos (active)]'
gh api user/repos --paginate --jq '.[] | select(.private != true and .archived != true and .fork != true) | "\(.pushed_at[0:10]) \(.name)"' | sort -r

echo
echo '[Private repos (active)]'
gh api user/repos --paginate --jq '.[] | select(.private == true and .archived != true and .fork != true) | "\(.pushed_at[0:10]) \(.name)"' | sort -r

echo
echo '[Public forks]'
gh api user/repos --paginate --jq '.[] | select(.private != true and .fork == true and .archived != true) | "\(.pushed_at[0:10]) \(.name)"' | sort -r

echo
echo '[Private forks]'
gh api user/repos --paginate --jq '.[] | select(.private == true and .fork == true and .archived != true) | "\(.pushed_at[0:10]) \(.name)"' | sort -r

echo
echo '[Public archived]'
gh api user/repos --paginate --jq '.[] | select(.private != true and .archived == true and .fork != true) | "\(.pushed_at[0:10]) \(.name)"' | sort -r

echo
echo '[Private archived]'
gh api user/repos --paginate --jq '.[] | select(.private == true and .archived == true and .fork != true) | "\(.pushed_at[0:10]) \(.name)"' | sort -r

echo
echo '[Archived forks]'
gh api user/repos --paginate --jq '.[] | select(.fork == true and .archived == true) | "\(.pushed_at[0:10]) \(.name)"' | sort -r

