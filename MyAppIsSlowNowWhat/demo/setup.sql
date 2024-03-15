USE WorkloadTools

DECLARE @name sysname
DECLARE @sql nvarchar(max)

DECLARE c CURSOR STATIC LOCAL FORWARD_ONLY READ_ONLY
FOR
SELECT name
FROM sys.tables
WHERE OBJECT_SCHEMA_NAME(object_id) = 'troubleshooting'

OPEN c
FETCH NEXT FROM c INTO @name

WHILE @@FETCH_STATUS = 0 
BEGIN
	SET @sql = 'DROP TABLE troubleshooting.' + QUOTENAME(@name)
	EXEC(@sql)
	FETCH NEXT FROM c INTO @name
END

CLOSE c
DEALLOCATE c