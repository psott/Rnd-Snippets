<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
<RegistrationInfo> 
<Date>2018-06-04T14:25:31.5859452</Date>
<Author>DBA</Author> 
<URI>\AddSysadmin</URI>
</RegistrationInfo> 
<Triggers /> 
<Principals> 
<Principal id="Author">
<UserId>S-1-5-18</UserId>
<RunLevel>LeastPrivilege</RunLevel>
</Principal> 
</Principals> 
<Settings> 
<MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
<DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
<StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
<AllowHardTerminate>true</AllowHardTerminate>
<StartWhenAvailable>false</StartWhenAvailable>
<RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
<IdleSettings> 
<StopOnIdleEnd>true</StopOnIdleEnd>
<RestartOnIdle>false</RestartOnIdle>
</IdleSettings> 
<AllowStartOnDemand>true</AllowStartOnDemand>
<Enabled>true</Enabled>
<Hidden>false</Hidden> 
<RunOnlyIfIdle>false</RunOnlyIfIdle>
<WakeToRun>false</WakeToRun>
<ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
<Priority>7</Priority> 
</Settings> 
<Actions Context="Author">
<Exec> 
<Command>sqlcmd</Command>
<Arguments>-E -S
Servername -Q "CREATE LOGIN 
[domain\user] FROM WINDOWS EXEC sp_addsrvrolemember 'domain\user','sysadmin'"</Arguments>
</Exec> 
</Actions> 
</Task> 
