$query = @"
resourcecontainers
| where type == 'microsoft.resources/subscriptions'
| project subscriptionName = name,
    subscriptionId,
    chain = properties.managementGroupAncestorsChain
| mv-expand with_itemindex = level chain
| project subscriptionName, subscriptionId, level,
    mgDisplayName = tostring(chain.displayName)
| sort by subscriptionId asc, level desc
| summarize subscriptionName = any(subscriptionName),
    chain = make_list(mgDisplayName)
    by subscriptionId
| project
    subscriptionId,
    subscriptionName,
    managementGroupPath = strcat_array(chain, "/"),
    ingestionTime = now()
"@

$query = @"
resourcecontainers
| where type == "microsoft.management/managementgroups"
| project
    id=name,
    ParentId = tostring(properties.details.parent.name),
    displayName = tostring(properties.displayName),
    NodeType = "ManagementGroup"
| union  (
    resourcecontainers
    | where type == "microsoft.resources/subscriptions"
    | project id = subscriptionId,
        displayName= name,
        ParentId = tostring(properties.managementGroupAncestorsChain[0].name),
        NodeType = "Subscription"
    )

"@


$searchResults = Search-AzGraph -Query $query -First 1000 -UseTenantScope

$jsonl = ($searchResults | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 20 }) -join "`n"
$jsonl += "`n"

$jsonl

$token = Get-AzAccessToken -ResourceUrl https://api.kusto.windows.net -AsSecureString

$connectKustoSplat = @{
    Cluster     = 'https://adxc-policyhistory-01.uaenorth.kusto.windows.net'
    AccessToken = $token.Token
}
Connect-Kusto @connectKustoSplat

# Convert string to bytes and create stream
$bytes = [System.Text.Encoding]::UTF8.GetBytes($jsonl)
$stream = New-Object System.IO.MemoryStream(, $bytes)
$stream.Position = 0

# Ingest data
Invoke-KustoIngestFromStream -Stream $stream -Table "SubscriptionMGHierarchy" -Format multijson -Verbose -Database "db-policyhistory"
$stream.Dispose()