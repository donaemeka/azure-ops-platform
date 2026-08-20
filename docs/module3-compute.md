# Module 3 - Compute

## Resources Created

| Resource | Name | Value |
|----------|------|-------|
| Virtual Machine | vm-azureops | Ubuntu 22.04 LTS |
| VM Size | Standard_D2s_v7 | 2 vCPUs, 8GB RAM |
| Public IP | Auto created | 40.87.23.150 |
| Region | East US | eastus |
| Admin Username | azureuser | SSH key authentication |

## Key Concepts

**Virtual Machine**
A computer that runs inside Azure data center. You rent it by the hour. Azure charges for compute only when the VM is running.

**VM Size**
Each size name tells you the family and specs. Standard_D2s_v7 means D-series general purpose, 2 vCPUs, version 7.

**SSH Key Authentication**
A private key stays on your machine. A public key goes onto the VM. When you connect they match and you get access. More secure than passwords.

**Deallocate vs Stop**
Stop keeps compute allocated and you still pay. Deallocate releases compute completely so you only pay for the disk.

**Nginx**
A popular web server. Listens on port 80 and 443. We installed it to prove the VM is reachable from the internet.

## Commands Used

**Generate SSH Key Pair**
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/vm-azureops-key -N ""
```

**Create Virtual Machine**
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

**Check VM Status**
```bash
az vm show --name vm-azureops --resource-group rg-azureops-platform --show-details --output table
```

**SSH Into VM**
```bash
ssh -i ~/.ssh/vm-azureops-key azureuser@40.87.23.150
```

**Install Nginx**
```bash
sudo apt update && sudo apt install nginx -y
```

**Test Web Server**
```bash
curl http://40.87.23.150
```

**Deallocate VM**
```bash
az vm deallocate --name vm-azureops --resource-group rg-azureops-platform
```

## Notes

VM deployed into snet-app subnet inside vnet-azureops. Used --nsg "" to prevent Azure creating a duplicate NSG. Nginx installed and verified on port 80. VM deallocated after testing to stop compute charges.