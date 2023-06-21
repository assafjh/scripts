#!/bin/bash

# Region
REGION=eu-west-2

# Specify the tag key and value for filtering
TAG_KEY="owner"
TAG_VALUE="ajh"

# Specify the tag key and value that needs to be added
NEW_TAG_KEY=CA_iEBSSnapretain
NEW_TAG_VALUE=active

# List EBS snapshots based on tag filter
snapshots_ids=$(aws ec2 describe-snapshots --region "$REGION" --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" --query 'Snapshots[].SnapshotId' --output text)

# Add tags to the selected volumes
if [[ -n "$snapshots_ids" ]]; then
    aws ec2 create-tags --resources $snapshots_ids --region "$REGION" --tags Key="${NEW_TAG_KEY}",Value="${NEW_TAG_VALUE}"
    echo "Tags added to the volumes: $snapshots_ids"
else
    echo "No volumes found with the specified tags."
fi
