#!/usr/bin/env zsh

USER='lttr'

LOOKING_FOR='package.json'

REPOS=`curl -s https://api.github.com/users/${USER}/repos`
REPOS_LIST=`echo "$REPOS" | json -c 'this.fork != true' -a name`

echo $REPOS_LIST | while read REPO ; do
  RESPONSE=`curl -s "https://api.github.com/repos/lttr/${REPO_NAME}/contents/${LOOKING_FOR}"`
  echo $RESPONSE | grep -q 'Not Found'
  if [ $? -ne 0 ]; then
    echo "[${REPO}]"
    echo $RESPONSE | json content | base64 -d | json name version
  fi
  echo
done
