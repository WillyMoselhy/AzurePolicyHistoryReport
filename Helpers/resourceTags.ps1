$query = @"
resources
| project
    ['id'],
    ['tags']
| union (
    resourcecontainers
    | project
        ['id'],
        ['tags']
    )
| mv-expand kind=array ['tags']
| project
    id,
    tagName = tostring(tags[0]),
    tagValue = tostring(tags[1])
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
Invoke-KustoIngestFromStream -Stream $stream -Table "resourceTags" -Format multijson -Verbose -Database "db-policyhistory"
$stream.Dispose()