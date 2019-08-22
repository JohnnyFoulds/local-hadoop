# server details
$EsxiHostName = "192.168.3.100"
$EsxiUser = "root"

# connect to the vCenter server
$server = Connect-VIServer -Verbose:$true -Server $EsxiHostName -User $EsxiUser -Password $EsxiPassword

# get the manager node
$vm = Get-VM -Server $server -Name "Hadoop Manager Node"

# shutdown the node
Shutdown-VMGuest -Server $server -VM $vm -Confirm:$false

# make a snapshot
New-Snapshot -Server $server -VM $vm -Name "Cloudera Manager Installed" -Description "Cloudera Manager initial install" -Quiesce

# start the vm
Start-VM -Server $server -VM $vm
