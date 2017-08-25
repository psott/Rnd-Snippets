$Base64 = '<b64 stribng here>'
$Content = [System.Convert]::FromBase64String($Base64)

$FileName = 'VMware.PowerCLI.zip.part8'
Set-Content -Path "C:\Users\xxx\Downloads\$FileName" -Value $Content -Encoding Byte

#clean up
$Content = $null
[System.GC]::Collect()
