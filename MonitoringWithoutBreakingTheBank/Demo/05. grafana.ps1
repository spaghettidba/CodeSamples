#
# DEMO 5
# ---------
# Download and install Grafana
#

$tmp = Join-Path -Path C:\temp\ -ChildPath "grafana.zip"
Invoke-WebRequest -Uri http://dl.grafana.com/oss/release/grafana-6.4.4.windows-amd64.zip -OutFile $tmp
Expand-Archive -Path $tmp -DestinationPath c:\tick -Force

# create a config file
Copy-Item -Path C:\tick\grafana-6.4.4\conf\defaults.ini -Destination C:\tick\grafana-6.4.4\conf\custom.ini
# open and change port to 8080
code C:\tick\grafana-6.4.4\conf\custom.ini

# start grafana
start-process C:\tick\grafana-6.4.4\bin\grafana-server.exe -ArgumentList @("-config","C:\tick\grafana-6.4.4\conf\custom.ini","-homepath","C:\tick\grafana-6.4.4")

# open browser and connect
start-process http://localhost:8080

# search for sql server dashboards on grafana.com
start-process https://grafana.com/grafana/dashboards?search=sql%20server

# pick the dashboard by Jonathan Rioux
start-process https://grafana.com/grafana/dashboards/9386

# install piechart panel
# remember to restart grafana!
start-process C:\tick\grafana-6.4.4\bin\grafana-cli.exe -ArgumentList @("plugins","install","grafana-piechart-panel") -WorkingDirectory C:\tick\grafana-6.4.4\bin\

