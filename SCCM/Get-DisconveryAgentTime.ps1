$Params = @{
    ComputerName = 'xxx'
    Namespace = "root\sms\site_xxx"
    ErrorAction = 'Stop'
}

$Resources = Get-WmiObject @Params -Query "SELECT Name,AgentName,AgentTime FROM SMS_R_System" | select Name,AgentName,AgentTime
$out = foreach ($Resource in $Resources) {
    $i = 0
    foreach($e in $Resource.AgentName.Count){
        [pscustomobject]@{
            "Resource Name" = $Resource.Name;
            "Agent Name" = $Resource.AgentName[$i]
            "Agent Time" = [System.Management.ManagementDateTimeconverter]::ToDateTime($Resource.AgentTime[$i])
        }
        $i++
    }
}
$out | Out-GridView
