#!/bin/bash
# This version will create a self signed certificate and will sign the request with an EXISTING CA
#=========== Variables ===============
CA_PUB=ca.pem
CA_KEY=ca.key
PRIV_KEY_FILE_NAME=rootCA.key
SIGNED_CERT_FILE_NAME=server.crt
#=========== Script ===============
openssl req -new -nodes -newkey rsa:2048 -keyout "$PRIV_KEY_FILE_NAME" -out server.csr -config csr.conf
openssl x509 -req -in server.csr -CA "$CA_PUB" -CAkey "$CA_KEY" -CAcreateserial -out "$SIGNED_CERT_FILE_NAME" -days 3650 -sha256 -extfile csr.conf