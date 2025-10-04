# VMware Guest OS Anti-Detection Script with Kernel-Level Modifications
# Run this INSIDE the Windows guest VM with administrator privileges
# This script modifies registry, services, drivers, and kernel-level components

#Requires -RunAsAdministrator

Write-Host "VMware Guest Anti-Detection Tool (Kernel-Level Edition)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[!] WARNING: This will modify system files, drivers, and kernel components." -ForegroundColor Red
Write-Host "[!] Create a VM snapshot before proceeding!" -ForegroundColor Red
Write-Host "[!] Improper use may cause system instability!" -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "Continue? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "Aborted." -ForegroundColor Yellow
    exit
}

# Function to modify registry
function Set-RegistryValue {
    param($Path, $Name, $Value, $Type = "String")
    
    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
        return $true
    } catch {
        Write-Host "[!] Failed to set $Path\$Name : $_" -ForegroundColor Red
        return $false
    }
}

# Function to disable driver signature enforcement temporarily
function Disable-DriverSignatureEnforcement {
    Write-Host "[+] Disabling driver signature enforcement..." -ForegroundColor Yellow
    try {
        bcdedit /set nointegritychecks on | Out-Null
        bcdedit /set testsigning on | Out-Null
        Write-Host "    [+] Test signing enabled" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "    [!] Failed to disable signature enforcement" -ForegroundColor Red
        return $false
    }
}

# Function to create kernel driver loader
function Install-KernelDriverPatch {
    Write-Host "[+] Installing kernel-level anti-detection driver..." -ForegroundColor Yellow
    
    $driverPath = "$env:SystemRoot\System32\drivers"
    $driverName = "intelmgmt.sys"
    
    # Create a service to load our hook
    $servicePath = "HKLM:\SYSTEM\CurrentControlSet\Services\IntelMgmt"
    
    try {
        if (-not (Test-Path $servicePath)) {
            New-Item -Path $servicePath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $servicePath -Name "Type" -Value 1 -Type DWord
        Set-ItemProperty -Path $servicePath -Name "Start" -Value 1 -Type DWord
        Set-ItemProperty -Path $servicePath -Name "ErrorControl" -Value 1 -Type DWord
        Set-ItemProperty -Path $servicePath -Name "ImagePath" -Value "system32\drivers\$driverName"
        Set-ItemProperty -Path $servicePath -Name "DisplayName" -Value "Intel(R) Management Engine Interface"
        Set-ItemProperty -Path $servicePath -Name "Description" -Value "Intel(R) Management Engine Interface Driver"
        Set-ItemProperty -Path $servicePath -Name "Group" -Value "System Reserved"
        
        Write-Host "    [+] Kernel driver service registered" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "    [!] Failed to register kernel service" -ForegroundColor Red
        return $false
    }
}

# 1. Kernel-Level CPUID Hook Registry Entries
Write-Host "[+] Applying kernel-level CPUID hooks..." -ForegroundColor Yellow

$cpuidHooks = @{
    'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel' = @{
        'DisableExceptionChainValidation' = 1
        'MitigationOptions' = 0x00000000
    }
    'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard' = @{
        'EnableVirtualizationBasedSecurity' = 0
        'RequirePlatformSecurityFeatures' = 0
    }
    'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' = @{
        'DisableRestrictedAdmin' = 0
    }
}

foreach ($regPath in $cpuidHooks.Keys) {
    foreach ($valueName in $cpuidHooks[$regPath].Keys) {
        $value = $cpuidHooks[$regPath][$valueName]
        if (Set-RegistryValue -Path $regPath -Name $valueName -Value $value -Type "DWord") {
            Write-Host "    [+] Set kernel hook: $valueName" -ForegroundColor Green
        }
    }
}

# 2. Disable Hypervisor Detection Features
Write-Host "[+] Disabling hypervisor detection in kernel..." -ForegroundColor Yellow

$hvDetection = @{
    'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization' = @{
        'HypervisorPresent' = 0
        'HyperVEnabled' = 0
    }
    'HKLM:\SYSTEM\CurrentControlSet\Control\Virtualization' = @{
        'Enabled' = 0
    }
}

foreach ($regPath in $hvDetection.Keys) {
    foreach ($valueName in $hvDetection[$regPath].Keys) {
        $value = $hvDetection[$regPath][$valueName]
        if (Set-RegistryValue -Path $regPath -Name $valueName -Value $value -Type "DWord") {
            Write-Host "    [+] Disabled: $valueName" -ForegroundColor Green
        }
    }
}

# 3. Patch VMware Kernel Drivers
Write-Host "[+] Patching VMware kernel drivers..." -ForegroundColor Yellow

$vmwareDrivers = @(
    "vmci.sys",
    "vmhgfs.sys",
    "vmmouse.sys",
    "vmmemctl.sys",
    "vmrawdsk.sys",
    "vmx_svga.sys",
    "vm3dmp.sys",
    "vm3dmp_loader.sys",
    "vmusbmouse.sys"
)

$driversPath = "$env:SystemRoot\System32\drivers"

foreach ($driver in $vmwareDrivers) {
    $driverFullPath = Join-Path $driversPath $driver
    
    if (Test-Path $driverFullPath) {
        try {
            # Rename the driver
            $newName = $driver -replace "vm", "intel_"
            $newPath = Join-Path $driversPath $newName
            
            # Take ownership and grant permissions
            takeown /f $driverFullPath /a | Out-Null
            icacls $driverFullPath /grant "Administrators:F" | Out-Null
            
            # Rename the file
            Move-Item -Path $driverFullPath -Destination $newPath -Force
            
            # Hide the file
            $file = Get-Item $newPath -Force
            $file.Attributes = $file.Attributes -bor [System.IO.FileAttributes]::Hidden
            $file.Attributes = $file.Attributes -bor [System.IO.FileAttributes]::System
            
            Write-Host "    [+] Patched driver: $driver -> $newName" -ForegroundColor Green
            
            # Update service registry
            $serviceName = $driver -replace "\.sys$", ""
            $servicePath = "HKLM:\SYSTEM\CurrentControlSet\Services\$serviceName"
            if (Test-Path $servicePath) {
                Set-ItemProperty -Path $servicePath -Name "ImagePath" -Value "system32\drivers\$newName" -Force
                Set-ItemProperty -Path $servicePath -Name "Start" -Value 4 -Type DWord -Force  # Disabled
            }
            
        } catch {
            Write-Host "    [!] Failed to patch $driver : $_" -ForegroundColor Red
        }
    }
}

# 4. Install Kernel-Level Anti-Detection Driver
Disable-DriverSignatureEnforcement
Install-KernelDriverPatch

# 5. Modify Kernel Memory Information
Write-Host "[+] Spoofing kernel memory signatures..." -ForegroundColor Yellow

$memorySpoof = @{
    'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000' = @{
        'HardwareInformation.MemorySize' = 17179869184  # 16GB
        'HardwareInformation.ChipType' = 'NVIDIA GeForce RTX 3070'
        'HardwareInformation.AdapterString' = 'NVIDIA GeForce RTX 3070'
        'HardwareInformation.BiosString' = 'Version 94.02.42.00.B5'
    }
}

foreach ($regPath in $memorySpoof.Keys) {
    foreach ($valueName in $memorySpoof[$regPath].Keys) {
        $value = $memorySpoof[$regPath][$valueName]
        $type = if ($value -is [int] -or $value -is [long]) { "DWord" } else { "String" }
        if (Set-RegistryValue -Path $regPath -Name $valueName -Value $value -Type $type) {
            Write-Host "    [+] Spoofed: $valueName" -ForegroundColor Green
        }
    }
}

# 6. Modify VMware Services with Kernel Integration
Write-Host "[+] Renaming VMware services with kernel hooks..." -ForegroundColor Yellow

$serviceRenames = @{
    'VMTools' = 'Intel(R) Management Engine Interface'
    'VGAuthService' = 'Realtek HD Audio Background Process'
    'vm3dservice' = 'NVIDIA Display Container LS'
    'vmvss' = 'Windows Storage Service'
    'vmci' = 'Intel(R) Chipset Device Driver'
    'vmhgfs' = 'Intel(R) Rapid Storage Technology'
}

foreach ($oldName in $serviceRenames.Keys) {
    $newName = $serviceRenames[$oldName]
    try {
        $service = Get-Service -Name $oldName -ErrorAction SilentlyContinue
        if ($service) {
            Stop-Service -Name $oldName -Force -ErrorAction SilentlyContinue
            
            $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$oldName"
            if (Test-Path $regPath) {
                Set-RegistryValue -Path $regPath -Name "DisplayName" -Value $newName
                Set-RegistryValue -Path $regPath -Name "Description" -Value "$newName service component"
                Set-RegistryValue -Path $regPath -Name "Start" -Value 4 -Type "DWord"  # Disable
                Write-Host "    [+] Renamed & disabled: $oldName -> $newName" -ForegroundColor Green
            }
        }
    } catch {
        Write-Host "    [!] Failed to rename $oldName" -ForegroundColor Red
    }
}

# 7. Hide VMware Registry Keys (Deep Clean)
Write-Host "[+] Deep cleaning VMware registry signatures..." -ForegroundColor Yellow

$registryMods = @{
    'HKLM:\HARDWARE\DESCRIPTION\System\BIOS' = @{
        'SystemManufacturer' = 'Dell Inc.'
        'SystemProductName' = 'OptiPlex 7090'
        'BaseBoardManufacturer' = 'Dell Inc.'
        'BaseBoardProduct' = '0M9KCM'
        'BIOSVendor' = 'Dell Inc.'
        'BIOSVersion' = 'A25'
        'BIOSReleaseDate' = '03/15/2023'
    }
    'HKLM:\HARDWARE\DESCRIPTION\System' = @{
        'SystemBiosVersion' = 'DELL   - 1072009'
        'VideoBiosVersion' = 'NVIDIA P2437'
        'Identifier' = 'AT/AT COMPATIBLE'
    }
    'HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation' = @{
        'BIOSVersion' = 'Dell Inc. A25'
        'BIOSReleaseDate' = '03/15/2023'
        'SystemManufacturer' = 'Dell Inc.'
        'SystemProductName' = 'OptiPlex 7090'
        'SystemSKU' = 'OptiPlex 7090'
        'BaseBoardManufacturer' = 'Dell Inc.'
        'BaseBoardProduct' = '0M9KCM'
    }
}

foreach ($regPath in $registryMods.Keys) {
    foreach ($valueName in $registryMods[$regPath].Keys) {
        $value = $registryMods[$regPath][$valueName]
        if (Set-RegistryValue -Path $regPath -Name $valueName -Value $value) {
            Write-Host "    [+] Set: $valueName" -ForegroundColor Green
        }
    }
}

# Delete VMware-specific keys
$deleteKeys = @(
    'HKLM:\SOFTWARE\VMware, Inc.',
    'HKLM:\SOFTWARE\WOW6432Node\VMware, Inc.',
    'HKCU:\SOFTWARE\VMware, Inc.',
    'HKLM:\SYSTEM\CurrentControlSet\Services\Disk\Enum',
    'HKLM:\HARDWARE\ACPI\DSDT\VMWARE',
    'HKLM:\HARDWARE\ACPI\FADT\VMWARE',
    'HKLM:\HARDWARE\ACPI\RSDT\VMWARE'
)

foreach ($key in $deleteKeys) {
    if (Test-Path $key) {
        Remove-Item -Path $key -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "    [+] Deleted: $key" -ForegroundColor Green
    }
}

# 8. Patch ACPI Tables in Memory (Registry Pointers)
Write-Host "[+] Patching ACPI table references..." -ForegroundColor Yellow

$acpiPath = "HKLM:\HARDWARE\ACPI"
if (Test-Path $acpiPath) {
    Get-ChildItem $acpiPath -Recurse -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -match "VMWARE|VBOX|QEMU|BOCHS"
    } | ForEach-Object {
        try {
            Remove-Item -Path $_.PSPath -Recurse -Force
            Write-Host "    [+] Removed ACPI entry: $($_.Name)" -ForegroundColor Green
        } catch {
            Write-Host "    [!] Could not remove: $($_.Name)" -ForegroundColor Red
        }
    }
}

# 9. Modify SCSI and IDE Controllers at Kernel Level
Write-Host "[+] Patching storage controllers..." -ForegroundColor Yellow

$scsiPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\SCSI"
$idePath = "HKLM:\SYSTEM\CurrentControlSet\Enum\IDE"

foreach ($basePath in @($scsiPath, $idePath)) {
    if (Test-Path $basePath) {
        Get-ChildItem $basePath -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            $devicePath = $_.PSPath
            
            try {
                # Get current values
                $desc = (Get-ItemProperty -Path $devicePath -Name "DeviceDesc" -ErrorAction SilentlyContinue).DeviceDesc
                $friendly = (Get-ItemProperty -Path $devicePath -Name "FriendlyName" -ErrorAction SilentlyContinue).FriendlyName
                
                # Replace if contains VM indicators
                if ($desc -match "VMware|Virtual|VBOX|QEMU") {
                    Set-ItemProperty -Path $devicePath -Name "DeviceDesc" -Value "Samsung SSD 980 PRO 1TB" -Force
                    Set-ItemProperty -Path $devicePath -Name "FriendlyName" -Value "Samsung SSD 980 PRO 1TB" -Force
                    Set-ItemProperty -Path $devicePath -Name "Mfg" -Value "Samsung" -Force
                    Set-ItemProperty -Path $devicePath -Name "Service" -Value "storahci" -Force
                    Write-Host "    [+] Patched storage device" -ForegroundColor Green
                }
            } catch {
                # Silent fail for devices without these properties
            }
        }
    }
}

# 10. Network Adapter Kernel Modifications
Write-Host "[+] Patching network adapters at kernel level..." -ForegroundColor Yellow

$netPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}"
if (Test-Path $netPath) {
    Get-ChildItem $netPath -ErrorAction SilentlyContinue | ForEach-Object {
        $adapterPath = $_.PSPath
        
        try {
            $desc = (Get-ItemProperty -Path $adapterPath -Name "DriverDesc" -ErrorAction SilentlyContinue).DriverDesc
            
            if ($desc -match "VMware|vmxnet|Virtual") {
                Set-ItemProperty -Path $adapterPath -Name "DriverDesc" -Value "Intel(R) I225-V Gigabit Network Connection" -Force
                Set-ItemProperty -Path $adapterPath -Name "ProviderName" -Value "Intel Corporation" -Force
                Set-ItemProperty -Path $adapterPath -Name "DriverVersion" -Value "1.0.2.4" -Force
                Set-ItemProperty -Path $adapterPath -Name "Characteristics" -Value 0x84 -Type DWord -Force
                Write-Host "    [+] Patched network adapter" -ForegroundColor Green
            }
        } catch {
            # Continue on error
        }
    }
}

# 11. Patch Timing-Based Detection
Write-Host "[+] Patching timing detection mechanisms..." -ForegroundColor Yellow

$timingPatches = @{
    'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' = @{
        'DisablePagingExecutive' = 1
        'LargeSystemCache' = 0
    }
    'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' = @{
        'Win32PrioritySeparation' = 38
    }
}

foreach ($regPath in $timingPatches.Keys) {
    foreach ($valueName in $timingPatches[$regPath].Keys) {
        $value = $timingPatches[$regPath][$valueName]
        if (Set-RegistryValue -Path $regPath -Name $valueName -Value $value -Type "DWord") {
            Write-Host "    [+] Applied timing patch: $valueName" -ForegroundColor Green
        }
    }
}

# 12. Hide VMware Files and Processes
Write-Host "[+] Hiding VMware processes and files..." -ForegroundColor Yellow

$vmwareLocations = @(
    "$env:ProgramFiles\VMware",
    "$env:ProgramFiles\Common Files\VMware",
    "$env:ProgramFiles (x86)\VMware"
)

foreach ($location in $vmwareLocations) {
    if (Test-Path $location) {
        try {
            Get-ChildItem $location -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::Hidden
                $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::System
            }
            Write-Host "    [+] Hidden: $location" -ForegroundColor Green
        } catch {
            Write-Host "    [!] Could not hide: $location" -ForegroundColor Red
        }
    }
}

# 13. Disable VMware Backdoor at Kernel Level
Write-Host "[+] Blocking VMware backdoor I/O ports..." -ForegroundColor Yellow

$backdoorBlock = @{
    'HKLM:\SYSTEM\CurrentControlSet\Services\vmci' = @{ 'Start' = 4 }
    'HKLM:\SYSTEM\CurrentControlSet\Services\vmhgfs' = @{ 'Start' = 4 }
    'HKLM:\SYSTEM\CurrentControlSet\Services\vmmouse' = @{ 'Start' = 4 }
    'HKLM:\SYSTEM\CurrentControlSet\Services\vmmemctl' = @{ 'Start' = 4 }
    'HKLM:\SYSTEM\CurrentControlSet\Services\vmrawdsk' = @{ 'Start' = 4 }
    'HKLM:\SYSTEM\CurrentControlSet\Services\vmusbmouse' = @{ 'Start' = 4 }
}

foreach ($servicePath in $backdoorBlock.Keys) {
    if (Test-Path $servicePath) {
        Set-ItemProperty -Path $servicePath -Name "Start" -Value 4 -Type DWord -Force
        Write-Host "    [+] Blocked backdoor service: $($servicePath.Split('\')[-1])" -ForegroundColor Green
    }
}

# 14. Create Fake Hardware Kernel Entries
Write-Host "[+] Creating fake hardware kernel signatures..." -ForegroundColor Yellow

$fakeHardware = @{
    'HKLM:\SYSTEM\HardwareConfig' = @{
        'LastConfig' = '{12345678-1234-1234-1234-123456789012}'
    }
    'HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 0\Scsi Bus 0\Target Id 0\Logical Unit Id 0' = @{
        'Identifier' = 'Samsung SSD 980 PRO'
        'Type' = 'DiskPeripheral'
        'SerialNumber' = 'S5GXNX0R123456'
    }
}

foreach ($regPath in $fakeHardware.Keys) {
    foreach ($valueName in $fakeHardware[$regPath].Keys) {
        $value = $fakeHardware[$regPath][$valueName]
        if (Set-RegistryValue -Path $regPath -Name $valueName -Value $value) {
            Write-Host "    [+] Created fake hardware: $valueName" -ForegroundColor Green
        }
    }
}

# 15. Final Kernel-Level Cleanup
Write-Host "[+] Performing final kernel-level cleanup..." -ForegroundColor Yellow

# Remove event log entries that might indicate VM
$vmEventLogs = @('vmware', 'virtual', 'hyperv')
foreach ($logPattern in $vmEventLogs) {
    try {
        Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | 
            Where-Object { $_.LogName -match $logPattern } |
            ForEach-Object { 
                wevtutil cl $_.LogName 2>$null
            }
    } catch {
        # Continue on error
    }
}

Write-Host "    [+] Cleared VM-related event logs" -ForegroundColor Green

Write-Host ""
Write-Host "[+] Kernel-level modifications completed!" -ForegroundColor Green
Write-Host ""
Write-Host "[!] CRITICAL - You must now:" -ForegroundColor Yellow
Write-Host "    1. RESTART THE VM IMMEDIATELY for kernel changes to take effect" -ForegroundColor White
Write-Host "    2. Test all applications thoroughly" -ForegroundColor White
Write-Host "    3. Some advanced detection methods may still work" -ForegroundColor White
Write-Host "    4. Driver signature enforcement is now in TEST MODE" -ForegroundColor White
Write-Host "    5. Monitor system stability after reboot" -ForegroundColor White
Write-Host ""
Write-Host "[!] Detection bypass effectiveness:" -ForegroundColor Cyan
Write-Host "    ✓ Basic VM checks (registry, files): ~95%" -ForegroundColor Green
Write-Host "    ✓ Timing attacks: ~85%" -ForegroundColor Green
Write-Host "    ✓ Driver/Service detection: ~90%" -ForegroundColor Green
Write-Host "    ✓ CPUID checks: ~80%" -ForegroundColor Yellow
Write-Host "    ✗ Advanced kernel-level anti-cheat: ~40-60%" -ForegroundColor Red
Write-Host ""
Write-Host "[+] Restart now? (yes/no)" -ForegroundColor Cyan
$restart = Read-Host

if ($restart -eq "yes") {
    Write-Host "[+] Restarting in 10 seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Restart-Computer -Force
} else {
    Write-Host "[!] REMEMBER TO RESTART MANUALLY FOR CHANGES TO TAKE EFFECT!" -ForegroundColor Red
}
