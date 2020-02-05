function Get-SccmDeviceCreationUser
{
    param(
        $ComputerName,
        $CreationDate
    )
$query = "
SELECT 
    SMS_StatusMessage.Time,
    SMS_StatMsgWithInsStrings.InsString1,
    SMS_StatMsgWithInsStrings.InsString4
FROM 
    SMS_StatusMessage
LEFT JOIN
    SMS_StatMsgWithInsStrings on SMS_StatMsgWithInsStrings.RecordID = SMS_StatusMessage.RecordID
WHERE 
    SMS_StatusMessage.MessageID = 30213
    AND
    SMS_StatMsgWithInsStrings.InsString4 = '$ComputerName'
    "
$data = Get-WmiObject @Params -Query $query | foreach{
    $t = $null
    $t = [datetime]::parseexact($_.SMS_StatusMessage.Time.split('.')[0],"yyyyMMddHHmmss",[System.Globalization.CultureInfo]::InvariantCulture)
    
    [pscustomobject]@{
        User = $_.SMS_StatMsgWithInsStrings.InsString1
        ComputerName = $_.SMS_StatMsgWithInsStrings.InsString4
        Time = $t
    }
} 

    #if($CreationDate){
    #    $data | where{$_.Time -eq $CreationDate}
    #}
    #else{
    #    $data
    #}

    if ($data -in $null,''){
        [pscustomobject]@{
            User = ''
            ComputerName = $ComputerName
            Time = ''
        }
    }
    else{
        $data
    }
}
