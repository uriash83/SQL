
-- wyswietli tylko raz hi bo zorientuje sie że hi jest zduplikowane
-- ponadto będą posotowane
-- union all zduplikuje hi wiec bada 4 linijki
select convert(char(5),'hi') as Greeting
union
select convert(char(11),'hello there') as GreetingNow
union 
select convert(char(11),'bonjour')
union
select convert(char(11),'hi')

-- sposob na utworzenie tymczasowej tabeli
with cte as (
select convert(tinyint, 45) as Mycolumn
union
select convert(bigint, 456)
)
select MyColumn
into tblTemp
from cte

-- tutaj podobnie tworzy nowa table
-- plus dodatkowo dodaje kolumne ShouldIDelete 
-- %3 to modulo 3
select *, Row_Number() over(order by (select null)) % 3 as ShouldIDelete
into tblTransactionNew
from tblTransaction
 
delete from tblTransactionNew
where ShouldIDelete = 1
 
update tblTransactionNew
set DateOfTransaction = dateadd(day,1,DateOfTransaction)
Where ShouldIDelete = 2
 
alter table tblTransactionNew
drop column ShouldIDelete


-- union vs union all
-- bo to druga jest zduplikwana
select * from tblTransaction --2502
union all -- union = 3322 vs union all 4170
select * from tblTransactionNew --1668

-- except
-- wyrzuca to co jest w 2 tabeli z pierwszej tabeli i wyswietla
select * from tblTransactionNew --2499
except
select * from tblTransaction --1666
--tab1
--1
--2
--3
--except
--tab2
--1
--2

--outpt = 3


--intersect wsplne dla obu tabel - 832 
select * from tblTransaction --2499
intersect
select * from tblTransactionNew --1666
order by EmployeeNum -- order by tylko na koncu


-- TA union TB - dodaje TA + TB i usuwa zdupikowane rekordy 
-- TA union al TB - dodaje TA + TB wraz ze zduplikowanymi
-- TA except TB - usuwa a TA te ktore istnieja w TB
-- TA intersect TB - zwraca tylok te które sa w TA i TB


-----------------
----- CASE ------
-----------------

  -- typ po then musi byc taki sam
declare @myOption as varchar(10) = 'Option C'

select case when @myOption = 'Option A' then 'First option' --convert(varchar(10),2)
            when @myOption = 'Option B' then 'Second option'
			--else 'No Option' 
			END as MyOptions


-- jesli pierwsza litera jest A to W myCol bedzie Letter A
-- jesli pierwsza litera jest B to W myCol bedzie Letter B
-- jesli nie to Neitehr letter
-- jesli nie było by else... i nie speniałoby zadnego warunku to zwroculoby NULL
SELECT *,
	  case when left(EmployeeGovernmetID,1)='A' then 'Letter A'
	       when left(EmployeeGovernmetID,1)='B' then 'Letter B'
		   else 'Neither letter' END + '.' as myCol
  FROM tblEmployee


SELECT *,
	  case when left(EmployeeGovernmetID,1)='A' then 'Letter A'
	       when EmployeeNumber > 200 then 'More then 200'
		   else 'Neither letter' END + '.' as myCol
  FROM tblEmployee




  --- to ponieżej jest alternatywa do ponizszego
SELECT *,
	  case left(EmployeeGovernmetID,1) when 'A' then 'Letter A'
	                                   when 'B' then 'Letter B'
		   else 'Neither letter' END + '.' as myCol
  FROM tblEmployee





-- isnull
-- funkcja sprawdza czy myNOption jest null, jesli nie , to zwraca jej wartosc a jesli jest null to zwraca No Option
declare @myNOption as varchar(10) = 'Option A'
select isnull(@myNOption, 'No Option') as MyOptions
go

-- coleace , moze miec wiele parametrów, i zwraca pierwsza wartośc która nie jest null, w tym przypadku Option A
declare @myFirstOption as varchar(10) ='Option A'
declare @mySecondOption as varchar(10) = 'Option B'

select coalesce(@myFirstOption, @mySecondOption, 'No option') as MyOptions
go


select isnull('ABC',1) as MyAnswer -- to działa
select coalesce('ABC',1) as MyOtherAnswer -- błąd konwersji




create table tblExample
(myOption nvarchar(10) null)
go
insert into tblExample (myOption)
values ('Option A')

select * from  tblExample
select * from tblIsNull 
select * from tblIsCoalesce


select coalesce(myOption, 'No option') as MyOptions
into tblIsCoalesce
from tblExample 


select case when myOption is not null then myOption else 'No option' end as myOptions from tblExample
go
select isnull(myOption, 'No option') as MyOptions
into tblIsNull
from tblExample 
go




select * from tblTransaction

select  * from tblTransactionNew
--select *, Row_Number() over(order by (select null)) % 3 as ShouldIDelete
--into tblTransactionNew
--from tblTransaction


--- MEGRE ---
-- matched - wtedy gdy klucze sa takie same w obu tabelach
-- not matched by target - wtedy gdy nie odnaleziono wg klucza , pasujacego rekordu w tabeli target

-- to nie dziala bo sa zduplikowane rows in tblTransacxtionNew
BEGIN TRAN
MERGE INTO tblTransaction as T -- source table 
USING tblTransactionNew as S -- target tabvle
ON T.EmployeeNum = S.EmployeeNum AND T.DateOfTransaction = S.DateOfTransaction
WHEN MATCHED THEN
    UPDATE SET Amount = T.Amount + S.Amount -- gdy sa rowne dodajemy kolumny
WHEN NOT MATCHED BY TARGET THEN -- gdy nie sa to kopiujemy z tabeli source do tabeli target
    INSERT ([Amount], [DateOfTransaction], [EmployeeNum])
	VALUES (S.Amount, S.DateOfTransaction, S.EmployeeNum);
ROLLBACK TRAN



-- poprawione to co wyzej
BEGIN TRAN
select count(*) as CounterBefore
from tblTransaction
MERGE INTO tblTransaction as T -- source table 
USING (select EmployeeNum,DateOfTransaction, sum(Amount) as TotalAmount from 
tblTransactionNew
group by EmployeeNum,DateOfTransaction) as S -- target tabvle
ON T.EmployeeNum = S.EmployeeNum AND T.DateOfTransaction = S.DateOfTransaction
WHEN MATCHED THEN
    UPDATE SET Amount = T.Amount + S.TotalAmount -- gdy sa rowne dodajemy kolumny
WHEN NOT MATCHED BY TARGET THEN -- gdy nie sa to kopiujemy z tabeli source do tabeli target
    INSERT ([Amount], [DateOfTransaction], [EmployeeNum])
	VALUES (S.TotalAmount, S.DateOfTransaction, S.EmployeeNum)
OUTPUT inserted.*, deleted.*;

select count(*) as CounterAfter
from tblTransaction
ROLLBACK TRAN
-------------------------------------------------------------------
-- to co wyzej plus dodanie kolumny comment z wlsciwym komentarzem
-------------------------------------------------------------------
BEGIN TRAN
--select count(*) as CounterBefore
--from tblTransaction

ALTER TABLE tblTransaction
ADD Comments varchar(50) NULL
go
MERGE INTO tblTransaction as T -- source table 
USING (select EmployeeNum,DateOfTransaction, sum(Amount) as TotalAmount from 
tblTransactionNew
group by EmployeeNum,DateOfTransaction) as S -- target tabvle
ON T.EmployeeNum = S.EmployeeNum AND T.DateOfTransaction = S.DateOfTransaction
WHEN MATCHED THEN
    UPDATE SET Amount = T.Amount + S.TotalAmount , Comments = 'Updated Row' -- gdy sa rowne dodajemy kolumny
WHEN NOT MATCHED BY TARGET THEN -- gdy nie sa to kopiujemy z tabeli source do tabeli target
    INSERT ([Amount], [DateOfTransaction], [EmployeeNum],Comments)
	VALUES (S.TotalAmount, S.DateOfTransaction, S.EmployeeNum, 'Inserted Row')
WHEN NOT MATCHED BY SOURCE THEN
	UPDATE SET Comments = 'Unchanged'
;
--OUTPUT inserted.*, deleted.*;
select * from tblTransaction
--select count(*) as CounterAfter
--from tblTransaction
ROLLBACK TRAN

use [70-461]
go
EXEC sp_rename 'tblTransaction.EmployeeNumber', 'EmployeeNum', 'COLUMN'
go
select * from   [dbo].[tblTransaction]



select EmployeeNum,DateOfTransaction, sum(Amount) as TotalAmount from 
tblTransactionNew
group by EmployeeNum,DateOfTransaction



SELECT COUNT(*) FROM [dbo].[tblEmployee] WHERE [EmployeeMiddleName] IS NULL 

SELECT ISNULL([EmployeeMiddleName],'Blank') FROM [dbo].[tblEmployee] 



drop trigger [tr_ViewByDepartment]
WHERE [EmployeeMiddleName] IS NULL





