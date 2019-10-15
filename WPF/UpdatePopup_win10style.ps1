#region XAML window definition
# Right-click XAML and choose WPF/Edit... to edit WPF Design
# in your favorite WPF editing tool
$xaml = @'
<Window
   xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"

   xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"

   Title="Update wird ausgeführt" SizeToContent="Height" Width="2000" ResizeMode="NoResize" AllowsTransparency="True"
   Topmost="True" WindowStyle="None" x:Name="win" WindowStartupLocation="CenterScreen" VerticalAlignment="Stretch" Background="{x:Null}">
    <Grid x:Name="grid">
        <TextBlock x:Name="Message"  TextAlignment="Center" HorizontalAlignment="Stretch" Padding="20" TextWrapping="Wrap" Text="Google Chrome wird aktualisiert, bitte warten." VerticalAlignment="Stretch" FontSize="26" Foreground="White" Background="#B27593E4"/>
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


$text = "Google Chrome wird aktualisiert.`nBitte warten Sie."

$window.Message.Text = $text

$result = Show-WPFWindow -Window $window
