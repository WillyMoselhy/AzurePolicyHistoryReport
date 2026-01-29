//------ Parameters ------//
@description('Required: No | Region of the Function App. This does not need to be the same as the location of the Azure Virtual Desktop Host Pool. | Default: Location of the resource group.')
param Location string = resourceGroup().location

// Resource Names
@description('Required: Yes | Name of the Function App to be created.')
param FunctionAppName string

// Storage Account
@description('Required: No | Name of the Blob Container used to store the Function App code. | Default: azurepolicyhistoryfunctionapp')
param blobContainerName string = 'azurepolicyhistoryfunctionapp'

// FunctionApp

@description('Required: No | URL of the FunctionApp.zip file. This is the zip file containing the Function App code. Must be provided when OfflineDeploy is set to false | Default: The latest release of the Function App code.')
param FunctionAppZipUrl string = 'https://github.com/Azure/AVDSessionHostReplacer/releases/download/v0.3.4-beta.0/FunctionApp.zip'

//Monitoring
param EnableMonitoring bool = true
param UseExistingLAW bool = false
@description('Required: Yes | Name of the Log Analytics Workspace used by the Function App Insights.')
param LogAnalyticsWorkspaceId string = 'none'

//---- Variables ----//
var varStorageAccountName = toLower('saaphx${uniqueString(resourceGroup().id, FunctionAppName)}')
var varFunctionAppEvironmentVariables = [
  // Required Parameters //
  {
    name: '_ADXClusterUri'
    value: 'SAMPLE VALUE'
  }
  {
    name: '_ADXDatabaseName'
    value: 'SAMPLE VALUE' //TODO: Get this from the ADX output
  }
  {
    name: '_ADX_ComplianceStates_TableName'
    value: 'PolicyComplianceStates'
  }
  {
    name: '_ADX_ResourceTags_TableName'
    value: 'ResourceTags'
  }
  {
    name: '_ADX_ManagementGroupHierarchy_TableName'
    value: 'ManagementGroupHierarchy'
  }
]

//---- Resources ----//
module FunctionAppPlan 'br/public:avm/res/web/serverfarm:0.6.0' = {
  params: {
    location: Location
    name: '${FunctionAppName}-plan'
    kind: 'functionapp'
    skuName: 'FC1' // Flex Consumption
    reserved: true
  }
}

module storageAccount 'br/public:avm/res/storage/storage-account:0.31.0' = {
  params: {
    location: Location
    name: varStorageAccountName
    skuName: 'Standard_ZRS'
    kind: 'StorageV2'
    accessTier: 'Hot'
    blobServices: {
      containers: [
        {
          name: blobContainerName
        }
      ]
    }
    roleAssignments: [
      {
        principalId: FunctionApp.outputs.?systemAssignedMIPrincipalId ?? ''
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'
        principalType: 'ServicePrincipal'
      }
      {
        principalId: FunctionApp.outputs.?systemAssignedMIPrincipalId ?? ''
        roleDefinitionIdOrName: 'Storage Blob Data Owner'
        principalType: 'ServicePrincipal'
      }
    ]
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
  }
}

module FunctionApp 'br/public:avm/res/web/site:0.21.0' = {
  params: {
    location: Location
    name: FunctionAppName
    serverFarmResourceId: FunctionAppPlan.outputs.resourceId
    managedIdentities: {
      systemAssigned: true
    }
    kind: 'functionapp,linux'
    functionAppConfig: {
      deployment: {
        storage: {
          authentication: {
            type: 'SystemAssignedIdentity'
          }
          type: 'blobContainer'
          value: 'https://${varStorageAccountName}.blob.${environment().suffixes.storage}/${blobContainerName}'
        }
      }
      runtime: {
        name: 'powershell'
        version: '7.4'
      }
      scaleAndConcurrency: {
        instanceMemoryMB: 2048
        maximumInstanceCount: 1
      }
    }
    siteConfig: {
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
    }
  }
}
resource FunctionAppMSDeploy 'Microsoft.Web/sites/extensions@2025-03-01' = {
  name: '${FunctionAppName}/MSDeploy'
  properties: {
    packageUri: FunctionAppZipUrl
  }
  dependsOn: [
    FunctionApp
    storageAccount
  ]
}
