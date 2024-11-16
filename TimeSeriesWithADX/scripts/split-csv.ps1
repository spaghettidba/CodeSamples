

function get-SeriesData($series) {
    $Columns = $series.columns
    foreach($value in $series.values) {
        $properties = New-Object System.Collections.Specialized.OrderedDictionary

        # first add the time column
        if($columns -contains "time") {
            $properties.time = $null
        }

        # then add tags
        foreach($tag in $series.tags.PSObject.Properties) {
            $properties[$tag.Name] = $Tag.Value
        }

        # then add fields
        for($i = 0; $i -lt $Columns.Length; $i++) {

            if ($Columns[$i] -eq 'time') {
                $properties.time = [DateTime]$value[$i]
            } else {
                $properties[$columns[$i]] = $value[$i]
            }
        }

        New-Object PSObject -Property $properties
    }
}
    




if(-not $credential) { $credential = get-credential }
$query = "SELECT * FROM standard.sqlserver_performance WHERE time > now() - 1h LIMIT 10000"
#$query = "SHOW DATABASES"
$Database = "geox"
$Url = "http://localhost:8686/query?db=$Database"
Add-Type -AssemblyName System.Web
$queryEncoded = [System.Web.HttpUtility]::UrlEncode($query) 
$method = "get"
$param = @{
    Uri = "$Url&q=$queryEncoded&chunked=true&chunk_size=20000"
    Credential = $credential 
    Headers = @{"Accept"="application/json"}
}
if((get-command Invoke-RestMethod).Parameters["AllowUnencryptedAuthentication"]){
    $param.Add("AllowUnencryptedAuthentication", $true)
}

$BatchSize = 10000

Get-Date

Invoke-RestMethod @param -Method $method | 
    Select @{n="series";e={$_.results.series}} | 
    ForEach-Object { get-seriesdata($_.series) } |
    ForEach-Object -Begin {
        $Index = 0
    } -Process {
        if ($Index % $BatchSize -eq 0) {
            $BatchNr = [math]::Floor($Index++/$BatchSize)
            $Pipeline = { Export-Csv -notype -Path "E:\export\geox\sqlserver_performance_$BatchNr.csv" -Encoding UTF8 }.GetSteppablePipeline()
            $Pipeline.Begin($True)
        }
        $Pipeline.Process($_)
        if ($Index++ % $BatchSize -eq 0) { $Pipeline.End() }
    } -End {
        if($Pipeline) { try {$Pipeline.End()} catch { "Cant end pipeline" } }
    }


Get-Date

