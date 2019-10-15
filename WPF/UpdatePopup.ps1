#region XAML window definition
# Right-click XAML and choose WPF/Edit... to edit WPF Design
# in your favorite WPF editing tool
$xaml = @'
<Window
   xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"

   Width ="400"
   Title="Update wird ausgeführt" SizeToContent="Height"
   Topmost="True" WindowStyle="None" Name="win" WindowStartupLocation="CenterScreen">
    <Grid Name="grid">
        <Border BorderBrush="Black" BorderThickness="1" HorizontalAlignment="Center" Margin="10" VerticalAlignment="Top" Height="100" Width="100">
            <TextBlock HorizontalAlignment="Center" TextWrapping="Wrap" Text="logo" VerticalAlignment="Center"/>
        </Border>
        <TextBlock Name="Message" TextAlignment="Center" HorizontalAlignment="Stretch" Margin="10,120,10,10" Padding="5" TextWrapping="Wrap" Text="Google Chrome wird aktualisiert" VerticalAlignment="Stretch" FontSize="18" Background="#FFE6E6E6"/>
    </Grid>
</Window>
'@
#endregion

#region Code Behind
function Convert-XAMLtoWindow
{
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $XAML
  )
  
  Add-Type -AssemblyName PresentationFramework
  
  $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
  $result = [Windows.Markup.XAMLReader]::Load($reader)
  $reader.Close()
  $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
  while ($reader.Read())
  {
      $name=$reader.GetAttribute('Name')
      if (!$name) { $name=$reader.GetAttribute('x:Name') }
      if($name)
      {$result | Add-Member NoteProperty -Name $name -Value $result.FindName($name) -Force}
  }
  $reader.Close()
  $result
}

function Show-WPFWindow
{
  param
  (
    [Parameter(Mandatory=$true)]
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
#endregion Code Behind

#region Convert XAML to Window
$window = Convert-XAMLtoWindow -XAML $xaml 
$window.win.add_MouseDoubleClick{
  $window.Close()
}

$window.win.add_MouseDown{
  $window.DragMove()
}

$text = "Google Chrome wird aktualisiert.`nBitte warten Sie."

$window.Message.Text = $text

$result = Show-WPFWindow -Window $window
