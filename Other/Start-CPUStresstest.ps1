#2147483647

#4 Threasds
1..4 | foreach{

    Start-Job -ScriptBlock {
      Start-Sleep -Seconds 3
      $result = 1
      foreach ($number in 1..21474831) {
        $result = $result * $number
      }
    }

}

Get-Job | Stop-Job
Get-Job | Remove-Job
