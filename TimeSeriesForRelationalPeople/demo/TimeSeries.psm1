

function Invoke-InfluxQLCmd {
    param(
        [Parameter()]
        [string]$Query,
        [Parameter()]
        [string]$Database,
        [Parameter()]
        [string]$method = "get"
    )
    Process {
        $Url = "http://localhost:8086/query?db=$Database"
        Add-Type -AssemblyName System.Web
        $queryEncoded = [System.Web.HttpUtility]::UrlEncode($query) 

        $param = @{
            Uri = "$Url&q=$queryEncoded"
            Credential = $credential 
            Headers = @{"Accept"="application/json"}
        }
        if((get-command Invoke-RestMethod).Parameters["AllowUnencryptedAuthentication"]){
            $param.Add("AllowUnencryptedAuthentication", $true)
        }
        $Results = Invoke-RestMethod @param -Method $method

        if($results.results.series) {

            foreach($series in $results.results.series) {

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
        }
        else {
            $Results.results
        }
    }
}






function Write-LineProtocol {
    param(
        [Parameter()]
        [string]$Body,
        [Parameter()]
        [string]$Database
    )
    Process {
        $Url = "http://localhost:8086/write?db=$Database"
        Add-Type -AssemblyName System.Web
        $queryEncoded = [System.Web.HttpUtility]::UrlEncode($query) 

        $param = @{
            Uri = "$Url&q=$queryEncoded"
            Credential = $credential 
            Headers = @{"Accept"="application/json"}
        }
        if((get-command Invoke-RestMethod).Parameters["AllowUnencryptedAuthentication"]){
            $param.Add("AllowUnencryptedAuthentication", $true)
        }
        $Body = $Body.Replace("`r`n","`n") # <-- requires UNIX newlines and will complain if Windows

        $Results = Invoke-RestMethod @param -Method "post" -Body $Body

    }
}

