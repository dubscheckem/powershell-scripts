#start the wmi driver query from smartdeploy support
start-process -FilePath .\wmi.vbs

#get file name from image file to append to query file name later
$Name = Get-Childitem "C:\Image Version*.txt" | Select -ExpandProperty Name

#append the image version file name to query file name
#Rename-item -Path .\wmi.txt -NewName "$($Name.Trim(".txt")) - wmi.txt"

#pause script while query runs, prevents failure moving the file
Start-Sleep -Seconds 15

#append the image version file name to query file name and move the wmi query file to upload reports
Move-Item -Path .\wmi.txt -Destination "C:\ProgramData\Revolution\AzureIot\Upload-Reports\$($Name.Trim(".txt")) - wmi.txt"

