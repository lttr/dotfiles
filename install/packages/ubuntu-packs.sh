#!/usr/bin/env bash

ubuntu-packs-history() {
    zgrep -hE '^(Start-Date:|Commandline:)' $(ls -tr /var/log/apt/history.log*.gz ) | egrep -v 'aptdaemon|upgrade' | egrep -B1 '^Commandline:'
}

ubuntu-packs-installed() {
    comm -23 <( apt-mark showmanual | sort -u ) <( gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u )
}

ubuntu-packs-missing() {
    comm -13 <( ubuntu-packs-installed ) <( cat ubuntu.packs )
}

ubuntu-packs-extra() {
    comm -23 <( ubuntu-packs-installed ) <( cat ubuntu.packs )
}
