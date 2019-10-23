
$TaskName = 'TaskName'
$ScriptPath = 'C:\Tasks\Start-Task.ps1'
$WorkingDirectory = "C:\Tasks"
$TaskDescription = "Task Description"
$TaskUser = $(whoami)

###########################################################################################
$cred = Get-Credential -Credential $(whoami)
$cred | Export-Clixml -Path "C:\Tasks\TaskCredentials.xml"

if(Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue){
  Get-ScheduledTask -TaskName $TaskName | Unregister-ScheduledTask -Confirm:$false
}

$taskaction = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-noprofile -executionpolicy bypass -file $ScriptPath" -WorkingDirectory $WorkingDirectory
$trigger =  New-ScheduledTaskTrigger -Daily -At 5am
$params = @{
  Action = $taskaction
  Trigger = $trigger
  TaskName = $TaskName
  Description = $TaskDescription
  User = $TaskUser
}
Register-ScheduledTask @params -RunLevel:Highest -Password $cred.GetNetworkCredential().Password
