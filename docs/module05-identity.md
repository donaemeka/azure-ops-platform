# Module 5 - Identity and Access Control

This module enables a Managed Identity on the VM and assigns RBAC roles so the VM can access storage without storing any credentials in code.

## Prerequisites

- VM from Module 3
- Storage account from Module 4
- Azure CLI logged in

## Resources

| Identity | Role | Scope |
|----------|------|-------|
| donaemeka92@gmail.com | Storage Blob Data Contributor | stdonatus2606 |
| vm-azureops Managed Identity | Storage Blob Data Reader | stdonatus2606 |

## Setup

View current role assignments at subscription level:

```bash
az role assignment list \
  --subscription "854d3ee4-f355-4fcf-ad11-91b09816ce88" \
  --output table
```

Enable System-assigned Managed Identity on the VM. Azure creates an identity automatically and links it to the VM:

```bash
az vm identity assign --name vm-azureops \
  --resource-group rg-azureops-platform
```

The output returns the Managed Identity ID. Use it to assign the Storage Blob Data Reader role. The VM only needs to read files so Reader is sufficient:

```bash
az role assignment create \
  --assignee "a7044a08-dec4-43ad-b019-e62063ee60c5" \
  --role "Storage Blob Data Reader" \
  --scope "/subscriptions/854d3ee4-f355-4fcf-ad11-91b09816ce88/resourceGroups/rg-azureops-platform/providers/Microsoft.Storage/storageAccounts/stdonatus2606"
```

## Verify

List all role assignments on the storage account:

```bash
az role assignment list \
  --scope "/subscriptions/854d3ee4-f355-4fcf-ad11-91b09816ce88/resourceGroups/rg-azureops-platform/providers/Microsoft.Storage/storageAccounts/stdonatus2606" \
  --output table
```

## Notes

Managed Identity ID: a7044a08-dec4-43ad-b019-e62063ee60c5. The VM gets Reader not Contributor because it only reads files. If the VM is compromised the attacker can only read — they cannot upload or delete. This is the principle of least privilege. System-assigned Managed Identity is deleted automatically when the VM is deleted.