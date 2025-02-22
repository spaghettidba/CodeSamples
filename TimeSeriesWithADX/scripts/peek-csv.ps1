get-childitem C:\temp\export\ -File |
    ForEach-Object {
        $currentFile = $_.FullName
        #$currentFile
        Get-Content $_.FullName | Select -First 2 | ConvertFrom-Csv | Select @{n="filename";e={$currentfile}}, time
    }
    | Sort-Object time
    | Out-GridView