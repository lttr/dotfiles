#!/usr/bin/env sh

REPO=web-start-single
TARGET="$1"

if [ -z $TARGET ]; then
    echo "Expecting name as first argument"
    exit 1
fi

git clone https://github.com/lttr/$REPO "$TARGET"

cd "$TARGET"

rm -rf .git

TITLE=$(echo "$TARGET" | sed 's/-/\ /g')

sed -i "s#<title></title>#<title>$TITLE</title>#" index.html

sed -i "1 s/.*/# $TITLE/" README.md

