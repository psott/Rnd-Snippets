$Params = @{
    ComputerName = 'xxx'
    Namespace = "root\sms\site_xxx"
    ErrorAction = 'Stop'
}

$Resources = Get-WmiObject @Params -Query "SELECT ResourceId,Name,AgentName,AgentTime FROM SMS_R_System" | select ResourceId,Name,AgentName,AgentTime
$out = foreach ($Resource in $Resources) {
    $i = 0
    1..$Resource.AgentName.Count | foreach{
        [pscustomobject]@{
            ResourceId = $Resource.ResourceId
            Name = $Resource.Name
            AgentName = $Resource.AgentName[$i]
            AgentTime = [System.Management.ManagementDateTimeconverter]::ToDateTime($Resource.AgentTime[$i])
        }
        $i++
    }
}
$out | Out-GridView
