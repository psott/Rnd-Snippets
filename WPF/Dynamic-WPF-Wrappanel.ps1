
$xaml = @'
<Window
   xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
   Height="400" Width ="400"
   Title="New" Topmost="True">
    <Grid>
        <Button Name="B1" Content="Button" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" Width="75"/>
        <WrapPanel Name="WP" HorizontalAlignment="Stretch" Margin="10,40,10,10" VerticalAlignment="Stretch" Background="#FFB0B0B0" ScrollViewer.CanContentScroll="True" ScrollViewer.VerticalScrollBarVisibility="Auto">
            <StackPanel Width="200" Height="100" Margin="5" Orientation="Horizontal" Background="#FF8FAA89">
                <StackPanel Margin="4">
                    <Button Content="Button 1" Width="90" Height="90"/>
                </StackPanel>
                <StackPanel Margin="4">
                    <Button Content="Button 2" Width="90" Margin="1"/>
                    <Button Content="Button 3" Width="90" Margin="1"/>
                    <Button Content="Button 4" Width="90" Margin="1"/>
                    <Button Content="Button 5" Width="90" Margin="1"/>
                </StackPanel>
            </StackPanel>
        </WrapPanel>
    </Grid>
</Window>
'@

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

$window = Convert-XAMLtoWindow -XAML $xaml 

$window.B1.add_Click{

  $NS = New-Object System.Windows.Controls.StackPanel
  $NS.Width = 200
  $NS.Height = 100
  $NS.Margin = 5
  $NS.Orientation = "Horizontal"
  $NS.Background = "#FF8FAA89"
  $window.WP.AddChild($NS)
  
  $NS2 = New-Object System.Windows.Controls.StackPanel
  $NS2.Margin = 4
  $NS.AddChild($NS2)
  
  $NS3 = New-Object System.Windows.Controls.StackPanel
  $NS3.Margin = 4
  $NS.AddChild($NS3)
  
  $NB = New-Object System.Windows.Controls.Button
  $NB.Height = 90
  $NB.Width = 90
  $NB.Content = 'Button1'
  $NS2.AddChild($NB)
  
  $NB = New-Object System.Windows.Controls.Button
  $NB.Width = 90
  $NB.Margin = 1
  $NB.Content = 'Button2'
  $NS3.AddChild($NB)
  
  $NB = New-Object System.Windows.Controls.Button
  $NB.Width = 90
  $NB.Margin = 1
  $NB.Content = 'Button3'
  $NS3.AddChild($NB)
  
  $NB = New-Object System.Windows.Controls.Button
  $NB.Width = 90
  $NB.Margin = 1
  $NB.Content = 'Button4'
  $NS3.AddChild($NB)
  
  $NB = New-Object System.Windows.Controls.Button
  $NB.Width = 90
  $NB.Margin = 1
  $NB.Content = 'Button5'
  $NS3.AddChild($NB)
  
}


$result = Show-WPFWindow -Window $window
