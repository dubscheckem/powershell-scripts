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
start-transcript -path "C:\Temp\getBarcodeLogs.txt"

#create destination folder (not creating the folder first copies all the source files into one big 'file', see MS documentation lmao)
if(Test-Path -path "C:\Temp\Logs\barcodeLogs")
	{
	$logPath = "C:\Temp\Logs\barcodeLogs"
	}
else	
	{
	new-item -path "C:\Temp\Logs\barcodeLogs" -itemtype Directory
	$logPath = "C:\Temp\Logs\barcodeLogs"
	}

#copy and move the desired files
copy-item -path "C:\Program Files\Zebra Technologies\Barcode Scanners\Common\Logs" -destination "C:\Temp\Logs\barcodeLogs" -recurse

#zip files in the desired path and upload to reach
compress-archive -path $logPath\* -destinationpath "C:\ProgramData\Revolution\AzureIot\Upload-Reports\$($UnitSerialNum.Trim('"'))_$(get-date -f yyyy-MM-dd-HHmmss)_barcodeLogs.zip"

#stop log file
stop-transcript

#moves the log file to be uploaded. 
move-item -Path .\*getBarcodeLogs.txt -Destination "C:\ProgramData\Revolution\AzureIot\Upload-Reports\$($UnitSerialNum.Trim('"'))_$(get-date -f yyyy-MM-dd-HHmmss)_barcodeOutputLog.csv"