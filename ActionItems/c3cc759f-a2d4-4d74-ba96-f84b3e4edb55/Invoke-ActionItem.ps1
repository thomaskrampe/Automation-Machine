<#
	.Synopsis
	Invokes the Wait action item.

	.Description
 	Invokes the Wait actionitem.
	
	.Parameter Actionitem
	Specifies the actionitem which to invoke.
		 
 	.Example
	$Pkg = Get-AMPackage -Name "TestPackage"
	Read-AMActionItems -Component $pkg
	$ActionSet = $Pkg.ActionSet | Select -First 1
	$ActionItem = $ActionSet.ActionItems | Select -First 1
 	Invoke-AMActionItemCopyFile2 -ActionItem $ActionItem
#>
function Invoke-AMActionItemWait
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[AutomationMachine.Data.ActionItem] $ActionItem
	)
	
	Write-AMInfo "Invoking $($ActionItem.Name)"
	# Resolve the variables including the filters,
	$Variables = $ActionItem.Variables
	$Variables | % {Resolve-AMVariableFilter $_}
	$Variables | % {Resolve-AMMediaPath $_}
	
	# Get the variables from the actionitem
	$WaitSec = $($Variables | ? {$_.name -eq "Wait seconds"}).Value.Path | Expand-AMEnvironmentVariables

    Start-Sleep -s $WaitSec
	Write-Verbose "Waiting for $WaitSec seconds."	
}