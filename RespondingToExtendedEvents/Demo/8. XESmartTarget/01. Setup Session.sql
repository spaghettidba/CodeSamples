IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'test_session')
	DROP EVENT SESSION [test_session] ON SERVER;
GO


CREATE EVENT SESSION [test_session] ON SERVER 
	ADD EVENT sqlserver.checkpoint_begin,
	ADD EVENT sqlserver.sql_batch_completed(
		ACTION(sqlserver.database_id,sqlserver.is_system)
		WHERE ([sqlserver].[database_id]>(4) 
			AND [sqlserver].[is_system]=(0))
	)
WITH (
	MAX_MEMORY=4096 KB,
	EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,
	MAX_DISPATCH_LATENCY=30 SECONDS,
	MAX_EVENT_SIZE=0 KB,
	MEMORY_PARTITION_MODE=NONE,
	TRACK_CAUSALITY=OFF,
	STARTUP_STATE=OFF
)
GO

ALTER EVENT SESSION [test_session] ON SERVER STATE = Start;
GO