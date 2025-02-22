Get-Date

    $BatchSize = 1000000


    Get-Content "C:\temp\export\sqlserver_performance.csv" |
    ForEach-Object -Begin {
        $Index = 0
    } -Process {
        if( $Index -eq 0) {
            $Headers = $_
        }
        if ($Index % $BatchSize -eq 0) {
            $BatchNr = [math]::Floor($Index++/$BatchSize)
            if( $Index -gt 1 ) {
                $Headers | Out-File -Path "c:\temp\export\sqlserver_performance_$BatchNr.csv" -Encoding utf8 
            }
            $Pipeline = { Out-File -Path "c:\temp\export\sqlserver_performance_$BatchNr.csv" -Encoding utf8 -Append }.GetSteppablePipeline()
            $Pipeline.Begin($True)
        }
        $Pipeline.Process($_)
        if ($Index++ % $BatchSize -eq 0) { $Pipeline.End() }
    } -End {
        if($Pipeline) { try {$Pipeline.End()} catch { "Cant end pipeline" } }
    }


Get-Date

