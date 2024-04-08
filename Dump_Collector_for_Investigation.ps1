<#
.SYNOPSIS
This script collects various types of data for forensic investigation purposes.

.DESCRIPTION
The script collects different types of data relevant to forensic investigations, including file system metadata, registry hives, event logs, network traffic, memory dumps, and more. It organizes the collected data into a target directory and compresses it into a password-protected ZIP file for secure transfer to forensic specialists.

.AUTHOR
Author: Alex Alex
Date: 29.03.2024
Version: 1.0 Alfa

#>

# Define the target directory where collected data will be stored
$targetDirectory = "C:\ForensicData"

# Create the target directory if it doesn't exist
if (-not (Test-Path -Path $targetDirectory)) {
    New-Item -ItemType Directory -Path $targetDirectory | Out-Null
}

# Collect AppCompatCache files and copy them to the target directory
Copy-Item "C:\Windows\AppCompat\Programs\*.appcompat.txt" -Destination $targetDirectory -Force

# Collect data from the Master File Table ($MFT)
Invoke-Expression "ntfsinfo C: > $targetDirectory\MFT_Data.txt"

# Define the directory containing Jump List files
$jumpListDirectory = "$env:APPDATA\Microsoft\Windows\Recent"

# Copy Jump List files to the target directory
Copy-Item "$jumpListDirectory\*" -Destination $targetDirectory -Recurse -Force

# Collect file system metadata
Get-ChildItem -Path C:\ -Recurse | Export-Csv "$targetDirectory\FileSystemMetadata.csv" -Force -NoTypeInformation

# Collect registry hives
$registryHives = "HKLM", "HKCU"
foreach ($hive in $registryHives) {
    reg export $hive "$targetDirectory\$hive.reg" /y
}

# Collect event logs
Get-WinEvent -LogName * | Export-Csv "$targetDirectory\EventLogs.csv" -Force -NoTypeInformation

# Capture network traffic
# Replace the placeholder with the appropriate command to capture network traffic
# Example: tcpdump -i eth0 -w $targetDirectory\network_traffic.pcap
# Make sure to adjust the command based on your network interface and desired parameters

# Collect memory dump
# Replace the placeholder with the appropriate command to capture a memory dump
# Example: Invoke-Mimikatz -DumpCreds > $targetDirectory\memory_dump.txt
# Ensure you have necessary permissions and tools for memory dump acquisition

# Take system snapshot/image
# Replace the placeholder with the appropriate command to create a system snapshot/image
# Example: New-PSDrive -Name Image -PSProvider FileSystem -Root \\.\PhysicalDrive0 -Persist
#           Copy-Item -Path C:\ -Destination Image:\ -Recurse
# Ensure you have necessary permissions and tools for creating disk images

# Collect user activity logs
# Include commands to collect browser history, application usage logs, etc.
# Example: Copy-Item -Path $env:APPDATA\Microsoft\Internet Explorer\TypedUrls -Destination $targetDirectory -Force

# Collect deleted files
# Include commands to recover deleted files from disk or using forensic file carving techniques
# Example: Recuva.exe /debug /silent /scan $targetDirectory

# Collect system configuration
systeminfo > "$targetDirectory\SystemConfiguration.txt"

# Mobile device data collection (if applicable)
# Include commands to extract data from mobile devices connected to the system
# Example: adb pull /sdcard/DCIM $targetDirectory\MobileData

# Zip the collected data with password protection
$zipFilePath = "C:\ForensicData.zip"
$sourceDirectory = $targetDirectory

# Prompt user to enter password
$securePassword = Read-Host "Enter password" -AsSecureString

# Compress files into a zip archive with password protection
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory($sourceDirectory, $zipFilePath, "Optimal", $true)

# Encrypt the zip file with the provided password
$zipContent = Get-Content $zipFilePath
$zipContentBytes = [System.Text.Encoding]::UTF8.GetBytes($zipContent)
$encryptedBytes = [System.Security.Cryptography.ProtectedData]::Protect($zipContentBytes, $null, "CurrentUser")
[System.IO.File]::WriteAllBytes($zipFilePath, $encryptedBytes)

# Inform the user that the operation is complete
Write-Host "Data collection and compression completed successfully. The encrypted zip file is located at: $zipFilePath"
