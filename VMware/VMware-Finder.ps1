$version = '0.1'

$Script:viservers = 'virtualcenter.yourdomain.com'

Add-Type -AssemblyName PresentationFramework

#region Funktionen
function Set-Console
{
  param(
    [switch]$show,
    [switch]$hide
  )
  Add-Type -Name Window -Namespace Console -MemberDefinition '
    [DllImport("Kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
  '
  $consolePtr = [Console.Window]::GetConsoleWindow()
  if($show){
    $null = [Console.Window]::ShowWindow($consolePtr, 1)
  }
  if($hide){
    $null = [Console.Window]::ShowWindow($consolePtr, 0)
  }
}

function Convert-XAMLtoWindow
{
  param
  (
    [Parameter(Mandatory)]
    [string]
    $XAML
  )
  $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
  $result = [Windows.Markup.XAMLReader]::Load($reader)
  [xml]$XmlXaml = $xaml
  $XmlXaml.SelectNodes("//*[@Name]") | ForEach-Object{$result | Add-Member NoteProperty -Name $_.Name -Value $result.FindName($_.Name) -Force}
  $result
}
function Show-WPFWindow
{
  param
  (
    [Parameter(Mandatory)]
    [Windows.Window]
    $Window
  )
  $result = $null
  $null = $window.Dispatcher.InvokeAsync{
    $result = $window.ShowDialog()
    Set-Variable -Name result -Value $result -Scope 1
  }.Wait()
  $result
}
function Write-Info
{
    param(
        [Parameter(Mandatory=$true)][string]$Text,
        [switch]$Exit,
        [switch]$Popup
    )
    if($exit){
        Write-Warning "$text"
        Write-Warning "Programm wird beendet in 5 Sekunden"
        Start-Sleep -Seconds 5
        if((Get-Host).Name -notlike '*ISE*'){exit}
    }
    elseif($Popup){
        $wshell = New-Object -ComObject Wscript.Shell
        $null = $wshell.Popup("$Text",0,"Info",0x0)
    }
    else{
        Write-Host "$text" -ForegroundColor Green
    }
}

function Start-Programm
{
    Clear-Host
    # Credentials abfragen
    Write-Info -Text "Anmeldedaten werden abgerufen"
    $Script:Credentials = Get-Credential -Credential $(whoami)
    if($Script:Credentials -eq $null){
        Write-Info -Text "Keine Anmeldedaten eingegeben" -Exit
    }
    Write-Info -Text "Anmeldedaten erfolgreich gespeichert"

    # snapin laden
    Write-Info -Text "VMware Snapin wird geladen..."
    if ((Get-PSSnapin -Name "VMware.VimAutomation.Core" -ErrorAction SilentlyContinue) -eq $null ){
        try{
            Add-PsSnapin VMware.VimAutomation.Core -ErrorAction Stop
        }
        catch{
            Write-Info -Text "VMware Snapin konnte nicht geladen werden" -Exit
        }
    }
    Write-Info -Text "VMware Snapin erfolgreich geladen"
    
    #console verstecken
    Set-Console -hide
    
    $window.PB.Maximum = $Script:viservers.count
    $window.TBlog.Text = 'Programm erfolgreich geladen'
}
function Update-Window
{
    $window.Dispatcher.Invoke([Action]{},'Render')
}

function Connect-MyVIServer
{
    param(
        [string]$Server
    )
    try{
        Connect-VIServer -Server $Server -Credential $Script:Credentials -ErrorAction Stop
        $region = ($Server.Split('.')[1]).Substring(($Server.Split('.')[1]).Length -1).ToUpper()
        $window.TBlog.Text = "Suche in Region $region ($Server) ..."
        Write-Output $true
    }
    catch{
        Write-Info -Text "Es konnte keine Verbindung zu $Server hergestellt werden" -Popup
        Write-Output $false
    }
    Update-Window
}
function Disconnect-MyVIServer
{
    param(
        [string]$Server
    )
    Disconnect-VIServer -Server $Server -confirm:$false -ErrorAction SilentlyContinue
}

function Search-Data
{
    $window.LVdata.Items.Clear()
    $servercount = 0
    Set-PB -value 0
    $window.TaskbarItemInfo.ProgressState = 'Normal'

    $suchfeld = ($window.TBsuche.Text).Trim()
    if($suchfeld -ne ''){
        foreach($viserver in $viservers){
            if(Connect-MyVIServer -Server $viserver){
                $region = ($viserver.Split('.')[1]).Substring(($viserver.Split('.')[1]).Length -1).ToUpper()
                if($window.RBvm.IsChecked){
                    Get-View -ViewType VirtualMachine -Filter @{"Name"="$suchfeld"} -Property Name | foreach{
                        $co = [pscustomobject]@{
                            Name = $_.Name
                            Region = $region
                            Server = $viserver
                        }
                        $window.LVdata.AddChild($co)
                        Update-Window
                    }
                }
                elseif($window.RBhost.IsChecked){
                    Get-View -ViewType HostSystem -Filter @{"Name"="$suchfeld"} -Property Name | foreach{
                        $co = [pscustomobject]@{
                            Name = $_.Name
                            Region = $region
                            Server = $viserver
                        }
                        $window.LVdata.AddChild($co)
                        Update-Window
                    }
                }
                elseif($window.RBdatastore.IsChecked){
                    Get-View -ViewType Datastore -Filter @{"Name"="$suchfeld"} -Property Name | foreach{
                        $co = [pscustomobject]@{
                            Name = $_.Name
                            Region = $region
                            Server = $viserver
                        }
                        $window.LVdata.AddChild($co)
                        Update-Window
                    }
                }
                Disconnect-MyVIServer -Server $viserver
            }
            $servercount++
            Set-PB -value $servercount
            Update-Window
        }
        $anzahl = 0
        $anzahl = $window.LVdata.Items.Count
        $window.TaskbarItemInfo.ProgressState = 'None'
        $window.TBlog.Text = "Suche abgeschlossen ($anzahl Objekte gefunden)"
    }
    else{
        Write-Info -Text "Das Suchfeld ist leer." -Popup
    }
}

function Export-Data
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $ofd = New-Object System.Windows.Forms.SaveFileDialog
    $ofd.initialDirectory = $env:UserProfile
    $ofd.filter = "CSV (*.csv)| *.csv"
    $ofd.FileName = 'VMwareFinderExport.csv'
    $result =$ofd.ShowDialog()
    if($result -eq 'OK'){
        $window.LVdata.Items | Export-Csv -Path $ofd.FileName -Delimiter ';' -NoTypeInformation
    }
}

function Set-PB
{
    param(
        [int]$value
    )
    $window.PB.Value = $value
    $window.TaskbarItemInfo.ProgressValue = ($value/$window.PB.Maximum)
}
#endregion

#region XAML
$xaml = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    Height="300" Width ="600"
    Title="VMware Finder"
    WindowStartupLocation="CenterScreen">
    <Window.TaskbarItemInfo>
        <TaskbarItemInfo/>
    </Window.TaskbarItemInfo>
     <Grid>
         <TextBox Name="TBsuche" HorizontalAlignment="Stretch" Height="23" Margin="10,10,100,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top"/>
         <Button Name="Bsuche" Content="Suchen" HorizontalAlignment="Right" Margin="0,10,10,0" VerticalAlignment="Top" Width="75" Height="23"/>
         <RadioButton Name="RBvm" Content="VM" HorizontalAlignment="Left" Margin="10,38,0,0" VerticalAlignment="Top" IsChecked="True"/>
         <RadioButton Name="RBhost" Content="Host" HorizontalAlignment="Left" Margin="114,38,0,0" VerticalAlignment="Top"/>
         <RadioButton Name="RBdatastore" Content="DataStore" HorizontalAlignment="Left" Margin="216,38,0,0" VerticalAlignment="Top"/>

         <ListView Name="LVdata" HorizontalAlignment="Stretch" Margin="10,60,10,70" VerticalAlignment="Stretch">
             <ListView.View>
                 <GridView>
                     <GridViewColumn Header="Name" DisplayMemberBinding="{Binding 'Name'}" Width="200"/>
                     <GridViewColumn Header="Region" DisplayMemberBinding="{Binding 'Region'}" Width="50"/>
                     <GridViewColumn Header="Server" DisplayMemberBinding="{Binding 'Server'}" Width="280"/>
                 </GridView>
             </ListView.View>
         </ListView>
         <TextBlock Name="TBlog" HorizontalAlignment="Left" Margin="10,0,10,40" VerticalAlignment="Bottom"/>
         <Button Name="Bexport" Content="Export" HorizontalAlignment="Right" Margin="0,0,10,40" VerticalAlignment="Bottom" Width="75"/>
         <ProgressBar Name="PB" Minimum="0" Maximum="100" Value="0" HorizontalAlignment="Stretch" Margin="10,0,10,10" VerticalAlignment="Bottom" Height="20"/>
     </Grid>
</Window>
'@
#endregion

$window = Convert-XAMLtoWindow -XAML $xaml #-PassThru

#region Aktionen
$window.Bsuche.add_Click{
    Search-Data
}
$window.Bexport.add_Click{
    Export-Data
}
#endregion

$Window.Add_ContentRendered{  
    #nix
}

Start-Programm
$result = Show-WPFWindow -Window $window
if($Host.Name -notlike '*ISE*'){
  Stop-Process -Id $PID
}
