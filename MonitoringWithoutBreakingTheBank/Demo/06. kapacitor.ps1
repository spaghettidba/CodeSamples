#
# DEMO 6
# ---------
# Kacpacitor
#

$tmp = Join-Path -Path C:\temp\ -ChildPath "kacapitor.zip"
Invoke-WebRequest -Uri https://dl.influxdata.com/kapacitor/releases/kapacitor-1.5.3_windows_amd64.zip -OutFile $tmp
Expand-Archive -Path $tmp -DestinationPath c:\tick -Force


# Generate conf file
c:\tick\kapacitor-1.5.3-1\kapacitord.exe config > c:\tick\kapacitor-1.5.3-1\kapacitor_custom.conf_temp
$content = get-content c:\tick\kapacitor-1.5.3-1\kapacitor_custom.conf_temp 
[IO.File]::WriteAllLines("c:\tick\kapacitor-1.5.3-1\kapacitor_custom.conf", $content) 
remove-item c:\tick\kapacitor-1.5.3-1\kapacitor_custom.conf_temp


# Edit conf file
# change user / pwd
code c:\tick\kapacitor-1.5.3-1\kapacitor_custom.conf

# run Kapacitor
start-process c:\tick\kapacitor-1.5.3-1\kapacitord.exe -ArgumentList "-config","c:\tick\kapacitor-1.5.3-1\kapacitor_custom.conf"

# run chronograf
start-process C:\tick\chronograf-1.7.14-1\chronograf.exe
start-process http://localhost:8888