# Module 5 - Identity and Access Control

## What Was Done

| Action | Detail |
|--------|--------|
| Viewed role assignments | Owner at subscription level |
| Enabled Managed Identity | System-assigned on vm-azureops |
| Managed Identity ID | a7044a08-dec4-43ad-b019-e62063ee60c5 |
| Assigned role to VM | Storage Blob Data Reader on stdonatus2606 |

## Key Concepts

**Microsoft Entra ID**
Azure identity platform. Manages all users, applications and permissions.
Previously called Azure Active Directory.

**Service Principal**
A robot identity for applications and automation. GitHub Actions uses
a Service Principal to deploy to Azure.

**Managed Identity**
A Service Principal that Azure manages automatically. No passwords or
keys to manage. Two types: system-assigned (tied to one resource) and
user-assigned (shared across multiple resources).

**RBAC**
Role Based Access Control. Controls what actions an identity can perform.
Three parts: who gets the role, what role they get, and where it applies.

**Built-in Roles**
Owner = full access including permissions management.
Contributor = create and manage resources but cannot manage permissions.
Reader = view only, no changes allowed.
Storage Blob Data Contributor = read and write blobs.
Storage Blob Data Reader = read blobs only.

**Principle of Least Privilege**
Give only the minimum permissions needed. If compromised the damage
is limited. VM gets Reader not Contributor because it only reads files.

**Scope**
Controls how wide a permission applies. Subscription is widest.
Resource is narrowest. Always assign at the narrowest scope possible.

## Commands Used

**View Role Assignments at Subscription Level**

```bash
az role assignment list --subscription "854d3ee4-f355-4fcf-ad11-91b09816ce88" --output table
```

**Enable System-assigned Managed Identity on VM**

```bash
az vm identity assign --name vm-azureops --resource-group rg-azureops-platform
```

**Assign Storage Blob Data Reader to Managed Identity**

```bash
az role assignment create \
  --assignee "a7044a08-dec4-43ad-b019-e62063ee60c5" \
  --role "Storage Blob Data Reader" \
  --scope "/subscriptions/854d3ee4-f355-4fcf-ad11-91b09816ce88/resourceGroups/rg-azureops-platform/providers/Microsoft.Storage/storageAccounts/stdonatus2606"
```

**Verify Role Assignments on Storage Account**

```bash
az role assignment list \
  --scope "/subscriptions/854d3ee4-f355-4fcf-ad11-91b09816ce88/resourceGroups/rg-azureops-platform/providers/Microsoft.Storage/storageAccounts/stdonatus2606" \
  --output table
```

## Notes

The VM Managed Identity has Storage Blob Data Reader on the storage
account. The engineer account has Storage Blob Data Contributor.
Neither has Owner on storage which means neither can delete the
storage account through these roles. This is least privilege in practice.