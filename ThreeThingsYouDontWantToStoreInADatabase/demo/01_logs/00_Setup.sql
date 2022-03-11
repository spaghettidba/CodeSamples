RAISERROR('You should not be running this script as a whole. Select the parts you want to run instead.',11,1)
	RETURN;

IF DB_ID('LOGS') IS NULL
    CREATE DATABASE LOGS;

USE LOGS;


IF OBJECT_ID('LogTable') IS NULL
CREATE TABLE [dbo].[LogTable](
	[logdate] [datetime] NULL,
	[level] [varchar](5) NULL,
	[type] [varchar](5) NULL,
	[msg] [varchar](8000) NULL
) 



-- Import 26 GB text file using Log Parser
--
-- .\LogParser.exe "SELECT TO_TIMESTAMP(substr(text,0,19),'yyyy-MM-dd hh:mm:ss') AS logdate, substr(text,21,4) as level, substr(text,43,3) as type, substr(text,50,100000) as msg INTO LogTable FROM 'C:\Users\gsartori\Downloads\Windows.log' WHERE type <> ''" -o:SQL -server:QDSRV05 -database:LOGS -driver:"SQL Server" -createTable:OFF
--



-- let's create a view to mimic what the report "disk usage by top tables" does
IF OBJECT_ID('ssms_disk_usage_top_tables') IS NULL
EXEC('CREATE VIEW ssms_disk_usage_top_tables AS SELECT 1 AS one');

ALTER VIEW ssms_disk_usage_top_tables 
AS
SELECT TOP 1000
	a2.name AS [tablename],
	a1.rows as row_count,
	(a1.reserved + ISNULL(a4.reserved,0))* 8 AS reserved,
	a1.data * 8 AS data,
	(CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN (a1.used + ISNULL(a4.used,0)) - a1.data ELSE 0 END) * 8 AS index_size,
	(CASE WHEN (a1.reserved + ISNULL(a4.reserved,0)) > a1.used THEN (a1.reserved + ISNULL(a4.reserved,0)) - a1.used ELSE 0 END) * 8 AS unused
FROM
(
	SELECT
		ps.object_id,
		SUM (CASE WHEN (ps.index_id < 2) THEN row_count ELSE 0 END) AS [rows],
		SUM (ps.reserved_page_count) AS reserved,
		SUM (
			CASE
				WHEN (ps.index_id < 2) THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count)
				ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count)
			END
		) AS data,
		SUM (ps.used_page_count) AS used
	FROM sys.dm_db_partition_stats ps
	WHERE ps.object_id NOT IN (SELECT object_id FROM sys.tables WHERE is_memory_optimized = 1)
	GROUP BY ps.object_id
) AS a1
LEFT OUTER JOIN
(	SELECT
		it.parent_id,
		SUM(ps.reserved_page_count) AS reserved,
		SUM(ps.used_page_count) AS used
	FROM sys.dm_db_partition_stats ps
	INNER JOIN sys.internal_tables it 
		ON it.object_id = ps.object_id
	WHERE it.internal_type IN (202,204)
	GROUP BY it.parent_id
) AS a4 
	ON a4.parent_id = a1.object_id
INNER JOIN sys.all_objects a2  
	ON a1.object_id = a2.object_id
INNER JOIN sys.schemas a3 
	ON a2.schema_id = a3.schema_id
WHERE a2.type <> N'S'
	and a2.type <> N'IT'
ORDER BY reserved DESC



IF OBJECT_ID('space_used') IS NULL
SELECT TOP 0 *, 
	CAST('' AS varchar(20)) AS compressed,
	CAST(1 AS varchar(20)) AS partitioned,
	1 AS avg_msg_size
INTO space_used
FROM ssms_disk_usage_top_tables


IF OBJECT_ID('time_taken') IS NULL
CREATE TABLE time_taken (
	operation varchar(10),
	tablename sysname,
	compressed varchar(20),
	partitioned varchar(20),
	avg_msg_size int,
	duration_ms bigint
)




IF OBJECT_ID('BuildStats') IS NULL
EXEC('
CREATE PROCEDURE BuildStats
AS RETURN
');

ALTER PROCEDURE BuildStats 
	@tablename sysname,
	@compressed varchar(20),
	@partitioned varchar(20),
	@avg_msg_size int,
	@startTime datetime2,
	@operation varchar(20) = 'INSERT'
AS
BEGIN

	MERGE INTO time_taken AS dest
	USING (
		SELECT 
			@operation AS operation,
			@tableName AS tablename,
			@compressed AS compressed,
			@partitioned AS partitioned,
			@avg_msg_size AS avg_msg_size,
			DATEDIFF(millisecond, @startTime, SYSDATETIME()) AS duration_ms
	) AS src
		ON  dest.operation = src.operation
		AND dest.tablename = src.tablename
		AND dest.compressed = src.compressed
		AND dest.partitioned = src.partitioned
		AND dest.avg_msg_size = src.avg_msg_size
	WHEN MATCHED THEN UPDATE
		SET duration_ms = src.duration_ms
	WHEN NOT MATCHED THEN INSERT
		(operation, tablename, compressed, partitioned, avg_msg_size, duration_ms)
		VALUES
		(src.operation, src.tablename, src.compressed, src.partitioned, src.avg_msg_size, src.duration_ms);


	MERGE INTO space_used AS dest
	USING (
		SELECT *,
			@compressed AS compressed,
			@partitioned AS partitioned,
			@avg_msg_size AS avg_msg_size
		FROM ssms_disk_usage_top_tables
		WHERE tablename = @tableName
	) AS src
		ON  src.tablename = dest.tablename
		AND src.compressed = dest.compressed
		AND src.partitioned = dest.partitioned
		AND src.avg_msg_size = dest.avg_msg_size
	WHEN MATCHED THEN UPDATE
		SET row_count = src.row_count,
		    reserved = src.reserved,
			data = src.data,
			index_size = src.index_size,
			unused = src.unused
	WHEN NOT MATCHED THEN INSERT
		(tablename, row_count, reserved, data, index_size, unused, compressed, partitioned, avg_msg_size)
	VALUES
		(src.tablename, src.row_count, src.reserved, src.data, src.index_size, src.unused, src.compressed, src.partitioned, src.avg_msg_size);

END




IF OBJECT_ID('TestLogPerformance') IS NULL
EXEC('
CREATE PROCEDURE TestLogPerformance @tableType varchar(100), @millionRows int
AS RETURN
');

ALTER PROCEDURE TestLogPerformance 
	@tableType varchar(100), 
	@millionRows int,
	@compressed varchar(20) = 'NO',
	@partitioned varchar(20) = 'NO',
	@avg_msg_size int = 192
AS
BEGIN
	DECLARE @sql nvarchar(max);
	DECLARE @numName nvarchar(5) = CAST(@millionRows AS nvarchar(5)) + N'M';

	DECLARE @tableName sysname = 'LogTable_' + @tableType + '_' + @numName + CASE WHEN @compressed <> 'NO' THEN '_' + @compressed ELSE '' END

	SET @sql = '
		CREATE TABLE [dbo].[' + @tableName + '](
			[logdate] [datetime] NULL,
			[level] [varchar](5) NULL,
			[type] [varchar](5) NULL,
			[msg] [varchar](8000) NULL,
			'+
			CASE @tableType 
				WHEN 'heap' THEN ''
				WHEN 'CI' THEN 'INDEX CI_LogTable CLUSTERED (logdate) ' + CASE @compressed WHEN 'PAGE' THEN ' WITH (DATA_COMPRESSION = PAGE) ' ELSE '' END
				WHEN 'CCI' THEN 'INDEX CCI_LogTable CLUSTERED COLUMNSTORE ' + CASE WHEN @compressed IN('COLUNSTORE','COLUMNSTORE_ARCHIVE') THEN ' WITH (DATA_COMPRESSION = '+ @compressed +') ' ELSE '' END
			END
			+'
		) '+ CASE WHEN @compressed = 'PAGE' AND @tableType = 'heap' THEN ' WITH (DATA_COMPRESSION = PAGE) ' ELSE '' END +'
	';

	PRINT @sql;

	IF OBJECT_ID(@tableName) IS NULL
		EXEC(@sql);

	SET @sql = 'TRUNCATE TABLE [' + @tableName + ']'
	EXEC(@sql);

	DECLARE @startTime datetime2 = SYSDATETIME();

	SET @sql = '
		INSERT INTO [' + @tableName + ']
		SELECT TOP ' + CAST(@millionRows * 1000000 AS varchar(20)) + ' *
		FROM LogTable
	';

	PRINT @sql;
	EXEC(@sql);

	-- record performance and space used
	EXEC BuildStats 
		@tablename = @tableName,
		@compressed = @compressed,
		@partitioned = @partitioned,
		@avg_msg_size = @avg_msg_size,
		@startTime = @startTime;
	

END





