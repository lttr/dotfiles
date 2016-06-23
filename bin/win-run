#!/usr/bin/env bash
( VirtualBox --startvm "$(vboxmanage list vms | grep "win10" | sed 's/.*{\(.*\)}/\1/')" &>/dev/null & )

