SELECT TOP(1000) 
    client_app_name,
    database_id,
    DB_NAME(database_id) AS database_name,
    object_id,
    OBJECT_NAME(object_id, database_id) AS object_name,
    last_read,
    last_write,
    read_count,
    write_count
FROM XERecipes.dbo.Recipe_07_TableAudit;