#!/bin/bash

set -e

echo "Setting up kubeconfig for k3s..."

cat /etc/rancher/k3s/k3s.yaml
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config

echo "kubeconfig setup completed!"

echo "Applying ConfigMap for Alert Rules and Contact Points..."

CONFIGMAP_PATH="$(dirname "$0")/../config/grafana-alerts-configmap.yaml"
echo "Resolved CONFIGMAP_PATH: $CONFIGMAP_PATH"

if [ -f "$CONFIGMAP_PATH" ]; then
  kubectl apply -f "$CONFIGMAP_PATH"
  echo "ConfigMap for Alert Rules and Contact Points applied."
else
  echo "ConfigMap file not found: $CONFIGMAP_PATH"
  exit 1
fi

echo "ConfigMap for Alert Rules and Contact Points applied."

echo "Creating a secret ..."

kubectl create secret generic grafana-admin-password \
--from-literal=password='qwerty1234' \
-n jenkins --dry-run=client -o yaml | kubectl apply -f -

if [ $? -ne 0 ]; then
  echo "Failed to create secret for Grafana admin password."
  exit 1
fi

echo "Secret created successfully."

echo "Deploying Grafana using Helm..."

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm upgrade --install grafana oci://registry-1.docker.io/bitnamicharts/grafana \
--namespace jenkins \
--set persistence.enabled=true \
--set persistence.size=2Gi \
--set admin.existingSecret=grafana-admin-password \
--set service.type=LoadBalancer \
--set service.port=30125 \
--set smtp.enabled=true \
--set smtp.host=email-smtp.eu-west-1.amazonaws.com:587 \
--set smtp.user=AKIAYS2NVTMHTXSXMPPP \
--set smtp.password=BNHF5ESsTs4VS7mpb4QgCzcp4YdTuyekA4rIdggoBiCq \
--set smtp.fromAddress=alerts@example.com \
--set smtp.fromName="Grafana Alerts" \
--set extraVolumes[0].name=grafana-alerts \
--set extraVolumes[0].configMap.name=grafana-alerts \
--set extraVolumeMounts[0].name=grafana-alerts \
--set extraVolumeMounts[0].mountPath=/etc/grafana/alerts

if [ $? -ne 0 ]; then
  echo "Failed to deploy Grafana using Helm."
  exit 1
fi

echo "Grafana deployed successfully with ConfigMap mounted for Alert Rules and Contact Points!"
