IF NOT EXISTS ( SELECT * FROM sys.server_event_sessions WHERE name = 'Recipe07')

CREATE EVENT SESSION [Recipe07] ON SERVER
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
);
GO


IF NOT EXISTS ( SELECT * FROM sys.dm_xe_sessions WHERE name = 'Recipe07')
    ALTER EVENT SESSION Recipe07 ON SERVER STATE = START;
