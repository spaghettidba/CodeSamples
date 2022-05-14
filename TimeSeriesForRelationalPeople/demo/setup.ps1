$influx_service = Get-WmiObject -Class Win32_Service -Filter "Name = 'influxdb'"
if($influx_service)
{
    stop-service "influxdb"
    $influx_service.delete()
}

# clean up
if(test-path "$($env:userprofile)\.influx_history") {remove-item "$($env:userprofile)\.influx_history" }
if(test-path "$($env:userprofile)\.influxdb") {remove-item "$($env:userprofile)\.influxdb" -Recurse }
if(test-path "C:\tick\grafana-8.5.2\data\grafana.db") {remove-item "C:\tick\grafana-8.5.2\data\grafana.db" }

