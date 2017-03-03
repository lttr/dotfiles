#!/usr/bin/env bash

# Run snippet of given jshell code within jshell session

if [ -z "$1" ]
    then echo "Please pass some jshell code as the first parameter"
    return
fi

TEMP_FILE_NAME="JAVAI_$$_$(date +'%y%d%m%s')"
TEMP_FILE="/tmp/$TEMP_FILE_NAME.java"

echo "$1" > $TEMP_FILE

u9
jshell --startup $TEMP_FILE
