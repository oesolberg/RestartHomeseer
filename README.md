# RestartHomeseer
Powershell script for restarting the homeseer 3 

Must be run as administrator

Not sure what version of powershell you need to have to run it. 

If you have HS3.exe installed somewhere else than "C:\Program Files (x86)\HomeSeer HS3\" then you need to edit CheckIfHomeseerIsRunning.ps1 and insert the right path and directory in -FilePath and -WorkingDirectory  

I have the scripts in folder C:\Program Files (x86)\HomeSeer HS3\PSScripts\. If you have placed them anywhere else please change that in the file CreateRecurringJobRestartHS.ps1

in the  line

$scriptPath=(Join-Path "C:\Program Files (x86)\HomeSeer HS3\PSScripts" "CheckIfHomeseerIsRunning.ps1")
