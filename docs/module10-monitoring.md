# Module 10 - Monitoring

This module sets up Azure Monitor with a Log Analytics Workspace, diagnostic settings on the storage account, an action group for email alerts and a metric alert that fires when storage transactions are unusually high.

## Prerequisites

- Storage account from Module 4
- Azure CLI logged in
- Microsoft.Insights provider registered

## Resources

| Name | Type | Value |
|------|------|-------|
| law-azureops | Log Analytics Workspace | 30 days retention |
| storage-diagnostics | Diagnostic Settings | Transaction metrics |
| ag-azureops | Action Group | Email to Donaemeka92@gmail.com |
| alert-storage-transactions | Metric Alert | Transactions > 100 in 5 minutes |

## Setup

Register the Insights provider:

```bash
az provider register --namespace Microsoft.Insights
az provider show --namespace Microsoft.Insights --query "registrationState"
```

Create the Log Analytics Workspace:

```bash
az monitor log-analytics workspace create \
  --workspace-name law-azureops \
  --resource-group rg-azureops-platform \
  --location eastus \
  --tags Project=AzureOpsPlatform Owner=Donatus Environment=Dev
```

Get the workspace ID for use in later commands:

```bash
az monitor log-analytics workspace show \
  --workspace-name law-azureops \
  --resource-group rg-azureops-platform \
  --query customerId --output tsv
```

Connect the storage account to send transaction metrics to the workspace:

```bash
az monitor diagnostic-settings create \
  --name storage-diagnostics \
  --resource /subscriptions/854d3ee4-f355-4fcf-ad11-91b09816ce88/resourceGroups/rg-azureops-platform/providers/Microsoft.Storage/storageAccounts/stdonatus2606 \
  --workspace /subscriptions/854d3ee4-f355-4fcf-ad11-91b09816ce88/resourceGroups/rg-azureops-platform/providers/Microsoft.OperationalInsights/workspaces/law-azureops \
  --metrics '[{"category":"Transaction","enabled":true}]'
```

Create an action group that sends email when an alert fires:

```bash
az monitor action-group create \
  --name ag-azureops \
  --resource-group rg-azureops-platform \
  --short-name agops \
  --action email donatus Donaemeka92@gmail.com
```

Create a metric alert that fires when storage transactions exceed 100 in any 5 minute window:

```bash
az monitor metrics alert create \
  --name alert-storage-transactions \
  --resource-group rg-azureops-platform \
  --scopes /subscriptions/854d3ee4-f355-4fcf-ad11-91b09816ce88/resourceGroups/rg-azureops-platform/providers/Microsoft.Storage/storageAccounts/stdonatus2606 \
  --condition "total transactions > 100" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action /subscriptions/854d3ee4-f355-4fcf-ad11-91b09816ce88/resourceGroups/rg-azureops-platform/providers/microsoft.insights/actionGroups/ag-azureops \
  --description "Alert when storage transactions exceed 100 in 5 minutes" \
  --severity 2
```

## Verify

List all metric alerts:

```bash
az monitor metrics alert list \
  --resource-group rg-azureops-platform --output table
```

Query the Log Analytics Workspace for recent Azure activity:

```bash
az monitor log-analytics query \
  --workspace d1a63fd6-f227-4858-9889-57e2a7a44767 \
  --analytics-query "AzureActivity | where TimeGenerated > ago(1h) | summarize count() by OperationNameValue | top 10 by count_"
```

## Notes

Log Analytics Workspace ID: d1a63fd6-f227-4858-9889-57e2a7a44767. New workspaces take 15 to 30 minutes before data starts appearing in queries. Alert severity 2 is Warning. Severity 0 is Critical. The alert evaluates every minute looking at the last 5 minutes of transaction data.