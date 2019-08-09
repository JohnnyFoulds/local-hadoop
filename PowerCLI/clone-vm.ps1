<# .SYNOPSIS Cloning a virtual machine on an esxi host using PowerCLI
 .PARAMETER EsxiHostName The name of the ESXi Host this VM that will be cloned
 .PARAMETER VMName The name of the VM that is cloned
 .PARAMETER VMNewName The name of the new VM
 .PARAMETER EsxiUser The name of the ESXi Host User
 .PARAMETER EsxiPassword The password for ESXi Host User
 .EXAMPLE PS> .\Clone-VM.ps1 -EsxiHostName 10.0.0.10 -EsxiUser "Esxi User Name" -EsxiPassword "Esxi Host Password" -VMName "VM Name" -VMNewName "VM Clone Name"
#>
 
param
(
[Parameter(Mandatory = $true)]
[String]$EsxiHostName,
[Parameter(Mandatory = $true)]
[String]$EsxiUser,
[Parameter(Mandatory = $true)]
[String]$EsxiPassword,
[Parameter(Mandatory = $true)]
[String]$VMName,
[Parameter(Mandatory = $true)]
[String]$VMNewName
)
 
## Connect to the ESXihost
Connect-VIServer -Verbose:$true -Server $EsxiHostName -User $EsxiUser -Password $EsxiPassword
 
## Check if the VM that you are going to clone is registered
 if ((Get-VM -Name $VMName) -like $VMName) 
 {
 Write-Host "Your VM ($VMName) is registered on this host!"
 } 
 else
 { 
 Cls
 Write-Host "VM ($VMName) does not exist or is not registered on this host($EsxiHostName)! Please register the VM ($VMName), then run the script!"
 pause
 Cls
 exit
 }
 
## Check whether the VM is enabled
 if((get-vm -name $VMName).PowerState -eq "PoweredOn" -or (get-vm -name $VMName).Guest.State -eq "Running") 
 {
 Cls
 Write-Host "Please correctly stop the VM ($VMName) before cloning, then start the script!"
 pause
 Cls
 exit
 }
 else
 { 
 Write-Host "Your VM ($VMName) is in a power off state!"
 }
 
## Check if the VM has snapshots
 if((Get-Snapshot -VM $VMName).Name.Length -cgt "0") 
 {
 Cls
 Write-Host "The script is completed due to the presence of snapshots of this VM ($VMName)! Please start the script after removing all snapshots for this VM ($VMName)!"
 pause
 Cls
 exit
 }
 else
 { 
 Write-Host "Snapshots of this VM ($VMName) do not exist!" 
 }
 
 ## Get the variable values for paths to the VM 
 $DatastoreBrowserPath = Get-Datastore | Select-Object DatastoreBrowserPath 
 $VMDatastoreId = (Get-VM -Name $VMName).DatastoreIdList 
 $VMDatastoreName = (Get-Datastore -id $VMDatastoreId).Name
 $VMDatastoreBrowserPath = (Get-Datastore -id $VMDatastoreId).DatastoreBrowserPath
 
## Derive the values for the paths variable to the VM directories
 $VMSourceFolder = $VMDatastoreBrowserPath+"\"+ $VMName+"\"
 $VMDestinationFolder = $VMDatastoreBrowserPath+ "\"+ $VMNewName+"\"
 $TempPcFolder = $env:TEMP+"\"+$VMNewName+"\"
 $ListOfSourceFolder=(Get-ChildItem -Recurse -Filter '*.vmx*' -Exclude '*.vmdk','*.vmsd' -Path $VMSourceFolder)
 
## Copy VM configuration files to the temp directory on PC to change the parameters
 ForEach ($_ in $ListOfSourceFolder)
 {
 Copy-DatastoreItem $_ -Recurse -Force -Confirm:$false -Verbose:$true -Destination ($TempPcFolder+$_.Name.Replace($VMName,$VMNewName))
 }
 
## Change the configuration settings 
 ForEach ($_ in (Get-ChildItem -Path $TempPcFolder*))
 {
 (Get-Content -Force -Path $_ -Raw) | %{($_).Replace($VMName,$VMNewName)} | Set-Content -Verbose:$true -Force $_ 
 }
 
## Copy the configuration files to the directory of the new VM to the host datastore
 $ListOfPcTempFolder=(Get-ChildItem -Recurse -Filter '*.vmx*' -Exclude '*.vmdk','*.vmsd' -Path $TempPcFolder)
 ForEach ($_ in $ListOfPcTempFolder)
 {
 Copy-DatastoreItem $_ -Recurse -Force -Confirm:$false -Verbose:$true -Destination $VMDestinationFolder
 }
 
## Delete the temp directory on the PC 
 Remove-Item -Recurse -Force -Confirm:$false -Verbose:$true $TempPcFolder
 
## Copy VM VMDK disks to the directory of another VM on the host datastore 
 $VMVMDKList=(Get-HardDisk -VM $VMName).Name 
 ForEach ($_ in $VMVMDKList)
 {
 $VMDK=(Get-HardDisk -vm $VMName -Name $_);
 Copy-HardDisk -Force -Confirm:$false -Verbose:$true -HardDisk ($VMDK) -DestinationPath (($VMDK).Filename.Replace($VMName,$VMNewName))
 }
 
## Copy the rest of the VM files to the host datastore 
 $ListOfAllSourceFolder=(Get-ChildItem -Recurse -Include '*.nvram','*.vmsd','*.log' -Path $VMSourceFolder)
 ForEach ($_ in $ListOfAllSourceFolder)
 {
 Copy-DatastoreItem $_ -Recurse -Force -Confirm:$false -Verbose:$true -Destination($VMDestinationFolder+$_.Name.Replace($VMName,$VMNewName))
 }
 
## Register the cloned VM in the ESXi inventory 
 New-VM -Confirm:$false -Verbose:$true -Name $VMNewName -VMHost $EsxiHostName -VMFilePath "[$VMDatastoreName] $VMNewName/$VMNewName.vmx"
 
## Start the clonedVM
 Start-VM -Verbose:$true -VM $VMNewName -ErrorAction SilentlyContinue 
 Get-VMQuestion -Verbose:$true -VM $VMNewName | Set-VMQuestion -DefaultOption -Confirm:$false
 
## Disconnect the ESXi Host
 Disconnect-VIServer -Verbose:$true -Confirm:$false -Server $EsxiHostName