# Module 9 - CI/CD with GitHub Actions

This module automates the build and deploy process using GitHub Actions. Every push to the main branch triggers the pipeline which builds the Docker image, pushes it to ACR and deploys the Bicep template.

## Prerequisites

- GitHub repository set up
- ACR from Module 7
- Bicep template from Module 8
- Service Principal created with Contributor role on resource group

## Resources

| Name | Type | Value |
|------|------|-------|
| sp-github-azureops | Service Principal | Contributor on rg-azureops-platform |
| AZURE_CREDENTIALS | GitHub Secret | Service Principal JSON |
| ACR_NAME | GitHub Secret | acrazureops2606 |
| RESOURCE_GROUP | GitHub Secret | rg-azureops-platform |

## Setup

Create a Service Principal for GitHub Actions to use when logging into Azure:

```bash
az ad sp create-for-rbac \
  --name sp-github-azureops \
  --role Contributor \
  --scopes /subscriptions/854d3ee4-f355-4fcf-ad11-91b09816ce88/resourceGroups/rg-azureops-platform \
  --sdk-auth
```

Copy the JSON output and add it as a GitHub Secret named `AZURE_CREDENTIALS` at Settings > Secrets and variables > Actions.

Add two more secrets:
- `ACR_NAME` = acrazureops2606
- `RESOURCE_GROUP` = rg-azureops-platform

The workflow file is at `.github/workflows/deploy.yml`. It triggers on push to main and runs these steps in order: checkout code, login to Azure, login to ACR, build Docker image tagged with the Git commit SHA, push image to ACR, deploy Bicep template, logout from Azure.

## Verify

Push any change to the main branch and watch the pipeline run at: https://github.com/donaemeka/azure-ops-platform/actions


All steps should show green checkmarks. Total run time is approximately 70 seconds.

## Notes

The Service Principal has Contributor on the resource group only — not the entire subscription. The Docker image is tagged with `github.sha` so every build produces a unique tag for traceability. Credentials are stored as GitHub Secrets and never appear in workflow logs or code. The pipeline logs out of Azure at the end of every run.