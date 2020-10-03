IF NOT EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'Recipe09')

CREATE EVENT SESSION [Recipe09] ON SERVER 
    ADD EVENT sqlserver.blocked_process_report (
        ACTION(
            package0.event_sequence,
            sqlserver.client_app_name, 
            sqlserver.client_hostname, 
            sqlserver.database_name, 
            sqlserver.server_instance_name, 
            sqlserver.server_principal_name, 
            sqlserver.session_id, 
            sqlserver.sql_text
        )
    )
,ADD EVENT sqlserver.error_reported (
        ACTION(
            package0.event_sequence,
            sqlserver.client_app_name, 
            sqlserver.client_hostname, 
            sqlserver.database_name, 
            sqlserver.server_instance_name, 
            sqlserver.server_principal_name, 
            sqlserver.session_id
        ) 
        WHERE ([severity] >= (16))
    )
,ADD EVENT sqlserver.rpc_completed (
        ACTION(
            package0.event_sequence,
            sqlserver.client_app_name, 
            sqlserver.client_hostname, 
            sqlserver.database_name, 
            sqlserver.query_hash, 
            sqlserver.server_instance_name, 
            sqlserver.server_principal_name, 
            sqlserver.session_id
        ) 
        WHERE ([result] = (2))
    )
,ADD EVENT sqlserver.sql_batch_completed (
        ACTION(
            package0.event_sequence,
            sqlserver.client_app_name, 
            sqlserver.client_hostname, 
            sqlserver.database_name, 
            sqlserver.query_hash, 
            sqlserver.server_instance_name, 
            sqlserver.server_principal_name, 
            sqlserver.session_id
        ) 
        WHERE ([result] = (2))
    )
,ADD EVENT sqlserver.xml_deadlock_report (
        ACTION(
            package0.event_sequence,
            sqlserver.client_app_name, 
            sqlserver.client_hostname, 
            sqlserver.database_name, 
            sqlserver.server_instance_name, 
            sqlserver.server_principal_name, 
            sqlserver.session_id
        )
)
WITH (
         MAX_MEMORY = 4096 KB
        ,EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS
        ,MAX_DISPATCH_LATENCY = 30 SECONDS
        ,MAX_EVENT_SIZE = 0 KB
        ,MEMORY_PARTITION_MODE = NONE
        ,TRACK_CAUSALITY = OFF
        ,STARTUP_STATE = OFF
)
GO

IF NOT EXISTS (SELECT * FROM sys.dm_xe_sessions WHERE name = 'Recipe09')
    ALTER EVENT SESSION Recipe09 ON SERVER STATE = START;
GO