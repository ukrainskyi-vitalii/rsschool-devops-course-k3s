#!/bin/bash
# Add Jenkins Helm repository
helm repo remove jenkins || true
helm repo add jenkins https://charts.jenkins.io
helm repo update

# Wait for k3s to initialize fully
until kubectl get nodes; do
  echo 'Waiting for k3s server to be ready...'
  sleep 10
done

# Create Jenkins namespace and set context
kubectl create namespace jenkins || true
kubectl config set-context --current --namespace=jenkins
kubectl get namespaces
