#!/bin/bash

MAJOR_MINOR=$1
if [ "$MAJOR_MINOR" = "" ]; then
    echo "Usage: $0 <version>"
    echo "  e.g: $0 1.2"
    echo ""
    exit 1
fi
DATATAG="refs/tags/data/v$MAJOR_MINOR"
LOCALTAG="data/v$MAJOR_MINOR"

# delete local tag if exists and update
git tag -d $LOCALTAG
git fetch --tags

# Does tag exist 0 if it exists, 1 otherwise
COMMIT=`git rev-parse --quiet --verify $DATATAG`
exist=$?
if [ "$exist" = "0" ]; then
    BUILDNO=$(git cat-file -p $COMMIT)
fi

if [ "$BUILDNO" = "" ]; then
    BUILDNO="-1" # so it starts at 0 when incremented
fi

# Increment
BUILDNO=$((BUILDNO+1))

# Save back into database
NEWHASH=$(echo "$BUILDNO" | git hash-object -w --stdin)
git update-ref $DATATAG $NEWHASH
git push origin :$DATATAG
git push origin --tags

echo "$MAJOR_MINOR.$BUILDNO"
