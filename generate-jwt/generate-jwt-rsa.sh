#!/bin/bash

openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout ./privateKey2.key -out ./certificate2.crt
openssl rsa  -pubout -in ./privateKey2.key > ./publicKey2.key

cat header.txt | tr -d '\n' | tr -d '\r' | base64 | tr +/ -_ | tr -d '=' > header.b64
cat payload.txt | tr -d '\n' | tr -d '\r' | base64 | tr +/ -_ |tr -d '=' > payload.b64
printf "%s" "$(<header.b64)" "." "$(<payload.b64)" > unsigned.b64
rm header.b64
rm payload.b64
openssl dgst -sha256 -sign -privateKey2.key -out sig.txt unsigned.b64
cat sig.txt | base64 | tr +/ -_ | tr -d '=' > sig.b64
printf "%s" "$(<unsigned.b64)" "." "$(<sig.b64)" > jwt.txt
rm unsigned.b64
rm sig.b64
rm sig.txt
