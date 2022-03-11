
$files = @()
Get-ChildItem -Path $env:USERPROFILE\downloads |
    Where-Object { $_.Length -gt 1kb -and $_.Length -lt 1MB} | 
    ForEach-Object {
        $currentFile = $_
        $files += New-Object PSCustomObject -Property @{
            file_name = $currentFile.Name;
            description = $currentFile.FullName;
            tags = "Some,Tags,Go,Here";
            date_created = $currentFile.CreationTime;
            date_modified = $currentFile.LastWriteTime;
            contents = (Get-Content $currentFile.FullName -AsByteStream -Raw)
        }
    }


$files | Write-DbaDataTable -sqlInstance "QDSRV05" -Database "PICTURES" -Table "PicturesSmall"






$files = @()
Get-ChildItem -Path $env:USERPROFILE\downloads |
    Where-Object { $_.Length -gt 1MB -and $_.Length -lt 1GB} | 
    ForEach-Object {
        $currentFile = $_
        $files += New-Object PSCustomObject -Property @{
            file_name = $currentFile.Name;
            description = $currentFile.FullName;
            tags = "Some,Tags,Go,Here";
            date_created = $currentFile.CreationTime;
            date_modified = $currentFile.LastWriteTime;
            contents = (Get-Content $currentFile.FullName -AsByteStream -Raw)
        }
    }


$files | Write-DbaDataTable -sqlInstance "QDSRV05" -Database "PICTURES" -Table "PicturesBig"

