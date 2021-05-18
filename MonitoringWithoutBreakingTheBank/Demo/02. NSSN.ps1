#
# DEMO 2
# ---------
# Download and install NSSM
#

$tmp = Join-Path -Path C:\temp\ -ChildPath "nssm.zip"
Invoke-WebRequest -Uri http://nssm.cc/release/nssm-2.24.zip -OutFile $tmp
Expand-Archive -Path $tmp -DestinationPath c:\tick -Force

# Rename folder 
if(Test-Path c:\tick\nssm) { Remove-Item c:\tick\nssm -Recurse }
Get-Item c:\tick\nssm* | Rename-Item -NewName nssm


# create a service for influxdb
start-process C:\tick\nssm\win64\nssm.exe -argumentlist "install","influxdb"

# start the service
start-process C:\tick\nssm\win64\nssm.exe -ArgumentList "start","influxdb"

# stop the service
Start-Process C:\tick\nssm\win64\nssm.exe -Argumentlist "stop","influxdb"