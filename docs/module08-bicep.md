# Module 8 - Infrastructure as Code with Bicep

This module rebuilds the networking infrastructure using Bicep. The same VNet, subnet and NSG from Module 2 are defined as code and deployed with a single command.

## Prerequisites

- Azure CLI logged in
- Bicep CLI installed
- Resource group exists

## Setup

Install Bicep:

```bash
az bicep install
az bicep version
```

The Bicep template is at `bicep/main.bicep`. It defines the VNet, subnet and NSG with all four inbound rules. Parameters allow the location, project name and environment to be changed at deploy time without editing the template.

Validate the template compiles without errors:

```bash
az bicep build --file bicep/main.bicep
```

Preview what will be created or changed before deploying:

```bash
az deployment group what-if \
  --resource-group rg-azureops-platform \
  --template-file bicep/main.bicep
```

Deploy the template:

```bash
az deployment group create \
  --resource-group rg-azureops-platform \
  --template-file bicep/main.bicep \
  --name bicep-networking-deploy
```

## Verify

```bash
az network vnet show --name vnet-azureops \
  --resource-group rg-azureops-platform --output table

az network nsg rule list --nsg-name nsg-azureops \
  --resource-group rg-azureops-platform --output table
```

## Bicep vs CLI

| Action | CLI | Bicep |
|--------|-----|-------|
| Validate | N/A | az bicep build |
| Preview | N/A | az deployment what-if |
| Deploy | az resource create | az deployment group create |
| Idempotent | No | Yes |

## Notes

Bicep compiles to ARM JSON which is what Azure actually deploys. The compiled `main.json` is added to `.gitignore` because it is generated — only `main.bicep` is committed. Bicep automatically detects that the VNet depends on the NSG and creates the NSG first. Running the template again on existing resources updates only what has changed.