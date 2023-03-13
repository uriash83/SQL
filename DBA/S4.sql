select OBJECT_NAME(u.object_id) as name,* from sys.dm_db_index_usage_stats as U
join sys.indexes as I
on U.object_id = I.object_id
and U.index_id = I.index_id

-- lista nieuzywanych indexow

--select * from sys.indexes