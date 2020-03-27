#!/usr/bin/env sh

find -maxdepth 3 -name '*.git' -type d | xargs dirname | xargs -I'{}' git -C {} pull
