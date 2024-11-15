#!/bin/bash
# Install k3s
curl -sfL https://get.k3s.io | sh -

# Change permissions to allow access to k3s config
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

# Set KUBECONFIG for both kubectl and helm
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Install Helm
curl -L https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz -o helm.tar.gz &&
tar -zxvf helm.tar.gz &&
sudo mv linux-amd64/helm /usr/local/bin/helm &&
rm -rf helm.tar.gz linux-amd64 &&
helm version

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" &&
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl &&
rm kubectl &&
kubectl version --client
