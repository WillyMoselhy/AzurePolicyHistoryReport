[CmdletBinding()]
param (
    [Parameter()]
    [string] $Path = '.\temp',

    [string] $Tag = 'v0.0.0'
)


# Update the version banner.
# The banner pattern is a regex pattern that matches the line containing the version banner. It has three matching groups, the second one is the one we replace.
$filesToUpdate = @(
    @{
        Path = '.\src\FunctionApp\profile.ps1'
        BannerPattern = @"
(Write-PSFMessage -Level Host -Message "This is Azure Policy History version \{0\}" -StringValues ')(.*)(')
"@
    }
    @{
        Path = '.\build\bicep\modules\deployAzurePolicyHistoryReport.bicep'
        BannerPattern = "(param FunctionAppZipUrl string = 'https://github.com/WillyMoselhy/AzurePolicyHistoryReport/releases/download/)(.*)(/FunctionApp.zip')"
    }
)

foreach($file in $filesToUpdate){
    $fileContent = Get-Content -Path $file.Path
    $bannerLine = $fileContent | Where-Object { $_ -match $file.BannerPattern } # This is the line that contains the version banner
    if (-not $bannerLine) { throw "Failed to find version banner line in $($file.Path)" } # Fail if the version banner line is not found
    $index = $fileContent.IndexOf($bannerLine) # This is the index of the version banner line
    $bannerLine = $bannerLine -replace $file.BannerPattern,  ('$1{0}$3' -f $Tag) # This is the new version banner line showing timestamp and build type
    $fileContent[$index] = $bannerLine # Replace the old version banner line with the new one
    $fileContent | Set-Content -Path $file.Path # Update the file

    Write-Host "Updated version in $($file.Path) to: $bannerLine"
}

# Create the zip file
$folder = New-Item -Path $Path -ItemType Directory -Force
$zipFilePath = $folder.FullName + "\FunctionApp.zip"
if (Test-Path $zipFilePath) { Remove-Item $zipFilePath -Force }
Compress-Archive -Path .\src\FunctionApp\* -DestinationPath $folder\FunctionApp.zip -Force -CompressionLevel Optimal
