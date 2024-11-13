#!/bin/bash
echo "${SSH_PRIVATE_KEY}" > private_key
chmod 600 private_key

echo "HOSTNAME: $HOSTNAME"
echo "USER_NAME: $USER_NAME"