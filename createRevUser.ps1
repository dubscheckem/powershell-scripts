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
	
<#
.SYNOPSIS
  Create local admin acc
.DESCRIPTION
  Creates a local administrator account on target computer. Requires RunAs permissions to run
.OUTPUTS
  none
.NOTES
  Version:        1.0
  Author:         Daniel Sorrells
  Creation Date:  2022.11.11
  Purpose/Change: Initial script development
#>
# Configuration
$username = "RevUser"   #change this value for desired account name
$password = ConvertTo-SecureString "t!d3Le" -AsPlainText -Force  #change this value for desired password. (not secure if someone can see the script)
$logFile = ".\createLocalAdminLog.txt"
Function Write-Log {
  param(
      [Parameter(Mandatory = $true)][string] $message,
      [Parameter(Mandatory = $false)]
      [ValidateSet("INFO","WARN","ERROR")]
      [string] $level = "INFO"
  )
  # Create timestamp
  $timestamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
  # Append content to log file
  Add-Content -Path $logFile -Value "$timestamp [$level] - $message"
}
Function Create-LocalAdmin {
    process {
      try {
		#creates new local user account
        New-LocalUser "$username" -Password $password -FullName "$username" -Description "local admin" -ErrorAction stop
        Write-Log -message "$username local user crated"
        # Add new user to administrator group
        Add-LocalGroupMember -Group "Administrators" -Member "$username" -ErrorAction stop
        Write-Log -message "$username added to the local administrator group"
      }catch{
        Write-log -message "Creating local account failed" -level "ERROR"
      }
    }    
}
Write-Log -message "#########"
Write-Log -message "$env:COMPUTERNAME - Create local admin account"
Create-LocalAdmin
#create one time task for revuser to run
#Create new task action
$taskAction = New-ScheduledTaskAction -Execute 'C:\Temp\revUserTest.bat'

#Create user to run the task
$taskUser = "RevUser"
$taskPass = "t!d3Le"

#Create task trigger to run once during startup
$taskTrigger = New-ScheduledTaskTrigger -AtStartup

# Task name 
$taskName = "RevUserLogin"

# Task description
$description = "generate ntuserdat file"
try{
# Register task
Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -User $taskUser -Password $taskPass -Description $description -RunLevel Highest -Force -ErrorAction stop
Write-Log -message "$taskName created successfully"
}catch{
	Write-Log -message "Task creation failed" -level "ERROR"
}
Write-Log -message "#########"
move-item -Path .\createLocalAdminLog.txt -Destination "C:\ProgramData\Revolution\AzureIot\Upload-Reports\$($UnitSerialNum.Trim('"'))_$(get-date -f yyyy-MM-dd-HHmmss)_createLocalAdminLog.csv"

Restart-Computer