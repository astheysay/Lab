md -Force c:\temp\
cp C:\windows\system32\winevt\Logs\System.evtx C:\temp\System.evtx
cp C:\windows\system32\winevt\Logs\Application.evtx C:\temp\Application.evtx
cp C:\windows\system32\winevt\Logs\SentinelOne%4Operational.evtx C:\temp\S1-Operational.evtx

Compress-Archive -Path C:\temp\System.evtx -Update -DestinationPath c:\temp\EventLogs.zip
Compress-Archive -Path C:\temp\Application.evtx -Update -DestinationPath c:\temp\EventLogs.zip
Compress-Archive -Path C:\temp\S1-Operational.evtx -Update -DestinationPath c:\temp\EventLogs.zip

rm c:\temp\Application.evtx -force
rm c:\temp\System.evtx -force
rm c:\temp\S1-Operational.evtx -force
