USE master;
GO

IF OBJECT_ID('CreateXERMLCapture') IS NULL
	EXEC('CREATE PROCEDURE CreateXERMLCapture AS RETURN;')
GO

ALTER PROCEDURE CreateXERMLCapture 
AS 
BEGIN

	SET NOCOUNT ON;

	IF EXISTS (SELECT * FROM sys.dm_xe_sessions WHERE name = 'XERMLCapture')
	BEGIN
		ALTER EVENT SESSION XERMLCapture ON SERVER STATE = STOP
	END


	IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE NAME = 'XERMLCapture')
	BEGIN
		DROP EVENT SESSION XERMLCapture ON SERVER
	END



	CREATE EVENT SESSION XERMLCapture ON SERVER
	ADD 
	EVENT sqlserver.rpc_completed( 
		set collect_data_stream = 1, 
		collect_statement = 1,
		collect_output_parameters = 1
		ACTION (
			sqlserver.session_id,
			sqlserver.request_id,
			sqlserver.database_id,
			sqlserver.database_name,
			sqlserver.is_system,
			package0.event_sequence,
			sqlserver.client_app_name,
			sqlserver.server_principal_name,
			sqlserver.transaction_id,
			sqlserver.plan_handle,
			package0.collect_current_thread_id,
			sqlos.system_thread_id,
			sqlos.task_address,
			sqlos.worker_address,
			sqlos.scheduler_id,
			sqlos.cpu_id
		) 
		WHERE (
			[sqlserver].[server_principal_name] = N'replayuser'
		)
	),
	ADD EVENT sqlserver.sql_batch_completed ( 
		SET collect_batch_text = 1
		ACTION (
			sqlserver.session_id,
			sqlserver.request_id,
			sqlserver.database_id,
			sqlserver.database_name,
			sqlserver.is_system,
			package0.event_sequence,
			sqlserver.client_app_name,
			sqlserver.server_principal_name,
			sqlserver.transaction_id,
			sqlserver.plan_handle,
			package0.collect_current_thread_id,
			sqlos.system_thread_id,
			sqlos.task_address,
			sqlos.worker_address,
			sqlos.scheduler_id,
			sqlos.cpu_id
		) 
		WHERE (
			[sqlserver].[server_principal_name] = N'replayuser'
		)
	)
	WITH( 
		MAX_DISPATCH_LATENCY = 3 SECONDS, 
		MAX_MEMORY = 40960 KB,
		EVENT_RETENTION_MODE = NO_EVENT_LOSS,		
		MEMORY_PARTITION_MODE = PER_CPU,
		STARTUP_STATE = OFF
	);
	
	ALTER EVENT SESSION XERMLCapture ON SERVER STATE = START;
END
GO

EXEC CreateXERMLCapture;
GO