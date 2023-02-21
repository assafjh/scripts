#!/bin/bash
# This script will create infra for postgres deployment
# Make sure to edit .env before running this script
#================ Internal ==============
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) 
source $SCRIPT_DIR/.env
#================ Script ==============
# Create namespace
$COP_CLI create namespace $NAMESPACE
# Create self-signed certificate for Postgres
CA_CN=postgres-db KEY_FILE_NAME=server.key CERTIFICATE_FILE_NAME=server.crt "$SCRIPT_DIR"/../../tools/01-create-root-ca.sh
# Store the certificate files as Kubernetes secrets
$COP_CLI --namespace $NAMESPACE \
  create secret generic \
  $NAMESPACE-certs \
  --from-file="$SCRIPT_DIR"/../../certs/server.crt \
  --from-file="$SCRIPT_DIR"/../../certs/server.key
