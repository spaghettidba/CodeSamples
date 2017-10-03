IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'audit_table_usage')
	DROP EVENT SESSION [audit_table_usage] ON SERVER;
GO

CREATE EVENT SESSION [audit_table_usage] ON SERVER
ADD EVENT sqlserver.lock_acquired (
    SET collect_database_name = (0)
        ,collect_resource_description = (1)
    ACTION(sqlserver.client_app_name, sqlserver.is_system, sqlserver.server_principal_name)
    WHERE (
        [package0].[equal_boolean]([sqlserver].[is_system], (0)) -- user SPID
        AND [package0].[equal_uint64]([resource_type], (5)) -- OBJECT
        AND [package0].[not_equal_uint64]([database_id], (32767))  -- resourcedb
        AND [package0].[greater_than_uint64]([database_id], (4)) -- user database
        AND [package0].[greater_than_equal_int64]([object_id], (245575913)) -- user object
        AND (
               [mode] = (1) -- SCH-S
            OR [mode] = (6) -- IS
            OR [mode] = (8) -- IX
            OR [mode] = (3) -- S
            OR [mode] = (5) -- X
        )
    )
)
WITH (
     MAX_MEMORY = 20480 KB
    ,EVENT_RETENTION_MODE = ALLOW_MULTIPLE_EVENT_LOSS
    ,MAX_DISPATCH_LATENCY = 30 SECONDS
    ,MAX_EVENT_SIZE = 0 KB
    ,MEMORY_PARTITION_MODE = NONE
    ,TRACK_CAUSALITY = OFF
    ,STARTUP_STATE = OFF
);
GO



ALTER EVENT SESSION [audit_table_usage] ON SERVER STATE = Start;
GO