#!/bin/bash

# Vanilla
CA_PRIV_KEY=/etc/kubernetes/pki/ca.key
CA_PUB_KEY=/etc/kubernetes/pki/ca.crt
# Rancher
#CA_PRIV_KEY=/var/lib/rancher/k3s/server/tls/client-ca.key
#CA_PUB_KEY=/var/lib/rancher/k3s/server/tls/client-ca.crt

openssl genrsa -out assaf.key 2048
openssl req -new -key assaf.key -out assaf.csr
sudo openssl x509 -req -in assaf.csr -CA "$CA_PUB_KEY" -CAkey "$CA_PRIV_KEY" -CAcreateserial -out assaf.crt -days 3650
