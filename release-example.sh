#!/bin/bash

#exit on error
set -e

feed=rhamerica
organization=https://dev.azure.com/rhamerica

package=$1

if [ "$package" = "" ]; then
    echo ""
    echo "Usage: $0 <package>"
    echo ""
    exit 1
fi


#
# Extract Major Minor from pom file
#   e.g.: 1.0
#
majorMinor=$(python3 -c 'from xml.dom.minidom import parse;  print(parse("pom.xml").getElementsByTagName("majorMinor")[0].firstChild.data)')

#
# Calculate next build number for majorMinor
#
BUILDNO=$(./get-build-number.sh $majorMinor)
BUILDNO=$((BUILDNO + 1))
./set-build-number.sh $majorMinor $BUILDNO


#
# construct full version
#   e.g.: 1.0.22
MAJOR_MINOR_BUILDNO="$majorMinor.$BUILDNO"


#
# Export variable in azure devops
#
echo "##vso[task.setvariable variable=BUILDNO;isOutput=true]$BUILDNO"
echo "##vso[task.setvariable variable=MAJOR_MINOR_BUILDNO;isOutput=true]$MAJOR_MINOR_BUILDNO"



# release package
az artifacts universal publish --organization $organization --feed $feed --name mypackage --version $MAJOR_MINOR_BUILDNO --description "release" --path src/

