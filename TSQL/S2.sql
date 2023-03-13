
CREATE TABLE [dbo].[tblEmployee](
	[EmployeeNumber] [int] NOT NULL,
	[EmployeeFirstName] [varchar](50) NOT NULL,
	[EmployeeMiddleName] [varchar](50) NULL,
	[EmployeeLastName] [varchar](50) NOT NULL,
	[EmployeeGovernmetID] [char](10) NULL,
	[DateOfBirth] [date] NOT NULL
) ON [PRIMARY]
GO

-- dodawanie kolumny
ALTER TABLE tblEmployee
ADD Department VARCHAR(10)

-- usuwanie kolumny
ALTER TABLE tblEmployee
DROP COLUMN Department

--modyfikowanie istniejącej kolumny
ALTER TABLE tblEmployee
ALTER COLUMN Department VARCHAR(20)


-- pierwsza litera to r,s lub t
WHERE [EmployeeLastName] LIKE '[r-t]%';
-- pierwsza litera nie jest r,s,t
WHERE [EmployeeLastName] LIKE '[^rst]%';
-- pierwsza litera musi byc %
WHERE [EmployeeLastName] LIKE '[%]%';

--------------------
--- SUMARIZE -------
--------------------


-- count() - to jest summarize function i musimy uzyc na kocnu  group by
-- klauzula wygląda tak
SELECT 
	year(DateOfBirth) AS yearBirth,
	count(*) AS dateCounter
FROM tblEmployee
GROUP BY DateOfBirth
-- ale MYSQL robi to w takiej kolejności
-- daletego nie można uzywac aliasow np. dateCounter
FROM tblEmployee
GROUP BY DateOfBirth
SELECT 
	year(DateOfBirth) AS yearBirth,
	count(*) AS dateCounter
-- alisny można uzywac w OREDER BY

-- zwraca pierwsza litere 
SELECT left(EmployeeFirstName,1) AS Initial FROM tblEmployee


-- HAVING - to samo to WHERE ale na po GROUP BY
USE[70-461]
SELECT 
	top (5)
	left(EmployeeFirstName,1) AS Initial, 
	count(*) as countOfIniital
FROM tblEmployee
GROUP BY left(EmployeeFirstName,1)
HAVING count(*)>50
ORDER BY count(*)


--KOLEJNOSC
-- tak jak ida lietry na klawiaturze z wyjatkiem W
-- S F W(wyjatek) G H O



-- derived table
SELECT Department
FROM
(
SELECT
	Department,
	count(distinct Department) as countDiscDepartment,
	count(*) as countDepartment
FROM tblEmployee
GROUP BY Department) AS newTable

-- inny sposób na stworzenie tablei
-- ta tabela ma kolumny: Deaprtment, DepartmentHead

-- into musi byc wtedy miedzy SELECT and FROM
SELECT distinct Department, convert(VARCHAR(20),N'') AS DepartmentHead
into tblDepartment
FROM tblEmployee


-- JOIN MANY TO MANY
-- oba warunki po ON musza byc spelnione
select * from 
	tblDepartment
join tblEmployee
on tblDepartment.Department = tblEmployee.Department
join tblTransaction
on tblEmployee.EmployeeNumber = tblTransaction.EmployeeNum


-- moznma tez pisac aliasami
select 
	D.DepartmentHead,
	sum(T.Amount) as SunOfAmount
from 
	tblDepartment as D
left join tblEmployee as E
on D.Department = E.Department
join tblTransaction as T
on E.EmployeeNumber = T.EmployeeNum
group by D.DepartmentHead
order by D.DepartmentHead

-- to troche bardziej skompilkowane
select * from 
(
select 
	E.EmployeeNumber as ENumber,
	E.EmployeeFirstName,
	E.EmployeeLastName,
	T.EmployeeNum as TNum,
	sum(T.Amount) as SunOfAmount
from 
	tblEmployee as E
left join tblTransaction as T 
on E.EmployeeNumber = T.EmployeeNum
where T.EmployeeNum is null
group by E.EmployeeNumber,T.EmployeeNum,E.EmployeeFirstName,E.EmployeeLastName

) as newTable
order by ENumber,TNum,EmployeeFirstName,EmployeeLastName



------------------------------------
begin transaction -- poczatek transacji
cos tam
rollback transaction -- wycofanie zmian
rollback tran



-- output wyswietla inserterd row( dlatego inserted , bo  uppdate najpierw usuwa a potem insert, taki zamiennik select * from ...)
-- ale tylko dal update,delete,inserter
begin tran
update tblTransaction
set EmployeeNum = 194
output inserted.* 
where EmployeeNum in ( 3,5,7,9)
rollback tran

-- to samo co wyzej ale wyswietli jeden wynik po update oraz wynik przed update
begin tran
update tblTransaction
set EmployeeNum = 194
output inserted.*, deleted.*
where EmployeeNum in ( 3,5,7,9)
rollback tran

