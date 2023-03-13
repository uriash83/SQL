select * from tblDepartment
select * from tblEmployee
select * from tblTransaction


---------------------------------------
-------------WHERE --------------------
---------------------------------------

select * from tblTransaction as T
inner join tblEmployee as E
on T.EmployeeNum = E.EmployeeNumber
where EmployeeLastName like 'Y%'
order by T.EmployeeNum

select * from 
tblTransaction 
where EmployeeNum in (select EmployeeNumber from tblEmployee where EmployeeLastName like 'Y%')
order by EmployeeNum

select EmployeeNumber from tblEmployee where EmployeeLastName like 'Y%'


---------------------------------------
-------------WHERE  and  NOT ----------
---------------------------------------

select * from tblTransaction as T
inner join tblEmployee as E
on T.EmployeeNum = E.EmployeeNumber
where EmployeeLastName like 'Y%'
order by T.EmployeeNum

select * from 
tblTransaction 
where EmployeeNum in (select EmployeeNumber from tblEmployee where EmployeeLastName not like 'Y%')
order by EmployeeNum  -- must be in tblTransaction and tblEmployee and not 
					  -- INNNER JOIN

select * from 
tblTransaction 
where EmployeeNum not in (select EmployeeNumber from tblEmployee where EmployeeLastName like 'Y%')
order by EmployeeNum -- must be in tblTransaction and notin 126-129
					 -- LEFT JOIN
					 
select EmployeeNumber from tblEmployee where EmployeeLastName like 'Y%'



---------------------------------------
-------------ANy, SOME and ALL ----------
---------------------------------------


select * from 
tblTransaction 
where EmployeeNum <> any -- tozsame z = any oraz = some
(select EmployeeNumber from tblEmployee where EmployeeLastName like 'Y%')
order by EmployeeNum 

 --anything up to 126 AND
 --anything up to 127 AND
 --anything up to 128 AND
 --anything up to 129

 --ANY = anything up to 129
 --ALL = anything up to 126

 --any/some = OR
 --all = AND

 --126 <> all(126,127,128,129)
 --126<>126 AND 126<>127 AND 126<>128 AND 126<>129
 --FALSE    AND TRUE = FALSE

 --126 <> any(126,127,128,129)
 --126<>126 OR 126<>127 OR 126<>128 OR 126<>129
 --FALSE    OR TRUE = TRUE

 ---------------------------------------
------------- FROM  ----------
---------------------------------------

 select * from 
tblTransaction  as T
left join  
(select EmployeeNumber from tblEmployee where EmployeeLastName like 'Y%') as E -- to w nawiasie to jest derived table
on T.EmployeeNum = E.EmployeeNumber
order by E.EmployeeNumber

select * from 
tblTransaction as T
left join tblEmployee as E
on T.EmployeeNum = E.EmployeeNumber
where EmployeeLastName like 'Y%'

select * from 
tblTransaction as T
left join tblEmployee as E
on T.EmployeeNum = E.EmployeeNumber -- to query jest podobne do tego pierwszego 
and EmployeeLastName like 'Y%' -- to co jest za and tyczy sie tblEmployee

--select * from tblEmployee where EmployeeNumber = 123 order  by EmployeeNumber

--select * from tblTransaction  where EmployeeNum = 123 order by EmployeeNum

--select * from tblEmployee as E
--right join  tblTransaction as T
--on T.EmployeeNum = E.EmployeeNumber
--order by E.EmployeeNumber



 ---------------------------------------
------------- SELECT  ----------
---------------------------------------

select *,count(*) as ETER from tblEmployee as E
inner join tblTransaction as T
on T.EmployeeNum = E.EmployeeNumber
where EmployeeLastName like 'y%'
group by E.EmployeeNumber,E.EmployeeFirstName,E.EmployeeLastName

select * from tblEmployee
go
select E.EmployeeNumber,E.EmployeeFirstName, E.EmployeeLastName, count(E.EmployeeLastName)as NumEmploy, sum(Amount) as SunEmplo from tblEmployee as E
join tblTransaction as T
on T.EmployeeNum = E.EmployeeNumber
where E.EmployeeLastName like 'y%'
group by E.EmployeeNumber, E.EmployeeFirstName, E.EmployeeLastName
order by E.EmployeeNumber
-- inny sposob

select EmployeeNumber,EmployeeFirstName,EmployeeLastName, (select count(*)
		   from tblTransaction as T 
		   where T.EmployeeNum = E.EmployeeNumber
		    )as NumEmploy , -- taka derived table nie moze zwracac wiecj niz 1 row, wiec trzeba stosowac jakies aggregare funkction
		(select sum(Amount)
		   from tblTransaction as T 
		   where T.EmployeeNum = E.EmployeeNumber
		    )as SumEmplo
from tblEmployee as E
where EmployeeLastName like 'y%' -- corelated query
-- ten drugi sposob jest szybsy 35% -. 65%


 ---------------------------------------
------------- WHERE   ----------
---------------------------------------

select Amount,DateOfTransaction,EmployeeNum from tblTransaction as T
 join tblEmployee as E
on T.EmployeeNum = E.EmployeeNumber
where E.EmployeeLastName like 'y%'
-- oba sa tak samo szybkie 50/50

select * 
from tblTransaction as T
Where exists 
    (Select EmployeeNumber from tblEmployee as E where EmployeeLastName like 'y%' and T.EmployeeNum = E.EmployeeNumber)
order by EmployeeNum

select *
from 
(select * from [dbo].[tblEmployee]
where EmployeeNumber < 200) as dfsf


