
$programName = "HS3"
$isRunning = (Get-Process | Where-Object { $_.Name -eq $programName }).Count -gt 0

if ($isRunning -eq $false){
    Start-Process "C:\Program Files (x86)\HomeSeer HS3\HS3.exe"
    Write-EventLog -LogName "HomeseerRestart" -Source "HomeseerRestart" -Message "Restarted Homeseer since it was not found" -EventId 9 -EntryType Error
}
