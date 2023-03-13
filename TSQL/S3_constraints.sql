
-- commit tran zatwierdza  zmiany
-- to niżej usuwa wyszystkie podwtójny wpisy
-- miało usuwać jeden z z nich ale nie działa:/
begin tran

delete  from tblEmployee where EmployeeGovernmetID = ANY (
select 
	EmployeeGovernmetID
from 
	tblEmployee
group by EmployeeGovernmetID
having count(EmployeeGovernmetID)>1

)
commit tran

-- dodawanie constraint
alter table tblTransaction
add constraint unqTransaction UNIQUE (Amount, DateOfTransaction, EmployeeNum)

-- usuwanie constraint
alter table tblTransaction
drop constraint unqTransaction

-- dodawanie constraint oraz  default value do constraint

alter table tblTransaction
add constraint defDateOfEntry DEFAULT GETDATE() for DateOfEntry;

-- definicja tabeli z constraint
create table tblTransaction2
(	
	Amount smallmoney not null,
	DateOfTransaction smalldatetime not null,
	EmployeeNumber int not null,
	DateOfEntry datetime null CONSTRAINT tblTransaction2_defDateOfEntry DEFAULT GETDATE()
)

-- by usunac kolumne ktora ma constraint najpierw usuwamy constraint a potem kolumne
alter table tblTransaction
drop constraint defDateOfEntry

alter table tblTransaction
drop column DateOfEntry

-- nocheck
-- nie sprawdza ograniczen do istniejacych juz rekordow
alter table tblEmployee with nocheck
add constraint chkMiddleName check
(REPLACE(EmployeeMiddleName,'.','') = EmployeeMiddleName or EmployeeMiddleName is null)


-- PRIMARY KEY 
-- tabela jest automaytycznie sortowana wg własnie PK
-- one per table, is clustered

-- nonclustered, czyli np nie będzie sortowania po PK
alter table tblEmployee
add constraint PK_tblEmployee PRIMARY KEY NONCLUSTERED (EmployeeNumber)

-- IDENTITY - podobny jak autoinkrement ( od jakiej liczby zaczyna, ile dodaje)
create table tblEmployee2
(EmployeeNumber int CONSTRAINT PK_tblEmployee2 PRIMARY KEY IDENTITY(1,1),
EmployeeName nvarchar(20))

-- usuwanie z tabeli jak niżej nie zeruje PK
delete from tblEmployee2

-- ale truncate zeruje PK
truncate table tblEmployee2

-- dzieki IDENTITY_INSERT możeby wpisac rekord z wymuszonym PK
SET IDENTITY_INSERT tblEmployee2 ON

insert into tblEmployee2(EmployeeNumber, EmployeeName)
values (38, 'My Name'), (39, 'My Name')

SET IDENTITY_INSERT tblEmployee2 OFF


-- @@ to zmienna globalna
-- oba zwracja to samo czyli aktualnie ostatnio uztye PK , ostanoi uzywanej tabeli
select @@IDENTITY
select SCOPE_IDENTITY()

-- zwraca ostatnoi uzyte PK danej tabeli
select IDENT_CURRENT('dbo.tblEmployee2')


-- FOREIGN KEY
-- moze byc NULL


ALTER TABLE tblTransaction ALTER COLUMN EmployeeNum INT NULL 
ALTER TABLE tblTransaction ADD CONSTRAINT DF_tblTransaction DEFAULT 124 FOR EmployeeNum
ALTER TABLE tblTransaction WITH NOCHECK
ADD CONSTRAINT FK_tblTransaction_EmployeeNumber FOREIGN KEY (EmployeeNum)
REFERENCES tblEmployee(EmployeeNumber)
-- w trakcie UPDATE moze byc: CASCASE , DEFAULT, NULL
ON UPDATE CASCADE
-- w trakcie delete moze byc: CASCADE, NO ACTION,
ON DELETE set default
UPDATE tblEmployee SET EmployeeNumber = 9123 Where EmployeeNumber = 123
--DELETE tblEmployee Where EmployeeNumber = 123
