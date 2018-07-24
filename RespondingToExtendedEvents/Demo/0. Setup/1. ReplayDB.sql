IF DB_ID('ReplayDB') IS NULL
	CREATE DATABASE ReplayDB;
GO

USE replayDB
GO

IF OBJECT_ID('testNumbers') IS NOT NULL 
	DROP TABLE testNumbers

CREATE TABLE testNumbers (
	num int identity(1,1)
)
GO
