# Module 7 - Containers

This module builds a Docker image, pushes it to Azure Container Registry, and deploys it to an AKS cluster. The application is exposed to the internet via an Azure Load Balancer.

## Prerequisites

- Docker installed and running
- Azure CLI logged in
- kubectl installed

## Resources

| Name | Type | Value |
|------|------|-------|
| acrazureops2606 | Container Registry | Basic SKU |
| aks-azureops | AKS Cluster | 1 node, Standard_D2s_v7 |

## Setup

Create the Container Registry:

```bash
az acr create --name acrazureops2606 \
  --resource-group rg-azureops-platform \
  --location eastus \
  --sku Basic \
  --tags Project=AzureOpsPlatform Owner=Donatus Environment=Dev
```

Build the Docker image from the Dockerfile in the repo root:

```bash
docker build -t myapp:v1.0 .
```

Log in to ACR and push the image:

```bash
az acr login --name acrazureops2606

docker tag myapp:v1.0 acrazureops2606.azurecr.io/myapp:v1.0

docker push acrazureops2606.azurecr.io/myapp:v1.0
```

Create the AKS cluster with one node. The `--attach-acr` flag gives AKS permission to pull images from ACR:

```bash
az aks create --name aks-azureops \
  --resource-group rg-azureops-platform \
  --location eastus \
  --node-count 1 \
  --node-vm-size Standard_D2s_v7 \
  --attach-acr acrazureops2606 \
  --generate-ssh-keys \
  --tags Project=AzureOpsPlatform Owner=Donatus Environment=Dev
```

Connect kubectl to the cluster:

```bash
az aks get-credentials --name aks-azureops \
  --resource-group rg-azureops-platform
```

Deploy the application using the manifest in the k8s folder:

```bash
kubectl apply -f k8s/deployment.yaml
```

## Verify

Check the pod is running:

```bash
kubectl get pods
```

Get the public IP of the load balancer service:

```bash
kubectl get service myapp-service
```

Test the application:

```bash
curl http://<EXTERNAL_IP>
```

## Cleanup

Delete the AKS cluster after testing to stop compute charges:

```bash
az aks delete --name aks-azureops \
  --resource-group rg-azureops-platform \
  --yes --no-wait
```

## Notes

AKS creates its own resource group called MC_rg-azureops-platform_aks-azureops_eastus for cluster infrastructure. The `--attach-acr` flag automatically assigns the AcrPull role to the AKS Managed Identity. Each pod gets an internal IP from the 10.244.0.0/16 pod CIDR. External traffic reaches pods through the LoadBalancer service on the public IP.