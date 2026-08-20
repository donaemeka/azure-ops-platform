# Module 4 — Storage

## Resources Created

| Resource | Name | Value |
|----------|------|-------|
| Storage Account | stdonatus2606 | Standard LRS, Hot tier |
| Container | app-files | Private access |
| Region | East US | eastus |

## Key Concepts

### Storage Account
Top level container for all storage in Azure. Name must be globally
unique - it becomes part of the public URL.
URL: https://stdonatus2606.blob.core.windows.net/

### Blob Storage
Object storage for unstructured data - files, images, videos, backups.
Every file must live inside a container.

### Container
A folder inside the storage account. Access can be private or public.
We use private -  only authenticated users can access files.

### LRS (Locally Redundant Storage)
Azure keeps 3 copies of every file in the same data center.
Cheapest redundancy option. Good for dev environments.

### Access Tiers
Hot = frequently accessed files. Lower access cost, higher storage cost.
Cool = infrequently accessed. Archive = rarely accessed backups.

### Encryption at Rest
Every file stored in Azure Blob Storage is automatically encrypted.
Enabled by default - no configuration needed.

### RBAC on Storage
Being subscription owner is not enough to upload files.
Must explicitly assign Storage Blob Data Contributor role.
This separates management permissions from data permissions.
Principle of least privilege - assign only minimum permissions needed.

## Commands Used

### Create Storage Account
    az storage account create --name stdonatus2606 \
      --resource-group rg-azureops-platform \
      --location eastus \
      --sku Standard_LRS \
      --kind StorageV2 \
      --access-tier Hot

### Create Container
    az storage container create --name app-files \
      --account-name stdonatus2606 \
      --auth-mode login

### Assign RBAC Role
    az role assignment create \
      --assignee "453ad0e0-a83d-4061-9c2b-e4612e9b151f" \
      --role "Storage Blob Data Contributor" \
      --scope "/subscriptions/854d3ee4.../storageAccounts/stdonatus2606"

### Upload File
    az storage blob upload \
      --container-name app-files \
      --account-name stdonatus2606 \
      --name testfile.txt \
      --file testfile.txt \
      --auth-mode login

### List Files
    az storage blob list \
      --container-name app-files \
      --account-name stdonatus2606 \
      --auth-mode login \
      --output table

### Download File
    az storage blob download \
      --container-name app-files \
      --account-name stdonatus2606 \
      --name testfile.txt \
      --file downloaded-testfile.txt \
      --auth-mode login