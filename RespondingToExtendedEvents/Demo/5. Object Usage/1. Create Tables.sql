IF DB_ID('TOOLS') IS NULL
	CREATE DATABASE TOOLS;

USE TOOLS;
GO

IF SCHEMA_ID('meta') IS NULL
    EXEC('CREATE SCHEMA meta;')
GO
 
IF OBJECT_ID('meta.table_usage_xe') IS NULL
CREATE TABLE meta.table_usage_xe(
       db_name sysname,
       schema_name sysname,
       object_name sysname,
       client_app_name nvarchar(128),
       last_read datetime,
       last_write datetime,
       PRIMARY KEY(db_name, schema_name, object_name, client_app_name)
);
 
IF OBJECT_ID('meta.table_usage_xe_last_snapshot') IS NULL
CREATE TABLE meta.table_usage_xe_last_snapshot(
       database_id int,
       object_id int,
       client_app_name nvarchar(128),
       last_read datetime,
       last_write datetime,
       PRIMARY KEY(database_id, object_id, client_app_name)
);