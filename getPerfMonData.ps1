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

#Defines performance monitor counters to read
$Counters = @(
	'\processor(_total)\% processor time',
	'\memory\% committed bytes in use',
	'\physicaldisk(_total)\% disk time'
)

#Loops through counters defined earlier, adjust total samples with MaxSamples, adjust frequency with SampleInterval in seconds. Current settings for 24 hours with 1 minute interval
Get-Counter -Counter $Counters -MaxSamples 1200 -SampleInterval 60 | ForEach {
	$_.CounterSamples | ForEach {
		[pscustomobject]@{
			TimeStamp = $_.TimeStamp
			Path = $_.Path
			Value = $_.CookedValue
		}
	}
} | Export-Csv -Path "C:\ProgramData\Revolution\AzureIot\Upload-Reports\$($UnitSerialNum.Trim('"'))_PerfMonData.csv" -NoTypeInformation