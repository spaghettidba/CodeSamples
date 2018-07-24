IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'Audit_Logon')
	DROP EVENT SESSION [Audit_Logon] ON SERVER;
GO


CREATE EVENT SESSION [Audit_Logon] ON SERVER 
ADD EVENT sqlserver.LOGIN (
	SET collect_database_name = (1)
	,collect_options_text = (0) 
	ACTION(
		sqlserver.client_app_name, 
		sqlserver.client_hostname, 
		sqlserver.server_principal_name
	)
)
WITH (
	MAX_MEMORY = 4096 KB
	,EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS
	,MAX_DISPATCH_LATENCY = 30 SECONDS
	,MAX_EVENT_SIZE = 0 KB
	,MEMORY_PARTITION_MODE = NONE
	,TRACK_CAUSALITY = OFF
	,STARTUP_STATE = ON
)
GO

ALTER EVENT SESSION [Audit_Logon] ON SERVER STATE = Start;
GO