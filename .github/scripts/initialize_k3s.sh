#!/bin/bash
# Add Jenkins Helm repository
/usr/local/bin/helm repo remove jenkins || true &&
/usr/local/bin/helm repo add jenkins https://charts.jenkins.io &&
/usr/local/bin/helm repo update &&
/usr/local/bin/helm search repo jenkins || exit 1 && 

# Wait for k3s to initialize fully
until sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml /usr/local/bin/kubectl get nodes; do
  echo 'Waiting for k3s server to be ready...'
  sleep 10
done &&

# Create Jenkins namespace and set context
sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml /usr/local/bin/kubectl create namespace jenkins || true &&
sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml /usr/local/bin/kubectl config set-context --current --namespace=jenkins &&
sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml /usr/local/bin/kubectl get namespaces
