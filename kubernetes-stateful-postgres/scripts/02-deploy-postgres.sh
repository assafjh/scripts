#!/bin/bash
# This script will deploy postgres
# Make sure to edit .env before running this script
#================ Internal ==============
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) 
set -o allexport && source $SCRIPT_DIR/.env && set +o allexport
#================ Script ==============
# Deploying Postgres
envsubst < "$SCRIPT_DIR"/../manifests/01-postgres-deployments.template.yml > "$SCRIPT_DIR"/../manifests/01-postgres-deployments.yml
$COP_CLI --namespace $NAMESPACE apply -f $SCRIPT_DIR/../manifests/01-postgres-deployments.yml