# server details
$vCenterHostName = "vcenter-server.lan"
$vCenterUser = "administrator@vsphere.local"

# instance details
$datastore = "seagullDatastore"
$vmHost = "server-pc.lan"

# connect to the vCenter server
$server = Connect-VIServer -Verbose:$true -Server $vCenterHostName -User $vCenterUser -Password $vCenterPassword

$vm = Get-VM -Server $server -Name "Base Linux Machine"
$snapshot = Get-Snapshot -VM $vm -Name "Clean Install"

# create the manager machine based on the snapshot
$cloneParams = @{
    'Name' = 'Hadoop Manager Node'
    'Datastore' = $datastore 
    'VM' = $vm
    'DiskStorageFormat' = 'Thin'
    'VMHost' = $vmHost
    'LinkedClone' = $null
    'ReferenceSnapshot' = $snapshot
}

# clone the vm
$managerVM = New-VM @cloneParams

# add cpu cores and memory
Set-VM -VM $managerVM -NumCpu 4 -MemoryGB 8 -Confirm:$false

# start the virtual machine
Start-VM -VM $managerVM
