$fp = "C:\FilePath"

$out = Get-ChildItem -Path $fp -Recurse | foreach{
    if($_.Extension -in '.ps1','.psd1','.psm1','.config'){
        $reader = [System.IO.StreamReader]::new($_.Fullname, [System.Text.Encoding]::default,$true)
        $peek = $reader.Peek()
        $encoding = $reader.currentencoding
        $reader.close()

        [PSCustomObject]@{
            Name = $_.Fullname
            BodyName = $encoding.BodyName
            EncodingName = $encoding.EncodingName
        }
    }

}

$out | ogv
