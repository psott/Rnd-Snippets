function Split-Object
{
  param(
    [Parameter(Mandatory)]
    $Objects,
    [Parameter(Mandatory)]
    [Int]$PartCount
  )
  $Array = $null
  for ($i = 0; $i -lt $Objects.count; $i += $PartCount) {
     $Array += ,@($Objects[$i..($i+($PartCount-1))]);
  }
  Write-Output $Array
}
