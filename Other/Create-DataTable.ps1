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
