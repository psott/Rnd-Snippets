winrm set winrm/config/client @{TrustedHosts="*"} 
cmdkey /add:srv1 /user:ADMINISTRATOR /pass:Password
