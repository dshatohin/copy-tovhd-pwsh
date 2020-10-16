param(
[Parameter(Mandatory=$false)]
[String]$DomainController = "dc01.domain.local",

[Parameter(Mandatory=$false)]
[String]$MountFolder = "C:\VHDmount",

[Parameter(Mandatory=$false)]
[String]$VHDFolder = "C:\VHDFolder",

[Parameter(Mandatory=$false)]
[String]$Filepath = ".\users.txt",

[Parameter(Mandatory=$false)]
[String]$DCAdminUser = "Administrator",

[Parameter(Mandatory=$false)]
[SecureString]$DCAdminPass
)

# Credentials
# $DCCreds = New-Object System.Management.Automation.PSCredential ($DCAdminUser, $DCAdminPass)

# Files and folders to exclude from copying
$ExcludeList = "Application Data", `
               "Cookies", `
               "Local Settings", `
               "My Documents", `
               "NetHood", `
               "PrintHood", `
               "Recent", `
               "SendTo", `
               "Start Menu", `
               "Templates", `
               "NTUSER*", `
               "главное меню", `
               "Мои документы", `
               "Шаблоны"

$Users = Get-Content -Path $Filepath
foreach ($User in $Users) {
    # Get SID
    $Target = Get-ADUser -Identity $User
    $VHDName = "UVHD-" + $target.SID

    # # Local testing
    # $Target = Get-LocalUser -Name $User
    # $VHDName = "UVHD-" + $target.SID.Value

    # Create mount-folder
    New-Item -Path $MountFolder -ItemType Directory

    # Mount VHD to temp folder
    $Mount = Mount-DiskImage -ImagePath "$VHDFolder\$VHDname.vhdx" -StorageType VHDX -Access ReadWrite
    Add-PartitionAccessPath -DiskNumber $Mount.Number -PartitionNumber 1 -AccessPath $MountFolder

    Copy-Item -Path "C:\Users\$User\*" -Destination "$MountFolder" -Exclude $ExcludeList -Recurse -Force -Verbose

    # Unmount VHD
    Remove-PartitionAccessPath -DiskNumber $Mount.Number -PartitionNumber 1 -AccessPath $MountFolder
    Dismount-DiskImage -ImagePath "$VHDFolder\$VHDname.vhdx"
    Remove-Item -Path $MountFolder -Recurse -Force
}
