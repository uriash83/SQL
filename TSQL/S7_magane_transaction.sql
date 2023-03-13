-- TRANSACTIONS

--Atomic
--Consistency
--Isolation
--Durability

-- to jestr implicit transaction
SELECT  * FROM [dbo].[tblEmployee]

-- to jest explicit transaction
begin transaction
SELECT  * FROM [dbo].[tblEmployee]
rollback/commit transaction

--tak nie mozna robic bo transakcja sie nei zakonczy i żadne inne zapytanie sie nie wykona 
begin transaction
SELECT  * FROM [dbo].[tblEmployee]

-- @@TRANCOUNT - level of transaction
select @@TRANCOUNT --0
begin tran
	select @@TRANCOUNT --1
	begin tran
		update [dbo].[tblEmployee] set EmployeeNumber = 122 where EmployeeNumber = 123
		select @@TRANCOUNT --2
	commit tran
	select @@TRANCOUNT --1
commit tran
select @@TRANCOUNT --0

-- jeśli zrobmy rollback w srodku zagniezdzonego transaction to wszystie transakcje beda rollback. dodatkowowo zeruje @@TRANCOUNT
-- rolback i commit również zeruja @@TRANCOIUNT



--- LEVEL ISOLATION
--- jesli zmienimy poziom na "read uncommited" 
set transaction isolation level read uncommited
-- to wtedy jeśli wykonamy 
begin transaction
SELECT  * FROM [dbo].[tblEmployee]
-- to można wykonac to co niżej mimo że wcześniejsza transakcja nie miała commita
--  to sie nazywa dirty read
begin tran
select * from [dbo].[tblEmployee]
commit tran

-- jesli zmienimy poziom na commited
set transaction isolation level read uncommited
--to wtedy wykonując
begin transaction
SELECT  * FROM [dbo].[tblEmployee]
-- oraz
begin tran
select * from [dbo].[tblEmployee]
commit tran
-- to drugie sie nie wykona bo czeka na commita z pierwszej transakcji


--INDEXES ---------

--seek - szuka kilku row - szybciej po indexie - select * from tblEmployee where id=2
--scan - szuka w całej tabeli - index nie ma znaczenia - select * from tblEmployee 
-- jesli nie mamy zdefiniowanego indexu na zrobomy select * from tblEmployee where id=2 to dalej będzie scan

-- primary key z deafultu tworzy index


-- clusterd index nie wymaga unique EmployeeNumber
-- clustered index sortuje od razu po stworzeniu indexu
-- unclustered index tego nie robi
-- clustered index moze byc  jeden , ale nonclusterd moge byc wicej
create clustered index idx_tblEmployee on tblEmployee(EmployeeNumber)

-- zamista tworzyc kilka indexów można zrobic include, i w zależnosci od tego co jest po select taki sobie dobera include
-- dodatkowo to co jest po include to jest leaf level
CREATE NONCLUSTERED INDEX idx_tblEmploy_Employ  
    ON dbo.tblEmploy(EmployeeNumber) include (EmployeeFirstName,EmployeeMiddleName, EmployeeLastName);


-- HASH
--1. Hash Join
--2. Nestest Join - One small table , one big table
--3. Merge Join - tWO TABLE, which one of tehem is sorted

-- na tych tabelach nie ma indexu
select E.EmployeeNumber, T.Amount
from [dbo].[tblEmployee] as E
left join [dbo].[tblTransact] as T
on E.EmployeeNumber = T.EmployeeNumber
-- na tych tablech jest index
select E.EmployeeNumber, T.Amount
from [dbo].[tblEmploy] as E
left join [dbo].[tblTransaction] as T
on E.EmployeeNumber = T.EmployeeNumber

-- dzieki tym indexom , zmienł sie typ z HASH Join ( górny ) na Merged ( dolny) oraz dzięki temu zmniejszyl się cost 


--SARG - Search Ergument, uzywają indexow
-- koszt jest duuzo mniejszy niz bez SARG,  w ponizszym przypasku 2x mniejszy
select E.EmployeeNumber, T.Amount
from [dbo].[tblEmploy] as E
left join [dbo].[tblTransaction] as T
on E.EmployeeNumber = T.EmployeeNumber
where E.EmployeeNumber / 10 = 34 -- to nie jest SARG bo operuje na funkcji dzielenia a nie bezposrednio na EmployeeNumber

select E.EmployeeNumber, T.Amount
from [dbo].[tblEmploy] as E
left join [dbo].[tblTransaction] as T
on E.EmployeeNumber = T.EmployeeNumber
where E.EmployeeNumber between 340 and 349 -- to jest SARG bo operuje bezposrednio na EmployeeNumber

-- ORDERED BY kosztuje bardzo duzo ok w powyzsztm przypadku to 40% całego kosztu



-- statystyki w formie tabeli
SET SHOWPLAN_ALL ON
go

select  D.Department, D.DepartmentHead, E.EmployeeNumber,E.EmployeeFirstName,E.EmployeeLastName 
from  [dbo].[tblEmploy] as E
left join [dbo].[tblDepartment] as D
on E.Department = D.Department
where D.Department = 'HR'

-- statystyki w formie 
SET STATISTICS IO ON
go

select  D.Department, D.DepartmentHead, E.EmployeeNumber,E.EmployeeFirstName,E.EmployeeLastName 
from  [dbo].[tblEmploy] as E
left join [dbo].[tblDepartment] as D
on E.Department = D.Department
where D.Department = 'HR'


--DYNAMIC QUERY
-- zły pomysł bo łatwo o SQL Injection
DECLARE @param varchar(1000) = '127';

DECLARE @sql nvarchar(max) =
    N'
    SELECT *
    FROM [dbo].[tblTransaction] AS T
    WHERE T.EmployeeNumber = ' + @param;

EXECUTE (@sql);

-- lepiej uzyc PARAMETIZED QUERY:
-- bo do @param nie można niczego dodac
EXECUTE sys.sp_executesql
DECLARE @param varchar(1000) = '127';
@statement = 
        N'SELECT * FROM [dbo].[tblTransaction] AS T WHERE T.EmployeeNumber = @EmployeeNumber;',
@params = N'@EmployeeNumber varchar(1000)',
@EmployeeNumber = @param;

-- DYNAMIC MANAGMENT VIEW
-- zwraca id aktualanie uzywanej database
select db_id() 


SELECT * FROM sys.dm_db_index_physical_stats  
    (DB_ID(N'70-461S7'), OBJECT_ID(N'dbo.tblEmployee'), NULL, NULL , 'DETAILED'); 