function Join-File {
    param(
        [string]$infilePrefix
    )
    $fileinfo = [System.IO.FileInfo]$infilePrefix
    $outFile = Join-Path $fileinfo.Directory $fileinfo.BaseName
    $ostream = [System.Io.File]::OpenWrite($outFile)
    $chunkNum = 1
    $infileName = "$infilePrefix$chunkNum"

    while (Test-Path $infileName) {
        $bytes = [System.IO.File]::ReadAllBytes($infileName)
        $ostream.Write($bytes, 0, $bytes.Count)
        Write-Host "Read $infileName"
        $chunkNum += 1
        $infileName = "$infilePrefix$chunkNum"
    }

    $ostream.close()
}

Join-File -infilePrefix "U:\Download\File.exe.part"
