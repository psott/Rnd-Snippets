$smsauth = gwmi -Namespace root\ccm -Class sms_authority
$SiteServer = $smsauth.CurrentManagementPoint
$SiteCode = $smsauth.name.split(':')[1]
$NS = "root\sms\site_$SiteCode"

$query = "select * FROM sms_collection"

$AllCollections = gwmi -ComputerName $SiteServer -Namespace $NS -Query $query

$count = ($AllCollections | Measure-Object).count
$i = 0
$out = foreach($Collection in $AllCollections){
    
    $coltype = switch($Collection.CollectionType){
        '1'{'Manual'}
        '2'{'Scheduled'}
        '4'{'Incremental'}
        '6'{'Scheduled and Incremental'}
        default{'unknown'}
    }

    $ColPath = [wmi]$Collection.__PATH
    $ColSched = $ColPath.RefreshSchedule

    $Update = if($ColSched.DaySpan -notin $null,'',0){
        #if($ColSched.DaySpan -eq 1){"$($ColSched.DaySpan) Tag"}
        #else{"$($ColSched.DaySpan) Tage"}
        "$($ColSched.DaySpan) Tage"
    }
    elseif($ColSched.HourSpan -notin $null,'',0){
        #if($ColSched.HourSpan -eq 1){"$($ColSched.HourSpan) Stunde"}
        #else{"$($ColSched.HourSpan) Stunden"}
        "$($ColSched.HourSpan) Stunden"
    }
    elseif($ColSched.MinuteSpan -notin $null,'',0){
        #if($ColSched.MinuteSpan -eq 1){"$($ColSched.MinuteSpan) Minute"}
        #else{"$($ColSched.MinuteSpan) Minuten"}
        "$($ColSched.MinuteSpan) Minuten"
    }
    else{
        'keiner'
    }

    if($ColSched.StartTime -notin $null,''){
        $csst = [datetime]::parseexact($ColSched.StartTime.split('.')[0],"yyyyMMddHHmmss",[System.Globalization.CultureInfo]::InvariantCulture)
    }
    else{
        $csst = ''
    }

    [pscustomobject]@{
        CollectionID = $Collection.CollectionID
        Name = $Collection.Name
        ObjectPath = $Collection.ObjectPath
        #CollectionType = $Collection.CollectionType
        CollectionTypeName = $coltype
        #MinuteSpan = $ColSched.MinuteSpan
        #HourSpan = $ColSched.HourSpan
        #DaySpan = $ColSched.DaySpan
        #MinuteDuration = $ColSched.MinuteDuration
        #HourDuration = $ColSched.HourDuration
        #DayDuration = $ColSched.DayDuration
        #IsGMT = $ColSched.IsGMT
        UpdateInterval = $Update
        StartTime = $csst
    }

    $i++
    Write-Host "$i/$count"
} 

$out | ogv

