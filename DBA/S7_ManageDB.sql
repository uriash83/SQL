--*************************
-- Filegroups
--*************************

-- jeli chcemy przeniesc tbl do innego pliku to musimy wpierw stworzyc clustered-index
USE [DBAdatabase]

GO

CREATE CLUSTERED INDEX [ClusteredIndex-20230312-092551] ON [dbo].[tblTable]
(
	[Head1] ASC,
	[Head2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF)
ON [Third]

GO

-- a jesli tworzymy tbl od zera to mozna od razy przupisac grupe plikow bez tworzenia indexu

create table tbltable2
(Head1 int,Head2 int) on [Third]


--*************************
-- Partition
--*************************

-- ustawiamy Partition tak by rekordy z Dateofentry =< 2017 byly w filegroup PRIMARY
-- rekordy miedzy 2017 a 2022 w filegroup secondary a rekordy > 2022 byly w filegroup Third

-- PPM on tblPartitiobns -> strogare -> create partiorns

USE [DBAdatabase]
GO
BEGIN TRANSACTION
CREATE PARTITION FUNCTION [PartitionFunctiontblPartition](date) AS RANGE LEFT  --- tutaj powinno byc RIGHT
FOR VALUES (N'2018-01-01', N'2022-01-01')
--             <= 1          <= 2

CREATE PARTITION SCHEME [PartitionSchemetblPartition] AS PARTITION [PartitionFunctiontblPartition]
TO ([PRIMARY], [Secondary], [Third])
--      1           2          3

CREATE CLUSTERED INDEX [ClusteredIndex_on_PartitionSchemetblPartition_638142118584768383] ON [dbo].[tblPartitions]
(
	[DateOfEntry]
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PartitionSchemetblPartition]([DateOfEntry])


DROP INDEX [ClusteredIndex_on_PartitionSchemetblPartition_638142118584768383] ON [dbo].[tblPartitions]


COMMIT TRANSACTION

select * from [dbo].[tblPartitions]

use [DBAdatabase]
select *,$PARTITION.PartitionFunctiontblPartition(DateOfEntry) as PartitionEntry from [dbo].[tblPartitions]

-- DBAdatabase -> Storage -> partiononSchema

--*************************
-- manage multiTB database
--*************************
-- w przypadku duzych DB ( TeraByte ) mozna robic backupy i restore okreslonych FleGroup by zmniejszyszych czas backupu

--*************************
-- manage log file growth
--*************************

select * from sys.dm_db_log_space_usage

select * from sys.databases


--*************************
--DBCC - database console command
--*************************

dbcc shrinkfile(DBAdatabase_log,20) -- zmnijesza rozmiar log file
dbcc shrinkdatabase([DBAdatabase],20)


select * from sys.database_files
dbcc shrinkfile(3,truncateonly)
select * from sys.database_files 
-- to w zasadzie nie zadziaalo


--*************************
-- logins
--*************************

--Sequritty -> logins -access to SQL Server
-- dla kazdej DB jest Secirity -> users -> access to DB