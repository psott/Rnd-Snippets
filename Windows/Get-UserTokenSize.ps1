function Get-UserTokenSize {
  param (
    [Parameter(Mandatory=$true)]
    [array]$Principals,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet(7600,9200,10586)]
    [Int]$OSBuild
  )

  $ExportPath = 'C:\Temp'
  
  if(!(Test-Path -Path $ExportPath)){
    New-Item -Name Temp -Path C:\ -ItemType Directory
  }
  
  if(!(Test-Path -Path "$ExportPath\GroupDetails")){
    New-Item -Name GroupDetails -Path $ExportPath -ItemType Directory
  }
  if(!(Test-Path -Path "$ExportPath\GroupSIDHistoryDetails")){
    New-Item -Name GroupSIDHistoryDetails -Path $ExportPath -ItemType Directory
  }
  if(!(Test-Path -Path "$ExportPath\UserSIDHistoryDetails")){
    New-Item -Name UserSIDHistoryDetails -Path $ExportPath -ItemType Directory
  }
  function Get-SIDHistorySIDs 
  {     
    param (
      [string]$objectname
    ) 

    $DomainInfo = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain() 
    $RootString = "LDAP://" + $DomainInfo.Name 
    $Root = New-Object  System.DirectoryServices.DirectoryEntry($RootString) 
    $searcher = New-Object DirectoryServices.DirectorySearcher($Root) 
    $searcher.Filter="(|(userprincipalname=$objectname)(name=$objectname))" 
    $results=$searcher.findone() 
    if ($results -ne $null) { 
      $SIDHistoryResults = $results.properties.sidhistory 
    } 

    $SIDHistorySids = @() 
    foreach ($SIDHistorySid in $SIDHistoryResults) { 
      $SIDString = (New-Object System.Security.Principal.SecurityIdentifier($SIDHistorySid,0)).Value 
      $SIDHistorySids += $SIDString 
    } 
    return $SIDHistorySids 
  } 
 
  foreach ($Principal in $Principals) { 

    $UserIdentity = New-Object System.Security.Principal.WindowsIdentity($Principal) 
    $Groups = $UserIdentity.get_Groups() 
    $DomainSID = $UserIdentity.User.AccountDomainSid 
    $GroupCount = $Groups.Count 

    $GroupDetails = @()

    $AllGroupSIDHistories = @() 
    $SecurityGlobalScope  = 0 
    $SecurityDomainLocalScope = 0 
    $SecurityUniversalInternalScope = 0 
    $SecurityUniversalExternalScope = 0 
   
    foreach ($GroupSid in $Groups){      
      $Group = [adsi]"LDAP://<SID=$GroupSid>" 
      $GroupType = $Group.groupType 
      if ($Group.name -ne $null) 
      { 
        $SIDHistorySids = Get-SIDHistorySIDs $Group.name 
        If (($SIDHistorySids | Measure-Object).Count -gt 0)  
        {$AllGroupSIDHistories += $SIDHistorySids} 
        $GroupName = $Group.name.ToString() 
       
        #Resolve SIDHistories if possible to give more detail. 
        if ($SIDHistorySids -ne $null) 
        { 
          $GroupSIDHistoryDetails = @()
          foreach ($GroupSIDHistory in $AllGroupSIDHistories) 
          { 
            $SIDHistGroup = New-Object System.Security.Principal.SecurityIdentifier($GroupSIDHistory) 
            $SIDHistGroupName = $SIDHistGroup.Translate([System.Security.Principal.NTAccount]) 
            $GroupSIDHISTString = $GroupName + "--> " + $SIDHistGroupName 

            $GroupSIDHistoryDetails += [pscustomobject]@{
              GroupSIDHistory = $GroupSIDHistory
              GroupSIDHISTString = $GroupSIDHISTString
            }
          } 
        }
      } 
                   
      #Count number of security groups in different scopes. 
      switch -exact ($GroupType) {
        "-2147483646" { 
          #Domain Global scope 
          $SecurityGlobalScope++

          $GroupDetails += [pscustomobject]@{
            GroupName = ($GroupName + " (" + ($GroupSID.ToString()) + ")")
            GroupType = 'Domain Global Group'
          }
        }
        "-2147483644" { 
          #Domain Local scope 
          $SecurityDomainLocalScope++ 

          $GroupDetails += [pscustomobject]@{
            GroupName = ($GroupName + " (" + ($GroupSID.ToString()) + ")" )
            GroupType = 'Domain Local Group'
          }
        } 
        "-2147483640" { 
          #Universal scope; must separate local 
          #domain universal groups from others. 
          if ($GroupSid -match $DomainSID) 
          { 
            $SecurityUniversalInternalScope++ 

            $GroupDetails += [pscustomobject]@{
              GroupName = $GroupName + " (" + ($GroupSID.ToString()) + ")" 
              GroupType = 'Local Universal Group'
            }
          } 
          else 
          { 
            $SecurityUniversalExternalScope++ 

            $GroupDetails += [pscustomobject]@{
              GroupName = $GroupName + " (" + ($GroupSID.ToString()) + ")" 
              GroupType = 'External Universal Group'
            }
          } 
        } 
      } 
 
    } 
 
    $SIDHistoryResults = Get-SIDHistorySIDs $Principal 
    $SIDCounter = $SIDHistoryResults.count 
    
    if ($SIDHistoryResults -ne $null) 
    { 
      $UserSIDHistoryDetails = @()
      foreach ($SIDHistory in $SIDHistoryResults) 
      { 
        $SIDHist = New-Object System.Security.Principal.SecurityIdentifier($SIDHistory) 
        $SIDHistName = $SIDHist.Translate([System.Security.Principal.NTAccount]) 

        $UserSIDHistoryDetails += [pscustomobject]@{
          SIDHistName = $SIDHistName
          SIDHistory = $SIDHistory
        }
      } 
    } 
                         
    $GroupSidHistoryCounter = $AllGroupSIDHistories.Count  
    $AllSIDHistories = $SIDCounter  + $GroupSidHistoryCounter 
  
    $TokenSize = 0 
    $TokenSize = 1200 + (40 * ($SecurityDomainLocalScope + $SecurityUniversalExternalScope + $GroupSidHistoryCounter)) + (8 * ($SecurityGlobalScope  + $SecurityUniversalInternalScope)) 
    $DelegatedTokenSize = 2 * (1200 + (40 * ($SecurityDomainLocalScope + $SecurityUniversalExternalScope + $GroupSidHistoryCounter)) + (8 * ($SecurityGlobalScope  + $SecurityUniversalInternalScope)))      

    $Username = $UserIdentity.name 
    $UserNameShort = $Username.Split('\')[1]
    
    
    
    $PrincipalsDomain = $Username.Split('\')[0] 

    if(!(Test-Path -Path "$ExportPath\GroupDetails\$PrincipalsDomain")){
      New-Item -Name $PrincipalsDomain -Path "$ExportPath\GroupDetails" -ItemType Directory
    }
    if(!(Test-Path -Path "$ExportPath\GroupSIDHistoryDetails\$PrincipalsDomain")){
      New-Item -Name $PrincipalsDomain -Path "$ExportPath\GroupSIDHistoryDetails" -ItemType Directory
    }
    if(!(Test-Path -Path "$ExportPath\UserSIDHistoryDetails\$PrincipalsDomain")){
      New-Item -Name $PrincipalsDomain -Path "$ExportPath\UserSIDHistoryDetails" -ItemType Directory
    }

    $KerbKey = Get-Item -Path Registry::HKLM\SYSTEM\CurrentControlSet\Control\LSA\Kerberos\Parameters 
    $MaxTokenSizeValue = $KerbKey.GetValue('MaxTokenSize') 
    if ($MaxTokenSizeValue -eq $null) { 
      if ($OSBuild -lt 9200) {$MaxTokenSizeValue = 12000} 
      if ($OSBuild -ge 9200) {$MaxTokenSizeValue = 48000} 
    }

    $ProblemDetected = $false 
    $ProblemDetails = ''
    if (($OSBuild -lt 9200) -and (($Tokensize -ge 12000) -or ((($Tokensize -gt $MaxTokenSizeValue) -or ($DelegatedTokenSize -gt $MaxTokenSizeValue)) -and ($MaxTokenSizeValue -ne $null)))) 
    { 
      $ProblemDetected = $true
      $ProblemDetails = "Problem detected. The token was too large for consistent authorization. Alter the maximum size per KB http://support.microsoft.com/kb/327825 and consider reducing direct and transitive group memberships."
    } 
    elseif ((($OSBuild -eq 9200) -or ($OSBuild -eq 9600)) -and (($Tokensize -ge 48000) -or ((($Tokensize -gt $MaxTokenSizeValue) -or ($DelegatedTokenSize -gt $MaxTokenSizeValue)) -and ($MaxTokenSizeValue -ne $null)))) 
    { 
      $ProblemDetected = $true
      $ProblemDetails = "Problem detected. The token was too large for consistent authorization. Alter the maximum size per KB http://support.microsoft.com/kb/327825 and consider reducing direct and transitive group memberships."
    } 
    elseif (($OSBuild -eq 10586) -and (($Tokensize -ge 65535) -or ((($Tokensize -gt $MaxTokenSizeValue) -or ($DelegatedTokenSize -gt $MaxTokenSizeValue)) -and ($MaxTokenSizeValue -ne $null)))) 
    { 
      $ProblemDetected = $true
      $ProblemDetails = "WARNING: The token was large enough that it may have problems when being used for Kerberos delegation or for access to Active Directory domain controller services. Alter the maximum size per KB http://support.microsoft.com/kb/327825 and consider reducing direct and transitive group memberships."
    } 
    
    if($GroupDetails -ne $null){
      $GroupDetails | Export-Csv -Path "$ExportPath\GroupDetails\$PrincipalsDomain\$UserNameShort.csv" -UseCulture -NoTypeInformation -Encoding UTF8
    }
    if($GroupSIDHistoryDetails -ne $null){
      $GroupSIDHistoryDetails | Export-Csv -Path "$ExportPath\GroupSIDHistoryDetails\$PrincipalsDomain\$UserNameShort.csv" -UseCulture -NoTypeInformation -Encoding UTF8
    }
    if($UserSIDHistoryDetails -ne $null){
      $UserSIDHistoryDetails | Export-Csv -Path "$ExportPath\UserSIDHistoryDetails\$PrincipalsDomain\$UserNameShort.csv" -UseCulture -NoTypeInformation -Encoding UTF8
    }

    [pscustomobject]@{
      UserName = $Username
      Domain = $PrincipalsDomain
      TokenSize = $Tokensize
      DelegatedTokenSize = $DelegatedTokenSize
      EffectiveMaxTokenSizeValue = $Maxtokensizevalue
      ProblemDetected = $ProblemDetected
      ProblemDetails = $ProblemDetails
      GroupCount = $GroupCount
      SIDCounter = $SIDCounter
      GroupSidHistoryCounter = $GroupSidHistoryCounter
      AllSIDHistories = $AllSIDHistories
      SecurityGlobalScope = $SecurityGlobalScope
      SecurityDomainLocalScope = $SecurityDomainLocalScope
      SecurityUniversalInternalScope = $SecurityUniversalInternalScope
      SecurityUniversalExternalScope = $SecurityUniversalExternalScope
    } | Export-Csv -Path "$ExportPath\UserTokenSize.csv" -UseCulture -NoTypeInformation -Encoding UTF8 -Append
  }
}
