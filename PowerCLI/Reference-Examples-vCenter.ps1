param
(
[Parameter(Mandatory = $false)] [String]$vCenterHostName = 'vcenter-server.lan',
[Parameter(Mandatory = $false)] [String]$vCenterUser = '"administrator@vsphere.local"'#,
#[Parameter(Mandatory = $true)] [String]$vCenterPassword
)

#--
# Create a new Linux VM
function Create-LinuxVM([string]$vmName, [string]$datastore, [string]$dnsServer, [string]$domain) {
    # create the os customization spec
    New-OSCustomizationSpec -Server $server -DnsServer $dnsServer -Domain $domain -OSType Linux
}

#--
# move a vm to the specified datastore
function Change-VMDatastore([string]$vmName, [string]$datastore) {
    Get-VM -Server $server -Name $vmName | Move-VM -Server $server -Datastore $datastore
}

#--
# create a clone of a virtual machie
function Clone-VM([string]$vmName, [string]$datastore, [string]$sourceVM, [string]$referenceSnapshot) {
    # get the source vm
    $vmSource = Get-VM -Server $server -Name $sourceVM

    # set up the creation paramaters
    $cloneParams = @{
        'Name' = $vmName
        'Datastore' = $datastore 
        'VM' = $vmSource 
        'DiskStorageFormat' = 'thin'
    }

    # add the reference snapshot and LinkedClone paramaters if a snapshot was specified
    if ($referenceSnapshot -ne "") {
        $snapshot = Get-Snapshot -VM $vmSource -Name $referenceSnapshot

        $cloneParams.Add("LinkedClone", $null)
        $cloneParams.Add("ReferenceSnapshot", $snapshot)
    }
    
    # clone the vm
    New-VM @cloneParams
}

#New-vm -name clonevmtest -vm convert3  -datastore 250stor01-vmhost 10.250.11.1 -DiskStorageFormat thin
#I suggest adding   -DiskStorageFormat  other wise it will use thick disks

# connect to the vCenter server
$server = Connect-VIServer -Verbose:$true -Server $vCenterHostName -User $vCenterUser -Password $vCenterPassword


#---
# create a new linux vm
Create-LinuxVM -vmName "CentOS 7.6 base" -datastore "mainDatastore" -dnsServer 192.168.3.1 -domain "lan"

# move the vm to a different datastore
#Change-VMDatastore -vmName $vmName -datastore "seagullDatastore"


# clone a virtual machine
#Clone-VM -vmName "Lubuntu Clone" -datastore "seagullDatastore" -sourceVM $vmName
#Clone-VM -vmName "Lubuntu Clone" -datastore "seagullDatastore" -sourceVM $vmName -referenceSnapshot "Clean Install"