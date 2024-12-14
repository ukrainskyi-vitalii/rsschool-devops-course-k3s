#!/bin/bash

set -e

echo "Setting up kubeconfig for k3s..."

cat /etc/rancher/k3s/k3s.yaml
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config

echo "kubeconfig setup completed!"

echo "Applying ConfigMap for Alert Rules and Contact Points..."

kubectl create configmap grafana-alerts -n jenkins --from-file=grafana-alerts-configmap.yaml

if [ $? -ne 0 ]; then
  echo "Failed to apply ConfigMap for Alert Rules and Contact Points."
  exit 1
fi

echo "ConfigMap for Alert Rules and Contact Points applied."

echo "Creating a secret ..."

kubectl create secret generic grafana-admin-password \
    --from-literal=password='qwerty1234' \
    -n jenkins --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic grafana-smtp-ses -n jenkins \
    --from-literal=user='AKIAYS2NVTMHTXSXMPPP' \
    --from-literal=password='BNHF5ESsTs4VS7mpb4QgCzcp4YdTuyekA4rIdggoBiCq'
    
if [ $? -ne 0 ]; then
  echo "Failed to create secret for Grafana admin password."
  exit 1
fi

echo "Secret created successfully."

echo "Deploying Grafana using Helm..."

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm upgrade --install grafana bitnami/grafana \
    --namespace jenkins \
    -f grafana-values.yaml

if [ $? -ne 0 ]; then
  echo "Failed to deploy Grafana using Helm."
  exit 1
fi

echo "Grafana deployed successfully with ConfigMap mounted for Alert Rules and Contact Points!"

echo "Verifying deployments..."
kubectl get pods -n jenkins
kubectl get svc -n jenkins
