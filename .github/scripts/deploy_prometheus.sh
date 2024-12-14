#!/bin/bash

echo "Setting up kubeconfig for k3s..."

cat /etc/rancher/k3s/k3s.yaml

mkdir -p ~/.kube

sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

sudo chown $(id -u):$(id -g) ~/.kube/config

echo "kubeconfig setup completed!"

echo "Deploying Prometheus using Helm..."

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

echo "Deploying Prometheus using Helm..."
helm install prometheus bitnami/prometheus \
   --namespace jenkins \
   --set server.service.type=NodePort \
   --set-string server.service.nodePorts.http=32002

echo "Prometheus deployment completed!"

echo "Deploying kube-state-metrics using Helm..."
helm install kube-state-metrics prometheus-community/kube-state-metrics \
   --namespace jenkins

echo "kube-state-metrics deployment completed!"

echo "Deploying node-exporter using Helm..."
helm install node-exporter prometheus-community/prometheus-node-exporter \
   --namespace jenkins

echo "node-exporter deployment completed!"

echo "Verifying deployments..."
kubectl get pods -n jenkins
kubectl get svc -n jenkins

echo "All components are successfully deployed!"
