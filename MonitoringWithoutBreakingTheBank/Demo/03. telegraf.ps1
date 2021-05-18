#
# DEMO 3
# ---------
# Download and install Telegraf
#

$tmp = Join-Path -Path C:\temp\ -ChildPath "telegraf.zip"
[Net.ServicePointManager]::SecurityProtocol = "Tls12, Tls11, Tls, Ssl3"
Invoke-WebRequest -Uri https://dl.influxdata.com/telegraf/releases/telegraf-1.16.0_windows_amd64.zip -OutFile $tmp
Expand-Archive -Path $tmp -DestinationPath c:\tick -Force

# Rename folder 
if(Test-Path c:\tick\telegraf) { Remove-Item c:\tick\telegraf -Recurse }
Get-Item c:\tick\telegraf* | Rename-Item -NewName telegraf



# generate the full configuration and write it to a file
c:\tick\telegraf\telegraf.exe config > c:\tick\telegraf\telegraf_full.conf_temp
# BE CAREFUL! The file gets generated with UTF-16, which is not understood by telegraf...
get-content c:\tick\telegraf\telegraf_full.conf_temp | Set-Content -Encoding UTF8 -Path c:\tick\telegraf\telegraf_full.conf
remove-item c:\tick\telegraf\telegraf_full.conf_temp
# code c:\tick\telegraf\telegraf_full.conf


#generate a filtered configuration (like the default one) and write it to a file
c:\tick\telegraf\telegraf.exe --input-filter sqlserver --output-filter influxdb config > c:\tick\telegraf\telegraf_sqlserver_counters.conf_temp
# BE CAREFUL! The file gets generated with UTF-16, which is not understood by telegraf...
get-content c:\tick\telegraf\telegraf_sqlserver_counters.conf_temp | Set-Content -Encoding UTF8 -Path c:\tick\telegraf\telegraf_sqlserver_counters.conf
remove-item c:\tick\telegraf\telegraf_sqlserver_counters.conf_temp
# code c:\tick\telegraf\telegraf_sqlserver_counters.conf


#test the conf file
c:\tick\telegraf\telegraf.exe -config c:\tick\telegraf\telegraf_sqlserver_counters.conf -test

#start telegraf
start-process c:\tick\telegraf\telegraf.exe -ArgumentList @("--config","c:\tick\telegraf\telegraf_sqlserver_counters.conf")


#install telegraf as a service
c:\tick\telegraf\telegraf.exe --service install --service-name=telegraf_sqlserver --service-display-name="Telegraf SQLServer" --config "C:\tick\telegraf\telegraf_sqlserver_counters.conf"
# FFS! Re-open code as admin...


# start the service
c:\tick\telegraf\telegraf.exe --service start --service-name=telegraf_sqlserver


# check collected data
start-process C:\tick\influxdb\influx.exe


# copy / paste this:
<#
SHOW DATABASES

USE telegraf
# a measurement can be the equivalent of a table in a relational db
SHOW MEASUREMENTS
#>