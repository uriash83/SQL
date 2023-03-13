-- OVER --
-- over - nie musimy uzywac group by, i segereguje tak jak group by
select A.EmployeeNumber, A.AttendanceMonth, A.NumberAttendance,
		sum(A.NumberAttendance) over() as TotalAttendance		
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber

select A.EmployeeNumber, A.AttendanceMonth, A.NumberAttendance,
		sum(A.NumberAttendance) over() as TotalAttendance,
		convert(decimal(18,7),A.NumberAttendance) / sum(A.NumberAttendance) over() * 100 as PercentageAttendance
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber


-- PARTITION
-- OVER
-- dodatkowo grupuje sumy wg EmployeeNumber i ustawia je wg EmployeeNumber
select A.EmployeeNumber, A.AttendanceMonth, A.NumberAttendance,
		sum(A.NumberAttendance) over(partition by A.EmployeeNumber order by A.AttendanceMonth) as TotalAttendance
		--convert(decimal(18,7),A.NumberAttendance) / sum(A.NumberAttendance) over() * 100 as PercentageAttendance
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber
where A.AttendanceMonth <'20150101'

-- ta suma z over patrza na całą table
sum(A.NumberAttendance) over() as TotalAttendance
-- a ta suma patrzy na poszczegilne miesiace dla kazdego rekordu
sum(A.NumberAttendance) over(partition by A.AttendanceMonth) as TotalAttendance
-- 
-- w kolumnie TotalAttendance dodaje stopniowo kazdy miesiac i segreguje po miesiacu a kasje z kazdym nowym EmployeeNumber
select A.EmployeeNumber, A.AttendanceMonth, A.NumberAttendance,
		sum(A.NumberAttendance) over(partition by A.EmployeeNumber order by A.AttendanceMonth) as TotalAttendance
		
-- w kolumnie TotalAttendance dodaje stopniowo kazdy miesiac i segreguje po miesiacu a kasje z kazdym nowym EmployeeNumber oraz AttendanceMonth
select A.EmployeeNumber, A.AttendanceMonth, A.NumberAttendance,
		sum(A.NumberAttendance) over(partition by A.EmployeeNumber, year(A.AttendanceMonth) order by A.AttendanceMonth) as TotalAttendance



		--convert(decimal(18,7),A.NumberAttendance) / sum(A.NumberAttendance) over(partition by A.EmployeeNumber) * 100 as PercentageAttendance
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber
where A.AttendanceMonth <'20150101'

-- ROW BETWEEN
-- bierze poprzedni, biezacy i nastepny rekod i dodaje je do siebie
select A.EmployeeNumber, A.AttendanceMonth, A.NumberAttendance,
		sum(A.NumberAttendance) over(partition by A.EmployeeNumber
									 order by A.AttendanceMonth
									 rows between 1 preceding and 1 following) as TotalAttendance
		
		--convert(decimal(18,7),A.NumberAttendance) / sum(A.NumberAttendance) over(partition by A.EmployeeNumber) * 100 as PercentageAttendance
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber
where A.AttendanceMonth <'20150101'


-- UNBOUNCED bierze wszystkie porzednie aż do biezacego, CURRENT ROW - bieze biezacy wiersz
select A.EmployeeNumber, A.AttendanceMonth, A.NumberAttendance,
		sum(A.NumberAttendance) over(partition by A.EmployeeNumber
									 order by A.AttendanceMonth
									 rows between unbounded preceding and current row ) as TotalAttendance		
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber
where A.AttendanceMonth <'20150101'

--- ROWS vs RANGE
-- rows bierze tylko jeden row i sprawdza poprzenie i następny, ale po ROW. Range bierze to co jest po partition ale również to co jest po ORDER i jesli sa takie same to dupikje je
-- RANGE musi byc w parze z UNBOUNDED oraz CORRENT ROW, czyli

--unbounded preceding and current row
--current row and unbounded following
--unbounded preceding and unbounded following - RANGE and ROWS are the same
-- rows jest szybszy od range
select A.EmployeeNumber, A.AttendanceMonth, A.NumberAttendance,
		sum(A.NumberAttendance) over(partition by A.EmployeeNumber		
									 order by A.AttendanceMonth
									 rows between unbounded preceding and current row)  as RowsTotal,
		sum(A.NumberAttendance) over(partition by A.EmployeeNumber
									 order by A.AttendanceMonth
									 range between unbounded preceding and current row)  as RangeTotal
from tblEmployee as E join (select * from tblAttendance UNION ALL select * from tblAttendance) as A
on E.EmployeeNumber = A.EmployeeNumber
where A.AttendanceMonth <'20150101'


------ ROW_NUMBER() 
select 
	E.EmployeeNumber, A.NumberAttendance, A.AttendanceMonth,
row_number() over(order by A.EmployeeNumber) as RowNumber
from
tblEmployee as E join tblAttendance as A
on 
E.EmployeeNumber = A.EmployeeNumber
-- partition jest kasowaniem 
select A.EmployeeNumber,A.AttendanceMonth,
		ROW_NUMBER() OVER(PARTITION BY A.EmployeeNumber ORDER BY E.EmployeeNumber, A.AttendanceMonth) as TheRowNumber,
		RANK() OVER(PARTITION BY A.EmployeeNumber ORDER BY E.EmployeeNumber, A.AttendanceMonth) as TheRank,
		DENSE_RANK() OVER(PARTITION BY A.EmployeeNumber ORDER BY E.EmployeeNumber, A.AttendanceMonth) as TheDenseRank
from tblEmployee as E join (select * from tblAttendance UNION ALL select * from tblAttendance) as A
on E.EmployeeNumber = A.EmployeeNumber



--w over musi być zawsze order by , wiec moze być null. Czyli że nie obchodzi mnie kolejność
select *, row_number() over(order by (select null)) from tblAttendance


--NTILE - dzieli na grupy
select A.EmployeeNumber,A.AttendanceMonth,A.NumberAttendance,
		NTILE(10) OVER(PARTITION BY A.EmployeeNumber 
		ORDER BY A.AttendanceMonth) as TheRowNumber
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber

-- first_value - pierwsza wartość na szeregu EmployeeNumber, 
-- last value będzie osatnia wartości równiez po AttendanceMonth czyli ostatnia w każdym wierszu
select A.EmployeeNumber, A.AttendanceMonth, 
A.NumberAttendance, 
first_value(NumberAttendance)
over(partition by E.EmployeeNumber order by A.AttendanceMonth) as FirstMonth,
last_value(NumberAttendance)
over(partition by E.EmployeeNumber order by A.AttendanceMonth) as LastMonth
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber

-- lag, lead,
-- tutaj przyklad wykorzstania , pokazuje różnice miedzy pierwszym a kolejnym wierszem
select A.EmployeeNumber, A.AttendanceMonth, 
A.NumberAttendance, 
lag(NumberAttendance,1)  over(partition by E.EmployeeNumber 
                            order by A.AttendanceMonth) as MyLag,
lead(NumberAttendance,1) over(partition by E.EmployeeNumber 
                            order by A.AttendanceMonth) as MyLead,
NumberAttendance - lag(NumberAttendance, 1)  over(partition by E.EmployeeNumber 
                            order by A.AttendanceMonth) as MyDiff
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber

-- cum_dist - cumulative distribution - dzieli który z kolejności to rekord przez  ilosc rekordów w partiion , 1/22 , 2,22....
-- perc_rank 
select A.EmployeeNumber, A.AttendanceMonth, 
A.NumberAttendance, 
CUME_DIST()    over(partition by E.EmployeeNumber 
               order by A.AttendanceMonth) as MyCume_Dist,
PERCENT_RANK() over(partition by E.EmployeeNumber 
                order by A.AttendanceMonth) as MyPercent_Rank, -- 
cast(row_number() over(partition by E.EmployeeNumber order by A.AttendanceMonth) as decimal(9,5))-- te 2 działają tak samo ale zrobione inaczje, łatwej dzięki CUME i PRECNET
/ count(*) over(partition by E.EmployeeNumber) as CalcCume_Dist,
cast(row_number() over(partition by E.EmployeeNumber order by A.AttendanceMonth) - 1 as decimal(9,5))
/ (count(*) over(partition by E.EmployeeNumber) - 1) as CalcPercent_Rank
from tblEmployee as E join tblAttendance as A
on E.EmployeeNumber = A.EmployeeNumber










-- SPATIAL ---
BEGIN TRAN
CREATE TABLE tblGeom
(GXY geometry, -- to jest typ geomatryczny
Description varchar(30),
IDtblGeom int CONSTRAINT PK_tblGeom PRIMARY KEY IDENTITY(1,1))
INSERT INTO tblGeom
VALUES (geometry::STGeomFromText('POINT (3 4)', 0),'First point'), -- to jest zmienna typu geometrycznego , :: musza byc, 0 SRID
       (geometry::STGeomFromText('POINT (3 5)', 0),'Second point'),
	   (geometry::Point(4, 6, 0),'Third Point'),
	   (geometry::STGeomFromText('MULTIPOINT ((1 2), (2 3), (3 4))', 0), 'Three Points')

Select * from tblGeom

ROLLBACK TRAN