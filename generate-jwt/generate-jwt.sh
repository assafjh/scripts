#!/bin/bash

secret='SomeFancyBase64Secret'
issuer='SomeFancyIssuer'

decoded_secret=$(echo -n "${secret}" | base64 -d)

exp_time_start=$(date +%s)
exp_time_end=$(date +%s --date="@$((exp_time_start + 30))")

header='{"typ": "JWT","alg": "HS256"}'
payload='{"exp": '${exp_time_end}',"iss": "'${issuer}'"}'

base64_encode()
{
    declare input=${1:-$(</dev/stdin)}
    printf '%s' "${input}" | base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n'
}
hmacsha256_sign()
{
    declare input=${1:-$(</dev/stdin)}
    printf '%s' "${input}" | openssl dgst -binary -sha256 -hmac "${decoded_secret}"
}

header_base64=$(echo "${header}" | base64_encode)
payload_base64=$(echo "${payload}" | base64_encode)

header_payload=$(echo "${header_base64}.${payload_base64}")
signature=$(echo "${header_payload}" | hmacsha256_sign | base64_encode)

echo "${header_payload}.${signature}"