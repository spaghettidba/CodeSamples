WITH Baseline AS (
    SELECT 
        TRY_PARSE(RTRIM(CD.CounterDateTime) AS datetime) AS CounterDateTime,
        TRY_PARSE(RTRIM(D.LogStartTime) AS datetime) AS StartDate,
        CD.CounterValue, 
        DET.ObjectName,
        DET.CounterName,
        DET.InstanceName,
        DET.DefaultScale
    FROM [PerfAnalysis_DS3_CAPTURE].[dbo].[DisplayToID] AS D
    INNER JOIN [PerfAnalysis_DS3_CAPTURE].[dbo].[CounterData] AS CD
        ON D.GUID = CD.GUID
    INNER JOIN [PerfAnalysis_DS3_CAPTURE].[dbo].[CounterDetails] AS DET
        ON CD.CounterID = DET.CounterID
    WHERE D.DisplayString = 'PerfAnalysis_DS3_CAPTURE'
),
OffBaseline AS (
    SELECT *, 
        offset_seconds = DATEDIFF(second,StartDate, CounterDateTime),
        offset_minnutes = DATEDIFF(minute,StartDate, CounterDateTime)
    FROM Baseline
),
Benchmark AS (
    SELECT 
        TRY_PARSE(RTRIM(CD.CounterDateTime) AS datetime) AS CounterDateTime,
        TRY_PARSE(RTRIM(D.LogStartTime) AS datetime) AS StartDate,
        CD.CounterValue, 
        DET.ObjectName,
        DET.CounterName,
        DET.InstanceName,
        DET.DefaultScale
    FROM [PerfAnalysis_DS3_REPLAY].[dbo].[DisplayToID] AS D
    INNER JOIN [PerfAnalysis_DS3_REPLAY].[dbo].[CounterData] AS CD
        ON D.GUID = CD.GUID
    INNER JOIN [PerfAnalysis_DS3_REPLAY].[dbo].[CounterDetails] AS DET
        ON CD.CounterID = DET.CounterID
    WHERE D.DisplayString = 'PerfAnalysis_DS3_REPLAY'
),
OffBenchmark AS (
    SELECT *, 
        offset_seconds = DATEDIFF(second,StartDate, CounterDateTime),
        offset_minnutes = DATEDIFF(minute,StartDate, CounterDateTime)
    FROM Benchmark
)
SELECT 
    CAST(DATEADD(second,BA.offset_seconds,0) AS time) AS counter_time,
    BA.ObjectName, 
    BA.CounterName,
    BA.InstanceName,
    BA.DefaultScale,
    BA.CounterValue AS Baseline,  
    BE.CounterValue AS Benchmark
FROM OffBaseline AS BA
LEFT JOIN OffBenchmark AS BE
    ON SUBSTRING(BA.ObjectName,CHARINDEX(':', BA.ObjectName) + 1,LEN(BA.ObjectName)) = SUBSTRING(BE.ObjectName,CHARINDEX(':',BE.ObjectName) +1,LEN(BE.ObjectName))
    AND BA.CounterName = BE.CounterName
    AND ISNULL(BA.InstanceName,'') = ISNULL(BE.InstanceName,'')
    AND BA.offset_seconds = BE.offset_seconds
--WHERE BA.CounterName = 'Batch Requests/sec'
ORDER BY counter_time, ObjectName, CounterName, InstanceName




