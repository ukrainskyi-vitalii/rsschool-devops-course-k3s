# DevOps Course. Terraform Infrastructure for AWS with GitHub Actions

# Task 9: Alertmanager Configuration and Verification

## Alertmanager Setup and Alert Configuration

## Objective
This document describes the steps to set up alerting in Grafana using Prometheus as the data source. Alerts are configured to monitor CPU utilization and RAM capacity in a Kubernetes cluster, with notifications sent via email using AWS SES.

## Prerequisites
1. Kubernetes cluster with Prometheus and Grafana installed.
2. Node Exporter and Kube State Metrics installed for monitoring metrics.
3. AWS SES verified email address for sending alerts.

## Step 1: Configure Grafana SMTP
- Create a secret for the Grafana admin password:

```bash
kubectl create secret generic grafana-admin-password \
--from-literal=admin-password=GrafanaAdminPassword \
-n jenkins
```
- Install Grafana using Helm:
```bash
helm upgrade --install grafana oci://registry-1.docker.io/bitnamicharts/grafana \
    --namespace jenkins \
    --set persistence.enabled=true \
    --set persistence.size=2Gi \
    --set admin.existingSecret=grafana-admin-password \
    --set service.type=LoadBalancer \
    --set service.port=30125 \
    --set smtp.enabled=true \
    --set smtp.host=email-smtp.eu-west-1.amazonaws.com:587 \
    --set smtp.user=<AWS_SES_SMTP_USER> \
    --set smtp.password=<AWS_SES_SMTP_PASSWORD> \
    --set smtp.fromAddress=<YOUR_VERIFIED_EMAIL> \
    --set smtp.fromName="Grafana Alerts"
```
- Retrieve the LoadBalancer IP
```bash
kubectl get svc -n jenkins
```

Open Grafana in your browser at http://#LoadBalancer-IP#:30125

- Test SMTP settings. Navigate to Alerting → Contact points → Test notification in Grafana.

## Step 2: Create a CPU Utilization Alert

1. Create a new alert:
- Navigate to Alerting → Alert rules → New alert rule.
- Use the following PromQL query:
promql

```bash
sum(rate(node_cpu_seconds_total{mode!="idle"}[5m])) by (instance) / sum(rate(node_cpu_seconds_total[5m])) by (instance) * 100
```

2. Set threshold conditions:
- Trigger an alert when CPU usage exceeds 80%:
```bash
WHEN avg() OF query IS ABOVE 80
```
3. Set evaluation parameters:
- Evaluate every: 1m.
- For: 3m.

4. Save the alert:
- Name the alert: High CPU Usage Alert.

## Step 3: Create a Memory Utilization Alert

1. Create a new alert:
- Navigate to Alerting → Alert rules → New alert rule.
- Use the following PromQL query:
promql

```bash
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

2. Set threshold conditions:
- Trigger an alert when memory usage exceeds 80%:
```bash
WHEN avg() OF query IS ABOVE 80
```
3. Set evaluation parameters:
- Evaluate every: 1m.
- For: 3m.

4. Save the alert:
- Name the alert: High Memory Usage Alert.

## Step 4: Test Alerts
1. Test CPU Alert:
- Run the following stress test to simulate high CPU usage:
```bash
stress --cpu 4 --timeout 300
```
2. Test Memory Alert:
- Run the following stress test to simulate high memory usage:
```bash
stress --vm 1 --vm-bytes 90% --timeout 300
```
3. Verify Alerts:
- Navigate to Alerting → Active alerts in Grafana and ensure the alerts transition to Firing.
- Check your email inbox for alert notifications.


# Task 8: Grafana Installation and Dashboard Creation
## Objective
In this task, you will install Grafana on your Kubernetes (K8s) cluster using a Helm chart and create a dashboard to visualize Prometheus metrics.

## Prerequisites
- Kubernetes cluster up and running.
- kubectl CLI installed and configured.
- Helm installed and configured.
- Prometheus installed and running in the cluster.

# Manual Deployment Steps

## Installation of Grafana

### 1. Add Helm Repository

Add the Bitnami Helm repository:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### 2: Install Grafana

Install Grafana in the namespace jenkins:

```bash
helm install grafana bitnami/grafana \
--namespace jenkins \
--set admin.password=your-admin-password \
--set service.type=LoadBalancer
```
Replace your-admin-password with your desired admin password for Grafana.

### 3: Verify Installation

Check the status of the Grafana pod:

```bash
kubectl get pods -n jenkins
```

Get the external IP address of the Grafana service:

```bash
kubectl get svc -n monitoring
```

Access Grafana in your browser at http://<EXTERNAL-IP>

## Configure Grafana

### Add Prometheus Data Source

- Log in to Grafana.
- Navigate to Configuration → Data Sources → Add data source.
- Select Prometheus and set the following:
URL: http://<prometheus-server-service-name>.<namespace>:<port> (e.g., http://prometheus-server.monitoring:9090).
- Click Save & Test to verify the connection.

## Create a Dashboard

### 1: Add Visualization

1. Navigate to Dashboards → New Dashboard → Add a new panel.
2. Select Prometheus as the data source.
3. Enter the PromQL query for the desired metric. For example:

CPU Utilization:
```bash
rate(node_cpu_seconds_total{mode!="idle"}[5m])
```

Memory Usage:
```bash
node_memory_Active_bytes / node_memory_MemTotal_bytes
```

Disk Space Usage:
```bash
1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)
```

4. Customize the panel's visualization and title.
5. Click Apply to save the panel.

## 2: Save Dashboard
1. After adding all necessary panels, click Save Dashboard.
2. Enter a name for the dashboard and save it.


# Task 7: Prometheus Deployment on K8s

## Objective
In this task, you will install Prometheus on your Kubernetes (K8s) cluster using a Helm chart and configure it to collect essential cluster-specific metrics.

## Prerequisites
- A Kubernetes cluster 
- Helm installed on the cluster
- Kubernetes CLI (kubectl) configured and connected to the cluster.
- A valid kubeconfig file

## Manual Deployment Steps

1. Add the Bitnami Helm Chart Repository:
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```
2. Deploy Prometheus: Run the following Helm command:
```bash
helm install prometheus bitnami/prometheus \
   --namespace jenkins \
   --set server.service.type=NodePort \
   --set-string server.service.nodePorts.http=32002
```
3. Verify Installation: Check the pods and services:
```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
```
## Prometheus Configuration
1. Edit configuration file:
```bash
kubectl edit configmap prometheus-server -n jenkins
```
2. Add new jobs:
- kubernetes-pods: Collects metrics from individual
Kubernetes pods with specific annotations.
- kube-state-metrics: Provides metrics on the state of Kubernetes objects like pods, deployments, and services.
- node-exporter: Monitors node-level resources such as CPU, memory, and disk usage.

```bash
scrape_configs:
  - job_name: 'node-exporter'
    scrape_interval: 1m
    metrics_path: /metrics
    static_configs:
      - targets:
          - node-exporter.jenkins.svc.cluster.local:9100

  - job_name: 'kube-state-metrics'
    scrape_interval: 1m
    metrics_path: /metrics
    static_configs:
      - targets:
          - kube-state-metrics.jenkins.svc.cluster.local:8080

  - job_name: kubernetes-pods
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        target_label: __address__
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
```
 
## Verifying Metrics Collection
### 1 .Open the Prometheus UI at the provided URL.
### 2. Go to Status > Targets to check active scrape targets.
### 3. Verify metrics by querying:
- node_memory_Active_bytes
- sum(node_memory_MemTotal_bytes) - sum(node_memory_MemFree_bytes)

>>>>>>> task-7

# Task 4: Jenkins Installation and Configuration

## Overview
In this task, we will guide you through the process of installing and configuring Jenkins, a popular open-source automation server. 

## Steps

### 1. Deploy Required Infrastructure
The infrastructure, including VPC, subnets, security groups, and EC2 instance (k3s_master), is deployed using Terraform. K3S service and Helm is installed automatically during the k3s_master installation.

To deploy the infrastructure, run the following commands:

```bash
terraform init
terraform plan
terraform apply
```
This will provision the necessary resources on AWS.

### 2. # Install k3s
```bash 
curl -sfL https://get.k3s.io | sh -
```

### 3. Install Helm
```bash 
curl -L https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz -o helm.tar.gz &&
tar -zxvf helm.tar.gz &&
sudo mv linux-amd64/helm /usr/local/bin/helm &&
rm -rf helm.tar.gz linux-amd64
```

### 4. Install kubectl
```bash 
curl -LO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\" &&
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl &&
rm kubectl
```

### 5. Install Helm Chart
Once the infrastructure is deployed, you can install a Helm chart:
```bash 
[ec2-user@ip-10-0-1-63 ~] helm install my-nginx oci://registry-1.docker.io/bitnamicharts/nginx
```
Verify the installed Nginx chart:
```bash 
[ec2-user@ip-10-0-1-63 ~] kubectl get pods

NAME                        READY   STATUS    RESTARTS   AGE
my-nginx-5797c99d4c-5mmmk   1/1     Running   0          61s
```

### 6. Create Persistent Volume Claim (PVC) and Persistent volumes (PV)

Create a working directory on the virtual machine:

```bash
mkdir -p ~/k8s-manifests
cd ~/k8s-manifests
```

Create the pvc.yaml file:

```bash
nano pvc.yaml
```

Insert the following content:

```bash
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-path-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 2Gi
```
Create the pod.yaml file:
```bash
apiVersion: v1
kind: Pod
metadata:
  name: volume-test
  namespace: default
spec:
  containers:
  - name: volume-test
    image: nginx:stable-alpine
    imagePullPolicy: IfNotPresent
    volumeMounts:
    - name: volv
      mountPath: /data
    ports:
    - containerPort: 80
  volumes:
  - name: volv
    persistentVolumeClaim:
      claimName: local-path-pvc
```
Apply and verify the PVC and POD creation:
```bash
kubectl apply -f pvc.yaml
kubectl apply -f pod.yaml
kubectl get pvc
kubectl get pods
```
### 7. Install Jenkins
https://www.jenkins.io/doc/book/installing/kubernetes/#install-jenkins-with-helm-v3

Also you can find all steps how to install Jenkins in the GIT Hub workflow file https://github.com/ukrainskyi-vitalii/rsschool-devops-course-k3s/blob/task-4/.github/workflows/deploy-jenkins.yml

## Authentication and Security

### Authentication

- **Method**: OIDC with AWS IAM Role for GitHub Actions
- **Variables**:
  - `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`: Required for AWS API access, stored in GitHub Secrets.
  - `KUBECONFIG`: Path to Kubernetes configuration file for cluster access.

### Security Configurations

- **TLS/SSL**: Enabled for secure communication.
- **IAM Policies**: Only necessary permissions are granted to GitHub Actions roles.
- **Access Controls**: Tokens are used for API access, restricted by roles.

### Environment Variables

| Variable                 | Description                           |
|--------------------------|---------------------------------------|
| `AWS_ACCOUNT_ID`         | AWS account ID                       |
| `AWS_REGION`             | AWS region for deployments           |
| `SSH_PRIVATE_KEY`        | Private key for SSH access           |

### Recommendations

- Store sensitive data in GitHub Secrets.
- Rotate keys regularly and follow IAM best practices for permissions.

### Example Configuration

```bash
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
```
