create synonym EmployeeTable
for tblEmployee
go

select * from EmployeeTable

create synonym DateTable
for tblDate
go

select * from DateTable

create synonym RemoteTable
for server_name.database_name.schema_name.object_name -- PLER0065.Sirex.dbo.Comuters
go

select * from RemoteTable

-- Dynacmic SQL

select * from tblEmployee where EmployeeNumber = 129;
go
declare @command as varchar(255);
set @command = 'select * from tblEmployee where EmployeeNumber = 129;'
--set @command = 'Select * from tblTransaction'
execute (@command);
go
declare @command as varchar(255), @param as varchar(50);
set @command = 'select * from tblEmployee where EmployeeNumber = '
set @param ='129' -- '129 or 1=1'
execute (@command + @param); --sql injection potential
go
declare @command as nvarchar(255), @param as nvarchar(50);
set @command = N'select * from tblEmployee where EmployeeNumber = @ProductID'
set @param =N'129 or 1=1'
execute sys.sp_executesql @statement = @command, @params = N'@ProductID int', @ProductID = @param;--- it is much safer than upper