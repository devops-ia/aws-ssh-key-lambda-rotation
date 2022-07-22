#!/bin/bash

USERS=('ec2-user' 'ubuntu' 'admin')
BUCKET=$1
PREFIX=$2
LOOP=$3
SLEEP=$4
COUNTER=0

_instances_configure() {
    echo "[INFO] Instance Configure"
    
    while [[ ! $(aws s3api head-object --bucket $BUCKET --key instances/$PREFIX/key.pub) ]]; do
        COUNTER=$((COUNTER+1))
        sleep $SLEEP
        if [[ "$COUNTER" == "$LOOP" ]]; then
            echo "[INFO] The file does not exist in the $BUCKET after $COUNTER attempts"
            exit 1
        fi
    done

    echo "[INFO] Download Public Key from AWS $BUCKET"
    aws s3 cp s3://$BUCKET/instances/$PREFIX/key.pub /home/$USER/.ssh/authorized_keys
    echo -e "\n" >> /home/$USER/.ssh/authorized_keys
    
    echo "[INFO] Set 600 permissions to /home/$USER/.ssh/authorized_keys"
    chmod 600 /home/$USER/.ssh/authorized_keys

    echo "[INFO] Set $USER:$USER to /home/$USER/.ssh/authorized_keys"
    chown $USER:$USER /home/$USER/.ssh/authorized_keys
}

##
# MAIN
##

echo "[INFO] Init instance configure"

for USER in ${USERS[@]}; do
    if id $USER &>/dev/null; then
        echo "[INFO] AMI User is: $USER"
        _instances_configure $USER
    else
        echo "[INFO] User: $USER does not exist."
    fi
done
