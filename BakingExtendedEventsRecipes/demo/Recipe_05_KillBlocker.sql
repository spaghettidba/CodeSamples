USE master;
GO

IF OBJECT_ID('killBlocker') IS NULL EXEC('CREATE PROCEDURE killBlocker AS BEGIN RETURN END');
GO

--
-- Kills the session that is blocking the specified
-- trasnsaction, when the blocking session is sleeping
-- and has not issued any command in the last 30 seconds
-- 
ALTER PROCEDURE killBlocker @transaction_id int
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @spid int;

    SELECT @spid = blocking_session_id
    FROM sys.dm_exec_sessions AS blocked_session
    INNER JOIN sys.dm_exec_requests AS blocked_request
        ON blocked_session.session_id = blocked_request.session_id
    INNER JOIN sys.dm_exec_sessions AS blocking_session
        ON blocked_request.blocking_session_id = blocking_session.session_id
    WHERE blocked_session.session_id = (
            SELECT DISTINCT request_session_id
            FROM sys.dm_tran_locks
            WHERE request_owner_id = @transaction_id
        )
        AND blocking_session.status = 'sleeping'
        AND blocking_session.last_request_start_time < DATEADD(second,-30,GETDATE());
    
    DECLARE @sql nvarchar(100) = 'KILL ' + CAST(@spid AS nvarchar(10));
    EXEC(@sql);
END