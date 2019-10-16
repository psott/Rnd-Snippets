$smsauth = gwmi -Namespace root\ccm -Class sms_authority
$SiteServer = $smsauth.CurrentManagementPoint
$SiteCode = $smsauth.name.split(':')[1]
$NS = "root\sms\site_$SiteCode"


$query = '
select 
    SMS_R_SYSTEM.ResourceID,
    SMS_R_SYSTEM.ResourceType,
    SMS_R_SYSTEM.Name,
    SMS_R_SYSTEM.SMSUniqueIdentifier,
    SMS_R_SYSTEM.ResourceDomainORWorkgroup,
    SMS_R_SYSTEM.Client,
    SMS_R_SYSTEM.OperatingSystemNameandVersion,
    SMS_G_System_LOGICAL_DISK.FreeSpace
from 
    SMS_R_System inner join SMS_G_System_LOGICAL_DISK on SMS_G_System_LOGICAL_DISK.ResourceID = SMS_R_System.ResourceId
where 
        SMS_G_System_LOGICAL_DISK.DeviceID = "C:" 
    and 
        SMS_G_System_LOGICAL_DISK.FreeSpace <= 40000
    and
        SMS_R_SYSTEM.OperatingSystemNameandVersion like "%workstation 10%"'

gwmi -ComputerName $SiteServer -Namespace $NS -Query $query | foreach{
    [pscustomobject]@{
        Name = $_.SMS_R_SYSTEM.Name
        FreeSpace = $_.SMS_G_System_LOGICAL_DISK.FreeSpace
    }
} | ogv -PassThru
