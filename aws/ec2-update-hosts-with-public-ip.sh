#!/bin/bash

# Scripts locates all public IP for running instances under specified Tag and modifies etc hosts
# $1 bypasses TAG_NAME, $2 bypasses TAG_VALUE

# Region
AWS_REGION=eu-west-2
# Tag Name
TAG_NAME=Owner
# Tag Value
TAG_VALUE=ajh

# Specify the file to modify
HOSTS_FILE_PATH=/etc/hosts

if [ -n "$1" ]  && [ -n "$2" ]
then
    TAG_NAME="${1}"
    TAG_VALUE="${2}"
fi
    

# List EC2 instances details based on tag filter
INSTANCE_LIST=$(aws ec2 describe-instances --region "${AWS_REGION}" \
--filters "Name=tag:${TAG_NAME},Values=${TAG_VALUE}" \
"Name=instance-state-name,Values=running" \
--query 'Reservations[].Instances[].[ PublicIpAddress, Tags[?Key==`Name`].Value | [0], join(``,[Tags[?Key==`Name`].Value | [0],`.local`]) ]' \
--output text)

# Saving a backup file
cp $HOSTS_FILE_PATH $HOSTS_FILE_PATH.backup

while IFS= read -r LINE; do
    INSTANCE_NAME=$(echo "$LINE" | awk '{print $2}')
    sed -i '' "/${INSTANCE_NAME}/d" "$HOSTS_FILE_PATH"
done <<< "$INSTANCE_LIST"

# Appending to file
echo "${INSTANCE_LIST}" >> $HOSTS_FILE_PATH