$SqlInstance = "$env:COMPUTERNAME\MSSQLSERVER"
$OldDbName = 'oldname'
$NewDbName = 'newname'
$NewPath = 'D:\MSSQL'

$Query = "
USE [$OldDbName];

ALTER DATABASE $OldDbName MODIFY FILE (NAME = '$OldDbName', FILENAME = '$NewPath\DATA\$NewDbName.mdf');

ALTER DATABASE $OldDbName MODIFY FILE (NAME = '$($OldDbName)_log', FILENAME = '$NewPath\PROT\$($NewDbName)_log.ldf');

ALTER DATABASE $OldDbName MODIFY FILE (NAME = $OldDbName, NEWNAME = $NewDbName);
ALTER DATABASE $OldDbName MODIFY FILE (NAME = $($OldDbName)_log, NEWNAME = $($NewDbName)_log);
"
Invoke-DbaQuery -SqlInstance $SqlInstance -Query $Query

$Query = "USE master
GO
ALTER DATABASE $OldDbName
SET OFFLINE WITH ROLLBACK IMMEDIATE
GO"
Invoke-DbaQuery -SqlInstance $SqlInstance -Query $Query

Rename-Item -Path "$NewPath\DATA\$OldDbName.mdf" -NewName "$($NewDbName).mdf"
Rename-Item -Path "$NewPath\PROT\$($OldDbName)_log.ldf" -NewName "$($NewDbName)_log.ldf"

$Query = "USE master
GO
ALTER DATABASE $OldDbName
SET ONLINE
GO
"
Invoke-DbaQuery -SqlInstance $SqlInstance -Query $Query


$Query = "ALTER DATABASE [$OldDbName] MODIFY NAME = [$NewDbName]"
Invoke-DbaQuery -SqlInstance $SqlInstance -Query $Query
