RAISERROR('You should not be running this script as a whole. Select the parts you want to run instead.',11,1)
	RETURN;

IF DB_ID('PICTURES') IS NULL
    CREATE DATABASE PICTURES;

USE PICTURES;


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


CREATE TABLE PicturesSmall (
	file_name nvarchar(128),
	description nvarchar(500),
	tags nvarchar(500),
	date_created datetime2,
	date_modified datetime2,
	contents varbinary(max)
)



CREATE TABLE PicturesSmall_1M (
	file_name nvarchar(128),
	description nvarchar(500),
	tags nvarchar(500),
	date_created datetime2,
	date_modified datetime2,
	contents varbinary(max)
)




INSERT INTO PicturesSmall_1M
SELECT TOP(1000000) P.*
FROM PicturesSmall AS P
CROSS JOIN sys.all_columns AS C1
CROSS JOIN sys.all_columns AS C2
CROSS JOIN sys.all_columns AS C3
CROSS JOIN sys.all_columns AS C4
CROSS JOIN sys.all_columns AS C5;

--------------------------------------------------
--  couldn't finish. Stopped after several hours
--------------------------------------------------


CREATE TABLE PicturesBig (
	file_name nvarchar(128),
	description nvarchar(500),
	tags nvarchar(500),
	date_created datetime2,
	date_modified datetime2,
	contents varbinary(max)
)



CREATE TABLE PicturesBig_1K (
	file_name nvarchar(128),
	description nvarchar(500),
	tags nvarchar(500),
	date_created datetime2,
	date_modified datetime2,
	contents varbinary(max)
)



INSERT INTO PicturesBig_1K
SELECT TOP(1000) P.*
FROM PicturesBig AS P
CROSS JOIN sys.all_columns AS C1
CROSS JOIN sys.all_columns AS C2
CROSS JOIN sys.all_columns AS C3
CROSS JOIN sys.all_columns AS C4
CROSS JOIN sys.all_columns AS C5;

--------------------------------
--        15 minutes 
--------------------------------





CREATE TABLE PicturesBig_1K_PAGE (
	file_name nvarchar(128),
	description nvarchar(500),
	tags nvarchar(500),
	date_created datetime2,
	date_modified datetime2,
	contents varbinary(max)
)
WITH (DATA_COMPRESSION = PAGE);



INSERT INTO PicturesBig_1K_PAGE
SELECT TOP(1000) P.*
FROM PicturesBig AS P
CROSS JOIN sys.all_columns AS C1
CROSS JOIN sys.all_columns AS C2
CROSS JOIN sys.all_columns AS C3
CROSS JOIN sys.all_columns AS C4
CROSS JOIN sys.all_columns AS C5;

--------------------------------
--        16 minutes 
--------------------------------




SELECT * 
FROM ssms_disk_usage_top_tables



-- ################################################################ --
--                        FILESTREAM
-- ################################################################ --



CREATE TABLE PicturesBig_1K_FILESTREAM (
	rowguid uniqueidentifier NOT NULL ROWGUIDCOL default(newsequentialid()) UNIQUE,
	file_name nvarchar(128),
	description nvarchar(500),
	tags nvarchar(500),
	date_created datetime2,
	date_modified datetime2,
	contents varbinary(max) FILESTREAM
)



INSERT INTO PicturesBig_1K_FILESTREAM ([file_name], [description], [tags], [date_created], [date_modified], [contents])
SELECT TOP(1000) P.*
FROM PicturesBig AS P
CROSS JOIN sys.all_columns AS C1
CROSS JOIN sys.all_columns AS C2
CROSS JOIN sys.all_columns AS C3
CROSS JOIN sys.all_columns AS C4
CROSS JOIN sys.all_columns AS C5;

--------------------------------
--        10 minutes 
--------------------------------


SELECT * 
FROM ssms_disk_usage_top_tables






CREATE TABLE PicturesSmall_1M_FILESTREAM (
	rowguid uniqueidentifier NOT NULL ROWGUIDCOL default(newsequentialid()) UNIQUE,
	file_name nvarchar(128),
	description nvarchar(500),
	tags nvarchar(500),
	date_created datetime2,
	date_modified datetime2,
	contents varbinary(max) FILESTREAM
)



INSERT INTO PicturesSmall_1M_FILESTREAM ([file_name], [description], [tags], [date_created], [date_modified], [contents])
SELECT TOP(1000000) P.*
FROM PicturesSmall AS P
CROSS JOIN sys.all_columns AS C1
CROSS JOIN sys.all_columns AS C2
CROSS JOIN sys.all_columns AS C3
CROSS JOIN sys.all_columns AS C4
CROSS JOIN sys.all_columns AS C5;


--------------------------------
--        2 hours
--------------------------------


SELECT * 
FROM ssms_disk_usage_top_tables