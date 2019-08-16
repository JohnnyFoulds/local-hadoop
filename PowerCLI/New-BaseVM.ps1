# server details
$vCenterHostName = "vcenter-server.lan"
$vCenterUser = "administrator@vsphere.local"

# instance details
$datastore = "seagullDatastore"
$vmHost = "server-pc.lan"

# connect to the vCenter server
$server = Connect-VIServer -Verbose:$true -Server $vCenterHostName -User $vCenterUser -Password $vCenterPassword

# create the new virtual machine
$vm = New-VM -Server $server -Name "Base Linux Machine" -GuestId "centos7_64Guest" -Datastore $datastore -VMHost $vmHost -NumCpu 2 -DiskGB 40 -DiskStorageFormat Thin -MemoryGB 2 -CD
  
# select installation iso to mount
Get-CDDrive -VM $vm | Set-CDDrive -IsoPath "[omvDatastore] iso\CentOS-7-x86_64-DVD-1810.iso" -StartConnected $true -Confirm:$false

# start the virtual machine
Start-VM -VM $vm
