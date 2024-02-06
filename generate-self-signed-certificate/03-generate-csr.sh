#!/bin/bash
# This script will generate a csr for the certificate generated at script #02
# Make sure to edit .env before running this script
#================ Internal ==============
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) 
source $SCRIPT_DIR/.env
#================ Script ==============
[ -n "$BYPASS_OUTPUT_FOLDER_PATH" ] && OUTPUT_FOLDER_PATH="$BYPASS_OUTPUT_FOLDER_PATH"
[ -n "$BYPASS_SERVER_KEY_FILE_PATH" ] && SERVER_KEY_FILE_PATH="$BYPASS_SERVER_KEY_FILE_PATH"
[ -n "$BYPASS_SUBJECT_ALT_NAMES" ] && SUBJECT_ALT_NAMES="$BYPASS_SUBJECT_ALT_NAMES"

cd "$OUTPUT_FOLDER_PATH" || exit 1

openssl req -new -key "$SERVER_KEY_FILE_PATH" -out server.csr -config csr.conf

cat > cert.conf <<EOF

authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

${SUBJECT_ALT_NAMES}

EOF

