$LogName = (Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | ogv -PassThru).LogName

$Level = 1,2,3,4,5 | ogv -PassThru

Get-WinEvent -FilterHashtable @{'LogName'="$LogName";'Level'=$Level} | ogv
