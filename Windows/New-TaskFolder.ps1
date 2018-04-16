#connect
$scheduleObject = New-Object -ComObject schedule.service
$scheduleObject.connect()

#create
$rootFolder = $scheduleObject.GetFolder("\")
$rootFolder.CreateFolder("PoshTasks")

#delete
$rootFolder.DeleteFolder("poshTasks",$unll)
