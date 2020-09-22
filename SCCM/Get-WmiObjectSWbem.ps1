function Get-WmiObjectSWbem
{
    param(
        $Query,
        $ComputerName = 'xxx',
        $siteCode = 'xxx'
    )

    $NameSpace = "root\sms\site_$siteCode"
    $ObjSWBemLocator = New-Object -ComObject "WbemScripting.SWbemLocator"
    #$SWbemLocator.Security_.AuthenticationLevel = 6
    $objWMIService = $ObjSWBemLocator.ConnectServer($ComputerName,$Namespace)

    $objCollection = $objWMIService.ExecQuery($query)

    foreach ($objInstance in $objCollection) {
        $obj = New-Object -TypeName psobject
        foreach ($property in $objInstance.Properties_) {
            $obj | Add-Member -MemberType NoteProperty -Name $property.Name -Value $property.Value
            
        }
        $obj
    }
}

$query = "SELECT * from SMS_R_SYSTEM where name = 'xxx'"

$query = "SELECT Name,SerialNumber from SMS_R_SYSTEM where name LIKE 'xxx%'"

Get-WmiObjectSWbem -Query $query | ogv
