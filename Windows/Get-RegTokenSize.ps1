$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer1)
$RegKey= $Reg.OpenSubKey('SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters')

$RegKey.GetValue('MaxTokenSize')
