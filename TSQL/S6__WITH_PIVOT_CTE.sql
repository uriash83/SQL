
with MyTable
	as (
		select D.Department, EmployeeNumber, EmployeeFirstName, EmployeeLastName,
		rank() over(partition by D.Department order by E.EmployeeNumber) as Therank
		from tblDepartment as D join tblEmployee as E
		on E.Department = D.Department ),
	Transaction2014 as -- to jest table Transaction2014 ale juz nie trzeba pisac with 
	(select * from tblTransaction where DateOfTransaction <'2015-01-01')


select * from MyTable left join Transaction2014 on Transaction2014.EmployeeNum = MyTable.EmployeeNumber



------------------------------------
------ generating list of numbers ---
-------------------------------------

select * from tblTransaction as t
left join tblEmployee as E
on E.EmployeeNumber = t.EmployeeNum
where E.EmployeeNumber is null
order by T.EmployeeNum
----------------

-- to generuje liste numerom EmployeeNumber ktorych nie ma w tblTransaction
with Numbers as (
	select top(1125) row_Number() over(order by (select null)) as RowNumber from tblTransaction ) -- top1125 bo tyle jest userw w tbltransaction

select * from Numbers as N
left join tblTransaction as T
on N.RowNumber = T.EmployeeNum
where T.EmployeeNum is null
----------------------------------

select ROW_NUMBER() over(order by(select 1)) from sys.objects  O cross join sys.objects   P


------------------------------------
------ grouping  numbers ---
-------------------------------------


with Numbers as (
	select top(1125) row_Number() over(order by (select null)) as RowNumber from tblTransaction ), -- top1125 bo tyle jest userw w tbltransaction
	Transaction2014 as (
	select * from tblTransaction where DateOfTransaction >= '2014-01-01' and DateOfTransaction< '2015-01-01')

select * from Numbers as N
left join Transaction2014  as T
on N.RowNumber = T.EmployeeNum
where T.EmployeeNum is null



------------------------------------
------ Pivot ---
-------------------------------------
with myTable as
(select year(DateOfTransaction) as TheYear, month(DateOfTransaction) as TheMonth, Amount from tblTransaction)

select * from myTable
PIVOT (sum(Amount) for TheMonth in ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) as myPvt
ORDER BY TheYear 
go

--- replacing null by 0
with myTable as
(select year(DateOfTransaction) as TheYear, month(DateOfTransaction) as TheMonth, sum(Amount) as Amount from tblTransaction
group by year(DateOfTransaction),month(DateOfTransaction)
)
select TheYear, isnull([1],0) as [1], 
									isnull([2],0) as [2], 
									isnull([3],0) as [3],
									isnull([4],0) as [4],
									isnull([5],0) as [5],
									isnull([6],0) as [6],
									isnull([7],0) as [7],
									isnull([8],0) as [8],
									isnull([9],0) as [9],
									isnull([10],0) as [10],
									isnull([11],0) as [11],
									isnull([12],0) as [12] from myTable
PIVOT (sum(Amount) for TheMonth in ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])) as myPvt
ORDER BY TheYear 



------------------------------------
------ CTE----------- ---
-------------------------------------
-- CTE meas with 
-- self join
begin tran
	alter table tblEmployee
		add Manager int
		go
		update tblEmployee
		set Manager = ((EmployeeNumber-123)/10)+123
		where EmployeeNumber>123
		
		select E.EmployeeNumber, E.EmployeeFirstName, E.EmployeeLastName,
			   M.EmployeeNumber as ManagerNumber, M.EmployeeFirstName as ManagerFirstName, 
			   M.EmployeeLastName as ManagerLastName
		from tblEmployee as E
		left JOIN tblEmployee as M -- self join bo to tej samej tabeli
		on E.Manager = M.EmployeeNumber -- bo EmployeeNumber managera laczymy z mamagerem Employyera 

rollback tran


------------------------------------
------ RECURVISE CTE----------- ---
-------------------------------------


begin tran
	alter table tblEmployee
	add Manager int
	go
	update tblEmployee
	set Manager = ((EmployeeNumber-123)/10)+123
	where EmployeeNumber>123;
		with myTable as
		(select EmployeeNumber, EmployeeFirstName, EmployeeLastName, 0 as BossLevel --Anchor
		from tblEmployee
		where Manager is null
		UNION ALL --UNION ALL!!
		select E.EmployeeNumber, E.EmployeeFirstName, E.EmployeeLastName, myTable.BossLevel + 1 --Recursive
		from tblEmployee as E
		join myTable on E.Manager = myTable.EmployeeNumber
		) --recursive CTE

select * from myTable

rollback tran