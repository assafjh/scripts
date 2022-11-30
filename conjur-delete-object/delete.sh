#!/bin/bash

[ $# -ne 2 ] && printf "expecting two parameters.\nSyntax: delete.sh <OBJECT_TYPE> <OBJECT_PATH>\n" && exit 1

SUPPORTED_OBJECT_TYPES=("variable" "policy" "webservice" "host" "user" "layer" "group")

! [[ " ${SUPPORTED_OBJECT_TYPES[*]} " =~ " ${1} " ]] && echo "Supported object types: ${SUPPORTED_OBJECT_TYPES[*]}" && exit 1

export OBJECT_TYPE=$1
export OBJECT_PATH=$2

envsubst < delete.template > delete.yml

conjur whoami
conjur policy update -b root -f delete.yml

rm -f delete.yml