#!/bin/bash
openssl req -new -key server.key -out server.csr -config csr.conf
cat > cert.conf <<EOF

authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = dns1
DNS.2 = dns2

EOF
