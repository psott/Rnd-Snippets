$ArgList = @(
    "powershell"
    "Start-Process powershell"
    "-Verb runAs"
    "-ArgumentList 'Enable-PSRemoting -force;"
    "Set-Item WSMan:localhost\client\trustedhosts -value *'"
    ) -join ' '

$IWM_Params = @{
    ComputerName = 'xxx'
    Namespace = 'root\cimv2'
    Class = 'Win32_Process'
    Name = 'Create'
    #Credential = $Cred
    # the next value may need to be quoted if it needs to be [string] instead of [int]
    Impersonation = 3
    EnableAllPrivileges = $True
    ArgumentList = $ArgList
    }
Invoke-WmiMethod @IWM_Params


##### OR
$CN = 'computername'
([wmiclass]"\\$CN\root\cimv2:Win32_Process").Create('powershell "Enable-PSRemoting -Force"')
