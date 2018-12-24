$Task = forEach ($n in 1..254) {
    (New-Object System.Net.NetworkInformation.Ping).SendPingAsync("192.168.1.$n")
}      
[Threading.Tasks.Task]::WaitAll()
$Task.Result
     
forEach ($n in 1..254) {
  Get-WmiObject -Class Win32_PingStatus -Filter "Address='192.168.1.1' and timeout=100"
}
