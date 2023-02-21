#!/bin/bash
# This script will check connection to the deployed postgres server that was deployed at script #2
# Make sure to edit .env before running this script
#================ Internal ==============
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) 
source $SCRIPT_DIR/.env
#================ Script ==============
$SUDO $CONTAINER_MGR run --rm -it -e PGPASSWORD=${POSTGRES_PASSWORD} postgres:11.2 \
  psql -U ${POSTGRES_USER} "postgres://${REMOTE_DB_HOST}/postgres" -c "\du"

