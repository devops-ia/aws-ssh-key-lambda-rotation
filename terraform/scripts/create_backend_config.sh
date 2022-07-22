#!/bin/bash

BUCKET=$1
REGION=$2

aws s3api create-bucket                                       \
    --bucket $BUCKET                                          \
    --region $REGION                                          \
    --create-bucket-configuration LocationConstraint=$REGION