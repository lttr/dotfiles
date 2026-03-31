#!/bin/bash

CURRENT_DIR_PATH=$(cd `dirname $0` && pwd)
CURRENT_DIR_NAME=$(basename "$CURRENT_DIR_PATH")

# -f = print full path
# --noreport = omits summary
# -I '' = excludes some files
# --charset ascii = simplify output charset

tree=$(tree -f -I '*~' --noreport --charset ascii $1 |
       sed -e 's/| \+/  /g' \
           -e 's/[|`]-\+/ */g' \
           -e 's:\(* \)\(\(.*/\)\([^/]\+\)\):\1[\4](\2):g' \
           -e '/^\.$/d' \
       )

printf "# $CURRENT_DIR_NAME\n\n${tree}"

