#!/bin/bash
# Create Jenkins volume directory
sudo mkdir -p /data/jenkins-volume
sudo chmod 777 /data/jenkins-volume

# Apply Jenkins configurations
kubectl apply -f /home/${USER_NAME}/jenkins-volume.yaml
kubectl apply -f /home/${USER_NAME}/jenkins-sa.yaml

# Install Jenkins using Helm
helm install jenkins -n jenkins -f /home/${USER_NAME}/jenkins-values.yaml jenkins/jenkins

