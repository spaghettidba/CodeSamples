IF DB_ID('TOOLS') IS NULL
	CREATE DATABASE TOOLS;
GO

USE [TOOLS]
GO

IF OBJECT_ID('AuditLogin_Staging') IS NOT NULL
	DROP TABLE AuditLogin_Staging;

-- A table to stage single logon events

CREATE TABLE [dbo].[AuditLogin_Staging](
	[event_date] [datetime] NULL,
	[original_login] [nvarchar](128) NULL,
	[host_name] [nvarchar](128) NULL,
	[program_name] [nvarchar](255) NULL,
	[database_name] [nvarchar](128) NULL
);

GO


IF OBJECT_ID('AuditLogin') IS NOT NULL
	DROP TABLE AuditLogin;

-- A table to store a summary of events

CREATE TABLE [dbo].[AuditLogin](
	[LoggingID] [int] IDENTITY(1,1) PRIMARY KEY CLUSTERED,
	[LoginName] [sysname] NOT NULL,
	[HostName] [varchar](128) NULL,
	[NTUserName] [varchar](100) NULL,
	[NTDomainName] [varchar](100) NULL,
	[ApplicationName] [varchar](255) NULL,
	[DatabaseName] [sysname] NULL,
	[FirstSeen] [datetime] NULL,
	[LastSeen] [datetime] NULL,
	[LogonCount] [bigint] NULL
);

GO

CREATE UNIQUE NONCLUSTERED INDEX UQ_AuditLogin ON AuditLogin (
	LoginName, 
	HostName, 
	ApplicationName,
	DatabaseName
)

GO

