function Add-ScheduledJobWithRemoveOfOldIfExists 
{
	
	Param
	(
		[Parameter(Position=0)]
		[string]$jobNameToAdd,
		[string]$scriptPath,
		[Microsoft.PowerShell.ScheduledJob.ScheduledJobTrigger]$jobTrigger
	)
	#Write-Host 	$jobNameToAdd
	try
	{
		$test=(Get-ScheduledJob -Name $jobNameToAdd -ErrorAction Stop -ErrorVariable ev)
		if ($test -ne $null)
			{ 
				Unregister-ScheduledJob -Name $jobNameToAdd
			}
	}
	catch
	{
		Write-Host ("Got an error : {0}" -f $ev.errorRecord.Exception.ToString())
	}

	$jobOption=New-ScheduledJobOption -StartIfOnBattery -RunElevated 

    Register-ScheduledJob -Name $jobNameToAdd -FilePath $scriptPath -Trigger $jobTrigger -ScheduledJobOption $jobOption

}



If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}


#   ---***^^^   Set up job   ^^^***---   #
$jobName='CheckAndRestartHomeSeer'
$numberOfMinutesBetweenChecking=5

$TriggerTime=(get-date)
#Some extra fiddling to get the job to start exactly every 5 mins (00,05,10,15 etc)
$minutesToAdd=(5- ((get-date).Minute%5))

$TriggerTime=$TriggerTime.AddMinutes($minutesToAdd).AddSeconds(-$TriggerTime.Second)

$Trigger = New-JobTrigger -RepetitionInterval (New-TimeSpan -Minutes $numberOfMinutesBetweenChecking) -RepetitionDuration ([timeSpan]::maxvalue) -At $TriggerTime -Once 

$scriptPath=(Join-Path  "C:\Program Files (x86)\HomeSeer HS3\PSScripts" "CheckIfHomeseerIsRunning.ps1")

Add-ScheduledJobWithRemoveOfOldIfExists -jobNameToAdd $jobName -scriptPath $scriptPath -jobTrigger $Trigger 


try
	{
		New-EventLog -LogName HomeseerRestart -Source HomeseerRestart -ErrorVariable ev -ErrorAction SilentlyContinue
		
	}
	catch
	{
		Write-Host ("Event registration error: {0}" -f $ev.errorRecord.Exception.ToString())
	}


Limit-EventLog -LogName HomeseerRestart -Maximumsize 4096KB -ErrorVariable ev -ErrorAction SilentlyContinue
