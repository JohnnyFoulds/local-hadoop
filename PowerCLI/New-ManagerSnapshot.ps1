# server details
$vCenterHostName = "vcenter-server.lan"
$vCenterUser = "administrator@vsphere.local"

# instance details
$datastore = "seagullDatastore"
$vmHost = "server-pc.lan"

# connect to the vCenter server
$server = Connect-VIServer -Verbose:$true -Server $vCenterHostName -User $vCenterUser -Password $vCenterPassword

# create a snapshot of the base machine
$vm = Get-VM -Server $server -Name "Hadoop Manager Node"
New-Snapshot -Server $server -VM $vm -Name "Manager Base Config" -Description "Hadoop Manager Node Base Config" -Quiesce