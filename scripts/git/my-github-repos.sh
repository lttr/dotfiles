#!/usr/bin/env zsh

USER='lttr'

echo '[Public repos]'
curl -s https://api.github.com/users/${USER}/repos | json -c 'this.fork != true' -a name

echo
echo '[Forked repos]'
curl -s https://api.github.com/users/${USER}/repos | json -c 'this.fork == true' -a name
