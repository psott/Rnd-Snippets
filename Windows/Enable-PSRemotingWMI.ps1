$ArgList = @(
    "powershell"
    "Start-Process powershell"
    "-Verb runAs"
    "-ArgumentList 'Enable-PSRemoting -force;"
    "Set-Item WSMan:localhost\client\trustedhosts -value *'"
    ) -join ' '

$IWM_Params = @{
    ComputerName = 'V998SPWTV191040'
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