param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $true)]
    [string]$VirtualMachineName
)

# Requires -Version 5.0
# Requires -Modules Az.Compute

<#
.SYNOPSIS
    Restarts an Azure Virtual Machine.

.DESCRIPTION
    This runbook restarts an Azure Virtual Machine. It is scheduled to run daily at 10 AM UTC.
    
    Prerequisites:
    - The Automation Account must have an Azure Run As Account or Managed Identity
    - The Run As Account must have permissions to restart the VM

.PARAMETER ResourceGroupName
    The name of the resource group containing the VM

.PARAMETER VirtualMachineName
    The name of the Virtual Machine to restart

.EXAMPLE
    .\main.ps1 -ResourceGroupName "myResourceGroup" -VirtualMachineName "myVM"

#>

$ErrorActionPreference = "Stop"

Write-Output "Starting VM restart process for VM: $VirtualMachineName in Resource Group: $ResourceGroupName"

try {
    # Log in using Automation Account's Managed Identity
    Connect-AzAccount -Identity -ErrorAction Stop
    
    Write-Output "Successfully authenticated with Azure"
    
    # Get the VM
    $vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VirtualMachineName -ErrorAction Stop
    
    if (-not $vm) {
        throw "Virtual Machine '$VirtualMachineName' not found in resource group '$ResourceGroupName'"
    }
    
    Write-Output "Found VM: $($vm.Name)"
    Write-Output "VM ID: $($vm.Id)"
    Write-Output "Current power state: $($vm.PowerState)"
    
    # Restart the VM
    Write-Output "Initiating VM restart..."
    Restart-AzVM -ResourceGroupName $ResourceGroupName -Name $VirtualMachineName -ErrorAction Stop
    
    Write-Output "VM restart initiated successfully"
    Write-Output "VM: $VirtualMachineName in Resource Group: $ResourceGroupName has been restarted"
    
}
catch {
    Write-Error "Error occurred during VM restart: $($_.Exception.Message)"
    Write-Error "Error details: $($_ | Out-String)"
    throw
}
finally {
    Write-Output "VM restart runbook execution completed"
}
