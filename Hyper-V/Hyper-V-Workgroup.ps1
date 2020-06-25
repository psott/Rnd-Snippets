winrm set winrm/config/client @{TrustedHosts="*"} 
cmdkey /add:srv1 /user:ADMINISTRATOR /pass:Password

Get-NetConnectionProfile | where{$_.NetworkCategory -eq 'Public'} | foreach{
    Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private
}

Get-Item WSMan:\localhost\Client\TrustedHosts

Enable-PSRemoting -Force
Set-Item WSMan:\localhost\Client\TrustedHosts *
