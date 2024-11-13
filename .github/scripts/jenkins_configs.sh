#!/bin/bash
echo "HOSTNAME: $HOSTNAME"
echo "USER_NAME: $USER_NAME"

# Copy jenkins-volume.yaml and verify
scp -o StrictHostKeyChecking=no -i private_key helm-configs/jenkins-volume.yaml ${USER_NAME}@${HOSTNAME}:/home/${USER_NAME}/jenkins-volume.yaml
ssh -o StrictHostKeyChecking=no -i private_key ${USER_NAME}@${HOSTNAME} "test -f /home/${USER_NAME}/jenkins-volume.yaml && echo 'jenkins-volume.yaml copied successfully' || echo 'Error: jenkins-volume.yaml not found'"

# Copy jenkins-sa.yaml and verify
scp -o StrictHostKeyChecking=no -i private_key helm-configs/jenkins-sa.yaml ${USER_NAME}@${HOSTNAME}:/home/${USER_NAME}/jenkins-sa.yaml
ssh -o StrictHostKeyChecking=no -i private_key ${USER_NAME}@${HOSTNAME} "test -f /home/${USER_NAME}/jenkins-sa.yaml && echo 'jenkins-sa.yaml copied successfully' || echo 'Error: jenkins-sa.yaml not found'"

# Copy jenkins-values.yaml and verify
scp -o StrictHostKeyChecking=no -i private_key helm-configs/jenkins-values.yaml ${USER_NAME}@${HOSTNAME}:/home/${USER_NAME}/jenkins-values.yaml
ssh -o StrictHostKeyChecking=no -i private_key ${USER_NAME}@${HOSTNAME} "test -f /home/${USER_NAME}/jenkins-values.yaml && echo 'jenkins-values.yaml copied successfully' || echo 'Error: jenkins-values.yaml not found'"
