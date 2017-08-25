function Convert-XAMLtoWindow
{
  param(
    [Parameter(Mandatory=$true)]
    [string]
    $XAML
  )
  Add-Type -AssemblyName PresentationFramework
  $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
  $result = [Windows.Markup.XAMLReader]::Load($reader)
  $reader.Close()
  $reader = [XML.XMLReader]::Create([IO.StringReader]$XAML)
  while ($reader.Read()){
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
  param(
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
$xaml = @'
<Window
   xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
   Height="500" Width ="500"
   Title="New" Topmost="True">
    <Grid>

    </Grid>
</Window>
'@

$window = Convert-XAMLtoWindow -XAML $xaml 


$result = Show-WPFWindow -Window $window
