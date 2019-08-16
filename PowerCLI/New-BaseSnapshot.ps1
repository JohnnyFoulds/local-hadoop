# server details
$vCenterHostName = "vcenter-server.lan"
$vCenterUser = "administrator@vsphere.local"

# instance details
$datastore = "seagullDatastore"
$vmHost = "server-pc.lan"

# connect to the vCenter server
$server = Connect-VIServer -Verbose:$true -Server $vCenterHostName -User $vCenterUser -Password $vCenterPassword

# create a snapshot of the base machine
$vm = Get-VM -Server $server -Name "Base Linux Machine"
New-Snapshot -Server $server -VM $vm -Name "Clean Install" -Description "Clean installation of CentOS 7 with admin user created" -Quiesce