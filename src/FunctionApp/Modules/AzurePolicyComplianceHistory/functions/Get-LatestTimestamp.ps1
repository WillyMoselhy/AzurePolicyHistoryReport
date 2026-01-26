function Get-LatestTimestamp {
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
        throw "Failed to get data from $blobContainerName/$blobName"
    }
    $contentBytes = New-Object byte[] ($storageBlob.Properties.Length)
    $null = $storageBlob.DownloadToByteArray($contentBytes, 0)

    try{
        [datetime] [System.Text.Encoding]::UTF8.GetString($contentBytes)
    }
    catch{
        throw $_
    }
}