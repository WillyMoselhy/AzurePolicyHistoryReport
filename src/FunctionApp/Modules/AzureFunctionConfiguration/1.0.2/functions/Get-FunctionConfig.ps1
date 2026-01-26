function Get-FunctionConfig {
    <#
    .SYNOPSIS
        Gets the value of a function config parameter.
    .DESCRIPTION
        Gets the value of a function config parameter.
        Use Import-FunctionConfig to import a set of data into a script config variable.
        Use Get-FunctionConfig to read config settings.
    .EXAMPLE
        PS C:\> Get-FunctionConfig -Name 'ParameterName'

        Gets the value of the parameter named 'ParameterName'.
    #>
    [CmdletBinding()]
    param (
        # Name of the parameter to get.
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $Name
    )
    $Script:FunctionConfig[$Name]
}