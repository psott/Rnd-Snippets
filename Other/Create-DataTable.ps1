cls
$cdt = Measure-Command{
  Write-Host "create DataTable..."
  $dt = New-Object -TypeName System.Data.DataTable
  [void]$dt.Columns.Add('Name', [string])
  [void]$dt.Columns.Add('CPU', [int])
  [void]$dt.Columns.Add('RAM', [int])
  [void]$dt.Columns.Add('HDD', [int])
  [void]$dt.Columns.Add('OS', [string])
  [void]$dt.Columns.Add('Type', [string])

  1..100000 | ForEach-Object {
    [void]$dt.Rows.Add(
      ("Server$_"),
      (1,2,4,8,12,16,24 | Get-Random),
      (2,4,8,12,16,24,32,64,128,256 | Get-Random),
      (60,80,100,200,400,1000 | Get-Random),
      ('Windows Server ' + (2008,'2008R2',2012,2016 | Get-Random)),
      ('SQL','DC','DHCP','DNS' | Get-Random)
    )
  }
} | select -ExpandProperty TotalMilliseconds

$cco = Measure-Command{
  Write-Host "create pscustomobject..."
  $psco =  1..100000 | foreach{
    [pscustomobject]@{
      Name = "Server$_"
      CPU = 1,2,4,8,12,16,24 | Get-Random
      RAM = 2,4,8,12,16,24,32,64,128,256 | Get-Random
      HDD = 60,80,100,200,400,1000 | Get-Random
      OS = 'Windows Server ' + (2008,'2008R2',2012,2016 | Get-Random)
      Type = 'SQL','DC','DHCP','DNS' | Get-Random
    }
  }
} | select -ExpandProperty TotalMilliseconds


$a = Measure-Command{
  foreach($o in $psco){if($o.CPU -eq 8 -and $o.Type -eq 'DC'){$o}}
} | select -ExpandProperty TotalMilliseconds

$b = Measure-Command{
  $dt.Select("CPU=8 and Type='DC'")
} | select -ExpandProperty TotalMilliseconds

Write-Host "time to create pscustomobject: $cco"
Write-Host "foreach() - $a"
Write-Host ''
Write-Host "time to create datatable: $cdt"
Write-Host "DataTable.Select. - $b"
