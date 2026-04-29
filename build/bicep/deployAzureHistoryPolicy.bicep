//--- Parameters ---//
param Location string = resourceGroup().location
param FunctionAppName string = 'func-azurepolicyhistory-01'
param ADXDatabaseName string = 'db-policyhistory'
param ScheduleCron string = '0 0 0 * * *' // Default to running at midnight every day

@description('Required: No | URL of the FunctionApp.zip file. This is the zip file containing the Function App code. Must be provided when OfflineDeploy is set to false | Default: The latest release of the Function App code.')
param FunctionAppZipUrl string = 'https://github.com/WillyMoselhy/AzurePolicyHistoryReport/releases/download/v0.0.10/FunctionApp.zip'


param Tags object = {}

//--- Variables ---//
var varADXClusterName = 'adx-azpolhist-${substring(uniqueString(resourceGroup().id,FunctionAppName), 0, 8)}'
var varADXClusterUri = '${varADXClusterName}.${resourceGroup().location}.kusto.windows.net'

//--- Resources ---//
module FunctionApp 'modules/FunctionApp.bicep' = {
  name: 'deployFunctionApp'
  params: {
    Location: Location
    FunctionAppName: FunctionAppName
    ADXClusterUri: varADXClusterUri
    FunctionAppZipUrl: FunctionAppZipUrl
    ADXDatabaseName: ADXDatabaseName
    ScheduleCron: ScheduleCron
    Tags: Tags
  }
}

module AzureDataExplorer 'modules/AzureDataExplorer.bicep' = {
  name: 'deployADX'
  params: {
    Location: Location
    ADXClusterName: varADXClusterName
    ADXDatabaseName: ADXDatabaseName
    FunctionAppSPId: FunctionApp.outputs.FunctionAppSPId
    Tags: Tags
  }
}

//--- Outputs ---//
