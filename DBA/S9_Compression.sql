use [AdventureWorks2014]
select * from [HumanResources].[Employee]


select * from sys.indexes where OBJECT_NAME(object_id)='Department'

exec sp_estimate_data_compression_savings 'HumanResources','Department',2,NULL,Page


-- sparse column - zajmuje wiecej miejsca dla wartosci non-null, ale zero dla null. ogolnie sie nie oplaca

