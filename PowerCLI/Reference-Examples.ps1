param
(
[Parameter(Mandatory = $false)] [String]$EsxiHostName = '192.168.3.100',
[Parameter(Mandatory = $false)] [String]$EsxiUser = 'root'#,
#[Parameter(Mandatory = $true)] [String]$EsxiPassword
)

#---
# get a collection of all the virtual machines on the server
function Show-VMs() {
    $reportPath = $env:TEMP + '\VMReport.html'

    # get all the virtual machines and write the output to a html file
    $vms = Get-VM -Name *
    $vms | ConvertTo-Html | Out-File $reportPath

    # display the html file
    Start-Process $reportPath
}

#---
#this function starts a vm if it is not already running
function Run-VM([string]$vmName) {
    # get the vm to start
    $vm = Get-VM -Server $server -Name $vmName
    #$vm | Get-View

    $powerState = $vm.PowerState
    if ($powerState -ne 'PoweredOff') {
        Write-Host("** The current state of the VM is ""$powerState"" and will not be started." )
    } 
    else {
        Write-Host("Starting: $vmName")
        Start-VM -Server $server -VM $vm -Confirm
    }   
}

#---
# create a a snapshot of the vm
function Create-Snapshot([string]$vmName, [string]$name, [string]$description) {
    $vm = Get-VM -Server $server -Name $vmName

    New-Snapshot -Server $server -VM $vm -Name $name -Description $description -Quiesce
}

#---
# create a new virtual machine
function Create-VM([string]$vmName, [string]$datastore) {
    $datastore = Get-Datastore -server $server -Name $datastore
    New-VM -Name $vmName -Datastore $datastore -DiskGB 20 -MemoryGB 2    
}

# connect the the exsi server
$server = Connect-VIServer -Verbose:$true -Server $EsxiHostName -User $EsxiUser -Password $EsxiPassword

# show a list of all the virtual machines
#Show-VMs

# start a vm
$vmName = "Docker Development (Lubuntu 19.04)"
#Run-VM $vmName

# create a snapshot
#Create-Snapshot $vmName "Sample" "This is the description"

# create a new virtual machine
Create-VM -vmName "CentOS 7.6 base" -datastore "mainDatastore"