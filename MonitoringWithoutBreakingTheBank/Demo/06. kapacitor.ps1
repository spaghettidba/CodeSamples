#
# DEMO 6
# ---------
# Kacpacitor
#

$tmp = Join-Path -Path C:\temp\ -ChildPath "kacapitor.zip"
[Net.ServicePointManager]::SecurityProtocol = "Tls12, Tls11, Tls, Ssl3"
Invoke-WebRequest -Uri https://dl.influxdata.com/kapacitor/releases/kapacitor-1.5.6_windows_amd64.zip -OutFile $tmp
Expand-Archive -Path $tmp -DestinationPath c:\tick -Force

# Rename folder 
if(Test-Path c:\tick\kapacitor) { Remove-Item c:\tick\kapacitor -Recurse }
Get-Item c:\tick\kapacitor* | Rename-Item -NewName kapacitor


# Generate conf file
c:\tick\kapacitor-1.5.3-1\kapacitord.exe config > c:\tick\kapacitor\kapacitor_custom.conf_temp
$content = get-content c:\tick\kapacitor\kapacitor_custom.conf_temp 
[IO.File]::WriteAllLines("c:\tick\kapacitor\kapacitor_custom.conf", $content) 
remove-item c:\tick\kapacitor\kapacitor_custom.conf_temp


# Edit conf file
# change user / pwd
code c:\tick\kapacitor\kapacitor_custom.conf

# run Kapacitor
start-process c:\tick\kapacitor\kapacitord.exe -ArgumentList "-config","c:\tick\kapacitor\kapacitor_custom.conf"

# run chronograf
start-process C:\tick\chronograf\chronograf.exe
start-process http://localhost:8888