//--- Parameters ---//
param Location string = resourceGroup().location
param FunctionAppName string = 'AzureHistoryPolicy'
param ADXDatabaseName string
param ScheduleCron string = '0 0 0 * * *' // Default to running at midnight every day

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
