RAISERROR('You should not be running this script as a whole. Select the parts you want to run instead.',11,1)
	RETURN;

USE LOGS;

-- ################################################################ --
--                        PARTITIONING
-- ################################################################ --

-- partition function

CREATE PARTITION FUNCTION PF_LOGS(datetime)
AS RANGE LEFT FOR VALUES (
	'20140301',
	'20140401',
	'20140501',
	'20140601',
	'20140701',
	'20140801',
	'20140901',
	'20141001',
	'20141101',
	'20141201',
	'20150101',
	'20150201',
	'20150301',
	'20150401',
	'20150501',
	'20150601',
	'20150701',
	'20150801',
	'20150901',
	'20151001',
	'20151101',
	'20151201',
	'20160101',
	'20160201',
	'20160301',
	'20160401',
	'20160501',
	'20160601',
	'20160701',
	'20160801',
	'20160901',
	'20161001',
	'20161101',
	'20161201',
	'20170101',
	'20170201',
	'20170301',
	'20170401',
	'20170501'
)


CREATE PARTITION SCHEME PS_LOGS AS PARTITION PF_LOGS ALL TO ([PRIMARY])



IF OBJECT_ID('LogTable_CCI_100M_PARTITIONED') IS NOT NULL
DROP TABLE [LogTable_CCI_100M_PARTITIONED];




IF OBJECT_ID('LogTable_CCI_100M_PARTITIONED') IS NULL
CREATE TABLE [dbo].[LogTable_CCI_100M_PARTITIONED](
	[logdate] [datetime] NULL,
	[level] [varchar](5) NULL,
	[type] [varchar](5) NULL,
	[msg] [varchar](8000) NULL,
    INDEX CCI_LogTable_CCI CLUSTERED COLUMNSTORE ON PS_LOGS(logdate)
) 
ON PS_LOGS(logdate)



ALTER TABLE [LogTable_CCI_100M_PARTITIONED]   
REBUILD PARTITION = ALL WITH (
	DATA_COMPRESSION = COLUMNSTORE_ARCHIVE ON PARTITIONS (1 TO 38),
	DATA_COMPRESSION = COLUMNSTORE ON PARTITIONS (39)
) ;  
GO

DECLARE @startTime datetime2 = SYSDATETIME();

INSERT INTO [LogTable_CCI_100M_PARTITIONED]
SELECT TOP 100000000 *
FROM LogTable;

-- record performance and space used
EXEC BuildStats 
	@tablename = 'LogTable_CCI_100M_PARTITIONED',
	@compressed = 'MIXED',
	@partitioned = 'YES',
	@avg_msg_size = 192,
	@startTime = @startTime;



SELECT * 
FROM ssms_disk_usage_top_tables 
WHERE tablename IN ('LogTable_CCI_100M_PARTITIONED')
ORDER BY reserved DESC;


-- show partitions
SELECT
    OBJECT_SCHEMA_NAME(pstats.object_id) AS SchemaName
    ,OBJECT_NAME(pstats.object_id) AS TableName
    ,ps.name AS PartitionSchemeName
    ,ds.name AS PartitionFilegroupName
    ,pf.name AS PartitionFunctionName
    ,CASE pf.boundary_value_on_right WHEN 0 THEN 'Range Left' ELSE 'Range Right' END AS PartitionFunctionRange
    ,CASE pf.boundary_value_on_right WHEN 0 THEN 'Upper Boundary' ELSE 'Lower Boundary' END AS PartitionBoundary
    ,prv.value AS PartitionBoundaryValue
    ,c.name AS PartitionKey
    ,CASE 
        WHEN pf.boundary_value_on_right = 0 
        THEN c.name + ' > ' + CAST(ISNULL(LAG(prv.value) OVER(PARTITION BY pstats.object_id ORDER BY pstats.object_id, pstats.partition_number), 'Infinity') AS VARCHAR(100)) + ' and ' + c.name + ' <= ' + CAST(ISNULL(prv.value, 'Infinity') AS VARCHAR(100)) 
        ELSE c.name + ' >= ' + CAST(ISNULL(prv.value, 'Infinity') AS VARCHAR(100))  + ' and ' + c.name + ' < ' + CAST(ISNULL(LEAD(prv.value) OVER(PARTITION BY pstats.object_id ORDER BY pstats.object_id, pstats.partition_number), 'Infinity') AS VARCHAR(100))
    END AS PartitionRange
    ,pstats.partition_number AS PartitionNumber
    ,pstats.row_count AS PartitionRowCount
    ,p.data_compression_desc AS DataCompression
	,pstats.reserved_page_count * 8 AS reserved
	,pstats.used_page_count * 8 AS used
FROM sys.dm_db_partition_stats AS pstats
INNER JOIN sys.partitions AS p ON pstats.partition_id = p.partition_id
INNER JOIN sys.destination_data_spaces AS dds ON pstats.partition_number = dds.destination_id
INNER JOIN sys.data_spaces AS ds ON dds.data_space_id = ds.data_space_id
INNER JOIN sys.partition_schemes AS ps ON dds.partition_scheme_id = ps.data_space_id
INNER JOIN sys.partition_functions AS pf ON ps.function_id = pf.function_id
INNER JOIN sys.indexes AS i ON pstats.object_id = i.object_id AND pstats.index_id = i.index_id AND dds.partition_scheme_id = i.data_space_id AND i.type IN(0,1,5) /* Heap or Clustered Index */
INNER JOIN sys.index_columns AS ic ON i.index_id = ic.index_id AND i.object_id = ic.object_id AND ic.partition_ordinal > 0
INNER JOIN sys.columns AS c ON pstats.object_id = c.object_id AND ic.column_id = c.column_id
LEFT JOIN sys.partition_range_values AS prv ON pf.function_id = prv.function_id AND pstats.partition_number = (CASE pf.boundary_value_on_right WHEN 0 THEN prv.boundary_id ELSE (prv.boundary_id+1) END)
WHERE pstats.object_id = OBJECT_ID('LogTable_CCI_100M_PARTITIONED')
ORDER BY TableName, PartitionNumber;



