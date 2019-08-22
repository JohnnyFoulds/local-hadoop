# server details
$EsxiHostName = "192.168.3.100"
$EsxiUser = "root"

# connect to the vCenter server
$server = Connect-VIServer -Verbose:$true -Server $EsxiHostName -User $EsxiUser -Password $EsxiPassword

Get-VM -Server $server -Name "Hadoop Manager Node"   | Start-VM -Confirm:$false
Get-VM -Server $server -Name "Hadoop Worker Node 01" | Start-VM -Confirm:$false
Get-VM -Server $server -Name "Hadoop Worker Node 02" | Start-VM -Confirm:$false
Get-VM -Server $server -Name "Hadoop Worker Node 03" | Start-VM -Confirm:$false
