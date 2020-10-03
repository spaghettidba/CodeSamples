#
# DEMO 1
# ---------
# Download and install InfluxDB
#

$tmp = Join-Path -Path C:\temp\ -ChildPath "influxdb.zip"
Invoke-WebRequest -Uri https://dl.influxdata.com/influxdb/releases/influxdb-1.7.9_windows_amd64.zip -OutFile $tmp
Expand-Archive -Path $tmp -DestinationPath c:\tick -Force


# Start InfluxDB
start-process C:\tick\influxdb-1.7.9-1\influxd.exe