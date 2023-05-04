#read file in, change path to desired file
$in_file = "C:\users\dsorrells\documents\AllComputersInSaylite2.csv" 

#output file, change path to desired file
$out_file = "C:\users\dsorrells\documents\pcModelsInSaylite.csv"

#read in PC names
$computers = import-csv $in_file | Select-Object -ExpandProperty Name


#iterate through PCs in the list, sending a remote command to each PC in the list
$output = ForEach($computer in $computers) {
        invoke-command -computername $computer -scriptblock{Get-CimInstance -ClassName CIM_Processor} 
          
    }


#write output to file
$output | Export-Csv $out_file -NoTypeInformation -Encoding UTF8
