-------------------------------------------------------------------
-- PROCEDURES --
-- roznica miedzy proc z views jest taka ze w proc mozna uzywac parametrów
-------------------------------------------------------------------
-- utworzenie procedury
if OBJECT_ID('NameEmployees','P') is not null
	drop proc NameEmployees
	go
	create proc NameEmployees(@EmployeeNumber int) as 
	begin
		if exists (select * from tblEmployee where EmployeeNumber = @EmployeeNumber)
		begin
			select 
				EmployeeNumber, EmployeeFirstName, EmployeeLastName
			from tblEmployee
			where EmployeeNumber = @EmployeeNumber
		end
		else
			select 'No data' -- to sie wykona zawsze
	end

-- 3 sposoby na wywołanie procedury 
go
NameEmployees 4

execute NameEmployees 321
exec NameEmployees 222

-- drop proc
if exists (select * from sys.procedures where name = 'NameEmployees') 
drop proc NameEmployees

--drop proc
if OBJECT_ID('NameEmployees','P') is not null
drop proc NameEmployees

-----------------------------------
-----------  IF -------------------
----------------------------------


if OBJECT_ID('NameEmployees','P') is not null
drop proc NameEmployees
go
create proc NameEmployees(@EmployeeNumber int) as 
begin
	if exists (select * from tblEmployee where EmployeeNumber = @EmployeeNumber)
	begin
		if @EmployeeNumber < 300
			begin
				select EmployeeNumber, EmployeeFirstName, EmployeeLastName
				from tblEmployee
				where EmployeeNumber = @EmployeeNumber
			end
		else
			begin
				select EmployeeNumber, EmployeeFirstName, EmployeeLastName, Department
				from tblEmployee
				where EmployeeNumber = @EmployeeNumber

				select *
				from tblTransaction
				where EmployeeNum = @EmployeeNumber
			end
	end
end
--------------------------
-- ----MANY ARGUMENTS-----
--------------------------
if OBJECT_ID('NameEmployees','P') is not null
drop proc NameEmployees
go
create proc NameEmployees(@EmployeeNumberFrom int, @EmployeeNumberTo int) as 
begin
	if exists (select * from tblEmployee where EmployeeNumber between @EmployeeNumberFrom and @EmployeeNumberTo)
	begin
		select EmployeeNumber, EmployeeFirstName, EmployeeLastName
		from tblEmployee
		where EmployeeNumber between @EmployeeNumberFrom and @EmployeeNumberTo					
	end
end
-- i wywolanie z named argument
execute NameEmployees 323,327
exec NameEmployees @EmployeeNumberTo = 127, @EmployeeNumberFrom = 123
select * from tblEmployee 

----------------------------------
----------------  WHILE ----------
---------------------------------
-- uzycie petli while bez brake
-- da sie ale trudne

if OBJECT_ID('NameEmployees','P') is not null
drop proc NameEmployees
go
create proc NameEmployees(@EmployeeNumberFrom int, @EmployeeNumberTo int) as 
begin
	if exists (select * from tblEmployee where EmployeeNumber between @EmployeeNumberFrom and @EmployeeNumberTo)
	begin
		declare @EmployeeNumber int = @EmployeeNumberFrom
		while @EmployeeNumber <= @EmployeeNumberTo
			begin 
				select EmployeeNumber, EmployeeFirstName, EmployeeLastName, @EmployeeNumber as Number
				from tblEmployee
				where EmployeeNumber = @EmployeeNumber	
				SET @EmployeeNumber = @EmployeeNumber + 1
				IF @EmployeeNumber = 126
					--GOTO Hello
			end
	end
	--Hello:
end
exec NameEmployees @EmployeeNumberTo = 127, @EmployeeNumberFrom = 123

--------------------------------
--------------RETURN -----------
--------------------------------
-- procedudy moga coś zwrócić

if OBJECT_ID('NameEmployees','P') is not null
drop proc NameEmployees
go
create proc NameEmployees(@EmployeeNumberFrom int, @EmployeeNumberTo int, @NumberOfRow int OUTPUT) as 
begin
	if exists (select * from tblEmployee where EmployeeNumber between @EmployeeNumberFrom and @EmployeeNumberTo)
	begin
		select EmployeeNumber, EmployeeFirstName, EmployeeLastName
		from tblEmployee
		where EmployeeNumber between @EmployeeNumberFrom and @EmployeeNumberTo
		SET @NumberOfRow = @@ROWCOUNT
	end
	else
		SET @NumberOfRow = 0
end
-- declare obowiązuje między go
go
DECLARE @NumberRows int
exec NameEmployees 4,5, @NumberRows OUTPUT
select @NumberRows
go
go
DECLARE @NumberRows int
exec NameEmployees @EmployeeNumberFrom = 123, @EmployeeNumberTo = 127,@NumberOfRow = @NumberRows OUTPUT
select @NumberRows
go

-- RETURN--
-- return 0 oznacza że zakoczyło sie success
-- ale nie da sie zwrocic wartosci w return
if OBJECT_ID('NameEmployees','P') is not null
drop proc NameEmployees
go
create proc NameEmployees(@EmployeeNumberFrom int, @EmployeeNumberTo int, @NumberOfRows int OUTPUT) as 
begin	
		if exists ( select * from tblEmployee where EmployeeNumber between @EmployeeNumberFrom and @EmployeeNumberTo)	
		begin
			select EmployeeNumber, EmployeeFirstName, EmployeeLastName
			from tblEmployee
			where EmployeeNumber between @EmployeeNumberFrom and @EmployeeNumberTo
			SET @NumberOfRows = @@ROWCOUNT
			RETURN 0
		end
		ELSE
		BEGIN
			SET @NumberOfRows = 0
			RETURN 1
		end
		

end
go
DECLARE @NumberRows int, @ReturnStatus int
exec @ReturnStatus = NameEmployees 123,127, @NumberRows OUTPUT
select @NumberRows, @ReturnStatus
go

