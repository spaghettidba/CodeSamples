SELECT TOP(1000) *
FROM XERecipes.dbo.Recipe_08_WorkloadAnalysis;


SELECT 
    [snapshot_id],
    [server_principal_name], 
    SUM([tot_cpu]) AS tot_cpu, 
    SUM([tot_duration]) AS tot_duration, 
    SUM([tot_reads]) AS tot_reads, 
    SUM([tot_writes]) AS tot_writes, 
    SUM([execution_count]) AS execution_count
FROM XERecipes.dbo.Recipe_08_WorkloadAnalysis
GROUP BY 
    [snapshot_id],
    [server_principal_name]
ORDER BY 1,2;