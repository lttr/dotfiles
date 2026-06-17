#!/bin/bash
#
# git catchup - fast-forward the current branch to its upstream, then restack
# any local branches that were branched off its previous tip.
#
# Steps:
#   1. Refuse to run with a dirty working tree.
#   2. Fast-forward pull the current branch (--ff-only).
#   3. Rebase dependent branches from the OLD tip onto the NEW tip.
#      Stacked chains (A -> B -> C) are handled in one rebase per leaf via
#      --update-refs, which moves the intermediate branch refs too.
#
# Usage:
#   git catchup            # show plan, ask for confirmation, then run
#   git catchup -y         # skip confirmation
#   git catchup -n         # dry run: print the plan and exit
#
set -euo pipefail

ASSUME_YES=0
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    -y|--yes)     ASSUME_YES=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -h|--help)    grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

bold() { printf '\033[1m%s\033[0m\n' "$1"; }
die()  { printf '\033[31m%s\033[0m\n' "$1" >&2; exit 1; }

# --- preconditions ---------------------------------------------------------
git rev-parse --git-dir >/dev/null 2>&1 || die "not a git repository"

current=$(git symbolic-ref --short -q HEAD) || die "detached HEAD; checkout a branch first"

if [ -n "$(git status --porcelain)" ]; then
  die "working tree not clean; commit or stash first"
fi

upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null) \
  || die "no upstream configured for '$current'"

OLD=$(git rev-parse HEAD)

# --- find dependent branches -----------------------------------------------
# candidate = local branch (not current) that contains OLD and has its own
# commits beyond OLD.
# ff_only = local branch (not current) sitting exactly on OLD with no own
# commits; it just needs to be fast-forwarded to the new tip.
candidates=()
ff_only=()
while IFS= read -r b; do
  [ "$b" = "$current" ] && continue
  if [ "$(git rev-parse "$b")" = "$OLD" ]; then
    ff_only+=("$b")
  elif git merge-base --is-ancestor "$OLD" "$b" 2>/dev/null; then
    candidates+=("$b")
  fi
done < <(git for-each-ref --format='%(refname:short)' refs/heads)

# leaf = candidate that is not an ancestor of any other candidate.
# Rebasing a leaf with --update-refs restacks its whole chain.
leaves=()
for L in "${candidates[@]:-}"; do
  [ -z "$L" ] && continue
  is_leaf=1
  for C in "${candidates[@]:-}"; do
    [ -z "$C" ] && continue
    [ "$C" = "$L" ] && continue
    if git merge-base --is-ancestor "$L" "$C" 2>/dev/null; then
      is_leaf=0; break
    fi
  done
  [ "$is_leaf" -eq 1 ] && leaves+=("$L")
done

# --- plan ------------------------------------------------------------------
bold "git catchup plan"
echo "  branch:    $current"
echo "  upstream:  $upstream"
echo "  old tip:   ${OLD:0:9}"
behind=$(git rev-list --count "HEAD..$upstream" 2>/dev/null || echo '?')
echo "  behind:    $behind commit(s)"
echo
echo "  1. pull --ff-only ($current -> $upstream)"
i=2
if [ "${#ff_only[@]}" -gt 0 ]; then
  echo "  $i. fast-forward to $current: ${ff_only[*]}"
  i=$((i+1))
fi
for L in "${leaves[@]:-}"; do
  [ -z "$L" ] && continue
  chain=$(git for-each-ref --format='%(refname:short)' refs/heads \
    | while IFS= read -r c; do
        [ "$c" = "$L" ] && continue
        [ "$c" = "$current" ] && continue
        if git merge-base --is-ancestor "$OLD" "$c" 2>/dev/null \
           && git merge-base --is-ancestor "$c" "$L" 2>/dev/null \
           && [ "$(git rev-parse "$c")" != "$OLD" ]; then
          printf '%s ' "$c"
        fi
      done)
  if [ -n "$chain" ]; then
    echo "  $i. rebase --onto $current ${OLD:0:9} $L  (also moves: ${chain%% })"
  else
    echo "  $i. rebase --onto $current ${OLD:0:9} $L"
  fi
  i=$((i+1))
done
[ "${#ff_only[@]}" -eq 0 ] && [ "${#leaves[@]}" -eq 0 ] \
  && echo "  2. no dependent branches to update"
echo

[ "$DRY_RUN" -eq 1 ] && { echo "dry run; nothing executed."; exit 0; }

if [ "$ASSUME_YES" -ne 1 ]; then
  read -r -p "proceed? [y/N] " ans
  case "$ans" in y|Y|yes) ;; *) echo "aborted."; exit 1 ;; esac
fi

# --- execute ---------------------------------------------------------------
bold "pulling $current"
git pull --ff-only

for b in "${ff_only[@]:-}"; do
  [ -z "$b" ] && continue
  bold "fast-forwarding $b to $current"
  git branch -f "$b" "$current"
done

for L in "${leaves[@]:-}"; do
  [ -z "$L" ] && continue
  bold "rebasing $L onto $current"
  if ! git rebase --onto "$current" "$OLD" "$L" --update-refs; then
    die "rebase of '$L' hit conflicts; resolve and 'git rebase --continue', then rerun catchup"
  fi
done

git switch -q "$current"
bold "done; back on $current"
