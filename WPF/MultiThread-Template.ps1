$Global:syncHash = [hashtable]::Synchronized(@{})
$newRunspace =[runspacefactory]::CreateRunspace()
$newRunspace.ApartmentState = "STA"
$newRunspace.ThreadOptions = "ReuseThread"
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

$psCmd = [PowerShell]::Create().AddScript({
    [xml]$xaml = @"
  <Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    Title="MainWindow" Height="350" Width="525">
    <Grid Background="#FF3A3A3A">
      <TextBlock Name="textBlock" HorizontalAlignment="Left" Height="62" Margin="10,23,0,0" TextWrapping="Wrap" Text="Use this template to easily drop a working progress bar into your UI" UseLayoutRounding="True" VerticalAlignment="Top" Width="337" Foreground="White" FontSize="18.667"/>
      <Button Name="button" Content="Start" HorizontalAlignment="Left" Height="62" Margin="322,23,0,0" VerticalAlignment="Top" Width="114"/>
      <ProgressBar Name = "ProgressBar" Height = "20" Width = "300" HorizontalAlignment="Left" VerticalAlignment="Top" Margin = "36,244,0,0"/>
    </Grid>
</Window>
"@

    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    $syncHash.Window=[Windows.Markup.XamlReader]::Load( $reader )
    [xml]$XAML = $xaml
        $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | %{
        $syncHash.Add($_.Name,$syncHash.Window.FindName($_.Name) )
    }

    $Script:JobCleanup = [hashtable]::Synchronized(@{})
    $Script:Jobs = [system.collections.arraylist]::Synchronized((New-Object System.Collections.ArrayList))

    $jobCleanup.Flag = $True
    $newRunspace =[runspacefactory]::CreateRunspace()
    $newRunspace.ApartmentState = "STA"
    $newRunspace.ThreadOptions = "ReuseThread"          
    $newRunspace.Open()        
    $newRunspace.SessionStateProxy.SetVariable("jobCleanup",$jobCleanup)     
    $newRunspace.SessionStateProxy.SetVariable("jobs",$jobs) 
    $jobCleanup.PowerShell = [PowerShell]::Create().AddScript({
        Do {    
            Foreach($runspace in $jobs) {            
                If ($runspace.Runspace.isCompleted) {
                    [void]$runspace.powershell.EndInvoke($runspace.Runspace)
                    $runspace.powershell.dispose()
                    $runspace.Runspace = $null
                    $runspace.powershell = $null               
                } 
            }
            #Clean out unused runspace jobs
            $temphash = $jobs.clone()
            $temphash | Where {
                $_.runspace -eq $Null
            } | ForEach {
                $jobs.remove($_)
            }        
            Start-Sleep -Seconds 1     
        } while ($jobCleanup.Flag)
    })
    $jobCleanup.PowerShell.Runspace = $newRunspace
    $jobCleanup.Thread = $jobCleanup.PowerShell.BeginInvoke()  

    $syncHash.button.Add_Click({
            $x+= "."
        $newRunspace =[runspacefactory]::CreateRunspace()
        $newRunspace.ApartmentState = "STA"
        $newRunspace.ThreadOptions = "ReuseThread"          
        $newRunspace.Open()
        $newRunspace.SessionStateProxy.SetVariable("SyncHash",$SyncHash) 
        $PowerShell = [PowerShell]::Create().AddScript({
            Function Update-Window {
              Param (
                $Control,
                $Property,
                $Value,
                [switch]$AppendContent
              )

              # This is kind of a hack, there may be a better way to do this
              If ($Property -eq "Close") {
                $syncHash.Window.Dispatcher.invoke([action]{$syncHash.Window.Close()},"Normal")
                Return
              }

              # This updates the control based on the parameters passed to the function
              $syncHash.$Control.Dispatcher.Invoke([action]{
                  # This bit is only really meaningful for the TextBox control, which might be useful for logging progress steps
                  If ($PSBoundParameters['AppendContent']) {
                    $syncHash.$Control.AppendText($Value)
                  } Else {
                    $syncHash.$Control.$Property = $Value
                  }
              }, "Normal")
            }                        
                                                      

            update-window -Control ProgressBar -Property Value -Value 25

            start-sleep -Milliseconds 850
            update-window -Control ProgressBar -Property Value -Value 50
                                                      
            start-sleep -Milliseconds 500
            update-window -Control ProgressBar -Property Value -Value 75
                                                      
            start-sleep -Milliseconds 200
            update-window -Control ProgressBar -Property Value -Value 100
        
        })
        $PowerShell.Runspace = $newRunspace
        [void]$Jobs.Add((
            [pscustomobject]@{
                PowerShell = $PowerShell
                Runspace = $PowerShell.BeginInvoke()
            }
        ))
    })

    $syncHash.Window.Add_Closed({
        Write-Verbose 'Halt runspace cleanup job processing'
        $jobCleanup.Flag = $False

        $jobCleanup.PowerShell.Dispose()      
    })

    $syncHash.Window.ShowDialog() | Out-Null
    $syncHash.Error = $Error
})
$psCmd.Runspace = $newRunspace
$data = $psCmd.BeginInvoke()
