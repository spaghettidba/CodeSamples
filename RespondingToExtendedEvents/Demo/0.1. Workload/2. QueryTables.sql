:CONNECT SQL2019

SET NOCOUNT ON
SELECT TOP 5 * FROM replayDB.dbo.testNumbers ORDER BY num DESC;
GO

:CONNECT SQL2016

SET NOCOUNT ON
SELECT TOP 5 * FROM replayDB.dbo.testNumbers ORDER BY num DESC
GO