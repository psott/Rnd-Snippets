foreach($FolderP in Get-ChildItem -Path 'C:\Program Files (x86)' -Directory -Recurse){
    Write-Host $FolderP.FullName -ForegroundColor Green
    $FolderACL = Get-Acl -Path $FolderP.FullName

    #FileSystemRights  : -1610612736
    #AccessControlType : Allow
    #IdentityReference : ZERTIFIZIERUNGSSTELLE FÜR ANWENDUNGSPAKETE\ALLE EINGESCHRÄNKTEN ANWENDUNGSPAKETE
    #IsInherited       : True
    #InheritanceFlags  : ContainerInherit, ObjectInherit
    #PropagationFlags  : InheritOnly

    foreach($a in $FolderACL.Access){
        if($a.IdentityReference.Value -in $acl.Access.IdentityReference.Value){
            $p = $acl.Access | where{$_.IdentityReference.Value -eq $a.IdentityReference.Value}
        }
        else{
            Write-Host "$($FolderP.FullName) - $($a.IdentityReference.Value) nicht gefunden" -ForegroundColor Red
        }
    }

    if(Compare-Object $acl.Access $FolderACL.Access){
        Write-Host "unterschied" -ForegroundColor Yellow
        #$FolderACL.Access | ogv
    }
    else{
        Write-Host "alles ok"
    }
}
