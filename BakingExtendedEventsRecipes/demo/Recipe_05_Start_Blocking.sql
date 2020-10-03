BEGIN TRANSACTION

UPDATE s
SET s.ModifiedDate = GETDATE()
FROM AdventureWorks2016.dbo.AWBuildVersion AS s

-- SELECT 1