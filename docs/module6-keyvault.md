# Module 6 - Key Vault

## Resources Created

| Resource | Name | Value |
|----------|------|-------|
| Key Vault | kv-azureops2606 | RBAC enabled, Soft Delete 90 days |
| Secret | db-password | Database password |
| Region | East US | eastus |

## Key Concepts

**Azure Key Vault**
A secure cloud vault for storing secrets, keys and certificates.
Everything stored is encrypted. Every access is logged automatically.
URL: https://kv-azureops2606.vault.azure.net/

**Secret**
A sensitive string value such as a database password or API key.
Retrieved at runtime by applications using Managed Identity.
Never stored in code or config files.

**Soft Delete**
Accidentally deleted secrets and vaults are kept for 90 days before
permanent deletion. Protects against accidental data loss.

**Secret Versioning**
Every update to a secret creates a new version. Old versions are kept.
You can roll back to a previous version if needed.

**RBAC on Key Vault**
Key Vault Secrets Officer: create, read, update and delete secrets.
Key Vault Secrets User: read secrets only.
Always assign at narrowest scope possible.

**Secure Pattern**
VM uses Managed Identity to authenticate to Key Vault.
Key Vault checks RBAC and returns the secret.
No credentials ever stored in code or config files.

## Role Assignments

| Identity | Role | Scope |
|----------|------|-------|
| donaemeka92@gmail.com | Key Vault Secrets Officer | kv-azureops2606 |
| vm-azureops Managed Identity | Key Vault Secrets User | kv-azureops2606 |

## Commands Used

**Register Key Vault Provider**

```bash
az provider register --namespace Microsoft.KeyVault
```

**Create Key Vault**

```bash
az keyvault create --name kv-azureops2606 \
  --resource-group rg-azureops-platform \
  --location eastus \
  --enable-rbac-authorization true \
  --tags Project=AzureOpsPlatform Owner=Donatus Environment=Dev
```

**Assign Secrets Officer Role**

```bash
az role assignment create \
  --assignee "453ad0e0-a83d-4061-9c2b-e4612e9b151f" \
  --role "Key Vault Secrets Officer" \
  --scope "/subscriptions/854d3ee4.../vaults/kv-azureops2606"
```

**Store a Secret**

```bash
az keyvault secret set --vault-name kv-azureops2606 \
  --name db-password \
  --value "MySecureP@ssw0rd2606"
```

**Retrieve a Secret**

```bash
az keyvault secret show --vault-name kv-azureops2606 \
  --name db-password \
  --query "value" \
  --output tsv
```

**Assign Secrets User to VM Managed Identity**

```bash
az role assignment create \
  --assignee "a7044a08-dec4-43ad-b019-e62063ee60c5" \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/854d3ee4.../vaults/kv-azureops2606"
```

## Notes

The VM Managed Identity has Key Vault Secrets User role so it can
read secrets but not create or delete them. The engineer account has
Key Vault Secrets Officer. This follows least privilege. Every secret
access is automatically logged in Azure Monitor.