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
  set autologin for a local user and sets up RevApp on that user
.DESCRIPTION
  sets registry data for RevUser
.OUTPUTS
  none
.NOTES
  Version:        1.0
  Author:         Daniel Sorrells
  Creation Date:  2022.11.12
  Purpose/Change: Initial script development
#>
# Configuration
$username = "RevUser" #change this value for desired account name
$password = "t!d3Le" #change this value for desired password. (not secure if someone can see the script)
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$userPath = "HKU:\UserHive\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$revappPath = "HKLM:\SOFTWARE\Tidel\Revolution\Config"
$profiles = @("C:\Users\RevUser") #list of users to modify
$null = New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
$logFile = ".\setRevUserSettings.txt"

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
Function Set-AutoLogonRevUser {
    process {
		try {
		#edit registry to set RevUser as autologin
        Set-ItemProperty $registryPath "AutoAdminLogon" -value "1" -Type String -ErrorAction stop
		Set-ItemProperty $registryPath "DefaultUsername" -value "$username" -Type String -ErrorAction stop
		Set-ItemProperty $registryPath "DefaultPassword" -value "$password" -Type String -ErrorAction stop
        Write-Log -message "$username set to autologin"
		
        }catch{
        Write-log -message "Editing registry failed" -level "ERROR"
      }
    }    
}
Function Set-RevUserKeys {
	process {
		foreach ($profile in $profiles) {
			try {
				
				#load the hives since we're using SYSTEM to run as
                $userHive = Split-Path $profile -leaf
				$null = reg load HKU\UserHive "$profile\NTUSER.DAT" 
				Write-Log -message "$profile hive loaded"
				Set-ItemProperty -path "HKU:\UserHive\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name "Shell" -value "C:\Revinstall\installer\revinstall.exe /CLUSTERSERVER" -ErrorAction Stop
				Write-Log -message "$profile shell is set"
				Set-ItemProperty -path "HKU:\UserHive\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -name "NoRun" -value '1' -ErrorAction Stop
				Write-Log -message "$profile explorerer set to NoRun"
				[gc]::collect()
				$null = reg unload HKU\UserHive 
				Write-Log -message "$profile hive unloaded"
			}
			catch{
			Write-log -message "Editing registry failed" -level "ERROR"
			}
		}
		$null = Remove-PSDrive -Name HKU

	}

}

Function Set-RevappSettings {
	process {
		#changes the iNetworkedDatabaseType key to cluster server primary role then disables previous scheduled tasks
		set-itemproperty $revappPath -name "iNetworkedDatabaseType" -value 3 -type DWord
		if ((get-itemproperty $revappPath -name "iNetworkedDatabaseType" | select-object -expandproperty "iNetworkedDatabaseType") -eq 3)
		{
			Write-Log -message "iNetworkedDatabaseType set to 3"
		}
		else
		{
			Write-Log -message "iNetworkedDatabaseType is NOT set to 3"
		}
		$schedTasks = @("Cluster Server Revinstall","RevUserLogin","SetRevUserSettings")
		foreach ($schedTask in $schedTasks) { 
			try {
				#stop the task
				stop-scheduledtask -taskname $schedTask -erroraction Stop
				write-log -message "$schedTask stopped successfully"
				#disable the task
				disable-scheduledtask -taskname $schedTask -erroraction Stop
				write-log -message "$schedTask disabled successfully"
			}
			catch {
				Write-Log -message "Stopping or disabling $schedTask failed" -level "ERROR"
			}
		}
	}
}

Write-Log -message "#########"
Write-Log -message "$env:COMPUTERNAME - Set Autologin for RevUser"
Set-AutoLogonRevUser
Set-RevUserKeys
Set-RevappSettings
Write-Log -message "#########"
move-item -Path .\setRevUserSettings.txt -Destination "C:\ProgramData\Revolution\AzureIot\Upload-Reports\$($UnitSerialNum.Trim('"'))_$(get-date -f yyyy-MM-dd-HHmmss)_setRevUserSettings.csv"
#Restart-Computer
