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

get-localuser -name "RevUser" | set-localuser -passwordneverexpires $True

get-wmiobject -class Win32_UserAccount -Filter "LocalAccount='True'" | where Name -eq "RevUser" | select -property Name, PasswordExpires | out-file "C:\ProgramData\Revolution\AzureIot\Upload-Reports\$($UnitSerialNum.Trim('"'))_RevUserPassExpiryStatus.csv"

