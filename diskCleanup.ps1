#edit this list to delete folders
$folders = @("C:\Fingerprint testing", "C:\LTSC", "C:\WinUpdateCumulative", "C:\WinUpdateMajor", "C:\WinUpdateMinor", "C:\WinUpdateServiceStack", "C:\WinUpdateStandard")

foreach ($i in $folders) 
	{
	if (test-path -path $i)
		{
		remove-item -path $i -force"
		}
	}