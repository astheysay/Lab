#Run PS in x64 context on x64 platform
If ($ENV:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    Try {
        &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
    }
    Catch {
        Throw "Failed to start $PSCOMMANDPATH"
    }
    Exit
}



Function CleanUpAndExit() {
    Param(
        [Parameter(Mandatory=$True)][String]$ErrorLevel
    )

    # Write results to registry for Intune Detection
    $Key = "HKEY_LOCAL_MACHINE\Software\DeleteAppPrinters\"
    $NOW = Get-Date -Format "yyyyMMdd-hhmmss"

    If ($ErrorLevel -eq "0") {
        [microsoft.win32.registry]::SetValue($Key, "Success", $NOW)
    } else {
        [microsoft.win32.registry]::SetValue($Key, "Failure", $NOW)
        [microsoft.win32.registry]::SetValue($Key, "Error Code", $Errorlevel)
    }
    
    # Exit Script with the specified ErrorLevel
    EXIT $ErrorLevel
}


# Delete application printers
$Error.Clear()
Get-WmiObject -Class Win32_Printer | where{$_.name -like "OneNote (Desktop)"}| foreach{$_.delete()}
Get-WmiObject -Class Win32_Printer | where{$_.name -like "OneNote for Windows 10"}| foreach{$_.delete()}
Get-WmiObject -Class Win32_Printer | where{$_.name -like "Fax"}| foreach{$_.delete()}
Get-WmiObject -Class Win32_Printer | where{$_.name -like "Microsoft Print to PDF"}| foreach{$_.delete()}
Get-WmiObject -Class Win32_Printer | where{$_.name -like "Microsoft XPS Document Writer"}| foreach{$_.delete()}
If ($Error.Count -gt 0) {

    CleanUpAndExit -ErrorLevel 101
} else {

}

CleanUpAndExit -ErrorLevel 0