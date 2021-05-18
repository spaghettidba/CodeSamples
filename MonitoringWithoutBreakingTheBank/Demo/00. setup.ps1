$influx_service = Get-WmiObject -Class Win32_Service -Filter "Name = 'influxdb'"
if($influx_service)
{
    stop-service "influxdb"
    $influx_service.delete()
}

$telegraf_sqlserver = Get-WmiObject -Class Win32_Service -Filter "Name = 'telegraf_sqlserver'"
if($telegraf_sqlserver)
{
    stop-service "telegraf_sqlserver"
    $telegraf_sqlserver.delete()
}

# clean up
if(test-path "$($env:userprofile)\chronograf-v1.db") {remove-item "$($env:userprofile)\chronograf-v1.db" }
if(test-path "$($env:userprofile)\chronograf-v1.db.lock") {remove-item "$($env:userprofile)\chronograf-v1.db.lock" }
if(test-path "$($env:userprofile)\.influx_history") {remove-item "$($env:userprofile)\.influx_history" }
if(test-path "$($env:userprofile)\.influxdb") {remove-item "$($env:userprofile)\.influxdb" -Recurse }
if(test-path "$($env:userprofile)\.kapacitor") {remove-item "$($env:userprofile)\.kapacitor" -Recurse }
if(test-path "C:\tick\grafana-6.4.4\data\grafana.db") {remove-item "C:\tick\grafana-6.4.4\data\grafana.db" }
if(test-path "$($env:programfiles)\grafanalabs\grafana\data\grafana.db") {remove-item "$($env:programfiles)\grafanalabs\grafana\data\grafana.db" }
if(test-path "$psscriptroot\chronograf-v1.db") {remove-item "$psscriptroot\chronograf-v1.db" }
if(test-path "$psscriptroot\chronograf-v1.db.lock") {remove-item "$psscriptroot\chronograf-v1.db.lock" }
