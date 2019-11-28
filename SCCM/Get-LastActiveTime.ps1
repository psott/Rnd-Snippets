$query = '
SELECT 
    SMS_R_SYSTEM.*,
    SMS_FullCollectionMembership.Name,
    SMS_G_System_CH_ClientSummary.LastActiveTime,
    SMS_G_System_CH_ClientSummary.LastHardwareScan
FROM 
    SMS_FullCollectionMembership
Inner join
    SMS_R_SYSTEM ON SMS_FullCollectionMembership.ResourceID = SMS_R_SYSTEM.ResourceID
inner join 
    SMS_G_System_CH_ClientSummary on SMS_G_System_CH_ClientSummary.ResourceID = SMS_R_System.ResourceId
WHERE 
    SMS_FullCollectionMembership.CollectionID = "SMS00001"'

$data = Get-CimInstance @params -Query $query
