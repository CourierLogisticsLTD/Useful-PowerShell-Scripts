param(
    [Parameter(Mandatory = $false)]
    [String]$ComputerName
)
if ($ComputerName) {
    $WmiObject = Get-WMIObject -Class Win32_OperatingSystem -ComputerName $ComputerName
}
else {
    $WmiObject = Get-WMIObject -Class Win32_OperatingSystem
}
$LastBootUpTime = $WmiObject.ConvertToDateTime($WmiObject.LastBootUpTime)
$SystemUptime = (Get-Date) - $LastBootUpTime
Write-Host "Uptime : $($SystemUptime.days) Days, $($SystemUptime.hours) Hours, $($SystemUptime.minutes) Minutes, $($SystemUptime.seconds) Seconds"