# Module 2 — Networking

## Resources Created

| Resource | Name | Value |
|----------|------|-------|
| Virtual Network | vnet-azureops | 10.0.0.0/16 |
| Subnet | snet-app | 10.0.1.0/24 |
| NSG | nsg-azureops | 4 inbound rules |
| Region | Germany West Central | germanywestcentral |
| Resource Group | rg-azureops-platform | germanywestcentral |

---

## Network Architecture

```
rg-azureops-platform (Germany West Central)
└── vnet-azureops (10.0.0.0/16)
    ├── snet-app (10.0.1.0/24)
    └── nsg-azureops
        ├── Rule 100:  Allow HTTPS 443  Inbound
        ├── Rule 200:  Allow HTTP  80   Inbound
        ├── Rule 300:  Allow SSH   22   Inbound
        └── Rule 4096: Deny All         Inbound
            Associated to snet-app
```

---

## NSG Inbound Rules

| Priority | Name | Protocol | Port | Source | Action |
|----------|------|----------|------|--------|--------|
| 100 | Allow-HTTPS | TCP | 443 | Internet | Allow |
| 200 | Allow-HTTP | TCP | 80 | Internet | Allow |
| 300 | Allow-SSH | TCP | 22 | Internet | Allow |
| 4096 | Deny-All-Inbound | Any | Any | Any | Deny |

---

## Commands

### Create Resource Group

    az group create \
      --name rg-azureops-platform \
      --location germanywestcentral \
      --tags Project=AzureOpsPlatform Owner=Donatus Environment=Dev

### Create Virtual Network

    az network vnet create \
      --name vnet-azureops \
      --resource-group rg-azureops-platform \
      --location germanywestcentral \
      --address-prefix 10.0.0.0/16 \
      --tags Project=AzureOpsPlatform Owner=Donatus Environment=Dev

### Create Subnet

    az network vnet subnet create \
      --name snet-app \
      --resource-group rg-azureops-platform \
      --vnet-name vnet-azureops \
      --address-prefix 10.0.1.0/24

### Create NSG

    az network nsg create \
      --name nsg-azureops \
      --resource-group rg-azureops-platform \
      --location germanywestcentral \
      --tags Project=AzureOpsPlatform Owner=Donatus Environment=Dev

### Add Rule: Allow HTTPS

    az network nsg rule create \
      --name Allow-HTTPS \
      --nsg-name nsg-azureops \
      --resource-group rg-azureops-platform \
      --priority 100 \
      --direction Inbound \
      --protocol TCP \
      --source-address-prefix Internet \
      --source-port-range "*" \
      --destination-address-prefix "*" \
      --destination-port-range 443 \
      --access Allow

### Add Rule: Allow HTTP

    az network nsg rule create \
      --name Allow-HTTP \
      --nsg-name nsg-azureops \
      --resource-group rg-azureops-platform \
      --priority 200 \
      --direction Inbound \
      --protocol TCP \
      --source-address-prefix Internet \
      --source-port-range "*" \
      --destination-address-prefix "*" \
      --destination-port-range 80 \
      --access Allow

### Add Rule: Allow SSH

    az network nsg rule create \
      --name Allow-SSH \
      --nsg-name nsg-azureops \
      --resource-group rg-azureops-platform \
      --priority 300 \
      --direction Inbound \
      --protocol TCP \
      --source-address-prefix Internet \
      --source-port-range "*" \
      --destination-address-prefix "*" \
      --destination-port-range 22 \
      --access Allow

### Add Rule: Deny All Inbound

    az network nsg rule create \
      --name Deny-All-Inbound \
      --nsg-name nsg-azureops \
      --resource-group rg-azureops-platform \
      --priority 4096 \
      --direction Inbound \
      --protocol "*" \
      --source-address-prefix "*" \
      --source-port-range "*" \
      --destination-address-prefix "*" \
      --destination-port-range "*" \
      --access Deny

### Associate NSG to Subnet

    az network vnet subnet update \
      --name snet-app \
      --resource-group rg-azureops-platform \
      --vnet-name vnet-azureops \
      --network-security-group nsg-azureops

### Verify Resources

    az network vnet show \
      --name vnet-azureops \
      --resource-group rg-azureops-platform \
      --output table

    az network vnet subnet show \
      --name snet-app \
      --resource-group rg-azureops-platform \
      --vnet-name vnet-azureops \
      --output table

    az network nsg rule list \
      --nsg-name nsg-azureops \
      --resource-group rg-azureops-platform \
      --output table

---

## Notes

The VNet uses address space 10.0.0.0/16 which gives enough room to add more subnets later for databases or management tools. The app subnet sits at 10.0.1.0/24. The NSG rules allow only HTTPS, HTTP and SSH inbound. All other inbound traffic is blocked by the deny rule at priority 4096. The NSG is associated directly to the app subnet so the rules apply to everything deployed into that subnet.
