function Invoke-ARGQuery {
    [CmdletBinding()]
    param (
        # Azure Resource Graph KQL Query
        [Parameter(Mandatory = $true)]
        [string]
        $Query,

        # Add Ingestion Time, requires "$ingestionTime" to appear in the query
        [Parameter(Mandatory = $false)]
        [switch]
        $AddIngestionTime,

        # Return as Json Lines
        [Parameter(Mandatory = $false)]
        [switch]
        $AsJsonLines
    )

    if ($AddIngestionTime) {
        # update the query to include the ingestionTime parameter
        $updatedQuery = $Query -replace '\$ingestionTime', "$(Get-Date -Format o)"
    }
    else {
        $updatedQuery = $Query
    }

    Write-PSFMessage -Level Verbose -Message "Executing Resource Graph Query:`n{0}" -StringValues $updatedQuery

    $skipToken = $null
    $searchResults = do {
        $results = Search-AzGraph -Query $updatedQuery -First 1000 -SkipToken $skipToken -UseTenantScope
        $skipToken = $results.SkipToken
        $results
    }
    while ($skipToken)

    Write-PSFMessage -Level Verbose -Message "Retrieved {0} records from Azure Resource Graph. If this is not expected review that the you have proper access." -StringValues $searchResults.Count


    if ($AsJsonLines) {
        $jsonl = ($searchResults | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 20 }) -join "`n"
        $jsonl += "`n"

        $jsonl
    }
    else {
        $searchResults
    }

}