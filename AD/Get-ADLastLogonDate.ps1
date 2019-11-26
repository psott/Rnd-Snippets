
# Gather all DC names
$AllDCs = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().domainControllers).Name

# In parallel, query the DCs for ALL users
$AllEntries = $AllDCs | foreach {
    if(Test-Connection -ComputerName $_){
        Write-Host "$_ - online" -ForegroundColor Green
        $de=[adsi]"LDAP://$_"
        $ComputerSeacher = New-Object System.DirectoryServices.DirectorySearcher($de,"(&(objectCategory=Computer)(samaccountname=WT*))")
        [void]$ComputerSeacher.PropertiesToLoad.Add('name')
        [void]$ComputerSeacher.PropertiesToLoad.Add('lastLogon')
        $ComputerSeacher.PageSize = 9999
        $Computers = $ComputerSeacher.FindAll().Properties

        foreach($Computer in $Computers){
            New-Object psobject -Property @{
                Name = $($Computer.name)
                LastLogon = ([datetime]::FromFileTime([string]$Computer.lastlogon))
            }
        }
    }
    else{
        Write-Host "$_ - offline" -ForegroundColor Red
    }
}

# Group all the results by user name
$out = foreach($ComputerEntry in $AllEntries | Group-Object -Property Name){
        # Emit the newest entry per username
        $ComputerEntry.Group | Sort-Object -Property LastLogon -Descending | Select-Object -First 1
    }
$out
