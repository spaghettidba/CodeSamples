USE AdventureWorks2012
GO


BEGIN TRAN

UPDATE Person.Person 
SET NameStyle = 0

DECLARE @waitString varchar(50) = 'WAITFOR DELAY ''00:00:'+ RIGHT('0' + CAST(ABS(CHECKSUM(NEWID())) % 10 AS varchar(2)),2) +''''
EXEC(@waitString)

UPDATE Production.Product
SET MakeFlag = MakeFlag / 1

ROLLBACK
GO

BEGIN TRAN

UPDATE Production.Product
SET MakeFlag = MakeFlag / 1

DECLARE @waitString varchar(50) = 'WAITFOR DELAY ''00:00:'+ RIGHT('0' + CAST(ABS(CHECKSUM(NEWID())) % 10 AS varchar(2)),2) +''''
EXEC(@waitString)

UPDATE Person.Person 
SET NameStyle = 0

ROLLBACK