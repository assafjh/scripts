#!/bin/bash
# This script will create a dummy database for the demo
# Make sure to edit .env before running this script
#================ Internal ==============
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) 
source $SCRIPT_DIR/.env
#================ Script ==============
$SUDO $CONTAINER_MGR run --rm -i -e PGPASSWORD=${POSTGRES_PASSWORD} postgres:11.2 \
    psql -U ${POSTGRES_USER} "postgres://${REMOTE_DB_HOST}/postgres" \
    << EOSQL

CREATE DATABASE ${APPLICATION_DB_NAME};

/* connect to it */

\c ${APPLICATION_DB_NAME};

CREATE TABLE pets (
  id serial primary key,
  name varchar(256)
);

/* Create Application User */

CREATE USER ${APPLICATION_DB_USER} PASSWORD '${APPLICATION_DB_INITIAL_PASSWORD}';

/* Grant Permissions */

GRANT SELECT, INSERT ON public.pets TO ${APPLICATION_DB_USER};
GRANT USAGE, SELECT ON SEQUENCE public.pets_id_seq TO ${APPLICATION_DB_USER};
EOSQL
