#!/usr/bin/env bash

#
# Copies, shrinks and uploads photos to cloud.
# Can be run multiple times on the same SOURCE and TARGET, 
# `gdrive sync upload` is also kind of idempotent.
#

# In which folder to start looking for photos recursively
# E.g. .../2014 to look for photos from year 2014
SOURCE="$1"

# Root target directory on local machine
TARGET_DIR=$HOME/fotky/fotky-Zipi-a-Tuc-na-web

# Root target directory on connected google drive
GDRIVE_DIR_ID=0B604VDf_fxQzbFNsME5wZVd2MWs

# Resolution limit
RESOLUTION=1920

# Jpeg quality in percent
QUALITY=82

# Get parent directory name
get_album_name() {
    DIRNAME=$(dirname "$1")
    BASENAME=$(basename "$DIRNAME")
    echo "$BASENAME"
}

find "$SOURCE" -type d -name "výběr" \
    | while read SOURCE_DIR; do
        ALBUM_NAME=$(get_album_name "$SOURCE_DIR")
        echo
        echo ALBUM: $ALBUM_NAME
        echo

        YEAR=$(echo "$ALBUM_NAME" | cut -d- -f1)
        TARGET_ALBUM="${TARGET_DIR}/${YEAR}/${ALBUM_NAME}"

        mkdir -p "$TARGET_ALBUM"

        find "$SOURCE_DIR" -type f -iname "*.jpg" \
            | while read SOURCE_PHOTO; do
                echo PHOTO: $SOURCE_PHOTO

                PHOTO_NAME=$(basename "$SOURCE_PHOTO")
                TARGET_PHOTO=$(echo "${TARGET_ALBUM}/${PHOTO_NAME}")

                # Copy photo (only newer or missing)
                cp --update --verbose "$SOURCE_PHOTO" "$TARGET_PHOTO"

                # Reduce size of target photo
                WIDTH=$(identify -format "%w" "$TARGET_PHOTO")
                HEIGHT=$(identify -format "%h" "$TARGET_PHOTO")
                if [ "$WIDTH" -gt "$RESOLUTION" ] || [ "$HEIGHT" -gt "$RESOLUTION" ]
                then
                    mogrify \
                        -verbose \
                        -resize "${RESOLUTION}x${RESOLUTION}>" \
                        -quality $QUALITY \
                        -auto-orient \
                        -interlace Plane \
                        "$TARGET_PHOTO"
                fi
            done
    done

# Upload
echo
gdrive sync upload "$TARGET_DIR" "$GDRIVE_DIR_ID"

