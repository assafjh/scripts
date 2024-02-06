#!/bin/bash
# This script will deploy a v2 registry and will generate a self signed certificate for registry usage

#================ Internal ==============
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/.functions

DATA_DIR="$HOME/registry"
GENERATE_CERTIFICATES_SCRIPTS_DIR=$SCRIPT_DIR/../generate-self-signed-certificate

#================ Variables ==============
REGISTRY_PORT=5443
CA_CN="Local Certificate Authority"
REGISTRY_CN="Local Registry"
REGISTRY_SUBJECT_ALT_NAMES="
[alt_names]
DNS.1 = $(hostname -s)
DNS.2 = $(hostname -f)
$(create_san_ip_list)
"

#================ Script ==============
[ ! -d "$GENERATE_CERTIFICATES_SCRIPTS_DIR" ] && { echo "Scripts folder $GENERATE_CERTIFICATES_SCRIPTS_DIR is missing"; exit 1; }
[ ! -d "$SCRIPT_DIR/certs/registry" ] && mkdir -p "$SCRIPT_DIR"/certs/registry
[ ! -d "$DATA_DIR" ] && mkdir -p "$DATA_DIR"

BYPASS_CA_CN="$CA_CN" BYPASS_OUTPUT_FOLDER_PATH="$SCRIPT_DIR/certs" "$GENERATE_CERTIFICATES_SCRIPTS_DIR"/01-create-root-ca.sh
BYPASS_SERVER_CN="$REGISTRY_CN" BYPASS_OUTPUT_FOLDER_PATH="$SCRIPT_DIR/certs" BYPASS_SERVER_KEY_FILE_PATH="$SCRIPT_DIR/certs/registry/docker-registry.key" "$GENERATE_CERTIFICATES_SCRIPTS_DIR"/02-create-self-signed-certificate.sh
BYPASS_SERVER_KEY_FILE_PATH="$SCRIPT_DIR/certs/registry/docker-registry.key" BYPASS_OUTPUT_FOLDER_PATH="$SCRIPT_DIR/certs" BYPASS_SUBJECT_ALT_NAMES="$REGISTRY_SUBJECT_ALT_NAMES" "$GENERATE_CERTIFICATES_SCRIPTS_DIR"/03-generate-csr.sh
BYPASS_CA_CERTIFICATE_FILE_PATH="$SCRIPT_DIR/certs/rootCA.pem" BYPASS_CA_KEY_FILE_PATH="$SCRIPT_DIR/certs/rootCA.key" BYPASS_OUTPUT_FOLDER_PATH="$SCRIPT_DIR/certs" BYPASS_SERVER_CERTIFICATE_FILE_PATH="$SCRIPT_DIR/certs/registry/docker-registry.crt" "$GENERATE_CERTIFICATES_SCRIPTS_DIR"/04-sign-csr.sh

docker run -d \
    --restart=always \
    --name registry \
    -v "$SCRIPT_DIR"/certs/registry:/certs \
    -v "$DATA_DIR":/var/lib/registry \
    -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/docker-registry.crt \
    -e REGISTRY_HTTP_TLS_KEY=/certs/docker-registry.key \
    -p "$REGISTRY_PORT":443 \
    registry:2
