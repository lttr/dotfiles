#!/usr/bin/env zsh

USER='lttr'

REPOS=`curl -s https://api.github.com/users/${USER}/repos`
REPOS_WITH_ISSUES=`echo "$REPOS" | json -c 'this.fork != true && this.open_issues_count > 0' -a name open_issues_count`

echo $REPOS_WITH_ISSUES | while read REPO ; do
  REPO_NAME=`echo $REPO | awk '{print $1}'`
  ISSUES_COUNT=`echo $REPO | awk '{print $2}'`
  echo "[${REPO_NAME} ${ISSUES_COUNT}]"
  curl -s "https://api.github.com/repos/lttr/${REPO_NAME}/issues" | json -c "this.state === 'open'" -a created_at title
  echo
done
