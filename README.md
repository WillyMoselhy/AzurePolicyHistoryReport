# AzurePolicyHistoryReport

1. FunctionApp 
    * Check for last run time, if not then we will not filter by time.
      * When  deploying, this file should contain "Jan 1, 2000" to ensure all data is pulled the first time.
    * Run the query to get the policy states changed since last run time.
    * Store the results in ADX
    * Update the last run time.
2. Power BI Report
    * Connect to ADX and visualize the data.