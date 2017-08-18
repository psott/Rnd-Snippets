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
    <Button Name="b1" Content="klick" VerticalAlignment="Top" HorizontalAlignment="Left"/>
      <TreeView Name="tree" Margin="5,40,5,5" VerticalAlignment="Stretch" HorizontalAlignment="Stretch">
        
        <TreeViewItem>
          <TreeViewItem.Header>
            <StackPanel Orientation="Horizontal">
              <Rectangle Width="10" Height="10" Fill="Green" Margin="0,0,5,0"/>
              <TextBlock Text="Server 1"/>
            </StackPanel>
          </TreeViewItem.Header>
        </TreeViewItem>

      </TreeView>
    </Grid>
</Window>
'@

$window = Convert-XAMLtoWindow -XAML $xaml 

$window.b1.add_Click{
  $tvi = New-Object System.Windows.Controls.TreeViewItem
  
  $sp = New-Object System.Windows.Controls.StackPanel
  $sp.Orientation = "Horizontal"
    
  $rec = New-Object System.Windows.Shapes.Rectangle 
  $rec.Width = 10
  $rec.Height = 10
  $rnd = 'Green','Red','Yellow' | Get-Random
  $rec.Fill = $rnd
  $rec.Margin = "0,0,5,0"
  $sp.AddChild($rec)
  
  $tb = New-Object System.Windows.Controls.TextBlock
  $tb.Text = "Server 2"
  $sp.AddChild($tb)
  
  $tvi.Header = $sp
  $tvi.Uid = 1
  $window.tree.Items.Add($tvi) 
  
  #'vm1','vm2','vm3' | foreach{
  #  ($window.tree.Items | where{$_.Uid -eq 1}).addChild($_)
  #}
}

$result = Show-WPFWindow -Window $window
