function Compare-Object2
{            
    param(            
        [psobject[]]$ReferenceObject,            
        [psobject[]]$DifferenceObject,            
        [switch]$IncludeEqual,            
        [switch]$ExcludeDifferent
    )                       
    $DifHash = @{}            
    $DifferenceObject | ForEach-Object {$DifHash.Add($_,$null)}            
    Remove-Variable -Name DifferenceObject            
              
    $RefHash = @{}            
    for ($i=0;$i -lt $ReferenceObject.Count;$i++) {            
        $RefHash.Add($ReferenceObject[$i],$null)            
    }            
           
    If ($IncludeEqual) {            
        $EqualHash = @{}            
           
        ForEach ($Item in $ReferenceObject) {            
            If ($DifHash.ContainsKey($Item)) {            
                $DifHash.Remove($Item)            
                $RefHash.Remove($Item)            
                $EqualHash.Add($Item,$null)            
            }            
        }            
    } Else {            
        ForEach ($Item in $ReferenceObject) {            
            If ($DifHash.ContainsKey($Item)) {            
                $DifHash.Remove($Item)            
                $RefHash.Remove($Item)            
            }            
        }            
    }            
            
    If ($IncludeEqual) {            
        $EqualHash.Keys | Select-Object @{Name='InputObject';Expression={$_}},`
            @{Name='SideIndicator';Expression={'=='}}            
    }            
            
    If (-not $ExcludeDifferent) {            
        $RefHash.Keys | Select-Object @{Name='InputObject';Expression={$_}},`
            @{Name='SideIndicator';Expression={'<='}}            
        $DifHash.Keys | Select-Object @{Name='InputObject';Expression={$_}},`
            @{Name='SideIndicator';Expression={'=>'}}            
    }            
}  
