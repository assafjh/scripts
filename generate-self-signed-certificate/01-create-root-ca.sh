#!/bin/bash
# This script will generate a Root Certificate for local CA purpose
# Make sure to edit .env before running this script
#================ Internal ==============
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) 
source $SCRIPT_DIR/.env
#================ Script ==============
[ -n "$BYPASS_OUTPUT_FOLDER_PATH" ] && OUTPUT_FOLDER_PATH="$BYPASS_OUTPUT_FOLDER_PATH"
[ ! -d "$OUTPUT_FOLDER_PATH" ] && mkdir "$OUTPUT_FOLDER_PATH"

[ -n "$BYPASS_CA_CN" ] && CA_CN="$BYPASS_CA_CN"

cd "$OUTPUT_FOLDER_PATH" || exit 1

openssl req -x509 \
            -sha256 -days 3560 \
            -nodes \
            -newkey rsa:2048 \
            -subj "/CN=$CA_CN/C=IL/L=Tel-Aviv" \
            -keyout rootCA.key -out rootCA.pem 
