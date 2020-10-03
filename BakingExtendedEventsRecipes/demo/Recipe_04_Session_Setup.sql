

EXEC sp_configure 'advanced', 1;
RECONFIGURE
EXEC sp_configure 'blocked process threshold', 10;
RECONFIGURE 
GO



IF NOT EXISTS ( SELECT * FROM sys.server_event_sessions WHERE name = 'Recipe04')

CREATE EVENT SESSION [Recipe04] ON SERVER 
ADD EVENT sqlserver.blocked_process_report(
    ACTION(
        sqlserver.client_app_name,
        sqlserver.client_hostname,
        sqlserver.database_name,
        sqlserver.server_instance_name,
        sqlserver.server_principal_name,
        sqlserver.session_id,
        sqlserver.sql_text
    )
),
ADD EVENT sqlserver.xml_deadlock_report(
    ACTION(
        sqlserver.client_app_name,
        sqlserver.client_hostname,
        sqlserver.database_name,
        sqlserver.server_instance_name,
        sqlserver.server_principal_name,
        sqlserver.session_id
    )
)
GO


IF NOT EXISTS ( SELECT * FROM sys.dm_xe_sessions WHERE name = 'Recipe04')
    ALTER EVENT SESSION Recipe04 ON SERVER STATE = START;

