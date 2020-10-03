IF NOT EXISTS ( SELECT * FROM sys.server_event_sessions WHERE name = 'Recipe02')

CREATE EVENT SESSION [Recipe02] ON SERVER 
ADD EVENT sqlserver.rpc_completed(
    ACTION(
        package0.event_sequence,
        sqlserver.client_app_name,
        sqlserver.client_pid,
        sqlserver.database_name,
        sqlserver.nt_username,
        sqlserver.query_hash,
        sqlserver.server_principal_name,
        sqlserver.session_id
    )
    WHERE ([package0].[equal_boolean]([sqlserver].[is_system],(0)))
),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(
        package0.event_sequence,
        sqlserver.client_app_name,
        sqlserver.client_pid,
        sqlserver.database_name,
        sqlserver.nt_username,
        sqlserver.query_hash,
        sqlserver.server_principal_name,
        sqlserver.session_id
    )
    WHERE ([package0].[equal_boolean]([sqlserver].[is_system],(0)))
)
GO

IF NOT EXISTS ( SELECT * FROM sys.dm_xe_sessions WHERE name = 'Recipe02')
    ALTER EVENT SESSION Recipe02 ON SERVER STATE = START;