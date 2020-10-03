USE master;

IF DB_ID('XESmartTargetTest') IS NOT NULL
BEGIN
	ALTER DATABASE XESmartTargetTest SET SINGLE_USER WITH ROLLBACK IMMEDIATE;	
	DROP DATABASE XESmartTargetTest;
END
GO

CREATE DATABASE XESmartTargetTest;
GO

USE XESmartTargetTest
GO

CREATE TABLE [dbo].[test_session_data](
	[cpu_time] [decimal](20, 0) NULL,
	[duration] [decimal](20, 0) NULL,
	[physical_reads] [decimal](20, 0) NULL,
	[logical_reads] [decimal](20, 0) NULL,
	[writes] [decimal](20, 0) NULL,
	[row_count] [decimal](20, 0) NULL,
	[batch_text] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO



USE master;
GO

