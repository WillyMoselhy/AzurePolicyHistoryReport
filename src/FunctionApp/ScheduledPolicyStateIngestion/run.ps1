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

#region: Ingest Compliance States
Write-PSFMessage -Level Verbose -Message "Querying Azure Resource Graph for compliance states"
$query = Get-Content -Path "$PSScriptRoot/../KQLQueries/AzGraphComplianceStates.kql" -Raw
$queryResults = Invoke-ARGQuery -Query $query -AddIngestionTime -AsJsonLines
if ($queryResults.Length -eq 1) {
    Write-PSFMessage -Level Warning -Message "No compliance states found"
}
else {
    Write-PSFMessage -Level Verbose -Message "Ingesting compliance states into ADX"
    $paramAddDataToADX = @{
        ClusterUri = (Get-FunctionConfig '_ADXClusterUri')
        Database   = (Get-FunctionConfig '_ADXDatabaseName')
        TableName  = (Get-FunctionConfig '_ADX_ComplianceStates_TableName')
        Data       = $queryResults
    }

    Add-DataToADX @paramAddDataToADX
}
#endregion: Ingest Compliance States

#region: Ingest Resource Tags
Write-PSFMessage -Level Verbose -Message "Querying Azure Resource Graph for Resource Tags"
$query = Get-Content -Path "$PSScriptRoot/../KQLQueries/AzGraphResourceTags.kql" -Raw
$queryResults = Invoke-ARGQuery -Query $query -AddIngestionTime -AsJsonLines
if ($queryResults.Length -eq 1) {
    Write-PSFMessage -Level Warning -Message "No Tags found"
}
else {
    Write-PSFMessage -Level Verbose -Message "Ingesting tags into ADX"
    $paramAddDataToADX = @{
        ClusterUri = (Get-FunctionConfig '_ADXClusterUri')
        Database   = (Get-FunctionConfig '_ADXDatabaseName')
        TableName  = (Get-FunctionConfig '_ADX_ResourceTags_TableName')
        Data       = $queryResults
    }

    Add-DataToADX @paramAddDataToADX
}
#endregion: Ingest Resource Tags

#region: Ingest Management Group Hierarchy
Write-PSFMessage -Level Verbose -Message "Querying Azure Resource Graph for Management Group Hierarchy"
$query = Get-Content -Path "$PSScriptRoot/../KQLQueries/AzGraphMGHierarchy.kql" -Raw
$queryResults = Invoke-ARGQuery -Query $query -AddIngestionTime -AsJsonLines
if ($queryResults.Length -eq 1) {
    Write-PSFMessage -Level Warning -Message "No Management Group Hierarchy found"
}
else {
    Write-PSFMessage -Level Verbose -Message "Ingesting management group hierarchy into ADX"
    $paramAddDataToADX = @{
        ClusterUri = (Get-FunctionConfig '_ADXClusterUri')
        Database   = (Get-FunctionConfig '_ADXDatabaseName')
        TableName  = (Get-FunctionConfig '_ADX_ManagementGroupHierarchy_TableName')
        Data       = $queryResults
    }

    Add-DataToADX @paramAddDataToADX
}
#endregion: Ingest Management Group Hierarchy


# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"
