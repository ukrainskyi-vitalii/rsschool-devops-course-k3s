#!/bin/bash
echo "HOSTNAME: $HOSTNAME"
echo "USER_NAME: $USER_NAME"

scp -o StrictHostKeyChecking=no -i private_key helm-configs/jenkins-volume.yaml ${USER_NAME}@${HOSTNAME}:/home/${USER_NAME}/jenkins-volume.yaml
scp -o StrictHostKeyChecking=no -i private_key helm-configs/jenkins-sa.yaml ${USER_NAME}@${HOSTNAME}:/home/${USER_NAME}/jenkins-sa.yaml
scp -o StrictHostKeyChecking=no -i private_key helm-configs/jenkins-values.yaml ${USER_NAME}@${HOSTNAME}:/home/${USER_NAME}/jenkins-values.yaml
