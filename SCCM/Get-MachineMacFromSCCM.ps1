Function Get-MachineMacFromSCCM{  
    Param(
        [parameter(Mandatory = $true)]
        $Computer
    )
    $smsauth = gwmi -Namespace root\ccm -Class sms_authority
    $SiteServer = $smsauth.CurrentManagementPoint
    $SiteCode = $smsauth.name.split(':')[1]
    $NS = "root\sms\site_$SiteCode"

    $query = "select * from SMS_R_SYSTEM WHERE Name = '$Computer'"

    $Mac = (Get-WmiObject -Namespace "root\sms\site_$SiteCode" -computerName $SiteServer -Query $query).MACAddresses 
    $Mac
}
