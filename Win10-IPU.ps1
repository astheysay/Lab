# Downloads Windows 10 ISO from Microsoft using FIDO script, then initiates in-place upgrade
if((Get-Volume -DriveLetter C | Select -ExpandProperty SizeRemaining) -gt 10737418240) { 

write-host "Free space sufficient. Downloading Windows 10 image to begin the upgrade." -ForegroundColor Green; $path = "c:\temp"
if (!(Test-Path $path)) { md -Force $path }

# Download ISO
$ProgressPreference = 'silentlyContinue'
$URL = & $([scriptblock]::Create((New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/pbatard/Fido/master/Fido.ps1"))) -param1 -Win 10 -Rel Latest -Ed Pro -Lang English -GetURL
Invoke-WebRequest -Uri $URL -OutFile "c:\temp\Windows10_x64.iso"
$ProgressPreference = 'Continue'

# Mount ISO
Mount-DiskImage -ImagePath "C:\temp\Windows10_x64.iso"
$DriveLetter = Get-DiskImage "C:\temp\Windows10_x64.iso" | Get-Volume | Select -ExpandProperty DriveLetter

# Run in-place upgrade (add /NoReboot at end if you do not want an automatic reboot)
&"${DriveLetter}:\setup.exe" /auto upgrade /migratedrivers all /ShowOOBE none /Compat IgnoreWarning /dynamicupdate Disable /Telemetry Disable
} 

else { 
write-host "Error: Stopping script. Not enough free space on C:\" -ForegroundColor Red
}
