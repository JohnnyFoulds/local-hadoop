# server details
$vCenterHostName = "vcenter-server.lan"
$vCenterUser = "administrator@vsphere.local"

# instance details
$datastore = "seagullDatastore"
$vmHost = "server-pc.lan"

function New-WorkerNode([string]$name) {
    $cloneParams = @{
        'Name' = $name
        'Datastore' = $datastore 
        'VM' = $vm
        'DiskStorageFormat' = 'Thin'
        'VMHost' = $vmHost
        'LinkedClone' = $null
        'ReferenceSnapshot' = $snapshot
    }

    # clone the vm
    $workerVM = New-VM @cloneParams

    # add cpu cores and memory
    Set-VM -VM $workerVM -NumCpu 2 -MemoryGB 2 -Confirm:$false
}

# connect to the vCenter server
$server = Connect-VIServer -Verbose:$true -Server $vCenterHostName -User $vCenterUser -Password $vCenterPassword

# get the manager node and snapshot to create the clones form
$vm = Get-VM -Server $server -Name "Hadoop Manager Node"
$snapshot = Get-Snapshot -VM $vm -Name "Manager Base Config"

# create the three worker nodes
New-WorkerNode -name "Hadoop Worker Node 01"
New-WorkerNode -name "Hadoop Worker Node 02"
New-WorkerNode -name "Hadoop Worker Node 03"

