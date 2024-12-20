IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'blocked_processes')
	DROP EVENT SESSION [blocked_processes] ON SERVER;
GO


CREATE EVENT SESSION [blocked_processes] ON SERVER ADD EVENT sqlserver.blocked_process_report
WITH (
    MAX_MEMORY = 2048 KB
    ,EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS
    ,MAX_DISPATCH_LATENCY = 30 SECONDS
    ,MAX_EVENT_SIZE = 0 KB
    ,MEMORY_PARTITION_MODE = NONE
    ,TRACK_CAUSALITY = OFF
    ,STARTUP_STATE = ON
);
GO



IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'deadlocks')
	DROP EVENT SESSION [deadlocks] ON SERVER;
GO


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
);
GO