#!/usr/bin/env zsh

USER='lttr'

mREPOS=$(curl -s https://api.github.com/users/${USER}/repos)

echo '[Public repos]'
echo $REPOS | json -c 'this.archived != true && this.fork != true' -e 'this.push = this.pushed_at.substring(0,10)' -a '.push' '.name' | sort -r

echo
echo '[Forked repos]'
echo $REPOS | json -c 'this.fork == true' -e 'this.push = this.pushed_at.substring(0,10)' -a '.push' '.name' | sort -r

echo
echo '[Archived repos]'
echo $REPOS | json -c 'this.archived == true' -e 'this.push = this.pushed_at.substring(0,10)' -a '.push' '.name' | sort -r

