function Update-LatestTimestamp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FileUri
    )

    # Convert the URI to a Storage Context
    $storageAccountName = (($FileUri -split '/')[2] -split '\.')[0]
    $blobContainerName = ($FileUri -split '/')[3]
    $blobName = ($FileUri -split "/")[4..($FileUri -split "/").Count] -join "/"

    $stgContext = New-AzStorageContext -StorageAccountName $storageAccountName
    $storageContainer = Get-AzStorageContainer -Name $blobContainerName -Context $stgContext

    try {
        $storageBlob = $storageContainer.CloudBlobContainer.GetBlobReferenceFromServer($blobName)
    }
    catch {
        throw "Failed to get data from $FileUri"
    }

    $contentBytes = [System.Text.Encoding]::UTF8.GetBytes( (Get-Date).ToString("o") )

    $storageBlob.UploadFromByteArray($contentBytes, 0, $contentBytes.Length)

    Write-PSFMessage -Level Verbose -Message "Updated latest ingestion timestamp to {0} in {1}" -StringValues (Get-Date).ToString("o"), $FileUri
}