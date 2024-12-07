#!/bin/bash

echo "Setting up kubeconfig for k3s..."

cat /etc/rancher/k3s/k3s.yaml

mkdir -p ~/.kube

sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

sudo chown $(id -u):$(id -g) ~/.kube/config

echo "kubeconfig setup completed!"

echo "Creating a secret ..."

kubectl create secret generic grafana-admin-password \
--from-literal=password='qwerty1234' \
-n jenkins

echo "Deploying Grafana using Helm..."

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install grafana bitnami/grafana \
--namespace jenkins \
--set admin.existingSecret=grafana-admin-password \
--set service.type=LoadBalancer

echo "Prometheus deployment completed!"
