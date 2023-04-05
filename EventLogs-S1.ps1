$Source = "C:\windows\system32\winevt\Logs"
$Destination = "C:\temp"

md -Force c:\temp\
cp $Source\System.evtx $Destination\System.evtx
cp $Source\Application.evtx $Destination\Application.evtx
cp $Source\SentinelOne%4Operational.evtx $Destination\S1-Operational.evtx

Compress-Archive -Path $Destination\System.evtx -Update -DestinationPath $Destination\S1-EventLogs.zip
Compress-Archive -Path $Destination\Application.evtx -Update -DestinationPath $Destination\S1-EventLogs.zip
Compress-Archive -Path $Destination\S1-Operational.evtx -Update -DestinationPath $Destination\S1-EventLogs.zip

rm $Destination\Application.evtx -force
rm $Destination\System.evtx -force
rm $Destination\S1-Operational.evtx -force