-----------------
--- VIEWS
-- w komendach w views nie moze byc ORDER , ale zamist tego moze byc TOP
-- i musi byc jako batch, czyli zamkniety GO
use [70-461]

if exists (select * from INFORMATION_SCHEMA.VIEWS
where TABLE_NAME='ViewByDepartment' and TABLE_SCHEMA='dbo' )
	drop view "ViewByDepartment"
		
go
create view ViewByDepartment as
select 
top(100) percent 
D.Department,
T.EmployeeNum,
T.DateOfTransaction,
T.Amount as TotalAmount
from [dbo].[tblDepartment] as D
left join tblEmployee as E
on D.Department = E.Department
left join tblTransaction as T
on E.EmployeeNumber = T.EmployeeNum
where T.EmployeeNum between 120 and 139
--order by D.Department , T.EmployeeNum
go

--usuwanie views
select * from ViewByDepartment where EmployeeNum = 129 and DateOfTransaction = '2015-04-09'
delete from ViewByDepartment where EmployeeNum = 129 and DateOfTransaction = '2015-04-09'
select * from tblTransaction where EmployeeNum = 129
drop view dbo.ViewByDepartment

-- podejrzenie aktualnych views wraz z codem
select V.name, C.text from sys.views as V
join sys.syscomments as C
on V.object_id = C.id

--
select * from INFORMATION_SCHEMA.VIEWS
where TABLE_NAME='ViewByDepartment' and TABLE_SCHEMA='dbo'

-- procedury, funckje i views
select * from sys.syscomments

-- to zwraca nam tresc view
select OBJECT_DEFINITION(object_id('dbo.ViewByDepartment'))


go
-- secure
-- wtedy nie mozna ani odczytac tresci ani zawartosci view
if exists (select * from INFORMATION_SCHEMA.VIEWS
where TABLE_NAME='ViewSummary' and TABLE_SCHEMA='dbo' )
	drop view "ViewSummary"
go
create view ViewSummary WITH ENCRYPTION  as
select
D.Department,
T.EmployeeNum as ENum,
sum(T.Amount) as TotalAmount
from tblDepartment as D
left join tblEmployee as E
on D.Department = E.Department
left join tblTransaction as T
on E.EmployeeNumber = T.EmployeeNum
group by T.EmployeeNum, D.Department
go



-- DBO - skrót od Database Owner
-- to jest też schema

-- jeśli mam dostęp do dbo.View i ten View ma dosteo do Table1 i Table2 ale nie mam dostępu bezposrednio do Table1 i Table2 
-- to mam dostęp do Table 1 i 2 ale przez dbo.View

-- dodatni row to View
-- dodaje też do tabeli ale tylko jednej
insert into ViewByDepartment(EmployeeNum, DateOfTransaction, TotalAmount) values (132,'2015-07-07', 999.99)
-- nie mozna dodaawac do kilku tabel, jak niżej, bo wywali blad
insert into ViewByDepartment(Department, DateOfTransaction, TotalAmount) values ('Customer Relations',132,'2015-07-07', 999.99)

-- ale mozna nadpisac wartosci 
update ViewByDepartment
set EmployeeNum = 142
where EmployeeNum = 132


-- zeby uchornic sie przed nadpisaniem nalezy dodac na koncu WITH CHECK OPTION

ALTER view [dbo].[ViewByDepartment] as
select 
top(100) percent 
D.Department,
T.EmployeeNum,
T.DateOfTransaction,
T.Amount as TotalAmount
from tblDepartment as D
left join tblEmployee as E
on D.Department = E.Department
left join tblTransaction as T
on E.EmployeeNumber = T.EmployeeNum
where T.EmployeeNum between 120 and 139
WITH CHECK OPTION
--order by D.Department , T.EmployeeNum
GO

-- nie można ussuwac w view z kilku tabel
delete from ViewByDepartment
where TotalAmount = 999.99 and EmployeeNum = 132

-- ale mozna w ramach jednej tabeli
begin tran
delete from SimpleView
where Amount = 999.99 and EmployeeNum = 132
rollback tran

-- można usunac z underlying table ale nie z view
-- view sie opiera na underlyiing table