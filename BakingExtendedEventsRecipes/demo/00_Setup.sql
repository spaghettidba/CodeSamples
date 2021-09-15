USE master;
GO
IF DB_ID('XERecipes') IS NOT NULL
BEGIN
    ALTER DATABASE XERecipes SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE XERecipes;
END
GO

CREATE DATABASE XERecipes;
GO

IF SUSER_ID('grafana') IS NULL
CREATE LOGIN grafana WITH PASSWORD = 'grafana', CHECK_POLICY = OFF
GO

USE XERecipes;
GO
CREATE USER grafana FOR LOGIN grafana;
ALTER ROLE db_datareader ADD MEMBER grafana;
GO

USE XERecipes;
GO
CREATE TABLE Recipe_02_Queries (
    name nvarchar(128), 
    collection_time datetime2, 
    client_app_name nvarchar(255), 
    server_principal_name nvarchar(128), 
    database_name nvarchar(128),
    batch_text nvarchar(max),
    statement nvarchar(max)
);
GO

USE XERecipes;
GO
CREATE TABLE Recipe_03_Queries (
    name nvarchar(128), 
    collection_time datetime2, 
    client_app_name nvarchar(255), 
    server_principal_name nvarchar(128), 
    database_name nvarchar(128),
    sql nvarchar(max),
    total_io int
);
GO

USE XERecipes;
GO
CREATE TABLE Recipe_04_Blocking (
    name nvarchar(128), 
    collection_time datetime2, 
    blocked_process nvarchar(max), 
    server_principal_name nvarchar(128), 
    database_name nvarchar(128),
    sql_text nvarchar(max),
    duration int
);
GO

USE XERecipes;
GO
CREATE TABLE Recipe_04_Deadlocking (
    name nvarchar(128), 
    collection_time datetime2, 
    client_app_name nvarchar(255), 
    server_principal_name nvarchar(128), 
    database_name nvarchar(128),
    xml_report nvarchar(max)
);
GO



USE XERecipes;
GO
CREATE TABLE Recipe_06_LoginAudit (
    server_principal_name nvarchar(128), 
    database_name nvarchar(128), 
    client_app_name nvarchar(255), 
    first_seen datetime2, 
    last_seen datetime2, 
    logon_count bigint
);
GO



USE XERecipes;
GO
CREATE TABLE Recipe_07_TableAudit (
    client_app_name nvarchar(255), 
    database_id int,
    object_id int,
    last_read datetime2, 
    last_write datetime2, 
    read_count bigint,
    write_count bigint
);
GO

USE XERecipes;
GO
CREATE TABLE Recipe_08_WorkloadAnalysis (
    snapshot_id varchar(20),
    client_app_name nvarchar(255),
    server_principal_name nvarchar(128),
    database_name nvarchar(128),
    tot_cpu bigint,
    tot_duration bigint,
    tot_reads bigint,
    tot_writes bigint,
    execution_count bigint,
    UNIQUE (snapshot_id, client_app_name, server_principal_name, database_name)
)
GO

IF OBJECT_ID('Recipe_08_WorkloadAnalysis_grafana') IS NULL
BEGIN
    EXEC('CREATE VIEW Recipe_08_WorkloadAnalysis_grafana AS SELECT 1 AS one');
END
GO

ALTER VIEW Recipe_08_WorkloadAnalysis_grafana
AS
SELECT 
    PARSE(snapshot_id AS datetime USING 'it-IT') AT TIME ZONE 'Central European Standard Time' AT TIME ZONE 'UTC' AS time,
    server_principal_name,
    client_app_name,
    database_name,
    SUM([tot_cpu]) AS tot_cpu, 
    SUM([tot_duration]) AS tot_duration, 
    SUM([tot_reads]) AS tot_reads, 
    SUM([tot_writes]) AS tot_writes, 
    SUM([execution_count]) AS execution_count
FROM XERecipes.dbo.Recipe_08_WorkloadAnalysis
GROUP BY 
    PARSE(snapshot_id AS datetime USING 'it-IT'),
    server_principal_name,
    client_app_name,
    database_name;
GO

USE master;
GO

DECLARE @name sysname;
DECLARE @sql nvarchar(max);

DECLARE c CURSOR STATIC LOCAL FORWARD_ONLY READ_ONLY
FOR
SELECT name FROM sys.server_event_sessions WHERE name LIKE 'Recipe%';

OPEN c;
FETCH NEXT FROM c INTO @name;

WHILE @@FETCH_STATUS = 0
BEGIN 

    SET @sql = 'DROP EVENT SESSION ' + QUOTENAME(@name) + ' ON SERVER ';
    EXEC(@sql);

    FETCH NEXT FROM c INTO @name;
END

CLOSE c;
DEALLOCATE c;
GO