[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True,Position=1)]
	[string]$servername
)

sl $Env:Temp

# For SQL Server 2012
#Add-Type -Path 'C:\Program Files\Microsoft SQL Server\110\Shared\Microsoft.SqlServer.XEvent.Linq.dll'

# For SQL Server >= 2014
Add-Type -Path 'C:\Program Files\Microsoft SQL Server\150\Shared\Microsoft.SqlServer.XE.Core.dll'
Add-Type -Path 'C:\Program Files\Microsoft SQL Server\150\Shared\Microsoft.SqlServer.XEvent.Linq.dll'


$connectionString = 'Data Source=' + $servername + '; Initial Catalog = master; Integrated Security = SSPI'
 
$SessionName = "Audit_Logon"

 
# create a DataTable to hold lock information in memory
$queue = New-Object -TypeName System.Data.DataTable
$queue.TableName = $SessionName

[Void]$queue.Columns.Add("event_date",[DateTime])
[Void]$queue.Columns.Add("original_login",[String])
[Void]$queue.Columns.Add("host_name",[String])
[Void]$queue.Columns.Add("program_name",[String])
[Void]$queue.Columns.Add("database_name",[String])


# save time of last upload to the destination table
$last_dump = [DateTime]::Now
 
# connect to the Extended Events session
[Microsoft.SqlServer.XEvent.Linq.QueryableXEventData] $events = New-Object -TypeName Microsoft.SqlServer.XEvent.Linq.QueryableXEventData `
    -ArgumentList @($connectionString, $SessionName, [Microsoft.SqlServer.XEvent.Linq.EventStreamSourceOptions]::EventStream, [Microsoft.SqlServer.XEvent.Linq.EventStreamCacheOptions]::DoNotCache)
 
$events | % {
    $currentEvent = $_
 
    $database_name = $currentEvent.Fields["database_name"].Value
    if($client_app_name -eq $null) { $client_app_name = [string]::Empty }
    $original_login_name = $currentEvent.Actions["server_principal_name"].Value
    $client_app_name = $currentEvent.Actions["client_app_name"].Value
	$client_host_name = $currentEvent.Actions["client_hostname"].Value
 
    $current_row = $queue.Rows.Add()
    $current_row["database_name"] = $database_name
    $current_row["program_name"] = $client_app_name
    $current_row["host_name"] = $client_host_name
	$current_row["original_login"] = $original_login_name
	$current_row["event_date"] = [DateTime]::Now

 
    $ts = New-TimeSpan -Start $last_dump -End (get-date)
 
    # Dump to database every 10 seconds
    if($ts.TotalSeconds -gt 10) {
        $last_dump = [DateTime]::Now
 
        # BCP data to the staging table TOOLS.dbo.AuditLogin_Staging
        $bcp = New-Object -TypeName System.Data.SqlClient.SqlBulkCopy -ArgumentList @($connectionString)
        $bcp.DestinationTableName = "TOOLS.dbo.AuditLogin_Staging"
        $bcp.Batchsize = 1000
        $bcp.BulkCopyTimeout = 0
 
        $bcp.WriteToServer($queue)
 
        $queue.Rows.Clear()
 
    }
 
}