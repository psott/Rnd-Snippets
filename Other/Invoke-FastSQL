function Invoke-FastSQL
{
  param
  (
    [String][Parameter(Mandatory)]
    $Query,
    [String][Parameter(Mandatory)]
    $Database,
    [String][Parameter(Mandatory)]
    $Server
  )
  $sqlc = New-Object System.Data.SqlClient.SqlConnection
  $sqlc.ConnectionString = "Server=$Server;Database=$Database;Integrated Security=True"
  $sqlc.Open()

  $sqlda = New-Object System.Data.SqlClient.SqlDataAdapter
  $sqlcs = New-Object System.Data.SqlClient.SqlCommand
  $sqlcs.CommandText = $Query
  $sqlcs.Connection = $sqlc
  $sqlda.SelectCommand = $sqlcs

  $sqlds = New-Object System.Data.DataSet
  $null = $sqlda.Fill($sqlds)
  $data = $sqlds.Tables[0]
  $sqlc.Close()
  Write-Output $data -NoEnumerate
}
