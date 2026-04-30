# Azure Policy History Report

Azure Policy provides current-state compliance insights, many teams also need historical trends for compliance posture, policy drift, and governance reporting. 
This solution captures policy-related state on a schedule, stores snapshots in ADX, and enables analytics with a Power BI template.

## Quick Start

### 1. Deploy to Azure and download the Power BI template

| Component | Link |
| :--- | :--- |
| Azure Portal UI | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FWillyMoselhy%2FAzurePolicyHistoryReport%2Fv0.0.14%2Fbuild%2Farm%2FdeployAzureHistoryPolicy.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FWillyMoselhy%2FAzurePolicyHistoryReport%2Fv0.0.14%2Fbuild%2Fportal-ui%2Fportal-ui.json) |
| Power BI Template | [<img src="https://raw.githubusercontent.com/microsoft/PowerBI-Icons/main/SVG/Power-BI.svg" width="25" alt="Power BI" />](https://github.com/WillyMoselhy/AzurePolicyHistoryReport/releases/latest/download/Azure.Policy.History.Report.Template.pbit)|


### 2. Configure access scope

Grant the deployed Function App system identity sufficient read access over your target scope (for example, root management group or selected subscriptions/resource groups) so queries can retrieve policy states.

### 3. (optional) Test run the function app to collect initial data

You can trigger the function manually from the Azure Portal to validate data collection and ingestion into ADX before opening the Power BI template.

### 4. Open the Power BI template

Open `Azure Policy History Report Template.pbit` and configure connection settings to your ADX cluster/database.

## Architecture

```mermaid
flowchart LR
		A[Azure Resource Graph\nPolicy and Resource Metadata] --> B[Azure Function App]
		B --> C[Azure Data Explorer\nPolicy History Database]
		C --> D[Power BI Template\nCompliance Reporting]
```

## Key Features

- Scheduled ingestion using an Azure Functions timer trigger.
- Centralized storage in ADX for historical analysis.
- Captures:
	- Policy compliance states
	- Resource tags
	- Subscription and management group hierarchy
- Deployable via Azure Portal custom deployment experience or Bicep.
- Sample Power BI template for fast reporting start.


## Prerequisites

- Azure subscription with permissions to deploy resources.
- Permissions to assign required roles for managed identity where needed.
- Power BI Desktop (for the provided `.pbit` template).


## Troubleshooting

- No data in ADX tables:
	- Check Function App run logs.
	- Validate managed identity read access on target scope.
	- Validate `_ADXClusterUri` and `_ADXDatabaseName` settings.
- Power BI connection issues:
	- Validate cluster/database names and authentication.
	- Confirm network and access restrictions.

## Contributing

Contributions are welcome.

- Open an issue to propose changes or report problems.
- Keep infrastructure, function logic, and reporting changes scoped and documented.
- Include validation steps in pull requests.
