#
# DEMO 1
# ---------
# Download and install InfluxDB
#

$tmp = Join-Path -Path C:\temp\ -ChildPath "influxdb.zip"
[Net.ServicePointManager]::SecurityProtocol = "Tls12, Tls11, Tls, Ssl3"
Invoke-WebRequest -Uri https://dl.influxdata.com/influxdb/releases/influxdb-1.8.3_windows_amd64.zip -OutFile $tmp
Expand-Archive -Path $tmp -DestinationPath c:\tick -Force


# Rename folder 
if(Test-Path c:\tick\influxdb) { Remove-Item c:\tick\influxdb -Recurse }
Get-Item c:\tick\influxdb* | Rename-Item -NewName influxdb


# Start InfluxDB
start-process C:\tick\influxdb\influxd.exe