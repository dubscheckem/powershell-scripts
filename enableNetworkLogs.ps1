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
	
#starting log file
start-transcript -path "C:\Temp\enableEventLogs.txt"

#create array of logs, add one into the list to put it in the loop
$logName = @("Microsoft-Windows-Dhcp-Client/Operational","Microsoft-Windows-DNS-Client/Operational","Microsoft-Windows-NetworkProfile/Operational")

#iterate through the logs enabling and checking status of the log
foreach ($eventLog in $logName) 
	{	$log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $eventLog
		$log.IsEnabled=$true
		$log.MaximumSizeInBytes=20971520
		$log.SaveChanges()
		Get-WinEvent -ListLog $eventLog | Format-List is*
	}


#stop log file
stop-transcript

#moves the log file to be uploaded. 
move-item -Path .\*enableEventLogs.txt -Destination "C:\ProgramData\Revolution\AzureIot\Upload-Reports\$($UnitSerialNum.Trim('"'))_enableEventLogs.csv"