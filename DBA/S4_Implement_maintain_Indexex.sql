select OBJECT_NAME(u.object_id) as name,* from sys.dm_db_index_usage_stats as U
join sys.indexes as I
on U.object_id = I.object_id
and U.index_id = I.index_id

-- lista nieuzywanych indexow

--select * from sys.indexes

-- **********************************
---ATTACH DB

USE [master]
GO
EXEC master.dbo.sp_detach_db @dbname = N'StockTemp'
GO

-- DETACH DB
USE [master]
GO
CREATE DATABASE [StockTemp] ON 
( FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\StockTemp.mdf' ),
( FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\StockTemp_log.ldf' )
 FOR ATTACH
GO


