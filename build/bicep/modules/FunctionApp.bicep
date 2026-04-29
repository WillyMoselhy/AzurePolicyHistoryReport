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
param FunctionAppZipUrl string

//Monitoring
param EnableMonitoring bool = true
param UseExistingLAW bool = false
@description('Required: Yes | Name of the Log Analytics Workspace used by the Function App Insights.')
param LogAnalyticsWorkspaceId string = 'none'

// ADX
@description('Required: Yes | URI of the Azure Data Explorer cluster to which the Function App will send data.')
param ADXClusterUri string
@description('Required: Yes | Name of the Azure Data Explorer database to which the Function App will send data.')
param ADXDatabaseName string

// Scheduler Cron
@description('Required: No | Cron expression for when the Function App should run. | Default: 0 0 0 * * * (every 24 hours)')
param ScheduleCron string = '0 0 0 * * *'

// Tags
@description('Required: No | Tags to apply to all resources deployed by this module.')
param Tags object = {}

//---- Variables ----//
var varStorageAccountName = toLower('saaphx${uniqueString(resourceGroup().id, FunctionAppName)}')
var varLogAnalyticsWorkspaceName = '${FunctionAppName}-law'
var varAppServicePlanName = '${FunctionAppName}-asp'

var varFunctionAppEnvironmentVariables = [
  // Storage Authentication
  {
    name: 'AzureWebJobsStorage__blobServiceUri'
    value: 'https://${varStorageAccountName}.blob.${environment().suffixes.storage}'
  }
  {
    name: 'AzureWebJobsStorage__queueServiceUri'
    value: 'https://${varStorageAccountName}.queue.${environment().suffixes.storage}'
  }
  {
    name: 'AzureWebJobsStorage__tableServiceUri'
    value: 'https://${varStorageAccountName}.table.${environment().suffixes.storage}'
  }
  {
    name: 'AzureWebJobsStorage__credential'
    value: 'managedidentity'
  }
  // Application Insights
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appInsights.properties.InstrumentationKey
  }
  // ADX Parameters //
  {
    name: '_ADXClusterUri'
    value: ADXClusterUri
  }
  {
    name: '_ADXDatabaseName'
    value: ADXDatabaseName
  }
  {
    name: '_ADX_ComplianceStates_TableName'
    value: 'PolicyStatesReport'
  }
  {
    name: '_ADX_ResourceTags_TableName'
    value: 'resourceTags'
  }
  {
    name: '_ADX_ManagementGroupHierarchy_TableName'
    value: 'SubscriptionMGHierarchy'
  }
  // Cron for when it runs
  {
    name: 'TIMER_SCHEDULE'
    value: ScheduleCron
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
    tags: Tags

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
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      resourceAccessRules: []
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    tags: Tags
  }
}

// Deploy or use Log Analytics Workspace
resource deployLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = if (EnableMonitoring && !UseExistingLAW) {
  name: varLogAnalyticsWorkspaceName
  location: Location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}
// Deploy App Insights for App Service Plan
resource appInsights 'Microsoft.Insights/components@2020-02-02' = if (EnableMonitoring) {
  name: varAppServicePlanName
  location: Location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    WorkspaceResourceId: UseExistingLAW ? LogAnalyticsWorkspaceId : deployLogAnalyticsWorkspace.id
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
      appSettings: varFunctionAppEnvironmentVariables
    }
    tags: Tags
  }
}
resource FunctionAppMSDeploy 'Microsoft.Web/sites/extensions@2025-03-01' = {
  name: '${FunctionAppName}/onedeploy'
  properties: {
    packageUri: FunctionAppZipUrl
    remoteBuild: false
  }
  dependsOn: [
    roleAssignments01
    roleAssignments02
  ]
}

// Role Assignment for Storage Account access
module roleAssignments01 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  params: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/b7e6dc6d-f1e8-4753-8033-0f276bb0955b' //'Storage Blob Data Owner'
    principalId: FunctionApp.outputs.?systemAssignedMIPrincipalId!
    resourceId: storageAccount.outputs.resourceId
    principalType: 'ServicePrincipal'
  }
}
module roleAssignments02 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.2' = {
  params: {
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/974c5e8b-45b9-4653-ba55-5f855dd0fb88' // 'Storage Queue Data Contributor'
    principalId: FunctionApp.outputs.?systemAssignedMIPrincipalId!
    resourceId: storageAccount.outputs.resourceId
    principalType: 'ServicePrincipal'
  }
}


//---- Outputs ----//
output FunctionAppSPId string = FunctionApp.outputs.?systemAssignedMIPrincipalId!
