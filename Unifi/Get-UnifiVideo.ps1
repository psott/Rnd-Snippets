#############################
#Put your protect ip in the respective area blow
#Add username and password. Do not delete anything special character as its quite important
#


$baseURI = "https://192.168.1.199:7443/api"
$cred = "`{`"username`": `"YOURUSER`", `"password`": `"YOURPASSWORD`"`}"
$filename = 'ProtectVideo.mp4'


[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

$oldProgressPreference = $progressPreference;
$progressPreference = 'SilentlyContinue';

$loginURI = "$baseURI/auth"
$authUri = "$baseURI/auth/access-key"
$EpocStart = Get-Date -Date "01/01/1970"

$returnFromAuth = Invoke-WebRequest -Uri $loginURI -Method Post -Body $cred -ContentType "application/json"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Accept','Application/Json')
$Key = $returnFromAuth.Headers.Authorization.tostring()
$headers.Add('Authorization', "Bearer $Key")



$accessKey = Invoke-RestMethod -uri $authUri -Method Post -Body $cred -ContentType "application/json" -SessionVariable session -Headers $headers
$cameraURI = "$baseURI/cameras?accessKey="+$accessKey.accessKey
$bootstrapURI = "$baseURI/bootstrap?accessKey="+$accessKey.accessKey
$data2 = Invoke-WebRequest -uri $cameraURI -Method Get  -ContentType "application/json" -SessionVariable session -Headers $headers
$bootstrapData = Invoke-WebRequest -uri $bootstrapURI -Method Get  -ContentType "application/json" -SessionVariable session -Headers $headers
$querydata = $bootstrapData |ConvertFrom-Json
$camerasToPullData = $querydata.cameras|Select-Object name, id








$Cameras = $camerasToPullData
Function Show-Menu {
    Param(
        $Cameras
    )
    do { 
        Write-Host "Please make a selection"
                $index = 1
        foreach ($Camera in $Cameras) {

            Write-Host [$index] $Camera.name
            $index++
        }

        $Selection = Read-Host 
    } until ($Cameras[$selection-1])
  

 
    $Cameras[$selection-1]
}


$Selection = Show-Menu -Cameras $camerasToPullData
Write-host "Selected Camera" $Selection.name










Add-Type -AssemblyName System.Windows.Forms

# Main Form
$mainForm = New-Object System.Windows.Forms.Form
$font = New-Object System.Drawing.Font("Consolas", 13)
$mainForm.Text = "Start time for video"
$mainForm.Font = $font
$mainForm.ForeColor = "Black"
$mainForm.BackColor = "White"
$mainForm.Width = 500
$mainForm.Height = 200

# DatePicker Label
$datePickerLabel = New-Object System.Windows.Forms.Label
$datePickerLabel.Text = "Date"
$datePickerLabel.Location = "15, 10"
$datePickerLabel.Height = 22
$datePickerLabel.Width = 90
$mainForm.Controls.Add($datePickerLabel)




# DatePicker
$datePicker = New-Object System.Windows.Forms.DateTimePicker
$datePicker.Location = "110, 7"
$datePicker.Width = "300"
$datePicker.Format = [windows.forms.datetimepickerFormat]::custom
$datePicker.CustomFormat = "MM/dd/yyyy HH:mm:ss"
$mainForm.Controls.Add($datePicker)



# OD Button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = "15, 130"
$okButton.ForeColor = "Black"
$okButton.BackColor = "White"
$okButton.Text = "OK"
$okButton.add_Click({$mainForm.close()})
$mainForm.Controls.Add($okButton)

[void] $mainForm.ShowDialog()



[string]$startTime = [int](get-date -Date $datePicker.Value -UFormat %s -Millisecond 0)
$startTime = $startTime+'000'




# Main Form
$mainForm = New-Object System.Windows.Forms.Form
$font = New-Object System.Drawing.Font("Consolas", 13)
$mainForm.Text = "Start time for video"
$mainForm.Font = $font
$mainForm.ForeColor = "Black"
$mainForm.BackColor = "White"
$mainForm.Width = 500
$mainForm.Height = 200

# DatePicker Label
$datePickerLabel = New-Object System.Windows.Forms.Label
$datePickerLabel.Text = "Date"
$datePickerLabel.Location = "15, 10"
$datePickerLabel.Height = 22
$datePickerLabel.Width = 90
$mainForm.Controls.Add($datePickerLabel)


# DatePicker
$datePicker = New-Object System.Windows.Forms.DateTimePicker
$datePicker.Location = "110, 7"
$datePicker.Width = "300"
$datePicker.Format = [windows.forms.datetimepickerFormat]::custom
$datePicker.CustomFormat = "MM/dd/yyyy HH:mm:ss"
$mainForm.Controls.Add($datePicker)



# OD Button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = "15, 130"
$okButton.ForeColor = "Black"
$okButton.BackColor = "White"
$okButton.Text = "OK"
$okButton.add_Click({$mainForm.close()})
$mainForm.Controls.Add($okButton)

[void] $mainForm.ShowDialog()

[string]$endTime = [int](get-date -Date $datePicker.Value -UFormat %s -Millisecond 0)
$endTime = $endTime+'000'


$accessKey = Invoke-RestMethod -uri $authUri -Method Post -Body $cred -ContentType "application/json" -SessionVariable session -Headers $headers
$cameraURI = "$baseURI/cameras?accessKey="+$accessKey.accessKey
$exportMe = "$baseURI/video/export?accessKey="+$accessKey.accessKey
$bootstrapURI = "$baseURI/bootstrap?accessKey="+$accessKey.accessKey
$channel = '0'

$exportVideoString = $exportMe+'&camera=' + $Selection.id + '&channel=0' + '&end=' + $endTime + '&filename=' + $filename + '&start=' + $startTime

$savepath = Get-Location
$savepath = $savepath.Path + '\' +$filename
Invoke-WebRequest -Uri $exportVideoString -Method Get  -ContentType "application/json" -SessionVariable session -Headers $headers -OutFile $savepath



Write-host 'your file was saved to ' $savepath

$progressPreference = $oldProgressPreference
