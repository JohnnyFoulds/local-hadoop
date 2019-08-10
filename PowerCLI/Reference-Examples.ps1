param
(
[Parameter(Mandatory = $false)] [String]$EsxiHostName = '192.168.3.100',
[Parameter(Mandatory = $false)] [String]$EsxiUser = 'root',
[Parameter(Mandatory = $true)] [String]$EsxiPassword
)

# get a collection of all the virtual machines on the server
function show-vms
{
    $vms = Get-VM -Name *
    $vms | Format-List
}

# connect the the exsi server
$server = Connect-VIServer -Verbose:$true -Server $EsxiHostName -User $EsxiUser -Password $EsxiPassword

show-vms