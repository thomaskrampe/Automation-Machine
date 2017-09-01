<#
	.Synopsis
	Invokes the apply file permissions action item.

	.Description
 	Invokes the specified install true type fonts actionitem.
	
	.Parameter Actionitem
	Specifies the actionitem which to invoke.
		 
 	.Example
	$Pkg = Get-AMPackage -Name "TestPackage"
	Read-AMActionItems -Component $pkg
	$ActionSet = $Pkg.ActionSet | Select -First 1
	$ActionItem = $ActionSet.ActionItems | Select -First 1
 	Invoke-AMActionItemInstallTTF -ActionItem $ActionItem
#>
function Invoke-AMActionItemCheckForPort

{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[AutomationMachine.Data.ActionItem] $ActionItem
	)
	
	Write-AMInfo "Invoking $($ActionItem.ActionItemTemplate.Name)"
	# Resolve the variables including the filters,
	$Variables = $ActionItem.Variables
	$Variables | % {Resolve-AMVariableFilter $_}
	
	# Get the variables from the actionitem
	$Port = $($Variables | ? {$_.name -eq "Port"}).Value
	$Timer = $($Variables | ? {$_.name -eq "Poll interval"}).Value
	$remotecomp = $($Variables | ? {$_.name -eq "Computer Name"}).Value | Expand-AMEnvironmentVariables
	$PortOpen = $false
	$MaxTime = $($Variables | ? {$_.name -eq "Max time to wait"}).Value
	$retry = $true
	$done = $false
	$TimeWaited = 0
	
	While ($retry -eq $true) 
	{		$Socket = New-Object System.Net.Sockets.TCPClient        Try 
		{		    $socket.connect($remotecomp, $port) | out-null
		    $PortOpen = $Socket.Connected
        } 
		Catch {}        if ($portOpen -eq $false)
		{                Write-AMInfo "Port $Port on Computer $RemoteComp not reachable, waiting $Timer seconds" 
				Sleep -seconds $timer
				$TimeWaited += $timer
				If ($TimeWaited -ge $MaxTime)
				{
					$retry = $false
				}
		} 
		else 
		{                Write-AMInfo "Port $Port on Computer $RemoteComp reachable."
				$done = $true
				$retry = $false        }
		$Socket.Close()	}

	If ($done -eq $false)
	{
		throw "Waited $($MaxTime) seconds for port $($Port) to become availabe on $($remotecomp), but still unreachable"
	}}





