#
# DEMO 4
# ---------
# Download and install Chronograf
#

$tmp = Join-Path -Path C:\temp\ -ChildPath "chronograf.zip"
[Net.ServicePointManager]::SecurityProtocol = "Tls12, Tls11, Tls, Ssl3"
Invoke-WebRequest -Uri https://dl.influxdata.com/chronograf/releases/chronograf-1.8.7_windows_amd64.zip -OutFile $tmp
Expand-Archive -Path $tmp -DestinationPath c:\tick -Force

# Rename folder 
if(Test-Path c:\tick\chronograf) { Remove-Item c:\tick\chronograf -Recurse }
Get-Item c:\tick\chronograf* | Rename-Item -NewName chronograf


start-process C:\tick\chronograf\chronograf.exe
start-process http://localhost:8888