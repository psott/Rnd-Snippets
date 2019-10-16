$pkid = 'xxx'

$smsauth = gwmi -Namespace root\ccm -Class sms_authority
$SiteServer = $smsauth.CurrentManagementPoint
$SiteCode = $smsauth.name.split(':')[1]
$NameSpace = "root\sms\site_$SiteCode"

$params = @{
    Namespace = $NameSpace
    ComputerName = $SiteServer
}

$pkinfo = Get-WmiObject @params -Query "select * from SMS_Package where PackageID = '$pkid'"

Get-WmiObject @params -Query "select * from SMS_TaskSequencePackageReference where RefPackageID = '$pkid'" | foreach{
    $PackageID = $_.PackageID

    $ts = Get-WmiObject @params -Query "select * from SMS_TaskSequencePackage where PackageID = '$PackageID'"
    
    [pscustomobject]@{
        PackageID = $pkinfo.PackageID
        PackageName = $pkinfo.Name
        PackagePath = $pkinfo.ObjectPath
        TaskSequenceID = $ts.PackageID
        TaskSequenceName = $ts.Name
        TaskSequencePath = $ts.ObjectPath
    }
} | ogv

