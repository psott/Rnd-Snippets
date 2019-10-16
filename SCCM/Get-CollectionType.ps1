$smsauth = gwmi -Namespace root\ccm -Class sms_authority
$SiteServer = $smsauth.CurrentManagementPoint
$SiteCode = $smsauth.name.split(':')[1]
$NS = "root\sms\site_$SiteCode"

$query = "select * FROM sms_collection"

$out = gwmi -ComputerName $SiteServer -Namespace $NS -Query $query | foreach{
    
    $coltype = switch($_.CollectionType){
        '1'{'Manual'}
        '2'{'Scheduled'}
        '4'{'Incremental'}
        '6'{'Scheduled and Incremental'}
        default{'unknown'}
    }

    [pscustomobject]@{
        CollectionID = $_.CollectionID
        Name = $_.Name
        CollectionType = $_.CollectionType
        CollectionType2 = $coltype
    }
} 

$out | ogv
$out | group -Property CollectionType2
