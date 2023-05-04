# Script to create a scheduled task that uploads a report of installed windows updates

#block to find unit serial number. it finds the elicense file, parses the xml and puts the unit serial value into a variable to pass into the file name later
if(Test-Path -path "C:\ProgramData\Revolution\AzureIot\Elicense.xml")
	{
	[xml]$ElicenseFile=Get-content -path "C:\ProgramData\Revolution\AzureIot\Elicense.xml"
	$UnitSerialNum=$ElicenseFile.PersistedData.s[2]
    }
else 
	{
	[xml]$ElicenseFile=Get-content -path "C:\Program Files\Axeda\Agent\Elicense.xml"
	$UnitSerialNum=$ElicenseFile.PersistedData.s[2]
    }

#begin log
Start-Transcript -path "C:\ProgramData\Revolution\AzureIoT\Upload-Reports\$($UnitSerialNum.Trim('"'))_reportTask.txt"

#Create new task action
$taskAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-ExecutionPolicy Bypass -File C:\Tools\getHotFix.ps1'

#Create user to run the task
$taskUser = "System"

#Create task trigger (Daily Reboot)
$taskTrigger = New-ScheduledTaskTrigger -Daily -At 1:00PM

# Task name 
$taskName = "ExportUpdateLog"

# Task description
$description = "Export a report of installed Windows Updates"

# check for previous task and register new task if necessary
$getTask = get-scheduledtask -TaskName ExportUpdateLog
if ($getTask)
	{
	Set-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -User $taskUser
	}
else
	{
	Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -User $taskUser -Description $description
	}
	
#output scheduled task
Get-ScheduledTaskInfo -TaskName ExportUpdateLog

#output log
Stop-Transcript