#!/bin/bash

set -e

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
git tag -d $LOCALTAG 1>& 2>/dev/null || true
git fetch --tags 1>&2

# Does tag exist 0 if it exists, 1 otherwise
set +e
COMMIT=$(git rev-parse --quiet --verify $DATATAG)
exist=$?
set -e
if [ "$exist" = "0" ]; then
    BUILDNO=$(git cat-file -p $COMMIT)
fi

if [ "$BUILDNO" = "" ]; then
    BUILDNO="0" # so it starts at 0 when incremented
fi

# Increment
echo $BUILDNO
