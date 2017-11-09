:CONNECT (local)\SQL2014

SELECT TOP 10 * FROM replayDB.dbo.testNumbers ORDER BY num DESC;
GO

:CONNECT (local)\SQL2016

SELECT TOP 10 * FROM replayDB.dbo.testNumbers ORDER BY num DESC
GO