# AzurePolicyHistoryReport

### Deployment
| Deployment Type   | Link                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| :---------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Azure Portal UI           | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FWillyMoselhy%2FAzurePolicyHistoryReport%2Fv0.0.14%2Fbuild%2Farm%2FdeployAzureHistoryPolicy.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FWillyMoselhy%2FAzurePolicyHistoryReport%2Fv0.0.14%2Fbuild%2Fportal-ui%2Fportal-ui.json) |
| Power BI Template | [<img src="https://raw.githubusercontent.com/microsoft/PowerBI-Icons/main/SVG/Power-BI.svg" width="25"></a>](PowerBI/Azure%20Policy%20History%20Report%20Template.pbit)                                                                                                                                                                                                                                                                        |


1. Deploy Azure Components
2. Assign the function app permissions to read all targetted resources, for example the root management group if you want to report on all subscriptions under it.
3. Power BI Report
