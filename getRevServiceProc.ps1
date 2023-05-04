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
start-transcript -path "C:\Temp\getRevServiceProc.txt"

Get-Process -IncludeUserName | Where UserName -Match "RevService" | select UserName,ProcessName

#stop log file
stop-transcript

#moves the log file to be uploaded. 
move-item -Path .\getRevServiceProc.txt -Destination "C:\ProgramData\Revolution\AzureIot\Upload-Reports\$($UnitSerialNum.Trim('"'))_$(get-date -f yyyy-MM-dd-HHmmss)_RevServiceProcesses.csv"