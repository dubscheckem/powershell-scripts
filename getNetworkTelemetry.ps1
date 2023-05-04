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


#add desired logs with Full Name to this list for capture	
$logName = @("Microsoft-Windows-Dhcp-Client/Operational","Microsoft-Windows-DNS-Client/Operational","Microsoft-Windows-NetworkProfile/Operational")

#iterate through the logs and upload them to reach
foreach ($eventLog in $logName) 
	{	
		Get-WinEvent -LogName $eventLog | Format-List | out-file "C:\ProgramData\Revolution\AzureIot\Upload-Reports\$($UnitSerialNum.Trim('"'))_$($eventLog.Trim('/Operational')).csv"
	}

