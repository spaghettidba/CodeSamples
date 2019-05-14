SET NOEXEC OFF;
:setvar sqlcmdEnabled "sqlcmdEnabled"
GO

IF ('$(sqlcmdEnabled)' = '$' + '(sqlcmdEnabled)')
BEGIN
    RAISERROR ('This script must be run in SQLCMD mode.', 1, 1);
	SET NOEXEC ON;
END
GO

/*
 * CREATE CREDENTIALS AND PROXIES
 */
USE [master]
GO
IF NOT EXISTS (SELECT * FROM sys.credentials WHERE name = 'pscredential')
CREATE CREDENTIAL [pscredential] WITH IDENTITY = N'$(SQLCMDWORKSTATION)\Administrator', SECRET = N'P4$$w0rd!'
GO

USE [msdb]
GO
IF NOT EXISTS (SELECT * FROM sysproxies WHERE name = 'psproxy')
BEGIN
	EXEC msdb.dbo.sp_add_proxy @proxy_name=N'psproxy',@credential_name=N'pscredential', @enabled=1
	EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'psproxy', @subsystem_id=3
END
GO



/*
 * CREATE JOB
 */
USE [msdb]
GO


BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = 'DBA_COLLECT_AUDIT_LOGIN')
	EXEC msdb.dbo.sp_delete_job @job_name = 'DBA_COLLECT_AUDIT_LOGIN'

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
DECLARE @cmd nvarchar(max) = N'powershell -File "$(targetDir)\5. Collect_Audit_Login.ps1" -servername '+ char(36) +'(ESCAPE_DQUOTE(SRVR))';

EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_COLLECT_AUDIT_LOGIN', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [COLLECT]    Script Date: 03/08/15 22:36:47 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'COLLECT', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, 
		@subsystem=N'CmdExec', 
		@command=@cmd, 
		@flags=0, 
		@proxy_name=N'psproxy'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'EVERY MINUTE', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150227, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


EXEC msdb.dbo.sp_start_job @job_name = 'DBA_COLLECT_AUDIT_LOGIN'
GO