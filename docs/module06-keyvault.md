# Module 6 - Key Vault

This module creates a Key Vault to store secrets securely. The VM Managed Identity is given permission to read secrets so applications can retrieve credentials at runtime without storing them in code.

## Prerequisites

- VM with Managed Identity from Module 5
- Azure CLI logged in
- Microsoft.KeyVault provider registered

## Resources

| Name | Type | Value |
|------|------|-------|
| kv-azureops2606 | Key Vault | RBAC enabled, Soft Delete 90 days |
| db-password | Secret | Database password |

## Setup

Register the Key Vault provider if not already registered:

```bash
az provider register --namespace Microsoft.KeyVault
az provider show --namespace Microsoft.KeyVault --query "registrationState"
```

Create the Key Vault with RBAC authorization enabled:

```bash
az keyvault create --name kv-azureops2606 \
  --resource-group rg-azureops-platform \
  --location eastus \
  --enable-rbac-authorization true \
  --tags Project=AzureOpsPlatform Owner=Donatus Environment=Dev
```

Assign yourself the Key Vault Secrets Officer role to manage secrets:

```bash
az role assignment create \
  --assignee "453ad0e0-a83d-4061-9c2b-e4612e9b151f" \
  --role "Key Vault Secrets Officer" \
  --scope "/subscriptions/854d3ee4-f355-4fcf-ad11-91b09816ce88/resourceGroups/rg-azureops-platform/providers/Microsoft.KeyVault/vaults/kv-azureops2606"
```

Store a secret:

```bash
az keyvault secret set --vault-name kv-azureops2606 \
  --name db-password \
  --value "MySecureP@ssw0rd2606"
```

Assign the VM Managed Identity the Key Vault Secrets User role so it can read secrets at runtime:

```bash
az role assignment create \
  --assignee "a7044a08-dec4-43ad-b019-e62063ee60c5" \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/854d3ee4-f355-4fcf-ad11-91b09816ce88/resourceGroups/rg-azureops-platform/providers/Microsoft.KeyVault/vaults/kv-azureops2606"
```

## Verify

Retrieve the secret to confirm it was stored correctly:

```bash
az keyvault secret show --vault-name kv-azureops2606 \
  --name db-password \
  --query "value" --output tsv
```

## Notes

Vault URL: https://kv-azureops2606.vault.azure.net/. Soft Delete keeps deleted secrets for 90 days before permanent deletion. Every secret update creates a new version — old versions are kept for rollback. The VM gets Secrets User not Secrets Officer because it only needs to read secrets not create or delete them.