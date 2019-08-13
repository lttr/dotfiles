#!/usr/bin/env sh

SCRIPTS=$HOME/dotfiles/scripts
BIN=$HOME/bin

# find all executable shell scripts in scripts folder
# and symlink them according to their names
# NAME is filename without path and extension
find $SCRIPTS -type f -name "*sh" -executable \
| while read EXE; do \
    NAME=${EXE##*/};
    NAME=${NAME%.*};
    LINK=$BIN/$NAME
    if [ -f $LINK ]; then
        if [ "$(readlink $LINK)" = "$EXE" ]; then
            echo "$LINK already exists"
        else
            echo "$LINK already exists but is a regular file!"
        fi
    else
        echo "Creating link $LINK -> $EXE"
        ln -s $EXE $BIN/$NAME;
    fi
done

exit 0
