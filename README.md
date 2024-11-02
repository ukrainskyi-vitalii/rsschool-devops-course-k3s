# DevOps Course. Terraform Infrastructure for AWS with GitHub Actions
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

### 2. Install Helm Chart
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

### 3. Create Persistent Volume Claim (PVC) and Persistent volumes (PV)

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
### 4.
