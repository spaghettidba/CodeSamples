RAISERROR('You should not be running this script as a whole. Select the parts you want to run instead.',11,1)
	RETURN;


USE LOGS;


-- ################################################################ --
--                        ONE MILLION ROWS
-- ################################################################ --

EXEC TestLogPerformance 'heap', 1
EXEC TestLogPerformance 'CI', 1


SELECT *
FROM time_taken 
WHERE tablename LIKE 'LogTable[_]%[_]1M'

SELECT *
FROM space_used
WHERE tablename LIKE 'LogTable[_]%[_]1M'
ORDER BY reserved DESC


-- ################################################################ --
--                        TWO MILLION ROWS
-- ################################################################ --


EXEC TestLogPerformance 'heap', 2
EXEC TestLogPerformance 'CI', 2


SELECT *
FROM time_taken 
WHERE tablename LIKE 'LogTable[_]%[_]2M'

SELECT *
FROM space_used
WHERE tablename LIKE 'LogTable[_]%[_]2M'
ORDER BY reserved DESC


-- ################################################################ --
--                        FIVE MILLION ROWS
-- ################################################################ --



EXEC TestLogPerformance 'heap', 5
EXEC TestLogPerformance 'CI', 5


SELECT *
FROM time_taken 
WHERE tablename LIKE 'LogTable[_]%[_]5M'

SELECT *
FROM space_used
WHERE tablename LIKE 'LogTable[_]%[_]5M'
ORDER BY reserved DESC



-- ################################################################ --
--                        TEN MILLION ROWS
-- ################################################################ --



EXEC TestLogPerformance 'heap', 10
EXEC TestLogPerformance 'CI', 10


SELECT *
FROM time_taken 
WHERE tablename LIKE 'LogTable[_]%[_]10M'

SELECT *
FROM space_used
WHERE tablename LIKE 'LogTable[_]%[_]10M'
ORDER BY reserved DESC



-- ################################################################ --
--                        FIFTY MILLION ROWS
-- ################################################################ --



EXEC TestLogPerformance 'heap', 50
EXEC TestLogPerformance 'CI', 50

SELECT * FROM [dbo].[LogTable_heap_50M] WHERE logdate > '20140301' AND logdate < '20140401' 
SELECT * FROM [dbo].[LogTable_CI_50M] WHERE logdate > '20140301' AND logdate < '20140401' 


SELECT *
FROM time_taken 
WHERE tablename LIKE 'LogTable[_]%[_]50M'

SELECT *
FROM space_used
WHERE tablename LIKE 'LogTable[_]%[_]50M'
ORDER BY reserved DESC




-- ################################################################ --
--                        LET'S COMPRESS
-- ################################################################ --



EXEC TestLogPerformance @tabletype = 'heap', @millionRows = 1, @compressed = 'PAGE'
EXEC TestLogPerformance @tabletype = 'CI', @millionRows = 1, @compressed = 'PAGE'

EXEC TestLogPerformance @tabletype = 'heap', @millionRows = 2, @compressed = 'PAGE'
EXEC TestLogPerformance @tabletype = 'CI', @millionRows = 2, @compressed = 'PAGE'

EXEC TestLogPerformance @tabletype = 'heap', @millionRows = 5, @compressed = 'PAGE'
EXEC TestLogPerformance @tabletype = 'CI', @millionRows = 5, @compressed = 'PAGE'

EXEC TestLogPerformance @tabletype = 'heap', @millionRows = 10, @compressed = 'PAGE'
EXEC TestLogPerformance @tabletype = 'CI', @millionRows = 10, @compressed = 'PAGE'

EXEC TestLogPerformance @tabletype = 'heap', @millionRows = 50, @compressed = 'PAGE'
EXEC TestLogPerformance @tabletype = 'CI', @millionRows = 50, @compressed = 'PAGE'


SELECT *
FROM time_taken 
WHERE compressed IN ('NO', 'PAGE')

SELECT *
FROM space_used
WHERE compressed IN ('NO', 'PAGE')
ORDER BY reserved DESC



-- ################################################################ --
--                  ENTER CLUSTER COLUMNSTORE INDEX
-- ################################################################ --


EXEC TestLogPerformance @tabletype = 'CCI', @millionRows = 1,   @compressed = 'COLUMNSTORE'
EXEC TestLogPerformance @tabletype = 'CCI', @millionRows = 2,   @compressed = 'COLUMNSTORE'
EXEC TestLogPerformance @tabletype = 'CCI', @millionRows = 5,   @compressed = 'COLUMNSTORE'
EXEC TestLogPerformance @tabletype = 'CCI', @millionRows = 10,  @compressed = 'COLUMNSTORE'
EXEC TestLogPerformance @tabletype = 'CCI', @millionRows = 50,  @compressed = 'COLUMNSTORE'
EXEC TestLogPerformance @tabletype = 'CCI', @millionRows = 100, @compressed = 'COLUMNSTORE'

EXEC TestLogPerformance @tabletype = 'CCI', @millionRows = 1,   @compressed = 'COLUMNSTORE_ARCHIVE'
EXEC TestLogPerformance @tabletype = 'CCI', @millionRows = 2,   @compressed = 'COLUMNSTORE_ARCHIVE'
EXEC TestLogPerformance @tabletype = 'CCI', @millionRows = 5,   @compressed = 'COLUMNSTORE_ARCHIVE'
EXEC TestLogPerformance @tabletype = 'CCI', @millionRows = 10,  @compressed = 'COLUMNSTORE_ARCHIVE'
EXEC TestLogPerformance @tabletype = 'CCI', @millionRows = 50,  @compressed = 'COLUMNSTORE_ARCHIVE'
EXEC TestLogPerformance @tabletype = 'CCI', @millionRows = 100, @compressed = 'COLUMNSTORE_ARCHIVE'

																						 
SELECT *
FROM time_taken 


SELECT *
FROM space_used
ORDER BY reserved DESC
GO

