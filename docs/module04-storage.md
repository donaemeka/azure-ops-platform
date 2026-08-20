# Module 4 - Storage

This module creates a storage account and blob container for the project. Files are uploaded and downloaded to verify the setup works end to end.

## Prerequisites

- Resource group `rg-azureops-platform` exists
- Azure CLI logged in
- Storage Blob Data Contributor role assigned to your user

## Resources

| Name | Type | Value |
|------|------|-------|
| stdonatus2606 | Storage Account | Standard LRS, Hot tier |
| app-files | Blob Container | Private access |

## Setup

Create the storage account. The name must be globally unique across all of Azure:

```bash
az storage account create --name stdonatus2606 \
  --resource-group rg-azureops-platform \
  --location eastus \
  --sku Standard_LRS \
  --kind StorageV2 \
  --access-tier Hot \
  --tags Project=AzureOpsPlatform Owner=Donatus Environment=Dev
```

Assign yourself the Storage Blob Data Contributor role. Being subscription owner is not enough to read and write blob data:

```bash
az role assignment create \
  --assignee "453ad0e0-a83d-4061-9c2b-e4612e9b151f" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/854d3ee4-f355-4fcf-ad11-91b09816ce88/resourceGroups/rg-azureops-platform/providers/Microsoft.Storage/storageAccounts/stdonatus2606"
```

Create a blob container inside the storage account:

```bash
az storage container create --name app-files \
  --account-name stdonatus2606 \
  --auth-mode login
```

Create a test file and upload it:

```bash
echo "Hello from Azure Ops Platform - Donatus" > testfile.txt

az storage blob upload \
  --container-name app-files \
  --account-name stdonatus2606 \
  --name testfile.txt \
  --file testfile.txt \
  --auth-mode login
```

## Verify

List files in the container:

```bash
az storage blob list \
  --container-name app-files \
  --account-name stdonatus2606 \
  --auth-mode login --output table
```

Download the file back to confirm round trip works:

```bash
az storage blob download \
  --container-name app-files \
  --account-name stdonatus2606 \
  --name testfile.txt \
  --file downloaded-testfile.txt \
  --auth-mode login

cat downloaded-testfile.txt
```

## Notes

Standard LRS keeps 3 copies of every file in the same data center. The storage account URL is https://stdonatus2606.blob.core.windows.net/. Every file stored is automatically encrypted at rest by default. The RBAC role was scoped to this specific storage account only — not the entire subscription.