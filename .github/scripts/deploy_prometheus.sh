#!/bin/bash

echo "Setting up kubeconfig for k3s..."

cat /etc/rancher/k3s/k3s.yaml

mkdir -p ~/.kube

sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

sudo chown $(id -u):$(id -g) ~/.kube/config

echo "kubeconfig setup completed!"

echo "Deploying Prometheus using Helm..."

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install prometheus bitnami/prometheus \
  --namespace jenkins \
  --create-namespace \
  --set-file serverFiles.prometheus.yml=/home/ubuntu/prometheus-config.yaml \
  --set server.service.type=NodePort \
  --set server.service.nodePorts.http="\"32002\""

echo "Prometheus deployment completed!"
