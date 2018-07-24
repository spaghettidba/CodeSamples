-- Activate SQL Server authentication
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2
GO

IF SUSER_ID('replayuser') IS NOT NULL 
BEGIN
	DECLARE @spid int
	DECLARE @whoToKill varchar(max)

	DECLARE killer CURSOR FAST_FORWARD 
	FOR
	SELECT session_id
	FROM sys.dm_exec_sessions
	WHERE login_name = 'replayuser'

	OPEN killer

	FETCH NEXT FROM killer INTO @spid

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @whoToKill = 'KILL ' + CAST(@spid AS varchar(50))
		EXEC(@whoToKill)
		FETCH NEXT FROM killer INTO @spid
	END

	CLOSE killer
	DEALLOCATE killer

	DROP LOGIN replayuser;
END

CREATE LOGIN replayuser WITH PASSWORD = 'replayuser', CHECK_POLICY = OFF;
GO

USE tempdb
GO

IF USER_ID('replayuser') IS NOT NULL 
	DROP USER replayuser;

CREATE USER replayuser FOR LOGIN replayuser
GO

EXEC sp_addrolemember 'db_owner', 'replayuser'
GO


USE ReplayDB
GO

IF USER_ID('replayuser') IS NOT NULL 
	DROP USER replayuser;

CREATE USER replayuser FOR LOGIN replayuser
GO

EXEC sp_addrolemember 'db_owner', 'replayuser'
GO
