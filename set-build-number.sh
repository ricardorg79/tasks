#!/bin/bash

set -e


MAJOR_MINOR=$1
BUILDNO=$2
if [ "$MAJOR_MINOR" = "" ] || [ "$BUILDNO" = "" ]; then
    echo "Usage: $0 <version> <buildno>"
    echo "  e.g: $0 1.2 11"
    echo ""
    exit 1
fi
DATATAG="refs/tags/data/v$MAJOR_MINOR"


NEWHASH=$(echo "$BUILDNO" | git hash-object -w --stdin)
git update-ref $DATATAG $NEWHASH
git push origin :$DATATAG
git push origin --tags

