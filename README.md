# Azure Ops Platform

Production-style Azure infrastructure covering networking, compute, storage, containers, CI/CD, monitoring and security. Built from scratch using Azure CLI, Bicep IaC and GitHub Actions.

## Project Architecture

![Azure Ops Platform Architecture](./image/architecture.png)

## Modules

| Module | Topic | Docs | Status |
|--------|-------|------|--------|
| 0 | Big Picture + Setup | - | ✅ Complete |
| 1 | Portal + CLI + Resource Group | - | ✅ Complete |
| 2 | Networking — VNet, Subnet, NSG | [docs](./docs/module02-networking.md) | ✅ Complete |
| 3 | Compute — Virtual Machine | [docs](./docs/module03-compute.md) | ✅ Complete |
| 4 | Storage — Blob Storage | [docs](./docs/module04-storage.md) | ✅ Complete |
| 5 | Identity — RBAC + Managed Identity | [docs](./docs/module05-identity.md) | ✅ Complete |
| 6 | Security — Key Vault | [docs](./docs/module06-keyvault.md) | ✅ Complete |
| 7 | Containers — ACR + AKS | [docs](./docs/module07-containers.md) | ✅ Complete |
| 8 | IaC — Bicep Templates | [docs](./docs/module08-bicep.md) | ✅ Complete |
| 9 | CI/CD — GitHub Actions | [docs](./docs/module09-cicd.md) | ✅ Complete |
| 10 | Monitoring — Azure Monitor | [docs](./docs/module10-monitoring.md) | ✅ Complete |

## Tech Stack

- Cloud: Microsoft Azure
- IaC: Bicep
- Containers: Docker, AKS, ACR
- CI/CD: GitHub Actions
- Monitoring: Azure Monitor, Log Analytics
- Security: Azure Key Vault, RBAC, Managed Identity
- CLI: Azure CLI, kubectl

## Azure Resources

- Resource Group: `rg-azureops-platform`
- Region: East US
- Subscription: Azure subscription 1

## Repository Structure

## Repository Structure

```
azure-ops-platform/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── bicep/
│   └── main.bicep
├── docs/
│   ├── module02-networking.md
│   ├── module03-compute.md
│   ├── module04-storage.md
│   ├── module05-identity.md
│   ├── module06-keyvault.md
│   ├── module07-containers.md
│   ├── module08-bicep.md
│   ├── module09-cicd.md
│   └── module10-monitoring.md
├── image/
│   └── architecture.png
├── k8s/
│   └── deployment.yaml
├── .gitignore
├── Dockerfile
├── index.html
├── LICENSE
└── README.md
```


## Author

Donatus Emeka Anyalebechi
- GitHub: [github.com/donaemeka](https://github.com/donaemeka)
- LinkedIn: [linkedin.com/in/donatus-devops](https://linkedin.com/in/donatus-devops)