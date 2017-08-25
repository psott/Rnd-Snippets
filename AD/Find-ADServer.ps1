$domains = (Get-ADForest).domains
$domains |foreach{ 
    $d = $_.split('.')
    $cn = "DC=" + $d[0] + ",DC=" + $d[1] + ",DC=" + $d[2]
    try{
        Get-ADComputer -Filter {primaryGroupID -eq '516'} -SearchBase $cn -Server $_ -ErrorAction Stop
        Write-Host "$cn - $_" -ForegroundColor Green
    }
    catch{
        Write-Host "$cn" -ForegroundColor Red
    }
} | Out-GridView -PassThru
