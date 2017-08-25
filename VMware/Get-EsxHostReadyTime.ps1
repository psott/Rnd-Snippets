###
#   Alexander Ott
#   6.7.17
#
#   Dieses Script loopt durch alle Regionen und prüft den CPU Ready Wert aller ESX Hosts
#   
###
cls
$ExportPath = 'C:\Users\xxx\Documents\ESX-VM-ReadyTimeMax.csv'

#############################################
Add-PsSnapin VMware.VimAutomation.Core
$creds = Get-Credential -Credential $(whoami)
$viservers = 'virtualcenter.yourdomain.com'

foreach($viserver in $viservers){
    try{
        Connect-VIServer -Server $viserver -Credential $creds -ErrorAction Stop
        Write-Host "Verbindung zu $viserver erfolgreich aufgebaut" -ForegroundColor Green

        $VMs = Get-VM | where{$_.PowerState -eq 'PoweredOn'}
        $count = $VMs.Count
        foreach($VmData in $VMs){

            $VM = $VmData.Name
            $count = $count - 1
            Write-Host "$VM wird abgefragt - noch $count"

            $VMRdy = $VmData | Get-Stat -Stat Cpu.Ready.Summation -Realtime -Instance '' | Measure-Object -Property Value -Average -Maximum
            
            $VMRdyAv = [math]::Round($VMRdy.Average,2)
            $VMRdyMax = $VMRdy.Maximum

            $vCpuCount = $VmData.NumCpu
            $RdyPerCoreAv = [math]::Round($VMRdyAv/$vCpuCount ,2)
            $RdyProzentAv = [math]::Round(((($VMRdyAv/$vCpuCount) / (20*1000))*100),2)

            $RdyPerCoreMax = [math]::Round($VMRdyMax/$vCpuCount ,2)
            $RdyProzentMax = [math]::Round(((($VMRdyMax/$vCpuCount) / (20*1000))*100),2)

            $co = [pscustomobject]@{
                'VIServer' = $viserver
                'VMName' = $VM
                'vCPU' = $vCpuCount
                'ReadyTime (ms) total' = $VMRdyAv
                'ReadyTime (ms) per Core' = $RdyPerCoreAv
                'ReadyTime (%) per vCore' = $RdyProzentAv
                'ReadyTime (ms) total max' = $VMRdyMax
                'ReadyTime (ms) per Core max' = $RdyPerCoreMax
                'ReadyTime (%) per vCore max' = $RdyProzentMax
            }
            $co | Export-Csv -Path $ExportPath -Delimiter ';' -NoTypeInformation -Append
        }
        Disconnect-VIServer -Server $viserver -confirm:$false
    }
    catch{
        Write-Host "es konnte keine Verbindung zu $viserver aufgebaut werden" -ForegroundColor Red
    }
}
