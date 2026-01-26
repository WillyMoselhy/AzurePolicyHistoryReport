function Add-DataToADX {
    [CmdletBinding()]
    param (
        # Cluster URi
        [Parameter(Mandatory = $true)]
        [string]
        $ClusterURi,

        # Database Name
        [Parameter(Mandatory = $true)]
        [string]
        $Database,

        # Table Name
        [Parameter(Mandatory = $true)]
        [string]
        $TableName,

        # Data as Json lines
        [Parameter(Mandatory = $true)]
        [string]
        $Data
    )

    # Create Kusto Connection
    $token = Get-AzAccessToken -ResourceUrl https://api.kusto.windows.net -AsSecureString

    $connectKustoSplat = @{
        Cluster     = $ClusterURi
        AccessToken = $token.Token
    }
    Connect-Kusto @connectKustoSplat

    # Convert string to bytes and create stream
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Data)
    $stream = New-Object System.IO.MemoryStream(, $bytes)
    $stream.Position = 0

    # Ingest data
    Invoke-KustoIngestFromStream -Stream $stream -Table $TableName -Format multijson -Verbose -Database $Database
    $stream.Dispose()
}