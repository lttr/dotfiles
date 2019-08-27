#!/usr/bin/env pwsh

# Based on https://github.com/fboender/multi-git-status/

$START_DIR = $PWD.Path

$DIRECTORIES = Get-ChildItem $START_DIR -Recurse -Directory -Exclude ".*" -Depth 1

foreach ($DIRECTORY in $DIRECTORIES) {
  $PROJ_DIR = $DIRECTORY.FullName
  $GIT_DIR = Join-Path -Path "$PROJ_DIR" -ChildPath ".git"
  $RELATIVE_PATH = $PROJ_DIR.Substring($START_DIR.Length + 1)
  $RELATIVE_NORMALIZED_PATH = $RELATIVE_PATH -replace "\\", "/"

  # If this dir is not a repo, and WARN_NOT_REPO is 1, tell the user
  if ($(Test-Path -PathType Container -Path "$GIT_DIR") -eq $false) {
    # Write-Host "${RELATIVE_NORMALIZED_PATH}: not a git repo"
    continue
  }

  # Check if repo is locked
  $LOCK_PATH = Join-Path -Path $GIT_DIR -ChildPath "index.lock"
  if (Test-Path -PathType Leaf -Path "$LOCK_PATH") {
    Write-Host "${PROJ_DIR}: Locked. Skipping."
    continue
  }

  # Do a 'git fetch'
  git --work-tree "$PROJ_DIR" --git-dir "$GIT_DIR" fetch -q 2>&1> $null

  # Refresh the index, or we might get wrong results
  git --work-tree "$PROJ_DIR" --git-dir "$GIT_DIR" update-index -q --refresh 2>&1> $null


  # Find out if there are unstaged, uncommitted or untracked changes
  $UNSTAGED = $(
    git --work-tree "$PROJ_DIR" --git-dir "$GIT_DIR" diff-index --quiet HEAD -- 2> $null
    $?
  )

  $UNCOMMITTED = $(
    git --work-tree "$PROJ_DIR" --git-dir "$GIT_DIR" diff-files --quiet --ignore-submodules
    $?
  )

  $UNTRACKED = $(
    git --work-tree "$PROJ_DIR" --git-dir "$GIT_DIR" ls-files --exclude-standard --others
  )

  $OLDPWD = $(Get-Location)
  Set-Location "$PROJ_DIR"
  $STASHES = $(git stash list | Measure-Object | Select-Object -ExpandProperty Count)
  Set-Location "$OLDPWD"

  # Find all remote branches that have been checked out and figure out if
  # they need a push or pull. We do this with various tests and put the name
  # of the branches in NEEDS_XXXX, seperated by newlines. After we're done,
  # we remove duplicates from NEEDS_XXX
  $NEEDS_PUSH_BRANCHES = @()
  $NEEDS_PULL_BRANCHES = @()
  $NEEDS_UPSTREAM_BRANCHES = @()

  $REF_HEADS_DIR = Join-Path -Path "${GIT_DIR}" -ChildPath "refs" | Join-Path -ChildPath "heads"
  $REF_HEADS = Get-ChildItem -File -Recurse "$REF_HEADS_DIR" | ForEach-Object {
    $PSItem.FullName -replace [regex]::Escape("$REF_HEADS_DIR"), '' -replace '\\', '/' -replace '^/', ''
  }

  foreach ($REF_HEAD in $REF_HEADS) {
    # Check if this branch is tracking an upstream (local/remote branch)
    $UPSTREAM = $(
      git --git-dir "$GIT_DIR" rev-parse --abbrev-ref --symbolic-full-name "$REF_HEAD@{u}" 2> $null
    )
    $HAS_UPSTREAM = $?

    if ($HAS_UPSTREAM) {
      # Branch is tracking a remote branch. Find out how much behind /
      # ahead it is of that remote branch
      $CNT_AHEAD_BEHIND = $(
        git --git-dir "$GIT_DIR" rev-list --left-right --count "$REF_HEAD...$UPSTREAM" 2> $null
      )
      $CNT_AHEAD_BEHIND -match "(?<ahead>\d+)\s+(?<behind>\d+)" > $null
      $CNT_AHEAD = $matches.ahead
      $CNT_BEHIND = $matches.behind

      if ($CNT_AHEAD -gt 0) {
        $NEEDS_PUSH_BRANCHES += $REF_HEAD
      }
      if ($CNT_BEHIND -gt 0) {
        $NEEDS_PULL_BRANCHES += $REF_HEAD
      }

      # Check if this branch is a branch off another branch and if it needs
      # to be updated
      $REV_LOCAL = $(
        git --git-dir "$GIT_DIR" rev-parse --verify "$REF_HEAD" 2> $null
      )
      $REV_REMOTE = $(
        git --git-dir "$GIT_DIR" rev-parse --verify "origin/$REF_HEAD" 2> $null
      )
      $REV_BASE = $(
        git --git-dir "$GIT_DIR" merge-base "$REF_HEAD" "origin/$REF_HEAD" 2> $null
      )

      if ("$REV_LOCAL" -ne "$REV_REMOTE") {
        if ("$REV_LOCAL" -eq "$REV_BASE") {
          $NEEDS_PULL_BRANCHES += $REF_HEAD
        }
        if ("$REV_REMOTE" -eq "$REV_BASE") {
          $NEEDS_PUSH_BRANCHES += $REF_HEAD
        }
      }

    } else {
      # Branch does not have an upstream (local/remote branch)
      $NEEDS_UPSTREAM_BRANCHES += $REF_HEAD
    }
  }

  $NEEDS_PUSH_BRANCHES = $(
    $sorted = $NEEDS_PUSH_BRANCHES | Sort-Object -Unique
    $sorted -join ", "
  )
  $NEEDS_PULL_BRANCHES = $(
    $sorted = $NEEDS_PULL_BRANCHES | Sort-Object -Unique
    $sorted -join ", "
  )
  $NEEDS_UPSTREAM_BRANCHES = $(
    $sorted = $NEEDS_UPSTREAM_BRANCHES | Sort-Object -Unique
    $sorted -join ", "
  )

  # Build up the status string
  $IS_OK = $true

  Write-Host -NoNewline "${RELATIVE_NORMALIZED_PATH}: "

  if ($NEEDS_PUSH_BRANCHES) {
    Write-Host -NoNewline -ForegroundColor DarkYellow "Needs push ($NEEDS_PUSH_BRANCHES) "
    $IS_OK = $false
  }
  if ($NEEDS_PULL_BRANCHES) {
    Write-Host -NoNewline -ForegroundColor DarkBlue "Needs pull ($NEEDS_PULL_BRANCHES) "
    $IS_OK = $false
  }
  if ($NEEDS_UPSTREAM_BRANCHES) {
    Write-Host -NoNewline -ForegroundColor DarkMagenta "Needs upstream ($NEEDS_UPSTREAM_BRANCHES) "
    $IS_OK = $false
  }

  if (($UNSTAGED -ne $true) -or ($UNCOMMITTED -ne $true)) {
    Write-Host -NoNewline -ForegroundColor DarkRed "Uncommitted changes "
    $IS_OK = $false
  }
  if ($UNTRACKED) {
    Write-Host -NoNewline -ForegroundColor DarkCyan "Untracked files "
    $IS_OK = $false
  }
  if ($STASHES -ne 0) {
    Write-Host -NoNewline -ForegroundColor Magenta "$STASHES stashes "
    $IS_OK = $false
  }

  if ($IS_OK) {
    Write-Host "ok"
  } else {
    Write-Host
  }

}
