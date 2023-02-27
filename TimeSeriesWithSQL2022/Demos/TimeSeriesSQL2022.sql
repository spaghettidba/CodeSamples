RETURN


PRINT 'You should not reach here'


IF DB_ID('TimeSeriesTest') IS NULL
BEGIN
    CREATE DATABASE TimeSeriesTest;
    ALTER DATABASE TimeSeriesTest SET RECOVERY SIMPLE;
END


USE TimeSeriesTest


IF OBJECT_ID('sqlserver_performance_staging') IS NULL
BEGIN
    CREATE TABLE sqlserver_performance_staging (
        [name] nvarchar(128),
        [time] bigint,
        [agent] nvarchar(50),
        [company] nvarchar(50),
        [counter] nvarchar(128),
        [counter_type] int,
        [host] nvarchar(128),
        [instance] nvarchar(128),
        [measurement_db_type] nvarchar(128),
        [object] nvarchar(128),
        [sql_instance] nvarchar(128),
        [value] bigint
    );
END




IF OBJECT_ID('sqlserver_performance') IS NULL
BEGIN
    CREATE TABLE sqlserver_performance (
        [name] nvarchar(128),
        [time] datetime2,
        [agent] nvarchar(50),
        [company] nvarchar(50),
        [counter] nvarchar(128),
        [counter_type] int,
        [host] nvarchar(128),
        [instance] nvarchar(128),
        [measurement_db_type] nvarchar(128),
        [object] nvarchar(128),
        [sql_instance] nvarchar(128),
        [value] bigint
    );
END


SELECT TOP 100 * FROM sqlserver_performance;



 -- ############################################
 -- DATA COMPRESSION WITH COLUMNSTORE
 -- ############################################


 
IF OBJECT_ID('sqlserver_performance_cci') IS NULL
BEGIN
    CREATE TABLE sqlserver_performance_cci (
        [name] nvarchar(128),
        [time] datetime2,
        [agent] nvarchar(50),
        [company] nvarchar(50),
        [counter] nvarchar(128),
        [counter_type] int,
        [host] nvarchar(128),
        [instance] nvarchar(128),
        [measurement_db_type] nvarchar(128),
        [object] nvarchar(128),
        [sql_instance] nvarchar(128),
        [value] bigint,
        INDEX cci_sqlserver_performance_cci CLUSTERED COLUMNSTORE
    );

END




IF OBJECT_ID('sqlserver_performance_cci_archive') IS NULL
BEGIN
    CREATE TABLE sqlserver_performance_cci_archive (
        [name] nvarchar(128),
        [time] datetime2,
        [agent] nvarchar(50),
        [company] nvarchar(50),
        [counter] nvarchar(128),
        [counter_type] int,
        [host] nvarchar(128),
        [instance] nvarchar(128),
        [measurement_db_type] nvarchar(128),
        [object] nvarchar(128),
        [sql_instance] nvarchar(128),
        [value] bigint,
        INDEX cci_sqlserver_performance_cci_archive CLUSTERED COLUMNSTORE
            WITH (DATA_COMPRESSION = COLUMNSTORE_ARCHIVE)
    );

END




 -- ############################################
 -- RETENTION PERIOD
 -- ############################################

SELECT is_data_retention_enabled, name
FROM sys.databases;

select name, data_retention_period, data_retention_period_unit from sys.tables


-- does not work: not _ALL_ features are coming to 2022 after all...
ALTER TABLE [dbo].[sqlserver_performance]
SET (DATA_DELETION = ON (FILTER_COLUMN = [time], RETENTION_PERIOD = 1 month))




 -- ############################################
 -- PARTITIONING
 -- ############################################



CREATE PARTITION FUNCTION PF_TIMESERIES(datetime2)
AS RANGE LEFT FOR VALUES (
    '20220929',
    '20220930',
    '20221001',
    '20221002',
    '20221003',
    '20221004',
    '20221005',
    '20221006',
    '20221007',
    '20221008',
    '20221009',
    '20221010',
    '20221011',
    '20221012',
    '20221013',
    '20221014',
    '20221015'
);


CREATE PARTITION SCHEME PS_TIMESERIES 
    AS PARTITION PF_TIMESERIES 
    ALL TO ([PRIMARY]);




 
IF OBJECT_ID('sqlserver_performance_cci_partitioned') IS NULL
BEGIN
    CREATE TABLE sqlserver_performance_cci_partitioned (
        [name] nvarchar(128),
        [time] datetime2,
        [agent] nvarchar(50),
        [company] nvarchar(50),
        [counter] nvarchar(128),
        [counter_type] int,
        [host] nvarchar(128),
        [instance] nvarchar(128),
        [measurement_db_type] nvarchar(128),
        [object] nvarchar(128),
        [sql_instance] nvarchar(128),
        [value] bigint,
        INDEX cci_sqlserver_performance_cci_partitioned CLUSTERED COLUMNSTORE
            ON PS_TIMESERIES(time)
    )
    ON PS_TIMESERIES(time);
END




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
WHERE pstats.object_id = OBJECT_ID('sqlserver_performance_cci_partitioned')
ORDER BY TableName, PartitionNumber;



 -- ############################################
 -- DATE_BUCKET
 -- ############################################


SELECT DATE_BUCKET(hour, 1, time) AS time, AVG(value) AS avg_lazy_writes_sec
FROM [dbo].[sqlserver_performance_cci_partitioned]
WHERE time >= '2022-10-01' 
    AND time < '2022-10-02' 
    AND counter = 'Lazy writes/sec'
    AND sql_instance = 'SQLCSRV04:SQL2017'
GROUP BY DATE_BUCKET(hour, 1, time)
ORDER BY 1




 -- ############################################
 -- GENERATE SERIES
 -- ############################################

 SELECT *
 FROM GENERATE_SERIES(1, 100);


 -- ############################################
 -- DATE_BUCKET AND GENERATE SERIES COMBINED
 -- ############################################


WITH actual_data AS (
    SELECT DATE_BUCKET(hour, 1, time) AS time, 
           AVG(value) AS avg_lazy_writes_sec
    FROM [dbo].[sqlserver_performance_cci_partitioned]
    WHERE time >= '2022-10-01'
        AND time < '2022-10-02'
        AND counter = 'Lazy writes/sec'
        AND sql_instance = 'SQLCSRV04:SQL2017'
        AND NOT time BETWEEN '2022-10-01 10:00' AND '2022-10-01 13:00'
    GROUP BY DATE_BUCKET(hour, 1, time)
),
intervals AS (
    SELECT DATEADD(hour, value, '2022-10-01') AS time
    FROM GENERATE_SERIES(0, DATEDIFF(hour, '2022-10-01', '2022-10-02') -1)
)
SELECT i.time, d.avg_lazy_writes_sec
FROM intervals AS i
LEFT JOIN actual_data AS d
    ON i.time = d.time
ORDER BY 1;

