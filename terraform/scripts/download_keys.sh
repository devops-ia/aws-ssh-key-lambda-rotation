#!/bin/bash

#BUCKET=$1
BUCKET=$1

_download() {
  if aws s3api head-object --bucket $BUCKET --key instances/current/key.pem &>/dev/null; then
    mkdir -p ./key_pairs
    aws s3 cp s3://$BUCKET/instances/current/key.pem ./key_pairs/instance_key.pem
    chmod 400 key_pairs/*.pem
  else
    echo "Objects do not exist for $BUCKET"
  fi
}

_download
