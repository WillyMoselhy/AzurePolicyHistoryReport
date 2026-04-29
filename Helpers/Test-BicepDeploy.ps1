$RGName = 'rg-policyhistory-iac-01'

$null = New-AzResourceGroup -Name $RGName -Location 'UAE North' -Force

$paramNewAzResourceGroupDeployment = @{
    Name                    = "Test-IAC-Deployment"
    ResourceGroupName       = $RGName
    TemplateFile            = ".\build\bicep\deployAzureHistoryPolicy.bicep"
    TemplateParameterObject = @{
        ADXDatabaseName = 'db-policyhistory'
        ScheduleCron    = '0 0 0 * * *'

        Tags            = @{
            SecurityControl = 'Ignore'
        }

    }
    FunctionAppName         = 'func-policyhistory-01'
    Verbose                 = $true
}
New-AzResourceGroupDeployment @paramNewAzResourceGroupDeployment