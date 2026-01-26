
$kql = @"
policyresources
| where type == "microsoft.policyinsights/policystates"
"@

Search-AzGraph -Query $kql -First 1 | ConvertTo-Json -Depth 10 | scb



# This is how to ingest data into ADX
Install-PSResource -Name Az.Kusto
Install-PSResource -Name PowerShellKusto

Get-Command -Module az.kusto


$row = @(
    @{
        timestamp                      = (Get-Date).ToString("o")  # ISO 8601 is safest
        resourceId                     = "/subscriptions/xxxx/resourceGroups/xxxx/providers/xxxx"
        complianceState                = "Compliant"
        action                         = "audit"
        policyDefinitionReferenceId    = "refId"
        policyAssignmentDisplayName    = "Assignment Name"
        policySetDefinitionDisplayName = "Set Name"
        policyDefinitionDisplayName    = "Definition Name"
        resourceType                   = "Microsoft.Compute/virtualMachines"
        policyDefinitionId             = "policyDefId"
        policySetDefinitionId          = "policySetDefId"
        policyAssignmentId             = "assignmentId"
        policyAssignmentScope          = "/subscriptions/xxxx"
    },
    @{
        timestamp                      = (Get-Date).ToString("o")
        resourceId                     = "/subscriptions/xxxx/resourceGroups/xxxx/providers/xxxx"
        complianceState                = "Compliant"
        action                         = "audit"
        policyDefinitionReferenceId    = "refId"
        policyAssignmentDisplayName    = "Assignment Name"
        policySetDefinitionDisplayName = "Set Name"
        policyDefinitionDisplayName    = "Definition Name"
        resourceType                   = "Microsoft.Compute/virtualMachines"
        policyDefinitionId             = "policyDefId"
        policySetDefinitionId          = "policySetDefId"
        policyAssignmentId             = "assignmentId"
        policyAssignmentScope          = "/subscriptions/xxxx"
    }
)

# Convert each record to one-line JSON, then join as JSON Lines (NDJSON)
$jsonl = ($row | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 20 }) -join "`n"
$jsonl += "`n"

# Convert string to bytes and create stream
$bytes  = [System.Text.Encoding]::UTF8.GetBytes($jsonl)
$stream = New-Object System.IO.MemoryStream(, $bytes)
$stream.Position = 0

$token = Get-AzAccessToken -ResourceUrl https://api.kusto.windows.net -AsSecureString

$connectKustoSplat = @{
    Cluster     = 'https://adxc-policyhistory-01.uaenorth.kusto.windows.net'
    AccessToken = $token.Token
}
Connect-Kusto @connectKustoSplat

Connect-Kusto -Cluster "https://adxc-policyhistory-01.uaenorth.kusto.windows.net" -Database "db-policyhistory" -Verbose
Invoke-KustoIngestFromStream -Stream $stream -Table "PolicyStatesReport" -Format json -Verbose -Database "db-policyhistory"

$stream.Dispose()




Connect-Kusto -Cluster "adxc-policyhistory-01" -Database "db-policyhistory"
Invoke-KustoIngestFromStream -Stream $stream -Table "PolicyStatesReport" -Format json -Verbose



-ClusterName "adxc-policyhistory-01" -DatabaseName "db-policyhistory" -TableName "PolicyStatesReport" -Data $json -DataFormat multijson

Find-Command Invoke-AzKustoDataIngestion
Find-Command Invoke-AzKustoQuery



$test = Search-AzGraph -UseTenantScope -Query @"
policyresources
| where type =~ 'microsoft.authorization/policydefinitionssss'
| project id, displayName=tostring(properties.displayName)
| take 5
"@ -First 5
