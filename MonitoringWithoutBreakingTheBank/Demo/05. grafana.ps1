#
# DEMO 5
# ---------
# Download and install Grafana
#


$tmp = Join-Path -Path C:\temp\ -ChildPath "grafana.msi"
Invoke-WebRequest -Uri http://dl.grafana.com/oss/release/grafana-7.1.5.windows-amd64.msi -OutFile $tmp
Invoke-Item $tmp

#By default we get a service: let's stop it
Stop-Service -Name "Grafana"

# create a config file
Copy-Item -Path "C:\Program Files\GrafanaLabs\grafana\conf\defaults.ini" -Destination "C:\Program Files\GrafanaLabs\grafana\conf\custom.ini"
# open and change port to 8080
code "C:\Program Files\GrafanaLabs\grafana\conf\custom.ini"

# start grafana
start-process "C:\Program Files\GrafanaLabs\grafana\bin\grafana-server.exe" -ArgumentList @('-config','"C:\Program Files\GrafanaLabs\grafana\conf\custom.ini"','-homepath','"C:\Program Files\GrafanaLabs\grafana"')

# open browser and connect
start-process http://localhost:8080

# search for sql server dashboards on grafana.com
start-process https://grafana.com/grafana/dashboards?search=sql%20server

# pick the dashboard by Jonathan Rioux
start-process https://grafana.com/grafana/dashboards/9386

# install piechart panel
# remember to restart grafana!
start-process "C:\Program Files\GrafanaLabs\grafana\bin\grafana-cli.exe" -ArgumentList @('plugins','install','grafana-piechart-panel') -WorkingDirectory 'C:\Program Files\GrafanaLabs\grafana\bin'

