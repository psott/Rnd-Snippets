function Test-Port{
    param(
        $hostname, 
        $port
    )
    try {
        $ip = [System.Net.Dns]::GetHostAddresses($hostname) | 
            Select-Object IPAddressToString -ExpandProperty  IPAddressToString
        if($ip.GetType().Name -eq "Object[]"){
            $ip = $ip[0]
        }
    } 
    catch{
        Write-Host "Possibly $hostname is wrong hostname or IP"
        return
    }
    $t = New-Object Net.Sockets.TcpClient

    try{
        $t.Connect($ip,$port)
    } catch {}

    if($t.Connected){
        $t.Close()
        $msg = "Port $port is operational"
    }
    else{
        $msg = "Port $port on $ip is closed, "
        $msg += "You may need to contact your IT team to open it. "                                 
    }
    Write-Host $msg
}
Test-Port -hostname localhost -port 80
