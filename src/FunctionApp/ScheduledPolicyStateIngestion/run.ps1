# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

trap {
    Write-PSFMessage -Level Critical -Message "An unhandled error occurred: {0}" -StringValues $_.Exception.Message
    throw $_
}

$lastIngestionTimestampFileURI = Get-FunctionConfig '_LastIngestionTimestampFileURI'

Write-PSFMessage -Level Verbose -Message "Looking up last ingestion timestamp from {0}" -StringValues $lastIngestionTimestampFileURI
$latestRunTimestamp = Get-LatestTimestamp -FileUri $lastIngestionTimestampFileURI
Write-PSFMessage -Level Verbose -Message "Last ingestion timestamp: {0}" -StringValues $latestRunTimestamp

Write-PSFMessage -Level Verbose -Message "Querying Azure Resource Graph for compliance states updated since {0}" -StringValues $latestRunTimestamp
$query = Get-Content -Path "$PSScriptRoot/../AzGraphComplianceStates.kql" -Raw
$queryResults = Get-ComplianceState -Query $query -LastRunTimestamp $latestRunTimestamp -AsJsonLines
if ($queryResults.Length -eq 1) {
    Write-PSFMessage -Level Warning -Message "No new compliance states found since last ingestion timestamp {0}" -StringValues $latestRunTimestamp
}
else {
    Write-PSFMessage -Level Verbose -Message "Ingesting compliance states into ADX"
    $paramAddDataToADX = @{
        Database   = (Get-FunctionConfig '_ADXDatabaseName')
        TableName  = (Get-FunctionConfig '_ADXTableName')
        ClusterUri = (Get-FunctionConfig '_ADXClusterUri')
        Data       = $queryResults
    }

    Add-DataToADX @paramAddDataToADX

    Write-PSFMessage -Level Verbose -Message "Updating last ingestion timestamp to current time"
    Update-LatestTimestamp -FileUri $lastIngestionTimestampFileURI
}


# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"
