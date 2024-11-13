#!/bin/bash
# Add Jenkins Helm repository
helm repo remove jenkins || true
helm repo add jenkins https://charts.jenkins.io
helm repo update

# Wait for k3s to initialize fully
until sudo kubectl get nodes; do
  echo 'Waiting for k3s server to be ready...'
  sleep 5
done

# Create Jenkins namespace and set context
sudo kubectl create namespace jenkins || true
sudo kubectl config set-context --current --namespace=jenkins
sudo kubectl get namespaces
