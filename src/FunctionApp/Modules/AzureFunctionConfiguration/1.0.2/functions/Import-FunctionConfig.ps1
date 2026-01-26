
function Import-FunctionConfig {
	<#
	.SYNOPSIS
		Imports a set of data into a script FunctionConfig variable.

	.DESCRIPTION
		#Amended from https://github.com/FriedrichWeinmann/Azure.Function.Tools
		Imports a set of data into a script config variable.
		Use Get-FunctionConfig to read config settings.
		Supports both Json and psd1 files, does not resolve any nesting of values.

		Sample psd1 file:
		@{
    		Parameter Name = @{Required = $false; Type = 'string'; Default = 'SampleDefaultValue' ; Description = 'Sample Parameter Description' }
		}
	.EXAMPLE
		PS C:\> Import-Config -Path ".\FunctionParameters.psd1"

		Loads the FunctionParameters.psd1 file from the folder of the calling file's.
	#>
	[CmdletBinding()]
	param (
		# Path to the config file to read. This can either be a psd1 or json file.
		[Parameter(Mandatory = $false)]
		[string]
		$FunctionParametersFilePath = '.\FunctionParameters.psd1',

		# Do not log the values of the parameters.
		[Parameter(Mandatory = $false)]
		[switch]
		$DoNotLogValues,

		# Show SAS keys in output. Default is to redact all SAS keys.
		[Parameter(Mandatory = $false)]
		[switch]
		$ShowSASKeys
	)
	Write-PSFMessage -Level Verbose -Message "Importing Function Parameters from: $FunctionParametersFilePath"
	$functionParameters = Import-PSFPowerShellDataFile -Path $FunctionParametersFilePath -ErrorAction Stop

	# Current options are default, or environment variable.
	# Loop through imported hashtable, and replace any values that are environment variables.
	foreach ($item in $functionParameters.GetEnumerator()) {
		Write-PSFMessage -Level Verbose -Message 'Processing parameter: {0}' -StringValues $item.Name
		# Required parameters should be supplied as environment variables.
		if($item.Value.Required){
			Write-PSFMessage -Level Verbose -Message 'Parameter is required. Looking for environment variable: {0}' -StringValues $item.Name
			if(Test-Path -Path "env:$($item.Name)"){
				Write-PSFMessage -Level Verbose -Message 'Found environment variable: {0}' -StringValues $item.Name
				$paramValue = (Get-Item -Path "env:$($item.Name)").Value
			}
			else{
				Write-PSFMessage -Level Verbose -Message 'Environment variable not found: {0}' -StringValues $item.Name
				throw "Required parameter not found: $($item.Name)"
			}
		}
		else{ # Check if provided as environment variable or use default.
			if(Test-Path -Path "env:$($item.Name)"){
				Write-PSFMessage -Level Verbose -Message 'Found environment variable: {0}' -StringValues $item.Name
				$paramValue = (Get-Item -Path "env:$($item.Name)").Value
			}
			else{
				Write-PSFMessage -Level Verbose -Message 'Environment variable not found: {0}.' -StringValues $item.Name
				$paramValue = $item.Value.Default
			}
		}
		# Check if values use the write type.
		Write-PSFMessage -Level Verbose -Message 'Parameter {0} should be of type [{1}].' -StringValues $item.Name, $item.Value.Type.Trim()
		if($item.Value.Type -ne 'Hashtable'){
			try{
				$paramValue = [System.Convert]::ChangeType($paramValue, $item.Value.Type.Trim())
			}
			catch{
				throw "Parameter $($item.Name) has value '$($paramValue)' is not of type $($item.Value.Type.Trim())."
			}
		}
		else{ #Convert any json to hashtable.
			try{
				$paramValue = ConvertFrom-Json -InputObject $paramValue -Depth 99 -AsHashtable
			}
			catch{
				throw "Parameter $($item.Name) could not be converted from Json to hashtable."
			}
		}
		$script:FunctionConfig[$item.Name] = $paramValue
	}
	if(-Not $DoNotLogValues){
		Write-PSFMessage -Level Host -Message "Function Parameters:"
		foreach($item in $Script:FunctionConfig.GetEnumerator()){
			if($item.Value -like "http*?*" -and (-Not $ShowSASKeys)){
				$logValue = $item.Value -replace '\?.+'," (SAS REDACTED)"
			}
			else{
				if($item.Value.GetType().Name -eq 'Hashtable'){
					$logValue = $item.Value | ConvertTo-Json -Depth 99 -Compress
				}
				else{
					$logValue = $item.Value
				}
			}

			Write-PSFMessage -Level Host -Message "{0}: {1}"  -StringValues $item.Name, $logValue

		}
	}
}