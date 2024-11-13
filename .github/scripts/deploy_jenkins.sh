#!/bin/bash
# Create Jenkins volume directory
sudo mkdir -p /data/jenkins-volume &&
sudo chmod 777 /data/jenkins-volume &&
ls -ld /data/jenkins-volume &&

# Apply Jenkins configurations
sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml /usr/local/bin/kubectl apply -f /home/${USER_NAME}/jenkins-volume.yaml
sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml /usr/local/bin/kubectl apply -f /home/${USER_NAME}/jenkins-sa.yaml

# Install Jenkins using Helm
KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm install jenkins -n jenkins -f /home/${USER_NAME}/jenkins-values.yaml jenkins/jenkins

