#
# DEMO 3
# ---------
# Download and install Telegraf
#

$tmp = Join-Path -Path $env:TEMP -ChildPath "telegraf.zip"
Invoke-WebRequest -Uri https://dl.influxdata.com/telegraf/releases/telegraf-1.12.6_windows_amd64.zip -OutFile $tmp
Expand-Archive -Path $tmp -DestinationPath c:\tick -Force

#generate the full configuration and write it to a file
c:\tick\telegraf\telegraf.exe config > c:\tick\telegraf\telegraf_full.conf
# code c:\tick\telegraf\telegraf_full.conf

#generate a filtered configuration (like the default one) and write it to a file
c:\tick\telegraf\telegraf.exe --input-filter sqlserver --output-filter influxdb config > c:\tick\telegraf\telegraf_sqlserver_counters.conf
code .\telegraf_sqlserver_counters.conf

#test the conf file
c:\tick\telegraf\telegraf.exe -config .\telegraf_sqlserver_counters.conf -test
# it works? yay! Let's copy this file over to the default folder
Copy-Item -Path .\telegraf_sqlserver_counters.conf -Destination C:\tick\telegraf\telegraf_sqlserver_counters.conf

#install telegraf as a service
c:\tick\telegraf\telegraf.exe --service install --service-name=telegraf_sqlserver --service-display-name="Telegraf SQLServer" --config "C:\tick\telegraf\telegraf_sqlserver_counters.conf"
# FFS! Re-open code as admin...

# start the service
c:\tick\telegraf\telegraf.exe --service start --service-name=telegraf_sqlserver

# check collected data
C:\tick\influxdb-1.7.9-1\influx.exe

# copy / paste this:
<#
SHOW DATABASES

USE telegraf
# a measurement can be the equivalent of a table in a relational db
SHOW MEASUREMENTS
#>