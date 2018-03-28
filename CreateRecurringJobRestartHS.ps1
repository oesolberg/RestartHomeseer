



function Add-ScheduledJobWithRemoveOfOldIfExists 
{
	
	Param
	(
		[Parameter(Position=0)]
		[string]$jobNameToAdd,
		[string]$scriptPath,
		[Microsoft.PowerShell.ScheduledJob.ScheduledJobTrigger]$jobTrigger#,
		#[System.Management.Automation.PSCredential]$mycreds,
		#[Parameter(Mandatory=$false)]
		#$argumentlist
	)
		
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

    if($argumentlist -ne $null)
    {
	    Register-ScheduledJob –Name $jobNameToAdd –FilePath $scriptPath -Credential $mycreds -Trigger $jobTrigger -ScheduledJobOption $jobOption -ArgumentList $argumentlist
    }
    else
    {
        Register-ScheduledJob –Name $jobNameToAdd –FilePath $scriptPath -Credential $mycreds -Trigger $jobTrigger -ScheduledJobOption $jobOption 
    }
}



If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}


#   ---***^^^   Set up SFTP job   ^^^***---   #
$jobName="CheckAndRestartHomeSeer"
$numberOfMinutesBetweenChecking=5

$SFtpTriggerTime=(get-date)
#Some extra fiddling to get the job to start exactly every 5 mins (00,05,10,15 etc)
$minutesToAdd=(5- ((get-date).Minute%5))

$SFtpTriggerTime=$SFtpTriggerTime.AddMinutes($minutesToAdd).AddSeconds(-$SFtpTriggerTime.Second)

$SFtpTrigger = New-JobTrigger -RepetitionInterval (New-TimeSpan -Minutes $numberOfMinutesBetweenChecking) -RepetitionDuration ([timeSpan]::maxvalue) -At $SFtpTriggerTime -Once 

#$argumentlist=$BasePath

$scriptPath=(Join-Path  "C:\Program Files (x86)\HomeSeer HS3\PSScripts" "CheckIfHomeseerIsRunning.ps1")

Add-ScheduledJobWithRemoveOfOldIfExists -jobNameToAdd $jobName -scriptPath $scriptPath -jobTrigger $SFtpTrigger #-mycreds $mycreds #-argumentlist $argumentlist


New-EventLog -LogName HomeseerRestart -Source HomeseerRestart -ErrorVariable ev -ErrorAction SilentlyContinue
if($ev -ne $null)
{
    Write-Host -ForegroundColor RED ($ev.Exception.ToString())
}

Limit-EventLog -LogName HomeseerRestart -Maximumsize 4096KB -ErrorVariable ev -ErrorAction SilentlyContinue
if($ev -ne $null)
{
    Write-Host -ForegroundColor RED ($ev.Exception.ToString())
}

