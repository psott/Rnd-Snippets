$isoPath = 'C:\xxx\Windows-1903-x64-ger.iso'

$mountResult = Mount-DiskImage -ImagePath $isoPath -PassThru

$driveLetter = ($mountResult | Get-Volume).DriveLetter

$d = dism /Get-WimInfo /WimFile:$($driveLetter):\sources\install.esd /index:1

$d[7]
$d[13]

$null = Dismount-DiskImage -ImagePath $isoPath
