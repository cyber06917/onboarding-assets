# Run this without any administrator permissions

# Get Computer System Info
$compSys = Get-CimInstance Win32_ComputerSystem
$bios = Get-CimInstance Win32_BIOS
$cpu = Get-CimInstance Win32_Processor

# Initialize variables
$monitors = @()

# Safely get physical drives
try {
    $drives = Get-PhysicalDisk
} catch {
    $drives = @()
}

# Try to get monitor info
try {
    $monitors = @(
    Get-WmiObject WmiMonitorID -Namespace root\wmi | ForEach-Object {
        [PSCustomObject]@{
            Manufacturer = ($_.ManufacturerName | Where-Object { $_ -ne 0 } | ForEach-Object { [char]$_ }) -join ''
            Model        = ($_.UserFriendlyName  | Where-Object { $_ -ne 0 } | ForEach-Object { [char]$_ }) -join ''
            SerialNumber = ($_.SerialNumberID   | Where-Object { $_ -ne 0 } | ForEach-Object { [char]$_ }) -join ''
            }
        }
    )
} catch {
    $monitors = @()
}

# Ensure at least 2 monitor entries, pad with "Nil"
while ($monitors.Count -lt 2) {
    $monitors += [PSCustomObject]@{
        Manufacturer = 'Nil'
        Model        = 'Nil'
        SerialNumber = 'Nil'
    }
}

# Convert monitor info to strings
$monitorInfoStrings = $monitors | ForEach-Object {
    "Manufacturer: $($_.Manufacturer), Model: $($_.Model), Serial: $($_.SerialNumber)"
}


# A PSCustomObject lets you create an object with named properties, 
# which is more structured and readable, especially for complex data.
# Prepare system info
$sysInfo = [PSCustomObject]@{
    Hostname     = $compSys.Name
    Manufacturer = $compSys.Manufacturer
    Username     = $env:USERNAME
    Model        = $compSys.Model
    RAM          = "$([math]::Round($compSys.TotalPhysicalMemory / 1GB, 2)) GB"
    SerialNumber = $bios.SerialNumber
    Processor    = $cpu.Name
    DrivesInfo   = ($drives | ForEach-Object {
        "$($_.MediaType) - $([math]::Round($_.Size / 1GB, 2)) GB"
    }) -join "`n"
}

# Add Monitor1 and Monitor2 properties
for ($i = 0; $i -lt 2; $i++) {
    $monitorProp = "Monitor$($i + 1)"
    $sysInfo | Add-Member -MemberType NoteProperty -Name $monitorProp -Value $monitorInfoStrings[$i]
}

# Output full system info
# Replace with your actual path in private use
$csvPath = "\\ip\Test\hostinfo.csv"
$hostname = $env:COMPUTERNAME
$shouldAppend = $true

# Check if file exists and if hostname already exists
if (Test-Path $csvPath) {
    try {
        $existingData = Import-Csv $csvPath
        if ($existingData | Where-Object { $_.Hostname -eq $hostname }) {
            Write-Host "Hostname '$hostname' already exists in CSV. Skipping append."
            $shouldAppend = $false
        }
    } catch {
        Write-Warning "Failed to read existing CSV: $_"
    }
}

# Append only if hostname not found
if ($shouldAppend) {
    try {
        $sysInfo | Export-Csv -Path $csvPath -Append -NoTypeInformation
        Write-Host "Appended system info for hostname '$hostname' to CSV."
    } catch {
        Write-Error "Failed to export CSV: $_"
    }
}