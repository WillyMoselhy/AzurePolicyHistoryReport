$requiredModules = @(
    'PSFramework',
    'AzureFunctionConfiguration'
    'Az.Accounts'
    'Az.ResourceGraph',
    'Az.Storage',
    'PowerShellKusto'
)
Save-PSResource -Name $requiredModules -path $PSScriptRoot\..\src\FunctionApp\Modules -AcceptLicense -Confirm:$false -TrustRepository
