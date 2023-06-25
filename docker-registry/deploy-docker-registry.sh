#!/bin/bash
docker run -d \
    --restart=always \
    --name registry \
    -v $(pwd)/certs:/certs \
    -e REGISTRY_HTTP_ADDR=0.0.0.0:5443 \
    -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/server.pem \
    -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \
    -p 5443:443 \
    registry:latest
