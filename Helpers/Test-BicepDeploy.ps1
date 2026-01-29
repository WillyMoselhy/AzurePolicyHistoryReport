$RGName = 'rg-policyhistory-iac-01'

New-AzResourceGroup -Name $RGName -Location 'UAE North'
New-AzResourceGroupDeployment -Name "Test-IAC-Deployment" -ResourceGroupName $RGName -TemplateFile ".\build\bicep\modules\deployAzurePolicyHistoryReport.bicep" -FunctionAppName 'func-policyhistory-01' -Verbose