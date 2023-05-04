$computerSystem = Get-CimInstance CIM_ComputerSystem
$computerBIOS = Get-CimInstance CIM_BIOSElement
$computerOS = Get-CimInstance CIM_OperatingSystem
$computerCPU = Get-CimInstance CIM_Processor
$computerHDD = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID = 'C:'"
$computerVideo = Get-WmiObject Win32_VideoController
$Filename = $computerSystem.UserName

Clear-Host
Out-File -filepath \\rrsfiles\Engineering\ENG_PC\$Filename.txt -append

Write-Host "System Information for: " $computerSystem.Name >> \\rrsfiles\Engineering\ENG_PC\$Filename.txt
"Manufacturer: " + $computerSystem.Manufacturer >> \\rrsfiles\Engineering\ENG_PC\$Filename.txt
"Model: " + $computerSystem.Model >> \\rrsfiles\Engineering\ENG_PC\$Filename.txt
"Serial Number: " + $computerBIOS.SerialNumber >> \\rrsfiles\Engineering\ENG_PC\$Filename.txt
"CPU: " + $computerCPU.Name >> \\rrsfiles\Engineering\ENG_PC\$Filename.txt
"HDD Capacity: "  + "{0:N2}" -f ($computerHDD.Size/1GB) + "GB" >> \\rrsfiles\Engineering\ENG_PC\$Filename.txt
"HDD Space: " + "{0:P2}" -f ($computerHDD.FreeSpace/$computerHDD.Size) + " Free (" + "{0:N2}" -f ($computerHDD.FreeSpace/1GB) + "GB)" >> \\rrsfiles\Engineering\ENG_PC\$Filename.txt
"RAM: " + "{0:N2}" -f ($computerSystem.TotalPhysicalMemory/1GB) + "GB" >> \\rrsfiles\Engineering\ENG_PC\$Filename.txt
"Operating System: " + $computerOS.caption + ", Service Pack: " + $computerOS.ServicePackMajorVersion >> \\rrsfiles\Engineering\ENG_PC\$Filename.txt
"User logged In: " + $computerSystem.UserName >> \\rrsfiles\Engineering\ENG_PC\$Filename.txt
"Video Info: " + $computerVideo.description >> \\rrsfiles\Engineering\ENG_PC\$Filename.txt