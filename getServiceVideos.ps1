#gets the video repo dir from user
$path = read-host "Enter path to root of video repo, ex C:\users\username\documents\repo"

#uses the path specified to look for service videos 
$directories=get-childitem -path $path -directory -recurse | where{$_.name -contains "Service"}

#loop through the service directories
$directories | foreach-object {get-childitem $_.Fullname} | out-file -filepath C:\serviceVideosList.txt