$smsauth = gwmi -Namespace root\ccm -Class sms_authority
$SiteServer = $smsauth.CurrentManagementPoint
$SiteCode = $smsauth.name.split(':')[1]
$NS = "root\sms\site_$SiteCode"

$query = "SELECT name, description, build, OperatingSystemNameandVersion, LastLogonTimestamp, Client, ClientVersion, active, macaddresses, ipaddresses, adsitename, creationdate, ResourceID
FROM sms_r_system 
WHERE OperatingSystemNameandVersion like '%workstation 10%'"

$d = gwmi -ComputerName $SiteServer -Namespace $NS -Query $query | 
select name, description, build, OperatingSystemNameandVersion,LastLogonTimestamp,Client,ClientVersion,active, macaddresses,adsitename, creationdate,ipaddresses, ResourceID

$data = foreach($c in $d){
    
    $version = switch ($c.build){
        '10.0.15063' {'1703'}
        '10.0.16299' {'1709'}
        '10.0.17134' {'1803'}
        '10.0.17763' {'1809'}
        '10.0.18362' {'1903'}
        '10.0.14393' {'1607'}
        '10.0.18950' {'2001'}
        default {'no version'}
    }

    $llt = $cd = $null

    $llt = if($c.LastLogonTimestamp -notin $null,''){
        [datetime]::parseexact($c.LastLogonTimestamp.split('.')[0],"yyyyMMddHHmmss",[System.Globalization.CultureInfo]::CurrentCulture)
    }

    $cd = if($c.creationdate -notin $null,''){
        [datetime]::parseexact($c.creationdate.split('.')[0],"yyyyMMddHHmmss",[System.Globalization.CultureInfo]::CurrentCulture)
    }

    [pscustomobject]@{
        ResourceID = $c.ResourceID
        name = $c.name
        description = $c.description
        build = $c.build
        version = $version
        OperatingSystemNameandVersion = $c.OperatingSystemNameandVersion
        LastLogonTimestamp = $llt
        Client = $c.Client
        ClientVersion = $c.ClientVersion
        Active = $c.Active
        IpAddresses = $c.ipaddresses
        MacAddresses = $c.macaddresses
        AdSitename = $c.adsitename
        Creationdate = $cd

    }
}
$data | ogv
