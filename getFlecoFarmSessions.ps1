import-module PSTerminalServices

$tservers = @("termserv4", "termserv5", "termserv6", "termserv7")

foreach ($tserver in $tservers) {
    Get-TSSession -computername $tserver
}