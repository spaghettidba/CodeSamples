-- date:    2012/10/26
-- author:  Gianluca Sartori - @spaghettidba
--
-- Interroga i performance counters più significativi
-- e integra con alcune soglie raccomandate
--
DECLARE @counters TABLE (
	object_name nchar(128),
	counter_name nchar(128),
	threshold_description nvarchar(500),
	threashold_min int,
	threshold_max int
)


INSERT INTO @counters VALUES
('SQLServer:Access Methods'    ,'Forwarded Records/sec'        ,'1 forwarded record for every 10 batch requests',NULL,NULL),
('SQLServer:Access Methods'    ,'FreeSpace Scans/sec'          ,'1 freespace scan for every 10 batch requests'  ,NULL,NULL),
('SQLServer:Access Methods'    ,'Full Scans/sec'               ,'1 SQL Full Scan for every 1000 Index Searches' ,NULL,NULL),
('SQLServer:Access Methods'    ,'Index Searches/sec'           ,'1 SQL Full Scan for every 1000 Index Searches' ,NULL,NULL),
('SQLServer:Access Methods'    ,'Page Splits/sec'              ,'1 page split for every 20 batch requests'      ,NULL,NULL),
('SQLServer:Access Methods'    ,'Scan Point Revalidations/sec' ,'Greater than 10 per second'                    ,NULL,10  ),
('SQLServer:Access Methods'    ,'Workfiles Created/sec'        ,'1 workfile created for every 20 batch requests',NULL,NULL),
('SQLServer:Access Methods'    ,'Worktables Created/sec'       ,'Greater than 200 per second'                   ,NULL,200 ),
('SQLServer:Buffer Manager'    ,'Buffer cache hit ratio'       ,'Divided by its base, less than 97 percent'     ,97  ,NULL),
('SQLServer:Buffer Manager'    ,'Buffer cache hit ratio base'  ,'Base for calcutation of cach hit ratio'        ,NULL,NULL),
('SQLServer:Buffer Manager'    ,'Checkpoint pages/sec'         ,NULL                                            ,NULL,NULL),
('SQLServer:Buffer Manager'    ,'Free pages'                   ,'Less than 640'                                 ,640 ,NULL),
('SQLServer:Buffer Manager'    ,'Lazy writes/sec'              ,'Greater than 20'                               ,NULL,20  ),
('SQLServer:Buffer Manager'    ,'Page life expectancy'         ,'Less than 300 seconds'                         ,300 ,NULL),
('SQLServer:Buffer Manager'    ,'Page lookups/sec'             ,'1 page lookup for every 1 batch request'       ,NULL,NULL),
('SQLServer:Buffer Manager'    ,'Page reads/sec'               ,'Greater than 90'                               ,NULL,90  ),
('SQLServer:Buffer Manager'    ,'Page writes/sec'              ,'Greater than 90'                               ,NULL,90  ),
('SQLServer:General Statistics','Logins/sec'                   ,'Greater than 2'                                ,NULL,2   ),
('SQLServer:General Statistics','Logouts/sec'                  ,'Greater than 2'                                ,NULL,2   ),
('SQLServer:General Statistics','User Connections'             ,'Greater than 10'                               ,NULL,10  ),
('SQLServer:Latches'           ,'Latch Waits/sec'              ,NULL                                            ,NULL,NULL),
('SQLServer:Latches'           ,'Total Latch Wait Time (ms)'   ,NULL                                            ,NULL,NULL),
('SQLServer:Locks(*)'          ,'Lock Requests/sec'            ,NULL                                            ,NULL,NULL),
('SQLServer:Locks(*)'          ,'Lock Timeouts/sec'            ,NULL                                            ,NULL,NULL),
('SQLServer:Locks(*)'          ,'Lock Wait Time (ms)'          ,NULL                                            ,NULL,NULL),
('SQLServer:Locks(*)'          ,'Lock Waits/sec'               ,NULL                                            ,NULL,NULL),
('SQLServer:Locks(*)'          ,'Number of Deadlocks/sec'      ,'Greater than 0'                                ,NULL,0   ),
('SQLServer:Memory Manager'    ,'Memory Grants Pending'        ,'Greater than 0'                                ,NULL,0   ),
('SQLServer:Memory Manager'    ,'Target Server Memory(KB)'     ,'500MBs more than Total Server Memory'          ,NULL,500 ),
('SQLServer:Memory Manager'    ,'Total Server Memory (KB)'     ,NULL                                            ,NULL,NULL),
('SQLServer:SQL Statistics'    ,'Batch Requests/sec'           ,'Greater than 1000'                             ,NULL,1000),
('SQLServer:SQL Statistics'    ,'SQL Compilations/sec'         ,'1 SQL Compilation for every 100 Batch Requests',NULL,NULL),
('SQLServer:SQL Statistics'    ,'SQL Re-Compilations/sec'      ,'1 Re-Compilation for every 10 SQL Compilations',NULL,NULL)



IF @@servername LIKE '%\%'
	UPDATE cnt
	SET object_name = REPLACE(object_name, 'SQLServer:', 'MSSQL$' + CAST(SERVERPROPERTY('InstanceName') AS sysname) + ':')
	FROM @counters AS cnt




SELECT PC.object_name
	,PC.counter_name
	,PC.instance_name
	,PC.cntr_value
	,C.threshold_description
	,C.threashold_min
	,C.threshold_max
FROM sys.dm_os_performance_counters AS PC
INNER JOIN @counters AS C
	ON  PC.object_name  = C.object_name
	AND PC.counter_name = C.counter_name


