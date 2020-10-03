IF NOT EXISTS ( SELECT * FROM sys.server_event_sessions WHERE name = 'Recipe06')

CREATE EVENT SESSION [Recipe06] ON SERVER 
ADD EVENT sqlserver.login(
    SET collect_database_name=(1)
    ACTION(
        sqlserver.client_app_name,
        sqlserver.server_principal_name
    )
)
GO


IF NOT EXISTS ( SELECT * FROM sys.dm_xe_sessions WHERE name = 'Recipe06')
    ALTER EVENT SESSION Recipe06 ON SERVER STATE = START;
