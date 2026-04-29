// Azure Data Explorer (ADX) module
//--- Parameters ---//
//------ Parameters ------//
@description('Required: No | Region of the Function App. This does not need to be the same as the location of the Azure Virtual Desktop Host Pool. | Default: Location of the resource group.')
param Location string = resourceGroup().location

param ADXClusterName string
param ADXDatabaseName string
param FunctionAppSPId string

@description('Required: No | Tags to apply to all resources deployed by this module.')
param Tags object = {}
//--- Variables ---//

//--- Resources ---//
resource adxCluster 'Microsoft.Kusto/clusters@2025-02-14' = {
  name: ADXClusterName
  location: Location
  tags: Tags
  sku: {
    name: 'Dev(No SLA)_Standard_D11_v2'
    capacity: 1
    tier: 'Basic'
  }
}

resource adxDatabase 'Microsoft.Kusto/clusters/databases@2025-02-14' = {
  parent: adxCluster
  name: ADXDatabaseName
  location: Location
  kind: 'ReadWrite'
  properties: {
    softDeletePeriod: 'P365D'
    hotCachePeriod: 'P31D'
  }
  resource adxDatabasePrincipalAssignment 'principalAssignments@2025-02-14' = {
    name: ADXDatabaseName
    properties: {
      principalId: FunctionAppSPId
      principalType: 'App'
      role: 'Ingestor'
    }
  }

  resource adxDatabaseTable01 'scripts@2025-02-14' = {
    name: 'create-table-PolicyStatesReport'
    properties: {
      continueOnErrors: false
      forceUpdateTag: guid(resourceGroup().id, ADXClusterName, ADXDatabaseName, 'PolicyStatesReport')
      scriptContent: '''
// This KQL script creates a table named 'PolicyStatesReport' with specified columns and data types.
.create table PolicyStatesReport (
    ingestionTime: datetime,
    policyStateTime: datetime,
    resourceId: string,
    resourceGroup: string,
    subscriptionId: string,
    resourceName: string,
    resourceType: string,
    complianceState: string,
    isCompliant: int,
    isNonCompliant: int,
    policyEffect: string,
    initiativePolicyReferenceId: string,
    policyAssignmentName: string,
    initiativeName: string,
    policyName: string,
    policyDefinitionId: string,
    policySetDefinitionId: string,
    policyAssignmentId: string,
    policyAssignmentScope: string
)
    '''
    }
  }
  resource adxDatabaseTable02 'scripts@2025-02-14' = {
    name: 'create-table-SubscriptionMGHierarchy'
    properties: {
      continueOnErrors: false
      forceUpdateTag: guid(resourceGroup().id, ADXClusterName, ADXDatabaseName, 'SubscriptionMGHierarchy')
      scriptContent: '''
// This KQL script creates a table named 'SubscriptionMGHierarchy' to store subscription and management group hierarchy information.
.create table SubscriptionMGHierarchy (
    ingestionTime: datetime,
    subscriptionName: string,
    subscriptionId: string,
    managementGroupPath: string
)
    '''
    }
  }
  resource adxDatabaseTable03 'scripts@2025-02-14' = {
    name: 'create-table-resourceTags'
    properties: {
      continueOnErrors: false
      forceUpdateTag: guid(resourceGroup().id, ADXClusterName, ADXDatabaseName, 'resourceTags')
      scriptContent: '''
.create table resourceTags (
    ingestionTime: datetime,
    id: string,
    tagName: string,
    tagValue: string
)
    '''
    }
  }
}

//--- Outputs ---//
