
$smsauth = gwmi -Namespace root\ccm -Class sms_authority
$SiteServer = $smsauth.CurrentManagementPoint
$SiteCode = $smsauth.name.split(':')[1]
$NS = "root\sms\site_$SiteCode"

$query = "SELECT Name,PackageID
FROM SMS_TaskSequencePackage"

$PackageID = (gwmi -ComputerName $SiteServer -Namespace $NS -Query $query |select name,PackageID | ogv -PassThru).PackageID
if($PackageID -in $null,''){write-host 'abbruch';break}

$query = "SELECT name, ResourceID
FROM sms_r_system
WHERE OperatingSystemNameandVersion like '%workstation 10%'"

$ResourceID = (gwmi -ComputerName $SiteServer  -Namespace $NS -Query $query | select name,ResourceID | ogv -PassThru).ResourceID
if($ResourceID -in $null,''){write-host 'abbruch';break}

$query = "SELECT * 
FROM SMS_TaskSequenceExecutionStatus
WHERE PackageID = '$PackageID' AND ResourceID = '$ResourceID' ORDER BY Step"

$data = gwmi -ComputerName $SiteServer  -Namespace $NS -Query $query | foreach{
    
    $et = ''
    $et = if($_.ExecutionTime -notin $null,''){
        [datetime]::parseexact($_.ExecutionTime.split('.')[0],"yyyyMMddHHmmss",[System.Globalization.CultureInfo]::CurrentCulture)
    }

    [pscustomobject]@{
        Step = $_.Step
        ExitCode = $_.ExitCode
        ExecutionTime = $et
        ExecutionTimeO = $_.ExecutionTime
        GroupName = $_.GroupName
        ActionName = $_.ActionName
        LastStatusMsgName = $_.LastStatusMsgName
        ActionOutput = $_.ActionOutput
    }
} 

if($data -notin $null,''){
    #$data | sort -Property ExecutionTime -Descending | ogv

    $prop1 = @{Expression='ExecutionTime'; Ascending=$true } #Ascending=$true Descending=$true
    $prop2 = @{Expression='Step'; Descending=$true }
    $data | Sort-Object $prop1, $prop2 | where{$_.LastStatusMsgName -notlike '*skipped*'} | ogv

}
else{
    Write-Host "keine daten"
}




