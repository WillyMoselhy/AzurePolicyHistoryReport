

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Tag,
    [Parameter()]
    [string]
    $GitRef
)

$timeStamp = Get-Date -Format 'yyyyMMdd-HHmmss'

$body = @"
ReleaseBody<<EOF
This release is built from $GitRef on $timeStamp
EOF
"@

$body >> $Env:GITHUB_OUTPUT