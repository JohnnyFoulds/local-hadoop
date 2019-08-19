# server details
$vCenterHostName = "vcenter-server.lan"
$vCenterUser = "administrator@vsphere.local"

Get-VM -Server $server -Name "Hadoop Manager Node"   | Shutdown-VMGuest -Confirm:$false
Get-VM -Server $server -Name "Hadoop Worker Node 01" | Shutdown-VMGuest -Confirm:$false
Get-VM -Server $server -Name "Hadoop Worker Node 02" | Shutdown-VMGuest -Confirm:$false
Get-VM -Server $server -Name "Hadoop Worker Node 03" | Shutdown-VMGuest -Confirm:$false
