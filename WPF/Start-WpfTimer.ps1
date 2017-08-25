Add-Type -AssemblyName System.Windows.Forms
$Script:timer = New-Object System.Windows.Forms.Timer
$Script:timer.Interval = 5000 #5sek
$Script:timer.add_tick({Your-Function})
$Script:timer.Start()


$Script:timer.Stop()
