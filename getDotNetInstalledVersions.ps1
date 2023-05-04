#script block to get unit serial number to append to log file name later
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
#Begin log
start-transcript -path "C:\Temp\dotNet.txt"

#gets dot Net version and release installed adds it to a file and uploads the file to Reach
get-childitem "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP" -Recurse | Get-ItemProperty -Name version -EA 0 | Where {$_.PSChildName - Match '^(?!S)\p{L}'} | Select PSCHildName, version


#export log to reach
Stop-Transcript

move-item -Path .\*dotNet.txt -Destination "C:\ProgramData\Revolution\AzureIot\Upload-Reports\$($UnitSerialNum.Trim('"'))_dotNetVersionInstalled.csv"