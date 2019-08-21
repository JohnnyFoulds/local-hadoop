# server details
$vCenterHostName = "vcenter-server.lan"
$vCenterUser = "administrator@vsphere.local"

# connect to the vCenter server
$server = Connect-VIServer -Verbose:$true -Server $vCenterHostName -User $vCenterUser -Password $vCenterPassword

Get-VM -Server $server -Name "Hadoop Manager Node"   | Start-VM -Confirm:$false
Get-VM -Server $server -Name "Hadoop Worker Node 01" | Start-VM -Confirm:$false
Get-VM -Server $server -Name "Hadoop Worker Node 02" | Start-VM -Confirm:$false
Get-VM -Server $server -Name "Hadoop Worker Node 03" | Start-VM -Confirm:$false
