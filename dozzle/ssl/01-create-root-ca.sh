#!/bin/bash
openssl req -x509 \
            -sha256 -days 3560 \
            -nodes \
            -newkey rsa:2048 \
            -subj "/CN=CN/C=IL/L=Tel-Aviv" \
            -keyout rootCA.key -out rootCA.crt 
