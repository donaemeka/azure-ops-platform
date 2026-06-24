# Module 2 — Networking

## What Was Built

| Resource | Name | Value |
|----------|------|-------|
| Virtual Network | vnet-azureops | 10.0.0.0/16 |
| Subnet | snet-app | 10.0.1.0/24 |
| NSG | nsg-azureops | 4 inbound rules |
| Region | Germany West Central | germanywestcentral |
| Resource Group | rg-azureops-platform | germanywestcentral |

---

## Architecture

```
rg-azureops-platform (Germany West Central)
└── vnet-azureops (10.0.0.0/16)
    ├── snet-app (10.0.1.0/24)
    └── nsg-azureops
        ├── Rule 100:  Allow HTTPS 443  — Inbound
        ├── Rule 200:  Allow HTTP  80   — Inbound
        ├── Rule 300:  Allow SSH   22   — Inbound
        └── Rule 4096: Deny All         — Inbound
        └── Associated to snet-app
```

---

## NSG Rules

| Priority | Name | Protocol | Port | Direction | Source | Action |
|----------|------|----------|------|-----------|--------|--------|
| 100 | Allow-HTTPS | TCP | 443 | Inbound | Internet | Allow |
| 200 | Allow-HTTP | TCP | 80 | Inbound | Internet | Allow |
| 300 | Allow-SSH | TCP | 22 | Inbound | Internet | Allow |
| 4096 | Deny-All-Inbound | * | * | Inbound | * | Deny |

---

## Key Concepts

### Virtual Network (VNet)
A private isolated network inside Azure. Nothing from the internet can enter unless explicitly allowed. Address space 10.0.0.0/16 gives 65,536 available IP addresses.

### Subnet
A segment inside the VNet. Resources in the same subnet communicate freely. Different subnets require explicit rules. Using /24 gives 251 usable IP addresses. Azure reserves 5 addresses per subnet.

### NSG (Network Security Group)
Azure built-in firewall. Rules processed in priority order — lowest number checked first. First matching rule wins. Must be associated to a subnet to take effect.

### NSG Rule Priority
Lower number = higher priority = checked first. Gaps between numbers (100, 200, 300) allow inserting rules later. Catch-all deny rule always sits at highest number (4096).

### CIDR Notation
- `/16` = large network (VNet level) — 65,536 addresses
- `/24` = smaller segment (Subnet level) — 256 addresses (251 usable)
- Smaller number after `/` = bigger network

---

## Azure Default NSG Rules (cannot be deleted)

| Priority | Name | Source | Port | Action |
|----------|------|--------|------|--------|
| 65000 | AllowVnetInbound | VirtualNetwork | Any | Allow |
| 65001 | AllowAzureLoadBalancer | AzureLoadBalancer | Any | Allow |
| 65500 | DenyAllInbound | Any | Any | Deny |

---

## Commands Used

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

### Add Rule — Allow HTTPS

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

### Add Rule — Allow HTTP

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

### Add Rule — Allow SSH

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

### Add Rule — Deny All Inbound

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

### Verify VNet

    az network vnet show \
      --name vnet-azureops \
      --resource-group rg-azureops-platform \
      --output table

### Verify Subnet

    az network vnet subnet show \
      --name snet-app \
      --resource-group rg-azureops-platform \
      --vnet-name vnet-azureops \
      --output table

### Verify NSG Rules

    az network nsg rule list \
      --nsg-name nsg-azureops \
      --resource-group rg-azureops-platform \
      --output table

---

## Interview Talking Points

### Q: Walk me through the networking you built.
I created a Virtual Network with address space 10.0.0.0/16 in Germany West Central. Inside it I created an app subnet with 10.0.1.0/24. I created a Network Security Group with four inbound rules — allowing HTTPS on 443, HTTP on 80, and SSH on 22, with a catch-all deny rule at priority 4096. I then associated the NSG to the subnet so all inbound traffic is filtered through those rules.

### Q: Why did you put the deny rule at priority 4096?
The deny rule is a catch-all — it should only fire if no other rule matches. By putting it at 4096 it is checked last. Rules 100, 200, and 300 are checked first. Only traffic that does not match any of those hits the deny rule.

### Q: What happens if you forget to associate the NSG?
The NSG exists in Azure but does nothing. It is like a security guard who has been hired but not assigned to any post. Association is what links the rules to the actual subnet traffic.

### Q: Why use port 443 instead of just port 80?
Port 443 is HTTPS — encrypted traffic. Port 80 is HTTP — unencrypted. Best practice is to redirect all HTTP to HTTPS so user data is always encrypted in transit. Both rules exist during development but in production you would add a redirect rule from 80 to 443.
