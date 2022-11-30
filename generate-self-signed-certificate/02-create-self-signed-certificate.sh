#!/bin/bash
openssl genrsa -out server.key 2048
cat > csr.conf <<EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = IL
ST = Hamerkaz
L = Tel-Aviv
O = Org
OU = DevSecOps
CN = CN

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = localhost
DNS.2 = dns2
IP.1 = 127.0.0.1

EOF
