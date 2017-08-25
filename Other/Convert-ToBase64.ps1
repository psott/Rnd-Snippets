$null | clip.exe
$file = "U:\Download\VMware.PowerCLI.zip.part8"

$IoStream = [System.IO.File]::ReadAllBytes($file)
[System.Convert]::ToBase64String($iostream) | clip.exe

#clean up
$IoStream = $null
[System.GC]::Collect()
