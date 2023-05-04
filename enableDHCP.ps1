# Set Internet connection to DHCP
$IPType = "IPv4"
$adapter = Get-NetAdapter -InterfaceDescription "Intel*"
$interface = $adapter |Get-NetIPInterface -AddressFamily $IPType
	
#Remove existing gateway
$interface | Remove-NetRoute -Confirm:$false
		
#Enable DHCP
$interface | Set-NetIPInterface -DHCP Enabled
		
#Configure DNS servers 
$interface | Set-DnsClientServerAddress -ResetServerAddresses