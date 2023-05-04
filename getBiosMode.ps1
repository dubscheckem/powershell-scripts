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

#get bios mode
$env:firmware_type | out-file "C:\ProgramData\Revolution\AzureIot\Upload-Reports\$($UnitSerialNum.Trim('"'))_biosMode.csv"