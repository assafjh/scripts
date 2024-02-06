#!/bin/bash
# This script will generate a certificate for usage with your application
# Make sure to edit .env before running this script
#================ Internal ==============
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) 
source $SCRIPT_DIR/.env
#================ Script ==============

[ -n "$BYPASS_OUTPUT_FOLDER_PATH" ] && OUTPUT_FOLDER_PATH="$BYPASS_OUTPUT_FOLDER_PATH"
[ -n "$BYPASS_SERVER_KEY_FILE_PATH" ] && SERVER_KEY_FILE_PATH="$BYPASS_SERVER_KEY_FILE_PATH"
[ -n "$BYPASS_SERVER_CN" ] && SERVER_CN="$BYPASS_SERVER_CN"

cd "$OUTPUT_FOLDER_PATH" || exit 1

openssl genrsa -out "$SERVER_KEY_FILE_PATH" 2048
cat > csr.conf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
C = IL
ST = Hamerkaz
L = Tel-Aviv
O = Org
OU = DevSecOps
CN = ${SERVER_CN}

EOF
