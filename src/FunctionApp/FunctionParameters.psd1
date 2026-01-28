@{
    _ADXClusterUri                          = @{Required = $true ; Type = 'string'  ; Default = ''             ; Description = 'The ADX Cluster URI' }
    _ADXDatabaseName                        = @{Required = $true ; Type = 'string'  ; Default = ''             ; Description = 'The ADX Database Name' }
    _ADX_ComplianceStates_TableName         = @{Required = $true ; Type = 'string'  ; Default = ''             ; Description = 'The ADX Table Name' }
    _ADX_ResourceTags_TableName             = @{Required = $true ; Type = 'string'  ; Default = ''             ; Description = 'The ADX Table Name for Resource Tags' }
    _ADX_ManagementGroupHierarchy_TableName = @{Required = $true ; Type = 'string'  ; Default = ''             ; Description = 'The ADX Table Name for Management Group Hierarchy' }
}
