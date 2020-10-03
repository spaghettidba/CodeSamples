#
# DEMO 2
# ---------
# Download and install NSSM
#

$tmp = Join-Path -Path C:\temp\ -ChildPath "nssm.zip"
Invoke-WebRequest -Uri http://nssm.cc/release/nssm-2.24.zip -OutFile $tmp
Expand-Archive -Path $tmp -DestinationPath c:\tick -Force


# create a service for influxdb
start-process C:\tick\nssm-2.24\win64\nssm.exe -argumentlist "install","influxdb"

# start the service
start-process C:\tick\nssm-2.24\win64\nssm.exe -ArgumentList "start","influxdb"

# stop the service
Start-Process C:\tick\nssm-2.24\win64\nssm.exe -Argumentlist "stop","influxdb"