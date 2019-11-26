$sc = 'C:\Users\xxx\ClientFix'

$pc = 'xxx'

$result = & $sc\PsExec.exe \\$PC -nobanner powershell.exe -executionpolicy bypass -file c:\myScript.ps1 2> $null

$result = & $sc\PsExec.exe \\$PC -nobanner powershell.exe -executionpolicy bypass -command "get-process" 2> $null

$result = & $sc\PsExec.exe \\$PC -nobanner C:\Windows\System32\cmd.exe /c "ipconfig" 2> $null

$result
