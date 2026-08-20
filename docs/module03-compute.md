# Module 3 - Compute

This module deploys a Linux virtual machine into the existing subnet. The VM uses SSH key authentication and runs Nginx to serve web traffic on port 80.

## Prerequisites

- VNet and subnet from Module 2
- SSH key pair generated
- Azure CLI logged in

## Resources

| Name | Type | Value |
|------|------|-------|
| vm-azureops | Virtual Machine | Ubuntu 22.04, Standard_D2s_v7 |
| vm-azureopsPublicIP | Public IP | Standard SKU |
| vm-azureopsVMNic | Network Interface | Connected to snet-app |

## Setup

Generate an SSH key pair. The private key stays on your machine. The public key goes onto the VM:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/vm-azureops-key -N ""
```

Verify both files exist:

```bash
ls ~/.ssh/vm-azureops-key*
```

Create the VM inside the existing VNet and subnet. Pass `--nsg ""` to prevent Azure creating a duplicate NSG since the subnet already has one:

```bash
az vm create --name vm-azureops \
  --resource-group rg-azureops-platform \
  --location eastus \
  --image Ubuntu2204 \
  --size Standard_D2s_v7 \
  --vnet-name vnet-azureops \
  --subnet snet-app \
  --admin-username azureuser \
  --ssh-key-values ~/.ssh/vm-azureops-key.pub \
  --public-ip-sku Standard \
  --nsg "" \
  --tags Project=AzureOpsPlatform Owner=Donatus Environment=Dev
```

Get the VM public IP:

```bash
az vm show --name vm-azureops \
  --resource-group rg-azureops-platform \
  --show-details --output table
```

SSH into the VM:

```bash
ssh -i ~/.ssh/vm-azureops-key azureuser@<PUBLIC_IP>
```

Install Nginx web server:

```bash
sudo apt update && sudo apt install nginx -y
```

Check Nginx is running:

```bash
sudo systemctl status nginx
```

## Verify

From your local machine test the web server is reachable:

```bash
curl http://<PUBLIC_IP>
```

Check the VM location from inside using the Azure Instance Metadata Service:

```bash
curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/compute/location?api-version=2021-02-01&format=text"
```

## Deallocate

Always deallocate the VM when not using it to stop compute charges. You only pay for the disk when deallocated:

```bash
az vm deallocate --name vm-azureops \
  --resource-group rg-azureops-platform
```

## Notes

Standard_D2s_v7 was used because smaller B-series sizes had no capacity in East US at the time of deployment. The VM public IP is 40.87.23.150. Stopping a VM is different from deallocating — stop keeps compute allocated and you still pay. Deallocate releases compute completely.