#
# DEMO 4
# ---------
# Download and install Chronograf
#

$tmp = Join-Path -Path $env:TEMP -ChildPath "chronograf.zip"
Invoke-WebRequest -Uri https://dl.influxdata.com/chronograf/releases/chronograf-1.7.14_windows_amd64.zip -OutFile $tmp
Expand-Archive -Path $tmp -DestinationPath c:\tick -Force

start-process C:\tick\chronograf-1.7.14-1\chronograf.exe
start-process http://localhost:8888