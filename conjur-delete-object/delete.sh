#!/bin/bash

ccloud=/Applications/ConjurCloudCLI.app/Contents/Resources/conjur/conjur
onprem=conjur

cli=$onprem

[ $# -lt 3 ] && printf "expecting three parameters. for cloud cli, add 4th param with the value \"true\"\nSyntax: delete.sh <OBJECT_TYPE> <BRANCH> <OBJECT_PATH>\n delete.sh <OBJECT_TYPE> <BRANCH> <OBJECT_PATH> true\n" && exit 1

SUPPORTED_OBJECT_TYPES=("variable" "policy" "webservice" "host" "user" "layer" "group" "host-factory" )

! [[ " ${SUPPORTED_OBJECT_TYPES[*]} " =~ " ${1} " ]] && echo "Supported object types: ${SUPPORTED_OBJECT_TYPES[*]}" && exit 1

[ "$4" == "true" ] && cli=$ccloud

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export OBJECT_TYPE=$1
export BRANCH=$2
export OBJECT_PATH=$3

envsubst < $SCRIPT_DIR/delete.template > $SCRIPT_DIR/delete.yml

$cli whoami
$cli policy update -b $BRANCH -f $SCRIPT_DIR/delete.yml

rm -f $SCRIPT_DIR/delete.yml

