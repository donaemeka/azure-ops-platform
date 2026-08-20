# Module 2 - Networking

This module sets up the core network for the project. All compute resources deploy into this network. The NSG controls what traffic is allowed in and out of the subnet.

## Prerequisites

- Resource group `rg-azureops-platform` created in East US
- Azure CLI logged in and subscription set

## Resources

| Name | Type | Value |
|------|------|-------|
| vnet-azureops | Virtual Network | 10.0.0.0/16 |
| snet-app | Subnet | 10.0.1.0/24 |
| nsg-azureops | Network Security Group | 4 inbound rules |

## Setup

Create the Virtual Network with a /16 address space giving 65,536 available IP addresses:

```bash
az network vnet create --name vnet-azureops \
  --resource-group rg-azureops-platform \
  --location eastus \
  --address-prefix 10.0.0.0/16 \
  --tags Project=AzureOpsPlatform Owner=Donatus Environment=Dev
```

Create the application subnet. Azure reserves 5 addresses per subnet so /24 gives 251 usable IPs:

```bash
az network vnet subnet create --name snet-app \
  --resource-group rg-azureops-platform \
  --vnet-name vnet-azureops \
  --address-prefix 10.0.1.0/24
```

Create the NSG:

```bash
az network nsg create --name nsg-azureops \
  --resource-group rg-azureops-platform \
  --location eastus \
  --tags Project=AzureOpsPlatform Owner=Donatus Environment=Dev
```

Add inbound rules. Rules are processed in priority order — lowest number first:

```bash
az network nsg rule create --name Allow-HTTPS \
  --nsg-name nsg-azureops \
  --resource-group rg-azureops-platform \
  --priority 100 --direction Inbound --protocol TCP \
  --source-address-prefix Internet --source-port-range "*" \
  --destination-address-prefix "*" --destination-port-range 443 \
  --access Allow

az network nsg rule create --name Allow-HTTP \
  --nsg-name nsg-azureops \
  --resource-group rg-azureops-platform \
  --priority 200 --direction Inbound --protocol TCP \
  --source-address-prefix Internet --source-port-range "*" \
  --destination-address-prefix "*" --destination-port-range 80 \
  --access Allow

az network nsg rule create --name Allow-SSH \
  --nsg-name nsg-azureops \
  --resource-group rg-azureops-platform \
  --priority 300 --direction Inbound --protocol TCP \
  --source-address-prefix Internet --source-port-range "*" \
  --destination-address-prefix "*" --destination-port-range 22 \
  --access Allow

az network nsg rule create --name Deny-All-Inbound \
  --nsg-name nsg-azureops \
  --resource-group rg-azureops-platform \
  --priority 4096 --direction Inbound --protocol "*" \
  --source-address-prefix "*" --source-port-range "*" \
  --destination-address-prefix "*" --destination-port-range "*" \
  --access Deny
```

Attach the NSG to the subnet:

```bash
az network vnet subnet update --name snet-app \
  --resource-group rg-azureops-platform \
  --vnet-name vnet-azureops \
  --network-security-group nsg-azureops
```

## Verify

```bash
az network vnet show --name vnet-azureops \
  --resource-group rg-azureops-platform --output table

az network nsg rule list --nsg-name nsg-azureops \
  --resource-group rg-azureops-platform --output table
```

## Resources

| Name | Type | Location |
|------|------|----------|
| vnet-azureops | Virtual Network | East US |
| snet-app | Subnet | 10.0.1.0/24 |
| nsg-azureops | Network Security Group | East US |

## Notes

The deny rule sits at priority 4096 so it is always checked last. Any traffic that does not match rules 100, 200 or 300 gets blocked. The NSG must be associated to a subnet before it protects anything. The VNet uses 10.0.0.0/16 which leaves room to add more subnets later.