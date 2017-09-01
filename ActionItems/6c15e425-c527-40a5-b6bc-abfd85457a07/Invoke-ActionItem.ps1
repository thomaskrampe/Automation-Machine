<#
	.Synopsis
	Invokes the create group action item.

	.Description
 	Invokes the specified create group actionitem.
	
	.Parameter Actionitem
	Specifies the actionitem which to invoke.
		 
 	.Example
	$Pkg = Get-AMPackage -Name "TestPackage"
	Read-AMActionItems -Component $pkg
	$ActionSet = $Pkg.ActionSet | Select -First 1
	$ActionItem = $ActionSet.ActionItems | Select -First 1
 	Invoke-AMActionItemCreateGroup -ActionItem $ActionItem
#>
function Invoke-AMActionItemCreateGroup
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
	$Name = [String] $($Variables | ? {$_.name -eq "Name"}).Value | Expand-AMEnvironmentVariables
	$UsePrefixSuffix = [Boolean] $($Variables | ? {$_.name -eq "AutoAdd Prefix/Suffix"}).Value
	$Scope = [String] $($Variables | ? {$_.name -eq "Scope"}).Value | Expand-AMEnvironmentVariables
	
	
	If ($UsePrefixSuffix -eq $true)
	{
		$Name = $am_col_gprefix + $Name + $am_col_gsuffix
	}

	If ((Get-AMComputerDomain) -eq $null)
	{
		If ($Scope -ne [AutomationMachine.Plugins.ActiveDirectory.GroupScope]::Local) 
		{
			Write-AMWarning "The groupscope was set to: $Scope, but this computer is not a member of a domain, reverting to local groups"
			$Scope = ([AutomationMachine.Plugins.ActiveDirectory.GroupScope]::Local)
		}
		[string] $OULDAP = "WinNT://$env:computername"
	}
	else
	{
		[string] $OULDAP = "LDAP://$am_col_gou_dn,$(Get-AMDomainDN)"			
	}
	$Group = Get-AMLDAPPath -Name $Name
	If ($Group -is [Object])
	{
		Write-AMInfo "Security group $Name already exists"
	}
	Else
	{
		New-AMGroup -Name $Name -LDAPPath $OULDAP -Scope $Scope -Description ($am_col_gdescription | Expand-AMEnvironmentVariables) | Out-Null
	}
	
}

# Wait for AD group to exist
# This is an extension scriplet for the Create Securityy Group Action Item in Automation Machine
# AI: 6c15e425-c527-40a5-b6bc-abfd85457a07 - Create Security Group

Write-AMInfo "Getting DC replication neighbours"
$DC = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().FindDomainController()
$SiteDCs = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().FindAllDiscoverableDomainControllers($DC.SiteName) | Select-Object -ExpandProperty Name 
$ReplicationNeighbor = $DC.GetAllReplicationNeighbors() | ? {$SiteDCs -contains $_.sourceserver} | Select-Object -Unique -ExpandProperty SourceServer -First 1

If ($ReplicationNeighbor -ne $null)
{
    $MaxCount = 300
    $i = 0;
    while ((Get-AMLDAPPath -Name $Name) -eq $null)
    {
        $i += 1
        if ($i -ge $MaxCount) {throw "Unable to find AD group: $Name on $($ReplicationNeighbor) after $($MaxCount) seconds."}
        Write-Verbose "Waiting for $Name to appear on $ReplicationNeighbor"
        Start-Sleep -Seconds 1
    }
}
else {
    Write-AMInfo "No DC replication neighbors found, not waiting for replication"
}