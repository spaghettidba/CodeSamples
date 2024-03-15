-- date:    2024/03/15
-- author:  Gianluca Sartori - @spaghettidba
--
-- Estrae i "TOP expensive statement" dalla plan cache
--
-- Gli statement possono essere ordinati per:
--   avg_elapsed_time
--   avg_worker_time
--   avg_logical_reads
--   avg_logical_writes
--   avg_physical_reads



SELECT TOP(50)
	 execution_count
	,total_elapsed_time   / execution_count AS avg_elapsed_time
	,total_worker_time    / execution_count AS avg_worker_time
	,total_logical_reads  / execution_count AS avg_logical_reads
	,total_logical_writes / execution_count AS avg_logical_writes
	,total_physical_reads / execution_count AS avg_physical_reads
	,(
		-- Estrae il singolo statement dal testo complessivo del batch
		-- e converte lo statement in un XML, per attivare l'hyperlink in SSMS <<
		SELECT 
			CHAR(10)  
				+ SUBSTRING(
						 sql.text
						,(stats.statement_start_offset / 2) + 1
						,CASE stats.statement_end_offset 
							WHEN -1 THEN LEN(sql.text) 
							ELSE (stats.statement_end_offset - stats.statement_start_offset) / 2  + 1
						 END
					)
				+ CHAR(10) AS [processing-instruction(query)]
		FOR XML PATH(''), TYPE
	 ) AS statement
	,DB_NAME(sql.dbid) + '.'
		+ OBJECT_SCHEMA_NAME(sql.objectid, sql.dbid) + '.' 
		+ OBJECT_NAME(sql.objectid, sql.dbid) AS object_name
	,q_plan.query_plan
FROM sys.dm_exec_query_stats AS stats
CROSS APPLY sys.dm_exec_sql_text(stats.sql_handle) AS sql
CROSS APPLY sys.dm_exec_query_plan(stats.plan_handle) AS q_plan
ORDER BY avg_worker_time DESC

