#!/bin/bash

# Region
REGION=eu-west-2

# Specify the tag key and value for filtering
TAG_KEY="owner"
TAG_VALUE="ajh"

# Specify the tag key and value that needs to be added
NEW_TAG_KEY=CA_iEC2Retain
NEW_TAG_VALUE=active

# List EC2 instances based on tag filter
instance_ids=$(aws ec2 describe-instances --region "$REGION" --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" --query 'Reservations[].Instances[].InstanceId' --output text)

# Add tags to the selected instances
if [[ -n "$instance_ids" ]]; then
    aws ec2 create-tags --resources $instance_ids --region "$REGION" --tags Key="${NEW_TAG_KEY}",Value="${NEW_TAG_VALUE}"
    echo "Tags added to the instances: $instance_ids"
else
    echo "No instances found with the specified tags."
fi
