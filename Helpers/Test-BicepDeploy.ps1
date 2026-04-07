$RGName = 'rg-policyhistory-iac-01'

$null = New-AzResourceGroup -Name $RGName -Location 'UAE North' -force

$paramNewAzResourceGroupDeployment = @{
    Name              = "Test-IAC-Deployment"
    ResourceGroupName = $RGName
    TemplateFile      = ".\build\bicep\modules\deployAzurePolicyHistoryReport.bicep"
    FunctionAppName   = 'func-policyhistory-01'
    Verbose           = $true
}   
New-AzResourceGroupDeployment @paramNewAzResourceGroupDeployment