#!/usr/bin/env bash

# Run snippet of given java code inside a main method.

if [ -z "$1" ]
    then echo "Please pass some java code as the first parameter"
    return
fi

TEMP_CLASS_NAME="JAVAS_$$_$(date +'%y%d%m%s')"
TEMP_FILE="/tmp/$TEMP_CLASS_NAME.java"

echo "public class $TEMP_CLASS_NAME \
{ public static void main(String[] args) { $1 } }" > $TEMP_FILE

javac $TEMP_FILE
cd /tmp
java $TEMP_CLASS_NAME
cd - > /dev/null

rm -rf $TEMP_FILE
rm -rf "/tmp/$TEMP_CLASS_NAME.class"
