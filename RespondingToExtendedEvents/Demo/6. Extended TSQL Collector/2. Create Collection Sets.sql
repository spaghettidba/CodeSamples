-- Enable editing advanced configuration options
EXEC sp_configure 'advanced', 1
RECONFIGURE
GO
 
-- Set the blocked process threshold
EXEC sp_configure 'blocked process threshold (s)', 20
RECONFIGURE
GO

DECLARE @retVal int, @collection_set_id int, @name sysname;
SET @name = 'Blocking and deadlocking'
EXEC @retVal = msdb.dbo.sp_syscollector_verify_collection_set @collection_set_id OUTPUT, @name OUTPUT
IF (@retVal <> 0)
BEGIN
	PRINT 'Not exists'

 
BEGIN TRANSACTION
BEGIN TRY
 
DECLARE @collection_set_id_1 int
DECLARE @collection_set_uid_2 uniqueidentifier
EXEC [msdb].[dbo].[sp_syscollector_create_collection_set]
    @name=N'Blocking and Deadlocking',
    @collection_mode=0,
    @description=N'Collects Blocked Process Reports and Deadlocks using Extended Events',
    @logging_level=1,
    @days_until_expiration=30,
    @schedule_name=N'CollectorSchedule_Every_5min',
    @collection_set_id=@collection_set_id_1 OUTPUT,
    @collection_set_uid= '19AE101D-B30F-4447-8233-1314AEF0A02F'
 
DECLARE @collector_type_uid_3 uniqueidentifier
 
SELECT @collector_type_uid_3 = collector_type_uid
FROM [msdb].[dbo].[syscollector_collector_types]
WHERE name = N'Extended XE Reader Collector Type';
 
DECLARE @collection_item_id_4 int
EXEC [msdb].[dbo].[sp_syscollector_create_collection_item]
    @name=N'Blocked Processes',
    @parameters=N'
<ns:ExtendedXEReaderCollector xmlns:ns="DataCollectorType">
    <Session>
        <Name>blocked_processes</Name>
        <OutputTable>blocked_processes</OutputTable>
        <Definition>
        CREATE EVENT SESSION [blocked_processes] ON SERVER ADD EVENT sqlserver.blocked_process_report
        WITH (
            MAX_MEMORY = 2048 KB
            ,EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS
            ,MAX_DISPATCH_LATENCY = 30 SECONDS
            ,MAX_EVENT_SIZE = 0 KB
            ,MEMORY_PARTITION_MODE = NONE
            ,TRACK_CAUSALITY = OFF
            ,STARTUP_STATE = ON
            )
        </Definition>
        <Filter>duration &lt;= 40000000</Filter>
        <ColumnsList>blocked_process</ColumnsList>
    </Session>
    <Alert Enabled="true" WriteToERRORLOG="false" WriteToWindowsLog="false">
        <Sender>MailProfile</Sender>
        <Recipient>dba@localhost.localdomain</Recipient>
        <Subject>Blocked process detected</Subject>
        <Importance>High</Importance>
        <ColumnsList>blocked_process</ColumnsList>
        <Filter>duration &lt;= 40000000</Filter>
        <Mode>Atomic</Mode>
        <Delay>60</Delay>
    </Alert>
</ns:ExtendedXEReaderCollector>',
    @collection_item_id=@collection_item_id_4 OUTPUT,
    @frequency=60,
    @collection_set_id=@collection_set_id_1,
    @collector_type_uid=@collector_type_uid_3
 
Declare @collection_item_id_6 int
EXEC [msdb].[dbo].[sp_syscollector_create_collection_item] @name=N'Collect deadlocks', @parameters=N'
<ns:ExtendedXEReaderCollector xmlns:ns="DataCollectorType">
    <Session>
        <Name>deadlocks</Name>
        <OutputTable>deadlocks</OutputTable>
        <Definition>
        CREATE EVENT SESSION [deadlocks] ON SERVER
        ADD EVENT sqlserver.xml_deadlock_report
        WITH (
            MAX_MEMORY = 2048 KB
            ,EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS
            ,MAX_DISPATCH_LATENCY = 30 SECONDS
            ,MAX_EVENT_SIZE = 0 KB
            ,MEMORY_PARTITION_MODE = NONE
            ,TRACK_CAUSALITY = OFF
            ,STARTUP_STATE = ON
            )
        </Definition>
        <ColumnsList>xml_report</ColumnsList>
    </Session>
    <Alert Enabled="true" WriteToERRORLOG="false" WriteToWindowsLog="false">
        <Sender>MailProfile</Sender>
        <Recipient>dba@localhost.localdomain</Recipient>
        <Subject>Deadlock detected</Subject>
        <Importance>High</Importance>
        <ColumnsList>xml_report</ColumnsList>
        <Mode>Atomic</Mode>
        <Delay>60</Delay>
    </Alert>
</ns:ExtendedXEReaderCollector>',
    @collection_item_id=@collection_item_id_6 OUTPUT,
    @frequency=60,
    @collection_set_id=@collection_set_id_1,
    @collector_type_uid=@collector_type_uid_3
 
COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    DECLARE @ErrorNumber INT;
    DECLARE @ErrorLine INT;
    DECLARE @ErrorProcedure NVARCHAR(200);
    SELECT @ErrorLine = ERROR_LINE(),
           @ErrorSeverity = ERROR_SEVERITY(),
           @ErrorState = ERROR_STATE(),
           @ErrorNumber = ERROR_NUMBER(),
           @ErrorMessage = ERROR_MESSAGE(),
           @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');
    RAISERROR (14684, @ErrorSeverity, 1 , @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine, @ErrorMessage);
 
END CATCH;

END
ELSE 
BEGIN
	EXEC [msdb].[dbo].[sp_syscollector_start_collection_set] @name = 'Blocking and deadlocking'
END
 
GO