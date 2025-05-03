#https://www.reddit.com/r/sysadmin/comments/ylgedc/comment/ivfnune/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
#Must update URL in line 38 at a minimum
$installationScript = $MyInvocation.InvocationName 

Clear-Host $registeredOwner = ""
New-Item -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "RegisteredOwner" -Force 
New-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name RegisteredOwner -Value "$registeredOwner" -PropertyType STRING -Force
New-Item -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "RegisteredOrganization" -Force 
New-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name RegisteredOrganization -Value "$registeredOwner" -PropertyType STRING -Force

function Remove-installationFiles { 
    $upgradeFileCheck = Test-Path -Path $PSScriptRoot$upgradefile 
    $upgradeDirectoryCheck = Test-Path -Path $PSScriptRoot$upgradeDirectory
    Remove-Item $installationScript
    Write-Host "Upgrade script has been removed." -ForegroundColor Green
    
    if ($upgradeFileCheck){
    Remove-Item $upgradeFile
    }
    if ($upgradeDirectoryCheck) {
    Remove-Item $upgradeDirectory -Recurse -Force
    }
    Remove-Item (Get-PSReadlineOption).HistorySavePath
    Set-ExecutionPolicy Restricted
}
$upgradeFile = "Windows10_22H2.zip" 
$upgradeDirectory = $upgradefile -replace ".{4}$"
$currentBuildVer = "19045"
$versionNameArray = ( ("17134","1803"), ("17763","1809"), ("18362","19H1"), ("18363","19H2"), ("19041","20H1"), ("19042","20H2"), ("19043","21H1"), ("19044","21H2"), ("19045","22H2"), ("22000","22H1") );

Write-Host Checking Current Build Number $currentVersionInfo = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' $installedBuildVer = $currentVersionInfo.CurrentBuildNumber $windowsProductNameLTSB = $currentVersionInfo.ProductName -match 'LTSB'

If ($windowsProductNameLTSB -eq $true) { Write-Host "This is an LTSB build just run updates" Remove-installationFiles Exit }
forEach ($version in $versionNameArray) { if ($version[0] -eq $installedBuildVer) { Write-Host "The current build is: " -ForegroundColor Green -NoNewline; Write-Host "$installedBuildVer " -ForegroundColor Yellow -NoNewline; Write-Host "(" -NoNewline; Write-Host $version[1] -NoNewline; Write-Host ")" } }

if ($installedBuildVer -gt $currentBuildVer) { Write-Host Windows 11 Remove-installationFiles Exit
} elseif ($installedBuildVer -lt $currentBuildVer) { Write-Host Downloading Image Write-Host Download started time (Get-Date).ToString("HHmm") -ForegroundColor Green
Invoke-WebRequest -Uri https://sub.domain.tld/path/to/$upgradeFile -Outfile "$PSScriptRoot\$upgradeFile"

Write-Host Download finished at (Get-Date).ToString("HHmm") -ForegroundColor Green

Write-Host Decompressing feature update
$zipPath = $PSScriptRoot
New-Item -Path $zipPath -Name $upgradeDirectory -ItemType "directory" | Out-Null
$featureZip = $PSScriptRoot + "\" + $upgradeFile
$featureExpandedDir = $PSScriptRoot + "\" + $upgradeDirectory
Expand-Archive -Path  $featureZip $featureExpandedDir | Out-Null
Write-Host Decompression Complete

Write-Host Running Upgrade.
Write-Host This will take a while.
Write-Host ...
Write-Host Do not close this Window
Write-Host ...
Write-Host The computer will reboot when done.
Write-Host "The upgrade process started at " -ForegroundColor White -NoNewline; Write-Host (Get-Date).ToString("yyyy.MM.dd") -ForegroundColor Green -NoNewline; Write-Host " :: " -ForegroundColor Yellow -NoNewline; Write-Host (Get-Date).ToString("HHmm") -ForegroundColor Green

$upgradeInstallLocation = "$PSScriptRoot\$upgradeDirectory\setup.exe"
Start-Process -FilePath $upgradeInstallLocation -ArgumentList '/Auto Upgrade /Quiet /MigrateDrivers all /DynamicUpdate Disable /Telemetry disable /compat IgnoreWarning /ShowOOBE none /NoReboot' -Wait

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" -Name “PreventDeviceMetadataFromNetwork” -Value 1

New-Item -Path HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows -Name "Windows Feeds" -Force
New-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name EnableFeeds -Value 0 -PropertyType DWORD -Force

Write-Host Removing update files
Remove-Item $featureZip
Remove-Item $featureExpandedDir -Recurse
    
Remove-Item $MyInvocation.InvocationName
Write-Host "Upgrade file has been removed." -ForegroundColor Green

Set-ExecutionPolicy Restricted -Force

Restart-Computer -Force
} else { Write-Host Build is current :: Run updates
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" -Name “PreventDeviceMetadataFromNetwork” -Value 1

New-Item -Path HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows -Name "Windows Feeds" -Force
New-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name EnableFeeds -Value 0 -PropertyType DWORD -Force

Remove-installationFiles

Set-ExecutionPolicy Restricted -Force
}