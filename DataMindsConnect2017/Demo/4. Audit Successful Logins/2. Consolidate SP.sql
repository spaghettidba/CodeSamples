USE [TOOLS]
GO


IF OBJECT_ID('spConsolidateAuditLogin') IS NOT NULL 
	EXEC('DROP PROCEDURE spConsolidateAuditLogin')
GO


CREATE PROCEDURE [dbo].[spConsolidateAuditLogin]
AS
BEGIN

    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#AuditLogin_Staging') IS NOT NULL
        DROP TABLE #AuditLogin_Staging;

    -- create a temporary table to avoid interfering with
    -- other rows being inserted by the collect job

    CREATE TABLE #AuditLogin_Staging(
        [event_date] [datetime] NULL,
        [original_login] [nvarchar](128) NULL,
        [host_name] [nvarchar](128) NULL,
        [program_name] [nvarchar](255) NULL,
        [database_name] [nvarchar](128) NULL
    );

    -- move all rows from the staging table to the 
    -- temporary table 

    DELETE 
    FROM dbo.AuditLogin_Staging
    OUTPUT DELETED.* INTO #AuditLogin_Staging
	WHERE 1 = 1; -- avoid obnoxious unsafe operation warning

    
    -- Merge rows into the destination table

    MERGE INTO [AuditLogin] AS AuditLogin
        USING (
            SELECT 
                MAX(event_date) AS event_date,
                original_login, 
                host_name, 
                program_name, 
                database_name,
                NTDomainName,
                NTUserName,
                COUNT(*) AS LogonCount
            FROM (
                SELECT event_date, 
                    original_login, 
                    host_name, 
                    program_name, 
                    database_name,
                    NtDomainName = CASE SSP.type WHEN 'U' THEN LEFT(SSP.name,CHARINDEX('\',SSP.name,1)-1) ELSE '' END,
                    NtUserName = CASE SSP.type WHEN 'U' THEN RIGHT(SSP.name,LEN(ssp.name) - CHARINDEX('\',SSP.name,1)) ELSE '' END
                FROM #AuditLogin_Staging AS ALA
                INNER JOIN sys.server_principals AS SSP
                    ON ALA.original_login = SSP.name
            ) AS the_data
            GROUP BY 
                original_login, 
                host_name, 
                program_name, 
                database_name,
                NTDomainName,
                NTUserName
        ) AS src (PostTime,LoginName,HostName,ApplicationName,DatabaseName,NtDomainName,NtUserName,LogonCount)
            ON  AuditLogin.LoginName       = src.LoginName
            AND AuditLogin.HostName        = src.HostName
            AND AuditLogin.ApplicationName = src.ApplicationName
            AND AuditLogin.DatabaseName    = src.DatabaseName
        WHEN MATCHED THEN 
            UPDATE SET
                 LastSeen    = GETDATE()
                ,LogonCount	+= src.LogonCount
        WHEN NOT MATCHED THEN
            INSERT (
                 LoginName
                ,HostName
                ,NTUserName
                ,NTDomainName
                ,ApplicationName
                ,DatabaseName
                ,FirstSeen
                ,LastSeen
                ,LogonCount
            )
            VALUES (
                 src.LoginName
                ,src.HostName
                ,src.NTDomainName
                ,src.NTUserName
                ,src.ApplicationName
                ,src.DatabaseName
                ,src.PostTime
                ,src.PostTime
                ,src.LogonCount
            );
END
GO