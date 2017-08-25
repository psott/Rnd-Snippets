$VM = [pscustomobject]@{
  Name = 'Server1'
  Status = 'Running'
}

Write-Host "Stop VM"
#Stop-VM -VM $VM -RunAsync

$timeoutmax = 10
$tick = 0
Do {
  $tick++
  
  #if($tick -eq 5){
  #  $VM.Status = 'NotRunning'
  #  break
  #}
  
  Write-Host "noch nicht - $tick - $($VM.Status)"
  Start-Sleep -Seconds 1
}
Until ($tick -ge $timeoutmax)

if($VM.Status -ne 'NotRunning'){
  Write-Host "zwangs shutdown"
  #Stop-VM -VM $VM -Kill -Confirm:$false
}


Write-Host "start vm"
