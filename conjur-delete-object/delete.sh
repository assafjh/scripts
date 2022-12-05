#!/bin/bash

[ $# -ne 2 ] && printf "expecting two parameters.\nSyntax: delete.sh <OBJECT_TYPE> <OBJECT_PATH>\n" && exit 1

SUPPORTED_OBJECT_TYPES=("variable" "policy" "webservice" "host" "user" "layer" "group")

! [[ " ${SUPPORTED_OBJECT_TYPES[*]} " =~ " ${1} " ]] && echo "Supported object types: ${SUPPORTED_OBJECT_TYPES[*]}" && exit 1

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export OBJECT_TYPE=$1
export OBJECT_PATH=$2

envsubst < $SCRIPT_DIR/delete.template > $SCRIPT_DIR/delete.yml

conjur whoami
conjur policy update -b root -f $SCRIPT_DIR/delete.yml

rm -f $SCRIPT_DIR/delete.yml
