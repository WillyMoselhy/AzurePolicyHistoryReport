@{
    _LastIngestionTimestampFileURI = @{Required = $true ; Type = 'string'  ; Default = ''             ; Description = 'The URI of the file containing the last ingestion date' }
    _ADXClusterUri                 = @{Required = $true ; Type = 'string'  ; Default = ''             ; Description = 'The ADX Cluster URI' }
    _ADXDatabaseName               = @{Required = $true ; Type = 'string'  ; Default = ''             ; Description = 'The ADX Database Name' }
    _ADXTableName                  = @{Required = $true ; Type = 'string'  ; Default = ''             ; Description = 'The ADX Table Name' }
}
