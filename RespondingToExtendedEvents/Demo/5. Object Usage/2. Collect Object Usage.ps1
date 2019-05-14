sl $Env:Temp
 
#For SQL Server 2014:
Add-Type -Path 'C:\Program Files\Microsoft SQL Server\150\Shared\Microsoft.SqlServer.XE.Core.dll'
Add-Type -Path 'C:\Program Files\Microsoft SQL Server\150\Shared\Microsoft.SqlServer.XEvent.Linq.dll'

#For SQL Server 2012:
#Add-Type -Path 'C:\Program Files\Microsoft SQL Server\110\Shared\Microsoft.SqlServer.XEvent.Linq.dll'
 
$connectionString = 'Data Source = SQL2019; Initial Catalog = master; Integrated Security = SSPI'
 
$SessionName = "audit_table_usage"
 
# loads all object ids for table objects and their database id
# table object_ids will be saved in order to rule out whether
# the locked object is a table or something else.
$commandText = "
DECLARE @results TABLE (
       object_id int,
       database_id int
);
 
DECLARE @sql nvarchar(max);
 
SET @sql = '
       SELECT object_id, db_id()
       FROM sys.tables t
       WHERE is_ms_shipped = 0
';
 
DECLARE @statement nvarchar(max);
 
SET @statement = (
       SELECT 'EXEC ' + QUOTENAME(name) + '.sys.sp_executesql @sql; '
       FROM sys.databases d
       WHERE name NOT IN ('master','model','msdb','tempdb')
       FOR XML PATH(''), TYPE
).value('.','nvarchar(max)');
 
INSERT @results
EXEC sp_executesql @statement, N'@sql nvarchar(max)', @sql;
 
SELECT *
FROM @results
"
 
$objCache = @{}
 
$conn = New-Object -TypeName System.Data.SqlClient.SqlConnection -ArgumentList $connectionString
$cmd = New-Object -TypeName System.Data.SqlClient.SqlCommand
$cmd.CommandText = $commandText
$cmd.Connection = $conn
$conn.Open()
$conn.ChangeDatabase("master")
$rdr = $cmd.ExecuteReader()
 
# load table object_ids and store them in a hashtable
 
while ($rdr.Read()) {
    $objId = $rdr.GetInt32(0)
    $dbId = $rdr.GetInt32(1)
    if(-not $objCache.ContainsKey($objId)){
        $objCache.add($objId,@($dbId))
    }
    else {
        $arr = $objCache.Get_Item($objId)
        $arr += $dbId
        $objCache.set_Item($objId, $arr)
    }
}
 
$conn.Close()
 
# create a DataTable to hold lock information in memory
$queue = New-Object -TypeName System.Data.DataTable
$queue.TableName = $SessionName
 
[Void]$queue.Columns.Add("database_id",[Int32])
[Void]$queue.Columns.Add("object_id",[Int32])
[Void]$queue.Columns.Add("client_app_name",[String])
[Void]$queue.Columns.Add("last_read",[DateTime])
[Void]$queue.Columns.Add("last_write",[DateTime])
 
# create a DataView to perform searches in the DataTable
$dview = New-Object -TypeName System.Data.DataView
$dview.Table = $queue
$dview.Sort = "database_id, client_app_name, object_id"
 
$last_dump = [DateTime]::Now
 
# connect to the Extended Events session
[Microsoft.SqlServer.XEvent.Linq.QueryableXEventData] $events = New-Object -TypeName Microsoft.SqlServer.XEvent.Linq.QueryableXEventData `
    -ArgumentList @($connectionString, $SessionName, [Microsoft.SqlServer.XEvent.Linq.EventStreamSourceOptions]::EventStream, [Microsoft.SqlServer.XEvent.Linq.EventStreamCacheOptions]::DoNotCache)
 
$events | % {
    $currentEvent = $_
 
    $database_id = $currentEvent.Fields["database_id"].Value
    $client_app_name = $currentEvent.Actions["client_app_name"].Value
    if($client_app_name -eq $null) { $client_app_name = [string]::Empty }
    $object_id = $currentEvent.Fields["object_id"].Value
    $mode = $currentEvent.Fields["mode"].Value
 
    # search the object id in the object cache
    # if found (and database id matches) ==> table
    # otherwise ==> some other kind of object (not interesting)
    if($objCache.ContainsKey($object_id) -and $objCache.Get_Item($object_id) -contains $database_id)
    {
        # search the DataTable by database_id, client app name and object_id
        $found_rows = $dview.FindRows(@($database_id, $client_app_name, $object_id))
 
        # if not found, add a row
        if($found_rows.Count -eq 0){
            $current_row = $queue.Rows.Add()
            $current_row["database_id"] = $database_id
            $current_row["client_app_name"] = $client_app_name
            $current_row["object_id"] = $object_id
        }
        else {
            $current_row = $found_rows[0]
        }
 
        if(($mode.Value -eq "IX") -or ($mode.Value -eq "X")) {
            # Exclusive or Intent-Exclusive lock: count this as a write
            $current_row["last_write"] = [DateTime]::Now
        }
        else {
            # Shared or Intent-Shared lock: count this as a read
            # SCH-S locks counted here as well (snapshot isolation ==> no shared locks)
            $current_row["last_read"] = [DateTime]::Now
        }
    }
 
    $ts = New-TimeSpan -Start $last_dump -End (get-date)
 
    # Dump to database every 5 minutes
    if($ts.TotalMinutes -gt 5) {
        $last_dump = [DateTime]::Now
 
        # BCP data to the staging table TOOLS.meta.table_usage_xe_last_snapshot
        $bcp = New-Object -TypeName System.Data.SqlClient.SqlBulkCopy -ArgumentList @($connectionString)
        $bcp.DestinationTableName = "TOOLS.meta.table_usage_xe_last_snapshot"
        $bcp.Batchsize = 1000
        $bcp.BulkCopyTimeout = 0
 
        $bcp.WriteToServer($queue)
 
        # Merge data with the destination table TOOLS.meta.table_usage_xe
        $statement = "
            BEGIN TRANSACTION
 
            BEGIN TRY
 
                MERGE INTO meta.table_usage_xe AS dest
                USING (
                    SELECT db_name(database_id) AS db_name,
                        object_schema_name(object_id, database_id) AS schema_name,
                        object_name(object_id, database_id) AS object_name,
                        client_app_name,
                        last_read,
                        last_write
                    FROM meta.table_usage_xe_last_snapshot
                ) AS src
                    ON src.db_name = dest.db_name
                    AND src.schema_name = dest.schema_name
                    AND src.object_name = dest.object_name
                    AND src.client_app_name = dest.client_app_name
                WHEN MATCHED THEN
                    UPDATE SET last_read = src.last_read,
                        last_write = src.last_write
                WHEN NOT MATCHED THEN
                    INSERT (db_name, schema_name, object_name, client_app_name, last_read, last_write)
                    VALUES (db_name, schema_name, object_name, client_app_name, last_read, last_write);
 
                TRUNCATE TABLE meta.table_usage_xe_last_snapshot;
 
                COMMIT;
 
            END TRY
            BEGIN CATCH
                ROLLBACK;
                THROW;
            END CATCH
        "
 
        $conn = New-Object -TypeName System.Data.SqlClient.SqlConnection -ArgumentList $connectionString
        $cmd = New-Object -TypeName System.Data.SqlClient.SqlCommand
        $cmd.CommandText = $statement
        $cmd.Connection = $conn
        $conn.Open()
        $conn.ChangeDatabase("TOOLS")
        [Void]$cmd.ExecuteNonQuery()
        $conn.Close()
 
        $queue.Rows.Clear()
 
    }
 
}