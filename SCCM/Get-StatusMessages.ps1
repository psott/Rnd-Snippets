$query = "
select 
stat.*, 
ins.*, 
att1.*, 
stat.Time

from SMS_StatusMessage as stat left join SMS_StatMsgInsStrings as ins on stat.RecordID = ins.RecordID left join SMS_StatMsgAttributes as att1 on stat.RecordID = att1.RecordID 

where 
      stat.MachineName = 'wtn700921' 
  and stat.MessageID = 11135
  and ins.AttributeValue = 'AS1202E1'

order by stat.Time desc
"

$all = gwmi -ComputerName $SiteServer -Namespace $NS -Query $query
#
$all.ins | ogv
