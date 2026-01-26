function Get-ComplianceState {
    [CmdletBinding()]
    param (
        # Azure Resource Graph KQL Query
        [Parameter(Mandatory = $true)]
        [string]
        $Query,

        # Last run timestamp
        [Parameter(Mandatory = $true)]
        [datetime]
        $LastRunTimestamp,

        # Return as Json Lines
        [Parameter(Mandatory = $false)]
        [switch]
        $AsJsonLines

    )

    # update the query to include the timestamp parameter
    $updatedQuery = $query -replace '\$LastRunTimestamp', "$($LastRunTimestamp.ToString("o"))"

    Write-PSFMessage -Level Verbose -Message "Executing Resource Graph Query:`n{0}" -StringValues $updatedQuery

    $skipToken = $null
    $searchResults = do {
        $results = Search-AzGraph -Query $updatedQuery -First 1000 -SkipToken $skipToken -UseTenantScope
        $skipToken = $results.SkipToken
        $results
    }
    while ($skipToken)

    Write-PSFMessage -Level Verbose -Message "Retrieved {0} compliance state records from Azure Resource Graph. If this is not expected review that the you have proper access." -StringValues $searchResults.Count


    if ($AsJsonLines) {
        $jsonl = ($searchResults | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 20 }) -join "`n"
        $jsonl += "`n"

        $jsonl
    }
    else {
        $searchResults
    }

}