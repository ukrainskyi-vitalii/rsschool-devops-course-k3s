#!/bin/bash

echo "Deploying Prometheus using Helm..."

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install prometheus bitnami/prometheus \
  --namespace jenkins \
  --create-namespace \
  --set-file serverFiles.prometheus.yml=/home/ubuntu/prometheus-config.yaml \
  --set server.service.type=NodePort \
  --set server.service.nodePorts.http=32002

echo "Prometheus deployment completed!"
