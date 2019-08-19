# server details
$vCenterHostName = "vcenter-server.lan"
$vCenterUser = "administrator@vsphere.local"

Get-VM -Server $server -Name "Hadoop Worker Node 01" | Remove-VM -DeletePermanently -Confirm:$false
Get-VM -Server $server -Name "Hadoop Worker Node 02" | Remove-VM -DeletePermanently -Confirm:$false
Get-VM -Server $server -Name "Hadoop Worker Node 03" | Remove-VM -DeletePermanently -Confirm:$false
