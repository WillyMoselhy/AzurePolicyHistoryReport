# AzurePolicyHistoryReport

### Deployment
| Deployment Type           | Link |
| :------------------------ | :--- |
| Azure Portal UI           | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FWillyMoselhy%2FAzurePolicyHistoryReport%2Fmain%2Fbuild%2Farm%2FdeployAzureHistoryPolicy.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FWillyMoselhy%2FAzurePolicyHistoryReport%2Fmain%2Fbuild%2Fportal-ui%2Fportal-ui.json)  [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FWillyMoselhy%2FAzurePolicyHistoryReport%2Fmain%2Fbuild%2Farm%2FdeployAzureHistoryPolicy.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FWillyMoselhy%2FAzurePolicyHistoryReport%2Fmain%2Fbuild%2Fportal-ui%2Fportal-ui.json)  [![Deploy to Azure China](https://aka.ms/deploytoazurechinabutton)](https://portal.azure.cn/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FWillyMoselhy%2FAzurePolicyHistoryReport%2Fmain%2Fbuild%2Farm%2FdeployAzureHistoryPolicy.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FWillyMoselhy%2FAzurePolicyHistoryReport%2Fmain%2Fbuild%2Fportal-ui%2Fportal-ui.json) |

1. FunctionApp 
    * Check for last run time, if not then we will not filter by time.
      * When  deploying, this file should contain "Jan 1, 2000" to ensure all data is pulled the first time.
    * Run the query to get the policy states changed since last run time.
    * Store the results in ADX
    * Update the last run time.
2. Power BI Report
    * Connect to ADX and visualize the data.